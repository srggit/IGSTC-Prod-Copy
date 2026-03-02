angular.module('cp_app').controller('address_ctrl', function ($scope, $sce, $rootScope) {

    $scope.siteURL = siteURL;
    // Use page's userId (when ConsortiaAddress is standalone) or rootScope candidateId (when inside ApplicantPortal)
    $scope.addressUserId = (typeof userId !== 'undefined' && userId) ? userId : ($rootScope.candidateId || $rootScope.userId);
    $scope.countrytype = $rootScope.countrytype || (typeof countrytype !== 'undefined' ? countrytype : []);
    // Initialize so template bindings don't break before/if fetch returns null
    $scope.addressDetails = { Contacts: [{}] };

    $scope.selectedFile;
    $scope.proposalStage = $scope.proposalStage ? true : ($scope.secondstage ? true : false);
    $scope.mailingCountry = '';
    $scope.proposalStatusData = false;
    $scope.isSecondStage = false;

    $scope.isUploadingAFRYear1 = false;
    $scope.isUploadingAFRYear2 = false;
    $scope.isUploadingAFRYear3 = false;

    var maxStringSize = 6821208;
    var chunkSize = 750000;
    var attachment = '';
    var attachmentName = '';
    var fileSize = 0;
    var positionIndex = 0;
    var doneUploading = false;
    var maxFileSize = 0;

    console.log('$scope.proposalStage : ', $scope.proposalStage);
    console.log('$scope.secondstage : ', $scope.secondstage);

    $scope.filePreviewHandler = function (fileContent) {
        debugger;
        $scope.selectedFile = fileContent;

        console.log('selectedFile---', $scope.selectedFile);
        var jhj = $scope.selectedFile.userDocument.Attachments[0].Id;
        console.log(jhj);
        $scope.filesrec = $sce.trustAsResourceUrl(window.location.origin + '/ApplicantDashboard/servlet/servlet.FileDownload?file=' + $scope.selectedFile.userDocument.Attachments[0].Id);
        //$scope.filesrec = window.location.origin +'/ApplicantDashboard/servlet/servlet.FileDownload?file='+$scope.selectedFile.userDocument.Attachments[0].Id;
        // $('#file_frame').attr('src', $scope.selectedFile.ContentDistribution.DistributionPublicUrl);
        $('#file_frame').attr('src', $scope.filesrec);

        var myModal = new bootstrap.Modal(document.getElementById('filePreview'));
        myModal.show('slow');
        $scope.$apply();

        //.ContentDistribution.DistributionPublicUrl
    }

    $scope.getDataFromLocalStorage = function () {
        debugger;
        if (localStorage.getItem('candidateId')) {
            $rootScope.candidateId = localStorage.getItem('candidateId');
        }
        if (localStorage.getItem('apaId')) {
            $rootScope.apaId = localStorage.getItem('apaId');
            $scope.apaId = $rootScope.apaId;
        }
        if (localStorage.getItem('proposalId')) {
            $rootScope.proposalId = localStorage.getItem('proposalId');
            $scope.proposalId = $rootScope.proposalId;
        }
    }
    $scope.getDataFromLocalStorage();

    /**
     * Fetches proposal stage from Apex on page load
     */
    $scope.getProposalStage = function () {
        debugger;
        if ($rootScope.apaId && $rootScope.proposalId) {
            ApplicantPortal_Contoller.getProposalStageUsingProposalId($rootScope.proposalId, $rootScope.apaId, function (result, event) {
                debugger;
                if (event.status && result) {
                    $scope.proposalStatusData = (result.proposalStage != 'Draft' && result.proposalStage != null && result.proposalStage != undefined);
                    $rootScope.proposalStatusData = result.proposalStage;
                    $scope.pStage = result.stage;

                    $scope.isSecondStage = ($scope.pStage === '2nd Stage');
                    $rootScope.isSecondStage = $scope.isSecondStage;

                    console.log('$scope.proposalStatusData : ', $scope.proposalStatusData);
                    console.log('$rootScope.proposalStatusData : ', $rootScope.proposalStatusData);
                    console.log('---$scope.pStage--- : ', $scope.pStage);
                    console.log('---$scope.isSecondStage--- : ', $scope.isSecondStage);

                    // Update editor lock state after proposal stage is fetched
                    //$scope.updateEditorLockState();
                    $scope.$apply();
                }

            }, { escape: true });
        }
    }
    $scope.getProposalStage();

    $scope.getProjectdetils = function () {
        debugger;
        $scope.selectedFile = '';
        $('#file_frame').attr('src', '');
        ApplicantPortal_Contoller.getContactUserDoc($rootScope.contactId, $rootScope.proposalId, function (result, event) {
            debugger
            console.log('result return onload :: ');
            console.log(result);
            /**
             * Added by : Aman [ result != null ]
             * Date : 25 Aug 2023
             * Description : Added null check for the result. Issue was that Coordinator details were not coming up correctly.
             */
            if (event.status && result != null) {
                $scope.allDocs = result;
                var uploadCount = 0;
                for (var i = 0; i < $scope.allDocs.length; i++) {
                    debugger;
                    if ($scope.allDocs[i].userDocument.Name == 'DSIR') {
                        $scope.doc = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    }
                    if ($scope.allDocs[i].userDocument.Name == 'Annual Financial Report - Year 1') {
                        $scope.docAFR1 = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    }
                    if ($scope.allDocs[i].userDocument.Name == 'Annual Financial Report - Year 2') {
                        $scope.docAFR2 = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    }
                    if ($scope.allDocs[i].userDocument.Name == 'Annual Financial Report - Year 3') {
                        $scope.docAFR3 = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    }
                }
                $scope.$apply();
            }
        }, {
            escape: true
        })
    }
    $scope.getProjectdetils();

    var setUploadingFlagForType = function (type, isUploading) {
        if (type === 'Annual Financial Report - Year 1') {
            $scope.isUploadingAFRYear1 = isUploading;
        } else if (type === 'Annual Financial Report - Year 2') {
            $scope.isUploadingAFRYear2 = isUploading;
        } else if (type === 'Annual Financial Report - Year 3') {
            $scope.isUploadingAFRYear3 = isUploading;
        }
    };

    $scope.uploadFile = function (type, userDocId, fileId, maxSize, minFileSize) {
        debugger;
        setUploadingFlagForType(type, true);
        var file;

        file = document.getElementById(type).files[0];
        if (!file) {
            swal('info', 'You must choose a file before trying to upload it', 'info');
            setUploadingFlagForType(type, false);
            return;
        }

        fileName = file.name;
        var typeOfFile = fileName.split(".");
        lengthOfType = typeOfFile.length;
        if (typeOfFile[lengthOfType - 1] != "pdf") {
            swal('info', 'Please choose pdf file only.', 'info');
            setUploadingFlagForType(type, false);
            return;
        }
        console.log(file);
        maxFileSize = maxSize;
        if (file != undefined) {
            if (file.size <= maxFileSize) {

                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex = 0;
                    fileSize = attachment.length;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    debugger;
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(type, userDocId, null);
                    } else {
                        swal('info', 'Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".', 'info');
                        setUploadingFlagForType(type, false);
                        return;
                    }

                }
                fileReader.onerror = function (e) {
                    swal('info', 'There was an error reading the file.  Please try again.', 'info');
                    setUploadingFlagForType(type, false);
                    return;
                }
                fileReader.onabort = function (e) {
                    swal('info', 'There was an error reading the file.  Please try again.', 'info');
                    setUploadingFlagForType(type, false);
                    return;
                }

                fileReader.readAsBinaryString(file);  //Read the body of the file

            } else {
                swal('info', 'Your file is too large.  Please try again.', 'info');
                setUploadingFlagForType(type, false);
                return;
            }
        } else {
            swal('info', 'You must choose a file before trying to upload it', 'info');
            setUploadingFlagForType(type, false);
            return;
        }
    }

    $scope.uploadAttachment = function (type, userDocId, fileId) {
        debugger;
        var attachmentBody = "";
        // if (fileId == undefined) {
        //     fileId = " ";
        // }
        if (fileSize <= positionIndex + chunkSize) {
            debugger;
            attachmentBody = attachment.substring(positionIndex);
            doneUploading = true;
        } else {
            attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
        }
        console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
        ApplicantPortal_Contoller.doCUploadAttachmentAa(
            attachmentBody, attachmentName, fileId, userDocId,
            function (result, event) {
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                    swal('Error', (event.message || 'Upload failed. Please try again.'), 'error');
                    setUploadingFlagForType(type, false);
                } else if (event.status) {
                    if (doneUploading == true) {
                        $scope.getProjectdetils();

                        swal(
                            'Success',
                            'Uploaded Successfully!',
                            'success'
                        )
                        $scope.getProjectdetils();
                        // $scope.disableSubmit = false;
                        setUploadingFlagForType(type, false);

                    }
                    // $scope.getCandidateDetails();\
                    else {
                        debugger;
                        positionIndex += chunkSize;
                        $scope.uploadAttachment(type, userDocId, result);
                    }
                    $scope.showUplaodUserDoc = false;
                } else {
                    swal('Error', (event.message || 'Upload failed. Please try again.'), 'error');
                    setUploadingFlagForType(type, false);
                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    $scope.getDependentPicklistValues = function () {
        debugger;
        $scope.indianStates = [];
        $scope.germanStates = [];
        ApplicantPortal_Contoller.getFieldDependencies('Contact', 'Country__c', 'States__c', function (result, event) {
            debugger;
            if (event.status && result != null) {
                debugger;
                var indianStatesArray = result.India;
                $scope.indianStates = indianStatesArray.map(item => item == "Union Territory of J&amp;K" ? "Union Territory of J&K" : item);
                $scope.germanStates = result.Germany;
                $scope.allStates = result.India.concat(result.Germany);
                $scope.$apply();
            }
        }
        )
    }
    $scope.getDependentPicklistValues();

    $scope.getAddressDetails = function () {
        debugger;
        var idToUse = $scope.addressUserId;
        if (!idToUse) {
            console.warn('ConsortiaAddress: No userId/candidateId available for getAddressDetails. Ensure page is loaded with ?id=Login_Hash_Code or from ApplicantPortal.');
            return;
        }
        ApplicantPortal_Contoller.getAddressDetails(idToUse, function (result, event) {
            if (event.status && result != null) {
                debugger;
                $scope.addressDetails = result;


                console.log('onload');
                console.log(result);
                if ($scope.addressDetails.Name != undefined) {
                    $scope.addressDetails.Name = $scope.addressDetails.Name.replace(/&amp;/g, '&').replace(/&#39;/g, '\'').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'');
                }
                if ($scope.addressDetails.Contacts != null && $scope.addressDetails.Contacts.length > 0) {
                    if ($scope.addressDetails.Contacts[0].Department != undefined)
                        $scope.addressDetails.Contacts[0].Department = $scope.addressDetails.Contacts[0].Department.replace(/&amp;/g, '&').replace(/&#39;/g, '\'').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'');
                }
                if ($scope.addressDetails.BillingStreet != undefined)
                    $scope.addressDetails.BillingStreet = $scope.addressDetails.BillingStreet.replace(/&amp;/g, '&').replace(/&#39;/g, '\'').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'');
                if ($scope.addressDetails.BillingCity != undefined)
                    $scope.addressDetails.BillingCity = $scope.addressDetails.BillingCity.replace(/&amp;/g, '&').replace(/&#39;/g, '\'').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'');
                if ($scope.addressDetails.BillingState != undefined)
                    $scope.addressDetails.BillingState = $scope.addressDetails.BillingState.replace(/&amp;/g, '&').replace(/&#39;/g, '\'').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'');

                if ($scope.addressDetails.BillingCountry == 'India') {
                    $scope.stateList = $scope.indianStates;
                } else if ($scope.addressDetails.BillingCountry == 'Germany') {
                    $scope.stateList = $scope.germanStates;
                }

                console.log('$scope.addressDetails.Contacts[0].MailingCountry : ', $scope.addressDetails.Contacts[0].MailingCountry);
                if ($scope.addressDetails.Contacts[0].MailingCountry != undefined) {
                    $scope.mailingCountry = $scope.addressDetails.Contacts[0].MailingCountry;
                }
                console.log('$scope.mailingCountry : ', $scope.mailingCountry);
                //$scope.addressDetails.ShippingCountry = $scope.addressDetails.BillingCountry; 
                $scope.$apply();
            } else if (event.status && result == null) {
                console.warn('ConsortiaAddress: getAddressDetails returned null (no Contact found for hashcode or no Account).');
                $scope.addressDetails = { Contacts: [{}] };
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }
    $scope.getAddressDetails();
    $scope.onCountryChange = function () {
        debugger;

        if ($scope.addressDetails.MailingCountry == 'India') {
            $scope.stateList = $scope.indianStates;
        } else if ($scope.addressDetails.MailingCountry == 'Germany') {
            $scope.stateList = $scope.germanStates;
        }
        $scope.$apply();
    }
    $scope.redirectPageURL = function (pageName) {
        var link = document.createElement("a");
        link.id = 'someLink'; //give it an ID!
        link.href = "#/" + pageName;
        link.click();
    }

    $scope.saveAddressDetails = function () {
        debugger;

        if (!$scope.addressDetails || !$scope.addressDetails.Contacts || !$scope.addressDetails.Contacts[0]) {
            swal("Address Details", "Contact data is not loaded. Please refresh the page or ensure you have access.");
            return;
        }
        var contact0 = $scope.addressDetails.Contacts[0];

        if ($scope.addressDetails.Name == undefined || $scope.addressDetails.Name == "") {
            swal("Address Details", "Please Enter Institution/Industry Name.");
            $("#inst").addClass('border-theme');
            return;
        }
        // if($scope.addressDetails.BillingCountry == 'India' && $scope.addressDetails.Industry__c == true && $scope.addressDetails.DSIR_Recoginition_Details__c == undefined){
        //     swal("Address Details", "Please Enter DSIR Number.");
        //     $("#dsir").addClass('border-theme');
        //     return;
        // }
        if (contact0.Title == undefined || contact0.Title == "") {
            swal("Address Details", "Please select salutation");
            $("#ddTitle").addClass('border-theme');
            return;
        }
        if (contact0.Name == undefined || contact0.Name == "") {
            swal("Address Details", "Please Enter Head of Project.");
            $("#head").addClass('border-theme');
            return;
        }
        if (contact0.Phone == undefined || contact0.Phone == "") {
            swal("Address Details", "Please Enter Phone.");
            $("#phone").addClass('border-theme');
            return;
        }
        if (contact0.Department == undefined || contact0.Department == "") {
            swal("Address Details", "Please Enter Department.");
            $("#dept").addClass('border-theme');
            return;
        }

        if ($scope.addressDetails.BillingStreet == undefined || $scope.addressDetails.BillingStreet == "") {
            swal("Address Details", "Please Enter Street.");
            $("#IStreet").addClass('border-theme');
            return;
        }
        if ($scope.addressDetails.BillingCity == undefined || $scope.addressDetails.BillingCity == "") {
            swal("Address Details", "Please Enter City.");
            $("#ICity").addClass('border-theme');
            return;
        }
        if ($scope.addressDetails.BillingCountry == undefined || $scope.addressDetails.BillingCountry == "") {
            swal("Address Details", "Please Enter Country.");
            $("#ICountry").addClass('border-theme');
            return;
        }
        if ($scope.addressDetails.BillingState == undefined || $scope.addressDetails.BillingState == "") {
            swal("Address Details", "Please Enter State.");
            $("#IState").addClass('border-theme');
            return;
        }
        if ($scope.addressDetails.BillingPostalCode == undefined || $scope.addressDetails.BillingPostalCode == "") {
            swal("Address Details", "Please Enter Post Code.");
            $("#IPcode").addClass('border-theme');
            return;
        }

        if ($scope.addressDetails.Industry__c == true) {
            if ($scope.addressDetails.Year_Of_Establishment__c == undefined || $scope.addressDetails.Year_Of_Establishment__c == "") {
                swal("Address Details", "Please Enter Year Of Establishment.");
                $("#establish").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.Main_Business_Area__c == undefined || $scope.addressDetails.Main_Business_Area__c == "") {
                swal("Address Details", "Please Enter Main Business Area.");
                $("#business").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.NumberOfEmployees == undefined || $scope.addressDetails.NumberOfEmployees === "") {
                swal("Address Details", "Please Enter Number Of Permanent Employees.");
                $("#employees").addClass('border-theme');
                return;
            }
            var numEmpCheck = parseInt($scope.addressDetails.NumberOfEmployees, 10);
            if (isNaN(numEmpCheck) || numEmpCheck < 0) {
                swal("Address Details", "Please enter a valid number for Number Of Permanent Employees.");
                $("#employees").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.Infrastructural_Facilities__c == undefined || $scope.addressDetails.Infrastructural_Facilities__c == "") {
                swal("Address Details", "Please Enter Infrastructural Facilities.");
                $("#facility").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.Domain_Expertise_Available__c == undefined || $scope.addressDetails.Domain_Expertise_Available__c == "") {
                swal("Address Details", "Please Enter Domain Expertise Available/Existing.");
                $("#domain").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.Ownership_Profile__c == undefined || $scope.addressDetails.Ownership_Profile__c == "") {
                swal("Address Details", "Please Enter Ownership profile.");
                $("#ownership").addClass('border-theme');
                return;
            }
            if ($scope.addressDetails.Last_Year_s_Balance__c == undefined || $scope.addressDetails.Last_Year_s_Balance__c == "") {
                swal("Address Details", "Please Enter Last year's balance.");
                $("#balance").addClass('border-theme');
                return;
            }

            if ($scope.mailingCountry == 'India' && $scope.proposalStage) {
                if (!$scope.docAFR1 || $scope.docAFR1.userDocument.Status__c != 'Uploaded') {
                    swal("Address Details", "Please upload Annual Financial Report - Year 1.", "info");
                    return;
                }
                if (!$scope.docAFR2 || $scope.docAFR2.userDocument.Status__c != 'Uploaded') {
                    swal("Address Details", "Please upload Annual Financial Report - Year 2.", "info");
                    return;
                }
                if (!$scope.docAFR3 || $scope.docAFR3.userDocument.Status__c != 'Uploaded') {
                    swal("Address Details", "Please upload Annual Financial Report - Year 3.", "info");
                    return;
                }
            } else if ($scope.mailingCountry == 'Germany' && $scope.proposalStage) {
                if (!$scope.docAFR1 || $scope.docAFR1.userDocument.Status__c != 'Uploaded') {
                    swal("Address Details", "Please upload Annual Financial Report - Year 1.", "info");
                    return;
                }
            }
        }

        $scope.contactList = [];
        if ($scope.addressDetails.Contacts != undefined) {
            $scope.contactList.push($scope.addressDetails.Contacts[0]);
        }
        $scope.addressDetails['Shipping_State__c'] = $scope.addressDetails['BillingState'];

        // Coerce numeric fields so Apex deserialization doesn't fail (Account.NumberOfEmployees is Integer)
        var numEmp = parseInt($scope.addressDetails.NumberOfEmployees, 10);
        $scope.addressDetails.NumberOfEmployees = (!isNaN(numEmp) && numEmp >= 0) ? numEmp : null;
        var yearEst = parseInt($scope.addressDetails.Year_Of_Establishment__c, 10);
        if ($scope.addressDetails.Year_Of_Establishment__c != null && $scope.addressDetails.Year_Of_Establishment__c !== '') {
            $scope.addressDetails.Year_Of_Establishment__c = (!isNaN(yearEst) && yearEst >= 1000 && yearEst <= 9999) ? yearEst : $scope.addressDetails.Year_Of_Establishment__c;
        }

        delete ($scope.addressDetails['Contacts']);
        delete ($scope.addressDetails['$$hashKey']);
        delete ($scope.addressDetails['stateList']);
        delete ($scope.addressDetails['RecordTypeId']);
        // Ensure Contact has AccountId so save persists correctly
        if ($scope.contactList.length > 0 && $scope.addressDetails.Id) {
            $scope.contactList[0].AccountId = $scope.addressDetails.Id;
        }
        $("#btnSubmit").html('<i class="fa-solid fa-spinner fa-spin-pulse me-3"></i>Please wait...');
        debugger;
        ApplicantPortal_Contoller.saveAddressDetails($scope.addressDetails, $scope.contactList, function (result, event) {
            debugger;
            $("#btnSubmit").html('<i class="fa-solid fa-check me-2"></i>Save and Next');
            if (event.type === 'exception' || !event.status || result !== 'success') {
                var errMsg = (result && typeof result === 'string') ? result : (event.message || 'Save failed. Please try again.');
                swal("Address Details", errMsg, "error");
                $scope.$apply();
                return;
            }
            swal({
                title: "Success",
                text: "Consortium Details have been saved successfully.",
                icon: "success",
                buttons: true,
                dangerMode: false,
            }).then((willDelete) => {
                if (willDelete) {
                    $scope.disableSubmit = true;
                    $scope.redirectPageURL('ConsortiaContacts');
                    $scope.$apply();
                } else {
                    return;
                }
            });
        },
            { escape: true }
        )
    }

    $scope.removeClass2 = function (controlid) {
        $("#" + controlid + "").removeClass('border-theme');
    }
});
angular.module('cp_app').controller('sign_Ctrl', function ($scope, $sce, $rootScope) {

    debugger;

    // Fetching the proposalId from Local Storage
    if (localStorage.getItem('proposalId')) {
        $rootScope.proposalId = localStorage.getItem('proposalId');
        console.log('Loaded proposalId from localStorage:', $rootScope.proposalId);
    }
    if (localStorage.getItem('apaId')) {
        $rootScope.apaId = localStorage.getItem('apaId');
        console.log('Loaded apaId from localStorage:', $rootScope.apaId);
    }   

    // Get yearlyCallId from LocalStorage
    if (localStorage.getItem('yearlyCallId')) {
        $rootScope.yearlyCallId = localStorage.getItem('yearlyCallId');
        console.log('Loaded yearlyCallId from localStorage:', $rootScope.yearlyCallId);
    }

    // Get candidateId from LocalStorage
    if (localStorage.getItem('candidateId')) {
        $rootScope.candidateId = localStorage.getItem('candidateId');
        console.log('Loaded candidateId from localStorage:', $rootScope.candidateId);
    }

    $scope.getProposalStage = function () {
        debugger;
        if ($rootScope.apaId && $rootScope.proposalId) {
            ApplicantPortal_Contoller.getProposalStageUsingProposalId($rootScope.proposalId, $rootScope.apaId, function (result, event) {
                debugger;
                if (event.status && result) {
                    $scope.proposalStage = (result.proposalStage != 'Draft' && result.proposalStage != null && result.proposalStage != undefined);
                    $rootScope.proposalStage = $scope.proposalStage;
                    $scope.$apply();
                }
            }, { escape: true });
        }
    } 
    $scope.getProposalStage();

    $scope.siteURL = siteURL;
    $rootScope.projectId;
    $rootScope.proposalId;
    $rootScope.apaId;
    $scope.decDetails = {};
    $scope.disableUploadButton = true;
    $scope.signDate;
    $scope.signDate2;
    $scope.checkbox = {};
    $scope.isLoading = false;


    // LATEST METHOD
    // $scope.getProposalConsentCheckbox = function () {
    //     debugger;
    //     console.log(' ----------------- getProposalConsentCheckbox() --------------------- ');

    //     WorkshopController.getConsentCheckbox($rootScope.proposalId, function (result, event) {
    //         if (event.status) {

    //             $scope.checkbox = result;

    //             if (result.Contacts && Array.isArray(result.Contacts) && result.Contacts.length > 0) {

    //                 for (var i = 0; i < result.Contacts.length; i++) {

    //                     if (result.Contacts[i].Account.Country_Type === "India") {
    //                         $scope.indianCo = result.Contacts[i].Id;
    //                     }
    //                     else if (result.Contacts[i].Account.Country_Type === "Germany") {
    //                         $scope.germanCo = result.Contacts[i].Id;
    //                     }
    //                 }

    //                 // First contact sign date
    //                 if (result.Contacts[0].Declaration_Sign_Date) {
    //                     $scope.signDate = new Date(result.Contacts[0].Declaration_Sign_Date);
    //                 }

    //                 // Second contact sign date
    //                 if (result.Contacts.length > 1 && result.Contacts[1].Declaration_Sign_Date) {
    //                     $scope.signDate2 = new Date(result.Contacts[1].Declaration_Sign_Date);
    //                 }

    //             } else {
    //                 console.warn("⚠ No Contacts returned from Apex");
    //                 result.Contacts = [];
    //             }

    //             $scope.$apply();
    //         }
    //     }, { escape: true });
    // };

    // $scope.getProposalConsentCheckbox();

    function initConsentCheckbox() {
        if (!$rootScope.proposalId) {
            console.warn('proposalId not found');
            return;
        }

        if (typeof Proposal_Controller !== 'undefined') {
            $scope.getProposalConsentCheckbox();
        } else {
            setTimeout(initConsentCheckbox, 200);
        }
    }

    initConsentCheckbox();

    // NEW METHOD

    $scope.getProposalConsentCheckbox = function () {
        debugger;
        $scope.isLoading = true;
        console.log(' ----------------- getProposalConsentCheckbox() --------------------- ');


        // ApplicantPortal_Contoller.getConsentCheckbox($rootScope.candidateId, function (result, event) {
        WorkshopController2.getConsentCheckbox($rootScope.proposalId, function (result, event) {
            if (event.status) {
                debugger;

                $scope.checkbox = result;

                // SAFE GUARD AGAINST undefined / null / empty
                if (result.Contacts && Array.isArray(result.Contacts) && result.Contacts.length > 0) {

                    console.log("Contacts available:", result.Contacts);

                    for (var i = 0; i < result.Contacts.length; i++) {
                        if (result.Contacts[i].Account.Country_Type === "India") {
                            $scope.indianCo = result.Contacts[i].Id;
                        } else if (result.Contacts[i].Account.Country_Type === "Germany") {
                            $scope.germanCo = result.Contacts[i].Id;
                        }

                    }

                    // Only if at least ONE contact exists:
                    if (result.Contacts[0].Declaration_Sign_Date__c) {
                        // $scope.signDate = new Date(result.Contacts[0].Declaration_Sign_Date);
                        $scope.signDate = toInputDate(result.Contacts[0].Declaration_Sign_Date);

                    } else {
                        $scope.signDate = new Date($rootScope.signDate);
                    }
                    console.log('result.Contacts[0].Declaration_Sign_Date ---> ', result.Contacts[0].Declaration_Sign_Date);
                    console.log('signDate ---> ', $scope.signDate);

                    // Only if second contact exists:
                    if (result.Contacts.length > 1 &&
                        result.Contacts[1].Declaration_Sign_Date__c) {

                        // $scope.signDate2 = new Date(result.Contacts[1].Declaration_Sign_Date);
                        $scope.signDate2 = toInputDate(result.Contacts[1]?.Declaration_Sign_Date);

                    } else {
                        $scope.signDate2 = new Date($rootScope.signDate);
                    }
                    console.log('signDate2 ---> ', $scope.signDate2);
                    console.log('result.Contacts[1].Declaration_Sign_Date ---> ', result.Contacts[1].Declaration_Sign_Date);
                } else {
                    console.warn("No Contacts returned from Apex");
                    result.Contacts = []; // Prevent future errors
                }
                $scope.isLoading = false;
                $scope.$apply();
            }
             else {
                $scope.isLoading = false;
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }
    $scope.getProposalConsentCheckbox();

    function toInputDate(val) {
        if (!val) return null;

        var d = new Date(val);

        // Convert to yyyy-MM-dd (required by input[type=date])
        var month = ('0' + (d.getMonth() + 1)).slice(-2);
        var day = ('0' + d.getDate()).slice(-2);

        return d.getFullYear() + '-' + month + '-' + day;
    }


    /*
    // OLD METHOD
    // Keep a single definition of getProposalConsentCheckbox
    $scope.getProposalConsentCheckbox = function () {
        debugger;
        WorkshopController.getConsentCheckbox($rootScope.proposalId, function (result, event) {
            if (event.status) {
                debugger;
                $scope.checkbox = result;

                console.log('$scope.checkbox : ', $scope.checkbox);
                console.log('result : ', result);
                console.log('result.Contacts__r : ', result.Contacts__r)

                for (var i = 0; i < result.Contacts__r.length; i++) {
                    if (result.Contacts__r[i].Account.Country_Type__c == "India") {
                        $scope.indianCo = result.Contacts__r[i].Id;
                    } else if (result.Contacts__r[i].Account.Country_Type__c == "Germany") {
                        $scope.germanCo = result.Contacts__r[i].Id;
                    }
                }
                if (result.Contacts__r[0].Declaration_Sign_Date__c != undefined) {
                    $scope.signDate = new Date(result.Contacts__r[0].Declaration_Sign_Date__c);
                } else {
                    $scope.signDate = new Date($rootScope.signDate);
                }
                if (result.Contacts__r[1].Declaration_Sign_Date__c != undefined) {
                    $scope.signDate2 = new Date(result.Contacts__r[1].Declaration_Sign_Date__c);
                } else {
                    $scope.signDate2 = new Date($rootScope.signDate);
                }
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }
    $scope.getProposalConsentCheckbox();
    */

    $scope.getProjectdetils = function () {
        debugger;
         $scope.isLoading = true;
        // ApplicantPortal_Contoller.getAllUserDoc($rootScope.candidateId, function (result, event) {
        WorkshopController2.getAllUserDoc($rootScope.proposalId, function (result, event) {
            debugger
            console.log('result return onload :: ');
            console.log(result);
            if (event.status) {
                $scope.allDocs = result;
                for (var i = 0; i < $scope.allDocs.length; i++) {
                    if ($scope.allDocs[i].userDocument.Name == 'Coordinator 1 Signature') {
                        $scope.doc = $scope.allDocs[i];
                    }
                    if ($scope.allDocs[i].userDocument.Name == 'Coordinator 2 Signature') {
                        $scope.doc2 = $scope.allDocs[i];
                    }
                }
                $scope.isLoading = false;
                $scope.$apply();
            }
             else {
                $scope.isLoading = false;
                $scope.$apply();
            }
        }, {
            escape: true
        })
    }
    $scope.getProjectdetils();

    $scope.selectedFile;

    $scope.filePreviewHandler = function (fileContent) {
        debugger;
        $scope.selectedFile = fileContent;

        console.log('selectedFile---', $scope.selectedFile);

        $('#file_frame').attr('src', $scope.selectedFile.ContentDistribution.DistributionPublicUrl);

        var myModal = new bootstrap.Modal(document.getElementById('filePreview'))
        myModal.show('slow');
        $scope.$apply();

        //.ContentDistribution.DistributionPublicUrl
    }

    $scope.uploadFile = function (type, userDocId, fileId, maxSize, minFileSize) {
        debugger;
        $scope.showSpinnereditProf = true;
        var file;
        var maxStringSize = 1048576;
        var chunkSize = 950000;

        file = document.getElementById(type).files[0];
        fileName = file.name;
        var typeOfFile = fileName.split(".");
        lengthOfType = typeOfFile.length;
        if (typeOfFile[lengthOfType - 1] == "jpg" || typeOfFile[lengthOfType - 1] == "jpeg") {

        } else {
            swal('Info', 'Please choose jpg/jpeg file only.', 'info');
            return;
        }
        console.log(file);
        maxFileSize = maxSize;
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                if (file.size < minFileSize) {
                    swal('Info', 'Your file is too small. Please try again.', 'info');
                    return;
                    // alert("Your file is too small. Please try again.");
                    // return;
                }
                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex = 0;
                    fileSize = attachment.length;
                    $scope.showSpinnereditProf = false;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    debugger;
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(type, userDocId, null);
                    } else {
                        swal('Info', 'Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".', 'info');
                        return;
                        // alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                    }

                }
                fileReader.onerror = function (e) {
                    swal('Info', 'There was an error reading the file.  Please try again.', 'info');
                    return;
                    // alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    swal('Info', 'There was an error reading the file.  Please try again.', 'info');
                    return;
                    // alert("There was an error reading the file.  Please try again.");
                }

                fileReader.readAsBinaryString(file);  //Read the body of the file

            } else {
                swal('Info', 'Your file is too large.  Please try again.', 'info');
                return;
                // alert("Your file is too large.  Please try again.");
                $scope.showSpinnereditProf = false;
            }
        } else {
            swal('Info', 'You must choose a file before trying to upload it', 'info');
            return;
            // alert("You must choose a file before trying to upload it");
            $scope.showSpinnereditProf = false;
        }
    }

    $scope.uploadAttachment = function (type, userDocId, fileId) {
        var chunkSize = 950000;
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

        // ApplicantPortal_Contoller.doCUploadAttachmentSignature(
        WorkshopController2.doCUploadAttachmentSignature(
            attachmentBody, attachmentName, fileId, userDocId,
            function (result, event) {
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
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

                    }
                    $scope.showUplaodUserDoc = false;
                    // $scope.getCandidateDetails();

                } else {
                    debugger;
                    positionIndex += chunkSize;
                    $scope.uploadAttachment(type, userDocId, result);
                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    // $scope.getUserDocs = function () {
    //     debugger;
    //     ApplicantPortal_Contoller.getContactUserDoc($rootScope.contactId, function (result, event) {
    //         if (event.status) {
    //             $scope.proposalDetails = result;
    //             var uploadCount=0;
    //             for(var i=0;i<$scope.proposalDetails.length;i++){
    //                 if($scope.proposalDetails[i].userDocument.Status__c == 'Uploaded'){
    //                     uploadCount=uploadCount+1;
    //                     if(uploadCount==$scope.proposalDetails.length)
    //                         $scope.disableUploadButton = false;
    //                 }
    //             }
    //             $scope.$apply();
    //         }
    //     }, {
    //         escape: true
    //     })
    // }
    // $scope.getUserDocs();

    // $scope.createUserDocument = function(){
    //     debugger;
    //     ApplicantPortal_Contoller.createUserDocument("", $rootScope.contactId, $rootScope.projectId,"", function(result,event){
    //         debugger;
    //         if(event.status && result){
    //             if(result != null){
    //                 $scope.uploadFile('sign',result,'');
    //             }
    //             debugger;
    //             $scope.$apply();
    //         }
    //     },
    //                                               {escape: true}
    //                                              )
    // }

    //     var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
    //     var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
    //     var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
    //     var attachment;
    //     var attachmentName;
    //     var fileSize;
    //     var positionIndex;
    //     var doneUploading;
    //     var appId = "{!$CurrentPage.parameters.id}";
    //     var conId = "{!contactId}"
    //     //Method to prepare a file to be attached to the Account bound to the page by the standardController
    //     $scope.uploadFile = function (type, userDocId, fileId) {
    //       debugger;
    //       $scope.showSpinnereditProf = true;
    //       var file;
    //       if (type == 'sign') {
    //           file = document.getElementById('sign').files[0];
    //           // userDocId = $rootScope.contactId;
    //       } else if (type == 'resume') {
    //           file = document.getElementById('resumeAttachmentFile').files[0];
    //       }

    //       console.log(file);
    //       if (file != undefined) {
    //           if (file.size <= maxFileSize) {

    //               attachmentName = file.name;
    //               const myArr = attachmentName.split(".");
    //               if (myArr[1] != "pdf" && type != 'profilePic') {
    //                   alert("Please upload in PDF format only");
    //                   return;
    //               }
    //               var fileReader = new FileReader();
    //               fileReader.onloadend = function (e) {
    //                   attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
    //                   positionIndex = 0;
    //                   fileSize = attachment.length;
    //                   $scope.showSpinnereditProf = false;
    //                   console.log("Total Attachment Length: " + fileSize);
    //                   doneUploading = false;
    //                   debugger;
    //                   if (fileSize < maxStringSize) {
    //                       $scope.uploadAttachment(type , userDocId, fileId);
    //                   } else {
    //                       alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
    //                   }

    //               }
    //               fileReader.onerror = function (e) {
    //                   alert("There was an error reading the file.  Please try again.");
    //               }
    //               fileReader.onabort = function (e) {
    //                   alert("There was an error reading the file.  Please try again.");
    //               }

    //               fileReader.readAsBinaryString(file);  //Read the body of the file

    //           } else {
    //               alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
    //               $scope.showSpinnereditProf = false;
    //           }
    //       } else {
    //           // alert("You must choose a file before trying to upload it");
    //           $scope.showSpinnereditProf = false;
    //       }
    //   }
    //   $scope.uploadAttachment = function (type, userDocId, fileId) {
    //       var attachmentBody = "";
    //       if (fileId == undefined) {
    //           fileId = " ";
    //       }
    //       if (fileSize <= positionIndex + chunkSize) {
    //           debugger;
    //           attachmentBody = attachment.substring(positionIndex);
    //           doneUploading = true;
    //       } else {
    //           attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
    //       }
    //       console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
    //       ApplicantPortal_Contoller.doCUploadAttachment(
    //           attachmentBody, attachmentName,fileId, userDocId,
    //           function (result, event) {
    //               console.log(result);
    //               if (event.type === 'exception') {
    //                   console.log("exception");
    //                   console.log(event);
    //               } else if (event.status) {
    //                   if (doneUploading == true) {
    //                       if (type == 'profilePic') {
    //                       }else{
    //                           Swal.fire(
    //                               '',
    //                               'Uploaded Successfully!',
    //                               'success'
    //                           )
    //                           $scope.getUserDocs();


    //                       }
    //                      // $scope.getCandidateDetails();

    //                   } else {
    //                       debugger;
    //                       positionIndex += chunkSize;
    //                       $scope.uploadAttachment(type,userDocId,result);
    //                   }
    //               } else {
    //                   console.log(event.message);
    //               }
    //           },


    //           { buffer: true, escape: true, timeout: 120000 }
    //       );
    //   }

    function buildProposalPayload() {
        if (!$scope.checkbox || !$scope.checkbox.Id) {
            return null;
        }

        var payload = {
            sobjectType: 'Application_Proposal__c',
            Id: $scope.checkbox.Id
        };

        if ($scope.checkbox.hasOwnProperty('Privacy_Policy_Accepted')) {
            payload.Privacy_Policy_Accepted__c = $scope.checkbox.Privacy_Policy_Accepted;
        }

        return payload;
    }

    $scope.submit = function () {
        debugger;

        for (var i = 0; i < $scope.allDocs.length; i++) {
            if ($scope.allDocs[i].userDocument.Name == 'Coordinator 1 Signature') {
                if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
                    swal('Info', 'Please upload Signature.', 'info');
                    return;
                }
            } else if ($scope.allDocs[i].userDocument.Name == 'Coordinator 2 Signature') {
                if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
                    swal('Info', 'Please upload Signature.', 'info');
                    return;
                }
            }
        }

        var year = 0;
        var month = 0;
        var day = 0;

        if ($scope.SignDate != undefined && $scope.SignDate != '') {
            year = $scope.SignDate.getUTCFullYear();
            month = $scope.SignDate.getUTCMonth() + 1;
            day = $scope.SignDate.getDate();
        }

        

        $scope.checkbox1 = angular.copy($scope.checkbox);
        delete ($scope.checkbox1.Contacts__r);
        delete ($scope.checkbox1.Contacts);
        delete ($scope.checkbox1.Privacy_Policy_Accepted);
        delete ($scope.checkbox1.email);
        delete ($scope.checkbox1.profilePicId);

        // if($scope.checkbox.Privacy_Policy_Accepted__c == false){
        //     swal("Required", "Please accept privacy policy.")
        //         return;
        // }

        $scope.isLoading = true;
        // ApplicantPortal_Contoller.upsertCheckbox($scope.checkbox, $rootScope.projectId, year, month, day, function (result, event) {
        WorkshopController2.upsertCheckbox($scope.checkbox1, $rootScope.projectId, year, month, day, $rootScope.apaId, function (result, event) {
            if (event.status) {
                debugger; 
                $scope.isLoading = false;           

                // swal(
                //     'Success',
                //     'Your proposal have been submitted successfully.',
                //     'success',
                //     function () {
                //         setTimeout(function () {
                //             // $scope.redirectPageURL();
                //            $scope.redirectPageURL('Home');
                //             $scope.$apply();
                //         },2000);
                //     }
                // );
                //  $scope.redirectPageURL('Home');             
                // $scope.checkbox = result;
                swal({
                    title: 'Success',
                    text: 'Your proposal have been submitted successfully.',
                    type: 'success'
                }, function () {
                    debugger;
                    $scope.redirectPageURL('Home');
                });
                $scope.$apply();
            }
            else {
                $scope.isLoading = false;
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }

    $scope.saveAsDraftWorkshop = function () {
        debugger;
        var year = 0;
        var month = 0;
        var day = 0;

        if ($scope.SignDate != undefined && $scope.SignDate != '') {
            year = $scope.SignDate.getUTCFullYear();
            month = $scope.SignDate.getUTCMonth() + 1;
            day = $scope.SignDate.getDate();
        }

        $scope.checkbox1 = angular.copy($scope.checkbox);
        delete ($scope.checkbox1.Contacts__r);
        delete ($scope.checkbox1.Contacts);
        delete ($scope.checkbox1.Privacy_Policy_Accepted);
        delete ($scope.checkbox1.email);
        delete ($scope.checkbox1.profilePicId);


        $scope.isLoading = true;

        ///ApplicantPortal_Contoller.saveAsDraftWorkshop($scope.checkbox, $rootScope.projectId, year, month, day, function (result, event) {
        WorkshopController2.saveAsDraftWorkshop($scope.checkbox1, $rootScope.candidateId, year, month, day, function (result, event) {
            if (event.status) {
                $scope.isLoading = false;
                debugger;               
                //  swal(
                //     'Success',
                //     'Your proposal has been saved as Draft.',
                //     'success',
                //     function () {
                //         setTimeout(function () {
                //             // $scope.redirectPageURL();
                //            $scope.redirectPageURL('Home');
                //             $scope.$apply();
                //         }, 2000);
                //     }
                // );
                // $scope.redirectPageURL('Home');
                swal({
                    title: 'Success',
                    text: 'Your proposal has been saved as Draft.',
                    type: 'success'
                }, function () {
                    debugger;
                    $scope.redirectPageURL('Home');
                });               
               // $scope.checkbox = result;
                $scope.$apply();
            }
            else {
                $scope.isLoading = false;
                $scope.$apply();
            }         
        },
            { escape: true }
        )
    }

    // $scope.redirectPageURL = function (pageName) {
    //     debugger;
    //     var link = document.createElement("a");
    //     link.id = 'someLink'; //give it an ID!
    //     link.href = "#/" + pageName;
    //     link.click();
    // };
     $scope.redirectPageURL = function(pageName) {
    debugger;
    var link = document.createElement("a");

    let baseUrl = link.baseURI;
    // Remove hash part ( #/something )
    if (baseUrl.includes('#/')) {
        baseUrl = baseUrl.split('#/')[0];
    }
    if (pageName === 'Home') {
        // Get id and campaign from current URL dynamically
        let urlParams = new URLSearchParams(window.location.search);
        let id = urlParams.get("id") || "";
        let campaign ='Workshop';
        // Build final HOME URL format dynamically
        let finalUrl = baseUrl;
        if (campaign) {
         //   finalUrl += "&campaign=" + campaign;
        }
       // finalUrl += "#/Home";
        finalUrl;
        // link.href = finalUrl;
        // link.click();
        
         // 1️⃣ Redirect to Home
        window.location.replace(finalUrl);

        // 2️⃣ Refresh AFTER redirect
        setTimeout(function () {
            window.location.reload();
        }, 100);
 
    } else {
        // For other pages → keep same base + hash routing
        link.href = baseUrl + "#/" + pageName;
        link.click();
    }
};


    // $scope.redirectPageURL = function () {
    //     window.location.href =
    //         window.location.origin +
    //         window.location.pathname +
    //         window.location.search;
    // };
});
        
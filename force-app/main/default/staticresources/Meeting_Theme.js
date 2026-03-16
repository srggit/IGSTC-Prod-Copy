angular.module('cp_app').controller('meeting_ctrl', function ($scope, $sce, $rootScope) {

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
    $scope.birthdate;
    $rootScope.contactId;
    $scope.allMeetingTheme = [];
    $scope.allMeetingDetails = [];
    $scope.proposedDate;
    $scope.endDate;
    $scope.proposalDays = 0;
    $scope.meetingDates = [];
    $scope.meetingDays = [];
    $scope.mettingThemeDateData = [];

    $scope.redirectPageURL = function (URL) {
        var link = document.createElement("a");
        link.id = 'someLink'; //give it an ID!
        link.href = '#/' + URL + '';
        link.click();
    }

    $scope.selectedFile;

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

        var myModal = new bootstrap.Modal(document.getElementById('filePreview'))
        myModal.show('slow');
        $scope.$apply();

        //.ContentDistribution.DistributionPublicUrl
    }

    // $scope.getProjectdetils = function () {
    //     debugger;
    //     ApplicantPortal_Contoller.getAllUserDoc($rootScope.projectId, function (result, event) {
    //         debugger
    //         console.log('result return onload :: ');
    //         console.log(result);
    //         if (event.status) {
    //             $scope.allDocs = result;
    //             for (var i = 0; i < $scope.allDocs.length; i++) {
    //                 if ($scope.allDocs[i].userDocument.Name == 'Meeting Agenda') {
    //                     $scope.doc = $scope.allDocs[i];
    //                 }
    //             }
    //             $scope.$apply();
    //         }
    //     }, {
    //         escape: true
    //     })
    // }
    // $scope.getProjectdetils = function () {
    //     debugger;
    //     ApplicantPortal_Contoller.getAllUserDoc($rootScope.candidateId, function (result, event) {
    //         debugger
    //         console.log('result return onload :: ');
    //         console.log(result);
    //         if (event.status) {
    //             $scope.allDocs = result;
    //             for (var i = 0; i < $scope.allDocs.length; i++) {
    //                 if ($scope.allDocs[i].userDocument.Name == 'Meeting Agenda') {
    //                     $scope.doc = $scope.allDocs[i];
    //                 }
    //             }
    //             $scope.$apply();
    //         }
    //     }, {
    //         escape: true
    //     })
    // }
    // $scope.getProjectdetils();

    $scope.getProjectdetils = function () {
        debugger;
        // ApplicantPortal_Contoller.getAllUserDoc($rootScope.proposalId, function (result, event) {
        WorkshopController2.getAllUserDoc($rootScope.proposalId, function (result, event) {
            debugger
            // console.log('result return onload :: ');
            // console.log(result);
            if (event.status) {
                $scope.allDocs = result;
                for (var i = 0; i < $scope.allDocs.length; i++) {
                    if ($scope.allDocs[i].userDocument.Name == 'Meeting Agenda') {
                        $scope.doc = $scope.allDocs[i];
                    }
                }
                $scope.$apply();
            }
        }, {
            escape: true
        })
    }
    $scope.getProjectdetils();

    $scope.uploadFile = function (type, userDocId, good, fileId, fileSizeFun) {


        //$scope.uploadFile = function (type, userDocId, good, fileId, fileSizeFun) {
        debugger;

        console.log('type :', type);
        console.log('userDocId :', userDocId);
        console.log('fileId :', fileId);
        console.log('fileSizeFun :', fileSizeFun);

        var lll = good;
        var chunkSize = 950000;
        var positionIndex = 0;
        var maxStringSize = 1048576;
        var attachment = "";
        var attachmentName = "";
        var fileSize = 0;
        var doneUploading = false;

        //userDocId = 'a0xe10000001L7FAAU';
        //type = 'PDF Upload Testing';

        maxFileSize = fileSizeFun;
        $scope.showSpinnereditProf = true;
        var file;

        file = document.getElementById(type).files[0];
        //file = document.getElementById('fileUploader').files[0];
        console.log("Selected File:", file);

        if (!file) {
            console.error("File is undefined. INPUT NOT FOUND.");
            return;
        }

        fileName = file.name;
        var typeOfFile = fileName.split(".");
        lengthOfType = typeOfFile.length;
        if (typeOfFile[lengthOfType - 1] == "pdf" || typeOfFile[lengthOfType - 1] == "PDF") {

        } else {
            swal('Info', 'Please choose pdf file only.', 'info');
            return;
        }
        console.log(file);
        if (file != undefined) {
            if (file.size <= maxFileSize) {

                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                /* if (myArr[1] != "pdf" && type != 'profilePic') {
                    alert("Please upload in PDF format only");
                    return;
                } */
                var fileReader = new FileReader();
                console.log("FileReader created:", fileReader);
                fileReader.onloadend = function (e) {
                    console.log('E Object==>', e);
                    //attachment = window.btoa(e.target.result);  //Base 64 encode the file before sending it
                    attachment = e.target.result.split(",")[1];
                    positionIndex = 0;                    
                    $scope.showSpinnereditProf = false;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    debugger;

                    console.log('attachment : ', attachment);
                    console.log('fileSize : ', fileSize);
                    console.log('doneUploading : ', doneUploading);
                    console.log('userDocId===>', userDocId);

                    //fileSize = attachment.length;
                    // if (fileSize < maxStringSize) {
                    //     $scope.uploadAttachment(type, userDocId, null, attachment, attachmentName);
                    // } else {

                    //     // swal("Info", "Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".", "info");
                    //     // return;
                    //      // Convert bytes to MB
                    //     var maxSizeMB = (maxStringSize / (1024 * 1024)).toFixed(2);
                    //     var fileSizeMB = (fileSize / (1024 * 1024)).toFixed(2);

                    //     swal(
                    //         "Info",
                    //         "File is too large. Maximum size is " + maxSizeMB + " MB. Your file is " + fileSizeMB + " MB.",
                    //         "info"
                    //     );
                    //     return;
                        
                    // }
                        fileSize = file.size; // use original file size instead of Base64
                        if (fileSize <= maxFileSize) {

                            $scope.uploadAttachment(type, userDocId, null, attachment, attachmentName);

                        } else {

                            var maxSizeMB = (maxFileSize / (1024 * 1024)).toFixed(2);
                            var fileSizeMB = (fileSize / (1024 * 1024)).toFixed(2);

                            swal(
                                "Info",
                                "File must be under " + maxSizeMB + " MB. Your file is " + fileSizeMB + " MB.",
                                "info"
                            );
                            return;
                        }

                }
                fileReader.onerror = function (e) {
                    swal("Info", "There was an error reading the file.  Please try again.", "info");
                    console.log('Error is==>', e);
                    console.log('Error Body Is===>', JSON.stringify(e.target.result));
                    return;
                    // alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    swal("Info", "There was an error reading the file.  Please try again.", "info");
                    return;
                    // alert("There was an error reading the file.  Please try again.");
                }

                fileReader.readAsDataURL(file); //Read the body of the file

            } else {
                // swal("Info", "File must be under 1 Mb in size.  Your file is too large.  Please try again.", "info");
                // return;
                var maxSizeMB = (maxFileSize / (1024 * 1024)).toFixed(2);
                var fileSizeMB = (file.size / (1024 * 1024)).toFixed(2);

                swal(
                    "Info",
                    "File must be under " + maxSizeMB + " MB. Your file is " + fileSizeMB + " MB.",
                    "info"
                );
                return;
            }
        } else {
            swal("Info", "You must choose a file before trying to upload it", "info");
            return;
            // alert("You must choose a file before trying to upload it");
            // $scope.showSpinnereditProf = false;
        }
    }

    $scope.uploadAttachment = function (type, userDocId, fileId, attachment, attachmentName) {
        debugger;

        console.log('type : ', type);
        console.log('userDocId : ', userDocId);
        console.log('fileId : ', fileId);
        console.log('attachment : ', attachment);
        console.log('attachmentName : ', attachmentName);

        //var attachmentBody;
        var fileSize = 1048576;
        var positionIndex = 1000000;
        var chunkSize = 48576;
        // if (fileId == undefined) {
        //     fileId = " ";
        // }
        attachmentBody = attachment;
        if (userDocId == undefined) {
            userDocId = null;
        }
        if (fileSize <= positionIndex + chunkSize) {
            debugger;
            attachmentBody = attachment;
            doneUploading = true;
        }
        else {
            attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
        }
        console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
        debugger;

        // ApplicantPortal_Contoller.doCUploadAttachmentAa(
        WorkshopController2.doCUploadAttachmentAa(
            attachmentBody, attachmentName, fileId, userDocId,
            function (result, event) {
                debugger;
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                } else if (event.status) {
                    if (doneUploading == true) {
                        swal(
                            'Success',
                            'Uploaded Successfully!',
                            'success'
                        )

                        $scope.getProjectdetils();
                        // $scope.disableSubmit = false;

                    }
                    else {
                        debugger;
                        positionIndex += chunkSize;
                        $scope.uploadAttachment(type, userDocId, result);
                    }
                    $scope.showUplaodUserDoc = false;
                    // $scope.getCandidateDetails();

                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    $scope.saveandNext = function () {
        debugger;
        for (var i = 0; i < $scope.allDocs.length; i++) {
            if ($scope.allDocs[i].userDocument.Name == 'Meeting Agenda') {
                if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
                    swal('Info', 'Please upload Meeting Agenda.', 'info');
                    return;
                }
            }
        }
        swal(
            'Success',
            'Your Workshop Agenda details have been saved successfully.',
            'success'
        );

        $scope.redirectPageURL('SignatureOfCoordinators');
    }
    //     $scope.allMeetingDetails.push({
    //         "Name": " ",
    //         "Affiliation__c": " ",
    //         "Email__c": "",
    //         "Phone__c": "",
    //         "Participant_Type__c": "",
    //         "Proposals__c": $rootScope.projectId
    //     });
    //     $scope.addMeetingDate = function () {
    //         $scope.allMeetingTheme.push({
    //             "Name": " ",
    //             "Phone": " ",
    //             "Academia__c": true,
    //             "Industry__c": false,
    //             "Proposals__c": $rootScope.projectId
    //         });

    //     }

    //     $scope.addMeetingDetail = function () {
    //         if ($scope.allMeetingDetails.length > 29) {
    //             swal("Max Account Limit", "You cannot add more than 30 partcipants.")
    //         } else {
    //             $scope.allMeetingDetails.push({
    //                 "Name": " ",
    //                 "Start_Time__c": " ",
    //                 "End_Time__c": "",
    //                 "Purpose__c": "",
    //                 "Participant_Type__c": "",
    //             });
    //         }
    //         if ($scope.allMeetingDetails.length > 30) {
    //             $scope.disableAddButton = true;
    //         }
    //     }

    //     $scope.updateExternalId = function (outerIndex, innerIndex) {

    //         $scope.allMeetingTheme[outerIndex - 1].MeetingDetailList[innerIndex - 1].meetingTopic.External_Id__c = parseInt(outerIndex.toString() + innerIndex.toString());
    //     }

    //     $scope.getMeetingThemeDetails = function () {
    //         Meeting_Theme_Controller.getMeetingThemeDetails($rootScope.projectId, function (result, event) {
    //             debugger
    //             console.log(result);
    //             if (event.status) {
    //                 $scope.allMeetingTheme = result;
    //                 if ($scope.allMeetingTheme != undefined && $scope.allMeetingTheme.length > 0) {
    //                     for (let index = 0; index < $scope.allMeetingTheme.length; index++) {
    //                         $scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c = new Date($scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c);
    //                         $scope.meetingDates.push({index:index,day:new Date($scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c).getDate(),date:new Date($scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c)});
    //                         for (let y = 0; y < $scope.allMeetingTheme[index].MeetingDetailList.length; y++) {
    //                             if ($scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda.length == 0) {
    //                                 $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda.push({
    //                                     "Start_Time__c": "",
    //                                     "End_Time__c": "",
    //                                     "Purpose__c": ""
    //                                 });
    //                             }
    //                             for (let x = 0; x < $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda.length; x++) {
    //                                 if ($scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda != undefined && $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.Start_Time__c != undefined) {
    //                                     $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.Start_Time__c = new Date($scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.Start_Time__c);
    //                                 }
    //                                 if ($scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda != undefined && $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.End_Time__c != undefined) {
    //                                     $scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.End_Time__c = new Date($scope.allMeetingTheme[index].MeetingDetailList[y].meetingAgenda[x].mAgenda.End_Time__c);
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 } else {
    //                     $scope.allMeetingTheme.push({
    //                         "MeetingDetailList": [{
    //                             "meetingAgenda": [{
    //                                 "Meeting_Theme__c": "",
    //                             }],
    //                             "meetingTopic": {
    //                                 "Meeting_Theme__c": "",
    //                                 "Meeting_Theme_Title__c": "",
    //                                 "Meeting_Agenda__r": [{
    //                                     "Meeting_Theme__c": "",
    //                                 }]
    //                             }
    //                         }],
    //                         "meetingTheme": {
    //                             "Meeting_Date__c": "",
    //                             "Proposals__c": $rootScope.projectId
    //                         }
    //                     })
    //                 }
    //                 $scope.$apply();
    //             }
    //         });
    //     }
    //     $scope.getMeetingThemeDetails();
    //     $scope.saveSingleMeetingDetails = function (sFlag) {
    //         debugger;

    //             if($scope.mettingThemeDateData.meetingTheme.Meeting_Date__c != undefined){
    //                 $scope.mettingThemeDateData.meetingYear = $scope.mettingThemeDateData.meetingTheme.Meeting_Date__c.getFullYear();
    //                 $scope.mettingThemeDateData.meetingMonth = $scope.mettingThemeDateData.meetingTheme.Meeting_Date__c.getMonth() + 1;
    //                 $scope.mettingThemeDateData.meetingDay = $scope.mettingThemeDateData.meetingTheme.Meeting_Date__c.getDate();
    //             }


    //             for (let j = 0; j < $scope.mettingThemeDateData.MeetingDetailList.length; j++) {
    //                 if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingTopic.Meeting_Theme_Title__c ==  "") {
    //                     swal("Meeting Details", "Please Enter Meeting Theme");
    //                     $("#theme"+j+"").addClass('border-theme');
    //                     return;
    //                 }

    //                 if($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda != undefined){
    //                     for (let z = 0; z < $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda.length; z++) {
    //                         delete($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z]['$$hashKey']);
    //                         if($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda != undefined){
    //                             if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c != undefined && !angular.isNumber($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c)) {
    //                                 $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].sHour = $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c.getHours();
    //                                 $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].sMin = $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c.getMinutes();
    //                             } else if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c == "" || $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c ==  null) {
    //                                 swal("Meeting Details", "Please Enter Start Time");
    //                                 $("#startTime"+z+"").addClass('border-theme');
    //                                 return;
    //                             }
    //                             if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c != undefined && !angular.isNumber($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c)) {
    //                                 $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].eHour = $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c.getHours();
    //                                 $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].eMin = $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c.getMinutes();
    //                             } else if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c == "" || $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c ==  null) {
    //                                 swal("Meeting Details", "Please Enter End Time");
    //                                 $("#endTime"+z+"").addClass('border-theme');
    //                                 return;
    //                             }
    //                             if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Attendees__c ==  "" || $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Attendees__c == undefined) {
    //                                 swal("Meeting Details", "Please Enter Meeting Attendees");
    //                                 $("#attendees"+z+"").addClass('border-theme');
    //                                 return;
    //                             }
    //                             if ($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Purpose__c ==  "" || $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Purpose__c == undefined) {
    //                                 swal("Meeting Details", "Please Enter Meeting Agenda");
    //                                 $("#agenda"+z+"").addClass('border-theme');
    //                                 return;
    //                             }
    //                         }else{
    //                             swal("Meeting Details", "Please Enter Start and End Time");
    //                             $("#startTime"+j+"").addClass('border-theme');
    //                             $("#endTime"+j+"").addClass('border-theme');
    //                         }

    //                     }
    //                 }
    //             }


    //             for (let j = 0; j < $scope.mettingThemeDateData.MeetingDetailList.length; j++) {
    //                 for (let z = 0; z < $scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda.length; z++) {
    //                     delete($scope.mettingThemeDateData['$$hashKey']);
    //                     delete($scope.mettingThemeDateData.meetingTheme.Meeting_Themes__r);
    //                     delete($scope.mettingThemeDateData.meetingTheme.Meeting_Date__c);
    //                     delete($scope.mettingThemeDateData.MeetingDetailList[j]['$$hashKey']);
    //                     delete($scope.mettingThemeDateData.MeetingDetailList[j].meetingTopic.Meeting_Agenda__r);
    //                     delete($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c);
    //                     delete($scope.mettingThemeDateData.MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c);

    //                 }

    //             }

    //         var arraySaveObj=[];
    //         arraySaveObj.push($scope.mettingThemeDateData);
    //         Meeting_Theme_Controller.saveMeetingThemeDetails(JSON.stringify(arraySaveObj),$rootScope.projectId, function (result, event) {
    //             if (event.status) {
    //                 swal("Meeting Details", "Meeting detail has been saved successfully.");
    //                 if(sFlag=='next')
    //                 $scope.redirectPageURL('Financial_Details');
    //                 else{
    //                     $scope.meetingDates=[];
    //                     $scope.meetingDays = [];
    //                     $scope.mettingThemeDateData=[];
    //                 $scope.getMeetingThemeDetails();
    //                 $scope.getWorkshopDates();                
    //                 }
    //             }
    //         });
    //     }
    //     $scope.saveAllMeetingDetails = function () {
    //         debugger;

    //         for (let index = 0; index < $scope.allMeetingTheme.length; index++) {
    //             if ($scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c ==  "" || $scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c == null) {
    //                 swal("Meeting Details", "Please Enter Meeting Date");
    //                 return;
    //             }
    //             $scope.allMeetingTheme[index].meetingYear = $scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c.getFullYear();
    //             $scope.allMeetingTheme[index].meetingMonth = $scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c.getMonth() + 1;
    //             $scope.allMeetingTheme[index].meetingDay = $scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c.getDate();


    //             for (let j = 0; j < $scope.allMeetingTheme[index].MeetingDetailList.length; j++) {
    //                 if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingTopic.Meeting_Theme_Title__c ==  "") {
    //                     swal("Meeting Details", "Please Enter Meeting Theme");
    //                     return;
    //                 }

    //                 if($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda != undefined){
    //                     for (let z = 0; z < $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda.length; z++) {
    //                         delete($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z]['$$hashKey']);
    //                         if($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda != undefined){
    //                             if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c != undefined && !angular.isNumber($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c)) {
    //                                 $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].sHour = $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c.getHours();
    //                                 $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].sMin = $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c.getMinutes();
    //                             } else if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c == "" || $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c ==  null) {
    //                                 swal("Meeting Details", "Please Enter Start Time");
    //                                 return;
    //                             }
    //                             if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c != undefined && !angular.isNumber($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c)) {
    //                                 $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].eHour = $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c.getHours();
    //                                 $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].eMin = $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c.getMinutes();
    //                             } else if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c == "" || $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c ==  null) {
    //                                 swal("Meeting Details", "Please Enter End Time");
    //                                 return;
    //                             }
    //                             if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Attendees__c ==  "" || $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Attendees__c == undefined) {
    //                                 swal("Meeting Details", "Please Enter Meeting Attendees");
    //                                 return;
    //                             }
    //                             if ($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Purpose__c ==  "" || $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Purpose__c == undefined) {
    //                                 swal("Meeting Details", "Please Enter Meeting Agenda");
    //                                 return;
    //                             }
    //                         }else{
    //                             swal("Meeting Details", "Please Enter Start and End Time");
    //                         }

    //                     }
    //                 }
    //             }

    //         }
    //         for (let index = 0; index < $scope.allMeetingTheme.length; index++) {
    //             for (let j = 0; j < $scope.allMeetingTheme[index].MeetingDetailList.length; j++) {
    //                 for (let z = 0; z < $scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda.length; z++) {
    //                     delete($scope.allMeetingTheme[index]['$$hashKey']);
    //                     delete($scope.allMeetingTheme[index].meetingTheme.Meeting_Themes__r);
    //                     delete($scope.allMeetingTheme[index].meetingTheme.Meeting_Date__c);
    //                     delete($scope.allMeetingTheme[index].MeetingDetailList[j]['$$hashKey']);
    //                     delete($scope.allMeetingTheme[index].MeetingDetailList[j].meetingTopic.Meeting_Agenda__r);
    //                     delete($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.Start_Time__c);
    //                     delete($scope.allMeetingTheme[index].MeetingDetailList[j].meetingAgenda[z].mAgenda.End_Time__c);

    //                 }

    //             }
    //         }

    //         Meeting_Theme_Controller.saveMeetingThemeDetails(JSON.stringify($scope.allMeetingTheme),$rootScope.projectId, function (result, event) {
    //             if (event.status) {
    //                 swal("Meeting Details", "Meeting detail has been saved successfully.");
    //                 $scope.redirectPageURL('SignatureOfCoordinators');
    //             }
    //         });
    //     }



    //     $scope.addMeetingTime = function (parentIndex,index) {        
    //         $scope.mettingThemeDateData.MeetingDetailList[parentIndex].meetingAgenda.push({
    //             "Start_Time__c": "",
    //             "End_Time__c": "",
    //             "Purpose__c": ""
    //         });
    //     }

    //     $scope.deleteMeetingTime = function (parentIndex,index) {        
    //         if ($scope.mettingThemeDateData.MeetingDetailList[parentIndex].meetingAgenda.length > 1) {
    //             $scope.mettingThemeDateData.MeetingDetailList[parentIndex].meetingAgenda.splice(index, 1);
    //         }
    //     }
    // $scope.removeEmploymentRow=function(index){
    //     if ($scope.mettingThemeDateData.MeetingDetailList.length > 1) {
    //         $scope.mettingThemeDateData.MeetingDetailList.splice(index, 1);
    //     }
    // }
    //     $scope.addMeetingTheme = function (parentIndex, index) {
    //         debugger
    //         $scope.mettingThemeDateData.MeetingDetailList.push({
    //             "meetingAgenda": [{
    //                         "Start_Time__c": "",
    //                         "End_Time__c": "",
    //                         "Purpose__c": ""
    //                     }],
    //                     "meetingTopic": {
    //                         "Name": "",
    //                         "Meeting_Theme__c": "",
    //                         "Meeting_Theme_Title__c": ""
    //                     }
    //         });
    //         console.log($scope.mettingThemeDateData);
    //     }

    //     $scope.deleteMeetingTheme = function (parentIndex, index) {

    //         if ($scope.allMeetingTheme[parentIndex-1].MeetingDetailList.length > 1) {
    //             $scope.allMeetingTheme[parentIndex-1].MeetingDetailList.splice(index, 1);
    //         }
    //     }

    //     $scope.deleteMeetingDay = function(parentIndex){
    //         debugger;
    //         if ($scope.allMeetingTheme.length > 1) {
    //             if($scope.allMeetingTheme[parentIndex].meetingTheme.Id != undefined){
    //                 Meeting_Theme_Controller.deleteMeetingTheme($scope.allMeetingTheme[parentIndex].meetingTheme.Id, function (result, event) {
    //                     if (event.status) {
    //                     }
    //                 });
    //             }
    //             $scope.allMeetingTheme.splice(parentIndex,1);
    //         }

    //     }

    //     $scope.addMeetingDay = function (index,aFlag) {
    //         debugger
    //         var dateActive=$scope.meetingDays[index].date;
    //         var matchStatus=0;
    //         for(var i=0;i<$scope.allMeetingTheme.length;i++){
    //             if($scope.allMeetingTheme[i].meetingTheme.Meeting_Date__c!=undefined && $scope.allMeetingTheme[i].meetingTheme.Meeting_Date__c!=""){
    //             if($scope.allMeetingTheme[i].meetingTheme.Meeting_Date__c.getDate()==dateActive.getDate()){
    //                 $scope.mettingThemeDateData=$scope.allMeetingTheme[i];
    //                 matchStatus=1;
    //             }            
    //         }
    //         }
    //         if(matchStatus==0){
    //             var objectToPush={
    //                 "MeetingDetailList": [{
    //                     "meetingAgenda": [{
    //                         "Meeting_Theme__c": "",
    //                     }],
    //                     "meetingTopic": {
    //                         "Meeting_Theme__c": "",
    //                         "Meeting_Theme_Title__c": "",
    //                         "Meeting_Agenda__r": [{
    //                             "Meeting_Theme__c": "",
    //                         }]
    //                     }
    //                 }],
    //                 "meetingTheme": {
    //                     "Proposals__c": $rootScope.projectId,
    //                     "Meeting_Date__c": dateActive
    //                 }
    //             };
    //             $scope.mettingThemeDateData=objectToPush;            
    //         }
    //         $('ul').children().removeClass('active_clicked');
    //             $('#li_'+index+'').addClass('active_clicked');
    //         $("#MeetingDetails").show();
    //         console.log("single object");
    //         console.log($scope.mettingThemeDateData);
    //     }
    //     $scope.redirectPageURL = function(pageName){

    //         var link=document.createElement("a");
    //         link.Id = 'someLink';
    //         link.href="#/"+pageName;
    //         link.click();
    //     }

    //     $scope.meetingDetailsList = [];
    //     $scope.getMeetingThemeDetailsforSlectdDay = function(){
    //         Meeting_Theme_Controller.getMeetingThemeDetailsforSlectdDay(day, year, month, function (result, event) {
    //             if (event.status) {
    //                 if(result != null){
    //                     $scope.meetingDetailsList = result;
    //                 }else{
    //                     $scope.meetingDetailsList = [{
    //                         "meetingAgenda": [{
    //                             "Meeting_Theme__c": "",
    //                         }],
    //                         "meetingTopic": {
    //                             "Meeting_Theme__c": "",
    //                             "Meeting_Theme_Title__c": "",
    //                             "Meeting_Agenda__r": [{
    //                                 "Meeting_Theme__c": "",
    //                             }]
    //                         }
    //                     }]
    //                 }
    //             }
    //         });
    //     }

    //     $scope.getWorkshopDates = function(){
    //         debugger;
    //         Meeting_Theme_Controller.getWorkshopDates($rootScope.userId, function(result,event){
    //             debugger;
    //             if(event.status){
    //                 debugger;
    //                 if(result.Proposed_Date__c != undefined && result.Proposed_Date__c != ""){
    //                     $scope.proposedDate = new Date(result.Proposed_Date__c);
    //                 }
    //                 if(result.Workshop_Finish_Date__c != undefined && result.Workshop_Finish_Date__c != ""){
    //                     $scope.endDate = new Date(result.Workshop_Finish_Date__c);
    //                 }
    //                 if($scope.endDate!=null && $scope.endDate!=undefined && $scope.proposedDate!=null && $scope.proposedDate!=undefined){
    //                     for (var d = new Date($scope.proposedDate); d <= new Date($scope.endDate); d.setDate(d.getDate() + 1)) {
    //                         var uFlag=0;
    //                         for(var ind=0;ind<$scope.meetingDates.length;ind++){                            
    //                             if($scope.meetingDates[ind].day==d.getDate()){
    //                                 $scope.meetingDays.push({date:new Date(d),day:d.getDate(),class:'active'});
    //                                 uFlag=1;
    //                             }
    //                         }
    //                         if(uFlag==0){
    //                             $scope.meetingDays.push({date:new Date(d),day:d.getDate(),class:'inactive'});
    //                         }
    //                         uFlag=0;                       
    //                     }    
    //                     console.log('meeting days');
    //                     console.log($scope.meetingDays);                
    //                 }
    //                 $scope.addMeetingDay(0,$scope.meetingDays[0].class);
    //                 $scope.workshopDates = result;
    //                 $scope.$apply();
    //             }
    //         }
    //         )
    //     }
    //     $scope.getWorkshopDates();

    //     $scope.removeClass=function(controlid,index){
    //         var controlIdfor=controlid+""+index;
    //         $("#"+controlIdfor+"").removeClass('border-theme');
    //       }
});
angular.module('cp_app').controller('attachmentWiser_ctrl', function ($scope, $sce, $rootScope) {

    $scope.objContact = {};
    $scope.disableSubmit = true;
    $scope.allDocs = {};
    $scope.doc = {};
    $scope.allSixDoc = {};
    $scope.proposalStage = false;

    var maxStringSize = 6000000;
    var chunkSize = 750000;

    debugger;
    $scope.redirectPageURL = function (URL) {
        var link = document.createElement("a");
        link.id = 'someLink';
        link.href = '#/' + URL + '';
        link.click();
    }

    /**
     * Downloads a file from a static resource URL
     * This function can be used as a fallback if the download attribute doesn't work
     * @param {string} resourceUrl - The static resource URL
     * @param {string} fileName - The desired filename for the download
     */
    $scope.downloadStaticResource = function (resourceUrl, fileName) {
        debugger;
        try {
            // Fetch the resource
            fetch(resourceUrl)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.blob();
                })
                .then(blob => {
                    // Create a blob URL
                    const url = window.URL.createObjectURL(blob);

                    // Create a temporary anchor element to trigger download
                    const link = document.createElement("a");
                    link.href = url;
                    link.download = fileName || 'download';

                    // Append to body, click, and remove
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);

                    // Clean up the blob URL
                    window.URL.revokeObjectURL(url);
                })
                .catch(error => {
                    console.error('Error downloading file:', error);
                    // Fallback: open in new tab
                    window.open(resourceUrl, '_blank');
                });
        } catch (error) {
            console.error('Error in downloadStaticResource:', error);
            // Fallback: open in new tab
            window.open(resourceUrl, '_blank');
        }
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

    // $scope.getApplicantStatusFromAPA = function () {
    //     debugger;
    //     ApplicantPortal_Contoller.fetchApplicantStatus($rootScope.apaId, function (result, event) {
    //         debugger;

    //         console.log('result return onload :: ');
    //         console.log(result);
    //         console.log('event:', event);

    //         if (event.status) {
    //             $rootScope.isCurrentUserSubmitted = result;
    //             CKEDITOR.config.readOnly = true;
    //         } else {
    //             console.log('Error in fetchApplicantStatus:', event.message);
    //         }
    //     }, {
    //         escape: true
    //     });
    // }
    // $scope.getApplicantStatusFromAPA();

    /**
     * Fetches proposal stage from Apex on page load
     */
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

    $scope.getProjectdetils = function () {
        debugger;
        $scope.selectedFile = '';
        $('#file_frame').attr('src', '');
        ApplicantPortal_Contoller.getContactUserDoc($rootScope.contactId, $rootScope.proposalId, function (result, event) {
            debugger
            console.log('result return onload :: ');
            console.log(result);
            if (event.status) {
                $scope.allDocs = result;
                var uploadCount = 0;
                for (var i = 0; i < $scope.allDocs.length; i++) {
                    if ($scope.allDocs[i].userDocument.Name == 'No objection certificate') {
                        $scope.noObjection = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    } else if ($scope.allDocs[i].userDocument.Name == 'Signature of the Applicant') {
                        $scope.signApp = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    } else if ($scope.allDocs[i].userDocument.Name == 'Signature of the Host') {
                        $scope.hostsign = $scope.allDocs[i];
                        if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                            uploadCount = uploadCount + 1;
                        }
                    }
                    // else if ($scope.allDocs[i].userDocument.Name == 'Acceptance letter') {
                    //     $scope.doc = $scope.allDocs[i];
                    //     if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
                    //         uploadCount = uploadCount + 1;
                    //     }
                    // }
                }
                $scope.$apply();
            }
        }, {
            escape: true
        })
    }
    $scope.getProjectdetils();


    $scope.uploadFile = function (type, userDocId, fileId, maxSize, minFileSize) {
        debugger;
        $scope.showSpinnereditProf = true;
        var file;

        file = document.getElementById(type).files[0];
        fileName = file.name;
        var typeOfFile = fileName.split(".");
        lengthOfType = typeOfFile.length;
        if (typeOfFile[lengthOfType - 1] != "pdf") {
            swal('Info', 'Please choose pdf file only.', 'info');
            return;
        }
        console.log(file);
        var maxFileSize = maxSize;
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                if (minFileSize && file.size < minFileSize) {
                    swal('Info', 'Your file is too small. Minimum size is ' + (minFileSize / 1024) + ' KB.', 'info');
                    return;
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
                var maxSizeMB = (maxFileSize / (1024 * 1024)).toFixed(0);
                swal('Info', 'Your file is too large. Maximum file size is ' + maxSizeMB + ' MB. Please try again.', 'info');
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

    $scope.uploadFile1 = function (type, userDocId, fileId, maxSize, minFileSize) {
        debugger;
        $scope.showSpinnereditProf = true;
        var file;

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
                } else if (event.status) {
                    if (doneUploading == true) {
                        $scope.getProjectdetils();
                        $scope.getProjectProposalDoc();
                        swal(
                            'Success',
                            'Uploaded Successfully!',
                            'success'
                        )
                        // $scope.disableSubmit = false;

                    }
                    // $scope.getCandidateDetails();\
                    else {
                        debugger;
                        positionIndex += chunkSize;
                        $scope.uploadAttachment(type, userDocId, result);
                    }
                    $scope.showUplaodUserDoc = false;
                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    $scope.saveandNext = function () {
        debugger;

        // Validate project proposal upload
        if (!$scope.projectProposal || !$scope.projectProposal.userDocument || $scope.projectProposal.userDocument.Status__c != 'Uploaded') {
            swal('Info', 'Please upload the project proposal.', 'info');
            return;
        }

        for (var i = 0; i < $scope.allDocs.length; i++) {
            if ($scope.allDocs[i].userDocument.Name == 'No objection certificate') {
                if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
                    swal('Info', 'Please upload no objection certificate.', 'info');
                    return;
                }
            }
            // if($scope.allDocs[i].userDocument.Name == 'Signature of the Host'){
            //     if($scope.allDocs[i].userDocument.Status__c != 'Uploaded'){
            //         swal('info','Please upload signature of the host.','info');
            //         return;
            //     }
            // }else
            // if ($scope.allDocs[i].userDocument.Name == 'Acceptance letter') {
            //     if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
            //         swal('Info', 'Please upload Acceptance Letter.', 'info');
            //         return;
            //     }
            // } else if ($scope.allDocs[i].userDocument.Name == 'No objection certificate') {
            //     if ($scope.allDocs[i].userDocument.Status__c != 'Uploaded') {
            //         swal('Info', 'Please upload no objection certificate.', 'info');
            //         return;
            //     }
            // }
        }

        swal({
            title: "Success",
            text: 'Attachments have been saved successfully.',
            icon: "success",
            button: "ok!",
        }).then(function () {
            $scope.redirectPageURL('Declaration_Wiser');
        });
    }

    // Show spinner on button
    $("#btnPreview").html('<i class="fa-solid fa-spinner fa-spin-pulse me-3"></i>Please wait...');
    $("#btnPreview").prop('disabled', true);

    // ----------------- CODE TO GET PROJECT PROPOSAL DOCUMENT FOR UPLOAD -------------------- //
    $scope.getProjectProposalDoc = function () {
        debugger;
        ApplicantPortal_Contoller.getAllUserDoc($rootScope.proposalId, function (result, event) {
            debugger;
            // Restore button
            $("#btnPreview").html('<i class="fa-solid fa-check me-2"></i>Save and Next');
            $("#btnPreview").prop('disabled', false);
            // console.log('result return onload :: ');
            // console.log(result);
            if (event.status) {
                $scope.projProposal = result;
                var apaId = $scope.projProposal[i].userDocument.Applicant_Proposal_Association__c;

                for (var i = 0; i < $scope.projProposal.length; i++) {
                    if ($scope.projProposal[i].userDocument.Name == 'project Description' && apaId !== null && apaId !== undefined) {
                        $scope.projectProposal = $scope.projProposal[i];
                    }
                }
                $scope.$apply();
            }
        }, {
            escape: true
        })
    }
    $scope.getProjectProposalDoc();

    // $scope.getProjectDetailsOnLoad = function () {
    //     debugger;
    //     $scope.selectedFile = '';
    //     $('#file_frame').attr('src', '');
    //     ApplicantPortal_Contoller.getAllProposalDoc($rootScope.proposalId, function (result, event) {
    //         debugger
    //         console.log('result return onload :: ');
    //         console.log(result);
    //         if (event.status) {
    //             $scope.allDocs = result;
    //             var uploadCount = 0;
    //             for (var i = 0; i < $scope.allDocs.length; i++) {
    //                 if ($scope.allDocs[i].userDocument.Name == 'project Description') {
    //                     $scope.doc = $scope.allDocs[i];
    //                     if ($scope.allDocs[i].userDocument.Status__c == 'Uploaded') {
    //                         uploadCount = uploadCount + 1;
    //                     }
    //                 }
    //             }
    //             $scope.$apply();
    //         }
    //     }, {
    //         escape: true
    //     })
    // }
    // $scope.getProjectDetailsOnLoad();



});



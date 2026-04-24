angular.module('cp_app').controller('cv_wiser', function ($scope, $rootScope) {
    debugger;
    $scope.siteURL = siteURL;
    $scope.contactData = {};
    $scope.proposalStage = false;
    $scope.isCurrentUserSubmitted = false;
    $scope.objRtf = [{ charCount: 0, maxCharLimit: 0, errorStatus: false }];
    $scope.objRtf.push({ charCount: 0, maxCharLimit: 0, errorStatus: false });
    $scope.objRtf.push({ charCount: 0, maxCharLimit: 0, errorStatus: false });
    $scope.objRtf.push({ charCount: 0, maxCharLimit: 0, errorStatus: false });

    // Function to update editor lock state based on current conditions
    $scope.updateEditorLockState = function () {
        // 🔐 Lock editor condition: disabled if proposalStage is true OR isCurrentUserSubmitted is true
        $scope.isEditorLocked = ($scope.proposalStage || $scope.isCurrentUserSubmitted);

        // 🔒 Apply lock to CKEditor instances (with retry mechanism)
        $scope.toggleCkEditorReadOnly($scope.isEditorLocked);
    };

    $scope.toggleCkEditorReadOnly = function (isReadOnly) {
        var retryCount = 0;
        var maxRetries = 10;

        function tryToggle() {
            if (CKEDITOR && CKEDITOR.instances && Object.keys(CKEDITOR.instances).length > 0) {
                Object.keys(CKEDITOR.instances).forEach(function (instanceName) {
                    try {
                        CKEDITOR.instances[instanceName].setReadOnly(isReadOnly);
                    } catch (e) {
                        console.log('Error setting read-only for instance:', instanceName, e);
                    }
                });
            } else if (retryCount < maxRetries) {
                retryCount++;
                setTimeout(tryToggle, 200);
            }
        }

        tryToggle();
    };

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
                    $scope.proposalStage = (result.proposalStage != 'Draft' && result.proposalStage != null && result.proposalStage != undefined);
                    $rootScope.proposalStage = $scope.proposalStage;
                    // Update editor lock state after proposal stage is fetched
                    $scope.updateEditorLockState();
                    $scope.$apply();
                }
            }, { escape: true });
        }
    }

    $scope.getProposalStage();

    /*
    $scope.getCVDetailsForWiserApplicant = function () {
        debugger;
        ApplicantPortal_Contoller.getCVDetailsForWiserApplicant($rootScope.candidateId, $rootScope.apaId, function (result, event) {
            debugger;
            if (event.status && result) {
                debugger;
                $scope.contactData = result;
                if ($scope.contactData.FirstName != undefined || $scope.contactData.FirstName != "") {
                    $scope.contactData.FirstName = $scope.contactData.FirstName ? $scope.contactData.FirstName.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.FirstName;
                }
                if ($scope.contactData.LastName != undefined || $scope.contactData.LastName != "") {
                    $scope.contactData.LastName = $scope.contactData.LastName ? $scope.contactData.LastName.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.LastName;
                }
                if ($scope.contactData.Publications_Patents__c != undefined || $scope.contactData.Publications_Patents__c != "") {
                    $scope.contactData.Publications_Patents__c = $scope.contactData.Publications_Patents__c ? $scope.contactData.Publications_Patents__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Publications_Patents__c;
                }
                if ($scope.contactData.List_Of_Patents_Filed_Granted__c != undefined || $scope.contactData.List_Of_Patents_Filed_Granted__c != "") {
                    $scope.contactData.List_Of_Patents_Filed_Granted__c = $scope.contactData.List_Of_Patents_Filed_Granted__c ? $scope.contactData.List_Of_Patents_Filed_Granted__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.List_Of_Patents_Filed_Granted__c;
                }
                if ($scope.contactData.Book_Chapters_Monographs__c != undefined || $scope.contactData.Book_Chapters_Monographs__c != "") {
                    $scope.contactData.Book_Chapters_Monographs__c = $scope.contactData.Book_Chapters_Monographs__c ? $scope.contactData.Book_Chapters_Monographs__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Book_Chapters_Monographs__c;
                }
                if ($scope.contactData.Any_Other_Notable_Achievements__c != undefined || $scope.contactData.Any_Other_Notable_Achievements__c != "") {
                    $scope.contactData.Any_Other_Notable_Achievements__c = $scope.contactData.Any_Other_Notable_Achievements__c ? $scope.contactData.Any_Other_Notable_Achievements__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Any_Other_Notable_Achievements__c;
                }
                if ($scope.contactData.Education_Details__r == undefined) {
                    var rec = {
                        'Applicant_Proposal_Association__c': $scope.apaId,
                        'Institution_Name__c': '',
                        'Contact__c': $scope.contactData.Id
                    };
                    $scope.contactData.Education_Details__r = [];
                    debugger;
                    $scope.contactData.Education_Details__r.push(rec);
                } else {
                    for (var i = 0; i < $scope.contactData.Education_Details__r.length; i++) {
                        if ($scope.contactData.Education_Details__r[i].Degree__c != undefined || $scope.contactData.Education_Details__r[i].Degree__c != "") {
                            $scope.contactData.Education_Details__r[i].Degree__c = $scope.contactData.Education_Details__r[i].Degree__c ? $scope.contactData.Education_Details__r[i].Degree__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Education_Details__r[i].Degree__c;
                        }
                        if ($scope.contactData.Education_Details__r[i].Institution_Name__c != undefined || $scope.contactData.Education_Details__r[i].Institution_Name__c != "") {
                            $scope.contactData.Education_Details__r[i].Institution_Name__c = $scope.contactData.Education_Details__r[i].Institution_Name__c ? $scope.contactData.Education_Details__r[i].Institution_Name__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Education_Details__r[i].Institution_Name__c;
                        }
                        if ($scope.contactData.Education_Details__r[i].Area_of_specialization__c != undefined || $scope.contactData.Education_Details__r[i].Area_of_specialization__c != "") {
                            $scope.contactData.Education_Details__r[i].Area_of_specialization__c = $scope.contactData.Education_Details__r[i].Area_of_specialization__c ? $scope.contactData.Education_Details__r[i].Area_of_specialization__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Education_Details__r[i].Area_of_specialization__c;
                        }
                    }
                }

                // ============================== CODE TO POPULATE EMPLOYMENT DETAILS =============================
                if (!$scope.contactData.Employment_Details__r ||
                    $scope.contactData.Employment_Details__r.length === 0) {

                    // Create fallback record using Contact data
                    var emprec = {
                        Applicant_Proposal_Association__c: $rootScope.apaId,
                        Organization_Name__c: $scope.contactData.Account ? $scope.contactData.Account.Name : '',
                        Position__c: $scope.contactData.Designation__c || '',
                        Contact__c: $scope.contactData.Id,
                        current_employement__c: true
                    };

                    $scope.contactData.Employment_Details__r = [emprec];

                } else {

                    // Records exist – clean values only
                    for (var i = 0; i < $scope.contactData.Employment_Details__r.length; i++) {

                        if (!$scope.contactData.Employment_Details__r[i].Organization_Name__c) {
                            $scope.contactData.Employment_Details__r[i].Organization_Name__c =
                                $scope.contactData.Account
                                    ? $scope.contactData.Account.Name
                                    : '';
                        }

                        if (!$scope.contactData.Employment_Details__r[i].Position__c) {
                            $scope.contactData.Employment_Details__r[i].Position__c =
                                $scope.contactData.Designation__c || '';
                        }
                    }
                }


                // if (!$scope.contactData.Employment_Details__r ||
                //     $scope.contactData.Employment_Details__r.length === 0) {

                //     // No employment record → show Contact data
                //     $scope.contactData.Employment_Details__r = [{
                //         Applicant_Proposal_Association__c: $rootScope.apaId,
                //         Organization_Name__c: $scope.contactData.Account
                //                                 ? $scope.contactData.Account.Name
                //                                 : '',
                //         Position__c: $scope.contactData.Designation__c || '',
                //         Contact__c: $scope.contactData.Id
                //     }];

                // } else {

                //     // Employment exists → override only EMPTY fields
                //     for (var i = 0; i < $scope.contactData.Employment_Details__r.length; i++) {

                //         var emp = $scope.contactData.Employment_Details__r[i];

                //         if (!emp.Organization_Name__c || emp.Organization_Name__c.trim() === '') {
                //             emp.Organization_Name__c = $scope.contactData.Account
                //                                         ? $scope.contactData.Account.Name
                //                                         : '';
                //         }

                //         if (!emp.Position__c || emp.Position__c.trim() === '') {
                //             emp.Position__c = $scope.contactData.Designation__c || '';
                //         }
                //     }
                // }

                // if ($scope.contactData.Employment_Details__r == undefined) {
                //     var emprec = {
                //         'Applicant_Proposal_Association__c': $scope.apaId,
                //         "Organization_Name__c": "",
                //         "Contact__c": $scope.contactData.Id
                //     };
                //     $scope.contactData.Employment_Details__r = [];
                //     debugger;
                //     $scope.contactData.Employment_Details__r.push(emprec);
                // } else {
                //     for (var i = 0; i < $scope.contactData.Employment_Details__r.length; i++) {
                //         if ($scope.contactData.Employment_Details__r[i].Organization_Name__c != undefined || $scope.contactData.Employment_Details__r[i].Organization_Name__c != "") {
                //             //$scope.contactData.Employment_Details__r[i].Organization_Name__c = $scope.contactData.Employment_Details__r[i].Organization_Name__c ? $scope.contactData.Employment_Details__r[i].Organization_Name__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Employment_Details__r[i].Organization_Name__c;
                //             $scope.contactData.Employment_Details__r[i].Organization_Name__c = $scope.contactData.Employment_Details__r[i].Organization_Name__c ? $scope.contactData.Employment_Details__r[i].Organization_Name__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Account.Name;

                //         }
                //         if ($scope.contactData.Employment_Details__r[i].Position__c != undefined || $scope.contactData.Employment_Details__r[i].Position__c != "") {
                //             //$scope.contactData.Employment_Details__r[i].Position__c = $scope.contactData.Employment_Details__r[i].Position__c ? $scope.contactData.Employment_Details__r[i].Position__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Employment_Details__r[i].Position__c;
                //             $scope.contactData.Employment_Details__r[i].Position__c = $scope.contactData.Employment_Details__r[i].Position__c ? $scope.contactData.Employment_Details__r[i].Position__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('lt;', '<').replaceAll('&gt;', '>').replaceAll('gt;', '>').replaceAll('&amp;', '&').replaceAll('amp;', '&').replaceAll('&quot;', '\'') : $scope.contactData.Designation__c;
                //         }
                //     }
                // }

                // Update editor lock state after CV data is loaded
                $scope.updateEditorLockState();
                $scope.$apply();
            }
        })
    }
    $scope.getCVDetailsForWiserApplicant();
    */


    // Initialize scope variables
    $scope.apaRecordData = null;  // This will hold the APA record with all fields
    $scope.educationList = [];     // This will hold education details
    $scope.employmentList = [];    // This will hold employment details

    $scope.getCVDetailsForWiserApplicant = function () {
        debugger;
        ApplicantPortal_Contoller.getCVDetailsForWiserApplicant($rootScope.candidateId, $rootScope.apaId, function (result, event) {
            debugger;
            if (event.status && result) {
                // Store the wrapper data
                $scope.cvWrapperData = result;

                // 1. Store APA Record (this contains Publications_Patents__c, etc.)
                $scope.apaRecordData = result.apaRecord;

                // 2. Store Education Details
                if (result.educationDetails && result.educationDetails.length > 0) {
                    $scope.educationList = result.educationDetails;
                    debugger;
                    console.log('educationList: ' + JSON.stringify($scope.educationList));
                } else {
                    // Create one empty row for user to fill
                    $scope.educationList = [{
                        'Id': '',
                        'Degree__c': '',
                        'Institution_Name__c': '',
                        'Area_of_specialization__c': '',
                        'Start_Year__c': '',
                        'End_Year__c': ''
                    }];
                }

                // 3. Store Employment Details
                if (result.employmentDetails && result.employmentDetails.length > 0) {
                    $scope.employmentList = result.employmentDetails;
                    console.log('employmentList: ' + JSON.stringify($scope.employmentList));
                } else {
                    // Create one empty row for user to fill
                    $scope.employmentList = [{
                        'Id': '',
                        'Organization_Name__c': '',
                        'Position__c': '',
                        'Start_Year__c': '',
                        'End_Year__c': '',
                        'current_employement__c': false
                    }];
                }

                // Apply HTML entity replacement if needed
                $scope.cleanSpecialCharacters();

                $scope.updateEditorLockState();
                $scope.$apply();
            }
        });
    }

    // Helper function to clean HTML entities
    $scope.cleanSpecialCharacters = function () {
        // Clean APA Record fields
        if ($scope.apaRecordData) {
            if ($scope.apaRecordData.Publications_Patents__c) {
                $scope.apaRecordData.Publications_Patents__c = $scope.replaceHtmlEntities($scope.apaRecordData.Publications_Patents__c);
            }
            if ($scope.apaRecordData.List_Of_Patents_Filed_Granted__c) {
                $scope.apaRecordData.List_Of_Patents_Filed_Granted__c = $scope.replaceHtmlEntities($scope.apaRecordData.List_Of_Patents_Filed_Granted__c);
            }
            if ($scope.apaRecordData.Book_Chapters_Monographs__c) {
                $scope.apaRecordData.Book_Chapters_Monographs__c = $scope.replaceHtmlEntities($scope.apaRecordData.Book_Chapters_Monographs__c);
            }
            if ($scope.apaRecordData.Any_Other_Notable_Achievements__c) {
                $scope.apaRecordData.Any_Other_Notable_Achievements__c = $scope.replaceHtmlEntities($scope.apaRecordData.Any_Other_Notable_Achievements__c);
            }
        }

        // Clean Education List
        angular.forEach($scope.educationList, function (edu) {
            if (edu.Degree__c) edu.Degree__c = $scope.replaceHtmlEntities(edu.Degree__c);
            if (edu.Institution_Name__c) edu.Institution_Name__c = $scope.replaceHtmlEntities(edu.Institution_Name__c);
            if (edu.Area_of_specialization__c) edu.Area_of_specialization__c = $scope.replaceHtmlEntities(edu.Area_of_specialization__c);
        });

        // Clean Employment List
        angular.forEach($scope.employmentList, function (emp) {
            if (emp.Organization_Name__c) emp.Organization_Name__c = $scope.replaceHtmlEntities(emp.Organization_Name__c);
            if (emp.Position__c) emp.Position__c = $scope.replaceHtmlEntities(emp.Position__c);
        });
    }

    $scope.replaceHtmlEntities = function (text) {
        if (!text) return text;
        return text.replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, "'");
    }

    /*
    // Modified addEducationRow function to work with contactData
    $scope.addEducationRow = function () {
        if (!$scope.contactData.Education_Details__r) {
            $scope.contactData.Education_Details__r = [];
        }
        var newEdu = {
            'Applicant_Proposal_Association__c': $rootScope.apaId,
            'Institution_Name__c': '',
            'Degree__c': '',
            'Area_of_specialization__c': '',
            'Start_Year__c': '',
            'End_Year__c': '',
            'Contact__c': $scope.contactData.Id
        };
        $scope.contactData.Education_Details__r.push(newEdu);
    }

    // Modified removeEducationRow function
    $scope.removeEducationRow = function (index) {
        if ($scope.contactData.Education_Details__r && $scope.contactData.Education_Details__r.length > index) {
            $scope.contactData.Education_Details__r.splice(index, 1);
        }
    }

    // Modified addEmploymentRow function (if needed)
    $scope.addEmploymentRow = function () {
        if (!$scope.contactData.Employment_Details__r) {
            $scope.contactData.Employment_Details__r = [];
        }
        var newEmp = {
            'Applicant_Proposal_Association__c': $rootScope.apaId,
            'Organization_Name__c': '',
            'Position__c': '',
            'Start_Year__c': '',
            'End_Year__c': '',
            'current_employement__c': false,
            'Contact__c': $scope.contactData.Id
        };
        $scope.contactData.Employment_Details__r.push(newEmp);
    }

    // Modified removeEmploymentRow function
    $scope.removeEmploymentRow = function (index) {
        if ($scope.contactData.Employment_Details__r && $scope.contactData.Employment_Details__r.length > index) {
            $scope.contactData.Employment_Details__r.splice(index, 1);
        }
    }
    */

    // Initialize the function
    $scope.getCVDetailsForWiserApplicant();

    // Show spinner on button
    $("#btnPreview").html('<i class="fa-solid fa-spinner fa-spin-pulse me-3"></i>Please wait...');
    $("#btnPreview").prop('disabled', true);

    // Helper function to restore button state
    $scope.restoreButtonState = function () {
        $("#btnPreview").html('<i class="fa-solid fa-check me-2"></i>Save and Next');
        $("#btnPreview").prop('disabled', false);
    };

    // $scope.saveAllDetails = function () {
    //     debugger;
    //     try {
    //         // Show spinner on button
    //         $("#btnPreview").html('<i class="fa-solid fa-spinner fa-spin-pulse me-3"></i>Please wait...');
    //         $("#btnPreview").prop('disabled', true);

    //         if ($scope.contactData != undefined) {
    //             if ($scope.contactData.Education_Details__r != undefined) {
    //                 for (var i = 0; i < $scope.contactData.Education_Details__r.length; i++) {
    //                     $scope.contactData.Education_Details__r[i].Applicant_Proposal_Association__c = $scope.apaId;
    //                     if ($scope.contactData.Education_Details__r[i].Institution_Name__c == undefined || $scope.contactData.Education_Details__r[i].Institution_Name__c == "") {
    //                         swal("Education Details", "Please Enter Institution Name.");
    //                         $("#institution" + i + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                     if ($scope.contactData.Education_Details__r[i].Area_of_specialization__c == undefined || $scope.contactData.Education_Details__r[i].Area_of_specialization__c == "") {
    //                         swal("Education Details", "Please Enter Specialization.");
    //                         $("#specialization" + i + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                     if ($scope.contactData.Education_Details__r[i].Degree__c == undefined || $scope.contactData.Education_Details__r[i].Degree__c == "") {
    //                         swal("Education Details", "Please Enter Degree.");
    //                         $("#degree" + i + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                     if ($scope.contactData.Education_Details__r[i].Start_Year__c == undefined || $scope.contactData.Education_Details__r[i].Start_Year__c == "") {
    //                         swal("Education Details", "Please Enter Start Year.");
    //                         $("#zipCode1" + i + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                     if ($scope.contactData.Education_Details__r[i].End_Year__c == undefined || $scope.contactData.Education_Details__r[i].End_Year__c == "") {
    //                         swal("Education Details", "Please Enter End Year.");
    //                         $("#zipCode2" + i + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                 }
    //             }

    //             if ($scope.contactData.Employment_Details__r != undefined) {
    //                 for (var j = 0; j < $scope.contactData.Employment_Details__r.length; j++) {
    //                     $scope.contactData.Employment_Details__r[j].Applicant_Proposal_Association__c = $scope.apaId;

    //                     if ($scope.contactData.Employment_Details__r[j].Organization_Name__c == undefined || $scope.contactData.Employment_Details__r[j].Organization_Name__c == "") {
    //                         swal("Employment Details", "Please Enter Organization Name.");
    //                         $("#org" + j + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }

    //                     if ($scope.contactData.Employment_Details__r[j].Position__c == undefined || $scope.contactData.Employment_Details__r[j].Position__c == "") {
    //                         swal("Employment Details", "Please Enter Position.");
    //                         $("#position" + j + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }

    //                     if ($scope.contactData.Employment_Details__r[j].Start_Year__c == undefined || $scope.contactData.Employment_Details__r[j].Start_Year__c == "") {
    //                         swal("Employment Details", "Please Enter Start Year.");
    //                         $("#zipCode11" + j + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }

    //                     if ($scope.contactData.Employment_Details__r[j].End_Year__c == undefined || $scope.contactData.Employment_Details__r[j].End_Year__c == "") {
    //                         swal("Employment Details", "Please Enter End Year.");
    //                         $("#zipCode22" + j + "").addClass('border-theme');
    //                         $scope.restoreButtonState();
    //                         return;
    //                     }
    //                 }

    //             }

    //         }

    //         $scope.educationDetails = [];
    //         $scope.employmentDetails = [];
    //         $scope.educationDetails = $scope.contactData.Education_Details__r;
    //         $scope.employmentDetails = $scope.contactData.Employment_Details__r;

    //         delete ($scope.contactData['Education_Details__r']);
    //         delete ($scope.contactData['Employment_Details__r']);
    //         delete ($scope.contactData['Education_Details__r']);

    //         // Preserve MailingState: Ensure State__c is set to MailingState if State__c is empty but MailingState has a value
    //         // This ensures the backend can properly map State__c to MailingState
    //         if (($scope.contactData.MailingState !== undefined && $scope.contactData.MailingState !== null && $scope.contactData.MailingState !== '')
    //             && ($scope.contactData.State__c === undefined || $scope.contactData.State__c === null || $scope.contactData.State__c === '')) {
    //             $scope.contactData.State__c = $scope.contactData.MailingState;
    //         }

    //         for (var i = 0; i < $scope.educationDetails.length; i++) {
    //             delete ($scope.educationDetails[i]['$$hashKey']);
    //         }
    //         for (var i = 0; i < $scope.employmentDetails.length; i++) {
    //             delete ($scope.employmentDetails[i]['$$hashKey']);
    //         }

    //         ApplicantPortal_Contoller.SaveWorkshopContactDetails2($scope.contactData, $scope.educationDetails, $scope.employmentDetails, $scope.apaId, function (result, event) {
    //             debugger;
    //             try {
    //                 if (event.status) {
    //                     debugger;
    //                     // Use Swal.fire with promise handling for better error handling

    //                     swal({
    //                         title: "SUCCESS",
    //                         text: 'Your CV Details has been Saved successfully.',
    //                         icon: "success",
    //                         confirmButtonText: "OK"
    //                     });

    //                     // Redirect after user clicks OK
    //                     $scope.redirectPageURL('FinancialOverview_wiser');
    //                     //$scope.$apply();

    //                 } else {
    //                     // Re-enable button on error
    //                     $scope.restoreButtonState();
    //                     $scope.$apply();
    //                 }
    //             } catch (error) {
    //                 // Re-enable button on unexpected error in callback
    //                 console.error('Error in save callback:', error);
    //                 $scope.restoreButtonState();
    //                 $scope.$apply();
    //             }
    //         }, { escape: true });
    //     } catch (error) {
    //         // Re-enable button on unexpected error
    //         console.error('Error in saveAllDetails:', error);
    //         $scope.restoreButtonState();
    //     }
    // }

    $scope.saveAllDetails = function () {
        debugger;
        try {
            // Show spinner on button
            $("#btnPreview").html('<i class="fa-solid fa-spinner fa-spin-pulse me-3"></i>Please wait...');
            $("#btnPreview").prop('disabled', true);

            // Prepare education details array
            var educationDetailsToSave = [];
            if ($scope.educationList && $scope.educationList.length > 0) {
                for (var i = 0; i < $scope.educationList.length; i++) {
                    var edu = $scope.educationList[i];

                    // Validate
                    if (!edu.Degree__c || edu.Degree__c.trim() == "") {
                        swal("Education Details", "Please Enter Degree.");
                        $("#degree" + i).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!edu.Institution_Name__c || edu.Institution_Name__c.trim() == "") {
                        swal("Education Details", "Please Enter Institution Name.");
                        $("#institution" + i).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!edu.Area_of_specialization__c || edu.Area_of_specialization__c.trim() == "") {
                        swal("Education Details", "Please Enter Specialization.");
                        $("#specialization" + i).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!edu.Start_Year__c || edu.Start_Year__c.toString().trim() == "") {
                        swal("Education Details", "Please Enter Start Year.");
                        $("#zipCode1" + i).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!edu.End_Year__c || edu.End_Year__c.toString().trim() == "") {
                        swal("Education Details", "Please Enter End Year.");
                        $("#zipCode2" + i).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }

                    // Create a clean object without Angular properties
                    var eduToSave = {
                        'Id': edu.Id || '',
                        'Degree__c': edu.Degree__c,
                        'Institution_Name__c': edu.Institution_Name__c,
                        'Area_of_specialization__c': edu.Area_of_specialization__c,
                        'Start_Year__c': edu.Start_Year__c,
                        'End_Year__c': edu.End_Year__c,
                        'Percentage__c': edu.Percentage__c || '',
                        'Percentage_cgpa__c': edu.Percentage_cgpa__c || ''
                    };
                    educationDetailsToSave.push(eduToSave);
                }
            }

            // Prepare employment details array
            var employmentDetailsToSave = [];
            if ($scope.employmentList && $scope.employmentList.length > 0) {
                for (var j = 0; j < $scope.employmentList.length; j++) {
                    var emp = $scope.employmentList[j];

                    // Validate
                    if (!emp.Organization_Name__c || emp.Organization_Name__c.trim() == "") {
                        swal("Employment Details", "Please Enter Organization Name.");
                        $("#org" + j).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!emp.Position__c || emp.Position__c.trim() == "") {
                        swal("Employment Details", "Please Enter Position.");
                        $("#position" + j).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!emp.Start_Year__c || emp.Start_Year__c.toString().trim() == "") {
                        swal("Employment Details", "Please Enter Start Year.");
                        $("#zipCode11" + j).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }
                    if (!emp.End_Year__c || emp.End_Year__c.toString().trim() == "") {
                        swal("Employment Details", "Please Enter End Year.");
                        $("#zipCode22" + j).addClass('border-theme');
                        $scope.restoreButtonState();
                        return;
                    }

                    // Create a clean object without Angular properties
                    var empToSave = {
                        'Id': emp.Id || '',
                        'Organization_Name__c': emp.Organization_Name__c,
                        'Position__c': emp.Position__c,
                        'Start_Year__c': emp.Start_Year__c,
                        'End_Year__c': emp.End_Year__c,
                        'current_employement__c': emp.current_employement__c || false,
                        'Nature_of_Job__c': emp.Nature_of_Job__c || ''
                    };
                    employmentDetailsToSave.push(empToSave);
                }
            }

            console.log('Education to save:', educationDetailsToSave);
            console.log('Employment to save:', employmentDetailsToSave);

            /*
            // Call the save method with simple parameters
            ApplicantPortal_Contoller.saveCVDetails(
                $scope.apaId,
                $scope.apaRecordData,
                JSON.stringify(educationDetailsToSave),
                JSON.stringify(employmentDetailsToSave),
                function (result, event) {
                    debugger;
                    try {
                        if (event.status && result === 'SUCCESS') {
                            var afterSuccess = function () {
                                $scope.redirectPageURL('FinancialOverview_wiser');
                                $scope.$apply();
                            };

                            if (typeof swal !== 'undefined' && typeof swal === 'function') {
                                swal({
                                    title: "Success",
                                    text: "Your CV Details have been saved successfully.",
                                    icon: "success",
                                    confirmButtonText: "OK"
                                }).then(function () {
                                    afterSuccess();
                                });
                            } else {
                                swal({
                                    title: "Success",
                                    text: "Your CV Details have been saved successfully.",
                                    type: "success",
                                    confirmButtonText: "OK"
                                }, function () {
                                    afterSuccess();
                                });
                            }
                        } else {
                            swal("ERROR", result || 'Error saving details. Please try again.', "error");
                            $scope.$apply();
                        }
                    } catch (error) {
                        console.error('Error in save callback:', error);
                        $scope.restoreButtonState();
                        $scope.$apply();
                    }
                });

            */

            ApplicantPortal_Contoller.saveCVDetails(
                $scope.apaId,
                $scope.apaRecordData,
                JSON.stringify(educationDetailsToSave),
                JSON.stringify(employmentDetailsToSave),
                function (result, event) {
                    debugger
                    if (event.status) {
                        swal({
                            title: "Success",
                            text: "Your CV Details have been saved successfully.",
                            type: "success",
                            button: "OK",
                        }).then((value) => {
                            $scope.restoreButtonState();
                            $scope.redirectPageURL('FinancialOverview_wiser');
                            $scope.$apply();
                        });
                        $scope.$apply();
                    }
                }, {
                escape: true
            })

        } catch (error) {
            console.error('Error in saveAllDetails:', error);
            $scope.restoreButtonState();
            swal("ERROR", "An unexpected error occurred: " + error.message, "error");
        }
    }

    $scope.restoreButtonState = function () {
        $("#btnPreview").html('<i class="fa-regular fa-floppy-disk me-3"></i>Save & Continue');
        $("#btnPreview").prop('disabled', false);
    }




    /*
    $scope.addEducationRow = function () {
        debugger;
        $scope.contactData.Education_Details__r.push({
            Institution_Name__c: "",
            Contact__c: $scope.contactData.Id
        });
        $scope.$apply();
        debugger;
    }
    $scope.removeEducationRow = function (index) {
        debugger;
        if ($scope.contactData.Education_Details__r.length != 1) {
            if ($scope.contactData.Education_Details__r[index].Id != undefined && $scope.contactData.Education_Details__r[index].Id != "") {
                $scope.deleteEducationRow($scope.contactData.Education_Details__r[index].Id);
            } else {
                $scope.contactData.Education_Details__r.splice(index, 1);
            }
        }
    }

    $scope.deleteEducationRow = function (eduId) {
        ApplicantPortal_Contoller.deleteEducationWorkshop(eduId, function (result, event) {
            if (event.status) {
                debugger;
                Swal.fire(
                    'Success',
                    'Deleted Succesfully.',
                    'success'
                );
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }

    $scope.addEmploymentRow = function (index) {
        debugger;
        $scope.contactData.Employment_Details__r.push({
            Organization_Name__c: "",
            Contact__c: $scope.contactData.Id
        });
        $scope.$apply();
        debugger;
    }
    $scope.removeEmploymentRow = function (index) {
        debugger;
        if ($scope.contactData.Employment_Details__r.length != 1) {
            if ($scope.contactData.Employment_Details__r[index].Id != undefined && $scope.contactData.Employment_Details__r[index].Id != "") {
                $scope.deleteEmploymentWorkshop($scope.contactData.Employment_Details__r[index].Id);
            } else {
                $scope.contactData.Employment_Details__r.splice(index, 1);
            }
        }
    }

    $scope.deleteEmploymentWorkshop = function (empId) {
        ApplicantPortal_Contoller.deleteEmploymentWorkshop(empId, function (result, event) {
            if (event.status) {
                debugger;
                Swal.fire(
                    'Success',
                    'Deleted Succesfully.',
                    'success'
                );
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }
    */
    // ========== EDUCATION ROW MANAGEMENT ==========
    $scope.addEducationRow = function () {
        debugger;
        $scope.educationList.push({
            'Degree__c': '',
            'Institution_Name__c': '',
            'Area_of_specialization__c': '',
            'Start_Year__c': '',
            'End_Year__c': ''
        });
        $scope.$apply();
    }

    $scope.removeEducationRow = function (index) {
        debugger;
        if ($scope.educationList.length > 1) {
            // If the record has an ID (already saved in database), delete it via server
            if ($scope.educationList[index].Id != undefined && $scope.educationList[index].Id != "") {
                $scope.deleteEducationRow($scope.educationList[index].Id, index);
            } else {
                // Just remove from local array
                $scope.educationList.splice(index, 1);
            }
        } else {
            // Don't remove the last row, just clear it
            swal("Information", "You must have at least one education record.", "info");
        }
    }

    $scope.deleteEducationRow = function (eduId, index) {
        ApplicantPortal_Contoller.deleteEducationWorkshop(eduId, function (result, event) {
            if (event.status) {
                debugger;
                // Remove from local array after successful deletion
                for (var i = 0; i < $scope.educationList.length; i++) {
                    if ($scope.educationList[i].Id == eduId) {
                        $scope.educationList.splice(i, 1);
                        break;
                    }
                }
                swal('Success', 'Deleted Successfully.', 'success');
                $scope.$apply();
            }
        }, { escape: true });
    }

    // ========== EMPLOYMENT ROW MANAGEMENT ==========
    $scope.addEmploymentRow = function () {
        debugger;
        $scope.employmentList.push({
            'Organization_Name__c': '',
            'Position__c': '',
            'Start_Year__c': '',
            'End_Year__c': '',
            'current_employement__c': false
        });
        $scope.$apply();
    }

    $scope.removeEmploymentRow = function (index) {
        debugger;
        if ($scope.employmentList.length > 1) {
            // If the record has an ID (already saved in database), delete it via server
            if ($scope.employmentList[index].Id != undefined && $scope.employmentList[index].Id != "") {
                $scope.deleteEmploymentWorkshop($scope.employmentList[index].Id, index);
            } else {
                // Just remove from local array
                $scope.employmentList.splice(index, 1);
            }
        } else {
            // Don't remove the last row, just clear it
            swal("Information", "You must have at least one employment record.", "info");
        }
    }

    $scope.deleteEmploymentWorkshop = function (empId, index) {
        ApplicantPortal_Contoller.deleteEmploymentWorkshop(empId, function (result, event) {
            if (event.status) {
                debugger;
                // Remove from local array after successful deletion
                for (var i = 0; i < $scope.employmentList.length; i++) {
                    if ($scope.employmentList[i].Id == empId) {
                        $scope.employmentList.splice(i, 1);
                        break;
                    }
                }
                swal('Success', 'Deleted Successfully.', 'success');
                $scope.$apply();
            }
        }, { escape: true });
    }


    $scope.redirectPageURL = function (pageName) {
        debugger;
        var link = document.createElement("a");
        link.Id = 'someLink'; //give it an ID!
        link.href = "#/" + pageName;
        link.click();
    }

    $scope.removeClass = function (controlid, index) {
        debugger;
        var controlIdfor = controlid + "" + index;
        $("#" + controlIdfor + "").removeClass('border-theme');
    }

    $scope.removeClass2 = function (controlid) {
        $("#" + controlid + "").removeClass('border-theme');
    }
    $scope.readCharacter = function (event, index) {
        try {
            var rtfString = event.toString().replace(/<[^>]*>|\s/g, '').replace(/\s+/g, '').replace(/&ndash;/g, '-').replace(/&euro;/g, '1').replace(/&amp;/g, '1').replace(/&#39;/g, '1').replace(/&quot;/g, '1').replace(/&nbsp;/g, '').replace(/&mdash;/g, '-').replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&bull;/g, '');
            charLength = rtfString.length;
            if (charLength > 0)
                $scope.objRtf[index].charCount = charLength;
            else
                $scope.objRtf[index].charCount = 0;
        } catch (e) { }
    }
    // $scope.readCharacter2=function(event){
    //     debugger
    //        var hh=$scope.contactData.List_Of_Patents_Filed_Granted__c;
    //        try{
    //        var ffh=hh.toString();
    //         var hhg=hh.replace(/<[^>]*>|\s/g, '').length;
    //         hhg=hhg.replace(/\s+/g,'').length;
    //         hhg=hhg.replace(/&nbsp;/g,'').length;
    //         if(hhg>0)
    //         $scope.rtf2=hhg;
    //         else
    //         $scope.rtf2=0;        
    //        }catch(e){}
    //    }
    var inputQuantity = [];
    $(function () {
        $(".zipcode-number").on("keyup", function (e) {
            var $field = $(this),
                val = this.value,
                $thisIndex = parseInt($field.data("idx"), 10);
            if (this.validity && this.validity.badInput || isNaN(val) || $field.is(":invalid")) {
                this.value = inputQuantity[$thisIndex];
                return;
            }
            if (val.length > Number($field.attr("maxlength"))) {
                val = val.slice(0, 5);
                $field.val(val);
            }
            inputQuantity[$thisIndex] = val;
        });
    });

    // $scope.getApplicantStatusFromAPA = function () {
    //     debugger;

    //     if (!$rootScope.apaId) {
    //         console.log('APA Id not available yet, skipping fetchApplicantStatus call');
    //         return;
    //     }

    //     ApplicantPortal_Contoller.fetchApplicantStatus(
    //         $rootScope.apaId,
    //         function (result, event) {
    //             debugger;

    //             if (event.status) {
    //                 $rootScope.isCurrentUserSubmitted = result;
    //                 $scope.isCurrentUserSubmitted = result;

    //                 // Update editor lock state after applicant status is fetched
    //                 $scope.updateEditorLockState();
    //                 $scope.$apply();
    //             } else {
    //                 // If fetch fails, assume not submitted
    //                 $rootScope.isCurrentUserSubmitted = false;
    //                 $scope.isCurrentUserSubmitted = false;
    //                 $scope.updateEditorLockState();
    //                 $scope.$apply();
    //             }
    //         },
    //         { escape: true }
    //     );
    // };
    // $scope.getApplicantStatusFromAPA();
});
angular.module('cp_app').controller('proposal_ctrl', function ($scope, $rootScope) {
    debugger;

    // Fetching the proposalId from Local Storage
    if (localStorage.getItem('proposalId')) {
        $rootScope.proposalId = localStorage.getItem('proposalId');
        console.log('Loaded proposalId from localStorage:', $rootScope.proposalId);
    }
    // Get apaId from LocalStorage
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

    $rootScope.siteURL = siteURL;
    $rootScope.proposalDetails = {};
    $scope.config.height = 500;
    $rootScope.proposalId;

    $scope.objRtf = [{ charCount: 0, maxCharLimit: 4500, errorStatus: false }];
    $scope.objRtf.push({ charCount: 0, maxCharLimit: 3000, errorStatus: false });

    $scope.readCharacter = function (event, index) {
        try {
            var rtfString = event.toString().replace(/<[^>]*>|\s/g, '').replace(/\s+/g, '').replace(/&ndash;/g, '-').replace(/&euro;/g, '1').replace(/&amp;/g, '1').replace(/&#39;/g, '1').replace(/&quot;/g, '1').replace(/&nbsp;/g, '').replace(/&mdash;/g, '-').replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&bull;/g, '');
            charLength = rtfString.length;
            if (charLength > 0) {
                $scope.objRtf[index].charCount = charLength;
                if (charLength > $scope.objRtf[index].maxCharLimit) {
                    $scope.objRtf[index].errorStatus = true;
                } else {
                    $scope.objRtf[index].errorStatus = false;
                }
            }
            else {
                $scope.objRtf[index].charCount = 0;
                $scope.objRtf[index].errorStatus = false;
            }
        } catch (e) { }
    }

    $scope.getProposalDetails = function () {
        debugger;

        // ApplicantPortal_Contoller.getProjectdetils($rootScope.candidateId, function (result, event) {
        WorkshopController2.getProjectdetils($rootScope.proposalId, function (result, event) {
            if (event.status) {
                $scope.proposalDetails = result;
                if (result.Background_Concept_Purpose__c != undefined || result.Background_Concept_Purpose__c != "") {
                    $scope.proposalDetails.Background_Concept_Purpose__c = result.Background_Concept_Purpose__c ? result.Background_Concept_Purpose__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&') : result.Background_Concept_Purpose__c;
                }
                if (result.Specific_Need_For_the_Bilateral_Event__c != undefined || result.Specific_Need_For_the_Bilateral_Event__c != "") {
                    $scope.proposalDetails.Specific_Need_For_the_Bilateral_Event__c = result.Specific_Need_For_the_Bilateral_Event__c ? result.Specific_Need_For_the_Bilateral_Event__c.replace(/&amp;/g, '&').replaceAll('&amp;amp;', '&').replaceAll('&amp;gt;', '>').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&') : result.Specific_Need_For_the_Bilateral_Event__c;
                }
                $scope.$apply();
            }
        },
            { escape: true }
        )
    }

    $scope.getProposalDetails();

    $scope.saveProposalDetails = function (saveType) {
        if (saveType == 'partial') {
            debugger;
            // ApplicantPortal_Contoller.insertProjectDetails($scope.proposalDetails, function (result, event) {
            WorkshopController2.insertProjectDetails($scope.proposalDetails, function (result, event) {
                if (event.status) {
                    debugger;
                    swal(
                        'Success',
                        'Your Proposal Details have been partially saved.',
                        'success'
                    );
                    //$scope.proposalDetails = result;
                    $scope.$apply();
                }
            },
                { escape: true }
            )
        } else {
            debugger;
            if ($scope.proposalDetails.Background_Concept_Purpose__c == undefined || $scope.proposalDetails.Background_Concept_Purpose__c == "") {
                swal("Proposal Details", "Please enter Background, concept and Purpose of Proposal.");
                return;
            }
            if ($scope.proposalDetails.Specific_Need_For_the_Bilateral_Event__c == undefined || $scope.proposalDetails.Specific_Need_For_the_Bilateral_Event__c == "") {
                swal("Proposal Details", "Please enter Specific need for the bilateral event of Proposal.");
                return;
            }
            if ($scope.proposalDetails.Background_Concept_Purpose__c != undefined || $scope.proposalDetails.Background_Concept_Purpose__c != "") {
                if ($scope.objRtf[0].charCount > 4500) {
                    swal("Info", "Background, concept and purpose maxlength will be 4500 characters only.", "info");
                    return;
                }
            }
            if ($scope.proposalDetails.Specific_Need_For_the_Bilateral_Event__c != undefined || $scope.proposalDetails.Specific_Need_For_the_Bilateral_Event__c != "") {
                if ($scope.objRtf[1].charCount > 3000) {
                    swal("Info", "Specific need for the bilateral event, its relevance and mutual benefits maxlength will be 3000 characters only.", "info");
                    return;
                }
            }

            // ApplicantPortal_Contoller.insertProjectDetails($scope.proposalDetails, function (result, event) {
            WorkshopController2.insertProjectDetails($scope.proposalDetails, function (result, event) {
                if (event.status) {
                    debugger;
                    swal(
                        'Success',
                        'Your Proposal Details have been saved successfully.',
                        'success'
                    );
                    $scope.redirectPageURL('Participants');
                    $scope.proposalDetails = result;
                    $scope.$apply();
                }
            },
                { escape: true }
            )
        }
    }

    $scope.redirectPageURL = function (pageName) {
        debugger;
        var link = document.createElement("a");
        link.id = 'someLink'; //give it an ID!
        link.href = "#/" + pageName;
        link.click();
    }
})
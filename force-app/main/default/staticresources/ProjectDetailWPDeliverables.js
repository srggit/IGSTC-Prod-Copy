// =====================================================================================
// ==================== NEW WORK PACKAGE + DELIVERABLES COMBINED TABLE ==================
// =====================================================================================

// This code should be added to ProjectDetail.js controller

// TRL dropdown options
$scope.trlOptions = [3, 4, 5, 6, 7, 8, 9];
$scope.wpDeliverablesTableList = [];

// Auto-generate WP and Deliverable sequence labels
$scope.regenerateWPSequences = function () {
    for (var i = 0; i < $scope.wpDeliverablesTableList.length; i++) {
        var wp = $scope.wpDeliverablesTableList[i];
        wp.wpSequence = 'WP' + (i + 1);
        
        if (wp.deliverables && wp.deliverables.length > 0) {
            for (var j = 0; j < wp.deliverables.length; j++) {
                wp.deliverables[j].deliverableSequence = 'D' + (i + 1) + '.' + (j + 1);
            }
        }
    }
};

// Add new Work Package row
$scope.addNewWP = function () {
    var wpIndex = $scope.wpDeliverablesTableList.length + 1;
    var newWP = {
        Id: '',
        wpSequence: 'WP' + wpIndex,
        title: '',
        trlFrom: null,
        trlTo: null,
        responsiblePartners: [],
        AccountList: JSON.parse(JSON.stringify($scope.defaultAccountList)),
        wpStartMonth: null,
        wpEndMonth: null,
        deliverables: [],
        externalId: new Date().getTime() + '_' + wpIndex
    };
    $scope.wpDeliverablesTableList.push(newWP);
};

// Add new Deliverable under a specific Work Package
$scope.addNewDeliverable = function (wpIndex) {
    var wp = $scope.wpDeliverablesTableList[wpIndex];
    var delivIndex = wp.deliverables.length + 1;
    var newDeliverable = {
        Id: '',
        deliverableSequence: 'D' + (wpIndex + 1) + '.' + delivIndex,
        title: '',
        startMonth: null,
        endMonth: null,
        externalId: new Date().getTime() + '_' + wpIndex + '_' + delivIndex
    };
    wp.deliverables.push(newDeliverable);
    $scope.regenerateWPSequences();
};

// Remove Work Package
$scope.removeWP = function (wpIndex) {
    if ($scope.wpDeliverablesTableList.length === 1) {
        swal("Info", "At least one Work Package is required.", "info");
        return;
    }
    
    var wp = $scope.wpDeliverablesTableList[wpIndex];
    if (wp.Id && wp.Id !== '') {
        swal({
            title: "Are you sure?",
            text: "This will delete the Work Package and all its deliverables!",
            icon: "warning",
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                ApplicantPortal_Contoller.deleteWorkPackageWithDeliverables(wp.Id, function (result, event) {
                    if (event.status && result === 'Success') {
                        $scope.wpDeliverablesTableList.splice(wpIndex, 1);
                        $scope.regenerateWPSequences();
                        swal("Success", "Work Package deleted successfully", "success");
                        $scope.$applyAsync();
                    } else {
                        swal("Error", "Failed to delete Work Package", "error");
                    }
                });
            }
        });
    } else {
        $scope.wpDeliverablesTableList.splice(wpIndex, 1);
        $scope.regenerateWPSequences();
    }
};

// Remove Deliverable
$scope.removeDeliverable = function (wpIndex, delivIndex) {
    var wp = $scope.wpDeliverablesTableList[wpIndex];
    var deliverable = wp.deliverables[delivIndex];
    
    if (deliverable.Id && deliverable.Id !== '') {
        swal({
            title: "Are you sure?",
            text: "This will delete the deliverable!",
            icon: "warning",
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                ApplicantPortal_Contoller.deleteDeliverableNew(deliverable.Id, function (result, event) {
                    if (event.status && result === 'Success') {
                        wp.deliverables.splice(delivIndex, 1);
                        $scope.regenerateWPSequences();
                        swal("Success", "Deliverable deleted successfully", "success");
                        $scope.$applyAsync();
                    } else {
                        swal("Error", "Failed to delete deliverable", "error");
                    }
                });
            }
        });
    } else {
        wp.deliverables.splice(delivIndex, 1);
        $scope.regenerateWPSequences();
    }
};

// Validate deliverable months against WP months
$scope.validateDeliverableMonths = function (wp, deliverable) {
    deliverable.startMonthError = false;
    deliverable.endMonthError = false;
    
    if (wp.wpStartMonth && deliverable.startMonth) {
        if (parseInt(deliverable.startMonth) < parseInt(wp.wpStartMonth)) {
            deliverable.startMonthError = true;
        }
    }
    
    if (wp.wpEndMonth && deliverable.endMonth) {
        if (parseInt(deliverable.endMonth) > parseInt(wp.wpEndMonth)) {
            deliverable.endMonthError = true;
        }
    }
};

// Load existing WP + Deliverables data
$scope.loadWPDeliverablesData = function () {
    ApplicantPortal_Contoller.getWPWithDeliverables($rootScope.proposalId, $rootScope.stage, function (result, event) {
        if (event.status && result) {
            console.log('WP with Deliverables data:', result);
            $scope.wpDeliverablesTableList = [];
            
            for (var i = 0; i < result.length; i++) {
                var wpData = result[i];
                const accountIdXselectedAcc = new Map();
                var accDetails = [];
                
                if (wpData.Account_Mapping__r != undefined) {
                    for (var j = 0; j < wpData.Account_Mapping__r.length; j++) {
                        accountIdXselectedAcc.set(wpData.Account_Mapping__r[j].Account__c, wpData.Account_Mapping__r[j]);
                    }
                    for (const accountId of accountIdXaccount.keys()) {
                        if (accountIdXselectedAcc.has(accountId)) {
                            var option = {
                                'Id': accountIdXaccount.get(accountId).Id,
                                'Name': accountIdXaccount.get(accountId).Name,
                                'selected': true,
                                'accountMappingId': accountIdXselectedAcc.get(accountId).Id
                            };
                        } else {
                            var option = {
                                'Id': accountIdXaccount.get(accountId).Id,
                                'Name': accountIdXaccount.get(accountId).Name,
                                'selected': false
                            };
                        }
                        accDetails.push(option);
                    }
                } else {
                    accDetails = JSON.parse(JSON.stringify($scope.defaultAccountList));
                }
                
                var deliverablesList = [];
                if (wpData.Deliverables__r && wpData.Deliverables__r.length > 0) {
                    for (var k = 0; k < wpData.Deliverables__r.length; k++) {
                        var deliv = wpData.Deliverables__r[k];
                        deliverablesList.push({
                            Id: deliv.Id,
                            deliverableSequence: deliv.Deliverable_Sequence__c || '',
                            title: deliv.Title__c || '',
                            startMonth: deliv.Duration_Start_Month__c || null,
                            endMonth: deliv.Duration_End_Month__c || null,
                            externalId: deliv.External_Id__c || (new Date().getTime() + '_' + i + '_' + k),
                            startMonthError: false,
                            endMonthError: false
                        });
                    }
                }
                
                $scope.wpDeliverablesTableList.push({
                    Id: wpData.Id,
                    wpSequence: wpData.WP_Sequence__c || '',
                    title: wpData.Title__c || '',
                    trlFrom: wpData.TRL_Level__c || null,
                    trlTo: wpData.End_TRL_Level__c || null,
                    AccountList: accDetails,
                    wpStartMonth: wpData.Duration_Start_Month__c || null,
                    wpEndMonth: wpData.Duration_End_Month__c || null,
                    deliverables: deliverablesList,
                    externalId: wpData.External_Id__c || (new Date().getTime() + '_' + i)
                });
            }
            
            if ($scope.wpDeliverablesTableList.length === 0) {
                $scope.addNewWP();
            }
            
            $scope.$applyAsync();
        }
    }, { escape: true });
};

// Save WP + Deliverables data
$scope.saveWPDeliverablesData = function () {
    var objData = JSON.parse(JSON.stringify($scope.wpDeliverablesTableList));
    
    // Validation
    for (var i = 0; i < objData.length; i++) {
        var wp = objData[i];
        
        // Check if at least one partner is selected
        var count = 0;
        if (wp.AccountList) {
            for (var k = 0; k < wp.AccountList.length; k++) {
                if (wp.AccountList[k].selected == true) {
                    count = count + 1;
                }
            }
        }
        if (count <= 0) {
            swal("Work Package Details", "Please select at least one partner for " + wp.wpSequence, "info");
            return;
        }
        
        // Validate WP fields
        if (!wp.title || wp.title === "") {
            swal("Work Package Details", "Please enter title for " + wp.wpSequence, "info");
            return;
        }
        
        if (!wp.trlFrom || wp.trlFrom === "") {
            swal("Work Package Details", "Please select TRL From for " + wp.wpSequence, "info");
            return;
        }
        
        if (!wp.trlTo || wp.trlTo === "") {
            swal("Work Package Details", "Please select TRL To for " + wp.wpSequence, "info");
            return;
        }
        
        if (parseInt(wp.trlTo) < parseInt(wp.trlFrom)) {
            swal("Work Package Details", "TRL To must be greater than or equal to TRL From for " + wp.wpSequence, "info");
            return;
        }
        
        if (!wp.wpStartMonth || wp.wpStartMonth === "") {
            swal("Work Package Details", "Please enter WP Start Month for " + wp.wpSequence, "info");
            return;
        }
        
        if (!wp.wpEndMonth || wp.wpEndMonth === "") {
            swal("Work Package Details", "Please enter WP End Month for " + wp.wpSequence, "info");
            return;
        }
        
        if (parseInt(wp.wpEndMonth) < parseInt(wp.wpStartMonth)) {
            swal("Work Package Details", "WP End Month must be greater than or equal to WP Start Month for " + wp.wpSequence, "info");
            return;
        }
        
        // Validate deliverables
        if (wp.deliverables && wp.deliverables.length > 0) {
            for (var j = 0; j < wp.deliverables.length; j++) {
                var deliv = wp.deliverables[j];
                
                if (!deliv.title || deliv.title === "") {
                    swal("Deliverable Details", "Please enter title for " + deliv.deliverableSequence, "info");
                    return;
                }
                
                if (!deliv.startMonth || deliv.startMonth === "") {
                    swal("Deliverable Details", "Please enter Start Month for " + deliv.deliverableSequence, "info");
                    return;
                }
                
                if (!deliv.endMonth || deliv.endMonth === "") {
                    swal("Deliverable Details", "Please enter End Month for " + deliv.deliverableSequence, "info");
                    return;
                }
                
                // Validation: Deliverable Start >= WP Start
                if (parseInt(deliv.startMonth) < parseInt(wp.wpStartMonth)) {
                    swal("Validation Error", "Deliverable Start Month must be >= WP Start Month for " + deliv.deliverableSequence, "error");
                    return;
                }
                
                // Validation: Deliverable End <= WP End
                if (parseInt(deliv.endMonth) > parseInt(wp.wpEndMonth)) {
                    swal("Validation Error", "Deliverable End Month must be <= WP End Month for " + deliv.deliverableSequence, "error");
                    return;
                }
                
                if (parseInt(deliv.endMonth) < parseInt(deliv.startMonth)) {
                    swal("Deliverable Details", "End Month must be >= Start Month for " + deliv.deliverableSequence, "info");
                    return;
                }
            }
        }
    }
    
    // Prepare data for backend
    var dataToSend = [];
    for (var i = 0; i < objData.length; i++) {
        var wp = objData[i];
        
        // Prepare account wrapper list
        var accountWrapperList = [];
        if (wp.AccountList) {
            for (var k = 0; k < wp.AccountList.length; k++) {
                var acc = wp.AccountList[k];
                var wrapper = {
                    accnt: { Id: acc.Id, Name: acc.Name },
                    isSelected: acc.selected === true
                };
                if (acc.accountMappingId !== undefined && acc.accountMappingId !== null) {
                    wrapper.accountMappingId = acc.accountMappingId;
                }
                accountWrapperList.push(wrapper);
            }
        }
        
        // Prepare deliverables list
        var deliverablesList = [];
        if (wp.deliverables && wp.deliverables.length > 0) {
            for (var j = 0; j < wp.deliverables.length; j++) {
                var deliv = wp.deliverables[j];
                deliverablesList.push({
                    Id: deliv.Id || '',
                    deliverableSequence: deliv.deliverableSequence,
                    title: deliv.title,
                    startMonth: String(deliv.startMonth),
                    endMonth: String(deliv.endMonth),
                    externalId: deliv.externalId
                });
            }
        }
        
        dataToSend.push({
            Id: wp.Id || '',
            wpSequence: wp.wpSequence,
            title: wp.title,
            trlFrom: String(wp.trlFrom),
            trlTo: String(wp.trlTo),
            wpStartMonth: String(wp.wpStartMonth),
            wpEndMonth: String(wp.wpEndMonth),
            externalId: wp.externalId,
            AccountListWrapper: accountWrapperList,
            deliverables: deliverablesList
        });
    }
    
    console.log('Saving WP + Deliverables data:', dataToSend);
    
    ApplicantPortal_Contoller.saveWPWithDeliverables(dataToSend, $rootScope.proposalId, $rootScope.stage, function (result, event) {
        if (event.status) {
            if (result === 'success') {
                Swal.fire('Success', 'Work Packages and Deliverables saved successfully!', 'success');
                $scope.loadWPDeliverablesData();
            } else {
                swal("Error", "Failed to save: " + result, "error");
            }
            $scope.$applyAsync();
        } else {
            console.error('Error saving WP + Deliverables:', event.message);
            swal("Error", "Failed to save. Please try again.", "error");
        }
    });
};

// Initialize - load data when accounts are ready
// Call this after $scope.getProposalAccounts() completes
// $scope.loadWPDeliverablesData();

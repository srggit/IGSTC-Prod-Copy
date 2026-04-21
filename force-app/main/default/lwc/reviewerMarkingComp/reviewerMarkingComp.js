import { LightningElement, wire, track } from 'lwc';
import getReviewerMarkingData from '@salesforce/apex/ReviewerMappingController.getReviewerMarkingData';
import getCampaignName from '@salesforce/apex/ReviewerMappingController.getCampaignName';
import getStageOptions from '@salesforce/apex/ReviewerMappingController.getStageOptions';
import getCallYearOptions from '@salesforce/apex/ReviewerMappingController.getCallYearOptions';

export default class ReviewerMarkingComp extends LightningElement {
    proposalIds = [];
    reviewerNames = [];
    gridRows = [];
    error = undefined;
    selectedName = '';
    campaignNameOptions = [];
    @track selectedCampaignName = '';
    callYearOptions = [];
    selectedCallYear = '';

    // Call the getCallYearOptions method from the Apex controller and store in callYearOptions
    @wire(getCallYearOptions)
    wiredCallYears({ error, data }) {
        if (data) {
            this.error = undefined;
            this.callYearOptions = [
                { label: 'All Call Years', value: '' },
                ...data.map((year) => ({
                    label: year.Name,
                    value: year.Name
                }))
            ];
        } else if (error) {
            this.error = error;
        }
    }

    // Proposal stage filter properties
    stage = '';
    stageOptions = [];

    @wire(getCampaignName)
    wiredCampaigns({ error, data }) {
        if (data) {
            this.error = undefined;
            // First add all values from Apex
            this.campaignNameOptions = data.map((camp) => ({
                label: camp.Name,
                value: camp.Id
            }));

            // Then remove 'Connect Plus'
            this.campaignNameOptions = this.campaignNameOptions.filter(option => option.label !== 'Connect Plus');

            // Sort by label to maintain ASC order
            this.campaignNameOptions.sort((a, b) => a.label.localeCompare(b.label));

        } else if (error) {
            this.error = error;
        }
    }

    handleChangeName(event) {
        this.selectedName = event.target.value;
        this.stage = '';
        this.selectedCallYear = '';

        const selectedCampaign = this.campaignNameOptions.find(
            (cmp) => cmp.value === this.selectedName
        );

        this.selectedCampaignName = selectedCampaign ? selectedCampaign.label : null;

        this.loadReviewerMappingData();
    }

    handleCallYearChange(event) {
        debugger;
        this.selectedCallYear = event.target.value;
        console.log('handleCallYearChange called with value:', this.selectedCallYear);
        this.stage = '';

        this.loadReviewerMappingData();
    }

    @wire(getStageOptions)
    wiredStages({ error, data }) {
        if (data) {
            // Add "All Stages" option at the beginning
            this.stageOptions = [
                { label: 'All Stages', value: '' },
                ...data.map(stage => ({
                    label: stage,
                    value: stage
                }))
            ];
        } else if (error) {
            // Don't set this.error for stage options error, just log it
            this.stageOptions = [{ label: 'All Stages', value: '' }];
        }
    }

    handleStageChange(event) {
        this.stage = event.target.value;
        this.loadReviewerMappingData();
    }

    // Flag to control when data should be loaded
    shouldLoadData = false;

    // Computed property to determine if grid should be displayed
    get showGrid() {
        return this.selectedCampaignName && this.proposalIds.length > 0;
    }

    // Computed property to determine if stage filter should be shown
    get showStageFilter() {
        return this.selectedCampaignName === '2+2 Call';
    }

    // Imperative method to load reviewer mapping data
    async loadReviewerMappingData() {
        console.log('loadReviewerMappingData called');
        debugger;
        console.log('this.selectedCallYear : ', this.selectedCallYear);

        if (!this.selectedName) {
            // Clear data if no campaign selected
            this.proposalIds = [];
            this.reviewerNames = [];
            this.gridRows = [];
            this.error = undefined;
            return;
        }

        try {
            const data = await getReviewerMarkingData({
                campaignId: this.selectedName,
                proposalStage: this.stage,
                proposalCallYear: this.selectedCallYear
            });

            this.proposalIds = data.proposalIds;
            this.reviewerNames = data.reviewerNames;
            this.gridRows = this.processGridData(data.gridRows, data.reviewerNames);
            this.error = undefined;
        } catch (error) {
            // Create a more user-friendly error message
            let errorMessage = 'Error loading reviewer assignment data.';
            if (error.body?.message) {
                errorMessage += ' Details: ' + error.body.message;
            } else if (error.message) {
                errorMessage += ' Details: ' + error.message;
            }

            this.error = { message: errorMessage };
            this.proposalIds = [];
            this.reviewerNames = [];
            this.gridRows = [];
        }
    }

    processGridData(gridRows, reviewerNames) {
        return gridRows.map(row => {
            const processedRow = {
                proposalId: row.proposalId,
                proposalName: row.proposalName,
                assignments: []
            };

            // Create assignment objects for each reviewer
            reviewerNames.forEach(reviewerName => {
                processedRow.assignments.push({
                    reviewerName: reviewerName,
                    isAssigned: row[reviewerName] === '1'
                });
            });

            return processedRow;
        });
    }
}
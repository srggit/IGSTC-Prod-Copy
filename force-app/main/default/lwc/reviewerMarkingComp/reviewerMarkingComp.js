import { LightningElement, wire, track } from 'lwc';
import getReviewerMappingData from '@salesforce/apex/ReviewerMappingController.getReviewerMarkingData';
import getCampaignName from '@salesforce/apex/ReviewerMappingController.getCampaignName';
import getStageOptions from '@salesforce/apex/ReviewerMappingController.getStageOptions';




export default class ReviewerMarkingComp extends LightningElement {
    proposalIds = [];
    reviewerNames = [];
    gridRows = [];
    error = undefined;
    selectedName = '';
    campaignNameOptions = [];
    @track selectedCampaignName = '';

    // Proposal stage filter properties
    stage = '';
    stageOptions = [];

    @wire(getCampaignName)
    wiredCampaigns({ error, data }) {
        console.log('wiredCampaigns - data:', data);
        console.log('wiredCampaigns - error:', error);
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

            console.log('campaignNameOptions:', this.campaignNameOptions);
        } else if (error) {
            console.error('Error in getCampaignName:', error);
            this.error = error;
        }
    }

    handleChangeName(event) {
        debugger;
        this.selectedName = event.target.value;
        console.log('this.stage ----> ', this.stage);
        this.stage = '';

        const selectedCampaign = this.campaignNameOptions.find(
            (cmp) => cmp.value === this.selectedName
        );

        this.selectedCampaignName = selectedCampaign ? selectedCampaign.label : null;

        this.loadReviewerMappingData();
    }

    @wire(getStageOptions)
    wiredStages({ error, data }) {
        console.log('wiredStages - data:', data);
        console.log('wiredStages - error:', error);
        if (data) {
            // Add "All Stages" option at the beginning
            this.stageOptions = [
                { label: 'All Stages', value: '' },
                ...data.map(stage => ({
                    label: stage,
                    value: stage
                }))
            ];
            console.log('stageOptions:', this.stageOptions);
        } else if (error) {
            console.error('Error in getStageOptions:', error);
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
        console.log('selectedCampaignName:', this.selectedCampaignName);
        console.log('stage:', this.stage);

        if (!this.selectedCampaignName) {
            // Clear data if no campaign selected
            this.proposalIds = [];
            this.reviewerNames = [];
            this.gridRows = [];
            this.error = undefined;
            console.log('No campaign selected, returning');
            return;
        }

        try {
            console.log('Calling getReviewerMappingData with:', {
                campaignName: this.selectedCampaignName,
                proposalStage: this.stage
            });

            const data = await getReviewerMappingData({
                campaignName: this.selectedCampaignName,
                proposalStage: this.stage
            });

            console.log('getReviewerMappingData returned:', data);

            this.proposalIds = data.proposalIds;
            this.reviewerNames = data.reviewerNames;
            this.gridRows = this.processGridData(data.gridRows, data.reviewerNames);
            this.error = undefined;
            console.log('Data loaded successfully');
        } catch (error) {
            console.error('Error in loadReviewerMappingData:', error);
            console.error('Error body:', error.body);
            console.error('Error message:', error.body?.message || error.message);

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
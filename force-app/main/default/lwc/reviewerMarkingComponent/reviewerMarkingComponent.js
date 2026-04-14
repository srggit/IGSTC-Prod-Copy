import { LightningElement, wire } from 'lwc';
import getReviewerMappingData from '@salesforce/apex/ReviewerMappingController.getReviewerMappingData';

export default class ReviewerMarkingComponent extends LightningElement {
    proposalIds = [];
    reviewerNames = [];
    gridRows = [];
    error = undefined;

    @wire(getReviewerMappingData)
    wiredReviewerMappingData({ error, data }) {
        if (data) {
            this.proposalIds = data.proposalIds;
            this.reviewerNames = data.reviewerNames;
            // Process grid data to create direct properties for template access
            this.gridRows = this.processGridData(data.gridRows, data.reviewerNames);
            this.error = undefined;
        } else if (error) {
            this.error = error;
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
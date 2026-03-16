import { LightningElement, api, wire, track } from 'lwc';
import getMatchingReviewers from '@salesforce/apex/ProposalReviewerController.getMatchingReviewers';
import createReviewerMapping from '@salesforce/apex/ProposalReviewerController.createReviewerMapping';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';

export default class ProposalReviewerMatcher extends LightningElement {

    @api recordId;
    @track reviewers = [];
    //@track selectedReviewerId;
    @track selectedReviewerIds = [];

    @track isLoading = true;
    @track isAssigning = false;

    columns = [
        { label: 'Reviewer Name', fieldName: 'reviewerName' },
        { label: 'Reviewer Email', fieldName: 'reviewerEmail' },
        { label: 'Matched Skill', fieldName: 'matchedSkill' }
    ];

    @wire(getMatchingReviewers, { proposalId: '$recordId' })
    wiredReviewers({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.reviewers = data;
        }
        else if (error) {
            this.showToast('Error', 'Error loading reviewers', 'error');
        }
    }

    // handleRowSelection(event) {
    //     const selectedRows = event.detail.selectedRows;
    //     if (selectedRows.length > 0) {
    //         this.selectedReviewerId = selectedRows[0].reviewerId;
    //     }
    // }
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedReviewerIds = selectedRows.map(row => row.reviewerId);
    }

    // get disableAssign() {
    //     return !this.selectedReviewerId || this.isAssigning;
    // }
    get disableAssign() {
        return this.selectedReviewerIds.length === 0 || this.isAssigning;
    }
    handleAssign() {
        this.isAssigning = true;
        // createReviewerMapping({
        //     proposalId: this.recordId,
        //     reviewerId: this.selectedReviewerId
        // })
        createReviewerMapping({
            proposalId: this.recordId,
            reviewerIds: this.selectedReviewerIds
        })
        .then(() => {
            this.showToast(
                'Success',
                'Reviewer Assigned Successfully',
                'success'
            );
            // Refresh Proposal record page
            this.dispatchEvent(new RefreshEvent());
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            this.isAssigning = false;
            this.showToast(
                'Error',
                error.body.message,
                'error'
            );
        });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }    
}
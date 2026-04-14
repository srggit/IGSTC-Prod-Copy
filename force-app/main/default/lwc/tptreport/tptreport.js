import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReviewerMappingData from '@salesforce/apex/ReviewerMappingController.getReviewerMappingData';
import getProposalStageFilterOptions from '@salesforce/apex/ReviewerMappingController.getProposalStageFilterOptions';
import getCallTypeFilterOptions from '@salesforce/apex/ReviewerMappingController.getCallTypeFilterOptions';

export default class Tptreport extends LightningElement {
    @track reviewers = [];
    @track rows = [];

    stage = '';
    stageOptions = [{ label: 'All stages', value: '' }];
    callType = '';
    callTypeOptions = [{ label: 'All call types', value: '' }];

    pageNumber = 1;
    pageSize = 50;
    isLoading = false;
    loadError = false;

    @wire(getProposalStageFilterOptions)
    wiredStageOptions({ data, error }) {
        if (data && data.length) {
            this.stageOptions = data.map((o) => ({
                label: o.label,
                value: o.value == null ? '' : o.value
            }));
            console.log('this.stageOptions ===>  ', this.stageOptions);
        } else if (error) {
            this.stageOptions = [{ label: 'All stages', value: '' }];
        }
    }

    @wire(getCallTypeFilterOptions)
    wiredCallTypeOptions({ data, error }) {
        if (data && data.length) {
            this.callTypeOptions = data.map((o) => ({
                label: o.label,
                value: o.value == null ? '' : o.value
            }));
        } else if (error) {
            this.callTypeOptions = [{ label: 'All call types', value: '' }];
        }
    }

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        debugger;
        this.isLoading = true;
        this.loadError = false;
        getReviewerMappingData({
            stage: this.stage,
            campaignId: this.callType,
            pageSize: this.pageSize,
            pageNumber: this.pageNumber
        })
            .then((result) => {
                this.reviewers = result.reviewers || [];
                this.rows = (result.rows || []).map((row) => {
                    const reviewerList = [];
                    this.reviewers.forEach((rev) => {
                        const raw = row.reviewerScores && row.reviewerScores[rev] != null
                            ? row.reviewerScores[rev]
                            : null;
                        reviewerList.push({
                            key: row.proposalId + '-' + rev,
                            value: this.formatScore(raw)
                        });
                    });
                    return {
                        proposalId: row.proposalId,
                        proposalName: row.proposalName,
                        avgScore: this.formatScore(row.avgScore),
                        reviewerList
                    };
                });
            })
            .catch((error) => {
                this.loadError = true;
                this.reviewers = [];
                this.rows = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Could not load report',
                        message: this.reduceError(error),
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /** Rounds decimals for display (avoids long float tails from Apex Decimal). */
    formatScore(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }
        const n = Number(value);
        if (Number.isNaN(n)) {
            return '';
        }
        return n.toLocaleString(undefined, {
            minimumFractionDigits: 0,
            maximumFractionDigits: 2
        });
    }

    reduceError(error) {
        if (Array.isArray(error?.body)) {
            return error.body.map((e) => e.message).join(', ');
        }
        if (typeof error?.body?.message === 'string') {
            return error.body.message;
        }
        if (typeof error?.message === 'string') {
            return error.message;
        }
        return 'Unknown error';
    }

    get hasRows() {
        return this.rows && this.rows.length > 0;
    }

    get showEmptyState() {
        return !this.isLoading && !this.loadError && !this.hasRows;
    }

    get isPrevDisabled() {
        return this.isLoading || this.pageNumber <= 1;
    }

    get showProposalStage() {
        return this.callLabel === '2+2 Call';
    }

    handleStageChange(event) {
        debugger;
        this.stage = event.detail.value;
        this.pageNumber = 1;
        this.loadData();
    }

    // handleCallTypeChange(event) {
    //     this.callType = event.detail.value;
    //     this.callLabel = event;
    //     console.log('callType changed to: ', this.callType);
    //     console.log('callLabel detail: ', this.callLabel);
    //     this.stage = '';
    //     this.pageNumber = 1;
    //     this.loadData();
    // }
    handleCallTypeChange(event) {
        this.callType = event.detail.value;

        // Get selected label from options
        const selectedOption = this.callTypeOptions.find(
            option => option.value === this.callType
        );

        this.callLabel = selectedOption ? selectedOption.label : '';

        console.log('callType changed to: ', this.callType);
        console.log('Selected Label: ', this.callLabel);

        this.stage = '';
        this.pageNumber = 1;

        this.loadData();
    }

    nextPage() {
        this.pageNumber++;
        this.loadData();
    }

    prevPage() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.loadData();
        }
    }
}
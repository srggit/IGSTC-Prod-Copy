import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProposalData from '@salesforce/apex/WPDeliverableGanttController.getProposalData';

export default class WpDeliverableGanttChart extends LightningElement {
    @api recordId; // Proposal Record ID

    @track isLoading = false;
    @track errorMessage = '';
    @track showChart = false;
    @track maxDuration = 36;
    @track monthHeaders = [];
    @track ganttData = [];

    // Connected callback to initialize component
    connectedCallback() {
        this.loadProposalData();
    }

    // Load proposal data and build Gantt chart
    async loadProposalData() {
        this.isLoading = true;
        this.errorMessage = '';

        try {
            const result = await getProposalData({ proposalId: this.recordId });

            if (result && result.success) {
                this.maxDuration = result.maxDuration || 36;
                this.buildGanttData(result.workPackages, this.maxDuration);
            } else {
                this.errorMessage = result.error || 'Failed to load proposal data';
            }
        } catch (error) {
            this.errorMessage = 'Error loading proposal data: ' + error.body.message;
            console.error('Error loading proposal data:', error);
        } finally {
            this.isLoading = false;
        }
    }

    // Build Gantt chart data structure
    buildGanttData(workPackages, maxDuration) {
        // Generate month headers (1 to maxDuration)
        this.monthHeaders = [];
        for (let i = 1; i <= maxDuration; i++) {
            this.monthHeaders.push(i.toString());
        }

        // Process work packages and deliverables
        this.ganttData = workPackages.map(wp => {
            const wpData = {
                wpId: wp.Id,
                wpName: wp.Title__c || `WP ${wp.WP_Sequence__c}`,
                startMonth: wp.Duration_Start_Month__c || 1,
                endMonth: wp.Duration_End_Month__c || maxDuration,
                monthData: {},
                deliverables: []
            };

            // Build month data for work package
            wpData.months = [];
            for (let month = 1; month <= maxDuration; month++) {
                const monthData = {
                    month: month,
                    isActive: month >= wpData.startMonth && month <= wpData.endMonth
                };
                wpData.months.push(monthData);
            }

            // Process deliverables if they exist
            if (wp.Deliverables__r) {
                wpData.deliverables = wp.Deliverables__r.map((deliverable, index) => {
                    const deliverableData = {
                        deliverableId: deliverable.Id || `${wpData.wpId}-deliverable-${index}`,
                        name: deliverable.Title__c || deliverable.Deliverable_Sequence__c || `Deliverable ${index + 1}`,
                        startMonth: deliverable.Duration_Start_Month__c || wpData.startMonth,
                        endMonth: deliverable.Duration_End_Month__c || wpData.endMonth,
                        months: []
                    };

                    // Build month data for deliverable
                    for (let month = 1; month <= maxDuration; month++) {
                        const monthData = {
                            month: month,
                            isActive: month >= deliverableData.startMonth &&
                                month <= deliverableData.endMonth &&
                                month >= wpData.startMonth &&
                                month <= wpData.endMonth // Ensure deliverable is within WP duration
                        };
                        deliverableData.months.push(monthData);
                    }

                    return deliverableData;
                });
            }

            return wpData;
        });
    }

    // Show Gantt Chart
    showGanttChart() {
        if (this.ganttData.length === 0) {
            this.showToast('No Data', 'No work packages found for this proposal', 'warning');
            return;
        }
        this.showChart = true;
    }

    // Hide Gantt Chart
    hideGanttChart() {
        this.showChart = false;
    }

    // Show toast notification
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

    // Refresh data
    handleRefresh() {
        this.loadProposalData();
    }
}

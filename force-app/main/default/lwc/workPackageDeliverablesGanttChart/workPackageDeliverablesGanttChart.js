import { LightningElement, api, track } from 'lwc';
import getProposalData from '@salesforce/apex/WPDeliverableGanttController.getProposalData';

// const colors = [
//     '#ffad43ff',
//     '#ff8c00',
//     '#a855f7',
//     '#10b981',
//     '#50d492ff',
//     '#f59e0b',
//     '#06b6d4',
//     '#8b5cf6'
// ];

const colors = [
    '#ffad43ff',
    '#ff8c00',
    '#a855f7',
    '#0e7adfff',
    '#50d492ff',
    '#f59e0b',
    '#06a5d6ff',
    '#8b5cf6'
];
export default class WorkPackageDeliverablesGanttChart extends LightningElement {

    @api recordId;

    @track months = [];
    @track workPackages = [];
    @track maxDuration = 24;
    @track isLoading = true;
    @track showChart = false;

    columnWidth = 40;



    connectedCallback() {
        this.loadData();
    }

    async loadData() {

        try {

            const result = await getProposalData({ proposalId: this.recordId });

            if (result.success) {

                this.maxDuration = result.maxDuration || 24;

                this.months = Array.from(
                    { length: this.maxDuration },
                    (_, i) => i + 1
                );

                // Console.log contacts for each Work Package
                console.log('Contacts by Work Package:');
                this.workPackages = result.workPackages.map(wp => {

                    const wpStart = Number(wp.durationStartMonth) || 1;
                    const wpEnd = Number(wp.durationEndMonth) || this.maxDuration;

                    // Log contacts for this Work Package
                    console.log(`\nWork Package: ${wp.title}`);
                    if (wp.contacts && wp.contacts.length > 0) {
                        wp.contacts.forEach(contact => {
                            const fullName = `${contact.FirstName || ''} ${contact.LastName || ''}`.trim();
                            console.log(`  - ${fullName} (${contact.Email})`);
                        });
                    } else {
                        console.log('  - No contacts found');
                    }

                    const deliverables = (wp.deliverables || []).map(d => {
                        const dStart = Number(d.Duration_Start_Month__c) || wpStart;
                        const dEnd = Number(d.Duration_End_Month__c) || wpEnd;

                        // Fix: Use (dStart - 1) to match VF logic
                        const colorIndex = (dStart - 1) % colors.length;

                        return {
                            id: d.Id,
                            label: d.Deliverable_Sequence__c,
                            style: `grid-column:${dStart} / ${dEnd + 1}; background:${colors[colorIndex]};`
                        };
                    });

                    // Generate contact initials for badge
                    const contactInitials = [];
                    if (wp.contacts && wp.contacts.length > 0) {
                        wp.contacts.forEach(contact => {
                            const firstInitial = (contact.FirstName || '').charAt(0).toUpperCase();
                            const lastInitial = (contact.LastName || '').charAt(0).toUpperCase();
                            const initials = `${firstInitial}${lastInitial}`;
                            const fullName = `${contact.FirstName || ''} ${contact.LastName || ''}`.trim();

                            if (initials.length > 1) {
                                contactInitials.push({
                                    initials: initials,
                                    fullName: fullName
                                });
                            }
                        });
                    }

                    // Then in the return object:
                    return {
                        id: wp.Id,
                        title: wp.title,
                        titleStyle: `grid-column:${wpStart} / ${wpEnd + 1};`,
                        wpStyle: `grid-column:${wpStart} / ${wpEnd + 1};`,
                        deliverables,
                        contacts: wp.contacts || [],
                        contactInitials: contactInitials  // Now an array of objects
                    };

                });

            }

        } catch (e) {
            console.error(e);
        }

        this.isLoading = false;

    }

    // showGanttChart() {
    //     this.showChart = true;
    // }

    // hideGanttChart() {
    //     this.showChart = false;
    // }

    get gridStyle() {
        return `grid-template-columns: repeat(${this.maxDuration}, 1fr);`;
    }



}
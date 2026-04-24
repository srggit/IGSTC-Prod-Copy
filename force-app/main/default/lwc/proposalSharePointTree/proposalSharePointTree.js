import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHierarchy from '@salesforce/apex/ProposalSharePointTreeController.getHierarchy';
import getFolderContent from '@salesforce/apex/ProposalSharePointTreeController.getFolderContent';
import createFolder from '@salesforce/apex/ProposalSharePointTreeController.createFolder';
import createFile from '@salesforce/apex/ProposalSharePointTreeController.createFile';
import deleteFileSP from '@salesforce/apex/ProposalSharePointTreeController.deleteFileSP';
import deleteFolderInsideSite from '@salesforce/apex/ProposalSharePointTreeController.deleteFolderInsideSite';

const TREE_COLUMNS = [{ label: 'Hierarchy', fieldName: 'label', type: 'text' }];
const FILE_COLUMNS = [
    { label: 'File Name', fieldName: 'Name', type: 'text' },
    {
        type: 'button',
        fixedWidth: 90,
        typeAttributes: { label: 'Preview', name: 'preview', variant: 'base' }
    },
    {
        type: 'button',
        fixedWidth: 80,
        typeAttributes: { label: 'Delete', name: 'delete', variant: 'destructive-text' }
    }
];

export default class ProposalSharePointTree extends LightningElement {
    @api recordId;

    treeColumns = TREE_COLUMNS;
    fileColumns = FILE_COLUMNS;

    @track hierarchy = [];
    @track files = [];
    @track folders = [];

    @track selectedNode;
    @track folderName = '';
    @track selectedUploadFile;
    @track selectedUploadFileName = '';
    @track loading = false;

    connectedCallback() {
        this.loadHierarchy();
    }

    async loadHierarchy() {
        this.loading = true;
        try {
            const data = await getHierarchy({ proposalId: this.recordId });
            this.hierarchy = this.normalizeTree(data || []);
            this.files = [];
            this.folders = [];
            this.selectedNode = null;
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    async handleRowSelection(event) {
        const selectedNode = this.extractSelectedNode(event);
        if (!selectedNode) {
            this.selectedNode = null;
            this.files = [];
            this.folders = [];
            return;
        }

        this.selectedNode = selectedNode;
        await this.loadFolderContent();
    }

    handleTreeToggle(event) {
        const rowName = event?.detail?.name;
        if (!rowName) {
            return;
        }
        const node = this.findNodeByKey(this.hierarchy, rowName);
        if (!node) {
            return;
        }
        this.selectedNode = node;
        this.loadFolderContent();
    }

    async loadFolderContent() {
        if (!this.selectedNode?.folderPath) {
            this.files = [];
            this.folders = [];
            return;
        }

        this.loading = true;
        try {
            const data = await getFolderContent({ folderPath: this.selectedNode.folderPath });
            this.files = (data?.files || []).map((file) => ({ ...file }));
            this.folders = (data?.folders || []).map((folder) => ({ ...folder }));
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    handleFolderNameChange(event) {
        this.folderName = (event.target.value || '').trim();
    }

    handleFileSelected(event) {
        this.selectedUploadFile = event.target.files?.[0];
        this.selectedUploadFileName = this.selectedUploadFile?.name || '';
    }

    async handleCreateFolder() {
        if (!this.selectedNode?.folderPath) {
            this.notify('Error', 'Select a node first.', 'error');
            return;
        }
        if (!this.folderName) {
            this.notify('Error', 'Enter folder name.', 'error');
            return;
        }

        this.loading = true;
        try {
            const path = `${this.selectedNode.folderPath}/${this.folderName}`;
            await createFolder({ path });
            this.folderName = '';
            this.notify('Success', 'Folder created successfully.', 'success');
            await this.loadFolderContent();
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    async handleUploadFile() {
        if (!this.selectedNode?.folderPath) {
            this.notify('Error', 'Select a node first.', 'error');
            return;
        }
        if (!this.selectedUploadFile) {
            this.notify('Error', 'Choose a file to upload.', 'error');
            return;
        }

        this.loading = true;
        try {
            const base64 = await this.readFileAsBase64(this.selectedUploadFile);
            await createFile({
                base64,
                fileName: this.selectedUploadFile.name.replaceAll(' ', '_'),
                path: this.selectedNode.folderPath
            });
            this.notify('Success', 'File uploaded successfully.', 'success');
            this.selectedUploadFile = null;
            this.selectedUploadFileName = '';
            await this.loadFolderContent();
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    async handleDeleteFolder() {
        if (!this.selectedNode?.folderPath) {
            this.notify('Error', 'Select a node first.', 'error');
            return;
        }
        if (this.selectedNode.nodeType === 'proposal') {
            this.notify('Error', 'Root proposal folder cannot be deleted from here.', 'error');
            return;
        }

        this.loading = true;
        try {
            const result = await deleteFolderInsideSite({ path: this.selectedNode.folderPath });
            if (result === 'Success') {
                this.notify('Success', 'Folder deleted successfully.', 'success');
                await this.loadHierarchy();
            } else {
                this.notify('Error', 'Folder delete failed.', 'error');
            }
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    async handleFileRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'preview') {
            this.previewFile(row);
            return;
        }
        if (action !== 'delete') {
            return;
        }

        this.loading = true;
        try {
            const result = await deleteFileSP({ path: row.ServerRelativeUrl });
            if (result === 'Success') {
                this.notify('Success', 'File deleted successfully.', 'success');
                await this.loadFolderContent();
            } else {
                this.notify('Error', 'File delete failed.', 'error');
            }
        } catch (error) {
            this.notify('Error', this.errorText(error), 'error');
        } finally {
            this.loading = false;
        }
    }

    previewFile(fileRow) {
        if (fileRow.linkedUrl) {
            window.open(fileRow.linkedUrl, '_blank');
            return;
        }
        if (!fileRow.ServerRelativeUrl) {
            this.notify('Error', 'Preview link not available.', 'error');
            return;
        }

        const id = encodeURIComponent(fileRow.ServerRelativeUrl);
        const parent = encodeURIComponent(
            fileRow.ServerRelativeUrl.substring(0, fileRow.ServerRelativeUrl.lastIndexOf('/'))
        );
        window.open(
            `https://igstc.sharepoint.com/sites/SalesforceSharepoint/Shared%20Documents/Forms/AllItems.aspx?id=${id}&parent=${parent}`,
            '_blank'
        );
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.onerror = () => reject(new Error('File read failed.'));
            reader.readAsDataURL(file);
        });
    }

    notify(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    errorText(error) {
        return error?.body?.message || error?.message || 'Unexpected error';
    }

    normalizeTree(nodes) {
        return (nodes || []).map((node) => {
            const children = this.normalizeTree(node.children || []);
            return {
                ...node,
                _children: children
            };
        });
    }

    extractSelectedNode(event) {
        const detail = event?.detail || {};

        if (Array.isArray(detail.selectedRows) && detail.selectedRows.length > 0) {
            return detail.selectedRows[0];
        }

        // Handles payload like { name, isExpanded, row: { ...actualNode } }
        if (detail.row?.row) {
            return detail.row.row;
        }
        if (detail.row) {
            return detail.row;
        }

        return null;
    }

    findNodeByKey(nodes, key) {
        if (!nodes || !key) {
            return null;
        }
        for (const node of nodes) {
            if (node.key === key) {
                return node;
            }
            const childMatch = this.findNodeByKey(node._children || [], key);
            if (childMatch) {
                return childMatch;
            }
        }
        return null;
    }

    get hasSelection() {
        return !!this.selectedNode?.folderPath;
    }

    get disableDeleteFolder() {
        return !this.hasSelection || this.selectedNode?.nodeType === 'proposal';
    }

    get disableCreateFolder() {
        return !this.hasSelection || !this.folderName;
    }

    get disableUploadFile() {
        return !this.hasSelection || !this.selectedUploadFile;
    }

    get selectedNodeLabel() {
        return this.selectedNode?.label || 'No node selected';
    }

    get fileCountLabel() {
        return `${this.files?.length || 0} file(s)`;
    }

    get hierarchyFolderCountLabel() {
        return `${this.countNodes(this.hierarchy)} folders`;
    }

    get selectedPath() {
        return this.selectedNode?.folderPath || 'No node selected';
    }

    countNodes(nodes) {
        if (!Array.isArray(nodes) || nodes.length === 0) {
            return 0;
        }

        let count = 0;
        nodes.forEach((node) => {
            count += 1;
            count += this.countNodes(node?._children || []);
        });
        return count;
    }
}
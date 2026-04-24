trigger UserDocumentTrigger on User_Document__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        UserDocumentTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        UserDocumentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
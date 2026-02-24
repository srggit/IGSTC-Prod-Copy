public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        try {
            return [
                SELECT Id, Name, Type, Industry, Phone, Website, 
                       BillingCity, BillingState, BillingCountry,
                       CreatedDate, LastModifiedDate
                FROM Account 
                ORDER BY Name ASC
                LIMIT 1000
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getAccountCount() {
        try {
            return [SELECT COUNT() FROM Account];
        } catch (Exception e) {
            throw new AuraHandledException('Error counting accounts: ' + e.getMessage());
        }
    }
}
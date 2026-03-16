/**
 * Batch class to fix Is_Last_Year__c flags and populate Year1/Year2/Year3_Expense__c
 * for multiple proposals.
 * 
 * Usage:
 * Set<Id> proposalIds = new Set<Id>{'a0XXXXXXXXXXXX', 'a0YYYYYYYYYYYY'};
 * Database.executeBatch(new ProposalYearlyExpenseFixerBatch(proposalIds), 1);
 */
public class ProposalYearlyExpenseFixerBatch implements Database.Batchable<Id>, Database.AllowsCallouts {
    
    private Set<Id> proposalIds;
    
    public ProposalYearlyExpenseFixerBatch(Set<Id> proposalIds) {
        this.proposalIds = proposalIds != null ? proposalIds : new Set<Id>();
    }
    
    public Iterable<Id> start(Database.BatchableContext bc) {
        if (proposalIds.isEmpty()) {
            // If no proposal IDs provided, query all proposals that need processing
            // Flatten nested subquery: Get APA IDs first, then get Proposal IDs
            Set<Id> apaIds = new Set<Id>();
            for (Yearly_Expense__c ye : [
                SELECT Applicant_Proposal_Association__c 
                FROM Yearly_Expense__c 
                WHERE Applicant_Proposal_Association__c != null
                LIMIT 10000
            ]) {
                apaIds.add(ye.Applicant_Proposal_Association__c);
            }
            
            Set<Id> allProposalIds = new Set<Id>();
            if (!apaIds.isEmpty()) {
                for (Applicant_Proposal_Association__c apa : [
                    SELECT Proposals__c 
                    FROM Applicant_Proposal_Association__c 
                    WHERE Id IN :apaIds AND Proposals__c != null
                    LIMIT 10000
                ]) {
                    allProposalIds.add(apa.Proposals__c);
                }
            }
            return allProposalIds;
        }
        return proposalIds;
    }
    
    public void execute(Database.BatchableContext bc, List<Id> scope) {
        for (Id proposalId : scope) {
            try {
                processProposal(proposalId);
            } catch (Exception e) {
                System.debug('Error processing proposal ' + proposalId + ': ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed');
    }
    
    /**
     * Process a single proposal - extracted from the original method
     */
    private void processProposal(Id proposalId) {
        // Get APAs for this proposal
        List<Applicant_Proposal_Association__c> apas = [
            SELECT Id, Proposals__c 
            FROM Applicant_Proposal_Association__c 
            WHERE Proposals__c = :proposalId
        ];
        
        if (apas.isEmpty()) {
            System.debug('No APAs found for proposal: ' + proposalId);
            return;
        }
        
        Set<Id> apaIds = new Set<Id>();
        for (Applicant_Proposal_Association__c apa : apas) {
            apaIds.add(apa.Id);
        }
        
        // Get all Yearly_Expense__c records
        List<Yearly_Expense__c> yearlyExpenses = [
            SELECT Id, Year__c, Is_Last_Year__c, Applicant_Proposal_Association__c 
            FROM Yearly_Expense__c 
            WHERE Applicant_Proposal_Association__c IN :apaIds
            ORDER BY Applicant_Proposal_Association__c, Year__c ASC
        ];
        
        if (yearlyExpenses.isEmpty()) {
            System.debug('No Yearly_Expense__c records found for APAs: ' + apaIds);
            return;
        }
        
        // Map to track last year yearly expense per APA
        Map<Id, Yearly_Expense__c> lastYearByApa = new Map<Id, Yearly_Expense__c>();
        List<Yearly_Expense__c> updates = new List<Yearly_Expense__c>();
        
        // Find max Year__c per APA
        for (Yearly_Expense__c ye : yearlyExpenses) {
            Id apaId = ye.Applicant_Proposal_Association__c;
            String yearStr = ye.Year__c != null ? ye.Year__c : '0';
            
            if (!lastYearByApa.containsKey(apaId)) {
                lastYearByApa.put(apaId, ye);
            } else {
                String existingYearStr = lastYearByApa.get(apaId).Year__c != null ? 
                                       lastYearByApa.get(apaId).Year__c : '0';
                Integer existingYear = Integer.valueOf(existingYearStr);
                Integer currentYear = Integer.valueOf(yearStr);
                
                if (currentYear > existingYear) {
                    lastYearByApa.put(apaId, ye);
                }
            }
        }
        
        // Set Is_Last_Year__c flags
        for (Yearly_Expense__c ye : yearlyExpenses) {
            Yearly_Expense__c lastYear = lastYearByApa.get(ye.Applicant_Proposal_Association__c);
            Boolean shouldBeLast = (lastYear != null && ye.Id == lastYear.Id);
            
            if (ye.Is_Last_Year__c != shouldBeLast) {
                ye.Is_Last_Year__c = shouldBeLast;
                updates.add(ye);
            }
        }
        
        // Update Yearly_Expense__c records if needed
        if (!updates.isEmpty()) {
            System.debug('=== UPDATING Yearly_Expense__c RECORDS ===');
            for (Yearly_Expense__c ye : updates) {
                System.debug('  Updating Yearly_Expense__c: Id=' + ye.Id + 
                           ' Year=' + ye.Year__c + 
                           ' Is_Last_Year__c=' + ye.Is_Last_Year__c + 
                           ' APA=' + ye.Applicant_Proposal_Association__c);
            }
            update updates;
            System.debug('✓ Successfully updated ' + updates.size() + ' Yearly_Expense__c records for proposal: ' + proposalId);
        } else {
            System.debug('No Yearly_Expense__c records to update');
        }
        
        // Get all Yearly Expense IDs
        Set<Id> yearlyExpenseIds = new Set<Id>();
        for (Yearly_Expense__c ye : yearlyExpenses) {
            yearlyExpenseIds.add(ye.Id);
        }
        
        // Get Expense Heads for all yearly expenses
        List<Expense_Head__c> expenseHeads = [
            SELECT Id, Name, Yearly_Expense__c, Yearly_Expense__r.Year__c, Yearly_Expense__r.Is_Last_Year__c,
                   Yearly_Expense__r.Applicant_Proposal_Association__c 
            FROM Expense_Head__c 
            WHERE Yearly_Expense__c IN :yearlyExpenseIds
        ];
        
        // Map to group expense heads by APA
        Map<Id, List<Expense_Head__c>> expenseHeadsByApa = new Map<Id, List<Expense_Head__c>>();
        
        // Organize expense heads by APA
        for (Expense_Head__c eh : expenseHeads) {
            if (eh.Yearly_Expense__r == null || eh.Yearly_Expense__r.Applicant_Proposal_Association__c == null) {
                continue;
            }
            
            Id apaId = eh.Yearly_Expense__r.Applicant_Proposal_Association__c;
            
            // Group by APA only
            if (!expenseHeadsByApa.containsKey(apaId)) {
                expenseHeadsByApa.put(apaId, new List<Expense_Head__c>());
            }
            expenseHeadsByApa.get(apaId).add(eh);
        }
        
        // Get all expense head IDs
        Set<Id> expenseHeadIds = new Set<Id>();
        for (Expense_Head__c eh : expenseHeads) {
            expenseHeadIds.add(eh.Id);
        }
        
        if (expenseHeadIds.isEmpty()) {
            System.debug('No Expense_Head__c records found for proposal: ' + proposalId);
            return;
        }
        
        // Get all line items (including those from previous years to populate Year1/Year2/Year3_Expense__c)
        List<Expense_Line_Item__c> lineItems = [
            SELECT Id, Name, Description__c, Position__c, Number__c, 
                   Person_Month__c, Salary_Month__c, Unit_Price__c, Multiplier__c,
                   Year1_Expense__c, Year2_Expense__c, Year3_Expense__c,
                   Year1_Approved_Amount__c, Year2_Approved_Amount__c, Year3_Approved_Amount__c,
                   Total_Expense__c, Index__c, Expense_Type__c, Expense_Head__c,
                   Time_Units__c, Expense_Description_2__c,
                   Expense_Head__r.Name, Expense_Head__r.Yearly_Expense__r.Year__c,
                   Expense_Head__r.Yearly_Expense__r.Is_Last_Year__c,
                   Expense_Head__r.Yearly_Expense__r.Applicant_Proposal_Association__c
            FROM Expense_Line_Item__c 
            WHERE Expense_Head__c IN :expenseHeadIds 
            ORDER BY Expense_Head__r.Yearly_Expense__r.Year__c ASC, Index__c ASC
        ];
        
        if (lineItems.isEmpty()) {
            System.debug('No Expense_Line_Item__c records found for proposal: ' + proposalId);
            return;
        }
        
        // Group line items by APA and Expense Head Name (more reliable than Expense_Type__c)
        Map<Id, Map<String, List<Expense_Line_Item__c>>> lineItemsByApaAndHeadName = new Map<Id, Map<String, List<Expense_Line_Item__c>>>();
        
        for (Expense_Line_Item__c li : lineItems) {
            if (li.Expense_Head__r == null || 
                li.Expense_Head__r.Yearly_Expense__r == null || 
                li.Expense_Head__r.Yearly_Expense__r.Applicant_Proposal_Association__c == null) {
                continue;
            }
            
            Id apaId = li.Expense_Head__r.Yearly_Expense__r.Applicant_Proposal_Association__c;
            // Use Expense_Head__r.Name instead of Expense_Type__c for more reliable matching
            String headName = li.Expense_Head__r.Name != null ? li.Expense_Head__r.Name : '';
            
            if (!lineItemsByApaAndHeadName.containsKey(apaId)) {
                lineItemsByApaAndHeadName.put(apaId, new Map<String, List<Expense_Line_Item__c>>());
            }
            if (!lineItemsByApaAndHeadName.get(apaId).containsKey(headName)) {
                lineItemsByApaAndHeadName.get(apaId).put(headName, new List<Expense_Line_Item__c>());
            }
            lineItemsByApaAndHeadName.get(apaId).get(headName).add(li);
        }
        
        List<Expense_Line_Item__c> lineItemsToUpdate = new List<Expense_Line_Item__c>();
        
        System.debug('=== Processing Proposal: ' + proposalId + ' ===');
        System.debug('Total line items: ' + lineItems.size());
        System.debug('Line items by APA and HeadName map size: ' + lineItemsByApaAndHeadName.size());
        for (Id apaId : lineItemsByApaAndHeadName.keySet()) {
            System.debug('  APA: ' + apaId + ' has ' + lineItemsByApaAndHeadName.get(apaId).size() + ' head names');
            for (String hn : lineItemsByApaAndHeadName.get(apaId).keySet()) {
                System.debug('    HeadName: ' + hn + ' has ' + lineItemsByApaAndHeadName.get(apaId).get(hn).size() + ' line items');
            }
        }
        
        // Process line items to populate yearly expense fields for last year records
        for (Expense_Line_Item__c li : lineItems) {
            // Only process line items in the last year yearly expense
            if (li.Expense_Head__r == null || 
                li.Expense_Head__r.Yearly_Expense__r == null || 
                !li.Expense_Head__r.Yearly_Expense__r.Is_Last_Year__c) {
                continue;
            }
            
            Id apaId = li.Expense_Head__r.Yearly_Expense__r.Applicant_Proposal_Association__c;
            String yearStr = li.Expense_Head__r.Yearly_Expense__r.Year__c != null ? 
                            li.Expense_Head__r.Yearly_Expense__r.Year__c : '0';
            Integer currentYear = Integer.valueOf(yearStr);
            // Use Expense_Head__r.Name instead of Expense_Type__c for matching
            String headName = li.Expense_Head__r != null && li.Expense_Head__r.Name != null ? li.Expense_Head__r.Name : '';
            
            // Get all expense heads for this APA with the SAME NAME (filter by current head name)
            List<Expense_Head__c> apaExpenseHeads = expenseHeadsByApa.get(apaId);
            
            if (apaExpenseHeads != null && !apaExpenseHeads.isEmpty()) {
                // Filter expense heads by the same name as current line item's head
                List<Expense_Head__c> filteredHeads = new List<Expense_Head__c>();
                for (Expense_Head__c eh : apaExpenseHeads) {
                    String ehName = eh.Name != null ? eh.Name : '';
                    if (ehName == headName) {
                        filteredHeads.add(eh);
                    }
                }
                
                if (filteredHeads.isEmpty()) {
                    System.debug('No expense heads found with name=' + headName + ' for APA=' + apaId);
                    continue;
                }
                
                // Sort expense heads by year
                List<Expense_Head__c> sortedHeads = new List<Expense_Head__c>();
                sortedHeads.addAll(filteredHeads);
                
                // Sort by year (ascending)
                for (Integer i = 0; i < sortedHeads.size() - 1; i++) {
                    for (Integer j = i + 1; j < sortedHeads.size(); j++) {
                        Expense_Head__c eh1 = sortedHeads[i];
                        Expense_Head__c eh2 = sortedHeads[j];
                        String year1Str = eh1.Yearly_Expense__r != null && eh1.Yearly_Expense__r.Year__c != null ? 
                                         eh1.Yearly_Expense__r.Year__c : '0';
                        String year2Str = eh2.Yearly_Expense__r != null && eh2.Yearly_Expense__r.Year__c != null ? 
                                         eh2.Yearly_Expense__r.Year__c : '0';
                        Integer year1 = Integer.valueOf(year1Str);
                        Integer year2 = Integer.valueOf(year2Str);
                        
                        if (year1 > year2) {
                            Expense_Head__c temp = sortedHeads[i];
                            sortedHeads[i] = sortedHeads[j];
                            sortedHeads[j] = temp;
                        }
                    }
                } 
                
                // Find current head index
                Integer currentIndex = -1;
                for (Integer i = 0; i < sortedHeads.size(); i++) {
                    if (sortedHeads[i].Id == li.Expense_Head__c) {
                        currentIndex = i;
                        break;
                    }
                }
                
                // Debug: Log sorting info for Year 2 records
                if (currentYear == 2 && currentIndex >= 0) {
                    System.debug('Year 2 processing - APA=' + apaId + ' HeadName=' + headName + 
                               ' CurrentIndex=' + currentIndex + ' SortedHeadsSize=' + sortedHeads.size());
                    for (Integer i = 0; i < sortedHeads.size(); i++) {
                        String yStr = sortedHeads[i].Yearly_Expense__r != null && sortedHeads[i].Yearly_Expense__r.Year__c != null ? 
                                     sortedHeads[i].Yearly_Expense__r.Year__c : 'null';
                        System.debug('  Head[' + i + '] Year=' + yStr + ' HeadId=' + sortedHeads[i].Id);
                    }
                }
                
                if (currentIndex >= 0) {
                    Boolean hasChanges = false;
                    
                    // Populate previous year values from matching line items
                    // For Year 2 (Is_Last_Year__c=true): Populate Year1_Expense__c from Year 1
                    // For Year 3 (Is_Last_Year__c=true): Populate Year1_Expense__c and Year2_Expense__c from previous years
                    if (currentIndex >= 1) {
                        Expense_Head__c year1Head = sortedHeads[currentIndex - 1];
                        String year1YearStr = year1Head.Yearly_Expense__r != null && year1Head.Yearly_Expense__r.Year__c != null ? 
                                            year1Head.Yearly_Expense__r.Year__c : '0';
                        Integer year1Year = Integer.valueOf(year1YearStr);
                        
                        // Only populate Year1_Expense__c if year1Head is actually Year 1
                        if (year1Year == 1) {
                            // Get Year 1 head name (should match current head name, but get it explicitly)
                            String year1HeadName = year1Head.Name != null ? year1Head.Name : '';
                            
                            Decimal year1Amount = findMatchingLineItemAmount(
                                lineItemsByApaAndHeadName, apaId, year1HeadName, year1Head.Id, li.Index__c
                            );
                            
                            // Fallback: Direct query if map lookup fails
                            if (year1Amount == null) {
                                List<Expense_Line_Item__c> year1LineItems = [
                                    SELECT Total_Expense__c 
                                    FROM Expense_Line_Item__c 
                                    WHERE Expense_Head__c = :year1Head.Id 
                                    AND Index__c = :li.Index__c 
                                    LIMIT 1
                                ];
                                if (!year1LineItems.isEmpty() && year1LineItems[0].Total_Expense__c != null) {
                                    year1Amount = year1LineItems[0].Total_Expense__c;
                                    System.debug('Found Year1 via direct query: ' + year1Amount);
                                }
                            }
                            
                            if (year1Amount != null) {
                                if (li.Year1_Expense__c != year1Amount) {
                                    System.debug('>>> SETTING Year1_Expense__c: LineItem=' + li.Id + 
                                               ' OLD_VALUE=' + li.Year1_Expense__c + 
                                               ' NEW_VALUE=' + year1Amount +
                                               ' from Year1 Head=' + year1Head.Id + 
                                               ' HeadName=' + year1HeadName +
                                               ' Index=' + li.Index__c);
                                    li.Year1_Expense__c = year1Amount;
                                    hasChanges = true;
                                } else {
                                    System.debug('Year1_Expense__c already correct: ' + year1Amount + ' for LineItem=' + li.Id);
                                }
                            } else {
                                System.debug('Could not find Year 1 line item for APA=' + apaId + 
                                           ' HeadName=' + year1HeadName + ' HeadId=' + year1Head.Id + 
                                           ' Index=' + li.Index__c + ' CurrentHeadName=' + headName);
                            }
                        } else {
                            System.debug('Year1 head validation failed - year1Year=' + year1Year + 
                                       ' expected 1, HeadId=' + year1Head.Id);
                        }
                    }
                    
                    // For Year 3 (Is_Last_Year__c=true): Populate Year2_Expense__c from Year 2
                    if (currentIndex >= 2) {
                        Expense_Head__c year2Head = sortedHeads[currentIndex - 2];
                        String year2YearStr = year2Head.Yearly_Expense__r != null && year2Head.Yearly_Expense__r.Year__c != null ? 
                                            year2Head.Yearly_Expense__r.Year__c : '0';
                        Integer year2Year = Integer.valueOf(year2YearStr);
                        
                        // Only populate Year2_Expense__c if year2Head is actually Year 2
                        if (year2Year == 2) {
                            // Get Year 2 head name
                            String year2HeadName = year2Head.Name != null ? year2Head.Name : '';
                            
                            Decimal year2Amount = findMatchingLineItemAmount(
                                lineItemsByApaAndHeadName, apaId, year2HeadName, year2Head.Id, li.Index__c
                            );
                            if (year2Amount != null) {
                                if (li.Year2_Expense__c != year2Amount) {
                                    System.debug('>>> SETTING Year2_Expense__c: LineItem=' + li.Id + 
                                               ' OLD_VALUE=' + li.Year2_Expense__c + 
                                               ' NEW_VALUE=' + year2Amount +
                                               ' from Year2 Head=' + year2Head.Id + 
                                               ' HeadName=' + year2HeadName +
                                               ' Index=' + li.Index__c);
                                    li.Year2_Expense__c = year2Amount;
                                    hasChanges = true;
                                } else {
                                    System.debug('Year2_Expense__c already correct: ' + year2Amount + ' for LineItem=' + li.Id);
                                }
                            }
                        }
                    }
                    
                    // ALWAYS set current year's expense value from Total_Expense__c:
                    // - Year 2 (Is_Last_Year__c=true): Set Year2_Expense__c = Total_Expense__c
                    // - Year 3 (Is_Last_Year__c=true): Set Year3_Expense__c = Total_Expense__c
                    if (currentYear == 2) {
                        // Year 2 is the last year - set Year2_Expense__c from current Total_Expense__c
                        if (li.Year2_Expense__c != li.Total_Expense__c) {
                            li.Year2_Expense__c = li.Total_Expense__c;
                            hasChanges = true;
                        }
                    } else if (currentYear == 3) {
                        // Year 3 is the last year - set Year3_Expense__c from current Total_Expense__c
                        if (li.Year3_Expense__c != li.Total_Expense__c) {
                            li.Year3_Expense__c = li.Total_Expense__c;
                            hasChanges = true;
                        }
                    }
                    
                    // Mark for update if any field changed
                    if (hasChanges) {
                        System.debug('>>> MARKING LineItem for update: Id=' + li.Id + 
                                   ' Year1_Expense__c=' + li.Year1_Expense__c +
                                   ' Year2_Expense__c=' + li.Year2_Expense__c +
                                   ' Year3_Expense__c=' + li.Year3_Expense__c);
                        lineItemsToUpdate.add(li);
                    } else {
                        System.debug('No changes needed for LineItem: Id=' + li.Id);
                    }
                }
            }
        }
        
        // Update line items if needed
        if (!lineItemsToUpdate.isEmpty()) {
            System.debug('=== UPDATING Expense_Line_Item__c RECORDS ===');
            System.debug('Total line items to update: ' + lineItemsToUpdate.size());
            for (Expense_Line_Item__c li : lineItemsToUpdate) {
                System.debug('  Updating LineItem: Id=' + li.Id + 
                           ' HeadName=' + (li.Expense_Head__r != null ? li.Expense_Head__r.Name : 'null') +
                           ' Year=' + (li.Expense_Head__r != null && li.Expense_Head__r.Yearly_Expense__r != null ? 
                                      li.Expense_Head__r.Yearly_Expense__r.Year__c : 'null') +
                           ' Index__c=' + li.Index__c +
                           ' Year1_Expense__c=' + li.Year1_Expense__c +
                           ' Year2_Expense__c=' + li.Year2_Expense__c +
                           ' Year3_Expense__c=' + li.Year3_Expense__c +
                           ' Total_Expense__c=' + li.Total_Expense__c);
            }
            update lineItemsToUpdate;
            System.debug('✓ Successfully updated ' + lineItemsToUpdate.size() + ' Expense_Line_Item__c records for proposal: ' + proposalId);
        } else {
            System.debug('No Expense_Line_Item__c records to update');
        }
    }
    
    // Helper method to find matching line item amount by Index__c and Expense Head Name
    private static Decimal findMatchingLineItemAmount(
        Map<Id, Map<String, List<Expense_Line_Item__c>>> lineItemsByApaAndHeadName, 
        Id apaId, 
        String headName, 
        Id expenseHeadId, 
        Decimal lineItemIndex
    ) {
        if (!lineItemsByApaAndHeadName.containsKey(apaId)) {
            System.debug('findMatchingLineItemAmount: APA not found in map: ' + apaId);
            return null;
        }
        
        if (!lineItemsByApaAndHeadName.get(apaId).containsKey(headName)) {
            System.debug('findMatchingLineItemAmount: HeadName not found in map: ' + headName + 
                        ' Available keys: ' + lineItemsByApaAndHeadName.get(apaId).keySet());
            return null;
        }
        
        // Handle null Index__c - use 0 as default
        Decimal searchIndex = lineItemIndex != null ? lineItemIndex : 0;
        
        List<Expense_Line_Item__c> candidates = lineItemsByApaAndHeadName.get(apaId).get(headName);
        System.debug('findMatchingLineItemAmount: Searching ' + candidates.size() + ' line items for HeadId=' + 
                    expenseHeadId + ' Index=' + searchIndex);
        
        for (Expense_Line_Item__c li : candidates) {
            if (li.Expense_Head__c == expenseHeadId) {
                Decimal liIndex = li.Index__c != null ? li.Index__c : 0;
                if (liIndex == searchIndex) {
                    Decimal result = li.Total_Expense__c != null ? li.Total_Expense__c : 0;
                    System.debug('findMatchingLineItemAmount: Found match! LineItem=' + li.Id + 
                               ' Total_Expense__c=' + result);
                    return result;
                }
            }
        }
        
        System.debug('findMatchingLineItemAmount: No match found for HeadId=' + expenseHeadId + 
                    ' Index=' + searchIndex);
        return null;
    }
    
    
    public static void newMethod(){
        string proposalId;
        List<Applicant_Proposal_Association__c> apas = [
            SELECT Id, Proposals__c 
            FROM Applicant_Proposal_Association__c 
            WHERE Proposals__c = :proposalId
        ];
    }
}
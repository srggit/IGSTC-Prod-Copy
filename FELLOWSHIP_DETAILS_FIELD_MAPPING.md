# Fellowship Details - Field Mapping Documentation

This document maps all UI fields from `Fellowship_Details.js` to their corresponding Salesforce objects and fields.

## Field Mappings

### 1. Title of the project
- **UI Field**: `Title of the project` (Line 270-274 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Title_Of_Project__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Title_Of_Project__c`
- **Notes**: Required field, stored in Contact object

### 2. Keywords
- **UI Field**: `Keywords` (Line 295-319 in Fellowship_Details.page)
- **JavaScript Variable**: `objKeyword` array (max 6 keywords)
- **Salesforce Object**: `Application_Proposal__c`
- **Salesforce Field**: `KeyWords__c`
- **Notes**: 
  - Stored as semicolon-separated string (e.g., "keyword1;keyword2;keyword3")
  - Maximum 6 keywords allowed
  - Saved in `insertFellowship_DetailsWithTheme` method (Line 9390)

### 3. Broad area of research
- **UI Field**: `Broad area of research` (Line 323-329 in Fellowship_Details.page)
- **JavaScript Variable**: `$scope.BroadAreaOfResearch`
- **Salesforce Object**: `Application_Proposal__c`
- **Salesforce Field**: `Broad_area_of_research__c`
- **Notes**: 
  - Required field
  - Passed as separate parameter to backend
  - Saved in `insertFellowship_DetailsWithTheme` method (Line 9392)

### 4. Non-technical title of the project
- **UI Field**: `Non-technical title of the project` (Line 330-336 in Fellowship_Details.page)
- **JavaScript Variable**: `$scope.NonTechTitle`
- **Salesforce Object**: `Application_Proposal__c`
- **Salesforce Field**: `Non_Technical_Title_Of_Project__c`
- **Notes**: 
  - Required field
  - Passed as separate parameter to backend
  - Saved in `insertFellowship_DetailsWithTheme` method (Line 9391)

### 5. Subtopic (Thematic Areas)
- **UI Field**: `Subtopic` (Line 278-292 in Fellowship_Details.page - Currently commented out)
- **JavaScript Variable**: `thematicAreaToDisplay` array, `selectedTheme` array
- **Salesforce Object**: `Application_Thematic_Area__c` (junction object)
- **Salesforce Fields**: 
  - `Application__c` (lookup to Application_Proposal__c)
  - `Thematic_Area__c` (lookup to Thematic Area)
- **Notes**: 
  - Currently commented out in UI but functionality exists
  - Multiple thematic areas can be selected
  - Saved as junction records in `insertFellowship_DetailsWithTheme` method (Lines 9396-9415)
  - Existing records are deleted and recreated on save

### 6. Work plan for the visit duration
- **UI Field**: `Work plan for the visit duration` (Line 342-357 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Planned_research_activities_of_the_visit__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Planned_research_activities_of_the_visit__c`
- **Notes**: 
  - Required field
  - Rich text field (CKEditor)
  - Maximum 1500 characters without spaces
  - Character count tracked via `objRtf[0].charCount`

### 7. Expected outcomes
- **UI Field**: `Expected outcomes including future plans emerging out of the visit and value addition to the parent organization` (Line 359-374 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Expected_outcomes__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Expected_outcomes__c`
- **Notes**: 
  - Required field
  - Rich text field (CKEditor)
  - Maximum 500 characters without spaces
  - Character count tracked via `objRtf[1].charCount`

### 8. Basis for choosing paired member
- **UI Field**: `What is the basis for choosing your paired member of the application?` (Line 376-390 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Basis_for_choosing_your_paired_member__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Basis_for_choosing_your_paired_member__c`
- **Notes**: 
  - Required field
  - Rich text field (CKEditor)
  - Maximum 500 characters without spaces
  - Character count tracked via `objRtf[2].charCount`

### 9. Plans for networking visits
- **UI Field**: `Plans for networking visits to different institutions during the fellowship, if any` (Line 392-405 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Tentative_plans__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Tentative_plans__c`
- **Notes**: 
  - Optional field
  - Rich text field (CKEditor)
  - Maximum 500 characters without spaces
  - Character count tracked via `objRtf[3].charCount`

### 10. Proposed Start Date
- **UI Field**: `Proposed Start Date` (Line 421-431 in Fellowship_Details.page)
- **JavaScript Variable**: `$scope.tentitiveStartDate`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Tentative_Start_Date__c`
- **Notes**: 
  - Required field
  - Date input field
  - Passed as separate parameters (startday, startmonth, startyear) to backend
  - Converted to Date object in `insertFellowship_DetailsWithTheme` method (Line 9366)
  - Validated against Pecfar_Information_Text__c and Result_Announcement_Date__c

### 11. Proposed End Date
- **UI Field**: `Proposed End Date` (Line 433-442 in Fellowship_Details.page)
- **JavaScript Variable**: `$scope.tentitiveEndDate`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Tentative_End_Date__c`
- **Notes**: 
  - Required field
  - Date input field
  - Passed as separate parameters (endday, endmonth, endyear) to backend
  - Converted to Date object in `insertFellowship_DetailsWithTheme` method (Line 9372)
  - Validated against Pecfar_Information_Text_2__c, Result_Announcement_Date__c, and Start Date
  - Duration must be at least 30 days

### 12. Are you availing any other fellowship currently?
- **UI Field**: `Are you availing any other fellowship currently?` (Line 447-473 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Availing_Fellowship__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Availing_Fellowship__c`
- **Notes**: 
  - Required field
  - Picklist field (Yes/No)
  - Populated from `$rootScope.availingFellowship` array

### 13. Give Fellowship Details
- **UI Field**: `Give Details Fellowship Details` (Line 474-484 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Give_Fellowship_Details__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Give_Fellowship_Details__c`
- **Notes**: 
  - Conditionally required (only if Availing_Fellowship__c = 'Yes')
  - Rich text field (CKEditor)
  - Shown conditionally via `ng-if="proposalDetails.Availing_Fellowship__c == 'Yes'"`

### 14. Whether the applicant/host/mentor/supervisor was previously associated with the IGSTC in past?
- **UI Field**: `Whether the applicant/host/mentor/supervisor was previously associated with the IGSTC in past?` (Line 454-492 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Associated_with_IGSTC__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Associated_with_IGSTC__c`
- **Notes**: 
  - Required field
  - Picklist field (Yes/No)
  - Populated from `$rootScope.pairedApplicant` array

### 15. Give Associated Details
- **UI Field**: `Give Details` (Line 497-507 in Fellowship_Details.page)
- **JavaScript Variable**: `proposalDetails.Give_Associated_Details__c`
- **Salesforce Object**: `Contact`
- **Salesforce Field**: `Give_Associated_Details__c`
- **Notes**: 
  - Conditionally required (only if Associated_with_IGSTC__c = 'Yes')
  - Rich text field (CKEditor)
  - Shown conditionally via `ng-if="proposalDetails.Associated_with_IGSTC__c == 'Yes'"`

## Read-Only/Display Fields (Not Saved)

### 16. Travel Date Range Information
- **UI Field**: Travel date range display (Line 407-419 in Fellowship_Details.page)
- **JavaScript Variable**: 
  - `$scope.Pecfar_dateInformationText` (Start date)
  - `$scope.Pecfar_dateInformationText2` (End date)
- **Salesforce Object**: `Yearly_Call__c` (via relationship)
- **Salesforce Fields**: 
  - `Pecfar_Information_Text__c` (via `Applicant_Proposal_Associations__r[0].Proposals__r.yearly_Call__r.Pecfar_Information_Text__c`)
  - `Pecfar_Information_Text_2__c` (via `Applicant_Proposal_Associations__r[0].Proposals__r.yearly_Call__r.Pecfar_Information_Text_2__c`)
- **Notes**: 
  - Display only - used for validation
  - Loaded in `getProjectdetils()` method (Lines 101-102)

### 17. Result Announcement Date
- **UI Field**: Used for validation only (not displayed in UI)
- **JavaScript Variable**: `$scope.announcementDate`
- **Salesforce Object**: `Yearly_Call__c` (via relationship)
- **Salesforce Field**: `Result_Announcement_Date__c` (via `Applicant_Proposal_Associations__r[0].Proposals__r.yearly_Call__r.Result_Announcement_Date__c`)
- **Notes**: 
  - Used for date validation only
  - Loaded in `getProjectdetils()` method (Lines 106-108)

## Summary of Objects Used

### Primary Objects:
1. **Contact** - Stores most fellowship detail fields
2. **Application_Proposal__c** - Stores proposal-level fields (Keywords, Broad Area, Non-Technical Title)
3. **Application_Thematic_Area__c** - Junction object for Thematic Areas (currently not in use)

### Related Objects (Read-Only):
- **Yearly_Call__c** - Provides date constraints for validation
- **Applicant_Proposal_Association__c** - Links Contact to Application_Proposal__c
- **Account** - Updated when Contact is updated (triggered update)

## Save Method Flow

The `saveApplication()` function (Line 255 in Fellowship_Details.js) calls:
- `ApplicantPortal_Contoller.insertFellowship_Details()` (Line 533)
- Which internally calls `Proposal_Controller.insertFellowship_DetailsWithTheme()` (Line 9350 in Proposal_Controller.cls)

### Save Process:
1. Contact fields are updated via `upsert proposalDetails` (Line 9375)
2. Contact record is updated (Line 9378)
3. Account is updated if Contact has AccountId (Lines 9380-9385)
4. Application_Proposal__c is updated with Keywords, Broad Area, and Non-Technical Title (Lines 9388-9394)
5. Application_Thematic_Area__c records are deleted and recreated (Lines 9396-9415)

## Data Loading

The `getProjectdetils()` function (Line 95 in Fellowship_Details.js) calls:
- `ApplicantPortal_Contoller.getFellowshipDetails()` (Line 97)
- Which internally calls `Proposal_Controller.getFellowshipDetails()` (Line 8918 in Proposal_Controller.cls)

### Load Process:
1. Contact record is queried with related Proposal data (Line 8923-8927)
2. Date fields are converted to Date objects
3. Keywords are split and loaded into `objKeyword` array
4. Thematic areas are loaded separately via `loadSavedThematicAreas()` (Line 210)



Primary objects:
Contact — Stores 11 fields:
Title_Of_Projectc
Planned_research_activities_of_the_visitc
Expected_outcomesc
Basis_for_choosing_your_paired_memberc
Tentative_plansc
Tentative_Start_Datec
Tentative_End_Datec
Availing_Fellowshipc
Give_Fellowship_Detailsc
Associated_with_IGSTCc
Give_Associated_Detailsc

Application_Proposalc — Stores 3 fields:
KeyWordsc (semicolon-separated)
Broad_area_of_researchc
Non_Technical_Title_Of_Projectc

Application_Thematic_Areac — Junction object (currently commented out in UI):
Applicationc (lookup)
Thematic_Areac (lookup)
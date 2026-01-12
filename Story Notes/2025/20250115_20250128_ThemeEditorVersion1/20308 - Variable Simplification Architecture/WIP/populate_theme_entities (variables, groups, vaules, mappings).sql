USE [VeoSolutions_DEV]
GO
/*

use [VeoSolutions_QA]
use [VeoSolutions_QA]
use [VEOSolutions_PREVIEW]
use [VEOSolutions_STAGING]

use [VEOSolutions]
use [AFI_VEOSolutions]
use [CCDI_VEOSolutions]
use [EPLAN_VEOSolutions]

*/

update t 
    set t.BaseThemeId = d.[ID]
from dbo.Theme t 
    inner join dbo.Theme d on d.[Name] = 'Default' and d.[Id] <> t.[Id]
where t.BaseThemeId is null 


drop table if exists #VariableIDS
drop table if exists #temp_ThemeVariableValue

select 
    v.Id,
    v.CssName,
    v.TargetThemeLookupKey,
    cast(v.Id as nvarchar(50)) as IdString
into #VariableIDS
from dbo.ThemeVariable v



select * into #temp_ThemeVariableValue from dbo.ThemeVariableValue

while exists(select * from #temp_ThemeVariableValue v inner join #VariableIDS i on (v.[Value] like '%'+i.IdString+'%' or (v.[Value] like '%var(--'+i.[CssName]+')%' and i.TargetThemeLookupKey is not null)) )
begin

    -- Resolve guids to Css Variable Pointers that are not theme specific
    update v
        set v.Value = replace(v.[Value],i.IdString,'var(--'+i.[CssName]+')')
    from #temp_ThemeVariableValue v 
        inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%' and i.TargetThemeLookupKey is null

    -- Resolve guids to raw Css values that are theme specific
    update v 
        set v.Value = replace(v.[Value],i.IdString, resolutionValue.[Value])
    from #temp_ThemeVariableValue v
        inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%'
        cross apply (
            select top 1 v.[Value] from (
            select *, 1 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = v.ThemeLookupKey
            union
            select *, 2 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = 'default' ) v
            order by v.[Rank]
        ) resolutionValue

    -- Resolve Css variable pointers of theme specific variables to raw Css values
    update v 
        set v.Value = replace(v.[Value], 'var(--'+i.[CssName]+')', resolutionValue.[Value])
    from #temp_ThemeVariableValue v
        inner join #VariableIDS i on v.[Value] like '%var(--'+i.[CssName]+')%' and i.TargetThemeLookupKey is not null
        cross apply (
            select top 1 v.[Value] from (
            select *, 1 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = v.ThemeLookupKey
            union
            select *, 2 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = 'default' ) v
            order by v.[Rank]
        ) resolutionValue
end

delete from #VariableIDS where TargetThemeLookupKey is not null

-- Populate ThemeableVariabe from ThemeVariable
MERGE into dbo.ThemeableVariable tvn
using (
    Select 
        tvo.Id,
        tvo.CssName,
        tvo.[Name],
        tvo.[Description],
        tvo.Author,
        tvo.CreateDate,
        tvo.Modifier,
        tvo.ModifiedDate
    from dbo.ThemeVariable tvo
        inner join #VariableIDS v on v.Id = tvo.Id ) tvo on tvn.Id = tvo.Id
when not matched by target then
    insert (Id, CssName, [Name], [Description], Author, CreateDate, Modifier, ModifiedDate)
    values (tvo.Id, tvo.CssName, tvo.[Name], tvo.[Description], tvo.Author, tvo.CreateDate, tvo.Modifier, tvo.ModifiedDate);

-- Populate ThemeableVariableValue from sanitized ThemeVariableValue temp table
merge into dbo.ThemeableVariableValue tvvn
using (
    select 
        t.Id as [ThemeId],
        tv.Id as [ThemeableVariableId],
        tvv.[Value],
        tvv.Author,
        tvv.CreateDate,
        tvv.Modifier,
        tvv.ModifiedDate
    from #temp_ThemeVariableValue tvv 
        inner join dbo.Theme t on t.LookupKey = tvv.ThemeLookupKey
        inner join dbo.ThemeableVariable tv on tv.Id = tvv.ThemeVariableId ) tvvo on tvvn.ThemeId = tvvo.ThemeId and tvvn.ThemeableVariableId = tvvo.ThemeableVariableId
when not matched by target then
    insert (ThemeId, ThemeableVariableId, [Value], Author, CreateDate, Modifier, ModifiedDate)
    values (tvvo.ThemeId, tvvo.ThemeableVariableId, tvvo.[Value], tvvo.Author, tvvo.CreateDate, tvvo.Modifier, tvvo.ModifiedDate);


-- Populate ThemeableGroupVariable
MERGE INTO [dbo].[ThemeableGroupVariable] AS tgt
USING (
    VALUES
    ('6886F0AA-063C-473A-B379-B88EA5E89D17', 'Font', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
    ('09ACE614-1198-4AD0-9722-FA68BCE269D8', 'Primary Lighter Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('E75488DA-B68B-4DE5-84EF-A20D788AA068', 'Primary Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('AA552504-6765-4F80-8C88-C12C3625498F', 'Primary Darker Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('75164761-D1E7-49A0-B208-B54AF7597B15', 'Primary Darkest Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('16B65323-87CF-489E-8808-159BF0FFED4D', 'Secondary Lighter Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('D76DCC1E-07D8-41BC-A76E-4E063A2F0DAB', 'Secondary Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('1EF3EAED-7DAD-4DBA-B46A-7DCBDB61486E', 'Secondary Darker Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('3EBDB7ED-0839-49C1-90EA-62123F7B30ED', 'Secondary Darkest Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('D986ED8B-9B29-420D-874F-EE1F40C1480F', 'Dark Background Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('CC83DB2D-4704-4C0A-B9E2-7C8AAE3B6C00', 'Text Primary Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('614CD9A1-06F3-4888-9B11-1FACD9B8757B', 'Text Dark Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('BB3A9308-8409-493E-A129-41BCDED790BC', 'Text Light Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('994C12ED-7ADB-4619-A88F-531D3A8032E9', 'Site Header/Footer Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('4F78D496-98E9-4400-B1A4-6F03E608ECFC', 'Title Bar Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('1EB103A6-5345-462C-9680-01AECBE878E2', 'Primary Icon Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('5F554E58-911F-4B38-9486-2A431B35A729', 'Complimentary/Emphasis Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('F4E591FA-3138-4164-A987-1663B3658436', 'Error Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('FD4E1F5E-BA61-43C0-8593-D49403ED9ECD', 'Complete Color', '', 'reidw', GETDATE(), 'reidw', GETDATE()),
	('A9BF8511-E3FE-4392-947C-DF4A8C4D34AE', 'Warning Color', '', 'reidw', GETDATE(), 'reidw', GETDATE())
) AS src (Id, Name, Description, Author, CreateDate, Modifier, ModifiedDate)
ON tgt.Id = src.Id
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Id, Name, Description, Author, CreateDate, Modifier, ModifiedDate)
    VALUES (src.Id, src.Name, src.Description, src.Author, src.CreateDate, src.Modifier, src.ModifiedDate);


-- Populate the desired mappings
merge into dbo.ThemeableGroupVariableMapping tgv
    using (
    select 
        tgv.[Id] as ThemeableGroupVariableId,
        tv.[Id] as ThemeableVariableId,
        'justinpo' as Author,
        getdate() as CreateDate,
        'justinpo' as Modifier,
        getdate() as ModifiedDate
    from (
        VALUES
            ('font-main', 'Font'),
            ('text-sessionCard-primary-2', 'Primary Lighter Color'),
            ('bg-hbDashboard-orientationStep-inactive-light', 'Primary Lighter Color'),
            ('bg-optionPricing-areaHeader-hover', 'Primary Lighter Color'),
            ('bg-disclaimerCheckbox', 'Primary Lighter Color'),
            ('bg-userRegistration-testUserMessage', 'Primary Lighter Color'),
            ('color-selectionsReportOptions-highlightedCategory', 'Primary Lighter Color'),
            ('boxShadow-selectionsReportOptions-option', 'Primary Lighter Color'),
            ('btn-primary', 'Primary Color'),
            ('btn-grouped-current', 'Primary Color'),
            ('switch-bg', 'Primary Color'),
            ('text-menu', 'Primary Color'),
            ('color-primary', 'Primary Color'),
            ('color-primary-alt1', 'Primary Color'),
            ('bg-cancelimpersonation', 'Primary Color'),
            ('border-left-menu-option-hover', 'Primary Color'),
            ('icon-titleBar-mobileMenu-dots', 'Primary Color'),
            ('color-sessionCard-actionBlock-title', 'Primary Color'),
            ('color-profileStatus-contracted', 'Primary Color'),
            ('bg-hbDashboard-orientationStep-inactive', 'Primary Color'),
            ('bg-hbDashboard-progressBar', 'Primary Color'),
            ('bg-optionPricing-areaHeader', 'Primary Color'),
            ('bg-optionPricing-priceLevel-selected', 'Primary Color'),
            ('color-dmh-icons-primary', 'Primary Color'),
            ('color-dmh-roomProducticon', 'Primary Color'),
            ('bg-dmh-optionMenu-optionDetailSelections-fullySelectedCheck', 'Primary Color'),
            ('color-ds-wizard-priceLevelSelector-flag-icon', 'Primary Color'),
            ('color-ds-cabinetWizard-priceLevelSelector-flag-icon', 'Primary Color'),
            ('bg-ds-catalog-item-field-section-divider', 'Primary Color'),
            ('bg-ds-catalogDocumentSelectedindicator', 'Primary Color'),
            ('bg-buyerWelcome-letsGetStarted-button', 'Primary Color'),
            ('color-selectionsReportOptions-selectedOption', 'Primary Color'),
            ('btn-primary-hover', 'Primary Darker Color'),
            ('bg-dmh-product-list-product-selected', 'Primary Darker Color'),
            ('bg-dmh-navMenu-selected', 'Primary Darker Color'),
            ('bg-ds-mobileMenu-hover', 'Primary Darker Color'),
            ('color-actionBar', 'Primary Darker Color'),
            ('boxShadowColor-actionBar-selected', 'Primary Darker Color'),
            ('bg-buyerWelcome-letsGetStarted-button-hover', 'Primary Darker Color'),
            ('btn-primary-active', 'Primary Darkest Color'),
            ('btn-grouped-border', 'Secondary Lighter Color'),
            ('bg-footer-contentSupportEmailArea-hover', 'Secondary Lighter Color'),
            ('bg-hbDashboard-orientationStep-active-light', 'Secondary Lighter Color'),
            ('btn-completeOrientationStep-hover', 'Secondary Lighter Color'),
            ('bg-optionPricing-priceLevelHeader-hover', 'Secondary Lighter Color'),
            ('bg-optionPricing-selectedCell', 'Secondary Lighter Color'),
            ('color-lifestyle-saturated-light-4', 'Secondary Lighter Color'),
            ('color-lifestyle-saturated-light-3', 'Secondary Lighter Color'),
            ('color-lifestyle-saturated-light-2', 'Secondary Lighter Color'),
            ('color-lifestyle-saturated-light-1', 'Secondary Lighter Color'),
            ('btn-secondary', 'Secondary Color'),
            ('btn-grouped-bg', 'Secondary Color'),
            ('text-disclaimerWelcomeMsg', 'Secondary Color'),
            ('bg-hbDashboard-orientationStep-active', 'Secondary Color'),
            ('btn-completeOrientationStep', 'Secondary Color'),
            ('bg-optionPricing-priceLevelHeader', 'Secondary Color'),
            ('color-optionPricing-screenToggle-active', 'Secondary Color'),
            ('color-dmh-disclaimer-dialog-community-name', 'Secondary Color'),
            ('bg-dmh-visualizableindicator-light-side', 'Secondary Color'),
            ('bg-nonEstimateditemCard-compareIcon-close', 'Secondary Color'),
            ('bg-nonEstimatedItemCard-compareIcon', 'Secondary Color'),
            ('boxShadowColor-nonEstimatedItemCard-compareIcon', 'Secondary Color'),
            ('border-nonEstimatedItemCard-compareIcon-close', 'Secondary Color'),
            ('color-lifestyle-primary', 'Secondary Color'),
            ('bg-lifestyle-button', 'Secondary Color'),
            ('color-lifestyle-saturated', 'Secondary Color'),
            ('color-colorGame-selector', 'Secondary Color'),
            ('color-wishlist', 'Secondary Color'),
            ('color-notification', 'Secondary Color'),
            ('btn-secondary-hover', 'Secondary Darker Color'),
            ('bg-dmh-visualizableIndicator-dark-side', 'Secondary Darker Color'),
            ('color-lifestyle-saturated-dark-1', 'Secondary Darker Color'),
            ('color-lifestyle-saturated-dark-2', 'Secondary Darker Color'),
            ('btn-secondary-active', 'Secondary Darkest Color'),
            ('btn-nonEstimateditem-compare', 'Secondary Darkest Color'),
            ('color-lifestyle-saturated-dark-3', 'Secondary Darkest Color'),
            ('color-lifestyle-saturated-dark-4', 'Secondary Darkest Color'),
            ('bg-dark', 'Dark Background Color'),
            ('bg-dark-noImage', 'Dark Background Color'),
            ('bg-sessionCard-actionBlock', 'Dark Background Color'),
            ('bg-optionPricing-leftPane', 'Dark Background Color'),
            ('bg-optionPricing-rightPane', 'Dark Background Color'),
            ('table-header-color', 'Dark Background Color'),
            ('bg-optionPricing-productSamplesTab-priceLevel-header', 'Dark Background Color'),
            ('bg-optionPricing-rightPane-disabledTab', 'Dark Background Color'),
            ('bg-optionPricing-screenToggle', 'Dark Background Color'),
            ('bg-optionPricing-screenToggle-active', 'Dark Background Color'),
            ('color-dmh-dark-accent', 'Dark Background Color'),
            ('color-dmh-dark-accent-alt-lighter', 'Dark Background Color'),
            ('color-dmh-prefMenu-prefToggle-top-border', 'Dark Background Color'),
            ('bg-dmh-header', 'Dark Background Color'),
            ('bg-dmh-optionMenu-tab-selected', 'Dark Background Color'),
            ('bg-dmh-product-filter-dropdown-top', 'Dark Background Color'),
            ('bg-dmh-leftPanel-nav', 'Dark Background Color'),
            ('bg-ds-sessionSupportEmail-attachFile', 'Dark Background Color'),
            ('bg-ds-leftPane', 'Dark Background Color'),
            ('bg-ds-catalogSearchBar', 'Dark Background Color'),
            ('bg-ds-mobileMenuLauncher-button', 'Dark Background Color'),
            ('bg-ds-mobileMenu', 'Dark Background Color'),
            ('bg-busyindicator', 'Dark Background Color'),
            ('bg-supportEmail-attachFile-button', 'Dark Background Color'),
            ('text-primary', 'Text Primary Color'),
            ('text-primary-lighter', 'Text Primary Color'),
            ('text-primary-alt1', 'Text Primary Color'),
            ('color-footer-helpMenu-item', 'Text Primary Color'),
            ('text-sessionCard-primary-1', 'Text Primary Color'),
            ('color-optionPricing-currentPlanEditButton', 'Text Primary Color'),
            ('color-dmh-text-primary', 'Text Primary Color'),
            ('color-dmh-optionMenu-tab-title', 'Text Primary Color'),
            ('color-dmh-optionMenu-tab-selected-title', 'Text Primary Color'),
            ('color-dmh-leftNav-listitem-active', 'Text Primary Color'),
            ('bg-dmh-navMenu-close-hover', 'Text Primary Color'),
            ('color-ds-text-primary', 'Text Primary Color'),
            ('color-beta-sup', 'Text Primary Color'),
            ('text-darkest', 'Text Dark Color'),
            ('text-dark', 'Text Dark Color'),
            ('color-title-bar-text', 'Text Dark Color'),
            ('color-dmh-optionMenu-tab-desc', 'Text Dark Color'),
            ('color-banner-text', 'Text Dark Color'),
            ('text-light', 'Text Light Color'),
            ('color-main-site-header-text', 'Text Light Color'),
            ('color-cancelImpersonation', 'Text Light Color'),
            ('text-copyright', 'Text Light Color'),
            ('color-optionPricing-screenToggle', 'Text Light Color'),
            ('color-optionPricing-areaCard-areaName-text', 'Text Light Color'),
            ('color-optionPricing-rightPane-disabledTab-text', 'Text Light Color'),
            ('color-dmh-optionMenu-tab-selected-desc', 'Text Light Color'),
            ('color-dmh-disclaimer-dialog-community-series-plan-text', 'Text Light Color'),
            ('color-dmh-materialsTab-text', 'Text Light Color'),
            ('color-dmh-materialsTab-text-selected', 'Text Light Color'),
            ('color-ds-mobileMenu-item-text', 'Text Light Color'),
            ('bg-planSelector-selectedPlan', 'Text Light Color'),
            ('icon-nonEstimateditemCard-compareIcon-close', 'Text Light Color'),
            ('color-userRegistration-testUserMessage-text', 'Text Light Color'),
            ('color-busyIndicator', 'Text Light Color'),
            ('color-buyerWelcome-letsGetStarted-button', 'Text Light Color'),
            ('color-buyerWelcome-maybeLater-button', 'Text Light Color'),
            ('bg-main-site-header', 'Site Header/Footer Color'),
            ('bg-footer', 'Site Header/Footer Color'),
            ('bg-footer-contentSupportEmailArea', 'Site Header/Footer Color'),
            ('bg-title-bar', 'Title Bar Color'),
            ('color-icon-light', 'Primary Icon Color'),
            ('color-icon-primary', 'Primary Icon Color'),
            ('color-icon-signOut', 'Primary Icon Color'),
            ('color-icon-training', 'Primary Icon Color'),
            ('color-training-text', 'Primary Icon Color'),
            ('bg-footer-supportEmailQuestionMark', 'Primary Icon Color'),
            ('color-optionPricing-rightPane-collapseButton-icon', 'Primary Icon Color'),
            ('color-optionPricing-selectionSummary-card-icon', 'Primary Icon Color'),
            ('color-optionPricing-currentPlanEditButton-icon', 'Primary Icon Color'),
            ('color-optionPricing-leftPane-applicationProductList-navIcon', 'Primary Icon Color'),
            ('color-ds-mobileMenu-item-icon', 'Primary Icon Color'),
            ('bg-emphasis', 'Complimentary/Emphasis Color'),
            ('color-profileStatus-other', 'Complimentary/Emphasis Color'),
            ('color-dmh-icon-included-product-on-darkBg', 'Complimentary/Emphasis Color'),
            ('color-dmh-icon-included-product-on-lightBg', 'Complimentary/Emphasis Color'),
            ('color-planSelector-selectedPlan', 'Complimentary/Emphasis Color'),
            ('bg-banner', 'Complimentary/Emphasis Color'),
            ('color-profileStatus-bustout', 'Error Color'),
            ('color-dmh-visualizer-somethingWentWrong-error-icon', 'Error Color'),
            ('color-ds-catalogCard-status-error', 'Error Color'),
            ('bg-ds-catalogCard-body-status-error', 'Error Color'),
            ('bg-ds-catalogCard-header-status-error', 'Error Color'),
            ('color-profileStatus-complete', 'Complete Color'),
            ('bg-hbDashboard-moduleComplete', 'Complete Color'),
            ('color-ds-catalogCard-status-complete', 'Complete Color'),
            ('color-ds-catalogCard-status-complete-icon', 'Complete Color'),
            ('bg-ds-catalogCard-body-status-complete', 'Complete Color'),
            ('bg-ds-catalogCard-header-status-complete', 'Complete Color'),
            ('bg-dmh-prefMenu-budgetExclamation', 'Warning Color'),
            ('bg-dmh-visualizer-exclamation-banner', 'Warning Color'),
            ('color-ds-catalogCard-status-incomplete', 'Warning Color'),
            ('color-ds-catalogCard-status-incomplete-icon', 'Warning Color'),
            ('bg-ds-catalogCard-body-status-incomplete', 'Warning Color'),
            ('bg-ds-catalogCard-header-status-incomplete', 'Warning Color'),
            ('color-ds-catalogCard-status-error-icon', 'Error Color'),
            ('btn-grouped-hover', 'Secondary Lighter Color'),
            ('color-footer-update','Text Light Color')) as src (CssName, GroupName)
        inner join dbo.ThemeableVariable tv on tv.CssName = src.CssName
        inner join dbo.ThemeableGroupVariable tgv on tgv.[Name] = src.GroupName ) grps on grps.ThemeableVariableId = tgv.ThemeableVariableId
                                                                                       and grps.ThemeableGroupVariableId = tgv.ThemeableGroupVariableId
when not matched by target then
    insert (ThemeableGroupVariableId, ThemeableVariableId, Author, CreateDate, Modifier, ModifiedDate)
    values (grps.ThemeableGroupVariableId, grps.ThemeableVariableId, grps.Author, grps.CreateDate, grps.Modifier, grps.ModifiedDate);






select * from dbo.ThemeableVariable 
select * from dbo.ThemeableVariableValue
select * from dbo.ThemeableGroupVariable
select * from dbo.ThemeableGroupVariableMapping
/*
USE [VeoSolutions_DEV]
USE [VeoSolutions_QA]
USE [VeoSolutions_PREVIEW]
USE [VeoSolutions_STAGING]

USE [AFI_VeoSolutions]
USE [CCDI_VeoSolutions]
USE [EPLAN_VeoSolutions]
USE [VeoSolutions]
*/

--variables used here for readability and reuse (D-R-Y);
DECLARE @cardBackgroundVariableId UNIQUEIDENTIFIER = 'E632A7B3-815E-40C4-A0B2-477C8C8EEED6';
DECLARE @cardPriceTextColorVariableId UNIQUEIDENTIFIER = '65E54D02-5739-447B-B1C4-8A4BF6CCE68F';

DECLARE @palettePrimaryDark1 varchar(7) = '#141e33';
DECLARE @textPrimaryAlt1 varchar(50) = '#19e697';
DECLARE @textPrimaryAlt1_REF varchar(50) = 'var(--text-primary-alt1)';
DECLARE @paletteSecondaryLight1_REF varchar(50) = 'var(--palette-secondary-light-1)';
DECLARE @vdsCustomThemeId UNIQUEIDENTIFIER = '8162223D-2857-4E57-80F3-1E7183173746';

DECLARE @Flintrock_ThemeId UNIQUEIDENTIFIER = '6CFA416D-2EF3-41F0-AB7B-EB503ABD5699';
DECLARE @HistoryMaker_ThemeId UNIQUEIDENTIFIER = 'D35129C5-451E-4E91-BD51-34AAD43BA189';
DECLARE @Newmark_ThemeId UNIQUEIDENTIFIER = 'A9A21737-6071-4405-86BB-3E86D2E68784';
DECLARE @Stylecraft_ThemeId UNIQUEIDENTIFIER = 'D4D24AA9-974D-455A-B7A2-D3FE77C0247B';
DECLARE @TaylorMorrison_ThemeId UNIQUEIDENTIFIER = '10A814CC-BAD9-42B3-B7BD-1D0BA438B3B9';
DECLARE @Wild_ThemeId UNIQUEIDENTIFIER = '3F7856C9-A4DA-4A3B-B334-880C5A85E5B3';

--Additional AFI Stack only theme Ids
DECLARE @Dreamfinders_ThemeId UNIQUEIDENTIFIER = '58A734CD-0249-42F3-A947-4D1D13D24248';
DECLARE @TrinityFamilyBuilders_ThemeId UNIQUEIDENTIFIER = '5928C746-E1A5-4DCA-A443-6B3C2600FC33';
DECLARE @Wohali_ThemeId UNIQUEIDENTIFIER = '7BD0A4D1-E33B-407B-9D77-114118283D03';

BEGIN TRY
    BEGIN TRANSACTION;

	--new variables for selection summary card background and price text
	INSERT INTO [dbo].[ThemeableVariable] ([Id],[CssName],[Name],[Description],[Author],[CreateDate],[Modifier],[ModifiedDate])
		 VALUES (@cardBackgroundVariableId,'bg-optionPricing-selectionSummary-card',NULL,NULL,'SEED',GETDATE(),'SEED',GETDATE())
				, (@cardPriceTextColorVariableId,'color-optionPricing-selectionSummary-card-price',NULL,NULL,'SEED',GETDATE(),'SEED',GETDATE());

	--value for new card background variable, for VDS (Custom) theme
	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
		VALUES (@vdsCustomThemeId, @cardBackgroundVariableId, @palettePrimaryDark1, 'SEED',GETDATE(),'SEED',GETDATE(), 1);

	--value for new card pricing text variable, for VDS (Custom) theme
	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
		VALUES (@vdsCustomThemeId, @cardPriceTextColorVariableId, @textPrimaryAlt1, 'SEED',GETDATE(),'SEED',GETDATE(), 1);

	/* Value for new card price text variable, for all current themes to point, either to palette-secondary-light-1 or text-primary-alt1, depending on their base theme and version. 
		NULL base theme & version => palette; Base theme & version NOT NULL => text-primary-alt1 (where the element was previously drawing value from) */
	INSERT INTO [dbo].[ThemeableVariableValue]
		([ThemeId], [ThemeableVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate], [ThemeVersionNumber])
	SELECT 
		t.Id, 
		@cardPriceTextColorVariableId,
		CASE 
			WHEN tv.BaseThemeId IS NULL THEN @paletteSecondaryLight1_REF
			ELSE @textPrimaryAlt1_REF
		END,
		'SEED',
		GETDATE(),
		'SEED',
		GETDATE(),
		tv.Number
	FROM 
		Theme t
	INNER JOIN 
		ThemeVersion tv ON t.Id = tv.ThemeId
	-- exclude VDS(Custom) theme, since that was handled in two separate inserts above
	WHERE t.Id != @vdsCustomThemeId;

	/* Value overrides for production themes whose appearance of the card background was changed by virtue of going from semi-opaque to a solid color.
		This portion of the script brings those back into alignment with their previous appearance, so as not to change the way existing production themes appear to the end-user */
	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#153151', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @Flintrock_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#5d5d5d', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @HistoryMaker_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#691519', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @Newmark_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#001727', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @Stylecraft_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#34322e', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @TaylorMorrison_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '#210052', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id = @Wild_ThemeId;

	INSERT INTO [dbo].[ThemeableVariableValue] ([ThemeId],[ThemeableVariableId], [Value],[Author],[CreateDate],[Modifier],[ModifiedDate],[ThemeVersionNumber])
	SELECT t.Id, @cardBackgroundVariableId, '##001727', 'SEED', GETDATE(), 'SEED', GETDATE(), tv.Number
	FROM Theme t
		INNER JOIN ThemeVersion tv ON t.Id = tv.ThemeId
	WHERE t.Id IN (@Dreamfinders_ThemeId, @TrinityFamilyBuilders_ThemeId, @Wohali_ThemeId); --same value documented, in EPLAN stack for all 3 themes

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;

--===============================================================================================================================
/*  Keeping this here, just in case anything goes sideways with the execution of the code above this.
	Due to the cascade delete of ThemeableVariableValue records upon deletion of their parent ThemeableVariable record,
	deleting the variables will also clear their values and allow you start with a "clean slate".

	DECLARE @cardBackgroundVariableId UNIQUEIDENTIFIER = 'E632A7B3-815E-40C4-A0B2-477C8C8EEED6';
	DECLARE @cardPriceTextColorVariableId UNIQUEIDENTIFIER = '65E54D02-5739-447B-B1C4-8A4BF6CCE68F';
	DELETE FROM ThemeableVariable where Id in (@cardBackgroundVariableId, @cardPriceTextColorVariableId)
*/

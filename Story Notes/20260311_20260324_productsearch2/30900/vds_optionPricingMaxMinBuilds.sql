SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[vds_optionPricingMaxMinBuilds]
@spec_id INT,
@plan_name VARCHAR(50),		
@effective_date DATE

as

/*

		Procedure:	vds_optionPricingMaxMinBuilds
		Author:		Adrian Garza
		Date:		1/21/2015
		Purpose:	Retrieves max/min builds for a spec/plan/effective date.  Used by VDS option pricing
		Usage:	vds_optionPricingMaxMinBuilds 3202,'2199','4/21/2014'

        Modified: 9/25/2015 Modified proc to match production version, WHERE we look for the most current
                            master plan, instead of using the prices landed effective date, since plans
                            can drop off FROM use. Saul.

                  9/25/2015 Modified proc for new cabinet rules for Option Pricing, WHERE the build that
                            is displayed is no longer the max build, but the default build. Saul.

                  9/25/2015 Modified proc to sort the initial select results before looping over them,
                            because this proc did not account for all builds for a given application, product,
                            area, sub area, and location having the same billable qty of 1, so the result
                            set order could change every time this proc was called. Saul.

				  5/25/2017 Modified it so that if it finds more than one plan, for the specified spec_id, plan 
				            name, and effective date - with published data - it uses the plan that was most 
							recently created. Shelby
*/

-----------------------------------------------------------
-- Determine which plan to use. It is possible for there to
-- be multiple matches for a given spec, plan name, and effective date.
-- If there are, we must choose the most recent one.
-----------------------------------------------------------
DECLARE @plan_id INT;
DECLARE @plan_create_date DATETIME;

SELECT DISTINCT TOP 1
	@plan_id = pm.plan_id, @plan_create_date = pm.create_date
FROM
	plan_mstr pm WITH (NOLOCK)
	JOIN prices_landed pl WITH (NOLOCK) ON pl.plan_id = pm.plan_id
WHERE
	pm.spec_id = @spec_id
	AND pm.plan_name = @plan_name
	AND pm.active = 1
	AND (pm.end_date IS NULL OR pm.end_date >= CONVERT(DATE, GETDATE()))
	AND pl.effective_date = @effective_date
ORDER BY
	pm.plan_id DESC

DECLARE @results TABLE
( 
  application_id VARCHAR(10),
  product_id VARCHAR(10),
  area_id VARCHAR(10),
  sub_area_id VARCHAR(10),
  location_id INT,
  max_build_id BIGINT,
  max_build_desc VARCHAR(100),
  max_field_qty DECIMAL(18,2),
  min_build_id BIGINT,
  min_build_desc VARCHAR(100),
  min_field_qty DECIMAL(18,2),
  std_build_id BIGINT,
  std_build_desc VARCHAR(100),
  std_field_qty DECIMAL(18,2)
)

DECLARE @build_id INT,
		@application_id VARCHAR(10),
		@product_id VARCHAR(10),
		@area_id VARCHAR(10),
		@sub_area_id VARCHAR(10),
		@location_id INT,
		@build_qty DECIMAL(18,2),
		@build_desc VARCHAR(100),
		@is_std bit

DECLARE b CURSOR FOR

	SELECT DISTINCT 
	    pl.application_id,
	    pl.product_id,
	    pl.area_id,
	    pl.sub_area_id,
	    pl.location_id,
	    pl.build_id,
	    pb.is_std
	FROM
        prices_landed pl WITH (NOLOCK)
	    LEFT JOIN plan_builds pb WITH (NOLOCK)
            ON pb.build_id = pl.build_id
	WHERE
        pl.plan_id = @plan_id 
        AND effective_date = @effective_date
    ORDER BY
        pl.application_id,
        pl.product_id,
        pl.area_id,
        pl.sub_area_id,
        pl.location_id,
        pb.is_std DESC

OPEN b
FETCH NEXT FROM b INTO @application_id, @product_id, @area_id, @sub_area_id, @location_id, @build_id, @is_std
WHILE @@fetch_status = 0
BEGIN

	SELECT 
		@build_qty = bill_qty,
		@build_desc = pb.build_desc
	FROM
        plan_builds pb WITH (NOLOCK)
	    LEFT JOIN plan_material pm WITH (NOLOCK) 
            ON pm.plan_id = pb.plan_id
		    AND pm.application_id = pb.application_id
		    AND pm.product_id = pb.product_id
		    AND pm.area_id = pb.area_id
		    AND pm.sub_area_id = pb.sub_area_id
		    AND pm.location_id = pb.location_id
		    AND pm.build_id = pb.build_id
		    AND pm.item_id = 'field'
	WHERE
        pb.plan_id = @plan_id
		AND pb.application_id = @application_id
		AND pb.product_id = @product_id
		AND pb.area_id = @area_id
		AND pb.sub_area_id = @sub_area_id
		AND pb.location_id = @location_id
		AND pb.build_id = @build_id

	IF (NOT EXISTS (SELECT
                        area_id
                    FROM
                        @results
                    WHERE
                        application_id = @application_id 
                        AND product_id = @product_id 
                        AND area_id = @area_id 
                        AND sub_area_id = @sub_area_id 
                        AND location_id = @location_id))
	BEGIN
		INSERT INTO @results
		SELECT @application_id, @product_id, @area_id, @sub_area_id, @location_id,
		       @build_id, @build_desc, @build_qty,
			   @build_id, @build_desc, @build_qty,
			   @build_id, @build_desc, @build_qty
	END
	ELSE
	BEGIN
        DECLARE @max_field_qty DECIMAL(18,2)
		DECLARE @min_field_qty DECIMAL(18,2)
		SELECT 
            @max_field_qty = max_field_qty,
			@min_field_qty = min_field_qty
		FROM 
            @results 
		WHERE
            application_id = @application_id 
            AND product_id = @product_id 
            AND area_id = @area_id 
            AND sub_area_id = @sub_area_id 
            AND location_id = @location_id

		IF ((@build_qty > @max_field_qty) OR (@is_std = 1 AND @application_id = '10' AND @product_id = 'Y'))
			UPDATE @results
			SET 
                max_field_qty = @build_qty,
			    max_build_id = @build_id,
			    max_build_desc = @build_desc
			WHERE
                application_id = @application_id AND product_id = @product_id AND area_id = @area_id AND sub_area_id = @sub_area_id AND location_id = @location_id

	    IF (@build_qty < @min_field_qty)
			UPDATE @results
			SET
                min_field_qty = @build_qty,
			    min_build_id = @build_id,
			    min_build_desc = @build_desc
			WHERE
                application_id = @application_id AND product_id = @product_id AND area_id = @area_id AND sub_area_id = @sub_area_id AND location_id = @location_id

		IF (@is_std = 1)
		    UPDATE @results
			SET
                std_field_qty = @build_qty,
			    std_build_id = @build_id,
			    std_build_desc = @build_desc
			WHERE 
                application_id = @application_id AND product_id = @product_id AND area_id = @area_id AND sub_area_id = @sub_area_id AND location_id = @location_id
	END


	FETCH NEXT FROM b INTO @application_id, @product_id, @area_id, @sub_area_id, @location_id, @build_id, @is_std
END
CLOSE b
DEALLOCATE b

SELECT * FROM @results

GO

18285 - Managing Builder Logos
This story creates a way for us to manage builder logos. To implement that the following has been done:

1) new table - organization_image_categories
    *** There should be a new foriegn key to this table from organization_images that key needs to be created after this table is populated ***
    Done with redgate 
    -or-
    script: create organizations_images_categories.sql 
        creates and populates
2) populate new table 
    *** This is not needed if script was executed in step 1 ***
    script: populate organization_images_categories.sql
3) foriegn Key from organization_image
    script: FK_orgnaization_images_category.sql
3) new synonyms
    script: PRODUCTION new org image and org image category synonym.sql 
4) update procedure
    script: procedure [dbo].[vds_selCustomerLogo].sql
5) populate org images with builder logos 
    script: insert customer logos into org images.sql

=== If you are not wanting to execute these scrips ====
Script: SQL_Deployment.sql
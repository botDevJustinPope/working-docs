/*
    Script to upsert OIDC Configuration and Domain Mapping for Tollbrothers Okta
*/

WITH
    SourceRows
    AS
    (
        SELECT *
        FROM (VALUES
                ('b9ccd4dd-6b05-48b8-98b5-892acb598856', 'TollBrothers-Okta', '0oa17v0oaj5Y5aQZT2p8', 'HYk38hbEuVI_yBv7rx-vuH83nbj3VnGge86mZgCPzpP2erzamK6vXIIdWYHuhW2i', 'https://tollbrothers.okta.com/.well-known/openid-configuration', 'https://upload.wikimedia.org/wikipedia/commons/8/83/Okta_logo_%282023%29.svg', 'justinpo@buildontechnologies.com', GETDATE(), 'justinpo@buildontechnologies.com', GETDATE())
			) AS insertVals (
				Id, Name, ClientId, ClientSecret, DiscoveryUrl, LogoUrl, Author, CreateDate, Modifier, ModifiedDate
			)
    )

	MERGE dbo.OIDCConfiguration as tgt
	USING SourceRows as src
		ON tgt.Id = src.Id
	WHEN MATCHED THEN
		UPDATE SET
			tgt.Name = src.Name,
			tgt.ClientId = src.ClientId,
			tgt.ClientSecret = src.ClientSecret,
			tgt.DiscoveryUrl = src.DiscoveryUrl,
			tgt.LogoUrl = src.LogoUrl,
			tgt.Modifier = src.Modifier,
			tgt.ModifiedDate = src.ModifiedDate
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			Id, Name, ClientId, ClientSecret, DiscoveryUrl, LogoUrl, 
			Author, CreateDate, Modifier, ModifiedDate
		)
		VALUES (
			src.Id, src.Name, src.ClientId, src.ClientSecret, src.DiscoveryUrl, src.LogoUrl, 
			src.Author, src.CreateDate, src.Modifier, src.ModifiedDate
		);
go

select * from dbo.OIDCConfiguration where Id = 'b9ccd4dd-6b05-48b8-98b5-892acb598856';
GO

with DomainSourceRows as (
    select * from (
        values ('b9ccd4dd-6b05-48b8-98b5-892acb598856', 'tollbrothers.com', 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate())
    ) as insertVals (
        OIDCConfigurationId, DomainName, Author, CreateDate, Modifier, ModifiedDate
    )
)

	MERGE dbo.OIDCConfigurationDomainMapping as tgt
	USING DomainSourceRows as src
		ON tgt.OIDCConfigurationId = src.OIDCConfigurationId 
			AND LOWER(tgt.Domain) = LOWER(src.DomainName)
	WHEN MATCHED THEN
		UPDATE SET
			tgt.Modifier = src.Modifier,
			tgt.ModifiedDate = src.ModifiedDate
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			OIDCConfigurationId, Domain,
			Author, CreateDate, Modifier, ModifiedDate
		)
		VALUES (
			src.OIDCConfigurationId, src.DomainName,
			src.Author, src.CreateDate, src.Modifier, src.ModifiedDate
		);
go

select * from dbo.OIDCConfigurationDomainMapping where OIDCConfigurationId = 'b9ccd4dd-6b05-48b8-98b5-892acb598856';
go
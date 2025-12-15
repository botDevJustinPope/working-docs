use [VeoSolutions_Roger];
go

With BioRev_Provider as (
    select '90C925BB-C28B-4903-AB0B-FF75D0D4DADD' as [Id],
           'BioRev' as [Name],
           null as [Description],
           'BioRevProvider' as [Discriminator],
           'https://buildon.xdesign360.com/api/v1/visualizer/createScene' as [RenderUrl],
           'https://buildon.xdesign360.com/api/v1/visualizer/getOptions' as [ConfigurationUrl],
           'https://buildon.xdesign360.com/api/v1/visualizer/getOptions' as [RenderableProductUrl],
           60 as [RenderTimeout]
)
merge into dbo.VisualizationProvider as target 
using BioRev_Provider as source
on target.Id = source.Id
when not matched then
    insert ([Id], [Name], [Description], [Discriminator], [RenderUrl], [ConfigurationUrl], [RenderableProductUrl], [RenderTimeout])
    values (source.[Id], source.[Name], source.[Description], source.[Discriminator], source.[RenderUrl], source.[ConfigurationUrl], source.[RenderableProductUrl], source.[RenderTimeout])
when matched then
    update set 
        target.[Name] = source.[Name],
        target.[Description] = source.[Description],
        target.[Discriminator] = source.[Discriminator],
        target.[RenderUrl] = source.[RenderUrl],
        target.[ConfigurationUrl] = source.[ConfigurationUrl],
        target.[RenderableProductUrl] = source.[RenderableProductUrl],
        target.[RenderTimeout] = source.[RenderTimeout];
go
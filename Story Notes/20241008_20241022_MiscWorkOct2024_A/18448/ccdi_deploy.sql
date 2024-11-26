if not exists(select * from [CCDI_VEOSolutionsSecurity].dbo.roles_legacy where [name] = 'Sales Counselor (Scheduling Only)')
begin

    insert into [CCDI_VEOSolutionsSecurity].dbo.roles_legacy (role_id, [name], [numeric_role_id], [alpha_role_id])
    values ('76FC6A8E-D27E-4EEC-93A9-2ED4B1C10156', 'Sales Counselor (Scheduling Only)', 11, 'saleschedulerschedulingonly')

end

select * from [CCDI_VEOSolutionsSecurity].dbo.roles_legacy

if not exists(select * from [CCDI_VEOSolutionsSecurity].dbo.app_roles_legacy arl 
                        inner join [CCDI_VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = arl.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 

    insert into [CCDI_VEOSolutionsSecurity].dbo.app_roles_legacy ([app_id],[role_id],[name],[description],[author],[create_date],[modifier],[modified_date])
    select 
        'Scheduling',
        rl.role_id,
        rl.[name],
        '',
        'SETUP',
        getdate(),
        'SETUP',
        getdate()
    from [CCDI_VEOSolutionsSecurity].dbo.roles_legacy rl
    where rl.[name] = 'Sales Counselor (Scheduling Only)'

end

select * from [CCDI_VEOSolutionsSecurity].dbo.app_roles_legacy

if not exists(select * from [CCDI_VEOSolutions].dbo.scheduling_roles sr 
                        inner join [CCDI_VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = sr.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 
    insert into [CCDI_VeoSolutions].dbo.scheduling_roles (role_id, [author], [create_date], [modifier], [modified_date])
    select 
        role_id,
        'SEED',
        getdate(),
        'SEED',
        getdate()
    from CCDI_VEOSolutionsSecurity.dbo.roles_legacy
    where [name] = 'Sales Counselor (Scheduling Only)'
end

select * from [CCDI_VEOSolutions].dbo.scheduling_roles

if not exists(select * from [VEOSolutions].dbo.scheduling_roles sr 
                        inner join [VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = sr.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 
    begin TRY
        begin transaction;

            insert into [VeoSolutions].dbo.scheduling_roles (role_id, [author], [create_date], [modifier], [modified_date])
            select 
                role_id,
                'SEED',
                getdate(),
                'SEED',
                getdate()
            from VEOSolutionsSecurity.dbo.roles_legacy
            where [name] = 'Sales Counselor (Scheduling Only)'

        commit TRANSACTION;
            
                select 'VeoSolutions Stack'
    
                select * from [VeoSolutions].dbo.scheduling_roles
                
    end TRY
    begin catch 
        if @@trancount > 0        
            rollback transaction;
        print 'Error occurred on VeoSolutions.dbo.scheduling_roles, transaction rolled back, message: ' + ERROR_MESSAGE();
    end catch
end

if not exists(select * from [AFI_VEOSolutions].dbo.scheduling_roles sr 
                        inner join [AFI_VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = sr.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 
    begin TRY
        begin transaction;
            
            insert into [AFI_VEOSolutions].dbo.scheduling_roles (role_id, [author], [create_date], [modifier], [modified_date])
            select 
                role_id,
                'SEED',
                getdate(),
                'SEED',
                getdate()
            from AFI_VEOSolutionsSecurity.dbo.roles_legacy
            where [name] = 'Sales Counselor (Scheduling Only)'

        commit TRANSACTION;
            
                select 'AFI Stack'
    
                select * from [AFI_VEOSolutions].dbo.scheduling_roles

    end TRY
    begin catch 
        if @@trancount > 0        
            rollback transaction;
        print 'Error occurred on AFI_VEOSolutions.dbo.scheduling_roles, transaction rolled back, message: ' + ERROR_MESSAGE();
    end catch
end

if not exists(select * from [EPLAN_VEOSolutions].dbo.scheduling_roles sr 
                        inner join [EPLAN_VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = sr.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 
    begin TRY
        begin transaction;
        
            insert into [EPLAN_VEOSolutions].dbo.scheduling_roles (role_id, [author], [create_date], [modifier], [modified_date])
            select 
                role_id,
                'SEED',
                getdate(),
                'SEED',
                getdate()
            from EPLAN_VEOSolutionsSecurity.dbo.roles_legacy
            where [name] = 'Sales Counselor (Scheduling Only)'

        commit TRANSACTION;
        
            select 'EPLAN Stack'

            select * from [EPLAN_VeoSolutions].dbo.scheduling_roles

    end TRY
    begin catch 
        if @@trancount > 0        
            rollback transaction;
        print 'Error occurred on EPLAN_VEOSolutions.dbo.scheduling_roles, transaction rolled back, message: ' + ERROR_MESSAGE();
    end catch
end

if not exists(select * from [CCDI_VEOSolutions].dbo.scheduling_roles sr 
                        inner join [CCDI_VEOSolutionsSecurity].dbo.roles_legacy rl on rl.role_id = sr.role_id
                        where rl.[name] = 'Sales Counselor (Scheduling Only)')
begin 
    begin TRY
        begin transaction;
        
            insert into [CCDI_VeoSolutions].dbo.scheduling_roles (role_id, [author], [create_date], [modifier], [modified_date])
            select 
                role_id,
                'SEED',
                getdate(),
                'SEED',
                getdate()
            from CCDI_VeoSolutionsSecurity.dbo.roles_legacy
            where [name] = 'Sales Counselor (Scheduling Only)'

        commit TRANSACTION;
        
            select 'CCDI Stack'

            select * from [CCDI_VeoSolutions].dbo.scheduling_roles

    end TRY
    begin catch 
        if @@trancount > 0        
            rollback transaction;
        print 'Error occurred on CCDI_VeoSolutions.dbo.scheduling_roles, transaction rolled back, message: ' + ERROR_MESSAGE();
    end catch
end

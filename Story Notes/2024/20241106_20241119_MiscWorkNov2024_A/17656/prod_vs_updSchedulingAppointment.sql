USE [EPLAN_VEOSolutions]
GO
/****** Object:  StoredProcedure [dbo].[vs_updSchedulingAppointment]    Script Date: 11/13/2024 9:28:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[vs_updSchedulingAppointment]
@appointment_id uniqueidentifier,
@buyer_profile_id uniqueidentifier,
@account_org_id uniqueidentifier,
@appointment_template_id uniqueidentifier = null,
@appointment_type int,
@appointment_duration int,
@is_scheduled bit = 0 ,
@is_conflict bit = 0,
@schedule_user_id uniqueidentifier = null,
@appointment_date datetime = null,
@start_time time = null,
@end_time time = null,
@location_id uniqueidentifier = null,
@appointment_label varchar(200)='',
@appointment_note varchar(200) = '',
@is_virtual bit = 0,
@in_design bit = 0,
@design_type uniqueidentifier = null,
@confirmation_status int = 0,
@is_provisional bit = 0,
@provisional_scheduler_user_id uniqueidentifier = null,
@security_token uniqueidentifier = NULL,
@stamp TIMESTAMP = null
as

declare @active_user_id varchar(100)
set @active_user_id = dbo.ef_getUserEmailFromSecurityToken(@security_token)

declare @sender_id uniqueidentifier
set @sender_id = null
select  @sender_id = [user_id] from VeoSolutionsSecurity_users_login_sessions where security_token = @security_token

-- validate
if (@is_scheduled = 1 and @schedule_user_id is not null)
begin
	DECLARE @result INT
	EXEC @result = dbo.vs_validateSchedulingAppointment @appointment_id, @buyer_profile_id, @account_org_id,  @schedule_user_id , @appointment_date, @start_time, @end_time, @stamp

	IF (@result <> 0)
	BEGIN
		-- custom errors are abs(return code) + 50100
		DECLARE @custom_error INT
		SET @custom_error = ABS(@result) + 50100;
		RAISERROR(@custom_error,16,1);
		return @result
	END
end

--select * from scheduling_appointments order by modified_date desc
-- select * from z_scheduling_appointments where appointment_id = 'F27538B5-B094-41C6-93AE-B393897B00CB' order by z_time desc
--select * from scheduling_appointment_tasks

declare @action varchar(20)
set @action = ''

if (@appointment_id = '00000000-0000-0000-0000-000000000000')
begin
	set @appointment_id = newid()
end

if not exists (select appointment_id from scheduling_appointments where appointment_id = @appointment_id )
begin

	-- buyer 'extra' appointments are created, but not scheduled.
	if (@is_scheduled = 1)
		set @action = 'Scheduled'

	declare @newid uniqueidentifier

	insert into scheduling_appointments (
		appointment_id,
		buyer_profile_id,
		account_org_id,
		appointment_template_id,
		appointment_type,
		appointment_duration,
		is_scheduled,
		is_conflict,
		schedule_user_id,
		appointment_date,
		start_time,
		end_time,
		location_id,
		appointment_label,
		appointment_note,
		author,
		create_date,
		modifier,
		modified_date,
		is_virtual,
		in_design,
		design_type,
		confirmation_status,
		is_provisional
	)
	values
	(
		@appointment_id,
		@buyer_profile_id,
		@account_org_id,
		@appointment_template_id,
		@appointment_type,
		@appointment_duration,
		@is_scheduled,
		@is_conflict,
		@schedule_user_id,
		@appointment_date ,
		@start_time ,
		@end_time ,
		@location_id ,
		@appointment_label,
		@appointment_note,
		@active_user_id,
		GETDATE(),
		@active_user_id,
		GETDATE(),
		@is_virtual,
		@in_design,
		@design_type,
		@confirmation_status,
		@is_provisional
	)
end
else -- udpate case
begin
	-- select * from scheduling_appointments where appointment_date is null
	if ( (@appointment_date is not null) and exists(select appointment_id from scheduling_appointments where appointment_id = @appointment_id and appointment_date is null) )
	set @action = 'Scheduled'

	if (@action = '')
	begin
	if ( (@appointment_date is not null) and exists(select appointment_id from scheduling_appointments where appointment_id = @appointment_id and appointment_date is not null and appointment_date <> @appointment_date) )
	set @action = 'Rescheduled'
	end

	-- canceled is handled in another proc
	if (@action = '')
	begin
	if ( (@appointment_date is not null) and exists(select appointment_id from scheduling_appointments where appointment_id = @appointment_id and appointment_date is not null and schedule_user_id <> @schedule_user_id) )
	set @action = 'Reassigned'
	end

	-- adjusted start time
	if (@action = '')
	begin
	if ( (@appointment_date is not null) and exists(select appointment_id from scheduling_appointments where appointment_id = @appointment_id and appointment_date is not null and appointment_date = @appointment_date and start_time <> @start_time ) )
	set @action = 'Changed Start Time'
	end

	-- changed duration
	if (@action = '')
	begin
	if ( (@appointment_date is not null) and exists(select appointment_id from scheduling_appointments where appointment_id = @appointment_id and appointment_date is not null and appointment_date = @appointment_date and start_time = @start_time and end_time <> @end_time  ) )
	set @action = 'Changed Duration'
	end

	update
		scheduling_appointments
	set
		schedule_user_id = @schedule_user_id,  -- reassign? todo: make a reassign proc
		--appointment_type = @appointment_type, -- change appointment type?  probably not
		--buyer_profile_id = @buyer_profile_id, -- never?
		--appointment_task_id = @appointment_task_id, -- never?
		is_scheduled = @is_scheduled,
		is_conflict = @is_conflict,
		appointment_date = @appointment_date, -- reschedule
		start_time = @start_time,
		end_time = @end_time,
		location_id = @location_id,
		appointment_label = @appointment_label,
		appointment_note = @appointment_note,
		modifier = @active_user_id,
		modified_date = GETDATE(),
		is_virtual = @is_virtual,
		in_design = @in_design,
		design_type = @design_type,
		confirmation_status = @confirmation_status,
		is_provisional = @is_provisional,
		provisional_scheduler_user_id = @provisional_scheduler_user_id 
	where
		appointment_id = @appointment_id
end


-- update buyer history
if (@action <> '')
begin 	
	declare @message varchar(300)
	select @message = dbo.ef_selSchedulingAppointmentSystemNote(@appointment_id, @action);

	-- select * from scheduling_messages order by create_date desc
	-- select * from scheduling_message_types
	insert into
	scheduling_messages
	(message_id, message_type, message_status, is_read, message_title, message_priority, [user_id], buyer_profile_id, appointment_id, sender_id, message_body, completion_date)
	values
	(newid(), 0, 0, 0, @action, 0, @schedule_user_id, @buyer_profile_id, @appointment_id, @sender_id, @message, getdate())

	-- update IS ACTIVE
	exec vs_updSchedulingBuyerActiveBasedOnAppointments @buyer_profile_id, @security_token
end
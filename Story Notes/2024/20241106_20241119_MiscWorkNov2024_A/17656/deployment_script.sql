
/*
*** 'DEV' DBS ***

USE [VeoSolutions_DEV]
use [VeoSolutions_QA]
use [VeoSolutions_Staging]
use [VeoSolutions_Preview]

*** Prod DBS ***

use [AFI_VEOSolutions]
use [CCDI_VEOSolutions]
use [EPLAN_VEOSolutions]
use [VEOSolutions]

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Robert Hobbs
 Create date:   04/23/13
 Description:	Builds a system generated buyer note
 =============================================
 Modifier:		Justin Pope
 Modified date: 11/13/24
 Description:	17656 - Provitional Note for Appointments
 =============================================
 */
ALTER FUNCTION [dbo].[ef_selSchedulingAppointmentSystemNote]
(
	@appointment_id uniqueidentifier, 
	@action varchar(30),
    @is_provisional bit = 0
)
RETURNS varchar(300)
AS
BEGIN
    /*
	testing 
	select * from scheduling_appointments where is_scheduled = 1 
	select * from scheduling_users
	declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Scheduled'); select @note;
	declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Changed Start Time'); select @note;
	declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Changed Duration'); select @note;
    */
	
	declare @note varchar(300) 
	set @note = '' 

	declare @appt_ord varchar(10)
	declare @date varchar(25) 
	declare @time varchar(25) 
	declare @designer varchar(100) 
	declare @duration int

	-- select * from scheduling_appointment_types
	select 
		@appt_ord = at.abbrev, 
		@date = convert(varchar, a.appointment_date,107), 
		@time = convert(varchar(15), a.start_time, 100), 
		@designer = (u.first_name + ' ' + u.last_name), 
		@duration = a.appointment_duration
	from 
		scheduling_appointments a 
		join scheduling_appointment_types at on at.appointment_type = a.appointment_type 
		join scheduling_users u on u.user_id = a.schedule_user_id
	where
		a.appointment_id = @appointment_id 

    declare @appointment varchar(50) = 'appt';
    if @is_provisional = 1
    begin
        set @appointment = 'provisional appt';
    end

	declare @note_1 varchar(150) = '<action> <appt_ord> <appointment> ';
	declare @note_2 varchar(150) = 'for <date> @ <time> w/<designer>';
	declare @note_3 varchar(150) = 'on <date> w/<designer> to <time>';
	declare @note_4 varchar(150) = 'on <date> w/<designer> to <duration>h';

	if @action in ( 'Scheduled' , 'Rescheduled', 'Reassigned') 
	begin 
		set @note = @note_1 + @note_2
	end 

	if @action = 'Changed Start Time' 
	begin 
		set @action = @action + ' for';
		set @note = @note_1 + @note_3;
	end 

	if @action = 'Changed Duration'
	begin 
		set @action = @action + ' for';
		set @note = @note_1 + @note_4;
	end 



	return replace(replace(replace(replace(replace(replace(replace(@note, '<duration>', convert(varchar(3), @duration/60)), 
																		  '<designer>', @designer), 
																		  '<time>', @time), 
																		  '<date>', @date), 
																		  '<appointment>', @appointment), 
																		  '<appt_ord>', @appt_ord), 
																		  '<action>', @action)

END;
go

/*
 =============================================
 Author:		n/a
 Create date:   n/a
 Description:	Update Scheduling Appointment
 =============================================
 Modifier:		Justin Pope
 Modified date: 11/13/24
 Description:	17656 - Provitional Notes for Appointments
 =============================================
*/
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
    begin 
    declare @active_user_id varchar(100)
    set @active_user_id = dbo.ef_getUserEmailFromSecurityToken(@security_token)

    declare @sender_id uniqueidentifier
    set @sender_id = null
    select @sender_id = [user_id]
    from VeoSolutionsSecurity_users_login_sessions
    where security_token = @security_token

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

    if not exists (select appointment_id
    from scheduling_appointments
    where appointment_id = @appointment_id )
    begin

        -- buyer 'extra' appointments are created, but not scheduled.
        if (@is_scheduled = 1)
            set @action = 'Scheduled'

        declare @newid uniqueidentifier

        insert into scheduling_appointments
            (
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
        if ( (@appointment_date is not null) and exists(select appointment_id
            from scheduling_appointments
            where appointment_id = @appointment_id and appointment_date is null) )
        set @action = 'Scheduled'

        if (@action = '')
        begin
            if ( (@appointment_date is not null) and exists(select appointment_id
                from scheduling_appointments
                where appointment_id = @appointment_id and appointment_date is not null and appointment_date <> @appointment_date) )
        set @action = 'Rescheduled'
        end

        -- canceled is handled in another proc
        if (@action = '')
        begin
            if ( (@appointment_date is not null) and exists(select appointment_id
                from scheduling_appointments
                where appointment_id = @appointment_id and appointment_date is not null and schedule_user_id <> @schedule_user_id) )
        set @action = 'Reassigned'
        end

        -- adjusted start time
        if (@action = '')
        begin
            if ( (@appointment_date is not null) and exists(select appointment_id
                from scheduling_appointments
                where appointment_id = @appointment_id and appointment_date is not null and appointment_date = @appointment_date and start_time <> @start_time ) )
        set @action = 'Changed Start Time'
        end

        -- changed duration
        if (@action = '')
        begin
            if ( (@appointment_date is not null) and exists(select appointment_id
                from scheduling_appointments
                where appointment_id = @appointment_id and appointment_date is not null and appointment_date = @appointment_date and start_time = @start_time and end_time <> @end_time  ) )
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
        select @message = dbo.ef_selSchedulingAppointmentSystemNote(@appointment_id, @action, @is_provisional);

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
end;
go
USE [VeoSolutions_DEV]
GO

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
CREATE FUNCTION [dbo].[ef_selSchedulingAppointmentSystemNote]
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
	else if @action = 'Changed Start Time' 
	begin 
		set @action = @action + ' for';
		set @note = @note_1 + @note_3;
	end 
	else if @action = 'Changed Duration'
	begin 
		set @action = @action + ' for';
		set @note = @note_1 + @note_4;
	end 

	return replace(replace(replace(replace(replace(replace(replace(@note, '<action>', @action), 
																		  '<appt_ord>', @appt_ord), 
																		  '<appointment>', @appointment), 
																		  '<date>', @date), 
																		  '<time>', @time), 
																		  '<designer>', @designer), 
																		  '<duration>', convert(varchar(3), @duration/60))

END;
GO
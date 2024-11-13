use [VeoSolutions];
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Hobbs
-- Create date: 04/23/13
-- Description:	Builds a system generated buyer note
-- =============================================
CREATE or ALTER FUNCTION [dbo].[ef_selSchedulingAppointmentSystemNote]
(
	@appointment_id uniqueidentifier, 
	@action varchar(20) 
)
RETURNS varchar(300)
AS
BEGIN

	-- testing 
	-- select * from scheduling_appointments where is_scheduled = 1 
	-- select * from scheduling_users
	-- declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Scheduled'); select @note;
	-- declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Changed Start Time'); select @note;
	-- declare @note varchar(300); select @note =  dbo.ef_selSchedulingAppointmentSystemNote('0FB1BA09-40A2-411F-85BF-0A13EB573366', 'Changed Duration'); select @note;
	-- 
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


	if @action in ( 'Scheduled' , 'Rescheduled', 'Reassigned') 
	begin 
		set @note = @action + @appt_ord + ' appt for ' + @date + ' @ ' + @time + ' w/' + @designer 
	end 

	if @action = 'Changed Start Time' 
	begin 
		set @note = 'Changed Start Time for ' + @appt_ord + ' appt on' + @date  + ' w/' + @designer + ' to ' + @time 
	end 

	if @action = 'Changed Duration'
	begin 
	
		set @note = 'Changed Duration for ' + @appt_ord + ' appt on' + @date  + ' w/' + @designer + ' to ' +  convert(varchar(3), @duration/60)  + 'h'
	end 



	return @note 

END
GO

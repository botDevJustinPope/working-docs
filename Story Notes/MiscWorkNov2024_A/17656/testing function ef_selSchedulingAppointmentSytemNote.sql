use [VeoSolutions_DEV];
go

declare @actions table ( [action_str] varchar(30), [is_provisional] bit);
insert into @actions 
values ('Scheduled',            0),
       ('Rescheduled',          0),
       ('Reassigned',           0),
       ('Changed Start Time',   0),
       ('Changed Duration',     0),
       ('Scheduled',            1),
       ('Rescheduled',          1),
       ('Reassigned',           1),
       ('Changed Start Time',   1),
       ('Changed Duration',     1);


select 
    a.appointment_id,
    b.action_str,
    [dbo].[ef_selSchedulingAppointmentSystemNote](a.appointment_id, b.action_str, b.is_provisional) as [message]
from (
    select top 5 
        a.appointment_id
    from dbo.scheduling_appointments a 
		join dbo.scheduling_appointment_types [at] on at.appointment_type = a.appointment_type 
		join dbo.scheduling_users u on u.user_id = a.schedule_user_id
    order by NEWID()) as a,
    @actions as b
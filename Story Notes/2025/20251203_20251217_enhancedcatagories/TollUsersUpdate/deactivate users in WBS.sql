declare @excludeUsers table (email nvarchar(255));
insert into @excludeUsers (email) values
('jtran@tollbrothers.com'),
('SGabriel@tollbrothers.com'),
('sbeach@tollbrothers.com'),
('hsmith@tollbrothers.com'),
('cbailey@tollbrothers.com');
 
select 
    count(*) as [count],
    [status]
from (
 select 
    u.[user_id],
    case 
        when u.[active] = 1 then 'Active'
        else 'Inactive' end 
        as [status]
from [VEOSolutionsSecurity].dbo.users u
 where email like '%@tollbrothers.com'
/* and email not in (select email from @excludeUsers)*/) i 
 group by [status];

begin TRANSACTION

update [VEOSolutionsSecurity].dbo.users 
set active = 0 
where email like '%@tollbrothers.com'
and email not in (select email from @excludeUsers)
and active = 1;

 COMMIT TRANSACTION

 
select 
    count(*) as [count],
    [status]
from (
 select 
    u.[user_id],
    case 
        when u.[active] = 1 then 'Active'
        else 'Inactive' end 
        as [status]
from [VEOSolutionsSecurity].dbo.users u
 where email like '%@tollbrothers.com'
/* and email not in (select email from @excludeUsers)*/) i 
 group by [status];
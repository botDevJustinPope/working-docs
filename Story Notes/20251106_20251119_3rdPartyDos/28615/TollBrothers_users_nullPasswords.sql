update dbo.users 
set temporary_password = null,
    password = null 
where [email] like '%@tollbrothers.com';


select * from dbo.users where [email] like '%@tollbrothers.com'
update dbo.users 
set temporary_password = null,
    password = null 
where [email] = 'jpope@tollbrothers.com';


select * from dbo.users where [email] = 'jpope@tollbrothers.com'
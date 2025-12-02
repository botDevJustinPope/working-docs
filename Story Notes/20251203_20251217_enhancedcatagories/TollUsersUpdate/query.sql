declare  @TollUsers table (
    userEmail varchar(255) not null,
    FirstName VARCHAR(100) not null,
    LastName VARCHAR(100) not null
);
insert into @TollUsers (FirstName, LastName, userEmail) values
('Adam',	'Bautista',	'abautista@tollbrothers.com'),
('Amber',	'Neeley',	'aneeley@tollbrothers.com'),
('Anabel',	'Flores',	'aflores@tollbrothers.com'),
('Ann',	'Tabor',	'atabor@tollbrothers.com'),
('Anne Marie',	'Hohensee',	'ahohensee@tollbrothers.com'),
('Atif',	'Iqbal',	'aiqbal@tollbrothers.com'),
('Chrissy',	'Bailey',	'CBailey@tollbrothers.com'),
('Daniel',	'Silva',	'dsilva@tollbrothers.com'),
('David',	'Vigil',	'DVigil@tollbrothers.com'),
('Debbie',	'Compton',	'dcompton@tollbrothers.com'),
('Denise',	'Ramirez',	'dzuniga@tollbrothers.com'),
('Desiree',	'Martinez',	'DMartinez@tollbrothers.com'),
('Dionna',	'LaMarque',	'dlamarque@tollbrothers.com'),
('Fredrick',	'Jones',	'fjones@tollbrothers.com'),
('Haley',	'Smith',	'hsmith@tollbrothers.com'),
('Holly',	'Williams',	'hwilliams@tollbrothers.com'),
('Jason',	'Haugh',	'jhaugh@tollbrothers.com'),
('Jeanne',	'Tran',	'jtran@tollbrothers.com'),
('John',	'Courtney',	'jcourtney@tollbrothers.com'),
('Julianne',	'Cashdollar',	'JCashdollar@tollbrothers.com'),
('Laurie',	'Tatum',	'ltatum@tollbrothers.com'),
('Lidia',	'Campos',	'acampos@tollbrothers.com'),
('Linda',	'Howland',	'lhowland@tollbrothers.com'),
('Neva',	'Nice',	'nnice@tollbrothers.com'),
('Oksana',	'Sudilovskaya',	'osudilovskaya@tollbrothers.com'),
('Paula',	'LaGrappe',	'plagrappe@tollbrothers.com'),
('Roger',	'Diaz',	'RDiaz@tollbrothers.com'),
('Samantha',	'Gabriel',	'sgabriel@tollbrothers.com'),
('Samis',	'Nagel',	'snagel@tollbrothers.com'),
('Sarah',	'Perez',	'SPerez@tollbrothers.com'),
('Scott',	'Trolio',	'strolio@tollbrothers.com'),
('Scott',	'Stewart',	'sstewart@tollbrothers.com'),
('Shawna',	'Beach',	'sbeach@tollbrothers.com'),
('Sheveta',	'Thukral',	'sthukral@tollbrothers.com'),
('Shirley',	'Long',	'slong3@tollbrothers.com'),
('Talvin',	'Wrighton',	'TWrighton@tollbrothers.com'),
('Tameka',	'Roche',	'troche@tollbrothers.com'),
('Vanessa',	'Skuter',	'vskuter@tollbrothers.com'),
('Veronica',	'Ramirez Gaecke',	'vramirezgaecke@tollbrothers.com'),
('Victoria',	'Koenig',	'vkoenig@tollbrothers.com'),
('Amneris',	'Palacios',	'apalacios1@tollbrothers.com'),
('Jay',	'Brown',	'jbrown5@tollbrothers.com'),
('Juan',	'Panganibano',	'jpanganiban@tollbrothers.com'),
('Thomas',	'Jacobsen',	'tjacobsen@tollbrothers.com'),
('James', 'Suhr', 'jsuhr@tollbrothers.com'),
('Rachel', 'Cortez', 'rcortez@tollbrothers.com'),
('Kolby', 'Bryant', 'kbryant@tollbrothers.com'),
('Robbie', 'Demaret', 'rdemaret@tollbrothers.com'),
('Jen', 'Moline', 'jmoline@tollbrothers.com'),
('Rama', 'Paramkusham', 'rparamkusham@tollbrothers.com'),
('Anisha', 'Langston', 'alangston@tollbrothers.com'),
('Seth', 'Vieregge', 'svieregge1@tollbrothers.com'),
('Tom', 'Laidlaw', 'tlaidlaw@tollbrothers.com'),
('Erik', 'Petersen', 'epetersen@tollbrothers.com'),
('Masuma', 'Kaka', 'mkaka@tollbrothers.com'),
('Amber', 'Thompson', 'athompson@tollbrothers.com'),
('Avisha', 'Patel', 'apatel1@tollbrothers.com'),
('Blake', 'Fletcher', 'bfletcher@tollbrothers.com'),
('Meryn', 'Shannon', 'mshannon@tollbrothers.com'),
('Leslie', 'Derkach', 'lderkach@tollbrothers.com'),
('Teri', 'Clark', 'tclark@tollbrothers.com'),
('Waylon', 'Vessell', 'wvessell@tollbrothers.com'),
('Heather', 'Leonard', 'hleonard@tollbrothers.com'),
('Brooklynn', 'Walker', 'dwalker@tollbrothers.com'),
('Heather', 'Newman', 'hnewman@tollbrothers.com'),
('Caitlin', 'Lanning', 'clanning@tollbrothers.com'),
('Mindy', 'Derby', 'mderby@tollbrothers.com'),
('Clark', 'Dunklin', 'adunklin@tollbrothers.com'),
('Savannah', 'Richard', 'srichard@tollbrothers.com'),
('Chris', 'Dunklin', 'cdunklin@tollbrothers.com'),
('David', 'Banks', 'dbanks@tollbrothers.com'),
('Jane', 'Kennedy', 'jkennedy@tollbrothers.com'),
('Veronica', 'Zimmerman', 'vzimmerman@tollbrothers.com'),
('John', 'Callender', 'jcallender@tollbrothers.com'),
('McKenna', 'Fox', 'mfox1@tollbrothers.com'),
('Scott', 'Maxwell', 'smaxwell1@tollbrothers.com'),
('Sarah', 'Haskell', 'shaskell@tollbrothers.com'),
('Patty', 'Brown', 'pbrown@tollbrothers.com'),
('Jennifer', 'Pepper', 'jpepper@tollbrothers.com'),
('Steven', 'Vieregge', 'svieregge@tollbrothers.com'),
('Shileya', 'Witcher', 'switcher@tollbrothers.com'),
('Ann', 'Villarosa', 'avillarosa@tollbrothers.com'),
('Adrienne', 'Cole', 'acole2@tollbrothers.com'),
('Chanci', 'Nicks', 'cnicks@tollbrothers.com'),
('BJ', 'Voldan', 'bvoldan@tollbrothers.com'),
('Kathey', 'Kerr', 'kkerr@tollbrothers.com'),
('Bel', 'Lozano', 'blozano@tollbrothers.com'),
('Judy', 'Davison', 'jdavison@tollbrothers.com'),
('Baylee', 'Barnes', 'bbarnes@tollbrothers.com'),
('Gina', 'Vance', 'gvance@tollbrothers.com'),
('Maritza', 'Lopez', 'mlopez3@tollbrothers.com'),
('Kevin', 'Boyett', 'kboyett@tollbrothers.com'),
('Spencer', 'Parchman', 'sparchman@tollbrothers.com'),
('Rhonda', 'Moorefield', 'rmoorefield@tollbrothers.com'),
('Donna', 'Fitzgerald', 'dfitzgerald@tollbrothers.com'),
('Ashlee', 'Austin', 'aaustin@tollbrothers.com'),
('Crystal', 'Halsell', 'chalsell@tollbrothers.com');

declare @Users table (
    UserID UNIQUEIDENTIFIER not null,
    Stack VARCHAR(100) not null,
    FirstName VARCHAR(100) not null,
    LastName VARCHAR(100) not null,
    EmailAddress varchar(255) not null
);

insert into @Users (FirstName, LastName, EmailAddress, UserID, Stack) 
select 
tu.FirstName,
tu.LastName,
u.email,
u.[user_id],
'WBS'
from @TollUsers tu 
inner join [VEOSolutionsSecurity].[dbo].[Users] u on tu.userEmail = u.email 

insert into @Users (FirstName, LastName, EmailAddress, UserID, Stack )
select 
tu.FirstName,
tu.LastName,
u.email,
u.[user_id],
'EPLAN'
from @TollUsers tu
inner join [EPLAN_VEOSolutionsSecurity].[dbo].[Users] u on tu.userEmail = u.email

/*
select * from @Users

select count(*) as WBSCount from @Users where Stack = 'WBS'
select count(*) as EPLANCount from @Users where Stack = 'EPLAN'
*/

select 
tu.userEmail, WBSUser.UserID as [WBSUserID], EPLANUser.UserID as [EPLANUserID]
from @TollUsers tu 
outer apply ( select top 1 u.UserID from @users u where tu.userEmail = u.EmailAddress and u.Stack = 'WBS') as WBSUser
outer apply ( select top 1 u.UserID from @users u where tu.userEmail = u.EmailAddress and u.Stack = 'EPLAN') as EPLANUser

select * from @users where EmailAddress in ('alangston@tollbrothers.com', 'cdunklin@tollbrothers.com')
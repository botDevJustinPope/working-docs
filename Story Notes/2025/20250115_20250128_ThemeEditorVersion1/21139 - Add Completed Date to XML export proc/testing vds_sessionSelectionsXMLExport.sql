/*
	Echelon can not pull a session if the session is not complete
*/
use [VeoSolutions_DEV];
go


drop table if exists #temp;
go

select top 5
	[SESSION_ID],
	[completed_date],
	[first_completed_date]
into #temp
from dbo.account_organization_user_profile_plan_catalog_sessions
where completed_date > '2024-01-01'

declare @session_id uniqueidentifier;
declare @completed_date as datetime;
declare @first_completed_date as datetime;
declare @xml xml;

declare cur cursor for 
select [SESSION_ID], [completed_date], [first_completed_date] from #temp;
open cur;
fetch next from cur into @session_id, @completed_date, @first_completed_date;
while @@FETCH_STATUS = 0
begin

	exec dbo.vds_sessionSelectionsXMLExport @session_id, @xml output;

	select 
		@xml as [XML Export],
		@session_id as [Session ID], 
		@completed_date as [Completed Date], 
		@first_completed_date as [First Completed Date];

	fetch next from cur into @session_id, @completed_date, @first_completed_date;
end
close cur;
deallocate cur;
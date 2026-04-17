use [VeoSolutions];
go

/*
Test - 1
org: Taylor Morrison - Houston
community: Trillium 60
series: Signature
plan: Jade

Test - 2
org: Taylor Morrison - Austin
community: Travisso 80
series: Reflecttions
plan: Arabella
*/

set statistics io on;
go
set statistics time on;
go

set showplan_xml on
go

execute [dbo].[vds_selNonSessionEstimatedProductSearchOptions] '01234567-89AB-CDEF-0000-123456789ABC', 'BAB32B7E-3ADA-497C-862E-E5083971CC59', '1A53AE0E-7AEE-456E-8F64-590272FC11C0', 'Travisso 80', 'Reflections', 'Arabella', '', 0;
go

set showplan_xml off
go
/*************************************************************************************************************

									Useful Bit of Code for SQL Server

*************************************************************************************************************/


--Date Difference
--Use to find the difference between two dates in years.  It is particularly helpful when calculating age.

declare @testDate dateTime;
set @testDate = cast('1/17/2016' as datetime);

select (CONVERT(decimal(12,4),CONVERT(char(8),@testDate,112))-CONVERT(char(8),GETDATE(),112))/10000




--Find data type of various columns. Yes, you could just look at the table explorer, but sometimes it is nice to use code!
--enter search terms in where statement
select 
	o.name as [Table]
	,c.name as [Column]
	,t.name as dataType
	,c.max_length -- varchar(max_length)
	,c.precision -- decimal(precision,scale)
	,c.scale 
from sys.columns c 
join sys.objects o on c.object_id=o.object_id 
join sys.types t on t.system_type_id=c.system_type_id or t.user_type_id=c.user_type_id
where 1=1
	and o.name like '%graduation%'
	and c.name like '%cohortYearNCLB%'



--Find Column
--If you don't know the table structures perfectly this will help you find columns whose name contains the SearchTerm
--Replace the word SearchTerm below
select o.name,c.name 
from sys.columns c inner join sys.objects  o on c.object_id=o.object_id 
and o.type = 'U'
and CHARINDEX('SearchTerm', c.name)>=1




--Drop temp table if exists
--Can also be used as a model to check for existence of other tables, etc
IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #Results


--List all tables and columns in the database
select 
	d.[name] as [database]
	, s.name as [schema]
	, o.name as [table]
	,c.name as [column]
	,t.name as dataType
	,c.max_length -- varchar(max_length)
	,c.precision -- decimal(precision,scale)
	,c.scale 

from sys.columns c 
inner join sys.objects  o on c.object_id=o.object_id and o.type = 'U'
join sys.schemas s on s.schema_id=o.schema_id
join sys.types t on t.system_type_id=c.system_type_id or t.user_type_id=c.user_type_id
join sys.databases d on d.database_id <> 1 --I think this excludes the master database but I can't remember :-S
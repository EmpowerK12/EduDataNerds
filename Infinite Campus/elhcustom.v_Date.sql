/*This view list each date from 2004 to 2024
Columns are included for Academic Dates.
Can be joined to the dbo.day table for instructional day information
*/

--CREATE VIEW elhcustom.v_Date AS
--ALTER VIEW elhcustom.v_Date AS

SELECT *
, CASE WHEN MONTH(date) >= 7 THEN YEAR(date) + 1 ELSE YEAR(Date) END AS AcademicEndYear
, CASE WHEN MONTH(date) >= 7 THEN MONTH(date) - 6 ELSE MONTH(Date)+6 END AS AcademicMonthNumber
, MonthName AS AcademicMonthName
, CASE WHEN dt.Week >= 28 THEN dt.Week - 27 ELSE dt.Week + 26 END AS AcademicWeekNumber
, t.name AS termName
 FROM elhcustom.datestable dt
 LEFT JOIN (
	SELECT t.name
		, c.endYear 
		, MIN(t.startDate) AS startDate
		, MAX(t.endDate) AS endDate

	FROM term t
	JOIN TermSchedule ts ON ts.termScheduleID = t.termScheduleID
	JOIN ScheduleStructure ss ON ss.structureID = ts.structureID
	JOIN Calendar c ON c.calendarID = ss.calendarID
	WHERE t.name IN ('Q1', 'Q2', 'Q3', 'Q4')
	GROUP BY t.name
		, c.endYear 
) t 
	ON t.startDate <= dt.Date
	AND t.endDate >= dt.Date
	AND t.endYear = (CASE WHEN MONTH(dt.date) >= 7 THEN YEAR(dt.date) + 1 ELSE YEAR(dt.Date ) END)
 WHERE dt.date >= '2004-08-01' AND dt.date < '2025-01-01'


 

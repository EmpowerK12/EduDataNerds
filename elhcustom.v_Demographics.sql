--ALTER VIEW elhcustom.v_Demographics AS
/*
This view creates a long table with one row for each demographic data point for each student for each calendar. 
This view should be joined to elhcustom.v_student with a many-to-one relationship on personCalendarID.
*/

SELECT personID
	, calendarID
	, PersonCalendarID
	, 'All Students' AS [Group]
	, 0 AS GroupSort
	, 'All Students' AS GroupType
	, 1 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, CASE 
		WHEN s.sped = 'Y' THEN 'IEP'
		WHEN s.Is504 = 'Y' THEN '504'
		ELSE 'No IEP'
		END AS [Group]
	, CASE 
		WHEN s.sped = 'Y' THEN 1
		WHEN s.Is504 = 'Y' THEN 2
		ELSE 3
		END AS [GroupSort]
	, 'SPED Status' AS GroupType
	, 2 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, CASE 
		WHEN s.LEP = 'Y' THEN 'ELL'
		WHEN s.LEPMonitored <> 'N' THEN 'ELL Monitored'
		ELSE 'Not ELL'
		END AS [Group]
	, CASE 
		WHEN s.LEP = 'Y' THEN 4
		WHEN s.LEPMonitored <> 'N' THEN 5
		ELSE 6
		END AS [GroupSort]
	, 'ELL Status' AS GroupType
	, 3 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, CASE s.RaceEthnicity
		WHEN 'Black' THEN s.RaceEthnicity
		WHEN 'Hispanic'  THEN s.RaceEthnicity
		WHEN 'White'  THEN s.RaceEthnicity
		WHEN 'Multiple'  THEN s.RaceEthnicity
		ELSE 'Other'
		END AS [Group]
	, CASE s.RaceEthnicity
		WHEN 'Black' THEN 7
		WHEN 'Hispanic'  THEN 8
		WHEN 'White'  THEN 9
		WHEN 'Multiple'  THEN 10
		ELSE 11
		END AS [GroupSort]
	, 'Race/Ethnicity' AS GroupType
	, 4 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, CASE s.atRisk
		WHEN 1 THEN 'At Risk'
		ELSE 'Not At Risk'
		END AS [Group]
	, CASE s.atRisk
		WHEN 1 THEN 12
		ELSE 13
		END AS [GroupSort]
	, 'At Risk Status' AS GroupType
	, 5 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, s.gender AS [Group]
	, CASE WHEN s.gender = 'F' THEN 14 ELSE 15 END AS [GroupSort]
	, 'Gender' AS GroupType
	, 6 AS GroupTypeSort
FROM elhcustom.v_student s

UNION 
SELECT personID
	, calendarID
	, PersonCalendarID
	, s.grade AS [Group]
	, 18 + s.gradenumeric AS [GroupSort]
	, 'Grade Level' AS GroupType
	, 7 AS GroupTypeSort
FROM elhcustom.v_student s


--SELECT DISTINCT s.gender FROM elhcustom.v_student s ORDER BY 1
--CREATE VIEW elhcustom.v_siblings AS
--ALTER VIEW elhcustom.v_siblings AS

SELECT s.FullName
	, s.grade
	, s.PersonCalendarID
	, s.endyear
	, s.personID
	, s.calendarID
	, rp.personID2 AS sibPersonID
	, si.calendarID AS sibCalendarID
	, si.grade AS sibGrade
	, si.GradeNumeric AS sibGradeNumeric
	, CONCAT(si.firstName, ' ' , si.lastname) AS siblingName
	, ar.attRate AS sibAttendanceRate
	, ROW_NUMBER() OVER (PARTITION BY s.personcalendarID ORDER BY si.GradeNumeric, si.birthdate, rp.personID2) AS sibRank
FROM elhcustom.v_student s
LEFT JOIN RelatedPair rp 
	ON rp.personID1 = s.personID 
	AND (rp.enddate IS NULL OR rp.enddate >= GETDATE())
	AND rp.name = 'Sibling'
JOIN elhcustom.v_student si 
	ON si.personID = rp.personID2 
	AND si.endyear = s.endYear 
	AND si.summerSchool = 0 
	AND si.Nonpublic = 'N'
	AND (
		si.endStatus <> 4321
		AND si.endStatus <> 1234
		OR si.endStatus IS NULL
	)
LEFT JOIN (
	SELECT personID
		, calendarID
		, AVG(attendanceValue*1.0) AS attRate 
	FROM elhCustom.v_DailyAttendance
	GROUP BY personID
		, calendarID
) ar ON ar.personID = si.personID 
	AND ar.calendarID = si.calendarID

WHERE s.summerSchool = 0 AND s.Nonpublic = 'N'

/* 
This view shows all of the sections for all of the courses.
Unique key is SectionID
*/
--Create VIEW elhcustom.v_Section AS
--ALTER VIEW elhcustom.v_Section AS

SELECT 
 
 c.courseID
 ,c.number AS CourseNumber
 ,c.name AS CourseName
 ,d.name AS Department
 ,sec.teacherDisplay 
 ,sec.teacherpersonID
 ,sec.sectionID
 ,sec.number AS SectionNumber
 ,c.terms
 ,rm.name AS Room
 ,cal.schoolID
 ,c.calendarID
 ,CAST(sec.teacherPersonID AS varchar(10)) + '-' + CAST(cal.schoolID AS varchar(10)) AS PersonSchoolID
 , c.activityCode
 , numQ
 , firstQ
 , CASE WHEN pri.lastName IS NOT NULL THEN	CONCAT(pri.lastName, ', ' , pri.firstName)  ELSE NULL END AS primaryTeacher
 , pri.personID AS primaryPersonID
 , secTeacher.secTeacher AS secondaryTeacher
 , c.attendance

FROM dbo.Section sec 
JOIN dbo.Course AS c ON c.courseID = sec.courseID
LEFT JOIN dbo.Department d ON d.departmentID = c.departmentID
LEFT JOIN dbo.Room AS rm ON rm.roomID = sec.roomID
JOIN dbo.calendar cal ON cal.calendarID = c.calendarID
LEFT JOIN (
	SELECT sp.sectionID
		, COUNT(tm.name) AS numQ
		, MIN(tm.name) AS firstQ
	FROM (
		SELECT DISTINCT sectionID, termID FROM dbo.SectionPlacement
	) sp
	LEFT JOIN Term AS tm ON tm.termID = sp.termID 
	GROUP BY sp.sectionID
) AS sp ON sp.sectionID = sec.sectionID


LEFT JOIN SectionStaffHistory sh ON sh.sectionID = sec.sectionID	
	AND (sh.startDate IS NULL OR sh.startDate <= GETDATE())
	AND (sh.endDate IS NULL OR sh.enddate >= GETDATE())
	AND sh.staffType = 'P'
LEFT JOIN individual pri ON pri.personID = sh.personID

--This Query lists all secondary teachers in one cell separated by semicolons
LEFT JOIN(
	SELECT 
	  sectionID,
	  STUFF(
		(
			SELECT '; ' + [lastname] 
			FROM  (SELECT sh.sectionID, st.lastname FROM SectionStaffHistory sh
						JOIN individual st ON st.personID = sh.personID
						WHERE (sh.startDate IS NULL OR sh.startDate <= GETDATE())
							AND (sh.endDate IS NULL OR sh.enddate >= GETDATE())
							AND sh.staffType = 'T'
			) sub
			WHERE (sectionID = a.sectionID) 
			FOR XML PATH('') , TYPE
		).value('(./text())[1]','VARCHAR(MAX)')
		, 1
		, 2
		, ''
	  ) AS secTeacher
	FROM (
		SELECT sh.sectionID, st.lastname 
		FROM SectionStaffHistory sh
		JOIN individual st ON st.personID = sh.personID
		WHERE (sh.startDate IS NULL OR sh.startDate <= GETDATE())
			AND (sh.endDate IS NULL OR sh.enddate >= GETDATE())
			AND sh.staffType = 'T'
	) a
	GROUP BY sectionID
) secTeacher ON secTeacher.sectionID = sec.sectionID

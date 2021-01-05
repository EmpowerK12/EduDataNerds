--Create VIEW elhcustom.v_Schedules AS
--ALTER VIEW elhcustom.v_Schedules AS

SELECT DISTINCT
 r.personID
 ,cl.calendarID
 ,cl.name AS calendarName
 ,cl.endYear
 ,cl.schoolID
 ,y.active AS ActiveYear
 ,tl.trialID
 ,tl.active AS ActiveTrial
 
 --,c.courseID
 --,c.number AS CourseNumber
 --,c.name AS CourseName
 --,d.name AS Department
-- ,sec.teacherDisplay 
 --,sec.teacherpersonID
 ,r.sectionID
 --,sec.number AS SectionNumber
 ,r.startDate
 ,r.endDate
 ,CASE WHEN (r.startDate IS NULL OR r.startDate <= GETDATE()) AND (r.endDate IS NULL OR r.endDate >= cast(GETDATE() AS date)) THEN 'Y' ELSE 'N' END AS ActiveRoster
 , CASE WHEN tm.startDate <= GETDATE() AND tm.endDate >= GETDATE() THEN 'Y' ELSE 'N' END AS activeTerm
 ,sp.termID
 ,tm.name AS 'Term'
 --,tm.startDate AS TermStartDate
 --,tm.endDate AS termEndDate
 ,pd.name AS 'Period'
 ,pd.seq AS PeriodSeq
 ,pd.periodID
 ,CONVERT(VARCHAR(8), pd.startTime,108) AS StartTime
 ,CONVERT(VARCHAR(8), pd.endTime,108) AS EndTime
 ,pd.periodMinutes
 ,ps.name AS ScheduleName
 ,ps.seq AS ScheduleSeq
 , ps.periodScheduleID AS periodScheduleID
 --,rm.Name AS Room
 ,CAST(e.personID AS varchar(10)) + '-' + CAST(tl.calendarID AS varchar(10)) AS PersonCalendarID
 , CASE WHEN pd.periodID IS NULL 
	THEN CAST(e.personID AS varchar(10)) + '-' + CAST(tl.calendarID AS varchar(10)) + '-None'
	ELSE CAST(e.personID AS varchar(10)) + '-' + CAST(tl.calendarID AS varchar(10)) + '-' + CAST(pd.periodID AS varchar(10)) 
	END AS PersonCalendarPeriodID




FROM dbo.Enrollment AS e
	INNER JOIN dbo.Trial AS tl ON tl.calendarID = e.calendarID AND tl.structureID = e.structureID AND tl.active = 1
	INNER JOIN dbo.Calendar AS cl ON cl.calendarID = tl.calendarID 
	INNER JOIN dbo.Roster AS r ON r.personID = e.personID AND tl.trialID = r.trialID 
	--INNER JOIN Section AS sec ON sec.sectionID = r.sectionID AND tl.trialID = sec.trialID 
	--INNER JOIN Course AS c ON c.courseID = sec.courseID AND c.calendarID = tl.calendarID 
	--LEFT JOIN Department d ON d.departmentID = c.departmentID
	LEFT JOIN dbo.SectionPlacement AS sp ON sp.sectionID = r.sectionID AND tl.trialID = sp.trialID 
	LEFT JOIN dbo.Period AS pd ON pd.periodID = sp.periodID 
	LEFT JOIN dbo.PeriodSchedule AS ps ON ps.periodScheduleID = pd.periodScheduleID AND ps.structureID = tl.structureID 
	LEFT JOIN Term AS tm ON tm.termID = sp.termID 
	--LEFT OUTER JOIN Room AS rm ON rm.roomID = sec.roomID
	LEFT JOIN dbo.SchoolYear y ON y.endyear = e.endyear


WHERE  (e.noShow IS NULL OR e.noShow = 0) 


--Create VIEW elhcustom.v_Student AS
--ALTER VIEW elhcustom.v_Student AS

/*This view returns student demographic information for each student for each calendarID. 
Unique key is PersonCalendarID
There are some repeats on EndYear, but you can use summerSchool = 0 to join with Assessments on personID-endYear-summerSchool = personId-endyear-0
DOES NOT include 17-18 Summer Bridge
*/


SELECT  e.endYear, 
		e.districtID, 
		e.calendarID, 
		c.name AS calendarName, 
		e.personID, 
		i.lastName, 
		i.firstName, 
		i.lastname + ', ' + i.firstName AS FullName,
		i.middleName, 
		e.grade, 
		CASE WHEN e.grade = 'PK-3' THEN -2 WHEN e.grade = 'PK-4' THEN -1 WHEN e.grade = 'K' THEN 0 ELSE CAST (e.grade AS int) END AS GradeNumeric,
		e.structureID, 
		e.noShow, 
		c.schoolID, 
		CASE c.schoolID
			WHEN 1 THEN 'HS'
			WHEN 2 THEN 'ELH'
			WHEN 3 THEN 'ES'
			WHEN 4 THEN 'MS'
			ELSE NULL END AS school,
		CASE c.schoolID
			WHEN 1 THEN 3
			WHEN 2 THEN 4
			WHEN 3 THEN 1
			WHEN 4 THEN 2
			ELSE NULL END AS sortSchool,
		e.enrollmentID, 
		p.stateID, 
		CAST(p.studentNumber AS int) AS studentNumber, 
		i.identityID, 
		i.effectiveDate, 
		i.suffix, 
		i.alias, 
		i.gender, 
		i.birthdate, 
		i.hispanicEthnicity, 
        i.raceEthnicityFed, 
		CASE WHEN i.raceEthnicityFed = 1 THEN 'Hispanic' 
			WHEN i.raceEthnicityFed = 2 THEN 'American Indian'
			WHEN i.raceEthnicityFed = 3 THEN 'Asian'
			WHEN i.raceEthnicityFed = 4 THEN 'Black'
			WHEN i.raceEthnicityFed = 5 THEN 'Hawaiian/PI'
			WHEN i.raceEthnicityFed = 6 THEN 'White'
			WHEN i.raceEthnicityFed = 7 THEN 'Multiple' END AS 'RaceEthnicity',
		i.raceEthnicityDetermination, 
		CASE WHEN LEP.identifiedDate <= c.endDate AND (lep.exitDate > c.startDate OR lep.exitDate IS NULL) THEN 'Y' ELSE 'N' END AS 'LEP',
		CASE WHEN LEP.programStatus = 'Exited LEP' THEN
			(CASE WHEN LEP.fourthYearMonitoring <= c.startdate + 15 THEN 'N'
				WHEN LEP.thirdYearMonitoring <= c.startdate + 15 THEN '4th Year'
				WHEN LEP.SecondYearMonitoring <= c.startdate + 15 THEN '3rd Year'
				WHEN LEP.firstYearMonitoring <= c.startdate + 15 THEN '2nd Year'
				WHEN LEP.exitDate <= c.startdate + 15 THEN '1st Year'
				ELSE 'N' END)
			ELSE 'N' END AS LEPMonitored,
		LEP.identifiedDate AS IdentifiedDateLEP, 
		cl.value AS EllCaseManager,
		cd.name AS homePrimaryLanguage, 
		i.dateEnteredUS,
		--e.serviceType, 
        e.startDate, 
		e.startStatus, 
		e.endDate, 
		CASE WHEN e.endStatus IN (1234, 4321) THEN 'No-show'
			WHEN e.endStatus IN (2020, 2022) THEN 'Graduated'
			WHEN MONTH(e.enddate) IN (8, 9) OR (MONTH(e.enddate) = 10 AND DAY(e.enddate) <= 5) THEN 'Before Oct 5'
			WHEN MONTH(e.enddate) IN (10, 11, 12, 1, 2) THEN 'Before March 1'
			WHEN MONTH(e.enddate) IN (3, 4, 5) THEN 'Before June 1'
			WHEN MONTH(e.enddate) IN (6,7) THEN 'June or July'
			ELSE NULL END AS endDateGroup


		, e.endStatus
		, eest.name AS endStatusName
		, e.endComments
		, CASE
			WHEN e.endStatus IN (1234, 4321) THEN 'Stage 4 Pre-Enrollment Exit'
			WHEN e.endStatus IN (2020, 2021, 2022, 2023, 2024, 2025) THEN 'Credential'
			WHEN e.endStatus IN (2000, 2001, 2002) THEN 'Year End'
			WHEN e.endStatus IN (2040, 2041, 2042, 2043) THEN 'Transfer'
			WHEN e.endStatus IN (1940, 1941, 1942, 1943, 1944) THEN 'Exited'
			WHEN e.endStatus IN (1960, 1961, 1962, 1963, 1964, 1965, 1966, 1968) THEN 'Discharge'
			WHEN e.endStatus IN (1980, 1981, 1982, 1983, 1984, 1989) THEN 'Disengagement'
			ELSE NULL END AS endStatusGroup
		, cdOOSd.name AS 'withdrawalOutOfStateDoc'
		, CASE WHEN HSRecDoc.value = 1 THEN 'Y' ELSE 'N' END AS 'HSReceivingSchoolDoc'
		, CASE WHEN OOSProvOSSE.value = 1 THEN 'Y' ELSE 'N' END AS 'OOSProvOSSE'
		, CASE 
			WHEN (
					(e.enddate IS NULL 
						OR e.enddate > getdate() 
						OR 
							(e.grade = '12'
								AND e.enddate > DATEFROMPARTS(e.endyear, 5, 1)
								AND GETDATE() < DATEFROMPARTS(e.endyear, 8, 1)
							)
						OR 
							(
								e.enddate > DATEFROMPARTS(e.endyear, 6, 1)
								AND GETDATE() < DATEFROMPARTS(e.endyear, 8, 1)

							)
					) 
					AND (e.startdate IS NULL OR e.startdate < getdate())
				) 
				AND (y.active = 1) 
				THEN 'Y' ELSE 'N' END AS 'ActiveStudent',
		e.stateExclude AS enrollmentStateExclude, 
		CASE WHEN 
			e.specialEdStatus = 1 
			OR (spedexit.value >= c.startDate 
				AND SpedExit.value <= c.endDate 
				AND e.disability1 IS NOT NULL
			) 
			THEN 'Y' ELSE 'N' END AS SPED,
		e.disability1,
		c.startDate AS calendarStart,
		c.endDate AS calendarEnd, 
		c.exclude AS calendarExclude, 
		c.summerSchool,
		y.startYear, 
        y.label, 
		y.active AS activeYear,
		
		CASE WHEN pe.FARM IS NOT NULL THEN pe.FARM ELSE 'N' END AS FARM,
		g.cohortYearNCLB,
		g.grade9Date,
		g.diplomaDate,
		g.diplomaType,
		striking.value AS StrikingDistance,
		CASE WHEN g.diplomaDate IS NOT NULL 
				THEN (
					CASE WHEN MONTH(g.diplomaDate) < 9
						THEN YEAR(g.diplomaDate)
					ELSE YEAR(g.diplomaDate) + 1
					END
				)
			WHEN striking.value = 1 
				THEN e.endYear 
			ELSE e.endyear + (12 - (CASE WHEN e.grade = 'PK-3' THEN -2 
										WHEN e.grade = 'PK-4' THEN -1 
										WHEN e.grade = 'K' THEN 0 
										ELSE CAST (e.grade AS int) 
										END)
								) 
			END AS ClassOf,
		CASE WHEN cer.programID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Certificate',
		ds.spedLevel,
		SpedCaseManager.value AS SPEDCaseManager,
		CASE WHEN ds3.atRisk IS NOT NULL 
				THEN ds3.atRisk 
			WHEN ds.atRisk IS NOT NULL 
				THEN ds.atRisk 
			WHEN ds2.atRisk IS NOT NULL
				THEN ds2.atRisk
			ELSE sled.MaxAtRisk
			END AS atRisk,
		CASE WHEN p504.programID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is504',
		CASE WHEN BIP.programID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'BIP',
		CASE WHEN BC.programID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'BehaviorContract',
		--CASE WHEN Homeless.personID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Homeless',
		CASE WHEN np.personID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Nonpublic',
		Advisor.Advisor,
		Advisor.AdvisorID
		, con.email AS email
		, years.yearsEnrolled
		, years.mostRecentEndyear
		, years.firstEndyear
		, CASE WHEN AltTest.value = 'Yes' THEN 'Y' ELSE 'N' END AS altAssessment
		, CAST(p.personID AS varchar(10)) +'-' + CAST(e.endyear AS varchar(10))+'-' + CAST(c.summerSchool AS varchar(10)) +'-' + CASE WHEN np.personID IS NOT NULL THEN 'Y' ELSE 'N' END   AS PersonEndyearSummerNP
		,  CAST(p.personID AS varchar(10)) + '-' + CAST(c.calendarID AS varchar(10)) AS PersonCalendarID
						
FROM    dbo.Person AS p 
INNER JOIN dbo.[Identity] AS i ON p.currentIdentityID = i.identityID AND p.personID = i.personID 
LEFT JOIN dbo.CampusDictionary cd ON cd.code = i.homePrimaryLanguage AND cd.attributeID = 961
INNER JOIN dbo.Enrollment AS e ON p.personID = e.personID AND e.active = 1 AND (e.noShow IS NULL OR e.noShow = 0) 
INNER JOIN dbo.Calendar AS c ON c.calendarID = e.calendarID 
INNER JOIN dbo.SchoolYear AS y ON y.endYear = e.endYear 
LEFT JOIN ( 
	SELECT personID, lepID , ROW_NUMBER () OVER (PARTITION BY personID ORDER BY lepID desc) AS rn FROM dbo.LEP 
) LEPid ON LEPid.personID = p.personID AND LEPid.rn = 1
LEFT JOIN dbo.Lep ON lep.personID = p.personID AND Lep.lepID = LEPid.lepID
LEFT JOIN dbo.CustomLep cl ON cl.lepID = LEP.lepID AND cl.attributeID = 869
LEFT JOIN (
	select personID, endyear, max(case when eligibility IN ('F', 'R') THEN 'Y' ELSE 'N' END) AS 'FARM' 
	from dbo.POSEligibility group by personid, endyear
) pe ON pe.personID = p.personID AND pe.endyear = e.endYear
LEFT JOIN dbo.Graduation g ON g.personID = p.personID
LEFT JOIN elhcustom.DemographicSnapshot ds ON ds.personID = p.personID AND ds.endyear = e.endyear AND ds.demoTypeID = 1
LEFT JOIN elhcustom.DemographicSnapshot ds2 ON ds2.personID = p.personID AND ds2.endyear = e.endyear AND ds2.demoTypeID = 2 --demoTypeID 2 is Temporary Oct 5 Enrollment snapshot
LEFT JOIN elhcustom.DemographicSnapshot ds3 ON ds3.personID = p.personID AND ds3.endyear = e.endyear AND ds3.demoTypeID = 3 --demoTypeID 3 is End of Year Enrollment snapshot
LEFT JOIN (
	SELECT USI
		, max(CASE [At Risk Indicator] WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END)	as MaxAtRisk
	FROM elhcustom.SLEDEnrollApp20 
	GROUP BY USI
) sled ON sled.USI = p.stateID AND e.endyear = 2021
LEFT JOIN dbo.ProgramParticipation p504 ON p504.personID = p.personID AND  p504.programID = 18 AND p504.startDate <= c.endDate AND (p504.endDate >= c.startDate OR p504.enddate IS NULL)
LEFT JOIN dbo.ProgramParticipation BIP ON BIP.personID = p.personID AND  BIP.programID = 31 AND BIP.startDate <= c.endDate AND (BIP.endDate >= c.startDate OR BIP.enddate IS NULL)
LEFT JOIN dbo.ProgramParticipation BC ON BC.personID = p.personID AND  BC.programID = 41 AND BC.startDate <= GETDATE() AND (BC.endDate >= GETDATE() OR BC.enddate IS NULL)
LEFT JOIN dbo.ProgramParticipation cer ON cer.personID = p.personID AND  cer.programID = 19 AND cer.startDate <= c.endDate AND (cer.endDate >= c.startDate OR cer.enddate IS NULL)
LEFT JOIN dbo.CustomStudent SpedExit ON SpedExit.personID = p.personID AND SpedExit.enrollmentID = e.enrollmentID AND SpedExit.attributeID = 546
--LEFT JOIN dbo.Homeless ON Homeless.personID = p.personID AND Homeless.startDate <= c.endDate AND (homeless.enddate >= c.startDate OR homeless.enddate IS NULL)
LEFT JOIN dbo.CustomStudent Striking ON Striking.personID = p.personID AND Striking.enrollmentID = e.enrollmentID AND Striking.attributeID = 606
LEFT JOIN dbo.CustomStudent np ON np.enrollmentID = e.enrollmentID and np.attributeID = 573 
LEFT JOIN dbo.CustomStudent wOOSd ON wOOSd.enrollmentID = e.enrollmentID AND wOOSd.attributeID = 986
LEFT JOIN dbo.CampusDictionary cdOOSd ON  cdOOSd.code = wOOSd.value AND cdOOSd.attributeID = 986 
LEFT JOIN dbo.CustomStudent HSRecDoc ON HSRecDoc.enrollmentID = e.enrollmentID AND HSRecDoc.attributeID = 985
LEFT JOIN dbo.CustomStudent OOSProvOSSE ON OOSProvOSSE.enrollmentID = e.enrollmentID AND OOSProvOSSE.attributeID = 987

LEFT JOIN (
	select personID, calendarID, AdvisorID, Advisor 
	from (
		select 
			r.personID,
			c.calendarID,
			i.lastName + ', ' + i.firstName AS Advisor,
			i.personID AS AdvisorID,
			ROW_NUMBER() OVER(PARTITION BY r.personID, c.calendarID ORDER BY case when r.startDate is null then 0 else r.startDate end DESC) rn
		from roster r 
		join trial tr on tr.trialID=r.trialID and tr.active=1
		join section sec on sec.sectionID=r.sectionID
		join (
			course c 
				join calendar cal on cal.calendarID=c.calendarID and cal.Name not like '%summer%' and cal.Name not like '%ss%'
				join school sch on sch.schoolID=cal.schoolID
		) on c.courseID=sec.courseID and ((sch.name not like '%Elementary%' and c.name='Advisory') or (sch.name like '%Elementary%' and c.name='Daily Attendance'))
		join individual i on i.personID=sec.teacherPersonID
				where (r.startDate is null or r.startDate <= getDate())
	) advTemp
	where advTemp.rn=1
) Advisor ON Advisor.personID = p.personID AND Advisor.calendarID = c.calendarID
LEFT JOIN (
	SELECT e.personID, COUNT(DISTINCT e.endyear) AS yearsEnrolled, MAX(e.endyear) AS mostRecentEndyear, MIN(e.endyear) AS firstEndyear
	FROM Enrollment e
	WHERE e.startStatus <> 1800
	GROUP BY e.personID 
) years ON years.personID = p.personID
LEFT JOIN customstudent AltTest 
	ON AltTest.personID = e.personID
	AND AltTest.enrollmentID = e.enrollmentID
	AND AltTest.attributeID = 1167
LEFT JOIN CustomStudent SpedCaseManager 
	ON SpedCaseManager.personID = e.personID 
	AND SpedCaseManager.enrollmentID = e.enrollmentID 
	AND SpedCaseManager.attributeID = 544

LEFT JOIN EnrollmentEndStatusType eest 
	ON eest.code = e.endStatus
LEFT JOIN contact con ON con.personID = e.personID

WHERE 1=1
	AND c.calendarID <> 44 --Excludes Summer Bridge to avoid duplicates

--ORDER BY endyear, calendarID, gradenumeric, personID

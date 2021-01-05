--CREATE VIEW elhcustom.v_OnTrack AS
--ALTER VIEW elhcustom.v_OnTrack AS

--This View gathers the courses a student has already passed from his or her transcript and the courses he or she is currently taking. It calculates
--the number of credits he/she has earned toward each graduation requirement.
--****WARNING: There is potential for inaccurate calculations if a student's current-year grades have been added to his/her transcript.
--The work-around for this is to exclude the first semester credits from the pct and pco tables. OR, remove posted grades from courses that have been added to the transcript.


SELECT s.fullname
	, s.personID
	, s.calendarID
	,  CAST(s.personID AS varchar(10)) + '-' + CAST(s.calendarID AS varchar(10)) AS personCalendarID
	, s.grade
	, s.cohortYearNCLB
	, s.endyear
	, 4-((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) as Years
	, CASE 
		WHEN s.Certificate = 'Y' THEN NULL 
		WHEN 
		(
			(
				(COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0) 
				+ COALESCE(MathT, 0) + COALESCE(MathP, 0)
				+ COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0)
				+ COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0)
				+ COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)
				+ COALESCE([HealthFitnessT], 0) + COALESCE([HealthFitnessP], 0)
				+ COALESCE(ArtT, 0) + COALESCE(ArtP, 0)
				+ COALESCE(MusicT, 0) + COALESCE(MusicP, 0)
				+ COALESCE(ElectivesT, 0) + COALESCE(ElectivesP , 0)
				) 
				>= (4 -(s.cohortYearNCLB - s.endYear)) * 6 
			)
			AND COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0) >= 4 -(s.cohortYearNCLB - s.endYear) 
			AND COALESCE(MathT, 0) + COALESCE(MathP, 0) >= 4-(s.cohortYearNCLB - s.endYear)
			AND COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0) >= 4-(s.cohortYearNCLB - s.endYear)
			AND COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0) >= 4-(s.cohortYearNCLB - s.endYear)
			AND 2 - (COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1.5 - (COALESCE([HealthFitnessT], 0) + COALESCE([HealthFitnessP], 0)) <= (s.cohortYearNCLB - s.endYear)
			AND .5 - (COALESCE(ArtT, 0) + COALESCE(ArtP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND .5 - (COALESCE(MusicT, 0) + COALESCE(MusicP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(AlgebraIT, 0) + COALESCE(AlgebraIP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(GeometryT, 0) + COALESCE(GeometryP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(AlgebraIIT, 0) + COALESCE(AlgebraIIP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(WorldHistoryT, 0) + COALESCE(WorldHistoryP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(USHistoryT, 0) + COALESCE(USHistoryP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND .5 - (COALESCE(GovernmentT, 0) + COALESCE(GovernmentP, 0)) <= (s.cohortYearNCLB - s.endYear) 
			AND .5 - (COALESCE(DCHistoryT, 0) + COALESCE(DCHistoryP, 0)) <= (s.cohortYearNCLB - s.endYear) 
			AND 1 - (COALESCE(BiologyT, 0) + COALESCE(BiologyP, 0)) <= (s.cohortYearNCLB - s.endYear)
			AND 1 - (COALESCE(ChemistryT, 0) + COALESCE(ChemistryP, 0)) <= (s.cohortYearNCLB - s.endYear) 
			--AND 1 - (COALESCE(PhysicsT, 0) + COALESCE(PhysicsP, 0)) <= (s.cohortYearNCLB - s.endYear) 
		) THEN 1 
		ELSE 0 
		END AS OT
	, COALESCE(cs.[CSHours], 0) AS CSHours
	, CASE WHEN (COALESCE(cs.[CSHours], 0) >= 25 * (4-(s.cohortYearNCLB - s.endYear)) OR cs.CSHours >=100 ) THEN 1 ELSE 0 END AS CSOT


	, COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0)
		+ COALESCE(MathT, 0) + COALESCE(MathP, 0)
		+ COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0)
		+ COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0)
		+ COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)
		+ COALESCE([HealthFitnessT], 0) + COALESCE([HealthFitnessP], 0)
		+ COALESCE(ArtT, 0) + COALESCE(ArtP, 0)
		+ COALESCE(MusicT, 0) + COALESCE(MusicP, 0)
		+ COALESCE(ElectivesT, 0) + COALESCE(ElectivesP, 0) AS TotalCredits
	, CASE WHEN (
			COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0) 
			+ COALESCE(MathT, 0) + COALESCE(MathP, 0)
			+ COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0)
			+ COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0)
			+ COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)
			+ COALESCE([HealthFitnessT], 0) + COALESCE([HealthFitnessP], 0)
			+ COALESCE(ArtT, 0) + COALESCE(ArtP, 0)
			+ COALESCE(MusicT, 0) + COALESCE(MusicP, 0)
			+ COALESCE(ElectivesT, 0) + COALESCE(ElectivesP , 0)
		) >= (4 -(CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) * 6 THEN 1 ELSE 0 END AS CreditsOT
	
	, COALESCE(EnglishT, 0) AS EnglishT
	, COALESCE(EnglishP, 0) AS EnglishP
	, COALESCE(EnglishF, 0) AS EnglishF
	, (COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0)) AS English
	, CASE WHEN COALESCE(EnglishT, 0) + COALESCE(EnglishP, 0) >= 4 -(CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END) THEN 1 ELSE 0 END AS EnglishOT
	
	, COALESCE(MathT, 0) AS MathT
	, COALESCE(MathP, 0) AS MathP
	, COALESCE(MathF, 0) AS MathF
	, (COALESCE(MathT, 0) + COALESCE(MathP, 0)) AS Math
	, CASE WHEN COALESCE(MathT, 0) + COALESCE(MathP, 0) >= 4 - (CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END) THEN 1 ELSE 0 END AS MathOT
	
	, COALESCE(SocialStudiesT, 0) AS SocialStudiesT
	, COALESCE(SocialStudiesP, 0) AS SocialStudiesP
	, COALESCE(SocialStudiesF, 0) AS SocialStudiesF
	, (COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0)) AS SocialStudies
	, CASE WHEN COALESCE(SocialStudiesT, 0) + COALESCE(SocialStudiesP, 0) >= 4-(CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END) THEN 1 ELSE 0 END AS SocialStudiesOT
	
	, COALESCE(ScienceT, 0) AS ScienceT 
	, COALESCE(ScienceP, 0) AS ScienceP
	, COALESCE(ScienceF, 0) AS ScienceF
	, (COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0)) AS Science
	, CASE WHEN COALESCE(ScienceT, 0) + COALESCE(ScienceP, 0) >= 4-((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS ScienceOT
	
	, COALESCE(WorldLangT, 0) AS WorldLangT
	, COALESCE(WorldLangP, 0) AS WorldLangP
	, COALESCE(WorldLangF, 0) AS WorldLangF
	, (COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)) AS WorldLang
	, CASE WHEN 2 - (COALESCE(WorldLangT, 0) + COALESCE(WorldLangP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS WorldLangOT
	
	, COALESCE([HealthFitnessT], 0) AS [HealthFitnessT]
	, COALESCE([HealthFitnessP], 0) AS [HealthFitnessP]
	, COALESCE([HealthFitnessF], 0) AS [HealthFitnessF]
	, (COALESCE([HealthFitnessT], 0) + COALESCE(HealthFitnessP, 0)) AS HealthFitness
	, CASE WHEN 1.5 - (COALESCE([HealthFitnessT], 0) + COALESCE([HealthFitnessP], 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS [HealthFitnessOT]
	
	, COALESCE(ArtT, 0) AS ArtT
	, COALESCE(ArtP, 0) AS ArtP
	, COALESCE(ArtF, 0) AS ArtF
	, (COALESCE(ArtT, 0) + COALESCE(ArtP, 0)) AS Art
	, CASE WHEN .5 - (COALESCE(ArtT, 0) + COALESCE(ArtP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS ArtOT
	
	, COALESCE(MusicT, 0) AS MusicT
	, COALESCE(MusicP, 0) AS MusicP
	, COALESCE(MusicF, 0) AS MusicF
	, (COALESCE(MusicT, 0) + COALESCE(MusicP, 0)) AS Music
	, CASE WHEN .5 - (COALESCE(MusicT, 0) + COALESCE(MusicP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS MusicOT
	
	, COALESCE(ElectivesT, 0) AS ElectivesT
	, COALESCE(ElectivesP, 0) AS ElectivesP
	, COALESCE(ElectivesF, 0) AS ElectivesF
	, (ElectivesT + COALESCE(ElectivesP, 0)) AS Electives
	
	, COALESCE(AlgebraIT, 0) AS AlgebraT
	, COALESCE(AlgebraIP, 0) AS AlgebraIP
	, COALESCE(AlgebraIF, 0) AS AlgebraIF
	, (COALESCE(AlgebraIT, 0) + COALESCE(AlgebraIP, 0)) AS AlgebraI 
	, CASE WHEN 1 - (COALESCE(AlgebraIT, 0) + COALESCE(AlgebraIP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS AlgebraIOT
	
	, COALESCE(GeometryT, 0) AS GeometryT
	, COALESCE(GeometryP, 0) AS GeometryP
	, COALESCE(GeometryF, 0) AS GeometryF
	, (COALESCE(GeometryT, 0) + COALESCE(GeometryP, 0)) AS Geometry 
	, CASE WHEN 1 - (COALESCE(GeometryT, 0) + COALESCE(GeometryP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS GeometryOT
	
	, COALESCE(AlgebraIIT, 0) AS AlgebraIIT
	, COALESCE(AlgebraIIP, 0) AS AlgebraIIP
	, COALESCE(AlgebraIIF, 0) AS AlgebraIIF
	, (COALESCE(AlgebraIIT, 0) + COALESCE(AlgebraIIP, 0)) AS AlgebraII 
	, CASE WHEN 1 - (COALESCE(AlgebraIIT, 0) + COALESCE(AlgebraIIP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS AlgebraIIOT
	
	, COALESCE(WorldHistoryT, 0) AS WorldHistoryT
	, COALESCE(WorldHistoryP, 0) AS WorldHistoryP
	, COALESCE(WorldHistoryF, 0) AS WorldHistoryF
	, (COALESCE(WorldHistoryT, 0) + COALESCE(WorldHistoryP, 0)) AS WorldHistory 
	, CASE WHEN 1 - (COALESCE(WorldHistoryT, 0) + COALESCE(WorldHistoryP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS WorldHistoryOT
	
	, COALESCE(USHistoryT, 0) AS USHistoryT
	, COALESCE(USHistoryP, 0) AS USHistoryP
	, COALESCE(USHistoryF, 0) AS USHistoryF
	, (COALESCE(USHistoryT, 0) + COALESCE(USHistoryP, 0)) AS USHistory 
	, CASE WHEN 1 - (COALESCE(USHistoryT, 0) + COALESCE(USHistoryP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS USHistoryOT
	
	, COALESCE(GovernmentT, 0) AS GovernmentT
	, COALESCE(GovernmentP, 0) AS GovernmentP
	, COALESCE(GovernmentF, 0) AS GovernmentF
	, (COALESCE(GovernmentT, 0) + COALESCE(GovernmentP, 0)) AS Government 
	, CASE WHEN .5 - (COALESCE(GovernmentT, 0) + COALESCE(GovernmentP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS GovernmentOT
	
	, COALESCE(DCHistoryT, 0) AS DCHistoryT
	, COALESCE(DCHistoryP, 0) AS DCHistoryP
	, COALESCE(DCHistoryF, 0) AS DCHistoryF
	, (COALESCE(DCHistoryT, 0) + COALESCE(DCHistoryP, 0)) AS DCHistory 
	, CASE WHEN .5 - (COALESCE(DCHistoryT, 0) + COALESCE(DCHistoryP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS DCHistoryOT
	
	, COALESCE(BiologyT, 0) AS BiologyT
	, COALESCE(BiologyP, 0) AS BiologyP
	, COALESCE(BiologyF, 0) AS BiologyF
	, (COALESCE(BiologyT, 0) + COALESCE(BiologyP, 0)) AS Biology 
	, CASE WHEN 1 - (COALESCE(BiologyT, 0) + COALESCE(BiologyP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS BiologyOT
	
	, COALESCE(ChemistryT, 0) AS ChemistryT
	, COALESCE(ChemistryP, 0) AS ChemistryP
	, COALESCE(ChemistryF, 0) AS ChemistryF
	, (COALESCE(ChemistryT, 0) + COALESCE(ChemistryP, 0)) AS Chemistry 
	, CASE WHEN 1 - (COALESCE(ChemistryT, 0) + COALESCE(ChemistryP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS ChemistryOT
/*	
	, COALESCE(PhysicsT, 0) ASPhysicsT 
	, COALESCE(PhysicsP, 0) AS PhysicsP
	, COALESCE(PhysicsF, 0) AS PhysicsF
	, (COALESCE(PhysicsT, 0) + COALESCE(PhysicsP, 0)) AS Physics 
	, CASE WHEN 1 - (COALESCE(PhysicsT, 0) + COALESCE(PhysicsP, 0)) <= ((CASE WHEN s.cohortYearNCLB < s.endyear THEN 0 ELSE (s.cohortYearNCLB - s.endYear) END)) THEN 1 ELSE 0 END AS PhysicsOT
	*/

FROM elhcustom.v_Student s


--Table tct returns the credits for courses a student has passed and are recorded on the transcript, organized by department
LEFT JOIN (
SELECT personID
		, endYear
		, calendarID
		, [5] AS EnglishT
		, [7] AS MathT
		, [10] AS [SocialStudiesT]
		, [9] AS ScienceT
		, [11] AS [WorldLangT]
		, [6] AS [HealthFitnessT]
		, [3] AS ArtT
		, [8] AS MusicT
		, [4] AS ElectivesT
	FROM ( 
	SELECT * FROM (
				
				SELECT s.personID
					, s.endyear
					, s.calendarID
					, tcr.standardID
					, tcr.creditsEarned
				FROM elhcustom.v_Student s
				JOIN TranscriptCredit tcr ON tcr.personID = s.personID
				JOIN CurriculumStandard cs ON tcr.standardID=cs.standardID AND cs.parentID=1
				JOIN TranscriptCourse tco ON tcr.transcriptID=tco.transcriptID AND tco.endyear <= s.endyear
				WHERE s.summerSchool = 0 AND s.Nonpublic = 'N'
			) AS [Past]
			PIVOT (
		sum([creditsEarned])
		for [standardID] in ([3],[4],[5],[6],[7],[8],[9],[10],[11])
	) AS Credits
	) AS TranscriptCreditsTable
) tct ON tct.personID = s.personID AND tct.calendarID = s.calendarID


--Table pct returns the credits for courses a student is currently passing this year, organized by department
LEFT JOIN (
	SELECT personID
		, [5] AS EnglishP
		, [7] AS MathP
		, [10] AS [SocialStudiesP]
		, [9] AS ScienceP
		, [11] AS [WorldLangP]
		, [6] AS [HealthFitnessP]
		, [3] AS ArtP
		, [8] AS MusicP
		, [4] AS ElectivesP
	FROM (
		SELECT * FROM ( 
				SELECT
					r.personID
					, gtc.standardID
					, CASE 
						WHEN gs.progresspercent>=60.5 THEN gtc.credit 
						WHEN gs.progresspercent<60.5 THEN 0.000
						WHEN gs.progresspercent IS NULL THEN gtc.credit
					END AS creditsEarned
				FROM v_SectionSchedule ss
				JOIN roster r ON ss.sectionID=r.sectionID AND (r.enddate>=getdate() OR r.enddate IS NULL)
				JOIN section sec ON sec.sectionID=r.sectionID
				JOIN course c ON c.courseID=sec.courseID
				JOIN gradingTaskCredit gtc ON gtc.courseID=c.courseID AND gtc.credit IS NOT NULL
				JOIN student s ON r.personID=s.personID AND s.calendarID=ss.calendarID
				JOIN calendar cal ON cal.calendarID=ss.calendarID AND cal.summerSchool = 0
				JOIN trial t ON ss.trialID=t.trialID AND t.active=1 
				LEFT JOIN v_GradingScores gs ON gs.sectionID=r.sectionID AND gs.personID=r.personID AND task='Final Grade'
				WHERE s.activeYear = 1 AND s.schoolID = 1
				--AND gs.termID <> 89                                                   --ADD THIS IN AFTER S1 TRANSCRIPTS WERE POSTED SO THAT THESE CREDITS ARE NOT DUPLICATED. REMOVE IN FALL 2020
			) AS [Current]
			PIVOT (
				sum([creditsEarned])
				for [standardID] in ([3],[4],[5],[6],[7],[8],[9],[10],[11])
			) AS Credits
	) AS ProgressCreditsTable
) pct ON pct.personID = s.personID AND s.activeYear = 1


--Table fct returns the credits for courses a student is currently failing, organized by department
LEFT JOIN (
	SELECT personID
		, [5] AS EnglishF
		, [7] AS MathF
		, [10] AS [SocialStudiesF]
		, [9] AS ScienceF
		, [11] AS [WorldLangF]
		, [6] AS [HealthFitnessF]
		, [3] AS ArtF
		, [8] AS MusicF
		, [4] AS ElectivesF
	FROM (
		SELECT * FROM ( 
				SELECT
					r.personID
					, gtc.standardID
					, CASE 
						WHEN gs.progresspercent>=60.5 THEN 0
						WHEN gs.progresspercent<60.5 THEN gtc.credit
						WHEN gs.progresspercent IS NULL THEN 0
					END AS creditsEarned
				FROM v_SectionSchedule ss
				JOIN roster r ON ss.sectionID=r.sectionID AND (r.startdate<=getdate() OR r.startdate IS NULL) AND (r.enddate>=getdate() OR r.enddate IS NULL)
				JOIN section sec ON sec.sectionID=r.sectionID
				JOIN course c ON c.courseID=sec.courseID
				JOIN gradingTaskCredit gtc ON gtc.courseID=c.courseID AND gtc.credit IS NOT NULL
				JOIN student s ON r.personID=s.personID AND s.calendarID=ss.calendarID
				JOIN calendar cal ON cal.calendarID=ss.calendarID  AND cal.summerSchool = 0
				JOIN trial t ON ss.trialID=t.trialID AND t.active=1 
				LEFT JOIN v_GradingScores gs ON gs.sectionID=r.sectionID AND gs.personID=r.personID AND task='Final Grade'
				WHERE s.activeYear = 1 AND s.schoolID = 1
			) AS [Current]
			PIVOT (
				sum([creditsEarned])
				for [standardID] in ([3],[4],[5],[6],[7],[8],[9],[10],[11])
			) AS Credits
	) AS FailingCreditsTable
) fct ON fct.personID = s.personID AND s.activeYear = 1






--Table tco returns the credits for courses a student has already passed and are on the transcript, organized by required course
LEFT JOIN (
	SELECT personID
		, calendarID
		, [Algebra I] AS AlgebraIT
		, [Geometry] AS GeometryT
		, [Algebra II] AS AlgebraIIT
		, Biology AS BiologyT
		, Chemistry AS ChemistryT
		, Physics AS PhysicsT
		, [World History] AS WorldHistoryT
		, [US History] AS USHistoryT
		, Government AS GovernmentT
		, [DC History] AS DCHistoryT
	FROM (	
		SELECT tcr.personID, sum(tcr.creditsEarned) AS credits, tcr.calendarID, req.displayValue
		FROM (
			SELECT * 
			FROM (	
			SELECT tcr.personID
						,s.firstName
						,s.lastName
						, s.endYear
						, s.calendarID
						,tcr.standardID
						,tco.courseNumber
						,tcr.creditsEarned
				FROM elhcustom.v_Student s
				JOIN TranscriptCredit tcr ON tcr.personID = s.personID
				JOIN CurriculumStandard cs ON tcr.standardID=cs.standardID AND cs.parentID=1
				JOIN TranscriptCourse tco ON tcr.transcriptID=tco.transcriptID AND tco.endyear <= s.endyear
				WHERE s.summerSchool = 0 AND s.Nonpublic = 'N'
			) AS [Past]
		) tcr 
		JOIN ProgramParticipation pp ON pp.personID=tcr.personID
		JOIN CourseRequirement req ON req.courseNumberString like '%'+courseNumber+'%' AND pp.programID=req.programID
		GROUP BY tcr.personID, displayValue, tcr.calendarID		
	) AS pReq
	PIVOT (
		SUM(credits)
		FOR [displayValue] in (
			[Algebra I],
			[Algebra II],
			[Biology],
			[Chemistry],
			[DC History],
			[Geometry],
			[Government],
			[Physics],
			[US History],
			[World History]
		)
	) AS courseReqs
) tco ON tco.personID = s.personID AND tco.calendarID = s.calendarID


--Table pco returns the credits for courses a student is currently passing, organized by required course
LEFT JOIN (
	SELECT personID
	, [Algebra I] AS AlgebraIP
	, [Geometry] AS GeometryP
	, [Algebra II] AS AlgebraIIP
	, Biology AS BiologyP
	, Chemistry AS ChemistryP
	, Physics AS PhysicsP
	, [World History] AS WorldHistoryP
	, [US History] AS USHistoryP
	, Government AS GovernmentP
	, [DC History] AS DCHistoryP
	FROM (
		SELECT tcr.personID
		, displayValue
		, sum(creditsEarned) AS creditsEarned
		, calendarID
		FROM (
				SELECT * 
				FROM (
					SELECT r.personID
							, s.calendarID
							, gtc.standardID
							,c.number AS courseNumber
							,CASE 
								WHEN gs.progresspercent>=60.5 THEN gtc.credit 
								WHEN gs.progresspercent<60.5 THEN 0.000
								WHEN gs.progresspercent IS NULL THEN gtc.credit
								END AS creditsEarned
					FROM v_SectionSchedule ss
					JOIN roster r ON ss.sectionID=r.sectionID AND (r.enddate>=getdate() OR r.enddate IS NULL)
					JOIN section sec ON sec.sectionID=r.sectionID
					JOIN course c ON c.courseID=sec.courseID
					JOIN gradingTaskCredit gtc ON gtc.courseID=c.courseID AND gtc.credit IS NOT NULL
					JOIN student s ON r.personID=s.personID AND s.calendarID=ss.calendarID AND s.activeYear = 1 AND s.schoolID = 1
					JOIN calendar cal ON cal.calendarID=ss.calendarID AND cal.endyear=s.endyear  AND cal.summerSchool = 0
					JOIN trial t ON ss.trialID=t.trialID AND t.active=1 
					LEFT JOIN v_GradingScores gs 
						ON gs.sectionID=r.sectionID 
						AND gs.personID=r.personID 
						AND gs.task='Final Grade' 
						--AND gs.termID <> 89   --Excludes courses from the first sememster so that they do not duplicate with the ones posted to the transcript.
				) AS [Current]
			) tcr 
			JOIN ProgramParticipation pp ON pp.personID=tcr.personID
			JOIN CourseRequirement req ON req.courseNumberString like '%'+courseNumber+'%' AND pp.programID=req.programID
			GROUP BY tcr.personID, calendarID, displayValue
	) AS pReq
	PIVOT (
		SUM([creditsEarned])
		FOR [displayValue] in (
			[Algebra I],
			[Algebra II],
			[Biology],
			[Chemistry],
			[DC History],
			[Geometry],
			[Government],
			[Physics],
			[US History],
			[World History]
		)
	) AS courseReqs
) pco ON pco.personID = s.personID AND s.activeYear = 1

--Table fco returns the credits for courses a student is currently failing, organized by required course
LEFT JOIN (
	SELECT personID
	, [Algebra I] AS AlgebraIF
	, [Geometry] AS GeometryF
	, [Algebra II] AS AlgebraIIF
	, Biology AS BiologyF
	, Chemistry AS ChemistryF
	, Physics AS PhysicsF
	, [World History] AS WorldHistoryF	
	, [US History] AS USHistoryF
	, Government AS GovernmentF
	, [DC History] AS DCHistoryF
	FROM (
		SELECT tcr.personID
		, displayValue
		, sum(creditsEarned) AS creditsEarned
		, calendarID
		FROM (
				SELECT * 
				FROM (
					SELECT r.personID
							, s.calendarID
							, gtc.standardID
							,c.number AS courseNumber
							,CASE 
								WHEN gs.progresspercent>=60.5 THEN 0.00 
								WHEN gs.progresspercent<60.5 THEN gtc.credit
								WHEN gs.progresspercent IS NULL THEN 0
								END AS creditsEarned
					FROM v_SectionSchedule ss
					JOIN roster r ON ss.sectionID=r.sectionID AND (r.startdate<=getdate() OR r.startdate IS NULL) AND (r.enddate>=getdate() OR r.enddate IS NULL)
					JOIN section sec ON sec.sectionID=r.sectionID
					JOIN course c ON c.courseID=sec.courseID
					JOIN gradingTaskCredit gtc ON gtc.courseID=c.courseID AND gtc.credit IS NOT NULL
					JOIN student s ON r.personID=s.personID AND s.calendarID=ss.calendarID
					JOIN calendar cal ON cal.calendarID=ss.calendarID AND cal.endyear=s.endyear  AND cal.summerSchool = 0
					JOIN trial t ON ss.trialID=t.trialID AND t.active=1 
					LEFT JOIN v_GradingScores gs ON gs.sectionID=r.sectionID AND gs.personID=r.personID AND task='Final Grade'
					WHERE s.activeYear = 1 AND s.schoolID = 1
				) AS [Current]
			) tcr 
			JOIN ProgramParticipation pp ON pp.personID=tcr.personID
			JOIN CourseRequirement req ON req.courseNumberString like '%'+courseNumber+'%' AND pp.programID=req.programID
			GROUP BY tcr.personID, calendarID, displayValue
	) AS pReq
	PIVOT (
		SUM([creditsEarned])
		FOR [displayValue] in (
			[Algebra I],
			[Algebra II],
			[Biology],
			[Chemistry],
			[DC History],
			[Geometry],
			[Government],
			[Physics],
			[US History],
			[World History]
		)
	) AS courseReqs
) fco ON fco.personID = s.personID AND s.activeYear = 1


--cs table adds in community service hours
LEFT JOIN (
	SELECT s.personID
		, s.calendarID
		, SUM(CAST(cs.value AS FLOAT)) AS [CSHours] 
	FROM student s
	LEFT JOIN customstudent cs on s.personID=cs.personID AND cs.attributeID=527 AND cs.date <= s.calendarEnd
	GROUP BY s.personID, s.calendarID
) AS cs ON cs.personID = s.personID AND cs.calendarID = s.calendarID

	


WHERE s.schoolID = 1 
	AND s.summerSchool = 0
	AND s.Nonpublic = 'N'
	--AND s.calendarID = 46
	--AND s.personID = 796
	--AND s.calendarID IN (34, 37, 40, 46)
	--AND s.activeYear = 1 AND s.ActiveStudent = 'Y' AND s.schoolID = 1

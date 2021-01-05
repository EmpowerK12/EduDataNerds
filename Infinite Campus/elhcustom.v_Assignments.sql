--CREATE VIEW elhcustom.v_Assignments AS 
--ALTER VIEW elhcustom.v_Assignments AS 

/*This view is very simlar to v_GradebookActivityDetail,  but it adds in the Task Name and Term Name, filters
to include only active Trials and removes any scores without a personID. Also hides some columns.
Should be joined on the many side using personCalendarID
ONLY returns assignments for the current school year.
*/


SELECT c.calendarID
	, sc.personID
	, cal.endYear
	--, s.trialID
	--, Trial.active AS activeTrial
	, gr.sectionID
	, ga.taskID
	, gt.name AS taskName
	, ga.termID
	, ga.groupActivityID
	, Term.name AS termName
	, CASE WHEN Term.startDate <= GETDATE() AND Term.endDate >= GETDATE() THEN 'Y' ELSE 'N' END AS activeTerm

	--, gr.groupID
	, gr.name AS groupName
	, CASE gr.name
		WHEN 'Summative' THEN 1
		WHEN 'Formative' THEN 2
		WHEN 'Homework' THEN 3
		WHEN 'Work Hard' THEN 4
		END AS groupOrder
	, gr.weight AS groupWeight
	--, gr.curveID AS groupCurveID
	--, gr.hidePortal AS groupHidePortal
	--, ga.groupActivityID
	--, imlos.objectSectionID
	--,imloss.schedulingSetID
	, imlo.name AS activityName
	, imloss.abbrev
	, imlos.endDate AS dueDate
	, imlos.startDate AS assignedDate
	, ga.scoringType
	, imloss.notGraded
	, ga.totalPoints
	, imlos.active
	, imlos.seq
	--, imlos.hidePortal AS activityHidePortal
	, ga.weight
	, imlob.[content] AS description
	, lpp.groupWeighted AS isWeighted
	, lpp.curveID AS preferenceCurve
	, lpp.usePercent
	, sc.scoreID
	, sc.comments
	, sc.late
	, sc.exempt
	, sc.missing
	, sc.cheated
	, sc.dropped
	, sc.incomplete
	, sc.turnedIn
	, sc.modifiedByID

	, CASE WHEN ga.scoringType != 'p' AND (sc.cheated = 1 OR (sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1)) THEN NULL 
			WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
			ELSE sc.score END 
			AS score
		
	, CASE WHEN ga.scoringType != 'r' AND sc.cheated = 1 AND sc.exempt = 0 AND sc.dropped = 0 THEN 0 
			WHEN ga.scoringType = 'r' AND (sc.cheated = 1 OR sc.missing = 1) THEN NULL 
			WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
			WHEN ga.scoringType != 'r' AND sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1 THEN ROUND(CAST(ISNULL(lpfp.percentage, 0) AS FLOAT) / 100 * ga.totalPoints, 3) 
            WHEN am.[percent] IS NOT NULL THEN NULL 
			WHEN dbo.fn_isNumericScore(sc.score) = 1 THEN CAST(sc.score AS float) 
			ELSE NULL END 
			AS scorePoints
	, CASE WHEN ga.scoringType != 'r' AND sc.cheated = 1 AND sc.exempt = 0 AND sc.dropped = 0 THEN 0 
			WHEN ga.scoringType = 'r' AND (sc.cheated = 1 OR sc.missing = 1) THEN NULL 
			WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
			WHEN ga.scoringType != 'r' AND sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1 THEN CAST(ISNULL(lpfp.percentage, 0) AS FLOAT) / 100 * ga.totalPoints * ga.weight 
			WHEN am.[percent] IS NOT NULL THEN NULL 
			WHEN dbo.fn_isNumericScore(sc.score) = 1 THEN CAST(sc.score AS float) * ga.weight 
			ELSE NULL END 
			AS weightedScore
						 
	,CASE WHEN ga.totalPoints IS NOT NULL THEN ga.totalPoints * ga.weight 
			ELSE NULL END 
			AS weightedTotalPoints
	, CASE WHEN ga.totalPoints IS NOT NULL AND ga.totalPoints > 0 
			THEN (
					CASE WHEN sc.cheated = 1 AND sc.exempt = 0 AND sc.dropped = 0 THEN 0 
					WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
					WHEN sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1 THEN ISNULL(lpfp.percentage, 0) 
					WHEN am.[percent] IS NOT NULL THEN am.[percent] 
					WHEN dbo.fn_isNumericScore(sc.score) = 1 THEN (CAST(sc.score AS float) / ga.totalPoints) * 100 END
				) 
			ELSE NULL END 
			AS percentage
	, CASE WHEN ga.totalPoints IS NOT NULL AND ga.totalPoints > 0 
			THEN (CASE WHEN sc.cheated = 1 AND sc.exempt = 0 AND sc.dropped = 0 THEN 0 
					WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
					WHEN sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1 THEN ISNULL(lpfp.percentage, 0) * ga.weight 
					WHEN am.[percent] IS NOT NULL THEN am.[percent] * ga.weight 
					WHEN dbo.fn_isNumericScore(sc.score) = 1 THEN ((CAST(sc.score AS float) / ga.totalPoints) * 100) * ga.weight END
				) 
			ELSE NULL END AS weightedPercentage
	, CASE WHEN dbo.fn_isNumericScore(sc.score) = 1 
		THEN
        (
		SELECT MAX(cli.score) 
		FROM dbo.CurveListItem cli WITH (NOLOCK) 
		WHERE cli.curveID = COALESCE (gr.curveID, lpp.curveID) 
			AND cli.minPercent = (
									SELECT MAX(minPercent) 
									FROM dbo.CurveListItem cli2 WITH (NOLOCK)
                                    WHERE cli2.curveID = COALESCE (gr.curveID, lpp.curveID) 
										AND cli2.minPercent <= CASE WHEN ga.scoringType != 'r' AND sc.cheated = 1 AND sc.exempt = 0 AND sc.dropped = 0 THEN 0 
																	WHEN ga.scoringType = 'r' AND (sc.cheated = 1 OR sc.missing = 1) THEN NULL 
																	WHEN ((sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1) OR sc.cheated = 1) AND (sc.exempt = 1 OR sc.dropped = 1) THEN NULL 
																	WHEN ga.scoringType != 'r' AND sc.missing = 1 AND ISNULL(lpfp.autoCalculate, 1) = 1 THEN CAST(ISNULL(lpfp.percentage, 0) AS FLOAT) / 100 
																	WHEN am.[percent] IS NOT NULL AND ga.totalPoints IS NOT NULL THEN am.[percent] / 100 
																	WHEN ga.totalPoints IS NOT NULL AND ga.totalPoints > 0 THEN CAST(sc.score AS float) / (ga.totalPoints) 
																	ELSE NULL END * 100
								)
		) 
		ELSE NULL END AS letterGrade
	, CASE 
		WHEN (r.startDate IS NULL OR r.startDate < getdate()) 
		AND (r.endDate IS NULL OR r.endDate >= getdate()) 
		THEN 'Y' ELSE 'N' END 
		AS ActiveRoster
	,CASE WHEN (r.endDate IS NULL OR r.endDate >= (term.endDate - 30)) THEN 'N' ELSE 'Y' END AS EarlyWithdrawal
	,  CAST(sc.personID AS varchar(10)) + '-' + CAST(c.calendarID AS varchar(10)) AS personCalendarID

FROM dbo.LessonPlanGroup AS gr WITH (NOLOCK) 
	INNER JOIN dbo.Section AS s WITH (NOLOCK) ON gr.sectionID = s.sectionID 
	INNER JOIN dbo.Course AS c WITH (NOLOCK) ON s.courseID = c.courseID 
	INNER JOIN dbo.Calendar AS cal WITH (NOLOCK) ON c.calendarID = cal.calendarID 
	LEFT OUTER JOIN dbo.LessonPlanGroupActivity AS ga WITH (NOLOCK) ON gr.groupID = ga.groupID AND s.sectionID = ga.sectionID 
	LEFT OUTER JOIN dbo.IMLearningObjectSection AS imlos WITH (NOLOCK) ON imlos.objectSectionID = ga.objectSectionID AND imlos.sectionID = ga.sectionID 
	LEFT OUTER JOIN dbo.IMLearningObjectSchedulingSet AS imloss WITH (NOLOCK) ON imloss.schedulingSetID = imlos.schedulingSetID 
	LEFT OUTER JOIN dbo.IMLearningObject AS imlo WITH (NOLOCK) ON imlo.objectID = imloss.objectID 
	LEFT OUTER JOIN dbo.IMLearningObjectBlob AS imlob WITH (NOLOCK) ON imlob.blobID = imlo.htmlContentID 
	LEFT OUTER JOIN dbo.LessonPlanScore AS sc WITH (NOLOCK) ON sc.objectSectionID = imlos.objectSectionID AND sc.sectionID = ga.sectionID AND sc.groupActivityID = ga.groupActivityID 
	LEFT OUTER JOIN dbo.AssignmentMark AS am WITH (NOLOCK) ON ga.markGroupID = am.markGroupID AND sc.score = am.score 
	LEFT OUTER JOIN dbo.LessonPlanPreference AS lpp WITH (NOLOCK) ON gr.sectionID = lpp.sectionID AND ga.taskID = lpp.taskID AND (ga.termID = lpp.termID OR ga.termID IS NULL AND lpp.termID IS NULL) 
	LEFT OUTER JOIN dbo.LessonPlanFlagPreference AS lpfp WITH (NOLOCK) ON lpfp.schoolID = cal.schoolID AND lpfp.flagType = 'M'
	LEFT OUTER JOIN dbo.GradingTask gt ON gt.taskID = ga.taskID
	LEFT OUTER JOIN dbo.Term ON Term.termID = ga.termID
	LEFT OUTER JOIN dbo.Trial ON Trial.trialID = s.trialID
	LEFT OUTER JOIN ( 
			SELECT sectionID
			, personID
			, trialID
			, MIN(
				CASE WHEN startdate IS NULL 
					THEN GETDATE () - 10000
					ELSE startdate END
				) AS  startDate
			, MAX(
				CASE WHEN endDate IS NULL 
					THEN GETDATE() + 10000
					ELSE endDate END
				) AS endDate
		FROM dbo.roster 
		--WHERE personID = 912 AND sectionID = 13914
		GROUP BY sectionID
			, personID
			, trialID
		) r ON r.sectionID = s.sectionID AND r.personID = sc.personID AND r.trialID = trial.trialID
		
WHERE Trial.active = 1 
	AND sc.personID IS NOT NULL
	AND cal.enddate >= GETDATE() 
	AND cal.startdate <= GETDATE()
	--AND cal.endyear >= 2019

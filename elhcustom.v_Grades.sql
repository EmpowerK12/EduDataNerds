--Create VIEW elhcustom.v_Grades AS

--ALTER VIEW elhcustom.v_Grades AS

SELECT 
 r.personID
 ,ca.calendarID
 ,ca.schoolID
 ,tl.trialID
 ,tl.active AS ActiveTrial
 ,r.sectionID
 , CASE 
	WHEN MIN(
		CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
		ELSE r.startDate	END
	) = CAST('1950-01-01' AS datetime) THEN NULL
	ELSE  MAX(
		CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
		ELSE r.startDate	END
	) END
	AS rosterStartDate

 , CASE 
	WHEN MAX(
		CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
		ELSE r.endDate	END
	) = CAST('2050-01-01' AS datetime) THEN NULL
	ELSE  MAX(
		CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
		ELSE r.endDate	END
	) 
	END
	AS rosterEndDate

 ,CASE 
	WHEN (
		(
			(
				CASE 
					WHEN MIN(
						CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
						ELSE r.startDate	END
					) = CAST('1950-01-01' AS datetime) THEN NULL
					ELSE  MAX(
						CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
						ELSE r.startDate	END
					) 
				END
			) IS NULL 
			OR (
				CASE 
					WHEN MIN(
						CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
						ELSE r.startDate	END
					) = CAST('1950-01-01' AS datetime) THEN NULL
					ELSE  MAX(
						CASE WHEN r.startDate IS NULL THEN CAST('1950-01-01' AS datetime)
						ELSE r.startDate	END
					) 
				END
			) < getdate()
		) 
		AND (
			(
				CASE 
					WHEN MAX(
						CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
						ELSE r.endDate	END
					) = CAST('2050-01-01' AS datetime) THEN NULL
					ELSE  MAX(
						CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
						ELSE r.endDate	END
					) 
				END
			) IS NULL 
			OR (
				CASE 
					WHEN MAX(
						CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
						ELSE r.endDate	END
					) = CAST('2050-01-01' AS datetime) THEN NULL
					ELSE  MAX(
						CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
						ELSE r.endDate	END
					) 
				END
			)>= getdate()
		) 
	)
	THEN 'Y' ELSE 'N' END AS ActiveRoster
 ,CASE 
	WHEN (
		(
			CASE 
				WHEN MAX(
					CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
					ELSE r.endDate	END
				) = CAST('2050-01-01' AS datetime) THEN NULL
				ELSE  MAX(
					CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
					ELSE r.endDate	END
				) 
			END
		) IS NULL 
		OR (
			CASE 
				WHEN MAX(
					CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
					ELSE r.endDate	END
				) = CAST('2050-01-01' AS datetime) THEN NULL
				ELSE  MAX(
					CASE WHEN r.endDate IS NULL THEN CAST('2050-01-01' AS datetime)
					ELSE r.endDate	END
				) 
			END		
		) >= (tm.endDate - 30)
	) THEN 'N' 	
	ELSE 'Y' 	
	END AS EarlyWithdrawal
 ,tm.termID
 ,tm.name AS termName 
 , tm.endDate AS termEndDate
 , CASE WHEN tm.startDate <= GETDATE() AND tm.endDate >= GETDATE() THEN 'Y' ELSE 'N' END AS activeTerm

 ,gt.taskID 
 ,gt.name AS TaskName
 ,gs.progressPercent
 ,gs.progressScore
  , CASE gs.progressScore
	WHEN 'F' THEN -1
	WHEN 'D-' THEN 1
	WHEN 'D' THEN 2
	WHEN 'D+' THEN 3
	WHEN 'C-' THEN 4
	WHEN 'C' THEN 5
	WHEN 'C+' THEN 6
	WHEN 'B-' THEN 7
	WHEN 'B' THEN 8
	WHEN 'B+' THEN 9
	WHEN 'A-' THEN 10
	WHEN 'A' THEN 11
	WHEN 'A+' THEN 12
	WHEN 'NY' THEN -1
	WHEN 'E' THEN 5
	WHEN 'P' THEN 8
	WHEN 'M' THEN 11
	ELSE NULL END AS progressScoreSort
 ,gs.progressPointsEarned
 ,gs.progressTotalPoints
 ,gs.comments

 ,gs.date AS PostedDate
 ,gs.[percent]
 ,gs.score
 , CASE gs.score
	WHEN 'F' THEN -1
	WHEN 'D-' THEN 1
	WHEN 'D' THEN 2
	WHEN 'D+' THEN 3
	WHEN 'C-' THEN 4
	WHEN 'C' THEN 5
	WHEN 'C+' THEN 6
	WHEN 'B-' THEN 7
	WHEN 'B' THEN 8
	WHEN 'B+' THEN 9
	WHEN 'A-' THEN 10
	WHEN 'A' THEN 11
	WHEN 'A+' THEN 12
	WHEN 'NY' THEN -1
	WHEN 'E' THEN 5
	WHEN 'P' THEN 8
	WHEN 'M' THEN 11
	ELSE NULL END AS scoreSort

 ,gs.modifiedDate AS LastModified
 ,sl.name AS scoreListItemName
 ,sl.seq AS scoreListItemSeq
 ,sl.passingScore

 ,sg.scoreGroupID
 ,cs1.name AS creditType
 ,cs1.standardID
  ,gtc.credit
 ,gt.transcript
 ,gtc.termGPA
 , sl.gpaValue
 , sl.unweightedGPAValue
 ,CAST(r.personID AS varchar(10)) + '-' + CAST(c.calendarID AS varchar(10)) AS PersonCalendarID
 , sg.name AS scoreGroup

FROM dbo.Roster r
	JOIN dbo.Section sec ON sec.sectionID = r.sectionID AND sec.trialID = r.trialID
	JOIN dbo.Trial tl ON tl.trialID = r.trialID AND tl.trialID = sec.trialID AND tl.active=1
	JOIN dbo.Course c ON c.courseID = sec.courseID AND tl.calendarID = c.calendarID
	JOIN dbo.SectionPlacement sp ON sp.sectionID = sec.sectionID AND sp.trialID = tl.trialID
	--JOIN dbo.Period pd ON pd.periodID = sp.periodID 
	--JOIN dbo.periodschedule ps ON ps.periodscheduleID = pd.periodscheduleID AND tl.structureID = ps.structureID AND ps.seq=1
	JOIN dbo.term tm ON tm.termID = sp.termID
	JOIN dbo.GradingTaskCredit gtc ON gtc.courseID = c.courseID AND gtc.calendarID = c.calendarID
	JOIN dbo.GradingTask gt ON gt.taskID = gtc.taskID
	LEFT JOIN dbo.GradingScore gs ON gs.personID = r.personID AND gs.calendarID = c.calendarID AND gs.sectionID = sec.sectionID AND gs.taskID = gt.taskID AND (gs.termID = tm.termID OR gs.termID IS NULL)

	JOIN dbo.Calendar ca ON ca.calendarID = c.calendarID
	LEFT JOIN dbo.Department d ON d.departmentID = c.departmentID
	LEFT OUTER JOIN dbo.CurriculumStandard AS cs1 WITH (NOLOCK) ON COALESCE (gtc.standardID, gt.standardID) = cs1.standardID 
	INNER JOIN dbo.ScoreGroup AS sg WITH (NOLOCK) ON sg.scoreGroupID = COALESCE (gtc.scoreGroupID, cs1.scoreGroupID) 
	LEFT OUTER JOIN dbo.ScoreListItem AS sl WITH (NOLOCK) ON sl.scoreGroupID = sg.scoreGroupID AND sl.score = gs.score
	

WHERE 1=1	
	

GROUP BY r.personID
 ,ca.calendarID
 ,ca.schoolID
 ,tl.trialID
 ,tl.active 
 ,r.sectionID
 ,tm.termID
 ,tm.name 
 , tm.startDate
 ,gt.taskID 
 ,gt.name 
 ,gs.progressPercent
 ,gs.progressScore
  ,  gs.progressScore
 ,gs.progressPointsEarned
 ,gs.progressTotalPoints
 ,gs.comments

 ,gs.date 
 ,gs.[percent]
 ,gs.score
 , gs.score
 ,gs.modifiedDate 
 ,sl.name
 ,sl.seq
 ,sl.passingScore
 ,sg.scoreGroupID
 ,cs1.name
 ,cs1.standardID
  ,gtc.credit
 ,gt.transcript
 ,gtc.termGPA
 , sl.gpaValue
 , sl.unweightedGPAValue
, c.calendarID
, tm.endDate
, sg.name
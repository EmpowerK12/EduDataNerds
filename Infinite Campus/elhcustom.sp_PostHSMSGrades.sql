--ALTER PROCEDURE elhcustom.sp_PostHSMSGrades AS
--UPDATE gs
SET gs.[percent] = g.progressPercent
	, gs.score = g.progressScore
	, gs.date = GETDATE()
	, gs.modifiedDate = GETDATE()
--SELECT g.progressPercent, g.progressScore, getdate(), g.score, g.[percent], *
FROM elhcustom.v_grades g
JOIN gradingscore gs 
	ON gs.personID = g.personID 
	AND gs.calendarID = g.calendarID 
	AND gs.sectionID = g.sectionID 
	AND gs.taskID = g.taskID 
	AND (gs.termID = g.termID OR gs.termID IS NULL)
WHERE 1=1
	AND g.activeTerm = 'Y'   --------------------------------------TURN THIS BACK OFF AFTER Q2 Ends 
	AND g.calendarID IN (60, 62)
	AND g.TaskName = 'Quarter Grade'
	AND g.activeRoster = 'Y'
	--AND (gs.[percent] <> g.progresspercent OR gs.[percent] IS NULL OR gs.score <> g.progressScore OR gs.score IS NULL)

--GO


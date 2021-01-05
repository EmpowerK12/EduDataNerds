--Create VIEW elhcustom.v_GPAs AS
--ALTER VIEW elhcustom.v_GPAs AS

SELECT s.personID
		, s.calendarID
		, s.PersonCalendarID
		, f.cumGpaBasic AS cumGPA
		, f.cumGpaUnweighted AS CumUnweighted
		,tg.term1GPA AS Q1TermPosted
		,tg.term2GPA AS Q2TermPosted
		,tg.term3GPA AS Q3TermPosted
		,tg.term4GPA AS Q4TermPosted
		,tc.gpa AS CurrentTermProgress
		,yq.GPA AS YearlyProgress
		,yg.cumGpaBasic AS YearlyTranscript
		,rc.GPA AS RollingCum
		, rc.unweightedGPA AS RollingCumUnweighted
		, rgco.unweightedGPA AS RollingCumUnweightedCoreOnly
		, s.endYear
		, s.grade
		, s.ActiveYear
		, s.summerSchool


FROM elhcustom.v_student s

JOIN dbo.v_TermGPA tg ON tg.calendarID = s.calendarID AND tg.personid = s.personID
LEFT JOIN dbo.v_cumgpa cg ON cg.calendarID = s.calendarID AND cg.personID = s.personID
LEFT OUTER JOIN dbo.v_CumGPAFull AS f ON f.calendarID = s.calendarID AND f.personID = s.personID 
LEFT JOIN elhcustom.v_GPAYearlyByQuarter yq ON yq.personID = s.personID AND yq.calendarID = s.calendarID AND yq.term = 'Q4'
LEFT JOIN elhcustom.v_GpaTermCalcUnroundedCurrentInProgress tc ON tc.calendarID = s.calendarID AND tc.personID = s.personid
LEFT JOIN dbo.v_RollingCumGPA rc ON rc.calendarID = s.calendarID AND rc.personID = s.personID AND rc.termName = 'Q4'
LEFT JOIN elhcustom.v_yearlyGPAfromTranscript yg ON yg.personID = s.personID AND yg.endYear = s.endYear
LEFT JOIN elhcustom.v_RollingcumGPACoreONly rgco ON rgco.personID = s.personID AND rgco.calendarID = s.calendarID AND rgco.termName = 'Q4'
WHERE s.schoolID IN(1, 4)

/* This view shows one line for each staff member for each school (staff can repeat, but not at the same school). 
It returns the assignment with the most recent start date at each school. 
Unique key is called PersonSchoolID
*/

--Create VIEW elhcustom.v_Staff AS
--ALTER VIEW elhcustom.v_Staff AS

SELECT i.personID AS staffPersonID
	, (i.lastName + ', ' + i.firstName) AS 'Staff Name'
	, i.lastName
	,i.firstName
	,i.staffNumber 
	,i.gender
	,e.employmentID
	,ea.assignmentID
	,ea.title
	,ea.titlecode
	, gradeLevel.value AS gradeLevel
	, subj.value AS subjectArea
	,ce.value AS associateID
	, c.email
	,c.cellPhone
	,c.workPhone
	,c.homePhone

	,ea.schoolID
	,school.name AS 'School'
	,ea.startDate
	,ea.endDate
	,CASE WHEN (ea.endDate IS NULL OR ea.endDate > GETDATE() ) AND (ea.startDate IS NULL OR ea.startDate < GETDATE() ) THEN 1 ELSE 0 END AS 'CurrentAssignment?'
	, sup1.personID AS supervisor1PersonID
	, ea1.assignmentID AS supervisor1AssignmentID
	, (sup1.lastName + ', ' + sup1.firstName) AS 'Supervisor 1 Name'
	, supEmail.email AS Sup1Email
	, (sup2.lastName + ', ' + sup2.firstName) AS 'Supervisor 2 Name'
	, (sup3.lastName + ', ' + sup3.firstName) AS 'Supervisor 3 Name'

	,ea.teacher
	,ea.specialed
	,ea.behavior
	,ea.health
	,ea.advisor
	,ea.supervisor
	,ea.foodservice
	,ea.counselor
	,ea.fte
	,ea.PersonSchoolID
FROM 
		(SELECT personID
			,assignmentID
			,title
			,titlecode
			,schoolID
			,startDate
			,endDate
			,ROW_NUMBER() over (partition by personID, schoolID order by startdate desc) as rn
			,  CAST(personID AS varchar(10)) + '-' + CAST(schoolID AS varchar(10)) AS PersonSchoolID
			,teacher
			,specialed
			,behavior
			,health
			,advisor
			,supervisor
			,foodservice
			,counselor
			,fte
		FROM EmploymentAssignment ) ea
JOIN dbo.Individual i ON i.personID = ea.personID
LEFT JOIN dbo.contact c ON c.personID = ea.personID
LEFT JOIN (
	SELECT sub.AssignmentID
		, MAX( CASE WHEN sub.SupervisorNumber = 1 THEN sub.assignmentSupervisorID ELSE NULL END) AS Sup1
		, MAX( CASE WHEN sub.SupervisorNumber =2 THEN sub.assignmentSupervisorID ELSE NULL END) AS Sup2
		, MAX( CASE WHEN sub.SupervisorNumber = 3 THEN sub.assignmentSupervisorID ELSE NULL END) AS Sup3
	FROM (
		SELECT *
			,   RANK() OVER (PARTITION BY AssignmentID ORDER BY assignmentsupervisorID) AS SupervisorNumber 
		FROM dbo.EmploymentAssignmentSupervisor
	) sub
	GROUP BY sub.AssignmentID 
) eas 
	ON eas.assignmentID = ea.assignmentID  --Brings in Teacher's Supervisor's Employment Assignment

LEFT JOIN dbo.EmploymentAssignment ea1 ON ea1.assignmentID = eas.Sup1 AND (ea1.endDate IS NULL OR ea1.endDate > GETDATE() ) --Brings in Supervisor 1's Employment Assignmnet
LEFT JOIN dbo.EmploymentAssignment ea2 ON ea2.assignmentID = eas.Sup2 AND (ea2.endDate IS NULL OR ea2.endDate > GETDATE() ) --Brings in Supervisor 2's Employment Assignmnet
LEFT JOIN dbo.EmploymentAssignment ea3 ON ea3.assignmentID = eas.Sup3 AND (ea3.endDate IS NULL OR ea3.endDate > GETDATE() ) --Brings in Supervisor 3's Employment Assignmnet
left JOIN dbo.individual sup1 ON sup1.personID = ea1.personID --Brings in Supervisor 1's information
left JOIN dbo.individual sup2 ON sup2.personID = ea2.personID --Brings in Supervisor 2's information
left JOIN dbo.individual sup3 ON sup3.personID = ea3.personID --Brings in Supervisor 3's information
LEFT JOIN dbo.contact supEmail ON supEmail.personID = sup1.personID
LEFT Join dbo.School ON school.schoolID = ea.schoolID
LEFT JOIN dbo.Employment e ON e.personID = ea.personID AND (e.enddate IS NULL OR e.enddate >= getdate())
LEFT JOIN CustomEmployment ce ON ce.personID = ea.personID AND ce.employmentID = e.employmentID AND ce.attributeID = 1261
LEFT JOIN CustomEmploymentAssignment gradeLevel ON gradeLevel.assignmentID = ea.assignmentID AND gradeLevel.attributeID = 1263
LEFT JOIN CustomEmploymentAssignment subj ON subj.assignmentID = ea.assignmentID AND subj.attributeID = 1264

WHERE ea.rn = 1
	AND (ea.titlecode <> 'UD74' OR ea.titleCode IS NULL)
 
--order by i.personID

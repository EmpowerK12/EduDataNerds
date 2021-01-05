--ALTER VIEW elhcustom.v_ParentEngagements AS 

--The first section of the query pulls in data from the "contact log" tab 
--in IC front end. The data is saved in the customstudent table.


SELECT Details.personID
	, cal.calendarID
	,Details.date
	,ContactedBy.value AS 'ContactedBy'
	, PersonContacted.value AS 'PersonContacted'
	, CONCAT(
		Details.value
		, Details2.value
		, Details3.value
		, CASE WHEN Duration.value IS NULL THEN '' ELSE CONCAT(' Duration: ', Duration.value, ' min.') END
		, CASE WHEN Q1d.name IS NULL THEN '' ELSE CONCAT(', Q1: ', Q1d.name) END
		, CASE WHEN A1d.name IS NULL THEN '' ELSE CONCAT(', A1: ', A1d.name) END
		, CASE WHEN Q2d.name IS NULL THEN '' ELSE CONCAT(', Q2: ', Q2d.name) END
		, CASE WHEN A2d.name IS NULL THEN '' ELSE CONCAT(', A2: ', A2d.name) END
		, CASE WHEN Q3d.name IS NULL THEN '' ELSE CONCAT(', Q3: ', Q3d.name) END
		, CASE WHEN A3d.name IS NULL THEN '' ELSE CONCAT(', A3: ', A3d.name) END
	) AS Details
	, ContactType.value AS 'ContactType'
	, 'General' AS Module
	,NULL AS EventCode
	,NULL AS EventName
	,NULL AS EndDate
	,NULL AS Goal
	,NULL AS Outcome
	,ContactStatusd.name AS 'contactStatus'
FROM dbo.CustomStudent Details
LEFT JOIN (
		SELECT e.personID, cal.calendarID, cal.startdate, cal.enddate, cal.summerSchool, cal.name
		FROM dbo.enrollment e 
		JOIN dbo.Calendar cal ON cal.calendarID = e.calendarID 
		) cal ON cal.personID = Details.personID AND cal.startdate <= Details.date AND cal.enddate >= Details.date AND cal.summerSchool = 0 AND cal.name NOT LIKE '%ELH%'
LEFT JOIN dbo.CustomStudent ContactedBy ON ContactedBy.date = Details.date AND ContactedBy.personID = Details.personID AND ContactedBy.attributeID = 895
LEFT JOIN dbo.CustomStudent ContactType ON ContactType.date = Details.date AND ContactType.personID = Details.personID AND ContactType.attributeID = 893
LEFT JOIN dbo.CustomStudent PersonContacted ON PersonContacted.date = Details.date AND PersonContacted.personID = Details.personID AND PersonContacted.attributeID = 894
LEFT JOIN dbo.CustomStudent Details2 ON Details2.date = Details.date AND Details2.personID = Details.personID AND Details2.attributeID = 1172             
LEFT JOIN dbo.CustomStudent Details3 ON Details3.date = Details.date AND Details3.personID = Details.personID AND Details3.attributeID = 1173        
LEFT JOIN dbo.CustomStudent Duration ON Duration.date = Details.date AND Duration.personID = Details.personID AND Duration.attributeID = 1193             
LEFT JOIN dbo.CustomStudent ContactStatus ON ContactStatus.date = Details.date AND ContactStatus.personID = Details.personID AND ContactStatus.attributeID = 1197
     LEFT JOIN dbo.CampusDictionary ContactStatusd ON ContactStatusd.code = ContactStatus.value AND ContactStatusd.attributeID = ContactStatus.attributeID            
LEFT JOIN dbo.CustomStudent Q1 ON Q1.date = Details.date AND Q1.personID = Details.personID AND Q1.attributeID = 1198 
	LEFT JOIN dbo.CampusDictionary Q1d ON Q1d.code = Q1.value AND Q1d.attributeID = Q1.attributeID            
LEFT JOIN dbo.CustomStudent Q2 ON Q2.date = Details.date AND Q2.personID = Details.personID AND Q2.attributeID = 1199             
     LEFT JOIN dbo.CampusDictionary Q2d ON Q2d.code = Q2.value AND Q2d.attributeID = Q2.attributeID            
LEFT JOIN dbo.CustomStudent Q3 ON Q3.date = Details.date AND Q3.personID = Details.personID AND Q3.attributeID = 1202             
     LEFT JOIN dbo.CampusDictionary Q3d ON Q3d.code = Q3.value AND Q3d.attributeID = Q3.attributeID            
LEFT JOIN dbo.CustomStudent A1 ON A1.date = Details.date AND A1.personID = Details.personID AND A1.attributeID = 1200             
     LEFT JOIN dbo.CampusDictionary A1d ON A1d.code = A1.value AND A1d.attributeID = A1.attributeID            
LEFT JOIN dbo.CustomStudent A2 ON A2.date = Details.date AND A2.personID = Details.personID AND A2.attributeID = 1201             
     LEFT JOIN dbo.CampusDictionary A2d ON A2d.code = A2.value AND A2d.attributeID = A2.attributeID            
LEFT JOIN dbo.CustomStudent A3 ON A3.date = Details.date AND A3.personID = Details.personID AND A3.attributeID = 1203             
     LEFT JOIN dbo.CampusDictionary A3d ON A3d.code = A3.value AND A3d.attributeID = A3.attributeID            
WHERE Details.attributeID = 896

UNION

--The second part of the query pulls in data from the ContactLog table, which is part of the Counseling or PLP modules in IC
--Some of this data is sensitive, so Counseling notes are redacted.
select cl.PersonID
	, cal.calendarID
	,cl.dateTimeStamp as Date
	
	,CONCAT(i.firstName, ' ', i.lastName) AS 'ContactedBy'
	,NULL AS 'PersonContacted'
	,CASE WHEN cl.module = 'counseling' THEN 'Redacted' ELSE cl.text END AS Details
	,CASE WHEN cl.contactType = 1 THEN 'Call' WHEN cl.contactType = 2 THEN 'Letter' WHEN cl.contactType = 3 THEN 'email' WHEN cl.contactType = 4 THEN 'In Person' ELSE 'Other' END AS 'ContactType'
	,cl.module AS Module
	,NULL AS EventCode
	,NULL AS EventName
	,NULL AS EndDate
	,NULL AS Goal	
	,NULL AS Outcome
	,NULL AS 'contactStatus'
FROM dbo.ContactLog cl
LEFT JOIN dbo.individual i ON i.personID = cl.contactByID
LEFT JOIN (
		SELECT e.personID, cal.calendarID, cal.startdate, cal.enddate, cal.summerSchool, cal.name
		FROM dbo.enrollment e 
		JOIN dbo.Calendar cal ON cal.calendarID = e.calendarID 
		) cal ON cal.personID = cl.personID AND cal.startdate <= cl.dateTimeStamp AND cal.enddate >= cl.dateTimeStamp AND cal.summerSchool = 0 AND cal.name NOT LIKE '%ELH%'

UNION

--The third part of the query pulls in data from the Parent Engagement tab in IC, which saves the data in CustomStudent
SELECT cs.personID
	, cal.calendarID
	, cs.date AS date
	, NULL AS 'ContactedBy'
	, NULL AS 'PersonContacted'
	,csc.value AS 'Details'
	,'Event' AS 'ContactType'
	,NULL AS 'Module'
	, cs.value AS EventCode
	, cd.name AS  EventName
	,NULL AS EndDate
	,NULL AS Goal
	,NULL AS Outcome
	,NULL AS 'contactStatus'
FROM dbo.CustomStudent cs 
LEFT JOIN dbo.CustomStudent csc ON csc.personID = cs.personID AND csc.date = cs.date  AND csc.attributeID = 763
LEFT JOIN dbo.customstudent csd ON csd.personID = cs.personID AND csd.date = cs.date AND csd.attributeID = 764
LEFT JOIN (
		SELECT e.personID, cal.calendarID, cal.startdate, cal.enddate, cal.summerSchool, cal.name
		FROM dbo.enrollment e 
		JOIN dbo.Calendar cal ON cal.calendarID = e.calendarID 
		) cal ON cal.personID = cs.personID AND cal.startdate <= cs.date AND cal.enddate >= cs.date AND cal.summerSchool = 0 AND cal.name NOT LIKE '%ELH%'
LEFT JOIN dbo.CampusDictionary cd ON cd.attributeID = cs.attributeID AND cd.code = cs.value
WHERE cs.attributeID = 762

UNION

--The fourth part of the query pulls in data from the ELH Intervention tab of IC, which saves its data in CustomStudent
select intervention.personID, cal.calendarID
	, intervention.date
	,ProvidedBy.value as 'ContactedBy'
	,NULL AS 'PersonContacted'
	,description.value as Details
	,CASE WHEN dict2.[name] IS NULL THEN 'Intervention' ELSE (CAST(dict2.[name] AS varchar(50)) + ' Intervention') END as 'ContactType'
	, NULL AS Module
	,intervention.value as EventCode
	,dict.[name] AS EventName
	,EndDate.value as 'EndDate'
	,Goal.value as 'Goal'
	,Outcome.name AS Outcome
	,NULL AS 'contactStatus'
FROM dbo.customstudent intervention 
LEFT JOIN (
		SELECT e.personID, cal.calendarID, cal.startdate, cal.enddate, cal.summerSchool, cal.name
		FROM dbo.enrollment e 
		JOIN dbo.Calendar cal ON cal.calendarID = e.calendarID 
		) cal ON cal.personID = intervention.personID AND cal.startdate <= intervention.date AND cal.enddate >= intervention.date AND cal.summerSchool = 0 AND cal.name NOT LIKE '%ELH%'
LEFT JOIN dbo.CampusDictionary dict ON dict.code = intervention.[value] AND dict.attributeID = intervention.attributeID
LEFT JOIN dbo.customstudent description ON description.personID = intervention.personID AND description.date = intervention.date AND description.attributeID = 597
LEFT JOIN dbo.customstudent Type ON Type.personID = intervention.personID AND Type.date = intervention.date AND Type.attributeID = 596
LEFT JOIN dbo.CampusDictionary dict2 ON dict2.code = Type.[value] AND dict2.attributeID = Type.attributeID
LEFT JOIN dbo.customstudent EndDate ON EndDate.personID = intervention.personID AND EndDate.date = intervention.date AND EndDate.attributeID = 948
LEFT JOIN dbo.customstudent Goal ON Goal.personID = intervention.personID AND Goal.date = intervention.date AND Goal.attributeID = 598
LEFT JOIN dbo.customstudent OutcomeStatus ON OutcomeStatus.personID = intervention.personID AND OutcomeStatus.date = intervention.date AND OutcomeStatus.attributeID = 599
LEFT JOIN dbo.CampusDictionary Outcome ON Outcome.attributeID = OutcomeStatus.attributeID AND OutcomeStatus.value = Outcome.code
LEFT JOIN dbo.customstudent ProvidedBy ON ProvidedBy.personID = intervention.personID AND ProvidedBy.date = intervention.date AND ProvidedBy.attributeID = 600

WHERE intervention.attributeID = 949


UNION

--The Fifth part of the query pulls in data from the COVID-19 Attendance in the gradebook

SELECT 
	s.personID
	, s.calendarID
	, ass.assignedDate AS [date]
	, st.[Staff Name] AS ContactedBy
	, s.FullName AS PersonContacted
	, CONCAT(
		'Course: '
		, sec.coursename
		, CASE WHEN ass.comments IS NOT NULL 
			THEN CONCAT(' - ' , ass.comments)
			ELSE ''
			END		
		) AS Details
	, 'Distance Learning' AS ContactType
	, 'COVID-19 Attendance' AS Module
	,NULL AS EventCode
	,NULL AS EventName
	,NULL AS EndDate
	,NULL AS Goal
	,NULL AS Outcome
	,NULL AS 'contactStatus'
FROM (
	SELECT  c.calendarID
		, sc.personID
		, sc.modifiedByID
		, sc.score
		, ga.taskID
		, sc.sectionID
		, sc.comments
		, imlos.startdate AS assignedDate
		, gr.name AS groupName
	FROM dbo.LessonPlanGroup AS gr WITH (NOLOCK) 
	INNER JOIN dbo.Section AS s WITH (NOLOCK) ON gr.sectionID = s.sectionID 
	INNER JOIN dbo.Course AS c WITH (NOLOCK) ON s.courseID = c.courseID 
	INNER JOIN dbo.Calendar AS cal WITH (NOLOCK) ON c.calendarID = cal.calendarID 
	LEFT OUTER JOIN dbo.LessonPlanGroupActivity AS ga WITH (NOLOCK) ON gr.groupID = ga.groupID AND s.sectionID = ga.sectionID 
	LEFT OUTER JOIN dbo.IMLearningObjectSection AS imlos WITH (NOLOCK) ON imlos.objectSectionID = ga.objectSectionID AND imlos.sectionID = ga.sectionID
	LEFT OUTER JOIN dbo.LessonPlanScore AS sc WITH (NOLOCK) ON sc.objectSectionID = imlos.objectSectionID AND sc.sectionID = ga.sectionID AND sc.groupActivityID = ga.groupActivityID 
) ass
JOIN elhcustom.v_Section sec ON sec.sectionID = ass.sectionID
JOIN elhcustom.v_staff st ON st.staffpersonID = ass.modifiedByID
JOIN elhcustom.v_Student s ON s.personID = ass.personID AND s.calendarID = ass.calendarID
WHERE ass.groupName = 'COVID-19 Attendance'
	AND ass.score > '0'

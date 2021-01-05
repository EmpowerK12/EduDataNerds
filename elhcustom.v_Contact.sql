--Create VIEW elhcustom.v_Contact AS
--ALTER VIEW elhcustom.v_Contact AS
SELECT s.personID, s.FullName, s.grade, s.calendarID
		, c.cellPhone AS StudentCell
		, c.email AS studentEmail
		,CONCAT(i1.lastName, ', ', i1.firstName) AS firstGuardianName
		, i1.firstName AS firstGuardianFirstName
		, i1.lastname AS firstGuardianLastName
		, i1.personID AS firstGuardianPersonID
		,COALESCE(cg1.cellPhone, cg1.homePhone, cg1.workphone) AS firstGuardianPhone
		,cg1.email AS firstGuardianEmail
		,sg1.name AS firstGuardianRelationship
		,CASE WHEN i2.firstName IS NOT NULL THEN CONCAT(i2.lastName, ', ', i2.firstName) ELSE i2.firstName END AS secondGuardianName 
		, i2.firstName AS secondGuardianFirstName
		, i2.lastname AS secondGuardianLastName
		, i2.personID AS secondGuardianPersonID
		,COALESCE(cg2.cellPhone, cg2.homePhone, cg2.workphone) AS secondGuardianPhone
		,cg2.email AS secondGuardianEmail
		,sg2.name AS secondGuardianRelationship
		,h.householdID as householdID
		, sih1.StudentsInHousehold AS currentStudentsInHousehold
		--, siblings.Siblings
		, h.name AS householdName
		, a.number AS streetNumber, a.prefix AS streetPrefix, a.street AS streetName, a.tag AS streetTag, a.dir as streetDir, a.apt, a.city, a.state, a.zip
		, CASE WHEN a.postOfficeBox = 1 THEN 'PO Box ' + a.number 
			ELSE 
				COALESCE (a.number + ' ', '') 
				+ COALESCE (a.prefix + ' ', '') 
				+ COALESCE (a.street + ' ', '') 
				+ COALESCE (a.tag + ' ', '') 
				+ COALESCE (a.dir + ' ', '') 
				+ COALESCE (CASE WHEN COALESCE (a.apt, '') <> '' AND LEFT(a.apt, 1) <> '#' THEN '#' + a.apt ELSE a.apt END, '') 
			END AS addressLine1
		, COALESCE (a.city + ', ', '') 
			+ COALESCE (a.state + ' ', '') 
			+ CASE WHEN LEN(a.zip) = 9 THEN LEFT(a.zip, 5) + '-' + RIGHT(a.zip, 4) ELSE COALESCE (a.zip, '') 
			END AS addressLine2
		, ward.value AS Ward
		, a.latitude
		,a.longitude
		, CASE WHEN cr.contactRestriction IS NULL THEN 'None' ELSE cr.contactRestriction END AS contactRestriction
		, pp.translationLanguage
		,s.PersonCalendarID

FROM elhcustom.v_Student s
LEFT JOIN dbo.Contact c ON c.personID = s.personID
LEFT JOIN (
	--This query returns the household ID for the most recently added household, ranked by memberID.
	SELECT personID, memberID, householdID, startDate, enddate
		, RANK () OVER (PARTITION BY personID ORDER BY memberID asc) AS Rank
	FROM (
		--This Query returns the householdID ranked by how recently they were added.
		SELECT  personID, memberID, householdID, startDate, enddate
			, RANK () OVER (PARTITION BY personID ORDER BY startDate DESC) AS Rank
		FROM dbo.HouseholdMember hm
		WHERE (hm.enddate IS NULL OR hm.enddate > getdate()) AND hm.secondary = 0
		) hm1
	WHERE hm1.Rank = 1
) hm2 ON hm2.personID = s.personID AND hm2.Rank = 1

LEFT JOIN dbo.household h ON h.householdID = hm2.householdID
LEFT JOIN (
	SELECT locationID, householdID, addressID
		, RANK() OVER (PARTITION BY householdID ORDER BY modifieddate desc, startDate desc, addressID) AS Rank
	FROM dbo.HouseholdLocation
	WHERE (enddate IS NULL OR enddate > getdate()) AND secondary = 0
) hl ON hl.householdID = h.householdID AND hl.Rank = 1

LEFT JOIN dbo.[Address] a ON a.addressID = hl.addressID

LEFT JOIN (
		select s.personID, s.calendarID, rp.personID2, rp.name, RANK() OVER (PARTITION BY s.personID, s.calendarID ORDER BY rp.seq, rp.personID2) AS Rank
		FROM dbo.student s
		JOIN dbo.RelatedPair rp ON rp.personID1 = s.personID AND rp.guardian = 1
	) sg1 ON sg1.personID = s.personID AND sg1.calendarID = s.calendarID AND sg1.Rank = 1
	
LEFT JOIN dbo.individual i1 ON i1.personID = sg1.personID2
LEFT JOIN dbo.Contact cg1 ON cg1.personID = sg1.personID2

LEFT JOIN (
		select s.personID, s.calendarID, rp.personID2, rp.name, RANK() OVER (PARTITION BY s.personID, s.calendarID ORDER BY rp.seq, rp.personID2) AS Rank
		FROM dbo.student s
		JOIN dbo.RelatedPair rp ON rp.personID1 = s.personID AND rp.guardian = 1
	) sg2 ON sg2.personID = s.personID AND sg2.calendarID = s.calendarID AND sg2.Rank = 2
	
LEFT JOIN dbo.individual i2 ON i2.personID = sg2.personID2
LEFT JOIN dbo.Contact cg2 ON cg2.personID = sg2.personID2
LEFT JOIN (
		SELECT ward.addressID, ward.value, RANK () OVER (PARTITION BY ward.addressID ORDER BY ward.date DESC, ward.customID DESC) AS Rank
		FROM dbo.CustomAddress ward 
		WHERE ward.attributeID = 528
		) ward ON ward.addressID = a.addressID AND ward.Rank = 1

LEFT JOIN (
	SELECT COUNT(s.personID) AS StudentsInHousehold
		, hm.householdID
	FROM elhcustom.v_Student s
		JOIN HouseholdMember hm ON hm.personID = s.personID 
			AND hm.secondary = 0
			AND (hm.endDate IS NULL OR hm.endDate > GETDATE())
			AND s.ActiveStudent = 'Y'
	GROUP BY hm.householdID
) sih1 ON sih1.householdID = h.householdID

LEFT JOIN (
	SELECT 
	  personID,
	  STUFF(
		(
			SELECT ', ' + userWarning 
			FROM (
				SELECT DISTINCT personID, userWarning
				FROM programParticipation pp 
				WHERE pp.programID = 4
				AND (pp.startdate IS NULL OR pp.startDate <= GETDATE())
				AND (pp.enddate IS NULL OR pp.enddate > GETDATE())
				
			) sub
			WHERE (personID = cr.personID) 
			FOR XML PATH('') , TYPE
		).value('(./text())[1]','VARCHAR(MAX)')
		, 1
		, 2
		, ''
	  ) AS contactRestriction

	FROM (
		SELECT DISTINCT personID, userWarning
		FROM programParticipation pp 
		WHERE pp.programID = 4
		AND (pp.startdate IS NULL OR pp.startDate <= GETDATE())
		AND (pp.enddate IS NULL OR pp.enddate > GETDATE())
	) cr
	GROUP BY personID
) cr ON cr.personID = s.personID

LEFT JOIN (
	SELECT personID, MAX(userWarning) AS translationLanguage
	FROM ProgramParticipation pp 
		WHERE (pp.startDate <= getdate() OR pp.startDate IS NULL)
		AND (pp.endDate >= GETDATE() OR pp.endDate IS NULL)
		AND pp.programID = 37
	GROUP BY personID
) pp ON pp.personID = s.personID


/*
LEFT JOIN (
SELECT s1.personID
	, s1.PersonCalendarID
	, s1.calendarID
	, s1.siblingName AS Sibling1
	, s2.siblingName AS Sibling2
	, s3.siblingName AS Sibling3
	, s4.siblingName AS Sibling4
	, s5.siblingName AS Sibling5
	, s6.siblingName AS Sibling6
	, s7.siblingName AS Sibling7
	, CONCAT(
		s1.siblingName
		, CASE WHEN s2.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s2.siblingName IS NOT NULL THEN s2.siblingName ELSE ''END
		, CASE WHEN s3.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s3.siblingName IS NOT NULL THEN s3.siblingName ELSE ''END
		, CASE WHEN s4.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s4.siblingName IS NOT NULL THEN s4.siblingName ELSE ''END
		, CASE WHEN s5.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s5.siblingName IS NOT NULL THEN s5.siblingName ELSE ''END
		, CASE WHEN s6.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s6.siblingName IS NOT NULL THEN s6.siblingName ELSE ''END
		, CASE WHEN s7.siblingName IS NOT NULL THEN ', ' ELSE ''END , CASE WHEN s7.siblingName IS NOT NULL THEN s7.siblingName ELSE ''END
	) AS siblings
FROM elhCustom.v_siblings s1
LEFT JOIN elhCustom.v_siblings s2 ON s2.PersonCalendarID = s1.PersonCalendarID AND s2.sibRank = 2
LEFT JOIN elhCustom.v_siblings s3 ON s3.PersonCalendarID = s1.PersonCalendarID AND s3.sibRank = 3
LEFT JOIN elhCustom.v_siblings s4 ON s4.PersonCalendarID = s1.PersonCalendarID AND s4.sibRank = 4
LEFT JOIN elhCustom.v_siblings s5 ON s5.PersonCalendarID = s1.PersonCalendarID AND s5.sibRank = 5
LEFT JOIN elhCustom.v_siblings s6 ON s6.PersonCalendarID = s1.PersonCalendarID AND s6.sibRank = 6
LEFT JOIN elhCustom.v_siblings s7 ON s7.PersonCalendarID = s1.PersonCalendarID AND s7.sibRank = 7

WHERE s1.sibRank = 1
) siblings ON siblings.personcalendarID = s.PersonCalendarID AND s.ActiveStudent = 'Y'
*/
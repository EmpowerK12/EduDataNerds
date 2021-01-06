--Create VIEW elhcustom.v_Incidents AS
--ALTER VIEW elhcustom.v_Incidents AS


SELECT   br.personID
		,bi.calendarID
		,ca.schoolID
		,bi.alignment
		, br.role
		, CASE WHEN (br.role = 'Offender' OR br.role = 'Participant') THEN 1 ELSE 0 END AS 'offenderParticipant'
		, br.comments AS roleComments
		,bi.contextDescription
 		,bi.description AS details
		, CAST(bi.timestamp AS TIME) incidentTime
		, CAST(bi.timestamp AS Date) incidentDate
		, bi.timestamp AS incidentTimeStamp
		,bi.incidentID
	    ,(SELECT cd.name FROM dbo.CampusDictionary AS cd INNER JOIN dbo.CampusAttribute AS ca ON cd.attributeID = ca.attributeID AND ca.object = 'BehaviorIncident' AND ca.element = 'location' WHERE (cd.code = bi.location)) AS location
		, bi.locationDescription
		, bi.status
		, bi.referralPersonID AS submittedByPersonID
		, refI.lastName + ', ' + refI.firstName AS submittedBy
		, bi.title
		, be.eventID
		, bt.name AS eventName
		, bres.timestamp AS resolutionTimestamp
		, bres.discAssignDate AS resolutionAssignDate
		, brt.code AS resolutionCode
		, brt.name AS resolutionName
        , bres.comments AS resolutionComments
		, (SELECT COUNT(DISTINCT date) AS Expr1 FROM dbo.Day AS d WHERE (calendarID = bi.calendarID) AND (instruction = 1) AND (date >= CAST(CONVERT(varchar(10), bres.timestamp, 120) AS datetime)) AND (date <= bres.endTimeStamp)) AS resolutionLengthSchoolDays
		, CASE WHEN bres.adminPersonID IS NOT NULL THEN (ISNULL(iResAdmin.lastName, '') + ', ' + ISNULL(iResAdmin.firstName, '')) END AS responderName
		, bres.adminPersonID AS ResponderPersonID
		, brsp.guardianContacted
		, brsp.guardianContactedDate
		, brsp.guardianContactedDetails
		, brsp.guardianContactedName
		, brspt.name AS responseName
		,(SELECT cd.name FROM dbo.CampusDictionary AS cd INNER JOIN dbo.CampusAttribute AS ca ON cd.attributeID = ca.attributeID AND ca.object = 'BehaviorResponseType' AND ca.element = 'responseType' WHERE (cd.code = brspt.responseType)) AS responseType
		,CAST(br.personID AS varchar(10)) + '-' + CAST(bi.calendarID AS varchar(10)) AS PersonCalendarID					   
		,CAST(br.personID AS varchar(10)) + '-' + CAST(be.eventID AS varchar(10)) AS PersonEventID					   
		, bh.harassmentType 
			+ ': ' 
			+( 
				SELECT cd.name 
				FROM dbo.CampusDictionary AS cd 
				INNER JOIN dbo.CampusAttribute AS ca 
					ON cd.attributeID = ca.attributeID 
					AND ca.object = 'BehaviorHarassment' 
					AND ca.element = 'harassmentType'
				WHERE (cd.code = bh.harassmentType)
			) AS harassmentType
		, bh.harassmentID
		, bh.harassmentDesc
		
			
FROM            dbo.BehaviorRole AS br WITH (NOLOCK) 
	INNER JOIN	dbo.BehaviorEvent AS be WITH (NOLOCK) ON br.eventID = be.eventID 
	INNER JOIN dbo.BehaviorIncident AS bi WITH (NOLOCK) ON be.incidentID = bi.incidentID 
	JOIN dbo.calendar ca ON ca.calendarID = bi.calendarID
	INNER JOIN dbo.BehaviorType AS bt WITH (NOLOCK) ON be.typeID = bt.typeID 
	LEFT OUTER JOIN dbo.Person AS refP WITH (NOLOCK) ON refP.personID = bi.referralPersonID 
	LEFT OUTER JOIN dbo.[Identity] AS refI WITH (NOLOCK) ON refI.identityID = refP.currentIdentityID 
	LEFT OUTER JOIN dbo.BehaviorResolution AS bres WITH (NOLOCK) ON bres.roleID = br.roleID 
	LEFT OUTER JOIN dbo.BehaviorResType AS brt WITH (NOLOCK) ON bres.typeID = brt.typeID 
	LEFT OUTER JOIN dbo.BehaviorResponse AS brsp WITH (NOLOCK) ON brsp.roleID = br.roleID 
	LEFT OUTER JOIN dbo.BehaviorResponseType AS brspt WITH (NOLOCK) ON brspt.responseTypeID = brsp.responseTypeID 
	LEFT OUTER JOIN dbo.BehaviorHarassment AS bh WITH (NOLOCK) ON bh.roleID = br.roleID 
	LEFT OUTER JOIN dbo.Person AS pResAdmin 
	INNER JOIN dbo.[Identity] AS iResAdmin ON pResAdmin.currentIdentityID = iResAdmin.identityID ON pResAdmin.personID = bres.adminPersonID 

WHERE        (bi.status <> 'DF')

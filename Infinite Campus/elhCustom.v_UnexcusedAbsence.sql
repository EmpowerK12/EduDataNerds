--ALTER VIEW elhcustom.v_UnexcusedAbsence AS

SELECT 
	attendanceFULL.personID,
	attendanceFULL.studentNumber,
	attendanceFULL.lastName,
	attendanceFULL.firstName,
	attendanceFULL.[School Name],
	cal.calendarID,
	attendanceFULL.grade,
	UA3.date AS '3rdUnexcusedAbsence',
	UA5.date AS '5thUnexcusedAbsence',
	UA8.date AS '8thUnexcusedAbsence',
	UA10.date AS '10thUnexcusedAbsence',
	UA15.date AS '15thUnexcusedAbsence',
	sum(case when attendanceFULL.[status] in ('UA', 'AFUDL', 'AFUIP', 'AFUI') then 1 else 0 end) as [TotalFullUnexcusedAbsences],
	max(case when attendanceFULL.[status] in ('UA', 'AFUDL', 'AFUIP', 'AFUI') then attendanceFull.date ELSE NULL END) as [MostRecentUnexcusedAbsence]
FROM elhCustom.adtAttendanceSourceTemp attendanceFull

--LEFT JOIN to a list that returns the date of students' third UA
LEFT JOIN (SELECT AttRank.personID, AttRank.lastname, AttRank.UACount, AttRank.date
			FROM (

					SELECT 
						attendanceFull.personID,
						attendanceFull.lastName,
						attendanceFull.firstName,
						attendanceFull.date,
						attendanceFull.status,
						RANK() OVER (Partition by attendanceFull.personID order by attendanceFull.date) AS UACount
					FROM elhCustom.adtAttendanceSourceTemp attendanceFull
					JOIN student s ON s.personID = attendanceFULL.personID AND s.activeYear = 1 AND (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())
					JOIN calendar cal ON cal.calendarID = s.calendarID
					where attendanceFull.date <= cal.endDate
					and attendanceFull.date >= cal.startDate
					AND attendanceFull.status IN ('UA', 'AFUDL', 'AFUIP', 'AFUI')
					) AttRank
			WHERE AttRank.UACount = 3
			) UA3 ON UA3.personID = attendanceFULL.personID


--LEFT JOIN to a list that returns the date of students' fifth UA
LEFT JOIN (SELECT AttRank.personID, AttRank.lastname, AttRank.UACount, AttRank.date
			FROM (

					SELECT 
						attendanceFull.personID,
						attendanceFull.lastName,
						attendanceFull.firstName,
						attendanceFull.date,
						attendanceFull.status,
						RANK() OVER (Partition by attendanceFull.personID order by attendanceFull.date) AS UACount
					FROM elhCustom.adtAttendanceSourceTemp attendanceFull
					JOIN student s ON s.personID = attendanceFULL.personID AND s.activeYear = 1 AND (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())
					JOIN calendar cal ON cal.calendarID = s.calendarID
					where attendanceFull.date <= cal.endDate
					and attendanceFull.date >= cal.startDate
					AND attendanceFull.status IN ('UA', 'AFUDL', 'AFUIP', 'AFUI')
					) AttRank
			WHERE AttRank.UACount = 5
			) UA5 ON UA5.personID = attendanceFULL.personID

--LEFT JOIN to a list that returns the date of students' Eighth UA
LEFT JOIN (SELECT AttRank.personID, AttRank.lastname, AttRank.UACount, AttRank.date
			FROM (

					SELECT 
						attendanceFull.personID,
						attendanceFull.lastName,
						attendanceFull.firstName,
						attendanceFull.date,
						attendanceFull.status,
						RANK() OVER (Partition by attendanceFull.personID order by attendanceFull.date) AS UACount
					FROM elhCustom.adtAttendanceSourceTemp attendanceFull
					JOIN student s ON s.personID = attendanceFULL.personID AND s.activeYear = 1 AND (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())
					JOIN calendar cal ON cal.calendarID = s.calendarID
					where attendanceFull.date <= cal.endDate
					and attendanceFull.date >= cal.startDate
					AND attendanceFull.status IN ('UA', 'AFUDL', 'AFUIP', 'AFUI')
					) AttRank
			WHERE AttRank.UACount = 8
			) UA8 ON UA8.personID = attendanceFULL.personID

--LEFT JOIN to a list that returns the date of students' 10th UA
LEFT JOIN (SELECT AttRank.personID, AttRank.lastname, AttRank.UACount, AttRank.date
			FROM (

					SELECT 
						attendanceFull.personID,
						attendanceFull.lastName,
						attendanceFull.firstName,
						attendanceFull.date,
						attendanceFull.status,
						RANK() OVER (Partition by attendanceFull.personID order by attendanceFull.date) AS UACount
					FROM elhCustom.adtAttendanceSourceTemp attendanceFull
					JOIN student s ON s.personID = attendanceFULL.personID AND s.activeYear = 1 AND (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())
					JOIN calendar cal ON cal.calendarID = s.calendarID
					where attendanceFull.date <= cal.endDate
					and attendanceFull.date >= cal.startDate
					AND attendanceFull.status IN ('UA', 'AFUDL', 'AFUIP', 'AFUI')
					) AttRank
			WHERE AttRank.UACount = 10
			) UA10 ON UA10.personID = attendanceFULL.personID


--LEFT JOIN to a list that returns the date of students' 15th UA
LEFT JOIN (SELECT AttRank.personID, AttRank.lastname, AttRank.UACount, AttRank.date
			FROM (

					SELECT 
						attendanceFull.personID,
						attendanceFull.lastName,
						attendanceFull.firstName,
						attendanceFull.date,
						attendanceFull.status,
						RANK() OVER (Partition by attendanceFull.personID order by attendanceFull.date) AS UACount
					FROM elhCustom.adtAttendanceSourceTemp attendanceFull
					JOIN student s ON s.personID = attendanceFULL.personID AND s.activeYear = 1 AND (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())
					JOIN calendar cal ON cal.calendarID = s.calendarID
					where attendanceFull.date <= cal.endDate
					and attendanceFull.date >= cal.startDate
					AND attendanceFull.status IN ('UA', 'AFUDL', 'AFUIP', 'AFUI')
					) AttRank
			WHERE AttRank.UACount = 15
			) UA15 ON UA15.personID = attendanceFULL.personID

JOIN School ON school.name =attendanceFull.[School Name]
JOIN calendar cal ON attendanceFull.date >= cal.startDate AND attendanceFull.date <= cal.endDate AND cal.schoolID = school.schoolID

JOIN student s ON s.personID = attendanceFULL.personID AND s.calendarID = cal.calendarID

WHERE (s.endDate IS NULL OR s.endDate >= GETDATE()) AND (s.startDate IS NULL OR s.startdate <= getdate())




Group By 
	attendanceFULL.personID,
	attendanceFULL.studentNumber,
	attendanceFULL.lastName,
	attendanceFULL.firstName,
	attendanceFULL.[School Name],
	cal.calendarID,
	attendanceFULL.grade,
	UA3.date,
	UA5.date,
	UA8.date,
	UA10.date,
	UA15.date

--Order by 4, 9 desc

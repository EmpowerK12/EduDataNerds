--ALTER view elhCustom.v_attendanceTotals as

	
SELECT 
	af.personID,
	cal.calendarID,
	convert(varchar,getdate(),101) as reportDate,
	sum(case when af.[status] in ('UA', 'AFUDL', 'AFUIP', 'AFUI') then 1 else 0 end) as [Total Full Unexcused Absences],
	sum(case when af.[status] in ('UA','APU', 'AFUDL', 'AFUIP', 'APUIP', 'AFUI') then 1 else 0 end) as [Total Unexcused Absences],
	sum(case when af.[status] in ('AFUDL') AND d.weekday = 'Wednesday' then 1 else 0 end) as [Total Async Unexcused Absences],
	sum(case when af.[status] in ('AFUDL') AND d.weekday <> 'Wednesday' then 1 else 0 end) as [Total Sync Unexcused Absences],
	sum(case when af.[status] in ('EA', 'AFEDL', 'AFEIP', 'AFEI') then 1 else 0 end) as [Total Full Excused Absences],
	sum(case when af.[status] in ('EA','UA', 'AFEDL', 'AFUDL', 'AFEIP', 'AFUIP', 'AFEI', 'AFUI') then 1 else 0 end) as [Total Full Day Absences (no OSS)],
	sum(case when af.[status] in ('APE','APU', 'APEIP', 'APUIP') then 1 else 0 end) as [Total Partial Absences],
	sum(case when af.[status] in ('EA','UA','APE','APU', 'AFEDL', 'AFUDL', 'AFEIP', 'AFUIP', 'APEIP', 'APUIP', 'AFEI', 'AFUI') then 1 else 0 end) as [Total All Absences (no OSS)],
	sum(case when af.[status] in ('TE','TU','PPE','PPU', 'PPEIP', 'PPUIP') then 1 else 0 end) as [Total Major Tardies],
	sum(case when af.[tardyFlag] = 1 then 1 else 0 end) as [Total Tardy Flags],
	sum(case when af.[status] in ('OSS', 'AOS') then 1 else 0 end) as [Total OSS],
	count(af.studentNumber) as [Total Attendance Records],
	1 - (1.0 * sum(case when af.[status] in ('EA','UA','APE','APU', 'AFEDL', 'AFUDL', 'AFEIP', 'AFUIP', 'APEIP', 'APUIP', 'AFEI', 'AFUI') then 1 else 0 end) / count(af.studentNumber)) AS [Attendance Rate],
	consec.maxFull,
	consec.maxPF,
	consec.currentConsecFull,
	consec.currentConsecPF
FROM elhCustom.adtAttendanceSourceTemp af
JOIN  School ON school.name = af.[School Name]
JOIN Calendar cal ON af.date >= cal.startDate 
	AND af.date <= cal.endDate 
	AND cal.summerSchool = 0 
	AND cal.schoolID = school.schoolID
JOIN elhcustom.v_date d ON d.date = af.date

left join --start consecutive absence code
	(
		select 
			tm.personID
			,max(tm.consecutiveFullAbsences) as maxFull
			,max(tm.consecutivePartialOrFullAbsences) as maxPF
			,c.consecutiveFullAbsences as currentConsecFull
			,c.consecutivePartialOrFullAbsences as currentConsecPF
		from (
				select 
					ta.personID
					,ta.lastName
					,ta.firstName
					,ta.[date]
					,ta.[status]
					--,ta.statusGroup
					--,ta.fullGroup
					--,ta.resetGroup
					,sum(fullGroup) over (partition by personID,resetFullGroup order by date rows unbounded preceding) as consecutiveFullAbsences
					,sum(partialGroup) over (partition by personID,resetPartialGroup order by date rows unbounded preceding) as consecutivePartialOrFullAbsences
				from
				(
					select *
						, sum(resetFull) over (partition by personID order by date rows unbounded preceding) as resetFullGroup
						, sum(resetPartial) over (partition by personID order by date rows unbounded preceding) as resetPartialGroup
					from 
						(
						select *
								,case when [status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end as partialGroup
								,case when [status] in ('EA','UA','AFEDL','AFUDL') then 1 else 0 end as fullGroup
								,case when
									case when 
										[status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end = 0
										and sum(case when [status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end) over (partition by personID order by date rows between 1 preceding and 1 preceding) = 1
									then 1 else 0 end as resetPartial
								,case when
									case when 
										[status] in ('AFEDL','AFUDL') then 1 else 0 end = 0
										and sum(case when [status] in ('AFEDL','AFUDL') then 1 else 0 end) over (partition by personID order by date rows between 1 preceding and 1 preceding) = 1
									then 1 else 0 end as resetFull
						from elhCustom.adtAttendanceSourceTemp a 
						) aTemp
				) ta
			) tm
		join (
			select *,Row_number() over(partition by personID order by [date] desc) as rn 
			from (
					select 
						ta.personID
						,ta.lastName
						,ta.firstName
						,ta.[date]
						,ta.[status]
						--,ta.statusGroup
						--,ta.fullGroup
						--,ta.resetGroup
						,sum(fullGroup) over (partition by personID,resetFullGroup order by date rows unbounded preceding) as consecutiveFullAbsences
						,sum(partialGroup) over (partition by personID,resetPartialGroup order by date rows unbounded preceding) as consecutivePartialOrFullAbsences
					from
					(
						select *
							, sum(resetFull) over (partition by personID order by date rows unbounded preceding) as resetFullGroup
							, sum(resetPartial) over (partition by personID order by date rows unbounded preceding) as resetPartialGroup
						from 
							(
						select *
								,case when [status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end as partialGroup
								,case when [status] in ('EA','UA','AFEDL','AFUDL') then 1 else 0 end as fullGroup
								,case when
									case when 
										[status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end = 0
										and sum(case when [status] in ('APE','APU','EA','UA','AFEDL','AFUDL') then 1 else 0 end) over (partition by personID order by date rows between 1 preceding and 1 preceding) = 1
									then 1 else 0 end as resetPartial
								,case when
									case when 
										[status] in ('AFEDL','AFUDL') then 1 else 0 end = 0
										and sum(case when [status] in ('AFEDL','AFUDL') then 1 else 0 end) over (partition by personID order by date rows between 1 preceding and 1 preceding) = 1
									then 1 else 0 end as resetFull
						from elhCustom.adtAttendanceSourceTemp a 
							) aTemp
					) ta
				) tm2
			) c on c.personID=tm.personID and rn=1


		where 1=1
		group by
			tm.personID,c.consecutiveFullAbsences,c.consecutivePartialOrFullAbsences
	) consec on consec.personID=af.personID
Group By 
	af.personID,
	cal.calendarID,
	consec.maxFull,
	consec.maxPF,
	consec.currentConsecFull,
	consec.currentConsecPF
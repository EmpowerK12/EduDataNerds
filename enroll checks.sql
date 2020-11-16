-- ENROLLMENT CHECKS FOR POWERSCHOOL

-- Entry/exit stage 4 mismatch 
select 'entryExit mismatch' as checkType, studentid, entrydate, entrycode, exitdate, exitcode
from ps_enrollment_all
where	(entrycode='1800' 
			and (exitcode not in ('1234', '4321') or exitcode is null)
		)
	or
		(exitcode in ('1234', '4321') 
			and entrycode<>'1800'
		)


-- Start date not before first day marked present 
-- if negative attendance, we can only check that days before and on entry are not absences
select  'start before present' as checkType, a.studentid, e.entrydate, a.att_date, ac.presence_status_cd
from attendance a
	left join PS_Enrollment_all e on 1=1
	    and a.studentid=e.studentid
        and a.schoolid=e.schoolid
		and e.entrycode<>'1800' -- students have a stage 5 enrollment
        and e.yearid=a.yearid
		and e.yearid=30 --for this year
		and a.att_date<=e.entrydate  --only match attendance that on or before entrydate
        and a.att_mode_code='ATT_ModeDaily'  -- don't want to include period attendance here
   join attendance_code ac on 1=1
        and ac.id=a.attendance_codeid  
        and ac.yearid=e.yearid
        and ac.presence_status_cd='Absent'


-- if attendance is filled in for both absences and presents:
select 'start before present' as checkType, a.studentid, min(a.att_date) as FirstPresent, e.Entrydate,   min(a.att_date)-e.entrydate as Dif
from attendance a
	left join PS_Enrollment_all e on 1=1
	    and a.studentid=e.studentid
        and a.schoolid=e.schoolid
		and e.entrycode<>'1800' -- students have a stage 5 enrollment
        and e.yearid=a.yearid
		and e.yearid=30 --for this year
    join attendance_code ac on 1=1
        and ac.id=a.attendance_codeid  
        and ac.yearid=e.yearid
        and ac.presence_status_cd='Present'
group by a.studentid, e.entrydate
having (min(a.att_date)-e.entrydate)<>0
order by FirstPresent
--ATTENDANCE CHECKS FOR POWERSCHOOL

--check for missing daily attendance (doesn't work if you are doing negative attendance)

select 'missing attendance' as checkType ,en.studentid ,c.date_value 
from ps_enrollment_all en
    join calendar_day c 
        on c.date_value>=en.entrydate
        and c.date_value<en.exitdate
        and c.date_value<=current_date
        and c.insession=1
        and c.schoolid=en.schoolid
        and en.entrycode not in ('1800')
        and en.yearid=30  --this year

    left outer join ps_attendance_daily at
        on at.att_date=c.date_value
        and at.studentid=en.studentid
        and at.schoolid=en.schoolid

    left outer join attendance_code ac on ac.id=at.attendance_codeid  and ac.yearid=en.yearid

    where ac.att_code is null


-------------------------------------------------------------------------------

--check for missing period attendance (doesn't work if you are doing negative attendance)

select 'missing perdiod attendance' as checkType ,cc.schoolid ,cc.studentid ,DateInSession as AttDate, periodabbrev as Period ,sm.sectionid 

from cc
join section_meeting sm on sm.sectionid=abs(cc.sectionid)
join
    (select
    cd.date_value as DateInSession
    ,p.abbreviation as PeriodAbbrev
    ,p.period_number as PeriodInSession
    ,c.letter as DayInSession
    ,cd.schoolid as SchoolInSession
    from calendar_day cd
    left outer join bell_schedule_items bs on bs.bell_schedule_id=cd.bell_schedule_id 
    left outer join period p on p.id=bs.period_id
    left outer join cycle_day c on c.id=cd.cycle_day_id
    where cd.date_value>='01-AUG-20' -- start date
        and cd.date_value<current_date  -- goes until today or change current_date to earlier date to limit
        --and cd.schoolid in (   )  -- if you want, specify schools to include
        --and p.abbreviation in (   )  -- if you want, specify periods to include
        and cd.insession=1)
    on DateInSession>=cc.dateenrolled
    and DateInSession<cc.dateleft
    and SchoolInSession=cc.schoolid
    and PeriodInSession=sm.period_number
    and DayInSession=sm.cycle_day_letter

left join ps_attendance_meeting am 
    on am.schoolid=cc.schoolid
    and am.studentid=cc.studentid
    and am.att_date=DateInSession
    and am.period_number=sm.period_number  
    and am.sectionid=abs(cc.sectionid)

where am.att_code is null


--------------------------------------------------------------------------------
--Duplicates
 
select 'dupplicate attendance' as checkType, studentid, att_date, periodid,  count(*)
from attendance
where yearid=30 -- just this year
group by studentid, att_date, periodid
having count(*) > 1


---------------------------------------------------------------------------------

--for schools doing negative attendance, having an accurate calendar is super important.

--for multischool LEA that should have same calendar, checking that insession days are the same

select 'wrong insession days' as checkType ,date_value, count(date_value)
from calendar_day
where 1=1
    and insession=1
    --and type in ()  might need to add if your school uses other markers for days where attendance is expected
    and date_value>'01-AUG-20' -- insert start date
    and schoolid in ( )--insert schools to include here
group by date_value
having count(date_value) < ( )  --insert number of schools here

---------------------------------------------------------------------------------

--counting insession days
select t.name, t.schoolid, t.firstday, t.lastday, count(c.insession)
from terms t
join calendar_day c on 1=1
    and c.date_value>=t.firstday 
    and c.date_value<=t.lastday 
    and c.schoolid=t.schoolid
    and c.insession=1
    --and type in ()  might need to add if your school uses other markers for days where attendance is expected
where yearid=30  -- just this year
group by t.name, t.schoolid, t.firstday, t.lastday
order by t.name

--------------------------------------------------------------------------------
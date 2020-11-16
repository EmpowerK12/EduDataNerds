-- DEMOGRAPHIC CHECKS FOR POWERSCHOOL

-- duplicate student number
select 'duplicate student number' as checkType, student_number, count(student_number) from Students
group by student_number
having count(student_number)>1


--duplicate USI
select 'duplicate USI' as checkType,  state_studentnumber, count(state_studentnumber) from Students
group by state_studentnumber
having count(state_studentnumber)>1


--duplicate Name, DOB
select 'duplicate name and DOB' as checkType, last_name, first_name, DOB, count(*)
from students 
group by last_name, first_name, DOB
having count(*) > 1


-- DEMOGRAPHIC CHECKS

-- duplicate student number
select student_number, count(student_number) from Students
group by student_number
having count(student_number)>1


--duplicate USI
select state_studentnumber, count(state_studentnumber) from Students
group by state_studentnumber
having count(state_studentnumber)>1


--duplicate Name, DOB
select last_name, first_name, DOB, count(*)
from students 
group by last_name, first_name, DOB
having count(*) > 1


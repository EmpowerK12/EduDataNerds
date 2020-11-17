/* A query to select a long table of current student class enrollments
One row per student per class including period, teacher, entry date
Useful for checking that all kids are appropriately enrolled, sharing student schedules, etc
Written for Powerschool tables in Oracle */

SELECT 
s.student_number
,ps_customfields.getcf('Students',s.id,'state_USI') AS USI
,s.lastfirst
,s.grade_level
,schools.abbreviation AS school
,ps_customfields.getcf('Students',s.id,'sped_classification') AS SPED_funding
,ps_customfields.getcf('Students',s.id,'sped_classification') AS SPED_classification
,s.entrydate AS school_start_date
,enrol.revised_course_type
,enrol.course_name
,enrol.section_number
,enrol.expression
,enrol.lastfirst AS teacher
,enrol.dateenrolled AS class_entry_date
,enrol.dateleft AS class_exit_date
FROM students s
JOIN schools on s.schoolid = schools.school_number

-- Subquery selects only current enrollments from the CC table (faster than joining directly to CC table then filtering)
LEFT JOIN (
  SELECT
  crs.course_name
  ,cc.sectionid
  ,cc.expression
  ,cc.studentid
  ,cc.section_number
  ,cc.dateenrolled
  ,cc.dateleft
  ,t.lastfirst
  ,CASE 
    WHEN crs.course_name in ('Homeroom','Attendance','Recess','Lunch') THEN crs.course_name
    ELSE crs.credittype
    END revised_course_type
  FROM cc
  JOIN courses crs ON crs.course_number=cc.course_number
  JOIN teachers t ON t.id = cc.teacherid
  WHERE cc.termid >= 3000  --change depending on the year (2800=18-19, 2900=19-20, etc); cc.termid is negative for dropped classes, so use >= for only currently-enrolled classes
  ) enrol
ON s.id = enrol.studentid

WHERE s.enroll_status=0  --only currently-enrolled students
AND schools.abbreviation != 'NPP'


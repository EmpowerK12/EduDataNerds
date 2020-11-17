--This statement lists parent portal login attempts (student name and guardian name) ordered by date.
--author: Emily Swain date:11/17/20

SELECT s.STUDENT_NUMBER, s.LASTFIRST,s.GRADE_LEVEL, g.FIRSTNAME,g.LASTNAME,paah.LOGINATTEMPTDATE FROM GUARDIANSTUDENT gs --guardianstudent table contains studentID and guardianID columns

JOIN STUDENTS s on gs.STUDENTSDCID = s.DCID --unique row on student DCID
JOIN GUARDIAN g ON gs.GUARDIANID = g.GUARDIANID --guardian table includes demographic data i.e. name, email address. creates unique row for each guardian, could create duplicate student rows if more than one guardian has a parent portal account
JOIN PCAS_ACCOUNT pa ON g.ACCOUNTIDENTIFIER = pa.PCAS_ACCOUNTTOKEN
JOIN PCAS_ACCOUNTACCESSHIST paah  ON paah.PCAS_ACCOUNTID = pa.PCAS_ACCOUNTID 

WHERE paah.ISLOGINSUCCESSFUL = 1
ORDER BY paah.LOGINATTEMPTDATE DESC

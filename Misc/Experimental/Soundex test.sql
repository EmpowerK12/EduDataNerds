/*************************************************************************************************************
                                             Sounds Like Test

Soundex and difference are SQL Server functions that allow you to compare the sounds of words and names.
This file investigates the properties of these functions.

*************************************************************************************************************/

--Looking at difference for a name that starts the same and just has weird letters at the end.  Soundex seems to only... 
--...look at the first four non-special letters (A, E, I O, U, H, W, Y). https://www.archives.gov/research/census/soundex
--this may be western centric.  I don't have enough info about it to know for sure.
SELECT DIFFERENCE('Johnstonsfdsdfsdfsdfsdff','Johnston') differenceInSound,soundex('Johnstonsfdsdfsdfsdfsdff') soundJ, soundex('Johnston') soundY;

IF OBJECT_ID('tempdb..#colorsTemp') IS NOT NULL
    DROP TABLE #colorsTemp

--creating fake data
SELECT * into #colorsTemp 
FROM 
(
   VALUES(1, 'lie'),
         (2, 'rye'),
         (3, 'bye'),
         (4, 'lemon'),
         (5, 'lilac'),
		 (6, 'Their'),
         (7, 'Bear'),
         (8, 'buy'),
		 (9, 'Jhonny'),
         (10, 'John')
) AS Colors(Id, testValue)

--compares every combination of the fake data
select c1.testValue as c1
	,c2.testValue as c2
	,soundex(c1.testValue) soundexVal1 
	,soundex(c2.testValue) soundexVal2 
	,DIFFERENCE(c1.testValue,c2.testValue) as diff
from #colorsTemp c1
join #colorsTemp c2 on 1=1 --joining everything
order by diff

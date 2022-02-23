--(idnr, name, login, program, branch)
CREATE VIEW BasicInformation AS
SELECT idnr,name,login,S.program,branch
FROM Students S
LEFT JOIN StudentBranches ON idnr=student;

--(student,course,grade,credits)
CREATE VIEW FinishedCourses AS 
SELECT idnr,course,grade,credits FROM STUDENTS
INNER JOIN TAKEN ON student = idnr
INNER JOIN Courses ON course = code;

CREATE VIEW PassedCourses AS
SELECT idnr,course,credits
FROM FinishedCourses
WHERE grade != 'U'; 

--(student, course, credits)
--(student, course, status)
CREATE VIEW Registrations AS 
SELECT student AS idnr,course,'registered' AS status
FROM Registered
UNION
SELECT student AS idnr,course,'waiting' AS status
FROM WaitingList;

CREATE VIEW UnreadMandatory AS
WITH MandatoryCourses AS (
    SELECT idnr,course FROM BasicInformation I
    JOIN MandatoryProgram M ON M.program=I.program
    UNION
    SELECT idnr,course FROM BasicInformation I
    JOIN MandatoryBranch B ON
        I.branch = B.branch
        AND I.program = B.program
    ORDER BY idnr
    )
SELECT * FROM MandatoryCourses EXCEPT (SELECT idnr,course FROM PassedCourses);

CREATE OR REPLACE VIEW PathToGraduation AS
WITH MathCredits AS (
    SELECT S.idnr,sum(credits) AS math FROM Students S
    JOIN PassedCourses P ON P.idnr = S.idnr
    JOIN Classified C ON C.course = P.course
    WHERE classification = 'math'
    GROUP BY S.idnr
),  ResearchCredits AS (
    SELECT S.idnr,sum(credits) AS research FROM Students S
    JOIN PassedCourses P ON P.idnr = S.idnr
    JOIN Classified C ON C.course = P.course
    WHERE classification = 'research'
    GROUP BY S.idnr
),  SeminarCourses AS (
    SELECT S.idnr,sum(credits) AS seminar FROM Students S
    JOIN PassedCourses P ON P.idnr = S.idnr
    JOIN Classified C ON C.course = P.course
    WHERE classification = 'seminar'
    GROUP BY S.idnr
), RecomendedRead AS (
    SELECT idnr,SUM(credits) AS read FROM Students S
    JOIN StudentBranches B ON S.idnr = B.student
    JOIN RecommendedBranch R ON
                                B.program = R.program AND
                                B.branch  = R.branch
    JOIN Courses ON course = code
    GROUP BY idnr
)
SELECT S.idnr,
       COALESCE(Tot.totalCredits,0) AS totalCredits,
       mandatoryLeft,
       COALESCE(Ma.math,0) AS math,
       COALESCE(Re.research,0) AS research,
       COALESCE(Se.seminar,0) AS seminar,
       COALESCE(mandatoryLeft = 0 AND
        R.read >= 10 AND
        Ma.math>=20 AND
        Re.research>=10 AND
        Se.seminar>=1,
        'f') AS qualified
       FROM Students S
LEFT JOIN (SELECT S.idnr,SUM(credits) AS totalCredits
    FROM STUDENTS S
    JOIN PassedCourses P on S.idnr = P.idnr
    GROUP BY S.idnr) Tot
    ON Tot.idnr = S.idnr
LEFT JOIN (SELECT S.idnr,COALESCE(COUNT(course),0) AS mandatoryLeft
    FROM Students S
    LEFT JOIN UnreadMandatory U ON S.idnr=U.idnr
    GROUP BY S.idnr) Man
    ON Man.idnr = S.idnr
LEFT JOIN RecomendedRead R ON R.idnr = S.idnr
LEFT JOIN MathCredits Ma ON Ma.idnr = S.idnr
LEFT JOIN ResearchCredits Re ON Re.idnr = S.idnr
LEFT JOIN SeminarCourses Se ON Se.idnr = S.idnr;

/*
CREATE VIEW CourseQueuePositions AS
SELECT course,student,ROW_NUMBER () OVER (ORDER BY position) AS place
FROM WaitingList
ORDER BY (course,position);
*/
CREATE VIEW CourseQueuePositions AS
SELECT course, student, row_number() OVER
        (PARTITION BY course ORDER BY position) AS place
FROM WaitingList ORDER BY (course,position);
--CourseQueuePositions(course,student,place)
CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbr TEXT UNIQUE NOT NULL
);

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL
);

CREATE TABLE ProgramDepartments(
    program TEXT NOT NULL REFERENCES Programs(name),
    department TEXT NOT NULL REFERENCES Departments(name),
    PRIMARY KEY (program,department)
);

--(name, program)
CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (name,program)
);

CREATE TABLE Students (
    idnr TEXT PRIMARY KEY CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL CHECK (login LIKE '_%'),
    login TEXT UNIQUE NOT NULL CHECK (login LIKE '_%'),
    program TEXT NOT NULL REFERENCES Programs(name),
    UNIQUE(idnr,program)
);

CREATE OR REPLACE FUNCTION progOfStudent(TEXT) RETURNS TEXT AS $$
    SELECT program FROM Students
    WHERE idnr = $1;
$$ LANGUAGE SQL;

--(code, name, credits, department)
CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK(credits > 0),
    department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE Prerequisites (
    course TEXT NOT NULL REFERENCES Courses(code),
    requires TEXT NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (course,requires)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY REFERENCES Courses(code),
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE Classified(
    classification TEXT NOT NULL,
    course TEXT NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (classification,course)
);

--(student, branch, program) 
--      student → Students.idnr 
--      (branch, program) → Branches.(name, program) 
CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY REFERENCES Students (idnr),
    branch TEXT NOT NULL,
    program TEXT NOT NULL CHECK (program = progOfStudent(student)),
    FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
);

--(course, program) 
--    course → Courses.code 
CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY (course,program)
);

--(course, branch, program) 
--    course → Courses.code 
--    (branch, program) → Branches.(name, program)
CREATE TABLE MandatoryBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch,program) REFERENCES Branches(name,program),
    PRIMARY KEY (course,branch,program)
);

--(course, branch, program) 
--    course → Courses.code 
--    (branch, program) → Branches.(name, program)
CREATE TABLE RecommendedBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch,program) REFERENCES Branches(name,program),
    PRIMARY KEY (course,branch,program)
);

--(student, course) 
--    student → Students.idnr 
--    course → Courses.code 
CREATE TABLE Registered(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY (student,course)
);

--(student, course, grade) 
--    student → Students.idnr 
--    course → Courses.code 
CREATE TABLE Taken(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK (grade IN ('U','3','4','5')),
    PRIMARY KEY (student,course)
);

-- position is either a SERIAL, a TIMESTAMP or the actual position 
--(student, course, position) 
--    student → Students.idnr 
--    course → Limitedcourses.code 
CREATE TABLE WaitingList(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position SERIAL,
    PRIMARY KEY (student,course),
    UNIQUE(course,position)
);


-- Inserts

INSERT INTO Departments VALUES ('Dep1','D1');

INSERT INTO Programs VALUES ('Prog1','P1'),
                            ('Prog2','P2');

INSERT INTO ProgramDepartments VALUES ('Prog1','Dep1'),
                                      ('Prog2','Dep1');

INSERT INTO Branches VALUES ('B1','Prog1'),
                            ('B2','Prog1'),
                            ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1'),
                            ('2222222222','N2','ls2','Prog1'),
                            ('3333333333','N3','ls3','Prog2'),
                            ('4444444444','N4','ls4','Prog1'),
                            ('5555555555','Nx','ls5','Prog2'),
                            ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1'),
                           ('CCC222','C2',20,'Dep1'),
                           ('CCC333','C3',30,'Dep1'),
                           ('CCC444','C4',60,'Dep1'),
                           ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1),
                                  ('CCC333',2);

INSERT INTO Classified VALUES ('math','CCC333'),
                              ('math','CCC444'),
                              ('research','CCC444'),
                              ('seminar','CCC444');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1'),
                                   ('3333333333','B1','Prog2'),
                                   ('4444444444','B1','Prog1'),
                                   ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1'),
                                   ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1'),
                                     ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111'),
                              ('1111111111','CCC222'),
                              ('1111111111','CCC333'),
                              ('2222222222','CCC222'),
                              ('5555555555','CCC222'),
                              ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5'),
                        ('4444444444','CCC222','5'),
                        ('4444444444','CCC333','5'),
                        ('4444444444','CCC444','5'),
                        ('5555555555','CCC111','5'),
                        ('5555555555','CCC222','4'),
                        ('5555555555','CCC444','3'),
                        ('2222222222','CCC111','U'),
                        ('2222222222','CCC222','U'),
                        ('2222222222','CCC444','U');


INSERT INTO WaitingList VALUES('3333333333','CCC222'),
                              ('3333333333','CCC333'), 
                              ('2222222222','CCC333');



--views

--(idnr, name, login, program, branch)
CREATE OR REPLACE VIEW BasicInformation AS
SELECT idnr,name,login,S.program,branch
FROM Students S
LEFT JOIN StudentBranches ON idnr=student;

--(student,course,grade,credits)
CREATE OR REPLACE VIEW FinishedCourses AS 
SELECT idnr,course,grade,credits FROM STUDENTS
INNER JOIN TAKEN ON student = idnr
INNER JOIN Courses ON course = code;

CREATE OR REPLACE VIEW PassedCourses AS
SELECT idnr,course,credits
FROM FinishedCourses
WHERE grade != 'U'; 

--(student, course, credits)
--(student, course, status)
CREATE OR REPLACE VIEW Registrations AS 
SELECT student AS idnr,course,'registered' AS status
FROM Registered
UNION
SELECT student AS idnr,course,'waiting' AS status
FROM WaitingList;

CREATE OR REPLACE VIEW UnreadMandatory AS
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


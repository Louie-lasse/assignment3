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
    capacity INT NOT NULL CHECK (capacity>=0)
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
\i yeet.sql;
\i setup.sql;
\i triggers.sql;

SELECT * FROM Registrations;
SELECT * FROM PassedCourses;
SELECT student,course FROM Taken EXCEPT (SELECT student,course FROM PassedCourses);
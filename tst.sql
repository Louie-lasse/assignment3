INSERT INTO Registrations VALUES (3333333333,'CCC333'); -- this student is already waiting
INSERT INTO Registrations VALUES (4444444444,'CCC333'); -- has already passed the course
INSERT INTO Registrations VALUES (1111111111,'CCC555'); -- should insert into course
INSERT INTO Registrations VALUES (6666666666,'CCC222'); -- should insert into waitinglist
DELETE FROM Registrations WHERE idnr='1111111111' AND course='CCC111';
DELETE FROM Registrations WHERE idnr='1111111111' AND course='CCC222';
DELETE FROM Registrations WHERE idnr='1111111111' AND course='CCC333';

SELECT idnr,name,login,program,branch,json_build_array(json_build_object('course',T.course,'grade',grade)) finnished FROM BasicInformation B
JOIN PathToGraduation P ON B.idnr=P.student
FULL OUTER JOIN Taken T ON P.student=T.student
GROUP BY (idnr,name,login,program,branch);

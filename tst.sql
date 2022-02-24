INSERT INTO Registrations VALUES (3333333333,'CCC333'); -- this student is already waiting
INSERT INTO Registrations VALUES (4444444444,'CCC333'); -- has already passed the course
INSERT INTO Registrations VALUES (1111111111,'CCC555'); -- should insert into course
INSERT INTO Registrations VALUES (6666666666,'CCC222'); -- should insert into waitinglist
DELETE FROM Registrations WHERE idnr='1111111111' AND course='CCC111';
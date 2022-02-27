-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC111'); 

-- TEST #2: Register for an limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC222'); 

-- TEST #3: waiting for a limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC222'); 

-- TEST #4: removed from a waiting list (with additional students in it).
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';


-- TEST #5: unregistered from an unlimited course.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';


-- TEST #6: unregistered from a limited course without a waiting list;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC555';


-- TEST #7: unregistered from a limited course with a waiting list, when the student is registered.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC333';

-- TEST #8: unregistered from a limited course with a waiting list, when the student is in the middle of the waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '4444444444' AND course = 'CCC666';

-- TEST #9: unregistered from an overfull course with a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC777';

-- TEST #10: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('1111111111', 'CCC222');

-- TEST #11: Register student which is already in the waiting list.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('2222222222', 'CCC222');

-- TEST #12: Register student which has already passed.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('5555555555', 'CCC111');

-- TEST #13: Register student which has not read prerequisites.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('6666666666', 'CCC111');

-- TEST #14: Register student which has not passed prerequisites .
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('3333333333', 'CCC111');

-- TEST #15: Register student which has read but not passed the course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('4444444444', 'CCC111');

--CourseQueuePositions(course,student,place)
CREATE OR REPLACE VIEW CourseQueuePositions AS
SELECT course, student, row_number() OVER
        (PARTITION BY course ORDER BY position) AS place
FROM WaitingList ORDER BY (course,position);


CREATE OR REPLACE FUNCTION prerequisitesMet(TEXT,TEXT) RETURNS BOOLEAN AS $$
    SELECT CASE WHEN EXISTS (
        SELECT Pre.course FROM Prerequisites Pre
        WHERE Pre.course = $2
        EXCEPT
        SELECT Pas.course FROM PassedCourses Pas
        WHERE Pas.idnr = $1
    ) THEN False
    ELSE True
    END;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION courseOverbooked (course TEXT) 
RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    full BOOLEAN := (SELECT amount >= capacity FROM LimitedCourses
                    JOIN (SELECT R.course, COUNT(student) AS amount
                    FROM Registered R
                    GROUP BY R.course
                    ) P ON P.course = $1
                    WHERE code = $1); -- rewrite using exists and 'WHERE amount >= capacity
BEGIN
    RETURN full;
END;
$$;

CREATE OR REPLACE FUNCTION registration_insertion() RETURNS trigger AS $registration_insertion$
    BEGIN
        IF NOT prerequisitesMet(NEW.idnr,NEW.course) THEN
            RAISE EXCEPTION 'Not all prerequisites met for %',NEW.course;
        END IF;
        IF EXISTS (SELECT * FROM PassedCourses P
                   WHERE P.idnr = NEW.idnr AND P.course = NEW.course) THEN
            RAISE EXCEPTION 'Student % has already passed the course',NEW.idnr;
        END IF;
        IF ((NEW.idnr,NEW.course) IN (SELECT idnr,course FROM Registrations)) THEN
            RAISE EXCEPTION 'Student is already registered or in the waitinglist for course %',NEW.course;
        END IF;
        IF courseOverbooked(NEW.course) THEN
            RAISE NOTICE 'Course % is fully booked, putting student into waitinglist',NEW.course;
            INSERT INTO WaitingList VALUES (NEW.idnr,NEW.course);
        ELSE
            INSERT INTO Registered VALUES (NEW.idnr,NEW.course);
        END IF;
        RETURN NEW;
    END;
$registration_insertion$ LANGUAGE plpgsql;

CREATE TRIGGER insertInRegistrations INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION registration_insertion();

CREATE OR REPLACE FUNCTION registered_deletion(TEXT) RETURNS VOID AS $$
    DECLARE
        firstInLine WaitingList%rowtype;
    BEGIN
        IF NOT (courseOverbooked($1)) THEN
            RAISE NOTICE 'Did a thing';
            SELECT student,course FROM WaitingList W INTO firstInLine
                WHERE W.course = $1
                ORDER BY position
                LIMIT 1;
            DELETE FROM WaitingList W WHERE W.student = firstInLine.student
                                            AND W.course = firstInLine.course;
        END IF;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION registrations_deletion() RETURNS trigger AS $registrations_deletion$
    DECLARE
        firstInLine WaitingList%rowtype;
    BEGIN
        IF (NEW.status = 'waiting') THEN
            DELETE FROM WaitingList W WHERE W.student = OLD.idnr
                                        AND W.course = OLD.course;
            RAISE NOTICE 'Deleted waiting student';
        ELSE
            DELETE FROM Registered r WHERE R.student = OLD.idnr
                                        AND R.course = OLD.course;
            SELECT student,course FROM WaitingList W INTO firstInLine
                WHERE W.course = OLD.COURSE
                ORDER BY position
                LIMIT 1;
            RAISE NOTICE 'Need to delete % from waitinglist', firstInLine.student;
            EXECUTE 'DELETE FROM WaitingList WHERE student = $1 AND
                                            course = $2' USING firstInLine.student,firstInLine.course;
            INSERT INTO Registered VALUES (firstInLine.student,firstInLine.course);
        END IF;
        RETURN OLD;
    END;
$registrations_deletion$ LANGUAGE plpgsql;

CREATE TRIGGER deleteFromRegistrations INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION registrations_deletion();
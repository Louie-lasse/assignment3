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
                    WHERE code = $1);
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

CREATE OR REPLACE FUNCTION registrations_deletion() RETURNS trigger AS $registrations_deletion$
    BEGIN
        IF (NEW.status = 'waiting') THEN
            DELETE FROM WaitingList W WHERE W.student = OLD.idnr
                                        AND W.course = OLD.course;
            RAISE NOTICE 'Deleted waiting student';
        ELSE
            DELETE FROM Registered r WHERE R.student = OLD.idnr
                                        AND R.course = OLD.course;
            RAISE NOTICE 'Deleted registered student';
        END IF;
        RETURN OLD;
    END;
$registrations_deletion$ LANGUAGE plpgsql;

CREATE TRIGGER deleteFromRegistrations INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION registrations_deletion();

CREATE OR REPLACE FUNCTION registered_deletion() RETURNS trigger AS $registered_deletion$
    DECLARE
        firstInLine WaitingList%rowtype;
    BEGIN
        RAISE EXCEPTION 'Overbooked: %', (courseOverbooked(OLD.course))
        IF NOT (courseOverbooked(OLD.course)) THEN
            RAISE NOTICE 'Did a thing';
            SELECT * FROM WaitingList W INTO firstInLine
                WHERE W.course = OLD.course
                ORDER BY position
                LIMIT 1;
            DELETE FROM WaitingList W WHERE W.student = firstInLine.student
                                            AND W.course = firstInLine.course;
        END IF;
        RETURN firstInLine;
    END;
$registered_deletion$ LANGUAGE plpgsql;

CREATE TRIGGER deleteFromRegistered AFTER DELETE ON Registered
    FOR EACH ROW EXECUTE FUNCTION registered_deletion();
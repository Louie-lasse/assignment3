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

CREATE OR REPLACE FUNCTION nextPos (CHAR(6)) RETURNS INT AS $$
    SELECT COUNT(*) + 1 FROM waitinglist WHERE course = $1
$$LANGUAGE SQL;

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
        IF courseOverbooked(NEW.course) THEN
            RAISE NOTICE 'Course % is fully booked, putting student into waitinglist',NEW.course;
            INSERT INTO WaitingList VALUES (NEW.idnr,NEW.course,nextPos(NEW.course));
        ELSE
            INSERT INTO Registered VALUES (NEW.idnr,NEW.course);
        END IF;
        RETURN NEW;
    END;
$registration_insertion$ LANGUAGE plpgsql;

CREATE TRIGGER insertInLimited INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION registration_insertion();
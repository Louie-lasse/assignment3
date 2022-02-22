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

/*
CREATE OR REPLACE FUNCTION insertInLimited() RETURNS trigger AS $insertInLimited$
    DECLARE registered INTEGER := (SELECT COALESCE(COUNT(student),0)
                            FROM Registered R
                            WHERE R.course = NEW.course);
    DECLARE capacity INTEGER := (SELECT capacity FROM LimitedCourses L
                                WHERE L.code = NEW.course
                                LIMIT 1);
    BEGIN
        IF NOT prerequisitesMet(NEW.student,NEW.course) THEN
            RAISE EXCEPTION 'Prerequisites not met for %',NEW.STUDENT
        IF EXISTS (SELECT * FROM LimitedCourses L
                   WHERE L.code = NEW.course) THEN
            IF (registered >= capacity) THEN
                RETURN NEW;
                --RAISE EXCEPTION 'Course % is full. Placing % into waitinglist',
                --                NEW.course,NEW.student;
            END IF;
        END IF;
        RETURN NEW;
    END;
$insertInLimited$ LANGUAGE plpgsql;
*/

CREATE OR REPLACE FUNCTION registration_insertion() RETURNS trigger AS $registration_insertion$
--DECLARE
BEGIN
    IF NOT prerequisitesMet(NEW.idnr,NEW.course) THEN
        RAISE EXCEPTION 'Not all prerequisites met for %',NEW.course;
    END IF;
    IF EXISTS (SELECT * FROM PassedCourses P
               WHERE P.idnr = NEW.idnr AND P.course = NEW.course) THEN
        RAISE EXCEPTION 'Student % has already passed the course',NEW.idnr;
    END IF;
    IF EXISTS (SELECT * FROM Registration R
               WHERE)
    raise notice 'Success';
END;
$registration_insertion$ LANGUAGE plpgsql;

CREATE TRIGGER insertInLimited INSTEAD OF INSERT ON Registration
    FOR EACH ROW EXECUTE FUNCTION registration_insertion();
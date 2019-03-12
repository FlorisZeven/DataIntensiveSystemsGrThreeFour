
CREATE INDEX course_req_srID_crID on courseRegistrations(CourseofferId);

--Q2
CREATE MATERIALIZED VIEW high_gpa_no_fail(StudentId, HIGHGPA) as (
    SELECT StudentId, CAST(sum(Grade * ECTS) AS FLOAT) / sum(ECTS) as HIGHGPA
    FROM CourseRegistrations as cr
    JOIN CourseOffers as co ON cr.CourseOfferId = co.CourseOfferId
    JOIN Courses as c ON c.CourseId = co.CourseId
    JOIN StudentRegistrationsToDegrees as srtd ON srtd.StudentRegistrationId = cr.StudentRegistrationId
    GROUP BY cr.StudentRegistrationId, StudentId
    HAVING MIN(cr.Grade) > 4 AND (CAST(sum(Grade * ECTS) AS FLOAT) / sum(ECTS)) > 9.0
);

-- Q3
CREATE MATERIALIZED VIEW all_courses_registrated(StudentId, DegreeId, CourseOfferId, Grade) AS (
    SELECT srtd.StudentId, srtd.DegreeId, cr.CourseOfferId, cr.Grade
      FROM CourseRegistrations as cr
      JOIN StudentRegistrationsToDegrees as srtd ON cr.StudentRegistrationId = srtd.StudentRegistrationId
);

-- Q4
CREATE MATERIALIZED VIEW females_per_department(Department, Amount) as (

    SELECT Dept, count(distinct s.StudentId)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE     s.Gender = 'F'
            and    s.StudentId = srtd.StudentId
            and    d.DegreeId = srtd.DegreeId
    GROUP BY d.Dept
);


-- Q4
CREATE VIEW students_per_department(Department, Amount) as (

    SELECT Dept, count(distinct s.StudentId)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE  s.Studentid = srtd.StudentId
            and    d.DegreeId = srtd.DegreeId
    GROUP BY d.Dept
);

-- Q8
CREATE VIEW total_students_per_offer(CourseOfferID, totalStudents) AS (

    SELECT CourseOfferID, COUNT(StudentRegistrationId)
    FROM
        CourseRegistrations
    GROUP BY
        CourseOfferID
);

-- Q8
CREATE VIEW total_assistants_per_offer(CourseOfferID, totalAssistants) AS (

    SELECT co.CourseOfferID, COUNT(sa.StudentRegistrationId)
    FROM
        CourseOffers as co
        FULL JOIN
        StudentAssistants as sa ON co.CourseOfferId = sa.CourseOfferId
    GROUP BY
        co.CourseOfferID
);

-- Q8
CREATE VIEW total_students_and_assistants_per_offer(CourseOfferID) AS
(
    SELECT DISTINCT tspo.CourseOfferID
    FROM total_students_per_offer AS tspo JOIN total_assistants_per_offer AS tapo ON tspo.CourseOfferID = tapo.CourseOfferID
    WHERE CAST(totalStudents + 50 AS FLOAT) / (totalAssistants + 1) > 50.0
);


-- Q1 indirectly Q2, Q3, Q4
CREATE MATERIALIZED VIEW all_courses_passed(StudentId, DegreeId, CourseOfferId, Grade) AS
(
    SELECT srtd.StudentId, srtd.DegreeId, cr.CourseOfferId, cr.Grade
      FROM CourseRegistrations as cr
      JOIN StudentRegistrationsToDegrees as srtd ON cr.StudentRegistrationId = srtd.StudentRegistrationId
     WHERE cr.Grade > 4
);

CREATE INDEX acp_studentid_degreeid ON all_courses_passed(StudentId, DegreeId);

CREATE MATERIALIZED VIEW gpa_active_complete(StudentId, DegreeId, Weighted, sumECTS, GPA, complete) AS
(
    SELECT acr.StudentId, acr.DegreeId, sum(Grade*ECTS) as Weighted, sum(ECTS) as sumECTS, CAST(sum(Grade*ECTS) AS  FLOAT) / sum(ECTS), case when  sum(ECTS) >=  TotalECTS then 1 else 0 end as complete
		FROM
		all_courses_registrated as acr
		JOIN Degrees as d ON d.DegreeId = acr.DegreeId
		JOIN CourseOffers as co ON co.CourseOfferId = acr.CourseOfferId
		JOIN Courses as c ON c.CourseId = co.CourseId
    GROUP BY acr.StudentId, acr.DegreeId, TotalECTS
);

-- Q3
CREATE VIEW active_per_degree(DegreeId, FemaleAmount, Amount) as (
    SELECT gac.DegreeId, sum(CASE s.Gender WHEN 'F' then 1 else 0 end), count(distinct gac.StudentId)
    FROM gpa_active_complete as gac, Students as s
    WHERE s.StudentId = gac.StudentId and gac.Complete = 0
    GROUP BY gac.DegreeId
);

CREATE VIEW high_gpa(StudentRegistrationId, StudentId, GPA) AS
(
	SELECT srtd.StudentRegistrationId, gac.StudentId, gac.GPA
	FROM gpa_active_complete as gac JOIN StudentRegistrationsToDegrees as srtd ON srtd.StudentId = gac.StudentId AND srtd.DegreeId = gac.DegreeID
	WHERE GPA >= 9.0 AND Complete = 1
);

CREATE MATERIALIZED VIEW high_gpa_no_fail(StudentId, GPA) AS
(
    SELECT high_gpa.StudentId, high_gpa.GPA
    FROM high_gpa
    WHERE high_gpa.StudentRegistrationId NOT IN
    (
        SELECT cr.StudentRegistrationId
        FROM high_gpa JOIN CourseRegistrations as cr ON cr.StudentRegistrationId = high_gpa.StudentRegistrationId
        WHERE cr.Grade  < 5 AND cr.Grade IS NOT NULL
    )
);

CREATE VIEW max_grades(CourseOfferId, Grade) AS (

    SELECT CourseOfferId, max(Grade)
    FROM all_courses_passed
    GROUP BY CourseOfferId
);

CREATE VIEW ExcellentStudents2018Q1(StudentID) AS (

    SELECT acp.StudentID
    FROM
        all_courses_passed AS acp
        JOIN
        max_grades
        ON
        acp.CourseOfferId = max_grades.CourseOfferId
    WHERE
        EXISTS(
            SELECT CourseOfferId
            FROM
                CourseOffers AS co
            WHERE
                Year = 2018 AND
                Quartile = 1
        )
        AND acp.Grade = max_grades.Grade
);
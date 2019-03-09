
-- Q4
CREATE VIEW females_per_department(Department, Amount) as (

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

    SELECT CourseOfferID, COUNT(StudentRegistrationId)
    FROM
        StudentAssistants
    GROUP BY
        CourseOfferID
);

-- Q8
CREATE VIEW total_students_and_assistants_per_offer(CourseOfferID) AS
(
    SELECT DISTINCT tspo.CourseOfferID
    FROM total_students_per_offer AS tspo JOIN total_assistants_per_offer AS tapo ON tspo.CourseOfferID = tapo.CourseOfferID
    WHERE CAST(totalStudents AS FLOAT) / totalAssistants > 50.0
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


CREATE MATERIALIZED VIEW gpa_active_complete(StudentId, DegreeId, GPA, complete) AS
(
    SELECT acp.StudentId, acp.DegreeId, cast(sum(Grade*ECTS) AS FLOAT) / sum(ECTS) as GPA, case when sum(ECTS) >=  TotalECTS then 1 else 0 end as complete
      FROM all_courses_passed as acp JOIN Degrees as d ON d.DegreeId = acp.DegreeId
      JOIN CourseOffers as co ON co.CourseOfferId = acp.CourseOfferId
      JOIN Courses as c ON c.CourseId = co.CourseId
    GROUP BY acp.StudentId, acp.DegreeId, TotalECTS
);




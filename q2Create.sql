CREATE MATERIALIZED VIEW all_courses_passed(StudentId, DegreeId, CourseOfferId, Grade) AS
(
    SELECT srtd.StudentId, srtd.degreeId, cr.CourseOfferId, cr.grade
      FROM CourseRegistrations as cr
      JOIN StudentRegistrationsToDegrees as srtd ON cr.StudentRegistrationId = srtd.StudentRegistrationId
     WHERE cr.grade > 4
);

CREATE INDEX acp_studentid_degreeid ON all_courses_passed(StudentId, DegreeId);


CREATE MATERIALIZED VIEW gpa_active_complete(StudentId, DegreeId, GPA, complete) AS
(
    SELECT acp.StudentId, acp.DegreeId, avg(Grade) as GPA, case when sum(ECTS) > TotalECTS then 1 else 0 end as complete
      FROM all_courses_passed as acp JOIN Degrees as d ON d.DegreeId = acp.DegreeId
      JOIN CourseOffers as co ON co.CourseOfferId = acp.CourseOfferId
      JOIN Courses as c ON c.CourseId = co.CourseId
    GROUP BY acp.StudentId, acp.DegreeId, TotalECTS
);

CREATE VIEW high_gpa(StudentRegistrationId, StudentId, GPA) AS
(
	SELECT srtd.StudentRegistrationId, gac.StudentId, gac.GPA
	FROM gpa_active_complete as gac JOIN StudentRegistrationsToDegrees as srtd ON srtd.StudentId = gac.StudentId AND srtd.DegreeId = gac.DegreeID
	WHERE GPA > 9.0 AND Complete = 1
);

CREATE MATERIALIZED VIEW high_gpa_no_fail(StudentId, GPA) AS
(
    SELECT high_gpa.StudentId, high_gpa.GPA
    FROM high_gpa
    WHERE high_gpa.StudentRegistrationId NOT IN
    (
        SELECT cr.StudentRegistrationId
        FROM high_gpa as gac JOIN CourseRegistrations as cr ON cr.StudentRegistrationId = high_gpa.StudentRegistrationId
        WHERE cr.Grade  < 4
    )
);
CREATE VIEW females_per_department(Department, Amount) as (

    SELECT Dept, count(distinct s.StudentId)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE     s.Gender = 'F'
            and    s.StudentId = srtd.StudentId
            and    d.DegreeId = srtd.DegreeId
    GROUP BY d.Dept
);

CREATE VIEW students_per_department(Department, Amount) as (

    SELECT Dept, count(distinct s.StudentId)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE  s.Studentid = srtd.StudentId
            and    d.DegreeId = srtd.DegreeId
    GROUP BY d.Dept
);

CREATE VIEW females_per_department_degree(Department, DegreeId, Amount) as (

    SELECT d.Dept, d.DegreeId, count(distinct s.StudentId)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE     s.gender = 'F'
            and    s.StudentId = srtd.StudentId
            and    d.Degreeid = srtd.DegreeId
    GROUP BY CUBE (d.Dept, d.DegreeId)
);

CREATE VIEW students_per_department_degree(Department, DegreeId, Amount) as (

    SELECT dept, d.DegreeId, count(distinct s.studentid)
    FROM Students as s, Degrees as d, StudentRegistrationsToDegrees as srtd
    WHERE  s.studentid = srtd.studentid
            and    d.degreeid = srtd.degreeid
    GROUP BY CUBE (d.Dept, d.DegreeId)
);

CREATE VIEW active_females_per_degree(Degree, Amount) as (

    SELECT gac.degreeID, count(distinct gac.StudentId)
    FROM
        gpa_active_complete as gac, Students as s
    WHERE
            s.StudentId = gac.StudentId
        and gac.Complete = 0
        and s.Gender = 'F'
    GROUP BY gac.DegreeId
);


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


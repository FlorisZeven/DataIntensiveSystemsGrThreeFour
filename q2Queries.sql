SELECT c.CourseName, Grade FROM  all_courses_passed as acp JOIN CourseOffers as co ON co.CourseOfferId = acp.CourseOfferId JOIN Courses as c ON c.CourseId = co.CourseId WHERE acp.StudentId = %1% AND acp.DegreeId = %2% ORDER BY co.Year, co.Quartile, co.CourseOfferId;
SELECT DISTINCT StudentId FROM high_gpa_no_fail WHERE GPA > %1%;
SELECT DegreeId, cast(count(case when s.Gender = 'F' then 1 end) AS FLOAT)/ count(Gender) as Percentage FROM gpa_active_complete as gac JOIN Students as s ON gac.StudentId = s.StudentId WHERE gac.complete = 0 GROUP BY DegreeId ORDER BY DegreeId;
SELECT 0;
SELECT 0;
SELECT 0;
SELECT 0;
SELECT 0;
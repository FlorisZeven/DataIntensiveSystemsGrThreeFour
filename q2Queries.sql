SELECT c.CourseName, Grade FROM  all_courses_passed as acp JOIN CourseOffers as co ON co.CourseOfferId = acp.CourseOfferId JOIN Courses as c ON c.CourseId = co.CourseId WHERE acp.StudentId = %1% AND acp.DegreeId = %2% ORDER BY co.Year, co.Quartile, co.CourseOfferId;
SELECT 0;
SELECT 0;
SELECT CAST(fpd.Amount AS FLOAT) / spd.Amount FROM females_per_department as fpd JOIN students_per_department as spd ON spd.Department = fpd.Department WHERE Department = %1%;
SELECT 0;
SELECT 0;
SELECT 0;
SELECT 0;
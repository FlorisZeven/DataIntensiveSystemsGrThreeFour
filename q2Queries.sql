SELECT c.CourseName, Grade FROM  all_courses_passed as acp JOIN CourseOffers as co ON co.CourseOfferId = acp.CourseOfferId JOIN Courses as c ON c.CourseId = co.CourseId WHERE acp.StudentId = %1% AND acp.DegreeId = %2% ORDER BY co.Year, co.Quartile, co.CourseOfferId;
SELECT DISTINCT StudentId FROM high_gpa_no_fail WHERE GPA > %1% ORDER BY StudentId;
SELECT DegreeId, CAST(FemaleAmount AS FLOAT) / Amount FROM active_per_degree as apd ORDER BY DegreeId;
SELECT CAST(fpd.Amount AS FLOAT) / spd.Amount FROM females_per_department as fpd JOIN students_per_department as spd ON spd.Department = fpd.Department WHERE fpd.Department = %1%;
SELECT 0;
SELECT 0;
SELECT gac.DegreeId, s.BirthYearStudent, s.Gender, CAST(sum(Weighted) AS FLOAT) / sum(sumECTS) as avgGPA FROM gpa_active_complete as gac JOIN Students as s ON gac.StudentId = s.StudentId WHERE gac.Complete = 0 GROUP BY CUBE (gac.DegreeId, s.BirthYearStudent, s.Gender) ORDER BY gac.DegreeId, s.BirthYearStudent, s.Gender;
SELECT DISTINCT c.CourseName, co.year, co.quartile FROM total_students_and_assistants_per_offer AS tsaapo  JOIN CourseOffers AS co ON co.CourseOfferID = tsaapo.CourseOfferId JOIN Courses as c ON c.CourseId = co.CourseId ORDER BY tsaapo.CourseOfferId;

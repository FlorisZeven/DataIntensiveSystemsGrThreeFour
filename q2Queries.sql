SELECT 0;
SELECT DISTINCT StudentId FROM high_gpa_no_fail WHERE GPA > %1% ORDER BY StudentId;
SELECT 0;
SELECT CAST(fpd.Amount AS FLOAT) / spd.Amount FROM females_per_department as fpd JOIN students_per_department as spd ON spd.Department = fpd.Department WHERE fpd.Department = %1%;
SELECT 0;
SELECT 0;
SELECT 0;
SELECT 0;
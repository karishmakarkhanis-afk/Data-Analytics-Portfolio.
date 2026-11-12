USE excelhr ;
-- Total count of Employeess 
SELECT COUNT(EmployeeNumber) AS Total_Employees 
FROM excel_hr;

-- Attrition count & Attrition rate 

SELECT COUNT(EmployeeNumber) AS Attrition_Count 
FROM excel_hr
WHERE Attrition = 'Yes';

SELECT 
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(EmployeeNumber)) * 100, 2) AS Attrition_Rate_Percentage 
FROM excel_hr;

-- Average Attrition rate for all Departments
SELECT Department,
    ROUND(AVG(Attrition_Y) * 100, 2) AS Attrition_Rate
FROM excel_hr
GROUP BY Department;

-- Active employes
SELECT COUNT(EmployeeNumber) AS Active_Employees 
FROM excel_hr
WHERE Attrition = 'No';

-- Average Employees age 
SELECT ROUND(AVG(Age), 1) AS Average_Age 
FROM excel_hr;

-- Average Hourly rate of Male Research Scientist 
SELECT ROUND(AVG(HourlyRate),2) AS Avg_Hourly_Rate
FROM excel_hr
WHERE Gender='Male'
AND JobRole='Research Scientist';

-- Attrition rate vs Monthly income stats
SELECT
    Attrition,
    ROUND(AVG(MonthlyIncome),2) AS Avg_Income,
    MIN(MonthlyIncome) AS Min_Income,
    MAX(MonthlyIncome) AS Max_Income
FROM excel_hr
GROUP BY Attrition;

-- Average working years for each Department 
SELECT
    Department,
    ROUND(AVG(TotalWorkingYears),2) AS Avg_Working_Years
FROM excel_hr
GROUP BY Department;

-- Job Role vs Work life balance
SELECT
    JobRole,
    ROUND(AVG(WorkLifeBalance),2) AS Avg_WorkLife_Balance
FROM excel_hr
GROUP BY JobRole;

-- Attrition rate vs year since last promotion relation
SELECT
    YearsSinceLastPromotion,
    ROUND(AVG(Attrition_Y) * 100,2) AS Attrition_Rate
FROM excel_hr
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;

-- summary 
SELECT 
    COUNT(EmployeeNumber) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count,
    COUNT(EmployeeNumber) - SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Active_Employees,
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(EmployeeNumber)) * 100, 2) AS Attrition_Rate_Percentage,
    ROUND(AVG(Age), 1) AS Average_Age,
    ROUND(AVG(MonthlyIncome), 2) AS Average_Monthly_Income
FROM excel_hr;



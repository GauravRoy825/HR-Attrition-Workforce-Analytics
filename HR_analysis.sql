select * from HR_Employee_Attrition

--checking null values
SELECT 
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END) AS Null_Income,
    SUM(CASE WHEN Attrition IS NULL THEN 1 ELSE 0 END) AS Null_Attrition
FROM HR_Employee_Attrition

--dropping 3 tables (having same repetitive values)
ALTER TABLE HR_Employee_Attrition 
DROP COLUMN EmployeeCount, Over18, StandardHours;

-- Adding Age Group
ALTER TABLE HR_Employee_Attrition ADD AgeGroup VARCHAR(20);

UPDATE HR_Employee_Attrition
SET AgeGroup = CASE 
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 40 THEN '30-40'
    WHEN Age BETWEEN 41 AND 50 THEN '41-50'
    ELSE '51+'
END;

-- Adding Income Group
ALTER TABLE HR_Employee_Attrition ADD IncomeGroup VARCHAR(20);

UPDATE HR_Employee_Attrition
SET IncomeGroup = CASE 
    WHEN MonthlyIncome < 5000 THEN 'Low (<$5k)'
    WHEN MonthlyIncome BETWEEN 5000 AND 10000 THEN 'Medium ($5k-$10k)'
    ELSE 'High (>$10k)'
END;

select agegroup, incomegroup  from HR_Employee_Attrition

--overall attrition rate
SELECT 
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Total_Attrition,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM HR_Employee_Attrition

--attrition by department and job role
SELECT 
    Department,
    JobRole,
    COUNT(*) AS Employee_Count,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM HR_Employee_Attrition
GROUP BY Department, JobRole
ORDER BY Attrition_Rate DESC

--overtime vs attrition
SELECT 
    OverTime,
    COUNT(*) AS Total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM HR_Employee_Attrition
GROUP BY OverTime

--attrition by age group
SELECT 
    AgeGroup,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate_Pct
FROM HR_Employee_Attrition
GROUP BY AgeGroup
ORDER BY Attrition_Rate_Pct DESC

--attrition by income band
SELECT 
    IncomeGroup,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate_Pct
FROM HR_Employee_Attrition
GROUP BY IncomeGroup
ORDER BY Attrition_Rate_Pct DESC

--attrition by business travel
SELECT 
    BusinessTravel,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate_Pct
FROM HR_Employee_Attrition
GROUP BY BusinessTravel
ORDER BY Attrition_Rate_Pct DESC

--overtime + job role
SELECT 
    JobRole,
    OverTime,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate_Pct
FROM HR_Employee_Attrition
GROUP BY JobRole, OverTime
ORDER BY Attrition_Rate_Pct DESC

--employee risk segmentation
--High Risk, Medium Risk, and Low Risk profiles based on common attrition triggers (OverTime, Low Income, High Travel, and Low Tenure)

SELECT 
    CASE 
        WHEN OverTime = 1 AND MonthlyIncome < 5000 AND BusinessTravel = 'Travel_Frequently' THEN 'High Risk (Burnout & Low Pay)'
        WHEN OverTime = 1 AND YearsAtCompany < 2 THEN 'Medium-High Risk (New Hire Overwork)'
        WHEN MonthlyIncome < 5000 AND YearsSinceLastPromotion > 3 THEN 'Medium Risk (Stagnant Low Earner)'
        ELSE 'Low Risk'
    END AS Risk_Segment,
    COUNT(*) AS Employee_Count,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate_Pct
FROM HR_Employee_Attrition
GROUP BY 
    CASE 
        WHEN OverTime = 1 AND MonthlyIncome < 5000 AND BusinessTravel = 'Travel_Frequently' THEN 'High Risk (Burnout & Low Pay)'
        WHEN OverTime = 1 AND YearsAtCompany < 2 THEN 'Medium-High Risk (New Hire Overwork)'
        WHEN MonthlyIncome < 5000 AND YearsSinceLastPromotion > 3 THEN 'Medium Risk (Stagnant Low Earner)'
        ELSE 'Low Risk'
    END
ORDER BY Attrition_Rate_Pct DESC
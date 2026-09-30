create database Hr;
Use Hr;
drop database Hr;
-- Importing Hr File from Excel
create table Hr (
	Satisfaction_Level varchar(10),
    Last_Evaluation varchar(10),
    Number_Project varchar(10),
    Average_Monthly_Hours varchar(10),
    Time_Spend_Company varchar(10),
    Work_Accident varchar(10),
    Left_ varchar(10),
    Promotion_Last_5years varchar(5),
	Department varchar(40),
	Salary varchar(20)
);

select * from Hr;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR_comma_sep.csv"
into table Hr
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(Satisfaction_Level, Last_Evaluation, Number_Project, Average_Monthly_Hours, Time_Spend_Company, 
Work_Accident, Left_, Promotion_Last_5years, Department, Salary);

-- Basic Analysis
select count(*) from Hr;
/*    14999 Employees    */


-- 1.]  EMPLOYEE SATISFACTION AND RETENTION
-- 1a] Identify trends between satisfaction levels and employee retention.

select Left_ as EmployeeStatus, count(*) as TotalEmployees,
round(avg(Satisfaction_Level),2) as AvgSatisfaction
from Hr Group by Left_;

/*  Employee Status for Those who Left the Company
	Total Employees      = 3,571 
    Average Satisfaction = 0.44
    
    Employee Status for Those who is still in the Company
    Total Employees      = 11,428
    Average Satisfaction = 0.67
*/

select case
when Satisfaction_Level between 0.0 and 0.4 then 'Low'
when Satisfaction_Level between 0.4 and 0.7 then 'Medium'
when Satisfaction_Level > 0.7 then 'High'
else 'N/A'
end as SatisfactionGroup,
avg(Left_) as Turnover_Rate
from Hr group by SatisfactionGroup order by SatisfactionGroup;

/* Satisfaction Group
   For High->   The Average is 0.15
   For Low->    The Average is 0.56
   For Medium-> The Average is 0.16
*/

-- 1b]  Compare satisfaction levels across different departments.
select Department,
  round(avg(Satisfaction_Level), 2) as AvgSatisfaction, count(*) as TotalEmployees
from HR
group by Department order by AvgSatisfaction desc;

/*  The Support department has an average satisfaction score of 0.62 across 2,229 employees.
    The Management department has an average satisfaction score of 0.62 across 630 employees.
    The IT department has an average satisfaction score of 0.62 across 1,227 employees.
    The Product_mng department has an average satisfaction score of 0.62 across 902 employees.
    The Marketing department has an average satisfaction score of 0.62 across 858 employees.
    The RandD department has an average satisfaction score of 0.62 across 787 employees.
    The Sales department has an average satisfaction score of 0.61 across 4,140 employees.
    The Technical department has an average satisfaction score of 0.61 across 2,720 employees.
    The Hr department has an average satisfaction score of 0.60 across 739 employees.
    The Accounting department has an average satisfaction score of 0.58 across 767 employees.
*/

-- 2.]	PERFORMANCE AND WORKLOAD ANALYSIS
-- 2a]  Evaluate the impact of the number of projects and working hours on employee performance.

select Number_Project, round(avg(Average_Monthly_Hours), 2) as AvgMonthlyHours, round(avg(Last_Evaluation), 2) as AvgPerformance
from Hr group by Number_Project  order by Number_Project;

/*   Number of Project(2) -> Average Monthly Hours = 160.34 and Average Performance = 0.57
     Number of Project(3) -> Average Monthly Hours = 197.51 and Average Performance = 0.72
     Number of Project(4) -> Average Monthly Hours = 205.12 and Average Performance = 0.74
     Number of Project(5) -> Average Monthly Hours = 212.06 and Average Performance = 0.76
     Number of Project(6) -> Average Monthly Hours = 238.69 and Average Performance = 0.79
     Number of Project(7) -> Average Monthly Hours = 276.08 and Average Performance = 0.86
*/

-- 2b]  Identify employees at risk of burnout based on excessive working hours.
select avg(Average_Monthly_Hours) from Hr;
-- Average = 201.05

select * from Hr where Average_Monthly_Hours > 201.05 order by Average_Monthly_Hours desc;

select Department, Number_Project, Average_Monthly_Hours, Last_Evaluation, Satisfaction_Level
from Hr where Average_Monthly_Hours > 201.05 order by Average_Monthly_Hours desc;

-- 3.]	Turnover Prediction
-- 3a]  Analyze common patterns among employees who left the company.

select round(avg(Satisfaction_Level), 2) as AvgSatisfaction, round(avg(Last_Evaluation), 2) as AvgEvaluation, 
       round(Avg(Number_Project), 2) as AvgProjects, round (avg(Time_Spend_Company), 2) as AvgYears,
       sum(Work_Accident) as AccidentsCount, sum(Promotion_Last_5years) as PromotedCount from Hr where Left_ = 1;
       
/*    Summary profile of those who left.
	The Average Satisfaction is 0.44
    Average Evaluation is 0.72
    Average Project is 3.86
    Average Years is 3.88
    Total Accident is 169
    Total Promoted is 19
*/

--  3b]  Determine the influence of promotions and salary levels on employee retention

select Promotion_Last_5years, Salary, count(*) as TotalEmployees,
	   sum(case when Left_ = 1 then 1 else 0 end) as EmployeesLeft,
       round(100 * sum(case when Left_ = 1 then 1 else 0 end) / count(*), 2) as TurnoverRate
       from Hr group by Promotion_Last_5years, salary order by Promotion_Last_5years desc, salary;

/*     Employees Promoted in the Last 5 Years
   For High Salary -> 72 Employees Stayed while None left and the rate is 0%
   For Low Salary -> 66 Employees Stayed while 14 Left and the rate is 21.21%
   For Medium Salary -> 181 Employees Stayed while 5 Left and the rate is 2.76%
   
		Employees not Promoted in the Last 5 Years
	For High Salary -> 1165 Stayed while 82 Left and the rate is 7.04%
    For Low Salary -> 7250 Stayed while 2158 Left and the rate is 29.77%
    For Meduim Salary -> 6265 Stayed while 1312 Left and the rate is 20.94%
*/

--  4.]	  DEPARTMENT-WISE INSIGHTS
--  4a]   Assess turnover rates across different departments.
select Department, count(*) as TotalEmployees,
sum(case when Left_ = 1 then 1 else 0 end) as EmployeesLeft,
round(sum(case when Left_ = 1 then 1 else 0 end) / count(*) *100,2) as TurnoverRate
from Hr group by Department;

/*  Sales ------>   1014 out of 4140 Employees left and the Turnover Rate is 24.49%
    Accounting ->   204 out of 767 Employees left and the Turnover Rate is 26.60%
    Hr --------->   215 out of 739 Employees left and the Turnover Rate is 29.09%
    Technical -->   697 out of 2720 Employees left and the Turnover Rate is 25.63%
    Support ---->   555 out of 2229 Employee left and the Turnover Rate is 24.90%
    Management ->   91 out of 630 Employees left and the Turnover Rate is 14.44%
    IT --------->   273 out of 1227 Employees left and the Turnover Rate is 22.25%
    Product_mng->   198 out of 902 Employees left and the Turnover Rate is 21.95%
    Marketing -->   203 out of 858 Employees left and the Turnover Rate is 23.66%
    RandD ------>   121 out of 787 Employees left and the Turnover Rate is 15.37%
*/

--  4b]   Identify departments with high retention and satisfaction levels.
select Department, count(*) as TotalEmployees,
sum(case when Left_ = 0 then 1 else 0 end) as EmployeesRetained,
round(avg(case when Left_ = 0 then Satisfaction_Level else null end), 2) as AvgSatisfaction_Stayed
from Hr group by Department;

/*   Sales ------->  3126 out of 4140 Employees Retained and the Average Satisfaction is 0.67
     Accounting -->  563 out of 767 Employees Retained and the Average Satisfaction is 0.65
     Hr ---------->  524 out of 739 Employees Retained and the Average Satisfaction is 0.67
     Technical - ->  2023 out of 2720 Employees Retained and the Average Satisfaction is 0.67
     Support ----->  1674 out of 2229 Employees Retained and the Average Satisfaction is 0.67
     Management -->  539 out of 630 Employees Retained and the Average Satisfaction is 0.65
     IT ---------->  954 out of 1227 Employees Retained and the Average Satisfaction is 0.68
     Product_mng ->  704 out of 902 Employees Retained and the Average Satisfaction is 0.66
     Marketing --->  655 out of 858 Employees Retained and the Average Satisfaction is 0.67
     RandD ------->  666 out of 787 Employees Retained and the Average Satisfaction is 0.65
*/

-- 5.] 	SALARY IMPACT ON RETENTION
-- 5a]   Analyze how salary levels influence employee satisfaction and attrition.
select * from Hr;

select Salary, count(Satisfaction_Level), Left_ from Hr where Left_ = 1 group by Salary;

select Salary, count(*) as TotalEmployees,
sum(case when Left_ = 1 then 1 else 0 end) as EmployeesLeft,
round(avg(Satisfaction_Level), 2) as AvgSatisfaction 
from Hr group by Salary order by field(Salary, 'low', 'meduim', 'high');

/*   For Low Salary ----> 2172 out of 7316 Employees Left with Average Satisfaction of 0.60
     For Medium Salary -> 1317 out of 6446 Employees Left with Average Satisfaction of 0.62
     For High Salary ---> 82 out of 1237 Employees Left with Average Satisfaction of 0.64
*/

-- 5b]   Compare salary trends across departments.

select Department, Salary, count(*) as EmployeeCount
from Hr group by Department, Salary
order by Department, field(Salary, 'low', 'meduim', 'high');

/*                       Low           Meduim            High
  For Accouting -->      358            335              74
  For Hr --------->      335            359              45
  For IT --------->      535            609              83
  for Management ->      180            225              225
  For Marketing -->      402            376              80
  Product_mng ---->      451            383              80
  RandD ---------->      364            372              51
  Sales ---------->      2099           1772             269
  Support -------->      1146           942              141
  Technical ------>      1372           1147             201
  
Sales Department have the Highest population of the Lowest Salaries, Medium Salaries and Highest Salaries (2099, 1772 and 269)
Hr Department have the Lowest population of High Salaries (45)
Management Department have the Lowest population of Lowest Salaries and Medium Salaries (180 and 225)
*/

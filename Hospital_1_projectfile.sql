--Flu Shot Recipients by County
--Dashboard Visualization: Bar chart or map showing the total number of flu shots by county.
--How many patients received a flu shot in each county?
select county, count(*) as counts
from HOSPITAL_DB.PUBLIC.FLU
where FLU_SHOT_2022=1
group by county

--Flu Shot Recipients by Age Group
--Dashboard Visualization: Pie chart or bar chart showing the distribution of flu shot recipients by age group.
--What is the distribution of flu shot recipients by age group (e.g., 0-18, 19-35, 36-50, 51-65, 66+)?
select case
when age<=18 then '0-18'
when age>=19 and age<=28 then '20-28'
when age>=29 and age<=65 then '29-65'
ELSE  '65+' end as Age_range, COUNT(ID) AS flu_shot_count
from HOSPITAL_DB.PUBLIC.FLU
where FLU_SHOT_2022=1
group by Age_range
order by Age_range

-- COVID Positive Flu Shot Recipients
-- Dashboard Visualization: Simple KPI indicator showing the count of COVID-positive flu recipients.
-- How many COVID-positive patients received a flu shot?
select count(distinct h.patient_id) as covid_positive_Count
from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.patient_id=f.id
where  f.flu_shot_2022=1 and h.covid=1

-- Flu Shot Recipients by Ethnicity
-- Dashboard Visualization: Stacked bar chart or pie chart displaying flu shot recipients by ethnicity.
-- What is the breakdown of flu shot recipients by ethnicity?
select ethnicity, count( distinct id) as flu_shot_Count
from HOSPITAL_DB.PUBLIC.FLU
where flu_shot_2022 =1
group by ethnicity

-- Monthly Flu Shot Administration
-- Dashboard Visualization: Line chart showing the trend of flu shots administered by month.
-- How many flu shots were administered each month in 2022?
Had to try ‘try_Cast’
Can't parse 'NULL' as timestamp with format 'YYYY-MM-DD HH24:MI:SS'
The issue you're encountering happens because there are NULL or invalid date strings (e.g., 'NULL' as a string) in your VARCHAR column. When using functions like TO_TIMESTAMP or STR_TO_DATE, the database attempts to convert these strings, which fails because 'NULL' (as a string) or other invalid formats can't be parsed as a date.
solution:
To handle this, you need to:
Filter out rows where the date string is 'NULL' (if that's a string, not an actual NULL).
Use a CASE statement or TRY_CAST (in SQL Server) to check if the value can be converted before attempting conversion.
   MONTH(TRY_CAST(EARLIEST_FLU_SHOT_2022 AS DATETIME)) AS month
SELECT 
    MONTH(TRY_CAST(EARLIEST_FLU_SHOT_2022 AS DATETIME)) AS month, count(distinct id) as recipients_count
FROM 
    HOSPITAL_DB.PUBLIC.FLU
where year(TRY_CAST(EARLIEST_FLU_SHOT_2022 AS DATETIME)) =2022 
group by month

-- Average Encounter Cost for Flu Patients
-- Dashboard Visualization: KPI indicator displaying the average encounter cost.
-- What is the average total claim cost for patients who received a flu shot?
select avg(h.TOTAL_CLAIM_COST)  AS average_claim_cost
from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.PATIENT_ID= f.id
where f.flu_shot_2022=1

-- Most Common Encounter Reasons for Flu Patients
 -- Dashboard Visualization: Bar chart showing the top encounter reasons.
-- What are the most common encounter reasons for patients who received flu shots?
Select distinct h.enc_reason, count(h.ENCOUNTER_ID) as enc_reason_count
from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.patient_id=f.id
where f.flu_shot_2022=1
group by h.enc_reason
order by enc_reason_count desc

-- Flu Shot Recipients by Birthdate
-- Dashboard Visualization: Line chart showing flu shot recipients by birth year.
--  How many flu shot recipients were born in each year?
select year(h.BIRTHDATE) as patient_birth_year, count(f.flu_shot_2022) as count
from HOSPITAL_DB.PUBLIC.FLU f
join HOSPITAL_DB.PUBLIC.HOSPITAL h on f.id=h.patient_id
where f.flu_shot_2022=1
group by patient_birth_year
order by patient_birth_year 

-- Flu Shot Trends by Month
 -- Dashboard Visualization: Line chart showing the trend of flu shots administered by month.
-- How many flu shots were administered each month in 2022?
SELECT MONTH(TRY_CAST(EARLIEST_FLU_SHOT_2022 AS DATE)) AS month, 
       COUNT(ID) AS total_flu_shots
FROM HOSPITAL_DB.PUBLIC.FLU
WHERE EARLIEST_FLU_SHOT_2022 IS NOT NULL
GROUP BY MONTH(TRY_CAST(EARLIEST_FLU_SHOT_2022 AS DATE))
ORDER BY month;

-- Top 5 Hospitals by Flu Shot Recipients*
-- Dashboard Visualization: Horizontal bar chart ranking hospitals by the number of flu shot recipients.
-- Which hospitals had the most patients receiving flu shots in 2022?
WITH RankedFluShots AS ( 
SELECT h.org_name, COUNT(DISTINCT h.PATIENT_ID) AS flu_shot_patients, 
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT h.PATIENT_ID) DESC) AS ranking 
FROM HOSPITAL_DB.PUBLIC.HOSPITAL h JOIN HOSPITAL_DB.PUBLIC.FLU f ON h.PATIENT_ID = f.id WHERE f.FLU_SHOT_2022 = 1 
GROUP BY h.org_name ) 
SELECT ranking, org_name, flu_shot_patients FROM RankedFluShots 
ORDER BY ranking 
LIMIT 5;

--Cost Distribution of Hospital Encounters
--Dashboard Visualization: Bar chart showing the count of patients in each cost range.
-- What is the distribution of total claim costs for hospital encounters among flu shot recipients?
select h.org_name,sum(h.total_claim_cost)as total_claim_Costs from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.patient_id=f.id
where f.FLU_SHOT_2022 = 1
group by h.org_name

-- Encounter Class Distribution for Flu Patients
-- Dashboard Visualization: Bar chart or pie chart showing the distribution of encounter classes.
-- What is the distribution of encounter classes for patients who received a flu shot?
select h.encounterclass, count(h.encounter_id)
from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.patient_id=f.id
where f.FLU_SHOT_2022=1
group by h.encounterclass

-- Total Encounter Cost by Encounter Class
-- Dashboard Visualization: Bar chart showing total costs by encounter class.
-- What is the total encounter cost for each encounter class for flu shot recipients?
select h.encounterclass, sum(h.base_encounter_cost) as tot
from HOSPITAL_DB.PUBLIC.HOSPITAL h
join HOSPITAL_DB.PUBLIC.FLU f on h.patient_id = f.id
where f.FLU_SHOT_2022 = 1
group by encounterclass

-- Flu Shot Recipients by ZIP Code
--  Dashboard Visualization: Map visualization of flu shot recipients by ZIP code.
-- What is the count of flu shot recipients by ZIP code?
select distinct zip, count(id)as people_count
from HOSPITAL_DB.PUBLIC.FLU
where flu_shot_2022=1
group by zip
order by people_count

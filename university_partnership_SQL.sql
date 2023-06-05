with t1 as (
select distinct institution_name, Unit_Id,
CAST(REPLACE(Total, ',','') AS int64) 
as enrollments, 
cast(replace(Foreign_countries___Number, ',', '') as int64) as foreign_enrollments,
year
from `prism-2023-c1.INTO_Live_Brief_Sandbox.MMC2a`
where Total != '-' and Foreign_countries___Number != '-' 
and 
institution_name not in ('Colorado State University', 'Drew University', 'George Mason University', 
'Hofstra University', 'Illinois State University', 'Oregon State University', 'Saint Louis University',
'Suffolk University', 'University of Massachusetts-Amherst', 'University of Massachusetts Amherst', 
'University of Alabama at Birmingham', 'University of Arizona')
-- and year = 2020 
--and institution_name = 'Florida State University'
), 
t2 as (
select distinct t1.institution_name as institution_name, t1.Unit_id as ID, t1.enrollments as enrollments, 
t1.foreign_enrollments as foreign_enrollments, 
round ((100 * (t1.foreign_enrollments / t1.enrollments)), 2) as percentage, t1.year as year
from t1
--where t1.enrollments between 5000 and 9000  and t1.year = 2020 
order by 3 desc
)
--select * from t2
,
t3 as (
  select distinct t2.institution_name as institution_name, t2.ID as ID, t2.enrollments as enrollments, 
t2.foreign_enrollments as foreign_enrollments, t2.percentage, round((t2.percentage / t2.enrollments), 4) as ratio, t2.year
from t2
--where (percentage between 1 and 5) 
order by 6 desc)
--select * from t3
,
t4 as (
select distinct UNITID, CONTROL
from  prism-2023-c1.INTO_Live_Brief_Sandbox.MMCC
)
select distinct t3.institution_name as institution_name, t3.enrollments as enrollments,  t3.foreign_enrollments as foreign_enrollments, 
t3.percentage, t3.ratio as ratio,
t4.control, t3.Year,t.LATITUDE, t.LONGITUDE, t.CITY, t.ADM_RATE_ALL,m.COUNTYNM, m.ICLEVEL,
cast(replace (t.TUITIONFEE_OUT, ',', '') as int64) as tuition
from t3
join t4 on t4.UNITID = t3.ID
join `prism-2023-c1.INTO_Live_Brief_Sandbox.MMC1a` m on t3.ID = m.UNITID and t3.year = m.year
join `prism-2023-c1.INTO_Live_Brief_Sandbox.MMC` t on t.UNITID = t3.ID
where t.TUITIONFEE_OUT not in ('NULL') 

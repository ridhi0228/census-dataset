SELECT * FROM datasetcensus.`datasheet 2 csv`;
SELECT* FROM census1.dataset1csv;

-- no of rows in our dataset
select count(*)from datasetcensus.`datasheet 2 csv`;
select count(*)from census1.dataset1csv;

-- dataset for jharkhand and bihar

SELECT* FROM census1.dataset1csv
WHERE STATE IN('Jharkhand', 'bihar');

-- population of India

select sum( population)'population of India'from datasetcensus.`datasheet 2 csv`;

-- average growth

select avg(growth)'Average growth' from census1.dataset1csv;

-- average growth as per state

select state, avg(growth) from  census1.dataset1csv group by state order by state asc;

-- average sex ratio per state

select state,
round(avg(sex_ratio),0)'avg_sex_ratio'
from census1.dataset1csv 
group by state
order by avg_sex_ratio desc;

-- average literacy rate >90

select state,round(avg(literacy),0)'avg_literacy_rate'
from census1.dataset1csv 
group by state
having round(avg(literacy),0) >90;

-- top 3 states having highest average growth rate

select state,
round(avg(growth),0)
from census1.dataset1csv 
group by state
order by round(avg(growth),0)desc
limit 3;

-- bottom 3 states having lowest sex ratio

select state,
round(avg(sex_ratio),0)
from census1.dataset1csv 
group by state
order by round(avg(sex_ratio),0) asc
limit 3;

-- top and bottom 3 rows in literacy ratio

drop table if exists topstates;
create table topstates
(state varchar(255),
topstate float);

insert into topstates
(select state,round(avg(literacy),0)'avg_literacy_rate'
from census1.dataset1csv 
group by state);

select* from topstates
order by topstates.topstate desc limit 3;

-- bottom 3 states

create table bottomstates
(state Varchar(255),
bottomstate float)

insert into bottomstates
(select state,round(avg(literacy),0)'avg_literacy_rate'
from census1.dataset1csv 
group by state);

select*from bottomstates
order by bottomstates.bottomstate asc limit 3;

-- union operator

select*from(
select* from topstates order by topstates.topstate desc limit 3)a

union

select*from(
select*from bottomstates order by bottomstates.bottomstate asc limit 3)b;

-- select states starting with letter a

select distinct  state from census1.dataset1csv
where state like 'a%';


-- males and females out of total population
-- joining both the tables


select d.state,sum(d.males)'total males',sum(d.females)'total female'from(select c.district,c.state,round(c.population/(c.sex_ratio+1),0)'Males',round((c.population*c.sex_ratio)/(c.sex_ratio+1),0)'Females'
 from
(select a.district, a.state, a.sex_ratio, b.population 
from census1.dataset1csv a JOIN datasetcensus.`datasheet 2 csv` b on a.district = b.district)c)d
group by d.state
order by state;

-- total literacy rate

select d.state,sum(literate_people),sum(illiterate_people) from(
select c.state,c.district,round(c.literacy_rate*c.population,0)'literate_people',round((1-c.literacy_rate)*c.population,0)'illiterate_people' from
(select a.district, a.state, a.literacy/100'literacy_rate', b.population 
from census1.dataset1csv a JOIN datasetcensus.`datasheet 2 csv` b on a.district = b.district)c)d
group by d.state
order by d.state ;

-- population in previous census


select sum(e.total_previous_census)'previous_census',sum(e.total_current_census)'current_census' from(
select d.state,sum(d.previous_census)'total_previous_census',sum(d.current_census)'total_current_census' from(
select c.district,c.state,round(c.population/(1+c.growth),0)'previous_census',c.population'current_census' from
(select a.district, a.state, a.growth/100'growth', b.population 
from census1.dataset1csv a JOIN datasetcensus.`datasheet 2 csv` b on a.district = b.district)c)d
group by d.state)e

-- top 3 districts from each state having highest literacy rate


 select a.*from
(select district,literacy,state,rank() over(partition by state order by literacy desc) rnk from census1.dataset1csv)a
where rnk in(1,2,3)
order by state;
 


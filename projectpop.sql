select * from projectpopulation.popdemograghics
order by 1;

SELECT 
    ranks, country, continent, pop2022, pop2021
FROM
    popdemograghics
    order by 1,3,4;
	
SELECT 
    ranks, country, continent, pop2022 , landAreaKm,density ,(pop2022/landAreaKm)*1000 as lk FROM
    popdemograghics
    order by 1,3,4;
    
select * from popother;

select country, ranks,`Fert.Rate`,`Med.Age`,`Migrants(net)` from popother
where `Migrants(net)`>0
and ranks between 50 and 100
and `Med.Age` not in (38,28,35)
    order by 2 desc;
    
    select continent, count(country),round(avg(WorldPercentage)*100,2) from popdemograghics
    group by Continent;
    
    select round(avg(ranks),0) as ranks,country, avg(pop2022)*1000 as population,WorldPercentage from popdemograghics
    group by country,WorldPercentage
    having ranks < 100
    order by 1  limit 20;
 
 -- creating tables
 
    drop table if exists topcountry;
    create table topcountry(
         ranks int not null, country varchar(250),population float, WorldPercentage varchar(100));
         
		insert into topcountry
        select round(avg(ranks),0) as ranks,country, avg(pop2022) as population,WorldPercentage from popdemograghics
    group by country,WorldPercentage
    having ranks <50
    order by 1  limit 20;
        
     create table bottomcountry(
         ranks int not null, country varchar(250),population float, WorldPercentage varchar(100));
         
		insert into bottomcountry
        select round(avg(ranks),0) as ranks,country, avg(pop2022) as population,WorldPercentage from popdemograghics
    group by country,WorldPercentage
    having ranks >150
    order by 1 desc  limit 20;
    
    select * from bottomcountry limit 5;
    
-- union functions


 select * from( select * from topcountry limit 5) a
  union
select * from (select * from bottomcountry limit 5) b;

    
    select * from popdemograghics
    where country like 'a%' or country like 'c%' or country like 'f%';
    
    -- joins
    
    select p1.ranks,p1.country,p1.pop2022,p1.pop2021,p1.landAreaKm, p2.`Migrants(net)`,p2.`Fert.Rate`,p2.`Urban Pop%` from popdemograghics p1   join popother p2
    on p1.ranks=p2.ranks
    order by ranks ;
    
    alter table popdemograghics
    drop column GrowthRate;

select * from popdemograghics;

-- Growth_rate= ((present_population-previous_population)/previous_population)*100

 select p3.ranks,p3.country,p3.Continent,p3.`Urban Pop%`,p3.pop2022,p3.pop2021,round(((p3.pop2022-p3.pop2021)/p3.pop2021)*100,2) Growth_Rate from
 (select p1.ranks,p1.country,p1.Continent,p1.pop2022,p1.pop2021,p1.landAreaKm, p2.`Migrants(net)`,p2.`Fert.Rate`,p2.`Urban Pop%` from popdemograghics p1
 left join popother p2 on p1.ranks=p2.ranks) p3;
    
    
    alter table popdemograghics
    drop column gr;
    alter table popdemograghics
    add column gr float not null;
    
      insert  into popdemograghics(gr) select  round(((p3.pop2022-p3.pop2021)/p3.pop2021)*100,2)  from
 (select p1.ranks,.country,p1.Continent,p1.pop2022,p1.pop2021,p1.landAreaKm, p2.`Migrants(net)`,
 p2.`Fert.Rate`,p2.`Urban Pop%` from popdemograghics p1 left join popother p2
    on p1.ranks=p2.ranks) p3;
    
 --   previous_popultion= present_population/(1+Growth_rate)
 -- predicting population
 select p3.ranks,p3.country,p3.Continent,p3.`Urban Pop%`,p3.pop2022,p3.pop2021,round(p3.pop2022*((1+Growth_rate)^10*0.1),2) pop2032 from
 (select p1.ranks,p1.country,p1.Continent,p1.pop2022,p1.pop2021,p1.Growth_rate,p1.landAreaKm, p2.`Migrants(net)`,p2.`Fert.Rate`,p2.`Urban Pop%` from popdemograghics p1
 left join popother p2 on p1.ranks=p2.ranks) p3 order by ranks;
 
 -- deleting null values in row
DELETE FROM popdemograghics
WHERE coalesce(ranks,cca2,country,Continent,pop2022,pop2020,pop2050,pop2030,pop2015,pop2010,pop2000,pop1990,pop1980,pop1970,
area,landAreaKm,density,WorldPercentage) IS NULL;


select * from popdemograghics order by ranks  ;

UPDATE popdemograghics
SET  gr =
 (select  round(((p3.pop2022-p3.pop2021)/p3.pop2021)*100,2)  from
  (select p1.ranks,p1.country,p1.Continent,p1.pop2022,p1.pop2021,p1.landAreaKm,p1.gr, p2.`Migrants(net)`,p2.`Fert.Rate`,p2.`Urban Pop%` from popdemograghics p1  join popother p2
    on p1.ranks=p2.ranks) p3)
where gr=0;

-- calculating rural population
 
 select  ranks,round(((p3.pop2022)-((p3.pop2022)*(`Urban Pop%`/100))),2) as ruralpop,pop2022,`Urban Pop%` 
 from (select p1.ranks,p1.country,p1.Continent,p1.pop2022,p1.pop2021,p1.landAreaKm,p1.gr, p2.`Migrants(net)`,p2.`Fert.Rate`,p2.`Urban Pop%` 
 from popdemograghics p1  join popother p2
    on p1.ranks=p2.ranks) p3 group by ranks,pop2022,`Urban Pop%` order by ranks;
    
    -- using partition by function
    
    select country,Continent,pop2022, rank() over( partition by Continent order by ranks) rnk from popdemograghics;
    
     select ranks, country,Continent,pop2022,  avg(pop2022) over( partition by Continent order by continent) avg_continent_population from popdemograghics;
     
     select ranks, country,Continent,pop2022, max(pop2022) over( partition by continent order by ranks) highest_population_continentwise from popdemograghics;
      
      select ranks, country,Continent,pop2022,area, min(area) over( partition by continent order by continent) let_are_continentwise from popdemograghics;
      
      --                                               Thank you 
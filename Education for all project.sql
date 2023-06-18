/* sql queries to extract data from the 'Donation_Data' and 'Donor_Data' tables which 
will help in gaining insight for the fundraising coming up the next year. The objective is to
 increase the number of donors in the database, increase the donation frequency of the donors,
 and increase the value of donations in the database.*/
 
 --getting familiar with the data in each table
 
 select * from Donation_Data;
 
 select * from Donor_Data;
 
 --1. Getting the donation value per donor
 
select a.id, a.first_name, a.donation, b.donation_frequency, 
 	case 
    when b.donation_frequency = 'Monthly' then (a.donation*12)
    when b.donation_frequency = 'Weekly' then (a.donation*52)
    else a.donation
    end as donation_value
from Donation_Data a
join Donor_Data b
on a.id = b.id
order by donation_value desc
--to see the high value donors, we will limit the output of the above query to 20
limit 20;

--2. What donation_frequency attracts more customers?

--Checking the distinct donation frequencies available

select distinct donation_frequency
from Donor_Data;

--how many donors per donation_frequency?

select donation_frequency, count(id) as popularity
from Donor_Data
group by donation_frequency
order by popularity desc;

--3. What is the correlation between donation amount and donation frequency?

--extract data for visualization in tableau

select a.id, a.donation, b.donation_frequency
from Donation_Data a
join Donor_Data b
on a.id = b.id;

/*4.Can we identify any patterns or trends in DONATION behavior based on demographic factors 
such as gender, job field, state, and shirt size?*/

--number of donors by the above listed demographics
--gender

select gender, count(id) as number_of_donors
from Donation_Data
group by gender;

--job_field

select job_field, count(id) as number_of_donors
from Donation_Data
group by job_field
order by number_of_donors desc;

--state

select state, count(id) as number_of_donors
from Donation_Data
group by state
order by number_of_donors desc

--shirt_size

select shirt_size, count(id) as number_of_donors
from Donation_Data
group by shirt_size
order by number_of_donors desc;

--5.Common characteristics shared by high value donors.

/*as seen from the query to determine donation value, high value donors have weekly donation
frequency hence the reason donation column is multiplied by 52 in the select statement*/

select a.id, a.gender, (a.donation*52) as donation_value, b.car,
--case statement to replace null values in 'second_language' column with N_a i.e not vailable
	case 
    when b.second_language isnull then 'N_a'
    else b.second_language
    end as second_language, b.movie_genre, b.favourite_colour
from Donation_Data a
join Donor_Data b
on a.id = b.id
where b.donation_frequency = 'Weekly'
order by donation_value desc
limit 20;

select*from album; 
--  1 who is senior most emplyee based on job title?

select*from employee;

select*from employee
order by levels desc
limit 1;

-- 2 which country have most invoices
select*from invoice;
select count(*),billing_country from invoice 
group by billing_country
order by billing_country desc;

-- 3. what are top 3 values of total invoices
select max(total) from invoice
group by total
order by total desc
limit 3;

--another way for this querry 
select (total)from invoice 
order by total desc
limit 3;

-- 4..whih city has the best customers? We would like to throw a promtional Music Festival in the 
--city we made the most money. Write a querry that returns one city that has the highest sunm of 
--invoice totals. Return both the city name &sum of all invoise totals?

select*from invoice;
select sum(total) as invoice_total,billing_city from invoice
group by billing_city
order by invoice_total desc;

--5.. Who is best customer? The customer who has spent the most money will be declared as best customer
--. Write a query that returns the person who has spent te most money?
select*from customer;
select*from invoice;

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

--Moderate
-- 1. write a querry to return the email, first name, last name , & Genre of all Rock Music listeners
--Return your list ordered alphabetically by email starting with A

select*from customer;
select*from genre;

select customer.first_name,customer.last_name,customer.email
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock')
order by email;

--another way
select distinct first_name, last_name, email
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock')
order by email;

--2.. lets invite the artists who have written the most rock music in our dataset.
--Write a query that the Artist name total track down count of the top 10 rock bands?
select*from artist;

select*from genre;

select artist.name, artist.artist_id,count(artist.artist_id) as no_of_songs 
from track 
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;

--3.. Return all the track names that have a song length longer than the avergae song lenght. 
--Return the name and milliseconds for each track. Order by the song length with the longest songs 
--listed first.?

select name,milliseconds from track
where milliseconds>(
select avg(milliseconds) as average_length
from track)
order by milliseconds desc;

--Advnace 
--1.. Find how much amount spent by each customer on artists? 
--Write a query to return cutomer name, artist name and total spent

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id= invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc 
limit 1
)
select c.customer_id, c.first_name, c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--2..we want to find out the most popular music genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write that returns each country along with the top Genre. For countries where the
--maximum number of purchaeses is shared return all genres?

with popular_genre as (
select count (invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
Row_Number() over (Partition by customer.country order by count(invoice_line.quantity) desc) as rowNo
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select* from popular_genre where rowno <=1;

--3-- Write a query that determines the customer that has spent the most on music for each country. 
--Wrte a query that returns the country along with the top customer and how they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

with recursive
customer_with_country as (
select customer.customer_id, first_name, last_name,billing_country,sum(total) as total_spending
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 2,3 desc),

country_max_spending as (
select billing_country, max(total_spending) as max_spending
from customer_with_country
group by billing_country)

select cc.billing_country,cc.total_spending,cc.first_nmae,cc.last_name
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;



 














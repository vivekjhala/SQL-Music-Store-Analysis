--Question Set 1 - Easy
--1. Who is the senior most employee based on job title?
Select *
From employee
Order By levels DESC
Limit 1

--2. Which countries have the most Invoices?
Select Count(*), billing_country
From invoice
Group By billing_country
Order By Count(billing_country) DESC

--3. What are top 3 values of total invoice?
Select total
From invoice
Order By total DESC
Limit 3

/*
4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals
*/

Select Sum(total), billing_city
From invoice
Group By billing_city
Order By Sum(total) DESC

/*
5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money
*/

Select customer.customer_id, first_name, last_name, Sum(invoice.total) AS total
From customer
Join invoice
On customer.customer_id = invoice.customer_id
Group By customer.customer_id
Order By total DESC
Limit 1

--Question Set 2 – Moderate
/*
1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
*/

Select DISTINCT email, first_name, last_name
From customer
Join invoice On customer.customer_id = invoice.customer_id
Join invoice_line On invoice.invoice_id = invoice_line.invoice_id
Where track_id IN (
	Select track_id
	From track
	Join genre On track.genre_id = genre.genre_id
	Where genre.name = 'Rock'
					)
Order By email

/*
2. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
*/

Select artist.artist_id, artist.name, Count(artist.artist_id) As total_tracks
From track
Join album On track.album_id = album.album_id
Join artist On album.artist_id = artist.artist_id
Join genre On genre.genre_id = track.genre_id
Where genre.name = 'Rock'
Group By artist.artist_id
Order By total_tracks DESC
Limit 10

/*
3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first
*/

Select track.name, track.milliseconds
From track
Where milliseconds > (
	Select AVG(milliseconds)
	From track)
Order By milliseconds DESC

/*
Question Set 3 – Advance
1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/*
2. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres
*/

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/*
3. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount
*/
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
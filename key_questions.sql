

--key questions and objectives listed with associated sql query run to extract the data used in tableau:

--1a.	Which movies contributed the most to revenue gain? 

        -- table flow: payment.amount > rental.rental_id > inventory.inventory_id > film.film_id 

SELECT D.title AS highest_revenue_films,
       SUM (A.amount) AS total_revenue
FROM payment A
INNER JOIN rental B ON A.rental_id = B.rental_id
INNER JOIN inventory C ON B.inventory_id = C.inventory_id
INNER JOIN film D ON C.film_id = D.film_id
GROUP BY highest_revenue_films
ORDER BY total_revenue DESC --descending  by revenue for top ten
LIMIT 10;

        
        
--1b.	Which movies contributed the least to revenue gain?

SELECT D.title AS lowest_revenue_films,
       SUM (A.amount) AS total_revenue
FROM payment A
INNER JOIN rental B ON A.rental_id = B.rental_id
INNER JOIN inventory C ON B.inventory_id = C.inventory_id
INNER JOIN film D ON C.film_id = D.film_id
GROUP BY lowest_revenue_films
ORDER BY total_revenue --default is descending
LIMIT 10;
	 
	 

--2.	What was the average rental duration for all videos? 

SELECT A.customer_id,
       AVG (Extract (day FROM (A.return_date - A.rental_date))) AS days_rented,
       D.name AS genre, --including genre to use in tableau for additional insights 
       COUNT (C.film_id) AS count_rental_transaction
FROM rental A
INNER JOIN inventory B ON A.inventory_id = B.inventory_id
INNER JOIN film_category C ON B.film_id = C.film_id
INNER JOIN category D ON C.category_id = D.category_id
GROUP BY A.customer_id,
         genre;

"avg_days_rented" = "4.541293538"

	
--3.	Which countries are Rockbuster customers based in? 
        -- table flow: customer.address_id > address.city_id > city.country_id > country.country


        --the top ten countries for Rockbuster in terms of customer numbers. 
        -- I started by writing the SELECT statement with country inserted as a column. Then began writing the filters: GROUP BY, ORDER BY DESC, and LIMIT 10. Then, I filled in the column name for each filter as seemed logical. Having then recognized customer_id needing to be aggregated by count, I set up the rest of query designating customer as table A and country as D using the INNER JOIN syntax.
SELECT A.country_id,
       A.country,
       COUNT (D.customer_id) AS number_of_customers  	   
FROM country A
INNER JOIN city B ON A.country_id = B.country_id
INNER JOIN address C ON B.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id	   
GROUP BY A.country,
	 A.country_id
ORDER BY COUNT(D.customer_id) DESC
LIMIT 10;

        --query to list all countries with customers
SELECT country
FROM country A
INNER JOIN city B ON A.country_id = B.country_id
INNER JOIN address C on B.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id
GROUP BY country
        --output: 108 countries


        --top 20 customer locations, customer id's derived from running the top ten modified for top twenty

SELECT D.customer_id,
	 B.city,
	 A.country	
FROM country A
INNER JOIN city B ON A.country_id = B.country_id
INNER JOIN address C on B.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id
WHERE customer_id IN (148, 526, 144, 236, 178, 410, 137, 459, 469, 468, 373, 403, 181, 522, 372, 550, 470, 462, 259, 187) 



--4.	Where are customers with a high lifetime value based? 
        -- the top 10 cities within the top 10 countries identified above
 
SELECT A.city,
	   B.country,
	   COUNT(D.customer_id) AS number_of_customers
FROM city A
INNER JOIN country B ON A.country_id = B.country_id
INNER JOIN address C ON A.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id
WHERE B.country_id IN (
					SELECT A.country_id
					FROM country A
					INNER JOIN city B ON A.country_id = B.country_id
					INNER JOIN address C ON B.city_id = C.city_id
					INNER JOIN customer D ON C.address_id = D.address_id	   
					GROUP BY A.country_id					        
					ORDER BY COUNT(D.customer_id) DESC
				 	LIMIT 10)
GROUP BY B.country,
		 A.city
ORDER BY COUNT(D.customer_id) DESC
LIMIT 10;


        --top 5 customers
        -- This query was written to filter the city table using WHERE and IN to include only the output from question 1 rather than list out the country names as strings. I also wanted to display from highest to lowest customer quantity (DESC) and LIMIT 10. I checked my work by counting the total cities from the results to question 1, results showed mostly 1 customer in each city. Double checking, I ran a querry for cities with customer quantity > 1 and found only 1 city, Aurora, had more than 1 customer. 
SELECT A.customer_id,
	   A.first_name,
	   A.last_name,
	   D.country,
	   C.city,
	   SUM(E.amount) AS total_amount_paid
FROM customer A
INNER JOIN address B ON A.address_id = B.address_id
INNER JOIN city C ON B.city_id = C.city_id
INNER JOIN country D ON C.country_id = D.country_id
INNER JOIN payment E ON A.customer_id = E.customer_id
WHERE C.city IN (
				'Aurora',
				'Acua',
				'Citrus Heights',
				'Iwaki',
				'Ambattur',
				'Shanwei',
				'So Leopoldo',
				'Teboksary',
				'Tianjin',
				'Cianjur')
GROUP BY D.country,
	     C.city,
		 A.customer_id,
		 A.first_name,
	     A.last_name	    
ORDER BY SUM(E.amount) DESC
LIMIT 5;


--5.	Do sales figures vary between geographic regions?
SELECT A.country_id,
	   A.country,
	   COUNT (D.customer_id) AS number_of_customers  	   
FROM country A
INNER JOIN city B ON A.country_id = B.country_id
INNER JOIN address C ON B.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id	   
GROUP BY A.country,
		 A.country_id
ORDER BY COUNT(D.customer_id) DESC
LIMIT 10;

SELECT A.country_id,
	 A.country,
	 SUM (E.amount) AS total_revenue
FROM country A
INNER JOIN city B ON A.country_id = B.country_id
INNER JOIN address C on B.city_id = C.city_id
INNER JOIN customer D ON C.address_id = D.address_id
INNER JOIN payment E ON D.customer_id = E.customer_id
GROUP BY A.country_id,
	   A.country
ORDER BY total_revenue DESC



--data summary of film and customer tables. aggregates for each integer column or mode for text columns.

SELECT MAX(film_id) AS film_max_id, MIN(film_id) AS film_min_id, AVG(film_id) AS film_avg_id FROM film;

SELECT MODE() WITHIN GROUP (ORDER BY title) AS film_mode_title FROM film;

SELECT MODE() WITHIN GROUP (ORDER BY description) AS film_mode_description FROM film;

SELECT MAX(release_year) AS film_max_release_year, MIN(release_year) AS film_min_release_year, AVG(release_year) AS film_avg_release_year FROM film;

SELECT MAX(language_id) AS film_max_language_id, MIN(language_id) AS film_min_language_id, AVG(language_id) AS film_avg_language_id FROM film;

SELECT MAX(rental_duration) AS film_max_rental_duration, MIN(rental_duration) AS film_min_rental_duration, AVG(rental_duration) AS film_avg_rental_duration FROM film;

SELECT MAX(rental_rate) AS film_max_rental_rate, MIN(rental_rate) AS film_min_rental_rate, AVG(rental_rate) AS film_avg_rental_rate FROM film;

SELECT MAX(length) AS film_max_length, MIN(length) AS film_min_length, AVG(length) AS film_avg_length FROM film;

SELECT MAX(replacement_cost) AS film_max_replacement_cost, MIN(replacement_cost) AS film_min_replacement_cost, AVG(replacement_cost) AS film_avg_replacement_cost FROM film;

SELECT MODE() WITHIN GROUP (ORDER BY rating) AS film_mode_rating FROM film;

SELECT MAX(last_update) AS film_max_last_update, MIN(last_update) AS film_min_last_update FROM film;

SELECT MODE() WITHIN GROUP (ORDER BY special_features) AS film_mode_special_features FROM film;

SELECT MODE() WITHIN GROUP (ORDER BY fulltext) AS film_mode_fulltext FROM film;

SELECT MAX(customer_id) AS customer_max_id, MIN(customer_id) AS customer_min_id, AVG(customer_id) AS customer_avg_id FROM customer;

SELECT MODE() WITHIN GROUP (ORDER BY store_id) AS customer_mode_store_id FROM customer;

SELECT MAX(store_id) AS customer_max_store_id, MIN(store_id) AS customer_min_store_id, AVG(store_id) AS customer_avg_store_id FROM customer;

SELECT MODE() WITHIN GROUP (ORDER BY first_name) AS customer_mode_first_name FROM customer;

SELECT MODE() WITHIN GROUP (ORDER BY last_name) AS customer_mode_last_name FROM customer;

SELECT MODE() WITHIN GROUP (ORDER BY email) AS customer_mode_email FROM customer;

SELECT MAX(address_id) AS customer_max_address_id, MIN(address_id) AS customer_min_address_id, AVG(address_id) AS customer_avg_address_id FROM customer;

SELECT MODE() WITHIN GROUP (ORDER BY activebool) AS customer_mode_activebool FROM customer;

SELECT MAX(last_update) AS customer_max_last_update, MIN(last_update) AS customer_min_last_update FROM customer;

SELECT MAX(active) AS customer_max_active, MIN(active) AS customer_min_active, AVG(active) AS customer_avg_active FROM customer;











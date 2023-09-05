-- Segment 1: Database - Tables, Columns, Relationships
-- Q1) What are the different tables in the database and how are they connected to each other in the database?
/* ANS) There are 6 tables movies, genre, director_mapping, role_mapping, names, ratings.
All of them are connected with either Primary keys or Composite keys for example 
movies table is connected with genre, ratings, role_mapping and director mapping with primary
key as id. 
The names table is connected with role_mapping and director_mapping with id. */

-- Q2) Find the total number of rows in each table of the schema.

SELECT COUNT(*) FROM director_mapping;
-- Number of rows in director_mapping = 3867

SELECT COUNT(*) FROM genre;
-- Number of rows in genre = 14662

SELECT COUNT(*) FROM movie;
-- Number of rows in movie = 7997

SELECT COUNT(*) FROM names;
-- Number of rows in names = 25735

SELECT COUNT(*) FROM ratings;
-- Number of rows in ratings = 7997

SELECT COUNT(*) FROM role_mapping;
-- Number of rows in role_mapping = 15615

-- Q3) Identify which columns in the movie table have null values.

SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS NULL_ID,
    Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS NULL_title,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS NULL_year,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS NULL_date_published,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS NULL_duration,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS NULL_country,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS NULL_worlwide_gross_income,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS NULL_languages,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS NULL_production_company
FROM   movie; 
/* Country has 20, worlwide_gross_income has 3724,
   languages has 194 and production_company has 528 NULL values rest other columns do not
   have null values */
   
-- Segment 2: Movie Release Trends
-- Q4) Determine the total number of movies released each year and analyse the month-wise trend.

SELECT 
    year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year;

-- 2017 - 3052 movies, 2018 - 2944 movies, 2019 - 2001 movies.

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(*) AS num_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;

/* 'Month'- 'Number of movies' = '1'-'804' ,'2'-'640','3'-'824','4'-'680','5'-'625',
'6'-'580','7'-'493','8'-'678','9'-'809','10'-'801','11'-'625','12'-'438'

Highest number of movies were released in 2017
Highest number of movies were released in the March month. This is yearwise and monthwise
trend */

-- Q5) Calculate the number of movies produced in the USA or India in the year 2019.
SELECT 
    COUNT(DISTINCT id) AS number_of_movies, year
FROM
    movie
WHERE(country LIKE '%USA%'
        OR country LIKE '%India%')
        AND year = 2019;
-- 1059 movies were produced in the USA or India in the year 2019

-- Segment 3: Production Statistics and Genre Analysis

-- Q6) Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT genre
from genre;

-- There are 13 genre including others 

-- Q7) Identify the genre with the highest number of movies produced overall.

SELECT 
    genre, COUNT(m.id) AS number_of_movies
FROM
    movie AS M
INNER JOIN genre AS g ON m.id = g.movie_id
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;

-- Drama genre has the highest number of movie i.e 4285

-- Q8) Determine the count of movies that belong to only one genre.

SELECT COUNT(*) AS movies_belongs_to_one_genre
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(DISTINCT genre) = 1
) AS movies_belongs_to_one_genre;

/* FINDINGS */
-- 3289 movies belong to only one genre

-- Q9) Calculate the average duration of movies in each genre.

SELECT genre, AVG(m.duration) AS avg_duration_each_genre
FROM movie AS m
INNER JOIN genre AS g ON m.id=g.movie_id
GROUP BY genre
ORDER BY avg_duration_each_genre DESC;

/* FINDINGS */
/* TOP 3 genre are Action with avg_duration of 112.88, Romance with avg_duration of 109.53 and
Crime with avg_duration of 107.05 */


-- Q10) Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.

WITH genre_overview 
AS (SELECT genre, COUNT(movie_id) as number_of_movies,
    RANK() OVER(ORDER BY COUNT(movie_id) DESC) as genre_rank
    FROM genre
    GROUP BY genre)
SELECT * FROM genre_overview
WHERE genre = "THRILLER";

/* FINDINGS */
-- Genre Thriller has rank = 3 with number of movies = 1484


-- Segment 4: Ratings Analysis and Crew Members

-- Q 11) Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings; 

-- Q 12) Identify the top 10 movies based on average rating.

SELECT title, avg_rating,
       ROW_NUMBER() OVER(ORDER BY (avg_rating) DESC) AS movie_rank
FROM ratings AS r 
INNER JOIN movie AS m on r.movie_id=m.id
ORDER BY movie_rank
LIMIT 10;

/* FINDINGS */
/* TOP 3 
1 Movie - Kirket With avg_rating of 10,  
2 Movie - Love in Kilnerry With avg_rating of 10,
3 Movie - Gini Helida Kathe With avg_rating of 9.8 */

-- Q13) Summarise the ratings table based on movie counts by median ratings.

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings 
GROUP BY median_rating
ORDER BY movie_count;

/* FINDINGS */
/* Median Rating 1 has 94 movies, Median Rating 2 has 119 movies,
Median Rating 3 has 283 movies also Median Rating 7 has highest movies count i.e 2257 */

-- Q14)Identify the production house that has produced the most number of hit movies (average rating > 8).

WITH production_house_overview
AS (SELECT production_company, COUNT(movie_id) AS number_of_movies,
    RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS prod_company_rank
    FROM ratings AS r 
    INNER JOIN movie AS m ON m.id = r.movie_id
    WHERE avg_rating > 8 AND production_company IS NOT NULL
    GROUP BY production_company)
SELECT *
FROM   production_house_overview
WHERE  prod_company_rank = 1; 

/* FINDINGS */
/* production_house Dream Warrior Pictures, National Theatre Live has 
most number of hit movies i.e 3 */

-- Q15) Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
SELECT genre, COUNT(id) AS number_of_movies
FROM movie as m
INNER JOIN genre as g on m.id=g.movie_id
INNER JOIN ratings as r on m.id=r.movie_id
WHERE year = 2017
AND MONTH(date_published) = 3 AND country LIKE '%USA%' AND total_votes>1000
GROUP BY genre
ORDER BY number_of_movies DESC;

/* FINDINGS */
/* TOP 3 Genres with total votes more than 1000 during March 2017 in USA
DRAMA - 24 movies, Comedy - 9 movies, Action - 8 movies and also Thriller - 8 movies. */

-- Q16)Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

WITH RankedMovies 
AS (SELECT genre,title,avg_rating,
	ROW_NUMBER() OVER (PARTITION BY title ) AS rank_movie
    FROM
        genre AS G
        INNER JOIN movie AS M ON G.movie_id = M.id
        INNER JOIN ratings AS R ON R.movie_id = M.id
    WHERE title LIKE 'The%' AND avg_rating > 8)
SELECT genre,title,avg_rating
FROM RankedMovies
WHERE rank_movie = 1
ORDER BY avg_rating DESC;

/* FINDINGS */
/* There are total 8 movies whose title starts with THE
The Brighton Miracle is the highest rated movie whose title starts with THE also there 
are 5 Drama genre movie out of 8.  */

-- Segment 5: Crew Analysis
-- Q17) Identify the columns in the names table that have null values.

-- Individual null count of each column 

SELECT COUNT(*) AS null_name
FROM names
WHERE name IS Null;

/* FINDINGS */
/* name column has 0 null values */

SELECT COUNT(*) AS null_height
FROM names
WHERE height IS Null;

/* FINDINGS */
/* height column has 17335 null values */

SELECT COUNT(*) AS null_date
FROM names
WHERE date_of_birth IS Null;

/* FINDINGS */
/* date_of_birth column has 13431 null values */

SELECT COUNT(*) AS null_known
FROM names
WHERE known_for_movies IS Null;

/* FINDINGS */
/*known_for_movies column has 15226 null values */

-- Q18) Determine the top three directors in the top three genres with movies having an average rating > 8.
WITH topgenres 
AS (SELECT genre, COUNT(id) AS number_of_movies,
	RANK() OVER (ORDER BY COUNT(id) DESC) AS genre_rank
    FROM movie AS m
	INNER JOIN genre AS g ON m.id = g.movie_id 
	INNER JOIN ratings AS r ON m.id = r.movie_id
    WHERE avg_rating > 8
    GROUP BY genre
    LIMIT 3)
SELECT name AS director_name, COUNT(d.movie_id) AS number_of_movies
FROM director_mapping AS d
INNER JOIN genre AS g 
USING (movie_id)
INNER JOIN names AS n
ON         n.id = d.name_id
INNER JOIN topgenres 
using     (genre)
INNER JOIN ratings
using      (movie_id)
WHERE      avg_rating > 8
GROUP BY   director_name
ORDER BY   number_of_movies DESC limit 3 ;

/* FINDINGS */
/* The top three directors in the top three genres whose movies have an average rating > 8
are James Mangold , Joe Russo and Anthony Russo  */

-- Q19)Find the top two actors whose movies have a median rating >= 8.

SELECT n.name AS actor_name, COUNT(rm.movie_id) AS number_of_movies
FROM role_mapping AS rm
INNER JOIN movie AS m ON m.id=rm.movie_id
INNER JOIN ratings AS r ON r.movie_id = rm.movie_id
INNER JOIN names AS n on n.id = rm.name_id
WHERE r.median_rating >= 8 AND category = 'Actor'
GROUP BY actor_name
ORDER BY number_of_movies DESC
LIMIT 2;

/* FINDINGS */
-- Top 2 actors are Mammootty and Mohanlal.

-- Q20)Identify the top three production houses based on the number of votes received by their movies.

SELECT production_company,Sum(total_votes) AS vote_count,
	   Rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r ON r.movie_id = m.id
GROUP BY production_company limit 3;

/* FINDINGS */
-- Marvel Studios, Twentieth Century Fox and Warner Bros are top 3 production houses based on the votes

-- Q21)Rank actors based on their average ratings in Indian movies released in India.

WITH actor_summary AS (
    SELECT
        N.NAME AS actor_name,
        COUNT(DISTINCT M.id) AS movie_count,
        ROUND(SUM(R.avg_rating * R.total_votes) / SUM(R.total_votes), 2) AS actor_avg_rating
    FROM
        movie AS M
    INNER JOIN role_mapping AS RM ON M.id = RM.movie_id
    INNER JOIN names AS N ON RM.name_id = N.id
    INNER JOIN (
        SELECT
            R.movie_id,
            R.avg_rating,
            R.total_votes
        FROM
            ratings AS R
    ) AS R ON M.id = R.movie_id
    WHERE
        category = 'ACTOR'
        AND country = 'india'
    GROUP BY
        actor_name
    HAVING
        movie_count >= 5
)

SELECT
    actor_name,
    movie_count,
    actor_avg_rating,
    RANK() OVER (ORDER BY actor_avg_rating DESC) AS actor_rank
FROM
    actor_summary;

/* FINDINGS */
/* TOP 3 Actors are 1st Vijay Sethupathi, 2nd Fahadh Faasil, 3rd Yogi Babu
based on their average ratings in Indian movies released in India */

-- Q22)Identify the top five actresses in Hindi movies released in India based on their average ratings.

WITH actress_summary AS (
    SELECT
        n.NAME AS actress_name,
        COUNT(r.movie_id) AS movie_count,
        ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actress_avg_rating
    FROM
        movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
    INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
    INNER JOIN names AS n ON rm.name_id = n.id
    WHERE
        category = 'ACTRESS'
        AND country = 'INDIA'
        AND languages LIKE '%HINDI%'
    GROUP BY
        actress_name
    HAVING
        movie_count >= 3
)

SELECT
    *,
    RANK() OVER (ORDER BY actress_avg_rating DESC) AS actress_rank
FROM
    actress_summary
LIMIT 5;

/* FINDINGS */
/* Top five actresses in Hindi movies released in India based on their average ratings 
are Taapsee Pannu, Kriti Sanon, Divya Dutta, Shraddha Kapoor, Kriti Kharbanda */

-- Segment 6: Broader Understanding of Data
-- Q23)Classify thriller movies based on average ratings into different categories.

WITH thriller_movies
     AS (SELECT DISTINCT title,
                         avg_rating
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
                INNER JOIN genre AS g using(movie_id)
         WHERE  genre LIKE 'THRILLER')
SELECT *,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit-movie'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit-movie'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movie'
         ELSE 'Flop movie'
       END AS avg_rating_category
FROM   thriller_movies
ORDER BY avg_rating DESC; 

/* FINDINGS */
/* Movie - Safe has 9.5 avg_rating which is the highest and Roofied has 1.1 avg_rating which is the lowest */

-- Q23) Analyse the genre-wise running total and moving average of the average movie duration.
SELECT
    genre,
    ROUND(AVG(duration), 2) AS avg_duration,
    SUM(ROUND(AVG(duration), 2)) OVER (ORDER BY genre) AS running_total_duration,
    AVG(ROUND(AVG(duration), 2)) OVER (ORDER BY genre ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM
    (SELECT g.genre, m.duration
     FROM movie AS m
     INNER JOIN genre AS g ON m.id = g.movie_id) AS subquery
GROUP BY
    genre
ORDER BY
    genre;

/* FINDINGS */
/* Action tops the list and Thriller is the lowest */

-- Q24) Identify the five highest-grossing movies of each year that belong to the top three genres.
WITH GenreCounts AS (
    SELECT
        g.genre,
        COUNT(m.id) AS movie_count
    FROM
        movie AS m
    INNER JOIN
        genre AS g ON m.id = g.movie_id
    INNER JOIN
        ratings AS r ON r.movie_id = m.id
    WHERE
        r.avg_rating > 8
    GROUP BY
        g.genre
    ORDER BY
        COUNT(m.id) DESC
    LIMIT 3
),
RankedMovies AS (
    SELECT
        g.genre,
        m.year,
        m.title AS movie_name,
        CAST(COALESCE(REPLACE(REPLACE(worlwide_gross_income, 'INR', ''), '$', ''), '0') AS DECIMAL(10)) AS worlwide_gross_income,
        DENSE_RANK() OVER (PARTITION BY m.year, g.genre ORDER BY CAST(COALESCE(REPLACE(REPLACE(worlwide_gross_income, 'INR', ''), '$', ''), '0') AS DECIMAL(10)) DESC) AS movie_rank
    FROM
        movie AS m
    INNER JOIN
        genre AS g ON m.id = g.movie_id
    WHERE
        g.genre IN (SELECT genre FROM GenreCounts)
)
SELECT *
FROM RankedMovies
WHERE movie_rank <= 5
ORDER BY year;

-- Q24)Determine the top two production houses that have produced the highest number of hits among multilingual movies.

WITH production_company_summary
     AS (SELECT production_company,
                Count(*) AS movie_count
         FROM   movie AS m
                inner join ratings AS r
                        ON m.id = r.movie_id
         WHERE  median_rating >= 8
                AND production_company IS NOT NULL
                AND Position(',' IN languages) > 0
         GROUP  BY production_company
         ORDER  BY movie_count DESC)
SELECT *,
       Rank()
         over(
           ORDER BY movie_count DESC) AS prod_comp_rank
FROM   production_company_summary
LIMIT 2;

/* FINDINGS */
/* Star Cinema has 7 movies and Twentieth Century Fox has 4 movies. */

-- Q25)Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

SELECT
    actress_name,
    total_votes,
    movie_count,
    actress_avg_rating,
    RANK() OVER (ORDER BY movie_count DESC) AS actress_rank
FROM
    (
        SELECT
            n.NAME AS actress_name,
            SUM(total_votes) AS total_votes,
            COUNT(r.movie_id) AS movie_count,
            ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating
        FROM
            movie AS m
        INNER JOIN
            ratings AS r ON m.id = r.movie_id
        INNER JOIN
            role_mapping AS rm ON m.id = rm.movie_id
        INNER JOIN
            names AS n ON rm.name_id = n.id
        INNER JOIN
            genre AS g ON g.movie_id = m.id
        WHERE
            category = 'ACTRESS'
            AND avg_rating > 8
            AND genre = 'Drama'
        GROUP BY
            NAME
    ) AS actress_summary
ORDER BY
    actress_rank
LIMIT 3;

-- Top 3 actresses based on number of Super Hit movies are Parvathy Thiruvothu, Susan Brown and Amanda Lawrence

-- Q26)Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

WITH directors_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   directors_summary )
SELECT   name_id AS director_id,
         NAME AS director_name,
         Count(movie_id) AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)AS avg_rating,
         Sum(total_votes) AS total_votes,
         Min(avg_rating) AS min_rating,
         Max(avg_rating) AS max_rating,
         Sum(duration) AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;

/* FINDINGS */
/* Andrew Jones tops the list. */

-- Q27) Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
/* ANS) Drama is the most popular genre with 4285 number of movies and average duration of 106.77 minutes. 
A total of 1078 drama movies were produced in 2019. Bolly movies can focus on Drama genre 
for its future film. Action and thriller genres can also be explored as they belong to the top three genres.
Based on total votes and average rating of 8.42 for movies released in India, 
Vijay Sethupathi can be added to the cast woo Indian audience for the upcoming project.
Based on total votes and average rating of 7.74 received for Hindi movies 
released in India, Taapsee Pannu can be chosen as the actress. */
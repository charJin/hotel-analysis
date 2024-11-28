-- What is the Total Revenue Contribution by RFM Segment?
SELECT
    c.segment AS segment,
    SUM(r.total_revenue) AS total_revenue,
    ROUND(SUM(r.total_revenue) * 100.0 /
        (SELECT SUM(total_revenue) FROM revenue), 2) AS percentage_contribution
FROM
    customers c
JOIN
    revenue r
ON
    c.id = r.customer_id
WHERE
    c.segment IS NOT NULL AND r.total_revenue IS NOT NULL
GROUP BY
    c.segment
ORDER BY
    total_revenue DESC;


-- Identify the most popular preferences for each RFM segment

SELECT 
    c.segment AS segment,
    'sr_king_size_bed' AS preference,
    ROUND(AVG(CAST(p.sr_king_bed AS integer)) * 100, 2) AS preference_rate
FROM 
    preferences p
JOIN 
    customers c ON p.customer_id = c.id
GROUP BY 
    c.segment
UNION ALL
SELECT 
    c.segment,
    'sr_twin_bed',
    ROUND(AVG(CAST(p.sr_twin_bed AS integer)) * 100, 2)
FROM 
    preferences p
JOIN 
    customers c ON p.customer_id = c.id
GROUP BY 
    c.segment
UNION ALL
SELECT 
    c.segment,
    'sr_quiet_room',
    ROUND(AVG(CAST(p.sr_quiet_room AS integer)) * 100, 2)
FROM 
    preferences p
JOIN 
    customers c ON p.customer_id = c.id
GROUP BY 
    c.segment
ORDER BY 
    segment, preference_rate DESC;

-- Which RFM Segment customers requests the  most preferences?
SELECT 
    c.segment,
    COUNT(c.id) AS total_customers,
    SUM(CASE WHEN p.sr_high_floor THEN 1 ELSE 0 END +
        CASE WHEN p.sr_low_floor THEN 1 ELSE 0 END +
        CASE WHEN p.sr_accessible_room THEN 1 ELSE 0 END +
        CASE WHEN p.sr_medium_floor THEN 1 ELSE 0 END +
        CASE WHEN p.sr_bath_tub THEN 1 ELSE 0 END +
        CASE WHEN p.sr_shower THEN 1 ELSE 0 END +
        CASE WHEN p.sr_crib THEN 1 ELSE 0 END +
        CASE WHEN p.sr_king_bed THEN 1 ELSE 0 END +
        CASE WHEN p.sr_twin_bed THEN 1 ELSE 0 END +
        CASE WHEN p.sr_near_elevator THEN 1 ELSE 0 END +
        CASE WHEN p.sr_away_from_elevator THEN 1 ELSE 0 END +
        CASE WHEN p.sr_no_alcohol_in_mini_bar THEN 1 ELSE 0 END +
        CASE WHEN p.sr_quiet_room THEN 1 ELSE 0 END) AS total_preferences,
    ROUND(
        AVG(
            CASE WHEN p.sr_high_floor THEN 1 ELSE 0 END +
            CASE WHEN p.sr_low_floor THEN 1 ELSE 0 END +
            CASE WHEN p.sr_accessible_room THEN 1 ELSE 0 END +
            CASE WHEN p.sr_medium_floor THEN 1 ELSE 0 END +
            CASE WHEN p.sr_bath_tub THEN 1 ELSE 0 END +
            CASE WHEN p.sr_shower THEN 1 ELSE 0 END +
            CASE WHEN p.sr_crib THEN 1 ELSE 0 END +
            CASE WHEN p.sr_king_bed THEN 1 ELSE 0 END +
            CASE WHEN p.sr_twin_bed THEN 1 ELSE 0 END +
            CASE WHEN p.sr_near_elevator THEN 1 ELSE 0 END +
            CASE WHEN p.sr_away_from_elevator THEN 1 ELSE 0 END +
            CASE WHEN p.sr_no_alcohol_in_mini_bar THEN 1 ELSE 0 END +
            CASE WHEN p.sr_quiet_room THEN 1 ELSE 0 END
        ), 2
    ) AS avg_preferences_per_booking
FROM 
    customers c
JOIN 
    preferences p ON c.id = p.customer_id
GROUP BY 
    c.segment
ORDER BY 
    avg_preferences_per_booking DESC;




-- What are the patterns in cancellations and no-shows
SELECT
    c.segment AS segment,
    ROUND(SUM(b.bookings_canceled) * 100.0 / COUNT(b.customer_id), 2) AS cancellation_rate,
    ROUND(SUM(b.bookings_no_showed) * 100.0 / COUNT(b.customer_id), 2) AS no_show_rate
FROM
    bookings b
JOIN
    customers c
ON
    b.customer_id = c.id
WHERE
	c.segment IS NOT NULL
GROUP BY
    c.segment
ORDER BY
    cancellation_rate DESC;


-- What is the distribution of Market Segment
SELECT
    market_segment,
    COUNT(id) AS customer_count,
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY market_segment
ORDER BY customer_count DESC;

-- What is the distribution of Distribution Channel
SELECT
    distribution_channel,
    COUNT(id) AS customer_count,
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY distribution_channel
ORDER BY customer_count DESC;

-- What is the revenue by market segment?
SELECT
    c.market_segment,
    ROUND(SUM(r.total_revenue), 2) AS total_revenue,
    ROUND(SUM(r.total_revenue) * 100.0 / (SELECT SUM(total_revenue) FROM revenue), 2) AS percentage_contribution
FROM
    customers c
JOIN
    revenue r
ON
    c.id = r.customer_id
GROUP BY
    c.market_segment
ORDER BY
    total_revenue DESC;

-- Which RFM and market segments contribute the most to revenue?
-- How does this revenue split between lodging and other services?
SELECT
    c.segment AS rfm_segment,
    c.market_segment,
    ROUND(SUM(r.total_revenue), 2) AS total_revenue,
    ROUND(SUM(r.lodging_revenue), 2) AS lodging_revenue,
    ROUND(SUM(r.other_revenue), 2) AS other_revenue,
    COUNT(c.id) AS customer_count,
    ROUND(SUM(r.total_revenue) * 100.0 / (SELECT SUM(total_revenue) FROM revenue), 2) AS revenue_percentage
FROM
    customers c
JOIN
    revenue r
ON
    c.id = r.customer_id
GROUP BY
    c.segment, c.market_segment
ORDER BY
    total_revenue DESC;

-- How does the revenue and booking volume compare between direct and indirect channels?
SELECT
    b.distribution_channel,
    COUNT(b.customer_id) AS booking_count,
    SUM(r.total_revenue) AS total_revenue,
    ROUND(AVG(r.total_revenue), 2) AS avg_revenue_per_booking,
	ROUND(AVG(r.lodging_revenue), 2) AS lodging_revenue,
    ROUND(AVG(r.other_revenue), 2) AS other_revenue
FROM
    bookings b
JOIN
    revenue r ON b.customer_id = r.customer_id
GROUP BY
    b.distribution_channel
ORDER BY
    total_revenue DESC;

-- Average person_nights and room_nights for each RFM segment

SELECT 
    c.segment AS rfm_segment,
    COUNT(b.customer_id) AS total_bookings,
    ROUND(AVG(b.persons_nights), 2) AS avg_persons_nights,
    ROUND(AVG(b.room_nights), 2) AS avg_room_nights,
    SUM(b.persons_nights) AS total_persons_nights,
    SUM(b.room_nights) AS total_room_nights
FROM 
    customers c
JOIN 
    bookings b ON c.id = b.customer_id
GROUP BY 
    c.segment
ORDER BY 
    avg_persons_nights DESC;

-- Calculate Average Revenue per Booking by Channel
SELECT
    c.segment AS rfm_segment,
    b.distribution_channel,
    ROUND(SUM(r.total_revenue), 2) AS total_revenue,
    COUNT(b.customer_id) AS total_bookings,
    ROUND(SUM(r.total_revenue) / COUNT(b.customer_id), 2) AS avg_revenue_per_booking,
	ROUND(SUM(r.lodging_revenue) / COUNT(b.customer_id), 2) AS avg_lodging_revenue_per_booking,
	ROUND(SUM(r.other_revenue) / COUNT(b.customer_id), 2) AS avg_other_revenue_per_booking
FROM
    customers c
JOIN
    bookings b
ON
    c.id = b.customer_id
JOIN
    revenue r
ON
    c.id = r.customer_id
GROUP BY
    c.segment, b.distribution_channel
ORDER BY
    avg_revenue_per_booking DESC;



-- AVIATION
-- Analyze 'bookings_checked_in', 'days_since_last_stay', and 'days_since_first_stay' for 'Aviation'

SELECT 
    b.customer_id,
    b.bookings_checked_in,
    c.days_since_last_day,
    c.days_since_first_stay
FROM 
    customers c
JOIN 
    bookings b
ON 
    c.id = b.customer_id
WHERE 
    c.market_segment = 'Aviation'
ORDER BY 
    c.days_since_first_stay;

-- total revenue for 'Aviation'

SELECT 
    r.total_revenue AS total_revenue,
    r.other_revenue AS other_revenue,
    r.lodging_revenue AS lodging_revenue
FROM 
    revenue r
JOIN 
    customers c
ON 
    r.customer_id = c.id
WHERE 
    c.market_segment = 'Aviation'
ORDER BY
	total_revenue DESC;

-- Revenue distribution amongs the top 10 nationalities (by revenue)
WITH RevenueByCountry AS (
    SELECT 
        c.nationality,
        SUM(r.other_revenue) AS other_revenue,
        SUM(r.lodging_revenue) AS lodging_revenue,
        SUM(r.total_revenue) AS total_revenue
    FROM 
        customers c
    JOIN 
        revenue r ON c.id = r.customer_id
    GROUP BY 
        c.nationality
    ORDER BY 
        SUM(r.total_revenue) DESC
    LIMIT 10
)
SELECT 
    nationality,
    other_revenue,
    lodging_revenue,
    total_revenue,
    ROUND((other_revenue / total_revenue) * 100, 2) AS other_revenue_percentage
FROM 
    RevenueByCountry
ORDER BY 
    total_revenue DESC;


-- what is the average revenue for each age category?

SELECT 
    CASE
        WHEN age < 18 THEN 'Minor (under age)'
        WHEN age BETWEEN 18 AND 24 THEN 'Young Adult (18–24)'
        WHEN age BETWEEN 25 AND 34 THEN 'Early Career (25–34)'
        WHEN age BETWEEN 35 AND 49 THEN 'Mid Career (35–49)'
        WHEN age BETWEEN 50 AND 64 THEN 'Pre-Retirement (50–64)'
        WHEN age >= 65 THEN 'Retired (65+)'
		ELSE 'Unknown'
    END AS age_category,
    ROUND(AVG(r.lodging_revenue), 2) AS avg_lodging_revenue,
    ROUND(AVG(r.other_revenue), 2) AS avg_other_revenue,
	ROUND(AVG(r.total_revenue), 2) AS avg_total_revenue
FROM 
    customers c
JOIN 
    revenue r ON c.id = r.customer_id
GROUP BY 
    age_category
ORDER BY 
    avg_total_revenue DESC;

-- What is the maket segment distribution for customers with empty or incorrect age?

SELECT 
    c.market_segment,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM 
    customers c
WHERE 
    c.age IS NULL
GROUP BY 
    c.market_segment
ORDER BY 
    count DESC;
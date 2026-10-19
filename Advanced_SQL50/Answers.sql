-- 175

SELECT 
    a.firstName, 
    a.lastName,
    b.city,
    b.state
FROM Person a 
LEFT JOIN Address b ON a.personID = b.personID;

--182
SELECT 
    email AS Email
FROM Person 
GROUP BY email
WHERE COUNT(email) > 1;

-- 183
SELECT DISTINCT
    name 
FROM Customers 
WHERE id NOT IN (SELECT id FROM Orders);

-- 184
WITH stats AS (
    SELECT 
        id,
        name,
        salary,
        DENSE_RANK() OVER (PARTITION BY departmentID ORDER BY salary DESC) AS rnk
    FROM Employee 
    LEFT JOIN Department 
    ON a.departmentID = b.departmentID
)
SELECT 
    b.name AS Department,
    a.name AS Employee,
    a.salary AS Salary
FROM stats a 
JOIN Department b ON a.departmentID = b.departmentID
WHERE a.rnk = 1;

-- 586
SELECT 
    customer_number
FROM Orders 
GROUP BY customer_number
ORDER BY COUNT(order_number) DESC
LIMIT 1;

-- 603
SELECT 
    a.seat_id
FROM Cinema a 
JOIN Cinema b ON ABS(b.seat_id - a.seat_id) = 1
WHERE a.free = 1 AND b.free = 1
ORDER BY a.seat_id;

--607
SELECT 
    name 
FROM SalesPerson 
WHERE sales_id NOT IN (
    SELECT b.sales_id
    FROM Orders b 
    JOIN Company c ON b.com_id = c.com_id 
    WHERE c.name = 'RED'
);

-- 608
SELECT 
    id, 
    CASE 
        WHEN p_id IS NULL THEN 'Root'
        WHEN p_id IN (SELECT p_id FROM Tree) THEN 'Inner'
        ELSE 'Leaf' 
    END AS type 
FROM Tree;

-- 613 
WITH stats AS (
    SELECT 
        x, 
        LAG(x) OVER (ORDER BY x) AS prev_x
    FROM Point
)
SELECT MIN(x - prev_x) AS shortest 
FROM stats;

-- 1136 
SELECT 
    actor_id, 
    director_id 
FROM ActorDirector 
GROUP BY actor_id, director_id 
HAVING COUNT(timestamp) >= 3;

-- 1163
WITH stats AS (
    SELECT 
        a.project_id,
        a.employee_id,
        b.experience_years,
        DENSE_RANK() OVER (PARTITION BY a.project_id ORDER BY b.experience_years DESC) AS rnk
    FROM Project a
    JOIN Employee b ON a.employee_id = b.employee_id
)
SELECT 
    project_id,
    employee_id 
FROM stats 
WHERE rnk = 1;

-- 1179
SELECT 
    player_id,
    event_date AS first_login
FROM (
    SELECT 
        player_id,
        event_date,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date) AS rnk
    FROM Activity
) AS t
WHERE rnk = 1;

--1180
SELECT 
    player_id,
    device_id
FROM (
    SELECT 
        player_id,
        device_id,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date) AS rnk
    FROM Activity
) AS t
WHERE rnk = 1;
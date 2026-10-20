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

-- 1181
SELECT 
    player_id,
    event_date,
    SUM(games_played) OVER (PARTITION BY player_id ORDER BY event_date) AS games_played_so_far
FROM Activity;

-- 1214
WITH stats AS (
    SELECT 
        student_id,
        course_id,
        grade,
        RANK() OVER (PARTITION BY student_id ORDER BY grade DESC, course_id) AS rnk
    FROM Enrollments
)
SELECT 
    student_id,
    course_id,
    grade
FROM stats 
WHERE rnk = 1;

-- 1291 
SELECT 
    ROUND(SUM(CASE WHEN customer_pref_delivery_date = order_date THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS immediate_percentage
FROM Delivery;

--1212
SELECT 
    a.team_id,
    a.team_name,
    COALESCE(SUM(
        CASE 
            WHEN a.team_id = b.host_team AND b.host_goals > b.guest_goals THEN 3 
            WHEN a.team_id = b.gust_team AND b.guest_goals > b.host_goals THEN 3
            WHEN b.host_goals = b.guest_goals THEN 1 
            ELSE 0 
        END), 0) AS num_points 
FROM Teams a 
LEFT JOIN Matches b 
ON a.team_id = b.host_team OR a.team_id = b.guest_team
GROUP BY a.team_id, a.team_name
ORDER BY num_points DESC, a.team_id;

-- 1225
WITH combined AS (
    SELECT fail_date AS date, 'failed' AS period_state FROM Failed 
    WHERE fail_date BETWEEN '2019-01-01' AND '2019-12-31'

    UNION ALL 

    SELECT success_date AS date, 'succeeded' AS period_state FROM Succeeded
    WHERE sucess_date BETWEEN '2019-01-01' AND '2019-12-31'
),
ranked AS (
    SELECT
        date, 
        period_state,
        ROW_NUMBER() OVER (ORDER BY date) - ROW_NUMBER() OVER (PARTITION BY period_state ORDER BY date) AS group_id
    FROM combined 
)
SELECT 
    period_state, 
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM ranked 
GROUP BY period_state, group_id
ORDER BY start_date;

-- 1399
SELECT DISTINCT 
    page_id AS recommended_page 
FROM Likes 
WHERE user_id IN (
    SELECT 
        CASE WHEN user1_id = 1 THEN user2_id 
        ELSE user1_id
        END
    FROM Friendship 
    WHERE user1_id = 1 OR user2_id = 1
)
AND page_id NOT IN (
    SELECT page_id 
    FROM Likes 
    WHERE user_id = 1
);

-- 1405 / 1270
SELECT employee_id FROM Employees WHERE manager_id = 1 AND employee_id <> 1

UNION 

SELECT a.employee_id FROM Employees a JOIN Employees b ON a.manager_id = b.employee_id WHERE b.manager_id = 1

UNION 

SELECT a.employee_id FROM Employees a JOIN Employees b ON a.manager_id = b.employee_id JOIN Employees c ON b.manager_id = c.employee_id WHERE c.manager_id = 1;

-- 1420
WITH stats AS (
    SELECT 
        log_id, 
        log_id - ROW_NUMBER() OVER (ORDER BY log_id) AS group_id 
    FROM Logs 
)
SELECT 
    MIN(log_id) AS start_id, 
    MAX(log_id) AS end_id
    FROM stats 
    GROUP BY group_id 
    ORDER BY start_id;

-- 1438
SELECT 
    employee_id, 
    COUNT(*) OVER (PARTITION BY team_id) AS team_size
FROM Employee;

-- 1481
SELECT 
    a.id,
    a.name
FROM Students a 
LEFT JOIN Departments b 
ON a.department_id = b.id 
WHERE b.id IS NULL;

-- 1536
SELECT 
    a.customer_id, 
    a.customer_name 
FROM Customers a 
JOIN Orders b 
ON a.customer_id = b.customer_id 
GROUP BY a.customer_id, a.customer_name 
HAVING SUM(b.product_name = 'A') > 0
AND SUM(b.product_name = 'B') > 0
AND SUM(b.product_name = 'C') = 0
ORDER BY a.customer_id;

-- 1541
SELECT 
    a.name,
    COALESCE(SUM(b.distance) ,0) AS travelled_distance
FROM Users a 
LEFT JOIN Rides b ON a.id = b.user_id 
GROUP BY a.id 
ORDER BY travelled_distance DESC, a.name;

-- 1546
WITH stats AS (
    SELECT 
        student_id,
        exam_id,
        score,
        RANK() OVER (PARTITION BY exam_id ORDER BY score) AS rnk_low,
        RANK() OVER (PARTITION BY exam_id ORDER BY score DESC) AS rnk_high
    FROM Exam 
)
SELECT 
    student_id,
    student_name 
FROM Student a
WHERE student_id IN (SELECT student_id FROM Exam)
AND student_id NOT IN (SELECT DISTINCT student_id FROM stats WHERE rnk_low = 1 OR rnk_high = 1)
ORDER BY student_id; 

-- 1565
SELECT 
    a.left_operand,
    a.operator,
    a.right_operand,
    CASE 
        WHEN a.operator = '<' AND b.value < c.value THEN 'true'
        WHEN a.operator = '=' AND b.value = c.value THEN 'true'
        WHEN a.operator = '>' AND b.value > c.value THEN 'true'
    ELSE 'false' END AS value
FROM Expressions a 
JOIN Varaiables b ON a.left_operand = b.name 
JOIN Vairables c ON a.right_operand = c.name;

-- 1578
WITH stats AS (
    SELECT 
        sale_date, 
        SUM(CASE WHEN fruit = 'apples' THEN sold_num ELSE 0 END) AS apple,
        SUM(CASE WHEN fruit = 'oranges' THEN sold_num ELSE 0 END) AS oranges
    FROM Sales 
    GROUP BY sale_date 
)
SELECT 
    sale_date,
    apple - oranges AS diff 
FROM stats
ORDER BY sale_date;

-- 1639
SELECT DISTINCT 
    b.title 
FROM TVProgram a 
JOIN Content b ON a.content_id = b.content_id 
WHERE DATE_FORMAT(a.program_date, '%Y-%m') = '2020-06'
AND b.Kids_content = 'Y'
AND b.content_type = 'Movies';

--1641 
WITH all_calls AS (
    SELECT called_id AS user_id, duration FROM Calls 
    UNION ALL
    SELECT callee_id AS user_id, duration FROM Calls
),
country_calls AS (
    SELECT 
        c.name AS country, 
        ac.duration 
    FROM all_calls ac 
    JOIN Person p ON ac.user_id = p.id
    JOIN Country c ON LEFT(p.phone_number, 3) = c.country_code
)
SELECT country 
FROM country_calls 
GROUP BY country 
HAVING AVG(duration) > (
    SELECT AVG(duration) FROM Calls
);

--1654 
SELECT 
    a.customer_id, 
    a.customer_name AS name 
FROM Customers a 
JOIN Orders b ON a.customer_id = b.customer_id 
JOIN Product c ON b.product_id = c.product_id 
WHERE DATE_FORMAT(b.order_date, '%Y-%m') IN ('2020-06', '2020-07')
GROUP BY a.customer_id, a.customer_name 
HAVING SUM(CASE WHEN DATE_FORMAT(b.order_date, '%Y-%m') = '2020-06' THEN b.quantity * c.price ELSE 0 END ) >= 100
AND SUM(CASE WHEN DATE_FORMAT(b.order_date, '%Y-%m') = '2020-07' THEN b.quantity * c.price ELSE 0 END ) >= 100;

-- 1671
WITH stats AS (
    SELECT 
        order_id, 
        order_date, 
        customer_id, 
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
    FROM Orders 
)
SELECT 
    a.customer_name,
    a.customer_id,
    b.order_id,
    b.order_date
FROM Customers a 
JOIN stats b ON a.customer_id = b.customer_id 
WHERE b.rnk <= 3
ORDER BY a.customer_name, a.customer_id, b.order_date DESC;

-- 1688
WITH stats AS (
    SELECT 
        a.product_id, 
        a.product_name,
        b.order_id,
        b.order_date 
        RANK() OVER (PARTITION BY a.product_id ORDER BY b.order_date DESC) AS rnk
    FROM Products a 
    JOIN Orders b ON a.product_id = b.product_id 
)
SELECT 
    product_name, 
    product_id,
    order_id, 
    order_date 
FROM stats 
WHERE rnk = 1
ORDER BY product_name, product_id, order_id;

--1718 
SELECT 
    a.name AS warehouse_name, 
    SUM(a.units * b.Width * b.Length * b.Height) AS volume
FROM Warehouse a 
JOIN Products b ON a.product_id = b.product_id 
GROUP BY a.name;


--1734
SELECT 
    a.name, 
    SUM(b.amount) AS balance 
FROM Users a 
JOIN Transactions b ON a.account = b.account 
GROUP BY a.account 
HAVING sum(b.amount) > 10000; 
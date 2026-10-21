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

-- 1735
WITH stats AS (
    SELECT 
        a.customer_id,
        a.product_id,
        b.product_name,
        RANK() OVER (PARTITION BY a.customer_id ORDER BY COUNT(b.order_id)) DESC) AS rnk 
    FROM Orders a 
    JOIN Products b ON a.product_id = b.product_id
    GROUP BY a.customer_id, a.product_id, b.product_name
)
SELECT 
    customer_id,
    product_id,
FROM stats
WHERE rnk = 1;

--1749 
SELECT 
    seller_name 
FROM Seller 
WHERE seller_id NOT IN (SELECT DISTINCT seller_id FROM Orders WHERE DATE_FORMAT(sale_date, '%Y') = '2020')
ORDER BY seller_name;

-- 1837 
SELECT 
    date_id,
    make_name,
    COUNT(DISTINCT lead_id) AS unique_leads,
    COUNT(DISTINCT partner_id) AS unique_partners
FROM DailySales 
GROUP BY date_id, make_name;

--1842
SELECT 
    LEAST(from_id, to_id) AS person1, 
    GREATEST(from_id, to_id) AS person2,
    COUNT(*) AS call_count 
    SUM(duration) AS total_duration
FROM Calls 
GROUP BY person1, person2;

-- 1852 
WITH stats AS (
    SELECT 
        user_id,
        visit_date,
        LEAD(visit_date, 1, '2021-01-01') OVER (PARTITION BY user_id ORDER BY visit_date) AS next_visit
    FROM UserVisits 
)
SELECT 
    user_id,
    MAX(DATEDIFF(next_visit, visit_date)) AS biggest_window 
FROM stats
GROUP BY user_id,
ORDER BY user_id;

-- 1892 
SELECT 
    event_day AS day,
    emp_id,
    SUM(out_time - in_time) AS total_time
FROM Employees
GROUP BY event_dat, emp_id;

--1898 
SELECT DISTINCT 
    a.account_id 
FROM LogInfo a
JOIN LogInfo b 
ON a.account_id = b.account_id
AND a.ip_address != b.ip_address
AND l1.login <= l2.logout 
AND l1.logout >= l2.login;

-- 1914
WITH RECURSIVE subtaskseq AS (
    SELECT 1 AS subtask_id,
    UNION ALL 
    SELECT subtask_id + 1
    FROM subtaskseq
    WHERE subtask_id < 20
),
possiblesubtask AS (
    SELECT 
        a.task_id,
        b.subtask_id
    FROM Task a 
    JOIN subtaskseq b 
    ON b.subtask_id <= a.subtasks_count 
)
SELECT 
    p.task_id,
    p.subtask_id
FROM possiblesubtask p
LEFT JOIN Executed e 
ON p.task_id = e.task_id 
AND p.subtask_id = e.subtask_id 
WHERE e.subtask_id IS NULL;

--1932
WITH winners AS (
    SELECT Wimbledon AS player_id FROM Championships 
    UNION ALL 
    SELECT Fr_open AS player_id FROM Championships 
    UNION ALL 
    SELECT US_open AS player_id FROM Championships 
    UNION ALL 
    SELECT Au_open AS player_id FROM Championships 
)
SELECT 
    a.player_id,
    a.player_name,
    COUNT(b.player_id) AS grand_slams_count
FROM Players a 
JOIN winners b ON a.player_id = b.player_id 
GROUP BY a.player_id, a.player_name;

--1948
SELECT product_id, 'store_1' AS store, store1 AS price FROM Products WHERE store1 IS NOT NULL 
UNION ALL 
SELECT product_id, 'store_2' AS store, store2 AS price FROM Products WHERE store2 IS NOT NULL 
UNION ALL 
SELECT product_id, 'store_3' AS store, store3 AS price FROM Products WHERE store3 IS NOT NULL;

-- 1974
SELECT 
    customer_id 
FROM Customers 
WHERE year = 2021
AND revenue > 0;

-- 1981 
WITH stats AS (
    SELECT 
        transaction_id,
        DENSE_RANK() OVER (PARTITION BY CAST(day AS DATE) ORDER BY amount DESC) AS rnk
    FROM Transactions
)
SELECT 
    transaction_id 
FROM stats 
WHERE rnk = 1
ORDER BY transaction_id;

-- 2024
SELECT 
    employee_id,
    CASE 
        WHEN employee_id % 2 = 0 OR name LIKE 'M%' THEN 0 
        ELSE salary
    END AS bonus 
FROM Employees;

-- 2041
SELECT 
    user_id,
    MAX(time_stamp) AS last_stamp 
FROM Logins 
WHERE YEAR(time_stamp) = 2020
GROUP BY user_id;

-- 2110
SELECT a.employee_id 
FROM Employees a
LEFT JOIN Salaries b ON a.employee_id = b.employee_id 
WHERE b.salary IS NULL

UNION

SELECT b.employee_id 
FROM Employees a
RIGHT JOIN Salaries b ON a.employee_id = b.employee_id 
WHERE a.name IS NULL

ORDER BY employee_id;
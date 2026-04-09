CREATE TABLE clinics (
    cid VARCHAR(50),
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE customers (
    uid VARCHAR(50),
    name VARCHAR(100),
    mobile VARCHAR(15)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50),
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount INT,
    datetime DATETIME,
    sales_channel VARCHAR(50)
);

CREATE TABLE expenses (
    eid VARCHAR(50),
    cid VARCHAR(50),
    description TEXT,
    amount INT,
    datetime DATETIME
);

INSERT INTO clinics VALUES
('c1','Clinic A','Mumbai','MH','India'),
('c2','Clinic B','Delhi','DL','India');

INSERT INTO customers VALUES
('u1','John','9999999999'),
('u2','Alice','8888888888');

INSERT INTO clinic_sales VALUES
('o1','u1','c1',5000,'2021-09-10','online'),
('o2','u2','c1',7000,'2021-09-12','offline'),
('o3','u1','c2',3000,'2021-09-15','online');

INSERT INTO expenses VALUES
('e1','c1','rent',2000,'2021-09-10'),
('e2','c2','supplies',1000,'2021-09-15');


#Q1: Revenue per sales channel SQL
SELECT sales_channel, SUM(amount) AS revenue
FROM clinic_sales
GROUP BY sales_channel;
#Q2: Top 10 customers SQL
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;
#Q3: Monthly revenue, expense, profit SQL
WITH revenue AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') m, SUM(amount) rev
    FROM clinic_sales GROUP BY m
),
expense AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') m, SUM(amount) exp
    FROM expenses GROUP BY m
)
SELECT r.m, r.rev, e.exp,
       (r.rev - e.exp) profit,
       CASE WHEN (r.rev - e.exp)>0 THEN 'PROFIT' ELSE 'LOSS' END status
FROM revenue r
LEFT JOIN expense e ON r.m = e.m;
#Q4: Most profitable clinic per city SQL
WITH profit AS (
    SELECT c.city, c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) profit
    FROM clinics c
    LEFT JOIN clinic_sales cs ON c.cid=cs.cid
    LEFT JOIN expenses e ON c.cid=e.cid
    GROUP BY c.city, c.cid
),
ranked AS (
    SELECT *, RANK() OVER(PARTITION BY city ORDER BY profit DESC) rnk
    FROM profit
)
SELECT * FROM ranked WHERE rnk=1;
#Q5: Second least profitable clinic per state SQL
WITH profit AS (
    SELECT c.state, c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) profit
    FROM clinics c
    LEFT JOIN clinic_sales cs ON c.cid=cs.cid
    LEFT JOIN expenses e ON c.cid=e.cid
    GROUP BY c.state, c.cid
),
ranked AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY state ORDER BY profit ASC) rnk
    FROM profit
)
SELECT * FROM ranked WHERE rnk=2;
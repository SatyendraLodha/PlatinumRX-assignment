CREATE TABLE users (
    user_id VARCHAR(50),
    name VARCHAR(100),
    phone_number VARCHAR(15),
    mail_id VARCHAR(100),
    billing_address TEXT
);

CREATE TABLE bookings (
    booking_id VARCHAR(50),
    booking_date DATETIME,
    room_no VARCHAR(20),
    user_id VARCHAR(50)
);

CREATE TABLE items (
    item_id VARCHAR(50),
    item_name VARCHAR(100),
    item_rate INT
);

CREATE TABLE booking_commercials (
    id VARCHAR(50),
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity FLOAT
);


INSERT INTO users VALUES
('u1','John','9999999991','john@mail.com','Address1'),
('u2','Alice','9999999992','alice@mail.com','Address2');

INSERT INTO bookings VALUES
('b1','2021-11-10 10:00:00','101','u1'),
('b2','2021-11-20 12:00:00','102','u1'),
('b3','2021-10-05 09:00:00','103','u2');

INSERT INTO items VALUES
('i1','Paratha',20),
('i2','Veg Curry',100),
('i3','Rice',50);

INSERT INTO booking_commercials VALUES
('c1','b1','bill1','2021-11-10','i1',2),
('c2','b1','bill1','2021-11-10','i2',1),
('c3','b2','bill2','2021-11-20','i3',4),
('c4','b3','bill3','2021-10-05','i2',5);
#Q1: Last booked room per user
SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) t
ON b.user_id = t.user_id AND b.booking_date = t.last_booking;

#Q2: Booking billing in Nov 2021 SQL
SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;
#Q3: Bills >1000 in Oct 2021
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING total_bill > 1000;

#Q4: Most & Least ordered item per month

WITH item_sales AS (
    SELECT DATE_FORMAT(bill_date,'%Y-%m') AS month,
           item_id,
           SUM(item_quantity) AS qty
    FROM booking_commercials
    GROUP BY month, item_id
),
ranked AS (
    SELECT *,
           RANK() OVER(PARTITION BY month ORDER BY qty DESC) r1,
           RANK() OVER(PARTITION BY month ORDER BY qty ASC) r2
    FROM item_sales
)
SELECT * FROM ranked WHERE r1=1 OR r2=1;

 #Second highest bill per month

WITH bill_data AS (
    SELECT DATE_FORMAT(bc.bill_date,'%Y-%m') AS month,
           b.user_id,
           bc.bill_id,
           SUM(bc.item_quantity * i.item_rate) AS total
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY month, b.user_id, bc.bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY month ORDER BY total DESC) rnk
    FROM bill_data
)
SELECT * FROM ranked WHERE rnk=2;
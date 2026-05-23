CREATE DATABASE ExpenseTrackerDB;

USE ExpenseTrackerDB;

-- =====================================================
-- SECTION A : CONCEPT APPLICATION
-- =====================================================

/*
1. Explain how relational databases help maintain accuracy in expense records.

Relational databases organize data into related tables.
Tables are connected using primary keys and foreign keys.
This avoids duplicate data and ensures every expense belongs
to a valid user and category. It improves data consistency
and accuracy.
*/


/*
2. Why are constraints important in personal finance data?

Constraints enforce rules on database data.
They prevent invalid entries and maintain integrity.

Examples:
- PRIMARY KEY prevents duplicate IDs.
- FOREIGN KEY ensures valid relationships.
- UNIQUE prevents duplicate emails.
- NOT NULL avoids empty important fields.
*/


/*
3. How does GROUP BY help analyze spending patterns?

GROUP BY groups similar records together.
It helps calculate:
- Total expense per category
- Total expense per user
- Monthly spending reports

This makes spending analysis easier.
*/


/*
4. Explain a scenario where rollback is required during expense entry.

Suppose a user accidentally enters an incorrect expense amount
such as 50000 instead of 500.

Using ROLLBACK cancels the transaction and restores
the previous correct data.
*/


/*
5. How do views help users track monthly expenses efficiently?

Views are virtual tables created from queries.
They simplify complex SQL queries and provide easy access
to monthly reports, category summaries, and user expenses.
*/


/*
6. Why use triggers for automatic category or balance updates?

Triggers automatically execute actions after INSERT, UPDATE,
or DELETE operations.

Examples:
- Automatically update account balance
- Automatically assign default category
- Maintain audit logs

Triggers reduce manual work and improve consistency.
*/


-- =====================================================
-- SECTION B : SQL HANDS-ON
-- =====================================================


-- =====================================================
-- GIVEN DATABASE SCHEMA
-- =====================================================

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    created_at DATE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE expenses (
    expense_id INT PRIMARY KEY,
    user_id INT,
    category_id INT,
    amount DECIMAL(10,2),
    expense_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);


-- =====================================================
-- 1. DDL UNDERSTANDING
-- =====================================================

/*
Why are foreign keys used?

Foreign keys maintain referential integrity.
The user_id in expenses must exist in users table,
and category_id must exist in categories table.

This prevents invalid expense records.
*/


/*
Issue if foreign keys are removed:

Without foreign keys, orphaned records may occur.

Example:
An expense may remain in expenses table even after
the related user is deleted from users table.

This creates inconsistent and unreliable data.
*/


-- =====================================================
-- 2. DML OPERATIONS
-- =====================================================


-- INSERT 5 USERS

INSERT INTO users VALUES
(1, 'Amit Shah', 'amit@gmail.com', '2026-01-10');

INSERT INTO users VALUES
(2, 'Priya Patel', 'priya@gmail.com', '2026-01-12');

INSERT INTO users VALUES
(3, 'Rahul Mehta', 'rahul@gmail.com', '2026-01-15');

INSERT INTO users VALUES
(4, 'Sneha Joshi', 'sneha@gmail.com', '2026-01-20');

INSERT INTO users VALUES
(5, 'Karan Desai', 'karan@gmail.com', '2026-01-25');


-- INSERT 3 CATEGORIES

INSERT INTO categories VALUES
(101, 'Food');

INSERT INTO categories VALUES
(102, 'Rent');

INSERT INTO categories VALUES
(103, 'Entertainment');


-- INSERT 10 EXPENSE RECORDS

INSERT INTO expenses VALUES
(1001, 1, 101, 250.00, '2026-02-01');

INSERT INTO expenses VALUES
(1002, 1, 102, 5000.00, '2026-02-02');

INSERT INTO expenses VALUES
(1003, 2, 101, 450.00, '2026-02-03');

INSERT INTO expenses VALUES
(1004, 2, 103, 700.00, '2026-02-05');

INSERT INTO expenses VALUES
(1005, 3, 102, 6000.00, '2026-02-06');

INSERT INTO expenses VALUES
(1006, 3, 101, 350.00, '2026-02-08');

INSERT INTO expenses VALUES
(1007, 4, 103, 1200.00, '2026-02-09');

INSERT INTO expenses VALUES
(1008, 4, 101, 500.00, '2026-02-10');

INSERT INTO expenses VALUES
(1009, 5, 102, 7500.00, '2026-02-12');

INSERT INTO expenses VALUES
(1010, 5, 103, 900.00, '2026-02-14');


-- UPDATE INCORRECT EXPENSE

UPDATE expenses
SET amount = 800.00
WHERE expense_id = 1004;


-- DELETE ONE EXPENSE

DELETE FROM expenses
WHERE amount < 300;


-- =====================================================
-- 3. DATA RETRIEVAL
-- =====================================================


-- DISPLAY ALL EXPENSE DETAILS USING INNER JOIN

SELECT
e.expense_date,
e.amount,
u.name,
c.category_name
FROM expenses e
INNER JOIN users u
ON e.user_id = u.user_id
INNER JOIN categories c
ON e.category_id = c.category_id;


-- TOTAL EXPENSE PER CATEGORY

SELECT
c.category_name,
SUM(e.amount) AS total_expense
FROM expenses e
INNER JOIN categories c
ON e.category_id = c.category_id
GROUP BY c.category_name;


-- USERS SORTED BY TOTAL SPENDING

SELECT
u.name,
SUM(e.amount) AS total_spending
FROM expenses e
INNER JOIN users u
ON e.user_id = u.user_id
GROUP BY u.name
ORDER BY total_spending DESC;


-- =====================================================
-- 4. VIEWS
-- =====================================================


-- CREATE VIEW

CREATE VIEW ActiveUsersView AS
SELECT
u.name,
u.email
FROM users u
INNER JOIN expenses e
ON u.user_id = e.user_id
GROUP BY u.user_id, u.name, u.email
HAVING COUNT(e.expense_id) > 5;


-- QUERY VIEW

SELECT * FROM ActiveUsersView;


-- =====================================================
-- SECTION C : MINI PROJECT
-- =====================================================


-- =====================================================
-- CRUD OPERATIONS
-- =====================================================


-- CREATE

INSERT INTO expenses VALUES
(1011, 1, 103, 1500.00, '2026-02-18');


-- READ

SELECT * FROM expenses;


-- UPDATE

UPDATE expenses
SET amount = 1800.00
WHERE expense_id = 1011;


-- DELETE

DELETE FROM expenses
WHERE expense_id = 1011;


-- =====================================================
-- STORED PROCEDURE
-- =====================================================

DELIMITER //

CREATE PROCEDURE GetMonthlyExpense(
    IN p_user_id INT,
    IN p_month INT,
    IN p_year INT
)
BEGIN

    SELECT
        u.name,
        SUM(e.amount) AS monthly_total

    FROM expenses e

    INNER JOIN users u
    ON e.user_id = u.user_id

    WHERE e.user_id = p_user_id
    AND MONTH(e.expense_date) = p_month
    AND YEAR(e.expense_date) = p_year

    GROUP BY u.name;

END //

DELIMITER ;


-- EXECUTE STORED PROCEDURE

CALL GetMonthlyExpense(1, 2, 2026);


-- =====================================================
-- COMMIT AND ROLLBACK
-- =====================================================


-- START TRANSACTION

START TRANSACTION;


-- INSERT WRONG DATA

INSERT INTO expenses VALUES
(1012, 2, 101, 99999.00, '2026-02-20');


-- CHECK RECORD

SELECT * FROM expenses
WHERE expense_id = 1012;


-- CANCEL TRANSACTION

ROLLBACK;


-- VERIFY RECORD REMOVED

SELECT * FROM expenses
WHERE expense_id = 1012;


-- START NEW TRANSACTION

START TRANSACTION;


-- INSERT CORRECT DATA

INSERT INTO expenses VALUES
(1013, 2, 103, 2000.00, '2026-02-22');


-- SAVE CHANGES

COMMIT;


-- VERIFY SAVED RECORD

SELECT * FROM expenses
WHERE expense_id = 1013;




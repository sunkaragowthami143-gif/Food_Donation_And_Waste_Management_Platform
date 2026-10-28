# 🍲 Food Donation & Waste Management Platform

## 📖 Project Overview

The **Food Donation & Waste Management Platform** is a database management project designed to reduce food waste by connecting food donors with people and organizations in need. The system helps manage food donations, donor details, recipient information, food collection, distribution, and waste records efficiently.

In a manual system, managing surplus food, finding suitable recipients, tracking donations, and arranging food collection can be difficult. Food may be wasted due to poor coordination, delayed distribution, and a lack of proper records.

To solve these problems, this project provides a structured system to maintain donation details, monitor food availability, manage recipients, and track the distribution of donated food. SQL queries and relational database concepts help improve data accuracy, organization, and retrieval.

## 🎯 Project Objectives

- Reduce food waste by encouraging food donations.
- Maintain donor and recipient information.
- Record surplus food donations and their quantities.
- Track food collection and distribution details.
- Maintain donation status and food availability.
- Retrieve donation and distribution information efficiently.
- Generate reports on donated food, distributed food, and food waste.
- Demonstrate SQL concepts learned during training.

## ✨ Features

- Relational database design.
- Donor and recipient management.
- Food donation registration.
- Food quantity and availability tracking.
- Food collection and distribution management.
- Donation status tracking.
- Primary keys and foreign keys.
- Constraints such as `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK`, where applicable.
- Insertion, updating, deletion, and retrieval of records.
- Filtering, sorting, and aggregate functions.
- Joins and subqueries for retrieving related information.
- Reports on food donations, distributions, and waste.
- Views, indexes, triggers, and stored procedures, where implemented.

## 🛠️ Technologies Used

- **Database:** MySQL
- **Query Language:** SQL
- **Database Tool:** MySQL Workbench / MySQL Command Line Client

## 🗄️ Database Name

`food_donation_db`

## 📋 Main Modules

1. **Donor Management:** Stores donor details, such as donor ID, name, contact information, and address.

2. **Recipient Management:** Maintains information about individuals, NGOs, charities, and other organizations receiving donated food.

3. **Food Donation Management:** Records the food item, quantity, donation date, expiry or best-before details where applicable, and availability status.

4. **Food Collection Management:** Tracks collection schedules, pickup details, and the status of donated food.

5. **Food Distribution Management:** Maintains records of food distributed to recipients, including quantities, distribution dates, and delivery status.

6. **Waste Tracking and Reporting:** Records food that is spoiled, expired, or otherwise unsuitable for donation and generates useful reports to analyse donation and waste patterns.

## 🔗 Database Relationships

The database uses relationships between tables to reduce unnecessary duplication and maintain data consistency.

- One donor can make multiple food donations.
- One recipient can receive multiple donations.
- One food donation can have collection details associated with it.
- One donation can be distributed through one or more distribution records, depending on the database design.
- Food waste records can be linked to the relevant donation or food item.
- Primary keys and foreign keys establish relationships between the tables.

## ⚙️ SQL Concepts Implemented

### 🟢 Basic SQL Concepts

- `CREATE DATABASE` and `CREATE TABLE`
- `INSERT`, `SELECT`, `UPDATE`, and `DELETE`
- `WHERE` clause
- `DISTINCT`
- `ORDER BY` and `LIMIT`
- Operators such as `AND`, `OR`, and `NOT`
- `BETWEEN`, `IN`, `LIKE`, and `IS NULL`

### 🟡 Intermediate SQL Concepts

- Aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`
- `GROUP BY` and `HAVING`
- Primary and foreign key constraints
- `ALTER TABLE`
- `UNIQUE`, `NOT NULL`, `DEFAULT`, and `CHECK` constraints
- Date and string functions
- Data validation and integrity

### 🔴 Advanced SQL Concepts

- `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`
- Multiple-table joins
- Subqueries
- Views
- Indexes
- Triggers
- Stored procedures
- Transaction handling using `COMMIT` and `ROLLBACK`

*Note: List advanced concepts as implemented only when the corresponding SQL statements or database objects are included in your project.*

## ▶️ How to Run the Project

1. Install MySQL Server and MySQL Workbench, or open the MySQL Command Line Client.
2. Open the SQL script for the project.
3. Create the database if it does not already exist:

   ```sql
   CREATE DATABASE food_donation_db;
   ```

4. Select the database:

   ```sql
   USE food_donation_db;
   ```

5. Execute the table creation statements in the correct order, creating parent tables before dependent tables.
6. Insert sample data into the tables while following primary key and foreign key rules.
7. Execute the SQL queries to test donation registration, recipient management, collection, and distribution.
8. Verify the results using `SELECT` statements.
9. If included, test the views, triggers, stored procedures, and transaction statements.

## 📊 Sample Queries

*The following examples assume that the project uses the indicated table and column names. Adjust them to match your actual database schema.*

### 1. Display all donors

```sql
SELECT *
FROM donors;
```

### 2. Display all food donations

```sql
SELECT *
FROM food_donations;
```

### 3. Display available food donations

```sql
SELECT *
FROM food_donations
WHERE status = 'Available';
```

### 4. Count the total number of donations

```sql
SELECT COUNT(*) AS total_donations
FROM food_donations;
```

### 5. Calculate the total quantity of donated food

```sql
SELECT SUM(quantity) AS total_food_quantity
FROM food_donations;
```

*Note: This calculation assumes that `quantity` is stored in a consistent unit, such as kilograms.*

### 6. Display donation details with donor names

```sql
SELECT
    fd.donation_id,
    d.donor_name,
    fd.food_item,
    fd.quantity,
    fd.donation_date,
    fd.status
FROM food_donations fd
INNER JOIN donors d
    ON fd.donor_id = d.donor_id;
```

### 7. Find donors who have donated more than once

```sql
SELECT
    donor_id,
    COUNT(*) AS donation_count
FROM food_donations
GROUP BY donor_id
HAVING COUNT(*) > 1;
```

## 🎓 Learning Outcomes

Through this project, the following concepts can be practised and demonstrated:

- Designing and implementing a relational database.
- Creating tables with appropriate data types.
- Understanding primary keys and foreign keys.
- Applying constraints to maintain data integrity.
- Managing donor, recipient, and donation records.
- Writing basic, intermediate, and advanced SQL queries.
- Using joins and subqueries to retrieve related information.
- Applying aggregate functions to analyse donation quantities.
- Tracking food availability, distribution, and waste.
- Understanding database normalization.
- Implementing views, triggers, indexes, and stored procedures when required.

## 🔮 Future Scope

- Develop a web or mobile application for donors and recipients.
- Enable online food donation registration.
- Provide location-based matching between donors and recipients.
- Send notifications about available food donations and collection schedules.
- Add expiry alerts to help prioritize suitable food for timely distribution.
- Integrate pickup and delivery tracking.
- Develop dashboards showing donated food, distributed food, and waste reduction.
- Introduce role-based access for administrators, donors, volunteers, and recipient organizations.
- Integrate food donation analytics to identify donation patterns and improve distribution planning.

## 👩‍💻 Author

Gowthami Sunkara

MySQL python full Stack Trainee

## 📝 Conclusion

The Food Donation & Waste Management Platform provides a structured approach to managing surplus food donations, recipients, collections, distributions, and food waste. By using MySQL and SQL concepts, the project demonstrates how a relational database can improve record management, data consistency, and reporting while supporting efforts to reduce food waste and make surplus food available to people in need.
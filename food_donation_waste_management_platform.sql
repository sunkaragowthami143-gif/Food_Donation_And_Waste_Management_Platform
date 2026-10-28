-- ================================================
-- Food Donation & Waste Management Platform
-- ==============================================
-- =========
--  Contents:
--    PART 1  : Database & Table Creation (schema)
--    PART 2  : Sample Data (INSERT statements)
--    PART 3  : Indexes
--    PART 4  : Views
--    PART 5  : Stored Procedures
--    PART 6  : Triggers
--    PART 7  : Query Bank - Level 1 (Q1-Q4)
--    PART 8  : Query Bank - Level 2 (Q5-Q8)
--    PART 9  : Query Bank - Level 3 (Q9-Q21)
--
--  RDBMS   : MySQL 8.0+ (also compatible with MariaDB 10.x)
--  Notes   : Every ANSWER below each query is a comment showing what
--            that query returns when run against the sample data in
--            PART 2. Run the SELECT yourself to confirm.
-- 

-- ============================================================
-- PART 1: CREATE DATABASE AND USE IT
-- ============================================================
CREATE DATABASE FOOD_DONATION_WASTE_DB;
USE FOOD_DONATION_WASTE_DB;
-- ============================================================
-- PART 2: CREATE TABLES (DDL)
-- ============================================================
-- 2.1 Donors (Strong Entity)
CREATE TABLE DONORS (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_name VARCHAR(100) NOT NULL,
    donor_type ENUM('Restaurant','Hotel','Grocery','Individual','Bakery','Caterer') NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number BIGINT,
    city VARCHAR(50) DEFAULT 'Hyderabad',
    address VARCHAR(255),
    registered_date DATE DEFAULT (CURRENT_DATE)
);
-- 2.2 Receivers / NGOs (Strong Entity)
CREATE TABLE RECEIVERS (
    receiver_id INT PRIMARY KEY AUTO_INCREMENT,
    organization_name VARCHAR(150) NOT NULL,
    receiver_type ENUM('NGO','Shelter','Community Kitchen','Orphanage','Old Age Home') NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number BIGINT,
    city VARCHAR(50) DEFAULT 'Hyderabad',
    capacity_meals INT DEFAULT 0,
    verified BOOLEAN DEFAULT FALSE
);
-- 2.3 Volunteers (Strong Entity)
CREATE TABLE VOLUNTEERS (
    volunteer_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_name VARCHAR(100) NOT NULL,
    phone_number BIGINT UNIQUE,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50) DEFAULT 'Hyderabad',
    availability ENUM('Weekdays','Weekends','Anytime','On-Call') DEFAULT 'Weekends',
    joined_date DATE DEFAULT (CURRENT_DATE),
    active BOOLEAN DEFAULT TRUE
);
-- 2.4 Food Listings (Surplus food posted by Donors)
CREATE TABLE FOOD_LISTINGS (
    listing_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    food_name VARCHAR(150) NOT NULL,
    food_category ENUM('Cooked Meal','Packaged','Bakery','Fruits & Vegetables','Beverages','Dairy') NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    servings INT NOT NULL,
    prepared_at DATETIME,
    expiry_at DATETIME,
    listing_status ENUM('Available','Claimed','Picked Up','Expired','Discarded') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES DONORS(donor_id)
);
-- 2.5 Claims (Receivers claim a listing)
CREATE TABLE CLAIMS (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id INT NOT NULL,
    receiver_id INT NOT NULL,
    claim_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    claim_status ENUM('Pending','Approved','Rejected','Completed','Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (listing_id) REFERENCES FOOD_LISTINGS(listing_id),
    FOREIGN KEY (receiver_id) REFERENCES RECEIVERS(receiver_id)
);
-- 2.6 Pickups (Volunteer schedules pickup)
CREATE TABLE PICKUPS (
    pickup_id INT PRIMARY KEY AUTO_INCREMENT,
    claim_id INT NOT NULL,
    volunteer_id INT,
    pickup_date DATE NOT NULL,
    pickup_time TIME NOT NULL,
    pickup_status ENUM('Scheduled','In Transit','Delivered','Failed') DEFAULT 'Scheduled',
    delivered_at DATETIME NULL,
    FOREIGN KEY (claim_id) REFERENCES CLAIMS(claim_id),
    FOREIGN KEY (volunteer_id) REFERENCES VOLUNTEERS(volunteer_id)
);
-- 2.7 Distributions (Meals actually served)
CREATE TABLE DISTRIBUTIONS (
    distribution_id INT PRIMARY KEY AUTO_INCREMENT,
    pickup_id INT NOT NULL,
    meals_served INT NOT NULL,
    people_benefited INT NOT NULL,
    distribution_date DATE NOT NULL,
    distribution_time TIME,
    notes TEXT,
    FOREIGN KEY (pickup_id) REFERENCES PICKUPS(pickup_id)
);
-- 2.8 Waste Log (Spoiled / Discarded food)
CREATE TABLE WASTE_LOG (
    waste_id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id INT NOT NULL,
    waste_reason ENUM('Expired','Spoiled','Contaminated','Unsold','Damaged Packaging','Other') NOT NULL,
    quantity_wasted_kg DECIMAL(10,2) NOT NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES FOOD_LISTINGS(listing_id)
);
-- 2.9 Donor Audit (Track donor type changes)
CREATE TABLE DONOR_AUDIT (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT,
    action_type VARCHAR(50),
    old_value VARCHAR(100),
    new_value VARCHAR(100),
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 2.10 Verify Structure
SHOW TABLES;
DESC donors;
DESC receivers;
DESC volunteers;
DESC food_listings;
DESC claims;
DESC pickups;
DESC distributions;
DESC waste_log;
DESC donor_audit;
-- ============================================================
-- PART 3: INSERT SAMPLE DATA (DML)
-- ============================================================
-- 3.1 Donors
INSERT INTO donors (donor_name, donor_type, contact_person, email, phone_number, city, address) VALUES
('Taj Kitchen',       'Restaurant', 'Ravi Sharma',  'ravi@tajkitchen.com',    9871110001, 'Hyderabad', 'Banjara Hills'),
('Grand Hotel',       'Hotel',      'Meera Iyer',   'meera@grandhotel.com',   9871110002, 'Hyderabad', 'Hitech City'),
('Fresh Mart',        'Grocery',    'Anil Kumar',   'anil@freshmart.com',     9871110003, 'Vijayawada','Gandhi Nagar'),
('Sweet Bakes',       'Bakery',     'Priya Reddy',  'priya@sweetbakes.com',   9871110004, 'Hyderabad', 'Jubilee Hills'),
('Lakshmi Caterers',  'Caterer',    'Lakshmi Devi', 'lakshmi@lcaterers.com',  9871110005, 'Visakhapatnam','MVP Colony');
-- 3.2 Receivers
INSERT INTO receivers (organization_name, receiver_type, contact_person, email, phone_number, city, capacity_meals, verified) VALUES
('Helping Hands NGO', 'NGO',              'Suresh Babu', 'suresh@hhands.org',  9872220001, 'Hyderabad', 500, TRUE),
('Sunshine Shelter',  'Shelter',          'Deepa Menon', 'deepa@sunshine.org', 9872220002, 'Hyderabad', 200, TRUE),
('Annapurna Kitchen', 'Community Kitchen','Raghu Rao',   'raghu@annapurna.org',9872220003, 'Visakhapatnam', 300, TRUE);
-- 3.3 Volunteers
INSERT INTO volunteers (volunteer_name, phone_number, email, city, availability) VALUES
('Arjun Reddy',   9873330001, 'arjun.reddy@example.com', 'Hyderabad', 'Weekends'),
('Pooja Nair',    9873330002, 'pooja.nair@example.com',  'Hyderabad', 'Anytime'),
('Vikram Singh',  9873330003, 'vikram.singh@example.com','Vijayawada','Weekdays');
-- 3.4 Food Listings
INSERT INTO food_listings (donor_id, food_name, food_category, quantity_kg, servings, prepared_at, expiry_at, listing_status) VALUES
(1, 'Veg Biryani', 'Cooked Meal', 15.00, 40, '2026-11-20 12:00:00', '2026-11-20 20:00:00', 'Picked Up'),
(2, 'Paneer Curry + Roti', 'Cooked Meal', 10.00, 25, '2026-11-21 13:00:00', '2026-11-21 21:00:00', 'Claimed'),
(3, 'Fresh Tomatoes','Fruits & Vegetables', 25.00, 60, '2026-11-21 06:00:00', '2026-11-24 18:00:00', 'Available'),
(4, 'Assorted Pastries','Bakery', 5.00,  30, '2026-11-22 08:00:00', '2026-11-22 20:00:00', 'Available'),
(5, 'Rice & Sambar', 'Cooked Meal', 20.00, 50, '2026-11-19 12:00:00', '2026-11-19 20:00:00', 'Expired');
-- 3.5 Claims
INSERT INTO claims (listing_id, receiver_id, claim_status) VALUES
(1, 1, 'Completed'),
(2, 2, 'Approved'),
(3, 3, 'Pending');
-- 3.6 Pickups
INSERT INTO pickups (claim_id, volunteer_id, pickup_date, pickup_time, pickup_status, delivered_at) VALUES
(1, 1, '2026-11-20', '15:00:00', 'Delivered', '2026-11-20 16:30:00'),
(2, 2, '2026-11-21', '16:00:00', 'Scheduled', NULL);
-- 3.7 Distributions
INSERT INTO distributions (pickup_id, meals_served, people_benefited, distribution_date, distribution_time, notes) VALUES
(1, 40, 40, '2026-11-20', '17:00:00', 'Served at Helping Hands NGO shelter.');
-- 3.8 Waste Log
INSERT INTO waste_log (listing_id, waste_reason, quantity_wasted_kg) VALUES
(5, 'Expired', 20.00),
(4, 'Unsold', 1.00);

-- 3.9 Verify
SELECT * FROM donors;
SELECT * FROM receivers;
SELECT * FROM volunteers;
SELECT * FROM food_listings;
SELECT * FROM claims;
SELECT * FROM pickups;
SELECT * FROM distributions;
SELECT * FROM waste_log;
SELECT * FROM donor_audit;
-- ============================================================
-- PART 4: INDEXES
-- ============================================================
-- 4.1 Create Indexs
CREATE INDEX idx_listings_donor              ON food_listings(donor_id);
CREATE INDEX idx_listings_status_expiry      ON food_listings(listing_status, expiry_at);
CREATE INDEX idx_listings_category           ON food_listings(food_category);
CREATE INDEX idx_claims_receiver             ON claims(receiver_id);
CREATE INDEX idx_claims_listing_status       ON claims(listing_id, claim_status);
CREATE INDEX idx_pickups_volunteer_date      ON pickups(volunteer_id, pickup_date);
CREATE INDEX idx_pickups_status              ON pickups(pickup_status);
CREATE INDEX idx_waste_listing               ON waste_log(listing_id);
CREATE INDEX idx_donors_city                 ON donors(city);

-- Verify
-- SHOW INDEX FROM food_listings;
-- SHOW INDEX FROM claims;
-- SHOW INDEX FROM pickups;

-- ============================================================
-- PART 5: VIEWS
-- ============================================================
-- 5.1 Full Listing Detail
CREATE OR REPLACE VIEW view_listing_details AS
SELECT l.listing_id,
       d.donor_name, d.donor_type,
       d.city AS donor_city,
       l.food_name, l.food_category,
       l.quantity_kg, l.servings,
       l.prepared_at, l.expiry_at,
       l.listing_status,
       IFNULL(r.organization_name, 'Unclaimed') AS claimed_by,
       c.claim_status
FROM food_listings l
JOIN donors d         ON d.donor_id = l.donor_id
LEFT JOIN claims c    ON c.listing_id = l.listing_id
LEFT JOIN receivers r ON r.receiver_id = c.receiver_id;
-- 5.2 Volunteer Performance
CREATE OR REPLACE VIEW view_volunteer_performance AS
SELECT v.volunteer_id,
       v.volunteer_name,
       COUNT(p.pickup_id) AS total_pickups,
       SUM(CASE WHEN p.pickup_status = 'Delivered' THEN 1 ELSE 0 END) AS successful_pickups
FROM volunteers v
LEFT JOIN pickups p ON p.volunteer_id = v.volunteer_id
GROUP BY v.volunteer_id, v.volunteer_name;
-- 5.3 Waste Summary Per Donor
CREATE OR REPLACE VIEW view_donor_waste_summary AS
SELECT d.donor_id,
       d.donor_name,
       COUNT(w.waste_id) AS waste_incidents,
       COALESCE(SUM(w.quantity_wasted_kg), 0) AS total_wasted_kg
FROM donors d
LEFT JOIN food_listings l ON l.donor_id = d.donor_id
LEFT JOIN waste_log w     ON w.listing_id = l.listing_id
GROUP BY d.donor_id, d.donor_name;
-- 5.4 Receiver Impact
CREATE OR REPLACE VIEW view_receiver_impact AS
SELECT r.receiver_id,
       r.organization_name,
       COUNT(DISTINCT c.claim_id) AS total_claims,
       COALESCE(SUM(ds.meals_served), 0) AS total_meals_served,
       COALESCE(SUM(ds.people_benefited), 0) AS total_people_benefited
FROM receivers r
LEFT JOIN claims c         ON c.receiver_id = r.receiver_id
LEFT JOIN pickups p        ON p.claim_id = c.claim_id
LEFT JOIN distributions ds ON ds.pickup_id = p.pickup_id
GROUP BY r.receiver_id, r.organization_name;
-- ============================================================
-- PART 6: STORED PROCEDURES
-- ============================================================
-- 6.1 Claim a Listing (with capacity validation)
DROP PROCEDURE IF EXISTS sp_claim_listing;
DELIMITER //
CREATE PROCEDURE sp_claim_listing(
    IN p_listing_id INT,
    IN p_receiver_id INT,
    OUT p_result VARCHAR(150)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_servings INT;
    DECLARE v_capacity INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Claim failed: transaction rolled back';
    END;

    START TRANSACTION;
    SELECT listing_status, servings INTO v_status, v_servings
    FROM food_listings WHERE listing_id = p_listing_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Listing does not exist';
    END IF;

    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Listing is not available for claim';
    END IF;

    SELECT capacity_meals INTO v_capacity FROM receivers WHERE receiver_id = p_receiver_id;
    IF v_servings > v_capacity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receiver capacity exceeded';
    END IF;

    INSERT INTO claims (listing_id, receiver_id, claim_status) VALUES (p_listing_id, p_receiver_id, 'Approved');
    UPDATE food_listings SET listing_status = 'Claimed' WHERE listing_id = p_listing_id;

    COMMIT;
    SET p_result = 'Claim created successfully';
END //
DELIMITER ;

-- 6.2 Record Distribution
DROP PROCEDURE IF EXISTS sp_record_distribution;
DELIMITER //
CREATE PROCEDURE sp_record_distribution(
    IN p_pickup_id INT,
    IN p_meals_served INT,
    IN p_people_benefited INT,
    IN p_date DATE,
    IN p_time TIME,
    OUT p_result VARCHAR(150)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Distribution record failed';
    END;

    START TRANSACTION;
    INSERT INTO distributions (pickup_id, meals_served, people_benefited, distribution_date, distribution_time)
    VALUES (p_pickup_id, p_meals_served, p_people_benefited, p_date, p_time);
    UPDATE pickups SET pickup_status = 'Delivered', delivered_at = NOW() WHERE pickup_id = p_pickup_id;
    COMMIT;
    SET p_result = 'Distribution recorded successfully';
END //
DELIMITER ;
-- 6.3 Food Waste Report by City
DROP PROCEDURE IF EXISTS sp_waste_report_by_city;
DELIMITER //
CREATE PROCEDURE sp_waste_report_by_city()
BEGIN
    SELECT d.city,
           COUNT(w.waste_id)         AS incidents,
           SUM(w.quantity_wasted_kg) AS total_wasted_kg
    FROM donors d
    JOIN food_listings l ON l.donor_id = d.donor_id
    JOIN waste_log w     ON w.listing_id = l.listing_id
    GROUP BY d.city
    ORDER BY total_wasted_kg DESC;
END //
DELIMITER ;
-- 6.4 Mark Listing as Expired
DROP PROCEDURE IF EXISTS sp_expire_listings;
DELIMITER //
CREATE PROCEDURE sp_expire_listings()
BEGIN
    UPDATE food_listings
    SET listing_status = 'Expired'
    WHERE listing_status IN ('Available','Claimed')
      AND expiry_at < NOW();
END //
DELIMITER ;
-- ============================================================
-- PART 7: TRIGGERS
-- ============================================================

-- 7.1 Prevent Double Claims on Same Listing
DROP TRIGGER IF EXISTS trg_prevent_double_claim;
DELIMITER $$
CREATE TRIGGER trg_prevent_double_claim
BEFORE INSERT ON claims
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM claims
        WHERE listing_id = NEW.listing_id
          AND claim_status IN ('Pending','Approved','Completed')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This listing already has an active claim';
    END IF;
END $$
DELIMITER ;
-- 7.2 Auto-Audit Donor Type Changes
DROP TRIGGER IF EXISTS trg_audit_donor_type_shift;
DELIMITER $$
CREATE TRIGGER trg_audit_donor_type_shift
AFTER UPDATE ON donors
FOR EACH ROW
BEGIN
    IF OLD.donor_type <> NEW.donor_type THEN
        INSERT INTO donor_audit (donor_id, action_type, old_value, new_value)
        VALUES (NEW.donor_id, 'DONOR_TYPE_CHANGE', OLD.donor_type, NEW.donor_type);
    END IF;
END $$
DELIMITER ;
-- 7.3 Block Deletion of Donor with Active Listings

DROP TRIGGER IF EXISTS trg_block_donor_delete;
DELIMITER $$
CREATE TRIGGER trg_block_donor_delete
BEFORE DELETE ON donors
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM food_listings
    WHERE donor_id = OLD.donor_id
      AND listing_status IN ('Available','Claimed','Picked Up');
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete donor: active listings exist';
    END IF;
END $$
DELIMITER ;
-- 7.4 Auto-Log Waste When Listing is Discarded
DROP TRIGGER IF EXISTS trg_autolog_waste_on_discard;
DELIMITER $$
CREATE TRIGGER trg_autolog_waste_on_discard
AFTER UPDATE ON food_listings
FOR EACH ROW
BEGIN
    IF NEW.listing_status = 'Discarded' AND OLD.listing_status <> 'Discarded' THEN
        INSERT INTO waste_log (listing_id, waste_reason, quantity_wasted_kg)
        VALUES (NEW.listing_id, 'Other', NEW.quantity_kg);
    END IF;
END $$
DELIMITER ;
-- 7.5 Prevent Scheduling Pickup in Past
DROP TRIGGER IF EXISTS trg_block_past_pickup;
DELIMITER $$
CREATE TRIGGER trg_block_past_pickup
BEFORE INSERT ON pickups
FOR EACH ROW
BEGIN
    IF NEW.pickup_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot schedule pickup in the past';
    END IF;
END $$
DELIMITER ;

-- ============================================================
-- PART 8: QUERY BANK - LEVEL 1 (BASIC)
-- ============================================================
- Q1: List all donors and their type.
SELECT donor_name, donor_type FROM donors;

-- Q2: Listings currently available.
SELECT listing_id, food_name, food_category, servings
FROM food_listings
WHERE listing_status = 'Available';

-- Q3: Volunteers available on weekends.
SELECT volunteer_name, phone_number, city
FROM volunteers
WHERE availability IN ('Weekends','Anytime') AND active = TRUE;

-- Q4: Total meals served so far.
SELECT SUM(meals_served) AS total_meals FROM distributions;

-- ============================================================
-- PART 9: QUERY BANK - LEVEL 2 (JOINS & AGGREGATION)
-- ============================================================
-- Q5: Every claim with donor + receiver + listing.
SELECT c.claim_id,
       l.food_name,
       d.donor_name,
       r.organization_name,
       c.claim_status
FROM claims c
JOIN food_listings l ON l.listing_id = c.listing_id
JOIN donors d         ON d.donor_id = l.donor_id
JOIN receivers r      ON r.receiver_id = c.receiver_id
ORDER BY c.claim_id;
-- Q6: Meals served per receiver.
SELECT r.organization_name,
       COALESCE(SUM(ds.meals_served), 0) AS meals_served
FROM receivers r
LEFT JOIN claims c         ON c.receiver_id = r.receiver_id
LEFT JOIN pickups p        ON p.claim_id = c.claim_id
LEFT JOIN distributions ds ON ds.pickup_id = p.pickup_id
GROUP BY r.receiver_id, r.organization_name
ORDER BY meals_served DESC;
-- Q7: Volunteers with zero deliveries.
SELECT v.volunteer_name
FROM volunteers v
LEFT JOIN pickups p ON p.volunteer_id = v.volunteer_id
WHERE p.pickup_id IS NULL;
-- Q8: Total kg wasted per food category.
SELECT l.food_category,
       SUM(w.quantity_wasted_kg) AS wasted_kg
FROM waste_log w
JOIN food_listings l ON l.listing_id = w.listing_id
GROUP BY l.food_category
ORDER BY wasted_kg DESC;
-- ============================================================
-- PART 10: QUERY BANK - LEVEL 3 (ADVANCED)
-- ============================================================
-- Q9: Top donor by servings donated.
SELECT d.donor_name, SUM(l.servings) AS total_servings
FROM donors d
JOIN food_listings l ON l.donor_id = d.donor_id
GROUP BY d.donor_id, d.donor_name
ORDER BY total_servings DESC
LIMIT 1;
-- Q10: Second-highest quantity of food listed (kg).
SELECT DISTINCT quantity_kg
FROM food_listings
ORDER BY quantity_kg DESC
LIMIT 1 OFFSET 1;
-- Q11: Listings that expired without pickup or claim.
SELECT l.listing_id, l.food_name, l.expiry_at, l.listing_status
FROM food_listings l
LEFT JOIN claims c ON c.listing_id = l.listing_id
WHERE l.listing_status = 'Expired'
  AND c.claim_id IS NULL;
  -- Q12: Donor efficiency ratio = donated kg vs wasted kg.
SELECT d.donor_name,
       COALESCE(SUM(l.quantity_kg), 0) AS total_donated_kg,
       COALESCE(SUM(w.quantity_wasted_kg), 0) AS total_wasted_kg,
       ROUND(COALESCE(SUM(w.quantity_wasted_kg),0) / NULLIF(SUM(l.quantity_kg),0), 3) AS waste_ratio
FROM donors d
LEFT JOIN food_listings l ON l.donor_id = d.donor_id
LEFT JOIN waste_log w     ON w.listing_id = l.listing_id
GROUP BY d.donor_id, d.donor_name
ORDER BY waste_ratio DESC;
-- Q13: City-wise meals distributed.
SELECT d.city,
       COALESCE(SUM(ds.meals_served), 0) AS meals_served
FROM donors d
JOIN food_listings l  ON l.donor_id = d.donor_id
JOIN claims c         ON c.listing_id = l.listing_id
JOIN pickups p        ON p.claim_id = c.claim_id
JOIN distributions ds ON ds.pickup_id = p.pickup_id
GROUP BY d.city
ORDER BY meals_served DESC;

-- Q14: Receivers who claimed but no pickup yet.
SELECT r.organization_name, c.claim_id, l.food_name
FROM receivers r
JOIN claims c        ON c.receiver_id = r.receiver_id
JOIN food_listings l ON l.listing_id = c.listing_id
LEFT JOIN pickups p  ON p.claim_id = c.claim_id
WHERE p.pickup_id IS NULL AND c.claim_status IN ('Approved','Pending');
-- Q15: Average pickup delay (in hours) from claim to delivery.
SELECT ROUND(AVG(TIMESTAMPDIFF(HOUR, c.claim_time, p.delivered_at)), 2) AS avg_hours
FROM claims c
JOIN pickups p ON p.claim_id = c.claim_id
WHERE p.delivered_at IS NOT NULL;
-- Q16: Donors whose every listing was delivered (no wasted).
SELECT d.donor_name
FROM donors d
JOIN food_listings l ON l.donor_id = d.donor_id
LEFT JOIN waste_log w ON w.listing_id = l.listing_id
GROUP BY d.donor_id, d.donor_name
HAVING SUM(CASE WHEN w.waste_id IS NOT NULL THEN 1 ELSE 0 END) = 0;
-- Q17: Each category's best-performing donor (max meals contributed).
SELECT l.food_category, d.donor_name, SUM(l.servings) AS total_servings
FROM food_listings l
JOIN donors d ON d.donor_id = l.donor_id
GROUP BY l.food_category, d.donor_id, d.donor_name
HAVING SUM(l.servings) = (
    SELECT MAX(sub.total) FROM (
        SELECT SUM(l2.servings) AS total
        FROM food_listings l2
        WHERE l2.food_category = l.food_category
        GROUP BY l2.donor_id
    ) AS sub
);
-- Q18: Monthly donation trend.
SELECT DATE_FORMAT(prepared_at, '%Y-%m') AS month,
       COUNT(*) AS listings,
       SUM(quantity_kg) AS total_kg,
       SUM(servings) AS total_servings
FROM food_listings
GROUP BY month
ORDER BY month;
-- Q19: Pending claims older than 24 hours.
SELECT c.claim_id, l.food_name, r.organization_name, c.claim_time
FROM claims c
JOIN food_listings l ON l.listing_id = c.listing_id
JOIN receivers r      ON r.receiver_id = c.receiver_id
WHERE c.claim_status = 'Pending'
  AND c.claim_time < NOW() - INTERVAL 24 HOUR;
  -- Q20: Volunteer leaderboard by meals delivered.
SELECT v.volunteer_name,
       COUNT(DISTINCT p.pickup_id) AS deliveries,
       COALESCE(SUM(ds.meals_served), 0) AS meals_moved
FROM volunteers v
JOIN pickups p        ON p.volunteer_id = v.volunteer_id
JOIN distributions ds ON ds.pickup_id = p.pickup_id
GROUP BY v.volunteer_id, v.volunteer_name
ORDER BY meals_moved DESC;
-- Q21: Overall platform efficiency score.
SELECT
    (SELECT SUM(servings) FROM food_listings) AS total_servings_offered,
    (SELECT COALESCE(SUM(meals_served),0) FROM distributions) AS total_meals_served,
    ROUND(
        (SELECT COALESCE(SUM(meals_served),0) FROM distributions) /
        NULLIF((SELECT SUM(servings) FROM food_listings),0) * 100, 2
    ) AS efficiency_pct;
-- ==================================================================================
-- END of the Project
-- =====================================================================================

/*
Project Details
-- Capstone Project: The Murder Mystery - "Who Killed the CEO"
-- 21 Days SQL Challenge Final Submission
-- By IDC & DPDzero 
-- Dataset: The Digital Evidence Logs: employee, keycard_logs, 
   calls, albis, evidence & table_creation_syntax.sql
-- Skills:  Aggregations, Joins, Subqueries, CTEs
-- Penned By: Himasprabh S

N.B. For the detail explanation, please visit my Linkedin Featured section.
*/


/*
Contents
--------
-- Database Preparation
-- Investigation Steps
	-> Step-1
    -> Step-2
    -> Step-3
    -> Step-4
    -> Step-5
    -> Step-6
-- The Findings
*/







/*Database Preparation*/
-----------------------------------------------------------------------
-- DROP TABLES if exist
DROP TABLE IF EXISTS employees, keycard_logs, calls, alibis, evidence;

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer

-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');



/*Step-1*/
/*Q1. Identify **where** and **when** the crime happened*/
-----------------------------------------------------------------

SELECT *
FROM keycard_logs
WHERE room = 'CEO Office'
AND entry_time BETWEEN '2025-10-15 20:50:00'
				 AND '2025-10-15 21:15:00';
                 
                 

 /*
 Fact given: The CEO of TechNova Inc. has been found dead in 
 their office on October 15, 2025, at 9:00 PM.
 */      
 
 
/*
Looking for the suspect, who has entered the CEO’s office around 
the murder time (15 Oct 2025, 9 PM) #keycard_logs
*/


/*
Step 1: findings 
-- Crime happened at the CEO office at 9 PM
-- B/W 8:50PM to 9PM suspect employee_id ‘4’ was present there
*/		
        

 /*
 So, I will use the ‘WHERE’ clause to tell the database ‘Exactly where to look? & 
 will give at most 25 mins time frame to find the suspect
 */
        
        
        
        
/*Step-2*/        
/*Q2. Analyze **who** accessed critical areas at the time*/
-----------------------------------------------------------------
SELECT e.employee_id, e.name, e.department, e.role,
       k.entry_time, k.exit_time
FROM keycard_logs k
JOIN employees e ON k.employee_id = e.employee_id
WHERE k.room = 'CEO Office'
	 AND k.entry_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:10:00'
ORDER BY k.entry_time;



/*Step-3*/
/*3. Cross-check **alibis** with actual logs*/

SELECT a.employee_id, e.name, a.claimed_location, a.claim_time,
	   k.room AS actual_room, k.entry_time
FROM alibis a
JOIN
employees e ON a.employee_id = e.employee_id
LEFT JOIN
keycard_logs k ON a.employee_id = k.employee_id
              AND a.claim_time BETWEEN k.entry_time AND k.exit_time;
 






/*Step-4*/
/*Q4. Investigate **suspicious calls** made around the time*/

SELECT c.call_id, c.caller_id, c.receiver_id, c.call_time, c.duration_sec,
      e1.name AS caller_name,
      e2.name AS receiver_name
FROM calls c
JOIN employees e1 ON c.caller_id = e1.employee_id
JOIN employees e2 ON c.receiver_id = e2.employee_id
WHERE
    c.call_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:00:00'
ORDER BY c.call_time;



/*Step-5*/
/*Q5. **Match** --evidence with --movements and claims*/

SELECT 	e.*, k.employee_id, es.name,  
		k.log_id,  k.entry_time,  k.exit_time,  
		a.claim_time, a.claimed_location 
FROM evidence e 
LEFT JOIN keycard_logs k 
	ON e.room = k.room 
LEFT JOIN employees es 
	ON k.employee_id = es.employee_id 
LEFT JOIN alibis a 
	ON k.employee_id = a.employee_id 
WHERE e.found_time BETWEEN k.entry_time 
and date_add(k.exit_time, interval 20 minute);


/*Step-6*/
/*Q.6. Combine all findings to identify the killer*/

WITH suspect_access AS (
    SELECT DISTINCT employee_id
    FROM keycard_logs
    WHERE room = 'CEO Office'
      AND entry_time BETWEEN '2025-10-15 20:50:00'
                         AND '2025-10-15 21:10:00'
),
invalid_alibis AS (
    SELECT DISTINCT a.employee_id
    FROM alibis a
    LEFT JOIN keycard_logs k
      ON a.employee_id = k.employee_id
     AND a.claim_time BETWEEN k.entry_time AND k.exit_time
    WHERE a.claim_time BETWEEN '2025-10-15 20:00:00'
                           AND '2025-10-15 22:00:00'
      AND (k.room IS NULL OR k.room <> a.claimed_location)
),
suspicious_calls AS (
    SELECT DISTINCT caller_id AS employee_id
    FROM calls
    WHERE call_time BETWEEN '2025-10-15 20:50:00'
                        AND '2025-10-15 21:00:00'
)
SELECT e.name AS killer
FROM employees e
WHERE e.employee_id IN (SELECT employee_id FROM suspect_access)
  AND e.employee_id IN (SELECT employee_id FROM invalid_alibis)
  AND e.employee_id IN (SELECT employee_id FROM suspicious_calls);
  
  
  
  
  
/*
suspect_access
→ People who were in the CEO's office during the crime window.
invalid_alibis
→ People whose alibi does not match system logs.
suspicious_calls 
→ People who made calls minutes before the crime.

And The employee who meets all criteria is the killer.
And He is non other than the suspect ‘David Kumar’ found Guilty
*/


/*The Findings*/
/*
It is found that
--	Step 1 : Crime happened at the CEO office at 9 PM
	B/W 8:50PM to 9PM suspect employee_id ‘4’ was present there
-- 	Step 2 Now here it is clear that the suspect employee_id ‘4’ 
	name is ‘David Kumar’
-- 	Step 3 This next investigation revels that, David Kumar 
	is lying about his presence in a location ‘server room’, 
	which mismatches with the actual database. Actual data says 
	he entered the ‘CEO office’ at 8:50 PM
--	Step 4 This investigation tells that, there was a suspicious call of 
	45 secs of  conversation. just 5 min before the CEO found dead. 
    And the caller name found to be ‘David kumar’ 
-- 	Step 5 Here we found that Evidence in CEO room was found 9:05 Pm & 
	another 9:10 pm. And around the same time the suspect movement 
    was recorded during 8:50 to 9:00 PM .Means the suspect was present 
    during that time

--	Then I build the Query around 3 Questions
	suspect_access → People who were in the CEO's office 
    during the crime window.
	invalid_alibis  → People whose alibi does not match system logs.
	suspicious_calls  → People who made calls minutes before the crime.

And The employee who meets all criteria is the killer.
And He is non other than the suspect ‘David Kumar’ found Guilty
*/




















































































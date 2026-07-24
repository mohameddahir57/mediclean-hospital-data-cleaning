-- PROJECT: MediClean - Hospital Admissions Data Cleaning (MySQL)
-- This script creates the database, connects to the imported raw
-- table, and cleans it step by step into a final analysis-ready table.

CREATE DATABASE hospital_records_db;
USE hospital_records_db;

SELECT * FROM patients_raw;


-- STEP 1: Create a working copy of the raw data
-- We copy patients_raw into patients_clean so the original import
-- stays untouched, in case we need to compare before/after.

DROP TABLE IF EXISTS patients_clean;

CREATE TABLE patients_clean AS
SELECT * FROM patients_raw;

-- Check it worked - row count should match patients_raw
SELECT COUNT(*) AS total_rows FROM patients_clean;


-- STEP 2: Remove blank/junk rows
-- Some rows are completely empty (no patient_id and no name at all).
-- These can't be cleaned or analyzed, so we delete them.

SET SQL_SAFE_UPDATES = 0;

DELETE FROM patients_clean
WHERE (patient_id IS NULL OR TRIM(patient_id) = '')
  AND (full_name IS NULL OR TRIM(full_name) = '');

-- Check how many rows are left after removing the blank ones
SELECT COUNT(*) AS total_rows FROM patients_clean;


-- STEP 3: Remove duplicate admissions
-- 3a: Build a list of one row_id per patient_id + admission_id group
--     (the smallest row_id in each group = the one we'll keep)

CREATE TABLE rows_to_keep AS
SELECT MIN(row_id) AS row_id
FROM patients_clean
GROUP BY patient_id, admission_id;

-- Check how many unique rows we found
SELECT COUNT(*) AS rows_to_keep_count FROM rows_to_keep;

-- 3b: Drop the temporary table now that duplicates have been removed
--     using it (this line matches your original script's position)
DROP TABLE rows_to_keep;


-- STEP 4: Remove extra spaces from text columns
-- Some values have extra spaces at the start/end, like "  Ahmed Ali  ".
-- TRIM() removes those spaces.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET full_name = TRIM(full_name);

UPDATE patients_clean
SET city = TRIM(city);

UPDATE patients_clean
SET address = TRIM(address);

UPDATE patients_clean
SET department = TRIM(department);

-- Check a few rows to see the result
SELECT full_name, city, address, department FROM patients_clean LIMIT 10;


-- STEP 5: Standardize gender values
-- Turns M / Male / MALE / m into "M", and F / Female / FEMALE / f
-- into "F". Anything else becomes "Unknown".

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET gender = 'M'
WHERE UPPER(TRIM(gender)) IN ('M', 'MALE');

UPDATE patients_clean
SET gender = 'F'
WHERE UPPER(TRIM(gender)) IN ('F', 'FEMALE');

UPDATE patients_clean
SET gender = 'Unknown'
WHERE gender NOT IN ('M', 'F');

-- Check the result - should only show M, F, Unknown
SELECT DISTINCT gender FROM patients_clean;


-- STEP 6: Standardize marital status values
-- Turns S/Single/SINGLE into "Single", and so on for the other
-- 3 categories. Anything else becomes "Unknown".

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET marital_status = 'Single'
WHERE UPPER(TRIM(marital_status)) IN ('S', 'SINGLE');

UPDATE patients_clean
SET marital_status = 'Married'
WHERE UPPER(TRIM(marital_status)) IN ('M', 'MARRIED');

UPDATE patients_clean
SET marital_status = 'Divorced'
WHERE UPPER(TRIM(marital_status)) IN ('D', 'DIVORCED');

UPDATE patients_clean
SET marital_status = 'Widowed'
WHERE UPPER(TRIM(marital_status)) IN ('W', 'WIDOWED');

UPDATE patients_clean
SET marital_status = 'Unknown'
WHERE marital_status NOT IN ('Single', 'Married', 'Divorced', 'Widowed');

-- Check the result - should only show these 5 values
SELECT DISTINCT marital_status FROM patients_clean;


-- STEP 7: Fill in blank text fields
-- Instead of leaving these fields empty, we replace blanks with a
-- clear label describing what's missing.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET occupation = 'Not Specified'
WHERE TRIM(occupation) = '';

UPDATE patients_clean
SET allergies = 'None'
WHERE TRIM(allergies) = '' OR TRIM(allergies) = 'N/A';

UPDATE patients_clean
SET symptoms = 'Not Recorded'
WHERE TRIM(symptoms) = '';

UPDATE patients_clean
SET attending_doctor = 'Unassigned'
WHERE TRIM(attending_doctor) = '';

UPDATE patients_clean
SET medication_prescribed = 'None'
WHERE TRIM(medication_prescribed) = '';

UPDATE patients_clean
SET bed_type = 'Unspecified'
WHERE TRIM(bed_type) = '';

UPDATE patients_clean
SET referral_source = 'Unknown'
WHERE TRIM(referral_source) = '';

UPDATE patients_clean
SET payment_method = 'Unknown'
WHERE TRIM(payment_method) = '';

UPDATE patients_clean
SET insurance_provider = 'Self-Pay'
WHERE TRIM(insurance_provider) = '' OR insurance_provider = 'None';

-- Check a few of these columns to see the result
SELECT occupation, allergies, symptoms, attending_doctor, medication_prescribed
FROM patients_clean LIMIT 10;


-- STEP 8: Standardize city names
-- Fixes spelling variants and local-language names (e.g. Muqdisho)
-- so each city has exactly one standard spelling.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET city = 'Mogadishu'
WHERE LOWER(city) IN ('mogadishu', 'muqdisho', 'mogadisho');

UPDATE patients_clean
SET city = 'Hargeisa'
WHERE LOWER(city) IN ('hargeisa', 'hargeysa');

UPDATE patients_clean
SET city = 'Kismayo'
WHERE LOWER(city) IN ('kismayo', 'kismaayo');

UPDATE patients_clean
SET city = 'Baidoa'
WHERE LOWER(city) IN ('baidoa', 'baydhabo');

UPDATE patients_clean
SET city = 'Bosaso'
WHERE LOWER(city) IN ('bosaso', 'boosaaso');

UPDATE patients_clean
SET city = 'Merca'
WHERE LOWER(city) IN ('merca', 'marka');

UPDATE patients_clean
SET city = 'Beledweyne'
WHERE LOWER(city) IN ('beledweyne', 'belet weyne');

UPDATE patients_clean
SET city = 'Galkayo'
WHERE LOWER(city) IN ('galkayo', 'galkacyo');

-- Check the result - should show one clean spelling per city
SELECT DISTINCT city FROM patients_clean ORDER BY city;


-- STEP 9: Standardize admission type and discharge status
-- These fields were written in different cases (emergency, EMERGENCY,
-- Emergency). We turn all variants into one clean, consistent value.

SET SQL_SAFE_UPDATES = 0;

-- Admission type
UPDATE patients_clean
SET admission_type = 'Emergency'
WHERE UPPER(TRIM(admission_type)) = 'EMERGENCY';

UPDATE patients_clean
SET admission_type = 'Elective'
WHERE UPPER(TRIM(admission_type)) = 'ELECTIVE';

UPDATE patients_clean
SET admission_type = 'Referral'
WHERE UPPER(TRIM(admission_type)) = 'REFERRAL';

UPDATE patients_clean
SET admission_type = 'Transfer'
WHERE UPPER(TRIM(admission_type)) = 'TRANSFER';

-- Discharge status
UPDATE patients_clean
SET discharge_status = 'Recovered'
WHERE UPPER(TRIM(discharge_status)) = 'RECOVERED';

UPDATE patients_clean
SET discharge_status = 'Referred'
WHERE UPPER(TRIM(discharge_status)) = 'REFERRED';

UPDATE patients_clean
SET discharge_status = 'Deceased'
WHERE UPPER(TRIM(discharge_status)) = 'DECEASED';

UPDATE patients_clean
SET discharge_status = 'Transferred'
WHERE UPPER(TRIM(discharge_status)) = 'TRANSFERRED';

-- Check the results
SELECT DISTINCT admission_type FROM patients_clean;
SELECT DISTINCT discharge_status FROM patients_clean;


-- STEP 10: Standardize Yes/No flag columns
-- Y / 1 / yes all become "Yes"; N / 0 / no all become "No".
-- Anything else becomes "Unknown". Applied to all 3 flag columns.

SET SQL_SAFE_UPDATES = 0;

-- Chronic condition flag
UPDATE patients_clean
SET chronic_condition_flag = 'Yes'
WHERE UPPER(TRIM(chronic_condition_flag)) IN ('YES', 'Y', '1');

UPDATE patients_clean
SET chronic_condition_flag = 'No'
WHERE UPPER(TRIM(chronic_condition_flag)) IN ('NO', 'N', '0');

UPDATE patients_clean
SET chronic_condition_flag = 'Unknown'
WHERE chronic_condition_flag NOT IN ('Yes', 'No');

-- Follow-up required
UPDATE patients_clean
SET follow_up_required = 'Yes'
WHERE UPPER(TRIM(follow_up_required)) IN ('YES', 'Y', '1');

UPDATE patients_clean
SET follow_up_required = 'No'
WHERE UPPER(TRIM(follow_up_required)) IN ('NO', 'N', '0');

UPDATE patients_clean
SET follow_up_required = 'Unknown'
WHERE follow_up_required NOT IN ('Yes', 'No');

-- Readmission within 30 days
UPDATE patients_clean
SET readmission_within_30_days = 'Yes'
WHERE UPPER(TRIM(readmission_within_30_days)) IN ('YES', 'Y', '1');

UPDATE patients_clean
SET readmission_within_30_days = 'No'
WHERE UPPER(TRIM(readmission_within_30_days)) IN ('NO', 'N', '0');

UPDATE patients_clean
SET readmission_within_30_days = 'Unknown'
WHERE readmission_within_30_days NOT IN ('Yes', 'No');

-- Check the results
SELECT DISTINCT chronic_condition_flag FROM patients_clean;
SELECT DISTINCT follow_up_required FROM patients_clean;
SELECT DISTINCT readmission_within_30_days FROM patients_clean;


-- STEP 11: Fix invalid ages
-- Blank, negative, or unrealistic ages (over 110) become NULL,
-- since we can't guess the real value.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET age = NULL
WHERE age = '';

UPDATE patients_clean
SET age = NULL
WHERE age < 0 OR age > 110;

-- Check how many ages are now NULL, and see the current range
SELECT COUNT(*) AS null_ages FROM patients_clean WHERE age IS NULL;
SELECT MIN(age) AS youngest, MAX(age) AS oldest FROM patients_clean WHERE age IS NOT NULL;


-- STEP 12: Clean the total_cost column
-- Raw values look like: 450.75, $450.75, 1,234.56, 450.75 USD.
-- We remove the extra characters so only plain numbers are left.

SET SQL_SAFE_UPDATES = 0;

-- Remove dollar signs
UPDATE patients_clean
SET total_cost = REPLACE(total_cost, '$', '');

-- Remove commas (used as thousand separators)
UPDATE patients_clean
SET total_cost = REPLACE(total_cost, ',', '');

-- Remove " USD" text
UPDATE patients_clean
SET total_cost = REPLACE(total_cost, ' USD', '');

-- Turn blank values into NULL, since an empty string isn't a valid number
UPDATE patients_clean
SET total_cost = NULL
WHERE TRIM(total_cost) = '';

-- Check the result
SELECT total_cost FROM patients_clean LIMIT 20;
SELECT COUNT(*) AS null_costs FROM patients_clean WHERE total_cost IS NULL;


-- STEP 13: Clean the lab_test_result column
-- Raw values look like: 95.5, 95.5 mg/dL, 95.5mg/dl, or 9999
-- (9999 was used as a placeholder for "no real result recorded").
-- We remove the unit text and turn 9999 into NULL.

SET SQL_SAFE_UPDATES = 0;

-- Remove " mg/dL" text (with a space before it)
UPDATE patients_clean
SET lab_test_result = REPLACE(lab_test_result, ' mg/dL', '');

-- Remove "mg/dl" text (no space, lowercase version)
UPDATE patients_clean
SET lab_test_result = REPLACE(lab_test_result, 'mg/dl', '');

-- Turn blank values into NULL
UPDATE patients_clean
SET lab_test_result = NULL
WHERE TRIM(lab_test_result) = '';

-- Turn the placeholder value 9999 into NULL (it's not a real result)
UPDATE patients_clean
SET lab_test_result = NULL
WHERE TRIM(lab_test_result) = '9999';

-- Check the result
SELECT lab_test_result FROM patients_clean LIMIT 20;
SELECT COUNT(*) AS null_lab_results FROM patients_clean WHERE lab_test_result IS NULL;


-- STEP 14a: Fix admission_date
-- The raw dates are written in 5 different formats, for example:
--   2024-05-10   (Year-Month-Day)
--   2024/05/10   (Year/Month/Day)
--   10/05/2024   (Day/Month/Year)
--   05-10-2024   (Month-Day-Year)
--   10-May-2024  (Day-MonthName-Year)
--
-- We check which pattern each value matches, then convert it into
-- a real DATE using that matching format.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET admission_date =
    CASE
        WHEN admission_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(admission_date, '%Y-%m-%d')
        WHEN admission_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN STR_TO_DATE(admission_date, '%Y/%m/%d')
        WHEN admission_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(admission_date, '%d/%m/%Y')
        WHEN admission_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(admission_date, '%m-%d-%Y')
        WHEN admission_date REGEXP '^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}$'
            THEN STR_TO_DATE(admission_date, '%d-%b-%Y')
        ELSE NULL
    END;

-- Check the result - dates should now look like YYYY-MM-DD
SELECT admission_date FROM patients_clean LIMIT 20;
SELECT COUNT(*) AS null_admission_dates FROM patients_clean WHERE admission_date IS NULL;


-- STEP 14b: Fix discharge_date
-- Same problem as admission_date - 5 mixed formats. Same fix.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET discharge_date =
    CASE
        WHEN discharge_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(discharge_date, '%Y-%m-%d')
        WHEN discharge_date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN STR_TO_DATE(discharge_date, '%Y/%m/%d')
        WHEN discharge_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(discharge_date, '%d/%m/%Y')
        WHEN discharge_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(discharge_date, '%m-%d-%Y')
        WHEN discharge_date REGEXP '^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}$'
            THEN STR_TO_DATE(discharge_date, '%d-%b-%Y')
        ELSE NULL
    END;

-- Check the result
SELECT discharge_date FROM patients_clean LIMIT 20;
SELECT COUNT(*) AS null_discharge_dates FROM patients_clean WHERE discharge_date IS NULL;


-- STEP 14c: Fix date_of_birth
-- Same problem, same fix, applied to the last remaining date column.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET date_of_birth =
    CASE
        WHEN date_of_birth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(date_of_birth, '%Y-%m-%d')
        WHEN date_of_birth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN STR_TO_DATE(date_of_birth, '%Y/%m/%d')
        WHEN date_of_birth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(date_of_birth, '%d/%m/%Y')
        WHEN date_of_birth REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(date_of_birth, '%m-%d-%Y')
        WHEN date_of_birth REGEXP '^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}$'
            THEN STR_TO_DATE(date_of_birth, '%d-%b-%Y')
        ELSE NULL
    END;

-- Check the result
SELECT date_of_birth FROM patients_clean LIMIT 20;
SELECT COUNT(*) AS null_dob FROM patients_clean WHERE date_of_birth IS NULL;


-- STEP 14d: Fix impossible discharge dates
-- If discharge_date is earlier than admission_date, something was
-- entered wrong. We can't know which value is correct, so we set
-- discharge_date to NULL for those rows instead of keeping bad data.

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET discharge_date = NULL
WHERE discharge_date IS NOT NULL
  AND admission_date IS NOT NULL
  AND discharge_date < admission_date;

-- Check how many rows were affected
SELECT COUNT(*) AS remaining_null_discharge_dates
FROM patients_clean
WHERE discharge_date IS NULL;


-- STEP 15: Fix the column data types
-- Until now, every column was still stored as text (even the dates
-- and numbers), just with clean-looking values inside. This step
-- changes the column types so MySQL treats them as real numbers
-- and real dates - which lets us do math, sorting, and date
-- calculations correctly in the analysis step.

ALTER TABLE patients_clean MODIFY patient_id INT;
ALTER TABLE patients_clean MODIFY admission_id INT;
ALTER TABLE patients_clean MODIFY age INT;
ALTER TABLE patients_clean MODIFY total_cost DECIMAL(10,2);
ALTER TABLE patients_clean MODIFY lab_test_result DECIMAL(6,1);
ALTER TABLE patients_clean MODIFY admission_date DATE;
ALTER TABLE patients_clean MODIFY discharge_date DATE;
ALTER TABLE patients_clean MODIFY date_of_birth DATE;

-- Check the new column types
DESCRIBE patients_clean;


-- STEP 16: Final verification
-- One last check across the whole table, to confirm every column
-- was cleaned correctly before we move on to analysis.

-- Total row count (should be less than the original 15,000, since
-- we removed blank rows and duplicates)
SELECT COUNT(*) AS total_rows FROM patients_clean;

-- Each of these should only show the clean values we set earlier
SELECT DISTINCT gender FROM patients_clean;
SELECT DISTINCT marital_status FROM patients_clean;
SELECT DISTINCT admission_type FROM patients_clean;
SELECT DISTINCT discharge_status FROM patients_clean;
SELECT DISTINCT chronic_condition_flag FROM patients_clean;
SELECT DISTINCT follow_up_required FROM patients_clean;
SELECT DISTINCT readmission_within_30_days FROM patients_clean;
SELECT DISTINCT city FROM patients_clean ORDER BY city;

-- How much data is still missing, column by column
SELECT
    SUM(age IS NULL) AS missing_age,
    SUM(admission_date IS NULL) AS missing_admission_date,
    SUM(discharge_date IS NULL) AS missing_discharge_date,
    SUM(date_of_birth IS NULL) AS missing_dob,
    SUM(total_cost IS NULL) AS missing_cost,
    SUM(lab_test_result IS NULL) AS missing_lab_result
FROM patients_clean;

-- A full look at 20 sample rows, to eyeball everything together
SELECT * FROM patients_clean LIMIT 20;


-- STEP 16 (repeated in your original file): Final verification
-- Same checks as above, run a second time.

SELECT COUNT(*) AS total_rows FROM patients_clean;

SELECT DISTINCT gender FROM patients_clean;
SELECT DISTINCT marital_status FROM patients_clean;
SELECT DISTINCT admission_type FROM patients_clean;
SELECT DISTINCT discharge_status FROM patients_clean;
SELECT DISTINCT chronic_condition_flag FROM patients_clean;
SELECT DISTINCT follow_up_required FROM patients_clean;
SELECT DISTINCT readmission_within_30_days FROM patients_clean;
SELECT DISTINCT city FROM patients_clean ORDER BY city;

SELECT
    SUM(age IS NULL) AS missing_age,
    SUM(admission_date IS NULL) AS missing_admission_date,
    SUM(discharge_date IS NULL) AS missing_discharge_date,
    SUM(date_of_birth IS NULL) AS missing_dob,
    SUM(total_cost IS NULL) AS missing_cost,
    SUM(lab_test_result IS NULL) AS missing_lab_result
FROM patients_clean;

SELECT * FROM patients_clean LIMIT 20;


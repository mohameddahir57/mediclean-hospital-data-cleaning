# MediClean: Hospital Admissions Data Cleaning & Analysis

A MySQL data-cleaning and analysis project built on a large, deliberately messy hospital admissions dataset created to practice and demonstrate real-world data cleaning skills using SQL.

## Project Background

Raw, real-world data is almost never ready to analyze straight out of the box. Hospitals, businesses, and organizations collect information from many sources forms, walk-in registration, different staff entering data in different formats and the result is usually inconsistent, incomplete, and full of small errors that can quietly distort any analysis built on top of it.

This project simulates that exact situation. Instead of using an already-clean dataset, I built a synthetic hospital admissions dataset of 15,000 patient records across 39 columns, deliberately loaded with the kinds of problems real hospital data actually has: inconsistent formatting, mixed date formats, typos, duplicate records, missing values, and invalid entries. The goal was to take that raw dataset from unusable to analysis-ready using nothing but SQL, and to document the process clearly enough that anyone reviewing it can follow exactly what was wrong and how it was fixed.

## Project Goal

- Practice and demonstrate a complete data-cleaning workflow in MySQL, from raw import to a clean, typed, analysis-ready table
- Build a portfolio piece that reflects the kind of messy data actually encountered in real analytics work, not a dataset that was already clean
- Provide an open, unclean dataset so other learners can practice their own cleaning process on the same data
- Turn the cleaned data into meaningful insights (patient trends, cost patterns, diagnosis frequency, and more)

## Dataset

The dataset represents hospital admission records and includes patient demographics, admission and discharge details, clinical information, billing/insurance data, and outcomes 15,000 rows across 39 columns in total.

It covers areas such as:

- **Patient demographics** name, gender, date of birth, age, marital status, occupation, contact details
- **Location** city, region, address, postal code
- **Clinical information** blood type, chronic condition status, smoker status, allergies, symptoms
- **Admission details** admission type, referral source, ward, room, bed type
- **Care team** department, attending doctor
- **Diagnosis & treatment** diagnosis, diagnosis code, medication prescribed
- **Lab results** a recorded lab test value
- **Billing & insurance** insurance provider, insurance status, payment method, total cost
- **Outcome** discharge status, follow-up requirement, readmission within 30 days

The raw, unclean version of this dataset is included in this repository so that anyone can attempt their own cleaning process on the same data before comparing it against the approach used here.

## Problems Found in the Raw Data

The raw dataset was intentionally built with the following issues, which is what the cleaning process worked through:

- Inconsistent capitalization and spacing across nearly every text column (e.g. gender written as `M`, `Male`, `MALE`, `m`, or left blank)
- City names with spelling and language variants (e.g. local names alongside standard spellings)
- Five different date formats mixed within the same date columns
- Cost values mixed with currency symbols, commas, and unit text
- Lab result values mixed with unit text, plus a placeholder value used to represent missing results
- Invalid or impossible ages (negative numbers, unrealistically high values)
- Fully duplicated admission records
- Completely blank rows
- Admission and discharge dates that were logically impossible (a discharge date earlier than the admission date)
- Missing values scattered across nearly every column, with no consistent way of marking "unknown"

## What Was Cleaned

The cleaning process worked through the dataset systematically, one issue at a time, rather than attempting to fix everything in a single step. In summary, the process:

1. Created a working copy of the raw data so the original import was never modified directly
2. Removed blank and duplicate records
3. Standardized formatting across all text fields (removing extra spaces, fixing inconsistent capitalization)
4. Standardized every categorical field (gender, marital status, admission type, discharge status, and all Yes/No style fields) down to a single consistent set of values
5. Replaced blank fields with clear, explicit labels instead of leaving them empty
6. Standardized city names to a single spelling per city
7. Corrected invalid age values
8. Cleaned currency and unit text out of the cost and lab result columns and converted them into real numeric values
9. Detected and corrected all five mixed date formats across every date column
10. Identified and corrected logically impossible date combinations
11. Converted every column from raw text into its proper data type (numbers, decimals, and dates)
12. Ran a full verification pass to confirm the cleaned table was consistent and ready for analysis

The full step-by-step SQL used to perform this cleaning is available in this repository for anyone who wants to see the exact logic behind each fix.

## Tools Used

- **MySQL** / **MySQL Workbench** database creation, data cleaning, and querying
- **Excel** source format for the raw dataset

## Repository Structure

```
├── README.md
├── hospital_admissions_raw_dirty.xlsx    (the unclean source dataset)
├── data_cleaning.sql                      (full step-by-step cleaning script)
├── analysis_queries.sql                   (queries used to generate insights)
```

## Key Insights

*(To be added once the analysis stage is complete patient trends by city, most common diagnoses, average length of stay, cost patterns, and outcome breakdowns.)*

## Limitations

- Some records had a mismatch between the recorded age and the recorded date of birth. Since it isn't possible to know which of the two values was entered correctly, both were left as-is rather than guessing a limitation worth noting rather than silently resolving.
- Some fields (such as missing lab results or missing costs) were converted to NULL rather than estimated, since inventing values would misrepresent the data rather than clean it.

## About This Project

This project was built as a personal portfolio piece to practice real-world SQL data cleaning at scale. The unclean dataset is included intentionally, so that anyone reviewing this repository is welcome to attempt their own cleaning approach on the same data before comparing it with the process documented here.

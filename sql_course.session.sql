CREATE TABLE job_applied(
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);
SELECT *
FROM job_applied;

INSERT INTO job_applied
            (job_id,
            application_sent_date,
            custom_resume,
            resume_file_name,
            cover_letter_sent,
            cover_letter_file_name,
            status)
    VALUES
            (1,
            '2024-02-01',
            true,
            'resume_01.pdf',
            true,
            'cover_letter_01.pdf',
            'submitted'),
            (2,
            '2024-02-02',
            false,
            'resume_02.pdf',
            false,
            NULL,
            'interview scheduled'),
            (3,
            '2024-02-03',
            true,
            'resume_03.pdf',
            true,
            'cover_letter_03.pdf',
            'ghosted'),
            (4,
            '2024-02-04',
            true,
            'resume_04.pdf',
            false,
            NULL,
            'submitted'),
            (5,
            '2024-02-05',
            false,
            'resume_05.pdf',
            true,
            'cover_letter_05.pdf',
            'rejected');

ALTER TABLE job_applied
ADD contact varchar(50);

UPDATE job_applied 
SET contact = 'Erlich Bachman'
WHERE job_id = 1;

UPDATE job_applied
SET contact = 'Dinesh Chugtai'
WHERE job_id = 2;

UPDATE job_applied
SET contact = 'Bertram Gilfoyle'
WHERE job_id = 3;

UPDATE job_applied
SET contact = 'Jian Yang'
WHERE job_id = 4;

UPDATE job_applied
SET contact = 'Big Head'
WHERE job_id = 5;

ALTER TABLE job_applied
RENAME COLUMN contact to contact_name;

ALTER Table job_applied
ALTER COLUMN contact_name type text;

ALTER TABLE job_applied
DROP COLUMN contact_name;

DROP Table job_applied;









SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date ::Date AS date
FROM 
    job_postings_fact
LIMIT 100;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS time_zone
FROM 
    job_postings_fact
LIMIT 100;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS time_zone,
    EXTRACT(MONTH FROM job_posted_date) AS Month,
    EXTRACT(YEAR FROM job_posted_date) AS Year
FROM 
    job_postings_fact
LIMIT 100;

SELECT
    COUNT(job_id) AS Job_count,
    EXTRACT(MONTH FROM job_posted_date) AS Month
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY 
    MONTH
ORDER BY 
    Job_count DESC
    ;

-- P1 
SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS S_Y_AVG,
    AVG(salary_hour_avg) AS S_H_AVG
FROM 
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY 
    job_schedule_type
    ;


-- P2
SELECT
    COUNT(job_id) AS Job_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS Month
FROM 
    job_postings_fact
WHERE
    job_posted_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    Month
ORDER BY
    MONTH
    ;


-- P3
SELECT
    job_id,
    EXTRACT(MONTH FROM job_posted_date) AS Month,
    job_postings_fact.company_id,
    name
FROM 
    job_postings_fact, company_dim
WHERE
    job_posted_date BETWEEN '2023-04-01' AND '2023-06-30' AND
    job_health_insurance IS TRUE
LIMIT 100
    ;


-- P6
CREATE TABLE January_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH From job_posted_date) = 1
;

CREATE TABLE February_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH From job_posted_date) = 2
;

CREATE TABLE March_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH From job_posted_date) = 3
;
SELECT * 
FROM March_jobs;




SELECT 
    COUNT(job_id) AS NO_of_jobs,
    CASE 
        WHEN job_location = 'New York, NY' THEN 'Local'
        WHEN job_location = 'Anywhere' THEN 'Remote'  
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    location_category
;


-- P1 Case
SELECT 
    COUNT(job_id) AS NO_of_jobs,
    CASE 
        WHEN salary_year_avg >= 120000 THEN 'High'
        WHEN salary_year_avg < 120000 AND salary_year_avg >= 90000 THEN 'Mid'  
        WHEN salary_year_avg < 90000 THEN 'Low'  
        ELSE 'Not Specified'
    END AS salary_category
FROM job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    salary_category
ORDER BY
    salary_category DESC
;



-- P1 subqueries
SELECT
    skills_job_dim.skill_id,
    skills_dim.skills
FROM skills_job_dim
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE skills_job_dim.skill_id IN (
    SELECT
        skill_id
    FROM
        skills_job_dim
    GROUP BY
        skill_id
    ORDER BY COUNT(skills_job_dim.job_id) DESC
    LIMIT 5
)
GROUP BY skills_job_dim.skill_id, skills_dim.skills

-- P2 CTE
With CTE AS(
    SELECT
        job_postings_fact.company_id,
        company_dim.name,
        COUNT(job_postings_fact.job_id) AS volume,
        CASE  
            WHEN COUNT(job_postings_fact.job_id) < 10 THEN 'Small'
            WHEN COUNT(job_postings_fact.job_id) >= 10 AND COUNT(job_postings_fact.job_id) <= 50 THEN 'Medium'
            WHEN COUNT(job_postings_fact.job_id) > 50 THEN 'Large'
            Else 'Not Specified'
        END AS Category
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    GROUP BY company_dim.name, job_postings_fact.company_id
    ORDER BY volume DESC
)

SELECT * 
FROM CTE



-- P8 Union
SELECT 
    q1_jobs.job_id,
    q1_jobs.job_title_short,
    q1_jobs.job_posted_date::DATE,
    q1_jobs.salary_year_avg
FROM (
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT * 
    FROM march_jobs
) AS q1_jobs
WHERE 
    q1_jobs.salary_year_avg > 70000 AND
    q1_jobs.job_title_short = 'Data Analyst'
ORDER BY q1_jobs.salary_year_avg DESC
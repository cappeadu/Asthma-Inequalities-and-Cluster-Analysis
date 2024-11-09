--STUDY YEAR IS FROM 2018-01-01 TO 2023-12-31
--CREATING A TABLE TO POPULATE DEMOGRAPHICS & CLINICAL VARIABLES OF PATIENTS
--DROP TABLE COHORT_SELECTION --DROP THIS TABLE IF ANY

CREATE TABLE COHORT_SELECTION (
ALF_PE NVARCHAR(10) DEFAULT 0,
GNDR_CD INT DEFAULT 0,
BMI DECIMAL(10,1) DEFAULT 0,
SMK_STATUS NVARCHAR(5) DEFAULT 0,
ASTHMA_GP_VISITS INT DEFAULT 0,
TOTAL_ASTHMA_HOSP INT DEFAULT 0,
EMER_ADM_LAST_12M INT DEFAULT 0,
EMER_ADM_BEFORE_LAST_12M INT DEFAULT 0,
ASTHMA_EXACERBATIONS INT DEFAULT 0,
ASTHMA_REVIEWS INT DEFAULT 0,
ASTHMA_OUTPATIENT_APPO INT DEFAULT 0,
ASTHMA_RE_ADMISSIONS INT DEFAULT 0,
TOTAL_PRESCRIPTIONS INT DEFAULT 0,
FIRST_ADMISSION_WITHIN_STUDY_YEARS INT DEFAULT 0
)


--SELECTING UNIQUE PATIENT IDs FROM GP REGISTRY TABLE AND POPULATING COHORT_SELECTION TABLE
INSERT INTO COHORT_SELECTION(ALF_PE) 
SELECT DISTINCT ALF_PE
FROM WLGP_CLEAN_GP_REG_MEDIAN
WHERE ALF_PE IS NOT NULL
ORDER BY ALF_PE

--SELECT ALF_PE, EVENT_DT
--FROM GP_EVENT_CODES EC
--JOIN GP_EVENT_REFORMATTED AS ER
--ON EC.EVENT_CD_ID = ER.EVENT_CD_ID



--POPULATE GENDER, BMI, SMK STATUS INTO COHORT SELECTION TABLE
MERGE COHORT_SELECTION A USING (
SELECT AR.ALF_PE, 
	   AR.GNDR_CD, 
	   AR.bmi AS BMI, 
	   smk_sta AS SMK_STATUS
FROM AR_PERS AR
JOIN COHORT_SELECTION AS C
ON C.ALF_PE = AR.ALF_PE
WHERE AR.ALF_PE IS NOT NULL
) AS B
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.GNDR_CD = B.GNDR_CD, 
		   A.BMI = B.BMI,
		   A.SMK_STATUS = B.SMK_STATUS;

---------FIRST_ADMISSION_WITHIN_STUDY_YEARS-----------
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	  MIN(YEAR(EVENT_DT)) AS FIRST_ADMISSION_WITHIN_STUDY_YEARS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE 'H%' OR EC.EVENT_CD LIKE '3%' OR EC.EVENT_CD LIKE '9%' OR EC.EVENT_CD LIKE '6%' OR EC.EVENT_CD LIKE '8%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2023-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.FIRST_ADMISSION_WITHIN_STUDY_YEARS = B.FIRST_ADMISSION_WITHIN_STUDY_YEARS;


--POPULATING ASTHMA GP_VISITS: EVENT_CODES STARTING WITH '6' OR 'H'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS ASTHMA_GP_VISITS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE '6%' OR EC.EVENT_CD LIKE 'H%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.ASTHMA_GP_VISITS = B.ASTHMA_GP_VISITS;


--POPULATING TOTAL_ASTHMA_HOSP: EVENT_CODES STARTING WITH '66' 
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS TOTAL_ASTHMA_HOSP
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND EC.EVENT_CD LIKE '66%'
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.TOTAL_ASTHMA_HOSP = B.TOTAL_ASTHMA_HOSP;


--POPULATING EMER_ADM_LAST_12M: EVENT_CODES STARTING WITH 'H' OR '3' OR '9' OR '6' OR '8' 
--PERIOD IS FOR LAST 12 MONTHS (LAST 1 YEAR)
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS EMER_ADM_LAST_12M
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE 'H%' OR EC.EVENT_CD LIKE '3%' OR EC.EVENT_CD LIKE '9%' OR EC.EVENT_CD LIKE '6%' OR EC.EVENT_CD LIKE '8%')
AND (ER.EVENT_DT >= '2023-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.EMER_ADM_LAST_12M = B.EMER_ADM_LAST_12M;


--POPULATING EMER_ADM_BEFORE_LAST_12M: EVENT_CODES STARTING WITH 'H' OR '3' OR '9' OR '6' OR '8' 
--PERIOD DOES NOT INCLUDE LAST YEAR ADMISSIONS
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS EMER_ADM_BEFORE_LAST_12M
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE 'H%' OR EC.EVENT_CD LIKE '3%' OR EC.EVENT_CD LIKE '9%' OR EC.EVENT_CD LIKE '6%' OR EC.EVENT_CD LIKE '8%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2023-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.EMER_ADM_BEFORE_LAST_12M = B.EMER_ADM_BEFORE_LAST_12M;


--POPULATING ASTHMA_OUTPATIENT_APPO: EVENT_CODES STARTING WITH '3' OR '1'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS ASTHMA_OUTPATIENT_APPO
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE '3%' OR EC.EVENT_CD LIKE '1%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.ASTHMA_OUTPATIENT_APPO = B.ASTHMA_OUTPATIENT_APPO;


--POPULATING ASTHMA_EXACERBATIONS: EVENT_CODES STARTING WITH '8'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS ASTHMA_EXACERBATIONS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE '8%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.ASTHMA_EXACERBATIONS = B.ASTHMA_EXACERBATIONS;


--POPULATING ASTHMA_REVIEWS: EVENT_CODES STARTING WITH 'H'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS ASTHMA_REVIEWS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND (EC.EVENT_CD LIKE 'H%')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.ASTHMA_REVIEWS = B.ASTHMA_REVIEWS;


--POPULATING ASTHMA_RE_ADMISSIONS: EVENT_CODES --> '663P200', '66Ys.00', '9OJA.11','663d.00'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS ASTHMA_RE_ADMISSIONS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND EC.EVENT_CD IN ('663P200', '66Ys.00', '9OJA.11','663d.00')
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.ASTHMA_RE_ADMISSIONS = B.ASTHMA_RE_ADMISSIONS;


--POPULATING TOTAL_PRESCRIPTIONS: EVENT_CODES STARTING WITH '1' OR EVENT CODE--> '38DV.00'
MERGE COHORT_SELECTION AS A USING(
SELECT ALF_PE, 
	   COUNT(DISTINCT ER.EVENT_DT) AS TOTAL_PRESCRIPTIONS
FROM GP_EVENT_CODES EC
JOIN GP_EVENT_REFORMATTED AS ER
ON EC.EVENT_CD_ID = ER.EVENT_CD_ID
AND EC.EVENT_CD LIKE '1%' OR EC.EVENT_CD LIKE '38DV.00'
AND (ER.EVENT_DT >= '2018-01-01' AND ER.EVENT_DT < '2024-01-01')
GROUP BY ER.ALF_PE
) AS B 
ON A.ALF_PE = B.ALF_PE
WHEN MATCHED THEN
UPDATE SET A.TOTAL_PRESCRIPTIONS = B.TOTAL_PRESCRIPTIONS;

--DROP TABLE asthma_data --DROP THIS TABLE IF ANY

--LINK COHORT SELECTION TABLE WITH ANY WIMD (I USED 2014 AND 2019 WIMD) TO GET 
--8 DOMAINS (Income, Employment etc) FOR EACH PATIENT BASED ON THEIR LSOA_CODES
SELECT c.ALF_PE,
	   c.GNDR_CD,
	   c.BMI,
	   c.SMK_STATUS,
	   c.ASTHMA_GP_VISITS,
	   c.TOTAL_ASTHMA_HOSP,
	   c.EMER_ADM_LAST_12M,
	   c.EMER_ADM_BEFORE_LAST_12M,
	   c.ASTHMA_EXACERBATIONS,
	   c.ASTHMA_REVIEWS,
	   c.ASTHMA_OUTPATIENT_APPO,
	   c.ASTHMA_RE_ADMISSIONS,
	   c.TOTAL_PRESCRIPTIONS,
	   imd.Income,
	   imd.Employment,
	   imd.Health,
	   imd.Education,
	   imd.Access_to_Services,
	   imd.Community_Safety,
	   imd.Physical_Environment,
	   imd.Housing,
	   WIMD_2019_LSOA_CODES,
	   c.FIRST_ADMISSION_WITHIN_STUDY_YEARS
	   INTO asthma_data
FROM COHORT_SELECTION AS c
JOIN WDSD_SINGLE_CLEAN_GEO_CHAR_LSOA2011_ wdsd
ON c.ALF_PE = wdsd.ALF_PE
JOIN imd_2014 imd
ON imd.LSOA_Code = wdsd.WIMD_2019_LSOA_CODES

SELECT *
FROM asthma_data
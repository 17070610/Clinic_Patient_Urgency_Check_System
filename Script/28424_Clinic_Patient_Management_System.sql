BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;

  FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

BEGIN
  FOR c IN (
    SELECT object_name, object_type FROM user_objects
    WHERE object_type IN ('TABLE','SEQUENCE','PACKAGE','PROCEDURE','FUNCTION','TRIGGER')
  ) LOOP
    BEGIN
      IF c.object_type = 'TABLE' THEN
        EXECUTE IMMEDIATE 'DROP TABLE "' || c.object_name || '" CASCADE CONSTRAINTS';
      ELSIF c.object_type = 'SEQUENCE' THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE "' || c.object_name || '"';
      ELSIF c.object_type = 'PACKAGE' THEN
        EXECUTE IMMEDIATE 'DROP PACKAGE "' || c.object_name || '"';
      ELSIF c.object_type = 'PROCEDURE' THEN
        EXECUTE IMMEDIATE 'DROP PROCEDURE "' || c.object_name || '"';
      ELSIF c.object_type = 'FUNCTION' THEN
        EXECUTE IMMEDIATE 'DROP FUNCTION "' || c.object_name || '"';
      ELSIF c.object_type = 'TRIGGER' THEN
        EXECUTE IMMEDIATE 'DROP TRIGGER "' || c.object_name || '"';
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END;
/

-- =====================
-- PART 1: TABLES
-- =====================

CREATE TABLE patients (
  patient_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name VARCHAR2(50) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR2(10) CHECK (gender IN ('Male','Female','Other')),
  phone VARCHAR2(20) NOT NULL,
  email VARCHAR2(100) UNIQUE,
  address VARCHAR2(200),
  blood_group VARCHAR2(5) CHECK (blood_group IN ('A+','A-','B+','B-','O+','O-','AB+','AB-')),
  registration_date DATE NOT NULL,
  status VARCHAR2(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE doctors (
  doctor_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name VARCHAR2(50) NOT NULL,
  specialization VARCHAR2(50) NOT NULL,
  phone VARCHAR2(20) NOT NULL,
  email VARCHAR2(100) UNIQUE NOT NULL,
  license_number VARCHAR2(50) UNIQUE NOT NULL,
  consultation_fee NUMBER(8,2) NOT NULL CHECK (consultation_fee > 0),
  years_experience NUMBER(2) CHECK (years_experience >= 0),
  status VARCHAR2(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE','ON_LEAVE','UNAVAILABLE'))
);

CREATE TABLE appointments (
  appointment_id NUMBER PRIMARY KEY,
  patient_id NUMBER REFERENCES patients(patient_id),
  doctor_id NUMBER REFERENCES doctors(doctor_id),
  appointment_date DATE NOT NULL,
  appointment_time VARCHAR2(10) NOT NULL,
  reason VARCHAR2(200) NOT NULL,
  status VARCHAR2(20) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED','COMPLETED','CANCELLED','NO_SHOW')),
  booking_date DATE NOT NULL,
  notes VARCHAR2(500)
);

CREATE TABLE prescriptions (
  prescription_id NUMBER PRIMARY KEY,
  appointment_id NUMBER REFERENCES appointments(appointment_id),
  patient_id NUMBER REFERENCES patients(patient_id),
  doctor_id NUMBER REFERENCES doctors(doctor_id),
  medication_name VARCHAR2(100) NOT NULL,
  dosage VARCHAR2(50) NOT NULL,
  duration_days NUMBER(3) CHECK (duration_days >= 0),
  instructions VARCHAR2(200),
  prescription_date DATE NOT NULL
);

CREATE TABLE billing (
  bill_id NUMBER PRIMARY KEY,
  appointment_id NUMBER REFERENCES appointments(appointment_id),
  patient_id NUMBER REFERENCES patients(patient_id),
  consultation_fee NUMBER(8,2) NOT NULL,
  medication_cost NUMBER(8,2) DEFAULT 0,
  lab_test_cost NUMBER(8,2) DEFAULT 0,
  total_amount NUMBER(10,2) NOT NULL,
  payment_status VARCHAR2(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING','PAID','PARTIALLY_PAID')),
  bill_date DATE NOT NULL,
  payment_date DATE
);

CREATE TABLE specializations (
  specialization_id NUMBER PRIMARY KEY,
  specialization_name VARCHAR2(50) UNIQUE NOT NULL,
  description VARCHAR2(200)
);

CREATE TABLE appointment_history (
  history_id NUMBER PRIMARY KEY,
  appointment_id NUMBER NOT NULL,
  patient_id NUMBER NOT NULL,
  doctor_id NUMBER NOT NULL,
  action_type VARCHAR2(20) CHECK (action_type IN ('SCHEDULED','COMPLETED','CANCELLED','RESCHEDULED')),
  action_date DATE NOT NULL,
  performed_by VARCHAR2(50) DEFAULT USER,
  remarks VARCHAR2(200)
);

-- =====================
-- PART 1: SEQUENCES
-- =====================
CREATE SEQUENCE patient_seq START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE doctor_seq START WITH 2000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE appointment_seq START WITH 3000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE prescription_seq START WITH 4000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE bill_seq START WITH 5000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE specialization_seq START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE history_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =====================
-- PART 2: SAMPLE DATA
-- (6 specializations, 10 doctors, 15 patients, 25 appointments, 15 prescriptions, 20 bills)
-- =====================
-- Specializations
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'General Medicine','General healthcare');
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'Cardiology','Heart specialist');
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'Pediatrics','Children specialist');
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'Orthopedics','Bone specialist');
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'Dermatology','Skin specialist');
INSERT INTO specializations VALUES (specialization_seq.NEXTVAL,'Gynecology','Women health');

-- Doctors (10)
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Cedric','Sugira','Cardiology','0788000001','cedric.sugira@clinic.rw','LIC-1001',80000,15,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Aline','Mukamana','General Medicine','0788000002','aline.mukamana@clinic.rw','LIC-1002',30000,5,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Jean','Nshimiyimana','Pediatrics','0788000003','jean.nshimi@clinic.rw','LIC-1003',40000,8,'ON_LEAVE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Beatrice','Uwase','Dermatology','0788000004','beatrice.uwase@clinic.rw','LIC-1004',50000,10,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Philippe','Rwagasana','Orthopedics','0788000005','philippe.rwagasana@clinic.rw','LIC-1005',90000,20,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Marie','Ingabire','Gynecology','0788000006','marie.ingabire@clinic.rw','LIC-1006',70000,12,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Olivier','Habimana','Cardiology','0788000007','olivier.habimana@clinic.rw','LIC-1007',85000,18,'UNAVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Sandrine','Uwera','Pediatrics','0788000008','sandrine.uwera@clinic.rw','LIC-1008',35000,3,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Eric','Niyonsaba','General Medicine','0788000009','eric.niyonsaba@clinic.rw','LIC-1009',32000,4,'AVAILABLE');
INSERT INTO doctors VALUES (doctor_seq.NEXTVAL,'Claire','Kamanzi','Dermatology','0788000010','claire.kamanzi@clinic.rw','LIC-1010',48000,9,'AVAILABLE');

-- Patients (15)
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Alice','Kagabo',TO_DATE('2010-06-15','YYYY-MM-DD'),'Female','0788110001','alice.kagabo@example.com','Kigali, Rwanda','A+',TO_DATE('2023-05-10','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Ben','Mugisha',TO_DATE('1985-02-20','YYYY-MM-DD'),'Male','0788110002','ben.mugisha@example.com','Kigali, Rwanda','O+',TO_DATE('2024-03-01','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Clara','Bizimana',TO_DATE('1950-11-30','YYYY-MM-DD'),'Female','0788110003','clara.bizimana@example.com','Butare, Rwanda','AB-',TO_DATE('2023-08-20','YYYY-MM-DD'),'INACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Daniel','Karekezi',TO_DATE('1992-07-25','YYYY-MM-DD'),'Male','0788110004','daniel.karekezi@example.com','Kigali, Rwanda','B+',TO_DATE('2025-01-15','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Esther','Niyonzima',TO_DATE('2000-12-05','YYYY-MM-DD'),'Female','0788110005','esther.n@example.com','Kigali, Rwanda','O-',TO_DATE('2024-11-10','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Frank','Habumuremyi',TO_DATE('1978-03-03','YYYY-MM-DD'),'Male','0788110006','frank.h@example.com','Rubavu, Rwanda','A-',TO_DATE('2023-12-01','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Gloria','Munyarwari',TO_DATE('2016-09-10','YYYY-MM-DD'),'Female','0788110007','gloria.m@example.com','Kigali, Rwanda','B-',TO_DATE('2024-06-22','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Herve','Isingizwe',TO_DATE('1999-04-01','YYYY-MM-DD'),'Male','0788110008','herve.isingizwe@example.com','Kigali, Rwanda','AB+',TO_DATE('2025-02-02','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Ivy','Uwitonze',TO_DATE('1988-10-12','YYYY-MM-DD'),'Female','0788110009','ivy.uwitonze@example.com','Kigali, Rwanda','O+',TO_DATE('2024-07-07','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Jack','Musanze',TO_DATE('2012-01-20','YYYY-MM-DD'),'Male','0788110010','jack.m@example.com','Kigali, Rwanda','A+',TO_DATE('2023-09-09','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Khadija','Bamporiki',TO_DATE('1965-05-05','YYYY-MM-DD'),'Female','0788110011','khadija.b@example.com','Kigali, Rwanda','B+',TO_DATE('2023-03-03','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Leo','Nkurunziza',TO_DATE('2005-08-30','YYYY-MM-DD'),'Male','0788110012','leo.n@example.com','Gisenyi, Rwanda','O-',TO_DATE('2025-04-12','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Maya','Twagira',TO_DATE('1995-09-17','YYYY-MM-DD'),'Female','0788110013','maya.t@example.com','Kigali, Rwanda','AB-',TO_DATE('2023-11-11','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Nicolas','Rurangwa',TO_DATE('1980-02-28','YYYY-MM-DD'),'Male','0788110014','nicolas.r@example.com','Kigali, Rwanda','A+',TO_DATE('2024-02-02','YYYY-MM-DD'),'ACTIVE');
INSERT INTO patients VALUES (patient_seq.NEXTVAL,'Olivia','Gashumba',TO_DATE('2018-04-14','YYYY-MM-DD'),'Female','0788110015','olivia.g@example.com','Kigali, Rwanda','B+',TO_DATE('2025-06-01','YYYY-MM-DD'),'ACTIVE');

-- Appointments (25) -- mix of completed, scheduled (future), cancelled, no_show
-- For brevity we'll insert 25 with varied statuses; use appointment_seq for IDs
-- Completed appointments (15)
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1000,2000,TO_DATE('2025-10-01','YYYY-MM-DD'),'09:00','Regular checkup','COMPLETED',TO_DATE('2025-09-30','YYYY-MM-DD'),'All good');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1001,2001,TO_DATE('2025-10-02','YYYY-MM-DD'),'10:30','Fever','COMPLETED',TO_DATE('2025-10-01','YYYY-MM-DD'),'Prescribed paracetamol');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1002,2002,TO_DATE('2025-10-03','YYYY-MM-DD'),'11:00','Skin rash','COMPLETED',TO_DATE('2025-10-02','YYYY-MM-DD'),'Given topical cream');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1003,2003,TO_DATE('2025-09-28','YYYY-MM-DD'),'14:00','Back pain','COMPLETED',TO_DATE('2025-09-25','YYYY-MM-DD'),'Physio advised');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1004,2004,TO_DATE('2025-09-29','YYYY-MM-DD'),'08:30','Pregnancy check','COMPLETED',TO_DATE('2025-09-28','YYYY-MM-DD'),'All normal');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1005,2005,TO_DATE('2025-09-30','YYYY-MM-DD'),'15:00','Child vaccination','COMPLETED',TO_DATE('2025-09-29','YYYY-MM-DD'),'Vaccinated');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1006,2006,TO_DATE('2025-09-27','YYYY-MM-DD'),'09:15','Chest pain','COMPLETED',TO_DATE('2025-09-26','YYYY-MM-DD'),'ECG done');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1007,2007,TO_DATE('2025-09-26','YYYY-MM-DD'),'10:00','Flu','COMPLETED',TO_DATE('2025-09-25','YYYY-MM-DD'),'Medication given');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1008,2008,TO_DATE('2025-09-25','YYYY-MM-DD'),'11:45','Skin check','COMPLETED',TO_DATE('2025-09-24','YYYY-MM-DD'),'Follow-up in 2 weeks');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1009,2009,TO_DATE('2025-09-24','YYYY-MM-DD'),'14:30','General consultation','COMPLETED',TO_DATE('2025-09-22','YYYY-MM-DD'),'Advised tests');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1010,2000,TO_DATE('2025-09-23','YYYY-MM-DD'),'08:45','Child fever','COMPLETED',TO_DATE('2025-09-21','YYYY-MM-DD'),'Paracetamol');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1011,2001,TO_DATE('2025-09-22','YYYY-MM-DD'),'09:30','Follow-up','COMPLETED',TO_DATE('2025-09-20','YYYY-MM-DD'),'Stable');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1012,2002,TO_DATE('2025-09-21','YYYY-MM-DD'),'10:15','Cold','COMPLETED',TO_DATE('2025-09-19','YYYY-MM-DD'),'Rest');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1013,2003,TO_DATE('2025-09-20','YYYY-MM-DD'),'11:00','Allergy','COMPLETED',TO_DATE('2025-09-18','YYYY-MM-DD'),'Antihistamine');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1014,2004,TO_DATE('2025-09-19','YYYY-MM-DD'),'12:00','Checkup','COMPLETED',TO_DATE('2025-09-17','YYYY-MM-DD'),'OK');

-- Scheduled (future) (5)
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1000,2000,TO_DATE('2025-12-10','YYYY-MM-DD'),'09:00','Follow-up','SCHEDULED',SYSDATE,'');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1001,2001,TO_DATE('2025-12-11','YYYY-MM-DD'),'10:00','Consultation','SCHEDULED',SYSDATE,'');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1002,2002,TO_DATE('2025-12-12','YYYY-MM-DD'),'14:00','Skin follow-up','SCHEDULED',SYSDATE,'');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1003,2003,TO_DATE('2025-12-15','YYYY-MM-DD'),'08:30','Pregnancy scan','SCHEDULED',SYSDATE,'');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1004,2004,TO_DATE('2025-12-16','YYYY-MM-DD'),'15:00','Vaccination','SCHEDULED',SYSDATE,'');

-- Cancelled (3)
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1005,2005,TO_DATE('2025-11-05','YYYY-MM-DD'),'09:00','Cancelled appt','CANCELLED',TO_DATE('2025-11-01','YYYY-MM-DD'),'Patient requested');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1006,2006,TO_DATE('2025-11-06','YYYY-MM-DD'),'10:00','Cancelled appt','CANCELLED',TO_DATE('2025-11-02','YYYY-MM-DD'),'Doctor unavailable');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1007,2007,TO_DATE('2025-11-07','YYYY-MM-DD'),'11:00','Cancelled appt','CANCELLED',TO_DATE('2025-11-03','YYYY-MM-DD'),'Rescheduled');

-- No-shows (2)
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1008,2008,TO_DATE('2025-10-20','YYYY-MM-DD'),'09:00','Missed','NO_SHOW',TO_DATE('2025-10-19','YYYY-MM-DD'),'');
INSERT INTO appointments VALUES (appointment_seq.NEXTVAL,1009,2009,TO_DATE('2025-10-21','YYYY-MM-DD'),'10:30','Missed','NO_SHOW',TO_DATE('2025-10-20','YYYY-MM-DD'),'');

-- Prescriptions (15) linked to completed appointments
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3001,1000,2000,'Paracetamol','500mg twice daily',5,'After meals',TO_DATE('2025-10-01','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3002,1001,2001,'Amoxicillin','250mg thrice daily',7,'Finish course',TO_DATE('2025-10-02','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3003,1002,2002,'Hydrocortisone cream','Apply twice daily',14,'Topical',TO_DATE('2025-10-03','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3004,1003,2003,'Ibuprofen','200mg thrice daily',5,'If pain',TO_DATE('2025-09-28','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3005,1004,2004,'Iron supplements','1 tab daily',30,'With orange juice',TO_DATE('2025-09-29','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3006,1005,2005,'Vaccine','N/A',0,'As per schedule',TO_DATE('2025-09-30','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3007,1006,2006,'Aspirin','75mg once daily',30,'Cardio',TO_DATE('2025-09-27','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3008,1007,2007,'Antihistamine','10mg once daily',7,'Allergy',TO_DATE('2025-09-26','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3009,1008,2008,'Topical cream','Apply once',10,'Skin',TO_DATE('2025-09-25','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3010,1009,2009,'Paracetamol','500mg twice daily',3,'Pain',TO_DATE('2025-09-24','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3011,1010,2000,'Paracetamol','250mg for child',3,'Child',TO_DATE('2025-09-23','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3012,1011,2001,'Antibiotic','500mg twice',5,'Infection',TO_DATE('2025-09-22','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3013,1012,2002,'Cough syrup','10ml thrice daily',7,'Cough',TO_DATE('2025-09-21','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3014,1013,2003,'Antihistamine','10mg once',5,'Allergies',TO_DATE('2025-09-20','YYYY-MM-DD'));
INSERT INTO prescriptions VALUES (prescription_seq.NEXTVAL,3015,1014,2004,'Multivitamin','1 tab daily',30,'General',TO_DATE('2025-09-19','YYYY-MM-DD'));

-- Billing (20) -- mix of PAID, PENDING, PARTIALLY_PAID
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3001,1000,80000,0,0,80000,'PAID',TO_DATE('2025-10-01','YYYY-MM-DD'),TO_DATE('2025-10-01','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3002,1001,30000,1500,0,31500,'PAID',TO_DATE('2025-10-02','YYYY-MM-DD'),TO_DATE('2025-10-02','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3003,1002,48000,2000,0,50000,'PAID',TO_DATE('2025-10-03','YYYY-MM-DD'),TO_DATE('2025-10-04','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3004,1003,90000,5000,0,95000,'PAID',TO_DATE('2025-09-28','YYYY-MM-DD'),TO_DATE('2025-09-28','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3005,1004,70000,0,0,70000,'PAID',TO_DATE('2025-09-29','YYYY-MM-DD'),TO_DATE('2025-09-29','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3006,1005,35000,0,0,35000,'PAID',TO_DATE('2025-09-30','YYYY-MM-DD'),TO_DATE('2025-09-30','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3007,1006,85000,0,10000,95000,'PARTIALLY_PAID',TO_DATE('2025-09-27','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3008,1007,32000,0,0,32000,'PENDING',TO_DATE('2025-09-26','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3009,1008,50000,1000,0,51000,'PAID',TO_DATE('2025-09-25','YYYY-MM-DD'),TO_DATE('2025-09-25','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3010,1009,30000,0,0,30000,'PAID',TO_DATE('2025-09-24','YYYY-MM-DD'),TO_DATE('2025-09-24','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3011,1010,32000,0,0,32000,'PAID',TO_DATE('2025-09-23','YYYY-MM-DD'),TO_DATE('2025-09-23','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3012,1011,80000,2000,0,82000,'PARTIALLY_PAID',TO_DATE('2025-09-22','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3013,1012,30000,0,0,30000,'PENDING',TO_DATE('2025-09-21','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3014,1013,48000,0,0,48000,'PAID',TO_DATE('2025-09-20','YYYY-MM-DD'),TO_DATE('2025-09-20','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3015,1014,90000,10000,15000,115000,'PENDING',TO_DATE('2025-09-19','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3016,1000,70000,0,0,70000,'PAID',TO_DATE('2025-09-18','YYYY-MM-DD'),TO_DATE('2025-09-18','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3017,1001,80000,0,0,80000,'PAID',TO_DATE('2025-09-17','YYYY-MM-DD'),TO_DATE('2025-09-17','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3018,1002,30000,0,0,30000,'PENDING',TO_DATE('2025-09-16','YYYY-MM-DD'),NULL);
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3019,1003,48000,0,0,48000,'PAID',TO_DATE('2025-09-15','YYYY-MM-DD'),TO_DATE('2025-09-15','YYYY-MM-DD'));
INSERT INTO billing VALUES (bill_seq.NEXTVAL,3020,1004,90000,500,0,90500,'PARTIALLY_PAID',TO_DATE('2025-09-14','YYYY-MM-DD'),NULL);

COMMIT;

-- =====================
-- PART 3: CURSORS & REPORTS
-- =====================

-- Task 1: Doctor Schedule and Revenue Report Cursor
-- SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
  CURSOR c_doctors IS
    SELECT d.doctor_id, d.first_name || ' ' || d.last_name AS full_name, d.specialization, d.license_number, d.consultation_fee
    FROM doctors d;

  v_total_appointments NUMBER;
  v_completed NUMBER;
  v_cancelled_noshow NUMBER;
  v_revenue NUMBER;
  v_avg_fee NUMBER;
  v_next_appointment_date DATE;
  v_next_appointment_time VARCHAR2(10);

  -- summary variables
  v_doc_most_app_id NUMBER; v_doc_most_app_count NUMBER := -1;
  v_doc_highest_rev_id NUMBER; v_doc_highest_rev NUMBER := -1;
  v_total_clinic_revenue NUMBER := 0;
  v_total_appointments_all NUMBER := 0;
  v_total_completed_all NUMBER := 0;

BEGIN
  FOR r IN c_doctors LOOP
    -- total appointments
    SELECT COUNT(*) INTO v_total_appointments FROM appointments a WHERE a.doctor_id = r.doctor_id;
    SELECT COUNT(*) INTO v_completed FROM appointments a WHERE a.doctor_id = r.doctor_id AND a.status = 'COMPLETED';
    SELECT COUNT(*) INTO v_cancelled_noshow FROM appointments a WHERE a.doctor_id = r.doctor_id AND a.status IN ('CANCELLED','NO_SHOW');
    -- revenue from completed appointments
    SELECT NVL(SUM(b.total_amount),0) INTO v_revenue
    FROM billing b JOIN appointments a ON b.appointment_id = a.appointment_id
    WHERE a.doctor_id = r.doctor_id AND a.status = 'COMPLETED';

    -- average consultation fee among this doctor's billed consultations
    SELECT NVL(AVG(b.consultation_fee), 0)
    INTO v_avg_fee
    FROM billing b
    JOIN appointments a ON b.appointment_id = a.appointment_id
    WHERE a.doctor_id = r.doctor_id;

    -- fallback if no billing rows
    IF v_avg_fee = 0 THEN
      v_avg_fee := r.consultation_fee;
    END IF;

    -- next scheduled appointment
    SELECT MIN(a.appointment_date) KEEP (DENSE_RANK FIRST ORDER BY a.appointment_date) INTO v_next_appointment_date
    FROM appointments a
    WHERE a.doctor_id = r.doctor_id AND a.status = 'SCHEDULED' AND a.appointment_date >= TRUNC(SYSDATE);

    IF v_next_appointment_date IS NOT NULL THEN
      SELECT appointment_time INTO v_next_appointment_time FROM appointments
      WHERE doctor_id = r.doctor_id AND appointment_date = v_next_appointment_date AND ROWNUM = 1;
    ELSE
      v_next_appointment_time := NULL;
    END IF;

    dbms_output.put_line('========================================');
    dbms_output.put_line('Dr. ' || r.full_name || ' - ' || r.specialization);
    dbms_output.put_line('License: ' || r.license_number);
    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Total Appointments: ' || v_total_appointments);
    dbms_output.put_line('Completed: ' || v_completed);
    dbms_output.put_line('Cancelled/No-Show: ' || v_cancelled_noshow);
    dbms_output.put_line('Total Revenue: ' || TO_CHAR(v_revenue,'FM999,999,999'));
    dbms_output.put_line('Average Fee: ' || TO_CHAR(v_avg_fee,'FM999,999'));
    IF v_next_appointment_date IS NOT NULL THEN
      dbms_output.put_line('Next Appointment: ' || TO_CHAR(v_next_appointment_date,'YYYY-MM-DD') || ' at ' || v_next_appointment_time);
    ELSE
      dbms_output.put_line('Next Appointment: None');
    END IF;

    -- update summary
    IF v_total_appointments > v_doc_most_app_count THEN
      v_doc_most_app_count := v_total_appointments;
      v_doc_most_app_id := r.doctor_id;
    END IF;
    IF v_revenue > v_doc_highest_rev THEN
      v_doc_highest_rev := v_revenue;
      v_doc_highest_rev_id := r.doctor_id;
    END IF;

    v_total_clinic_revenue := v_total_clinic_revenue + NVL(v_revenue,0);
    v_total_appointments_all := v_total_appointments_all + NVL(v_total_appointments,0);
    v_total_completed_all := v_total_completed_all + NVL(v_completed,0);
  END LOOP;

  dbms_output.put_line('========================================');
  IF v_doc_most_app_id IS NOT NULL THEN
    DECLARE vdoc_name VARCHAR2(100);
    BEGIN
      SELECT first_name||' '||last_name INTO vdoc_name FROM doctors WHERE doctor_id = v_doc_most_app_id;
      dbms_output.put_line('Doctor with most appointments: ' || vdoc_name || ' (' || v_doc_most_app_count || ')');
    END;
  END IF;
  IF v_doc_highest_rev_id IS NOT NULL THEN
    DECLARE vdoc_name2 VARCHAR2(100);
    BEGIN
      SELECT first_name||' '||last_name INTO vdoc_name2 FROM doctors WHERE doctor_id = v_doc_highest_rev_id;
      dbms_output.put_line('Doctor with highest revenue: ' || vdoc_name2 || ' (' || TO_CHAR(v_doc_highest_rev,'FM999,999,999') || ')');
    END;
  END IF;
  dbms_output.put_line('Total clinic revenue from consultations: ' || TO_CHAR(v_total_clinic_revenue,'FM999,999,999'));
  IF v_total_appointments_all > 0 THEN
    dbms_output.put_line('Overall appointment completion rate: ' || TO_CHAR((v_total_completed_all / v_total_appointments_all)*100,'FM990.00') || '%');
  END IF;
END;
/

-- Task 2: Patient Medical History Cursor
-- SET SERVEROUTPUT ON;
DECLARE
  CURSOR c_patients IS
    SELECT p.patient_id, p.first_name || ' ' || p.last_name AS full_name, p.blood_group, p.date_of_birth
    FROM patients p
    WHERE EXISTS (SELECT 1 FROM appointments a WHERE a.patient_id = p.patient_id AND a.status = 'COMPLETED');

  v_total_visits NUMBER;
  v_last_visit DATE;
  v_primary_doctor VARCHAR2(100);
  v_total_spent NUMBER;
  v_outstanding NUMBER;

BEGIN
  FOR r IN c_patients LOOP
    SELECT COUNT(*) INTO v_total_visits FROM appointments WHERE patient_id = r.patient_id;
    SELECT MAX(appointment_date) INTO v_last_visit FROM appointments WHERE patient_id = r.patient_id;
    -- primary doctor: doctor with most visits by this patient
    SELECT d.first_name||' '||d.last_name INTO v_primary_doctor FROM (
      SELECT a.doctor_id, COUNT(*) AS cnt FROM appointments a WHERE a.patient_id = r.patient_id GROUP BY a.doctor_id ORDER BY cnt DESC
    ) ad JOIN doctors d ON ad.doctor_id = d.doctor_id WHERE ROWNUM = 1;
    SELECT NVL(SUM(b.total_amount),0) INTO v_total_spent FROM billing b WHERE b.patient_id = r.patient_id AND b.payment_status = 'PAID';
    SELECT NVL(SUM(CASE WHEN b.payment_status IN ('PENDING','PARTIALLY_PAID') THEN b.total_amount - NVL(0,0) ELSE 0 END),0) INTO v_outstanding FROM billing b WHERE b.patient_id = r.patient_id AND b.payment_status IN ('PENDING','PARTIALLY_PAID');

    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Patient: ' || r.full_name || ' | Blood group: ' || r.blood_group);
    dbms_output.put_line('Total visits: ' || v_total_visits);
    dbms_output.put_line('Last visit: ' || TO_CHAR(v_last_visit,'YYYY-MM-DD'));
    dbms_output.put_line('Primary doctor: ' || v_primary_doctor);
    dbms_output.put_line('Total spent: ' || TO_CHAR(v_total_spent,'FM999,999'));
    dbms_output.put_line('Outstanding balance: ' || TO_CHAR(v_outstanding,'FM999,999'));

    -- categorize
    IF v_total_visits > 10 OR v_total_spent > 500000 THEN
      dbms_output.put_line('Category: VIP');
    ELSIF v_total_visits BETWEEN 5 AND 10 THEN
      dbms_output.put_line('Category: Regular');
    ELSE
      dbms_output.put_line('Category: New');
    END IF;

    IF v_outstanding > 0 THEN
      dbms_output.put_line('*** Has pending payments ***');
    END IF;

    -- list prescriptions
    dbms_output.put_line('Prescriptions:');
    FOR rx IN (SELECT medication_name||' ('||dosage||', '||duration_days||' days)' AS med FROM prescriptions WHERE patient_id = r.patient_id) LOOP
      dbms_output.put_line(' - ' || rx.med);
    END LOOP;
  END LOOP;
END;
/

-- =====================
-- PART 4: PROCEDURES
-- =====================

-- Procedure: register_patient
CREATE OR REPLACE PROCEDURE register_patient (
  p_first_name IN VARCHAR2,
  p_last_name IN VARCHAR2,
  p_date_of_birth IN DATE,
  p_gender IN VARCHAR2,
  p_phone IN VARCHAR2,
  p_email IN VARCHAR2,
  p_blood_group IN VARCHAR2,
  p_patient_id OUT NUMBER
) AS
  v_age NUMBER;
  e_dup EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_dup, -00001);
BEGIN
  -- Validations
  IF INSTR(p_email,'@') = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'Invalid email format');
  END IF;
  IF NOT REGEXP_LIKE(p_phone,'^\d{10}$') THEN
    RAISE_APPLICATION_ERROR(-20002,'Phone must be 10 digits');
  END IF;
  IF p_gender NOT IN ('Male','Female','Other') THEN
    RAISE_APPLICATION_ERROR(-20003,'Invalid gender');
  END IF;
  IF p_blood_group NOT IN ('A+','A-','B+','B-','O+','O-','AB+','AB-') THEN
    RAISE_APPLICATION_ERROR(-20004,'Invalid blood group');
  END IF;
  IF p_date_of_birth > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20005,'Date of birth cannot be in the future');
  END IF;
  v_age := FLOOR(MONTHS_BETWEEN(SYSDATE,p_date_of_birth)/12);
  IF v_age > 150 THEN
    RAISE_APPLICATION_ERROR(-20006,'Age unrealistic (>150)');
  END IF;

  -- Unique email check is enforced by constraint; handle exception
  p_patient_id := patient_seq.NEXTVAL;
  INSERT INTO patients(patient_id,first_name,last_name,date_of_birth,gender,phone,email,address,blood_group,registration_date,status)
  VALUES (p_patient_id, p_first_name, p_last_name, p_date_of_birth, p_gender, p_phone, p_email, NULL, p_blood_group, SYSDATE, 'ACTIVE');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Patient registered. ID='||p_patient_id||' Name='||p_first_name||' '||p_last_name);
EXCEPTION
  WHEN e_dup THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20007,'Email or other unique constraint violated');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END register_patient;
/

-- Procedure: is_doctor_available function (declared as function in Part5, but used here in schedule_appointment)

-- Procedure: schedule_appointment
CREATE OR REPLACE PROCEDURE schedule_appointment(
  p_patient_id IN NUMBER,
  p_doctor_id IN NUMBER,
  p_appointment_date IN DATE,
  p_appointment_time IN VARCHAR2,
  p_reason IN VARCHAR2
) AS
  v_patient_status VARCHAR2(20);
  v_doctor_status VARCHAR2(20);
  v_pending_bills NUMBER;
  v_count_conflict NUMBER;
BEGIN
  -- validations
  SELECT status INTO v_patient_status FROM patients WHERE patient_id = p_patient_id;
  IF v_patient_status <> 'ACTIVE' THEN
    RAISE_APPLICATION_ERROR(-20011,'Patient not ACTIVE or not found');
  END IF;
  SELECT status INTO v_doctor_status FROM doctors WHERE doctor_id = p_doctor_id;
  IF v_doctor_status <> 'AVAILABLE' THEN
    RAISE_APPLICATION_ERROR(-20012,'Doctor not AVAILABLE');
  END IF;
  IF TRUNC(p_appointment_date) < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20013,'Appointment date cannot be in the past');
  END IF;
  IF NOT REGEXP_LIKE(p_appointment_time,'^([0-1][0-9]|2[0-3]):[0-5][0-9]$') THEN
    RAISE_APPLICATION_ERROR(-20014,'Time must be in HH:MM format');
  END IF;
  -- working hours 08:00 - 17:00
  IF TO_NUMBER(SUBSTR(p_appointment_time,1,2)) < 8 OR TO_NUMBER(SUBSTR(p_appointment_time,1,2)) > 17 THEN
    RAISE_APPLICATION_ERROR(-20015,'Appointment time must be between 08:00 and 17:00');
  END IF;
  -- conflicts
  SELECT COUNT(*) INTO v_count_conflict FROM appointments WHERE doctor_id = p_doctor_id AND appointment_date = p_appointment_date AND appointment_time = p_appointment_time AND status = 'SCHEDULED';
  IF v_count_conflict > 0 THEN
    RAISE_APPLICATION_ERROR(-20016,'Doctor has another appointment at that date/time');
  END IF;
  SELECT COUNT(*) INTO v_count_conflict FROM appointments WHERE patient_id = p_patient_id AND appointment_date = p_appointment_date AND appointment_time = p_appointment_time AND status = 'SCHEDULED';
  IF v_count_conflict > 0 THEN
    RAISE_APPLICATION_ERROR(-20017,'Patient has another appointment at that date/time');
  END IF;
  -- pending bills > 100000
  SELECT NVL(SUM(CASE WHEN payment_status IN ('PENDING','PARTIALLY_PAID') THEN total_amount ELSE 0 END),0) INTO v_pending_bills FROM billing WHERE patient_id = p_patient_id;
  IF v_pending_bills > 100000 THEN
    RAISE_APPLICATION_ERROR(-20018,'Patient has pending bills > 100,000 RWF');
  END IF;

  -- create appointment
  INSERT INTO appointments(appointment_id,patient_id,doctor_id,appointment_date,appointment_time,reason,status,booking_date,notes)
  VALUES (appointment_seq.NEXTVAL,p_patient_id,p_doctor_id,p_appointment_date,p_appointment_time,p_reason,'SCHEDULED',SYSDATE,NULL);

  -- log history
  INSERT INTO appointment_history(history_id,appointment_id,patient_id,doctor_id,action_type,action_date,performed_by,remarks)
  VALUES (history_seq.NEXTVAL,appointment_seq.CURRVAL,p_patient_id,p_doctor_id,'SCHEDULED',SYSDATE,USER,'Scheduled by procedure');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Appointment scheduled for patient '||p_patient_id||' with doctor '||p_doctor_id||' on '||TO_CHAR(p_appointment_date,'YYYY-MM-DD')||' at '||p_appointment_time);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20019,'Patient or doctor not found');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END schedule_appointment;
/

-- Procedure: complete_appointment
CREATE OR REPLACE PROCEDURE complete_appointment(
  p_appointment_id IN NUMBER,
  p_medication_cost IN NUMBER DEFAULT 0,
  p_lab_test_cost IN NUMBER DEFAULT 0,
  p_notes IN VARCHAR2 DEFAULT NULL
) AS
  v_status VARCHAR2(20);
  v_doctor_id NUMBER;
  v_patient_id NUMBER;
  v_consult_fee NUMBER;
  v_bill_id NUMBER;
BEGIN
  SELECT status, doctor_id, patient_id INTO v_status, v_doctor_id, v_patient_id FROM appointments WHERE appointment_id = p_appointment_id;
  IF v_status <> 'SCHEDULED' THEN
    RAISE_APPLICATION_ERROR(-20021,'Appointment not in SCHEDULED status or not found');
  END IF;
  IF TRUNC((SELECT appointment_date FROM appointments WHERE appointment_id = p_appointment_id)) > TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20022,'Appointment date is in the future');
  END IF;

  -- update appointment
  UPDATE appointments SET status = 'COMPLETED', notes = NVL(notes, p_notes) WHERE appointment_id = p_appointment_id;

  -- get consultation fee
  SELECT consultation_fee INTO v_consult_fee FROM doctors WHERE doctor_id = v_doctor_id;

  -- create billing
  v_bill_id := bill_seq.NEXTVAL;
  INSERT INTO billing(bill_id,appointment_id,patient_id,consultation_fee,medication_cost,lab_test_cost,total_amount,payment_status,bill_date)
  VALUES (v_bill_id,p_appointment_id,v_patient_id,v_consult_fee,p_medication_cost,p_lab_test_cost,(v_consult_fee + NVL(p_medication_cost,0) + NVL(p_lab_test_cost,0)),'PENDING',SYSDATE);

  -- log history
  INSERT INTO appointment_history(history_id,appointment_id,patient_id,doctor_id,action_type,action_date,performed_by,remarks)
  VALUES (history_seq.NEXTVAL,p_appointment_id,v_patient_id,v_doctor_id,'COMPLETED',SYSDATE,USER,'Completed and billed');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Appointment '||p_appointment_id||' completed. Bill ID='||v_bill_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20023,'Appointment not found');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END complete_appointment;
/

-- =====================
-- PART 5: FUNCTIONS
-- =====================

CREATE OR REPLACE FUNCTION get_patient_age(p_patient_id IN NUMBER) RETURN NUMBER IS
  v_dob DATE;
  v_age NUMBER;
BEGIN
  SELECT date_of_birth INTO v_dob FROM patients WHERE patient_id = p_patient_id;
  v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_dob)/12);
  RETURN v_age;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END get_patient_age;
/

CREATE OR REPLACE FUNCTION is_doctor_available(p_doctor_id IN NUMBER, p_appointment_date IN DATE, p_appointment_time IN VARCHAR2) RETURN VARCHAR2 IS
  v_status VARCHAR2(20);
  v_count NUMBER;
BEGIN
  SELECT status INTO v_status FROM doctors WHERE doctor_id = p_doctor_id;
  IF v_status <> 'AVAILABLE' THEN
    RETURN 'NO';
  END IF;
  SELECT COUNT(*) INTO v_count FROM appointments WHERE doctor_id = p_doctor_id AND appointment_date = p_appointment_date AND appointment_time = p_appointment_time AND status = 'SCHEDULED';
  IF v_count > 0 THEN
    RETURN 'NO';
  END IF;
  RETURN 'YES';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NO';
  WHEN OTHERS THEN
    RAISE;
END is_doctor_available;
/

CREATE OR REPLACE FUNCTION get_patient_balance(p_patient_id IN NUMBER) RETURN NUMBER IS
  v_sum NUMBER;
  v_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM patients WHERE patient_id = p_patient_id;
  IF v_exists = 0 THEN
    RETURN -1;
  END IF;
  SELECT NVL(SUM(CASE WHEN payment_status = 'PAID' THEN 0 WHEN payment_status = 'PARTIALLY_PAID' THEN total_amount ELSE total_amount END),0) INTO v_sum FROM billing WHERE patient_id = p_patient_id AND payment_status IN ('PENDING','PARTIALLY_PAID');
  RETURN v_sum;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_patient_balance;
/

-- =====================
-- PART 6: TRIGGERS
-- =====================

-- Trigger: Validate appointment time and set booking_date
CREATE OR REPLACE TRIGGER trg_validate_appointment
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.booking_date := NVL(:NEW.booking_date, SYSDATE);
  END IF;
  IF :NEW.appointment_date < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20031,'Appointment date cannot be in the past');
  END IF;
  IF NOT REGEXP_LIKE(:NEW.appointment_time,'^([0-1][0-9]|2[0-3]):[0-5][0-9]$') THEN
    RAISE_APPLICATION_ERROR(-20032,'Appointment time must be HH:MM');
  END IF;
  IF TO_NUMBER(SUBSTR(:NEW.appointment_time,1,2)) < 8 OR TO_NUMBER(SUBSTR(:NEW.appointment_time,1,2)) > 17 THEN
    RAISE_APPLICATION_ERROR(-20033,'Appointment time must be between 08:00 and 17:00');
  END IF;
END trg_validate_appointment;
/

-- Trigger: Auto-calculate bill total
CREATE OR REPLACE TRIGGER trg_calculate_bill_total
BEFORE INSERT OR UPDATE ON billing
FOR EACH ROW
BEGIN
  IF :NEW.consultation_fee < 0 OR NVL(:NEW.medication_cost,0) < 0 OR NVL(:NEW.lab_test_cost,0) < 0 THEN
    RAISE_APPLICATION_ERROR(-20041,'Costs cannot be negative');
  END IF;
  :NEW.total_amount := :NEW.consultation_fee + NVL(:NEW.medication_cost,0) + NVL(:NEW.lab_test_cost,0);
  IF :NEW.bill_date IS NULL THEN
    :NEW.bill_date := SYSDATE;
  END IF;
END trg_calculate_bill_total;
/

-- Trigger: Log appointment status changes
CREATE OR REPLACE TRIGGER trg_log_appointment_changes
AFTER UPDATE OF status ON appointments
FOR EACH ROW
BEGIN
  IF :OLD.status != :NEW.status THEN
    INSERT INTO appointment_history(history_id,appointment_id,patient_id,doctor_id,action_type,action_date,performed_by,remarks)
    VALUES (history_seq.NEXTVAL,:NEW.appointment_id,:NEW.patient_id,:NEW.doctor_id,:NEW.status,SYSDATE,USER,'Status changed from '||:OLD.status||' to '||:NEW.status);
  END IF;
END trg_log_appointment_changes;
/



-- =====================
-- BONUS: SMS Reminder Simulation
-- =====================
CREATE OR REPLACE PROCEDURE send_sms_reminders IS
BEGIN
  FOR r IN (SELECT a.appointment_id, p.phone, p.first_name||' '||p.last_name AS patient_name, d.first_name||' '||d.last_name AS doctor_name, a.appointment_time
            FROM appointments a JOIN patients p ON a.patient_id = p.patient_id JOIN doctors d ON a.doctor_id = d.doctor_id
            WHERE TRUNC(a.appointment_date) = TRUNC(SYSDATE)+1 AND a.status = 'SCHEDULED') LOOP
    DBMS_OUTPUT.PUT_LINE('SMS reminder to: '||r.phone||' - Dear '||r.patient_name||', reminder: appointment with Dr. '||r.doctor_name||' tomorrow at '||r.appointment_time);
  END LOOP;
END send_sms_reminders;
/

-- =====================
-- END OF SCRIPT
-- Run the demo scenarios using the procedures and functions above.
-- Examples:
-- EXEC clinic_mgt_pkg.register_patient('Test','Patient',TO_DATE('1990-01-01','YYYY-MM-DD'),'Male','0788999000','test@example.com','O+',:newid);
-- EXEC clinic_mgt_pkg.schedule_appointment(1000,2000,TO_DATE('2025-12-20','YYYY-MM-DD'),'09:00','Demo');
-- EXEC clinic_mgt_pkg.complete_appointment(3001,1500,200, 'Notes');
-- SELECT clinic_mgt_pkg.get_patient_age(1000) FROM dual;
-- EXEC send_sms_reminders;


CREATE OR REPLACE PACKAGE clinic_mgt_pkg IS
  -- Procedures (from Part 4)
  PROCEDURE register_patient(
    p_first_name    IN VARCHAR2,
    p_last_name     IN VARCHAR2,
    p_date_of_birth IN DATE,
    p_gender        IN VARCHAR2,
    p_phone         IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_blood_group   IN VARCHAR2,
    p_patient_id    OUT NUMBER
  );

  PROCEDURE schedule_appointment(
    p_patient_id       IN NUMBER,
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_appointment_time IN VARCHAR2,
    p_reason           IN VARCHAR2
  );

  PROCEDURE complete_appointment(
    p_appointment_id IN NUMBER,
    p_medication_cost IN NUMBER DEFAULT 0,
    p_lab_test_cost   IN NUMBER DEFAULT 0,
    p_notes          IN VARCHAR2 DEFAULT NULL
  );

  -- Additional
  PROCEDURE cancel_appointment(
    p_appointment_id IN NUMBER,
    p_reason         IN VARCHAR2
  );

  PROCEDURE process_payment(
    p_bill_id     IN NUMBER,
    p_amount_paid IN NUMBER
  );

  FUNCTION get_doctor_daily_schedule(
    p_doctor_id IN NUMBER,
    p_date      IN DATE
  ) RETURN NUMBER;

  -- Functions
  FUNCTION get_patient_age(p_patient_id IN NUMBER) RETURN NUMBER;
  FUNCTION is_doctor_available(
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_appointment_time IN VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION get_patient_balance(p_patient_id IN NUMBER) RETURN NUMBER;
END clinic_mgt_pkg;
/
  
CREATE OR REPLACE PACKAGE BODY clinic_mgt_pkg IS

  ----------------------------------------------------------------------------
  -- 1) register_patient
  ----------------------------------------------------------------------------
  PROCEDURE register_patient(
    p_first_name    IN VARCHAR2,
    p_last_name     IN VARCHAR2,
    p_date_of_birth IN DATE,
    p_gender        IN VARCHAR2,
    p_phone         IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_blood_group   IN VARCHAR2,
    p_patient_id    OUT NUMBER
  ) IS
    v_age NUMBER;
  BEGIN
    -- Basic validations (raise application errors for invalid input)
    IF p_first_name IS NULL OR p_last_name IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'First name and last name are required.');
    END IF;

    IF p_date_of_birth > SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20002, 'Date of birth cannot be in the future.');
    END IF;

    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_date_of_birth)/12);
    IF v_age > 150 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Age appears unrealistic (> 150).');
    END IF;

    IF p_gender IS NULL OR NOT (p_gender IN ('Male','Female','Other')) THEN
      RAISE_APPLICATION_ERROR(-20004, 'Invalid gender. Allowed: Male, Female, Other.');
    END IF;

    IF p_blood_group IS NOT NULL AND NOT (p_blood_group IN ('A+','A-','B+','B-','O+','O-','AB+','AB-')) THEN
      RAISE_APPLICATION_ERROR(-20005, 'Invalid blood group.');
    END IF;

    IF p_phone IS NULL OR NOT REGEXP_LIKE(p_phone,'^\d{10}$') THEN
      RAISE_APPLICATION_ERROR(-20006, 'Phone must be 10 digits.');
    END IF;

    IF p_email IS NULL OR INSTR(p_email,'@') = 0 THEN
      RAISE_APPLICATION_ERROR(-20007, 'Invalid email format.');
    END IF;

    -- Create patient
    p_patient_id := patient_seq.NEXTVAL;
    INSERT INTO patients(
      patient_id, first_name, last_name, date_of_birth,
      gender, phone, email, blood_group, registration_date, status
    ) VALUES (
      p_patient_id, p_first_name, p_last_name, p_date_of_birth,
      p_gender, p_phone, p_email, p_blood_group, SYSDATE, 'ACTIVE'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient registered. ID=' || p_patient_id);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20009,'Duplicate value � email or unique field already used.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END register_patient;

  ----------------------------------------------------------------------------
  -- 2) schedule_appointment
  ----------------------------------------------------------------------------
  PROCEDURE schedule_appointment(
    p_patient_id       IN NUMBER,
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_appointment_time IN VARCHAR2,
    p_reason           IN VARCHAR2
  ) IS
    v_patient_status VARCHAR2(20);
    v_doctor_status  VARCHAR2(20);
    v_pending_bills  NUMBER := 0;
    v_conflicts      NUMBER := 0;
    v_new_appt_id    NUMBER;
    v_hour NUMBER;
  BEGIN
    -- Existence & status checks
    SELECT status INTO v_patient_status FROM patients WHERE patient_id = p_patient_id;
    SELECT status INTO v_doctor_status FROM doctors  WHERE doctor_id  = p_doctor_id;

    IF v_patient_status <> 'ACTIVE' THEN
      RAISE_APPLICATION_ERROR(-20011,'Patient is not ACTIVE or not allowed to book.');
    END IF;

    IF v_doctor_status <> 'AVAILABLE' THEN
      RAISE_APPLICATION_ERROR(-20012,'Doctor is not AVAILABLE to take appointments.');
    END IF;

    IF TRUNC(p_appointment_date) < TRUNC(SYSDATE) THEN
      RAISE_APPLICATION_ERROR(-20013,'Appointment date cannot be in the past.');
    END IF;

    IF NOT REGEXP_LIKE(p_appointment_time,'^([0-1][0-9]|2[0-3]):[0-5][0-9]$') THEN
      RAISE_APPLICATION_ERROR(-20014,'Time must be in HH24:MI format (e.g. 09:00).');
    END IF;

    v_hour := TO_NUMBER(SUBSTR(p_appointment_time,1,2));
    IF v_hour < 8 OR v_hour > 17 THEN
      RAISE_APPLICATION_ERROR(-20015,'Appointment time must be between 08:00 and 17:00.');
    END IF;

    -- Check conflicts for doctor & patient (only SCHEDULED appointments)
    SELECT COUNT(*) INTO v_conflicts
    FROM appointments
    WHERE appointment_date = TRUNC(p_appointment_date)
      AND appointment_time = p_appointment_time
      AND status = 'SCHEDULED'
      AND (doctor_id = p_doctor_id OR patient_id = p_patient_id);

    IF v_conflicts > 0 THEN
      RAISE_APPLICATION_ERROR(-20016,'Either doctor or patient already has a scheduled appointment at that date/time.');
    END IF;

    -- Pending bills check
    SELECT NVL(SUM(CASE WHEN payment_status IN ('PENDING','PARTIALLY_PAID') THEN total_amount ELSE 0 END),0)
      INTO v_pending_bills
    FROM billing
    WHERE patient_id = p_patient_id;

    IF v_pending_bills > 100000 THEN
      RAISE_APPLICATION_ERROR(-20018,'Patient pending bills exceed 100,000 RWF; cannot schedule new appointment.');
    END IF;

    -- Insert appointment
    v_new_appt_id := appointment_seq.NEXTVAL;
    INSERT INTO appointments(
      appointment_id, patient_id, doctor_id, appointment_date,
      appointment_time, reason, status, booking_date
    ) VALUES (
      v_new_appt_id, p_patient_id, p_doctor_id, TRUNC(p_appointment_date),
      p_appointment_time, p_reason, 'SCHEDULED', SYSDATE
    );

    -- Log history
    INSERT INTO appointment_history(
      history_id, appointment_id, patient_id, doctor_id,
      action_type, action_date, performed_by, remarks
    ) VALUES (
      history_seq.NEXTVAL, v_new_appt_id, p_patient_id, p_doctor_id,
      'SCHEDULED', SYSDATE, USER, 'Scheduled via package procedure'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment scheduled. ID=' || v_new_appt_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20019,'Patient or Doctor not found.');
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20020,'Unique constraint violated when creating appointment.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END schedule_appointment;

  ----------------------------------------------------------------------------
  -- 3) complete_appointment
  ----------------------------------------------------------------------------
  PROCEDURE complete_appointment(
    p_appointment_id IN NUMBER,
    p_medication_cost IN NUMBER DEFAULT 0,
    p_lab_test_cost   IN NUMBER DEFAULT 0,
    p_notes          IN VARCHAR2 DEFAULT NULL
  ) IS
    v_status      VARCHAR2(20);
    v_patient_id  NUMBER;
    v_doctor_id   NUMBER;
    v_consult_fee NUMBER;
    v_bill_id     NUMBER;
    v_appt_date   DATE;
  BEGIN
    SELECT status, patient_id, doctor_id, appointment_date
      INTO v_status, v_patient_id, v_doctor_id, v_appt_date
    FROM appointments
    WHERE appointment_id = p_appointment_id;

    IF v_status <> 'SCHEDULED' THEN
      RAISE_APPLICATION_ERROR(-20021,'Only SCHEDULED appointments can be completed.');
    END IF;

    IF TRUNC(v_appt_date) > TRUNC(SYSDATE) THEN
      RAISE_APPLICATION_ERROR(-20022,'Cannot complete an appointment whose date is in the future.');
    END IF;

    SELECT consultation_fee INTO v_consult_fee FROM doctors WHERE doctor_id = v_doctor_id;

    -- Update appointment
    UPDATE appointments
    SET status = 'COMPLETED',
        notes = NVL(notes, p_notes)
    WHERE appointment_id = p_appointment_id;

    -- Create bill
    v_bill_id := bill_seq.NEXTVAL;
    INSERT INTO billing(
      bill_id, appointment_id, patient_id,
      consultation_fee, medication_cost, lab_test_cost,
      total_amount, payment_status, bill_date
    ) VALUES (
      v_bill_id, p_appointment_id, v_patient_id,
      v_consult_fee, NVL(p_medication_cost,0), NVL(p_lab_test_cost,0),
      v_consult_fee + NVL(p_medication_cost,0) + NVL(p_lab_test_cost,0),
      'PENDING', SYSDATE
    );

    -- Log history
    INSERT INTO appointment_history(
      history_id, appointment_id, patient_id, doctor_id,
      action_type, action_date, performed_by, remarks
    ) VALUES (
      history_seq.NEXTVAL, p_appointment_id, v_patient_id, v_doctor_id,
      'COMPLETED', SYSDATE, USER, 'Completed and billed'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment completed and billed. Bill ID=' || v_bill_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20023,'Appointment or related data not found.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END complete_appointment;

  ----------------------------------------------------------------------------
  -- 4) cancel_appointment
  ----------------------------------------------------------------------------
  PROCEDURE cancel_appointment(
    p_appointment_id IN NUMBER,
    p_reason         IN VARCHAR2
  ) IS
    v_status     VARCHAR2(20);
    v_patient_id NUMBER;
    v_doctor_id  NUMBER;
    v_appt_date  DATE;
    v_seconds_to_appt NUMBER;
    v_cancellation_fee NUMBER := 0;
    v_new_bill_id NUMBER;
  BEGIN
    SELECT status, patient_id, doctor_id, appointment_date
      INTO v_status, v_patient_id, v_doctor_id, v_appt_date
    FROM appointments
    WHERE appointment_id = p_appointment_id;

    IF v_status <> 'SCHEDULED' THEN
      RAISE_APPLICATION_ERROR(-20051,'Only SCHEDULED appointments can be cancelled.');
    END IF;

    -- If within 24 hours -> create a cancellation fee (business rule: fee = 5,000)
    v_seconds_to_appt := (TRUNC(v_appt_date) - TRUNC(SYSDATE)) * 24 * 3600; -- seconds difference
    IF v_seconds_to_appt <= 24*3600 AND v_seconds_to_appt >= 0 THEN
      v_cancellation_fee := 5000;
      v_new_bill_id := bill_seq.NEXTVAL;
      INSERT INTO billing(
        bill_id, appointment_id, patient_id,
        consultation_fee, medication_cost, lab_test_cost,
        total_amount, payment_status, bill_date
      ) VALUES (
        v_new_bill_id, p_appointment_id, v_patient_id,
        0, 0, v_cancellation_fee,
        v_cancellation_fee, 'PENDING', SYSDATE
      );
    END IF;

    UPDATE appointments
    SET status = 'CANCELLED',
        notes = NVL(notes,'') || ' | Cancel reason: ' || p_reason
    WHERE appointment_id = p_appointment_id;

    INSERT INTO appointment_history(
      history_id, appointment_id, patient_id, doctor_id,
      action_type, action_date, performed_by, remarks
    ) VALUES (
      history_seq.NEXTVAL, p_appointment_id, v_patient_id, v_doctor_id,
      'CANCELLED', SYSDATE, USER, p_reason
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment cancelled. ID=' || p_appointment_id
                         || CASE WHEN v_cancellation_fee > 0 THEN ' (cancellation fee applied: '||v_cancellation_fee||')' ELSE '' END);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20052,'Appointment not found.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END cancel_appointment;

  ----------------------------------------------------------------------------
  -- 5) process_payment
  ----------------------------------------------------------------------------
  PROCEDURE process_payment(
    p_bill_id     IN NUMBER,
    p_amount_paid IN NUMBER
  ) IS
    v_total_amount NUMBER;
    v_new_status   VARCHAR2(20);
    v_current_total_paid NUMBER := 0;
    -- NOTE: this implementation treats each payment as paying the bill in full or partial;
    -- for real systems you'd track payment history � here we update payment_status only.
  BEGIN
    SELECT total_amount INTO v_total_amount FROM billing WHERE bill_id = p_bill_id;

    IF p_amount_paid <= 0 THEN
      RAISE_APPLICATION_ERROR(-20061,'Payment amount must be greater than 0.');
    END IF;

    IF p_amount_paid >= v_total_amount THEN
      UPDATE billing
      SET payment_status = 'PAID', payment_date = SYSDATE
      WHERE bill_id = p_bill_id;
      v_new_status := 'PAID';
    ELSE
      UPDATE billing
      SET payment_status = 'PARTIALLY_PAID'
      WHERE bill_id = p_bill_id;
      v_new_status := 'PARTIALLY_PAID';
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payment processed for Bill ' || p_bill_id || '. New status: ' || v_new_status);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20062,'Bill not found.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END process_payment;

  ----------------------------------------------------------------------------
  -- 6) get_doctor_daily_schedule
  ----------------------------------------------------------------------------
  FUNCTION get_doctor_daily_schedule(
    p_doctor_id IN NUMBER,
    p_date      IN DATE
  ) RETURN NUMBER IS
    v_count NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE doctor_id = p_doctor_id
      AND TRUNC(appointment_date) = TRUNC(p_date)
      AND status = 'SCHEDULED';

    RETURN v_count;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RAISE;
  END get_doctor_daily_schedule;

  ----------------------------------------------------------------------------
  -- 7) get_patient_age
  ----------------------------------------------------------------------------
  FUNCTION get_patient_age(p_patient_id IN NUMBER) RETURN NUMBER IS
    v_dob DATE;
    v_age NUMBER;
  BEGIN
    SELECT date_of_birth INTO v_dob FROM patients WHERE patient_id = p_patient_id;
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_dob)/12);
    RETURN v_age;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_patient_age;

  ----------------------------------------------------------------------------
  -- 8) is_doctor_available
  ----------------------------------------------------------------------------
  FUNCTION is_doctor_available(
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_appointment_time IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_status VARCHAR2(20);
    v_conflict_count NUMBER := 0;
  BEGIN
    SELECT status INTO v_status FROM doctors WHERE doctor_id = p_doctor_id;

    IF v_status <> 'AVAILABLE' THEN
      RETURN 'NO';
    END IF;

    SELECT COUNT(*) INTO v_conflict_count
    FROM appointments
    WHERE doctor_id = p_doctor_id
      AND TRUNC(appointment_date) = TRUNC(p_appointment_date)
      AND appointment_time = p_appointment_time
      AND status = 'SCHEDULED';

    IF v_conflict_count = 0 THEN
      RETURN 'YES';
    ELSE
      RETURN 'NO';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'NO';
    WHEN OTHERS THEN
      RAISE;
  END is_doctor_available;

  ----------------------------------------------------------------------------
  -- 9) get_patient_balance
  ----------------------------------------------------------------------------
  FUNCTION get_patient_balance(p_patient_id IN NUMBER) RETURN NUMBER IS
    v_exists NUMBER;
    v_balance NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM patients WHERE patient_id = p_patient_id;
    IF v_exists = 0 THEN
      RETURN -1; -- patient not found
    END IF;

    SELECT NVL(SUM(
      CASE
        WHEN payment_status = 'PAID' THEN 0
        ELSE total_amount
      END
    ),0) INTO v_balance
    FROM billing
    WHERE patient_id = p_patient_id;

    RETURN v_balance;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RAISE;
  END get_patient_balance;

END clinic_mgt_pkg;
/


--SCENARIO 1.

-- SET SERVEROUTPUT ON;
-- SET VERIFY OFF;

DECLARE
    v_new_patient_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TESTING PATIENT REGISTRATION ---');

    -- Call the procedure from your package
    clinic_MGT_PKG.register_patient(
        p_first_name    => 'solal',
        p_last_name     => 'kamonyo',
        p_date_of_birth => TO_DATE('1995-01-01', 'YYYY-MM-DD'),
        p_gender        => 'Male',
        p_phone         => '0781244433',
        p_email         => 'kamonyosolal@email.com',
        p_blood_group   => 'O+',
        p_patient_id    => v_new_patient_id
    );

    -- Check if we got an ID back
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('SUCCESS! New Patient Created.');
    DBMS_OUTPUT.PUT_LINE('Patient ID: ' || v_new_patient_id);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAILED to register patient.');
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
END;

--SCENARIO 2.

-- SET SERVEROUTPUT ON;
-- SET VERIFY OFF;
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> SCENARIO 2: SCHEDULE APPOINTMENT');
    clinic_MGT_PKG.schedule_appointment(
        p_patient_id       => 1005,
        p_doctor_id        => 2004,
        p_appointment_date => TRUNC(SYSDATE),
        p_appointment_time => '10:00',
        p_reason           => 'dental prob'
    );
END;
/

-- SET SERVEROUTPUT ON;

BEGIN
  clinic_mgt_pkg.schedule_appointment(1000, 2000, SYSDATE+2, '16:00', 'Checkup');
END;
/

-- SET SERVEROUTPUT ON;
BEGIN
  clinic_mgt_pkg.schedule_appointment(1000, 2000, SYSDATE+2, '10:00', 'Checkup');
END;
/

--Scenario 3 � Check Doctor schedule

--(i). function to check if doctor is available 
-- SET SERVEROUTPUT ON;
-- SET VERIFY OFF;
DECLARE
    v_is_available VARCHAR2(10);
    v_daily_count  NUMBER;
    v_doctor_id    NUMBER := 2001;
    v_check_date   DATE := TRUNC(SYSDATE) + 1; -- Checking tomorrow
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> SCENARIO 3: CHECK DOCTOR SCHEDULE');

    -- 1. Check specific slot availability
    v_is_available := clinic_MGT_PKG.is_doctor_available(v_doctor_id, v_check_date, '10:00');
    DBMS_OUTPUT.PUT_LINE('Is Doctor ' || v_doctor_id || ' available tomorrow at 10:00? ' || v_is_available);

    -- 2. Count appointments for that day
    v_daily_count := clinic_MGT_PKG.get_doctor_daily_schedule(v_doctor_id, v_check_date);
    DBMS_OUTPUT.PUT_LINE('Doctor ' || v_doctor_id || ' has ' || v_daily_count || ' appointment(s) scheduled for ' || TO_CHAR(v_check_date, 'YYYY-MM-DD'));
END;
/


SELECT clinic_mgt_pkg.is_doctor_available(2001, SYSDATE+1, '10:00') FROM Doctors;

--(iii). select doctor's schedule on a specific day

SELECT 
    appointment_id,
    appointment_date,
    appointment_time,
    status,
    reason
FROM appointments
WHERE doctor_id = 2001
  AND TRUNC(appointment_date) = TRUNC(SYSDATE + 2)
ORDER BY appointment_time;


--Scenario 4 � Complete Appointment.....

-- --trying to cmplete unscheduled appointment.
-- BEGIN
--   clinic_mgt_pkg.complete_appointment(3000, 5000, 1500, 'Everything okay');
-- END;
-- /

-- BEGIN
--   clinic_mgt_pkg.complete_appointment(3044, 2004, 1005, 'teeth repaired');
-- END;
-- /

--Scenario 5 � Enter Prescription
INSERT INTO prescriptions VALUES(
  prescription_seq.NEXTVAL, 3000, 1000, 2000,
  'ascolill', '500mg', 7, 'use small spoon', SYSDATE
);

--Scenario 6 � Process Payment

BEGIN
  clinic_mgt_pkg.process_payment(5000, 20000);
END;
/

--Scenario 7 � Reports(attention)

SELECT clinic_mgt_pkg.get_doctor_daily_schedule(2000, SYSDATE+2)
FROM Doctors;

--Scenario 8 � Appointment Cancellation

-- BEGIN
--   clinic_mgt_pkg.cancel_appointment(3001, 'Patient not feeling well');
-- END;
-- /

--Scenario 9 � Error Handling
-- BEGIN
--   clinic_mgt_pkg.schedule_appointment(1000,2000,SYSDATE-5,'09:00','Test error');
-- END;
-- /

--CURSOR Doctor Schedule and Revenue Report Cursor

-- SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
CURSOR c_doctors IS
SELECT d.doctor_id, d.first_name || ' ' || d.last_name AS full_name, d.specialization, d.license_number, d.consultation_fee
FROM doctors d;



v_total_appointments NUMBER;
v_completed NUMBER;
v_cancelled_noshow NUMBER;
v_revenue NUMBER;
v_avg_fee NUMBER;
v_next_appointment_date DATE;
v_next_appointment_time VARCHAR2(10);

v_doc_most_app_id NUMBER; v_doc_most_app_count NUMBER := -1;
v_doc_highest_rev_id NUMBER; v_doc_highest_rev NUMBER := -1;
v_total_clinic_revenue NUMBER := 0;
v_total_appointments_all NUMBER := 0;
v_total_completed_all NUMBER := 0;

BEGIN
FOR r IN c_doctors LOOP
-- total appointments
SELECT COUNT(*) INTO v_total_appointments FROM appointments a WHERE a.doctor_id = r.doctor_id;
SELECT COUNT(*) INTO v_completed FROM appointments a WHERE a.doctor_id = r.doctor_id AND a.status = 'COMPLETED';
SELECT COUNT(*) INTO v_cancelled_noshow FROM appointments a WHERE a.doctor_id = r.doctor_id AND a.status IN ('CANCELLED','NO_SHOW');

SELECT NVL(SUM(b.total_amount),0) INTO v_revenue
FROM billing b JOIN appointments a ON b.appointment_id = a.appointment_id
WHERE a.doctor_id = r.doctor_id AND a.status = 'COMPLETED';


-- average consultation fee among this doctor's billed consultations
SELECT AVG(b.consultation_fee)
INTO v_avg_fee
FROM billing b
JOIN appointments a ON b.appointment_id = a.appointment_id
WHERE a.doctor_id = r.doctor_id;

IF v_avg_fee IS NULL THEN
  v_avg_fee := r.consultation_fee;
END IF;

-- next scheduled appointment
SELECT MIN(a.appointment_date) KEEP (DENSE_RANK FIRST ORDER BY a.appointment_date) INTO v_next_appointment_date
FROM appointments a
WHERE a.doctor_id = r.doctor_id AND a.status = 'SCHEDULED' AND a.appointment_date >= TRUNC(SYSDATE);


IF v_next_appointment_date IS NOT NULL THEN
SELECT appointment_time INTO v_next_appointment_time FROM appointments
WHERE doctor_id = r.doctor_id AND appointment_date = v_next_appointment_date AND ROWNUM = 1;
ELSE
v_next_appointment_time := NULL;
END IF;

dbms_output.put_line('========================================');
dbms_output.put_line('Dr. ' || r.full_name || ' - ' || r.specialization);
dbms_output.put_line('License: ' || r.license_number);
dbms_output.put_line('----------------------------------------');
dbms_output.put_line('Total Appointments: ' || v_total_appointments);
dbms_output.put_line('Completed: ' || v_completed);
dbms_output.put_line('Cancelled/No-Show: ' || v_cancelled_noshow);
dbms_output.put_line('Total Revenue: ' || TO_CHAR(v_revenue,'FM999,999,999'));
dbms_output.put_line('Average Fee: ' || TO_CHAR(v_avg_fee,'FM999,999'));
IF v_next_appointment_date IS NOT NULL THEN
   dbms_output.put_line('Next Appointment: ' || TO_CHAR(v_next_appointment_date,'YYYY-MM-DD') || ' at ' || v_next_appointment_time);
ELSE
   dbms_output.put_line('Next Appointment: None');
END IF;

IF v_total_appointments > v_doc_most_app_count THEN
v_doc_most_app_count := v_total_appointments;
v_doc_most_app_id := r.doctor_id;
END IF;
IF v_revenue > v_doc_highest_rev THEN
v_doc_highest_rev := v_revenue;
v_doc_highest_rev_id := r.doctor_id;
END IF;

v_total_clinic_revenue := v_total_clinic_revenue + NVL(v_revenue,0);
v_total_appointments_all := v_total_appointments_all + NVL(v_total_appointments,0);
v_total_completed_all := v_total_completed_all + NVL(v_completed,0);
END LOOP;

dbms_output.put_line('========================================');
IF v_doc_most_app_id IS NOT NULL THEN
DECLARE vdoc_name VARCHAR2(100);
BEGIN
SELECT first_name||' '||last_name INTO vdoc_name FROM doctors WHERE doctor_id = v_doc_most_app_id;
dbms_output.put_line('Doctor with most appointments: ' || vdoc_name || ' (' || v_doc_most_app_count || ')');
END;
END IF;
IF v_doc_highest_rev_id IS NOT NULL THEN
DECLARE vdoc_name2 VARCHAR2(100);
BEGIN
SELECT first_name||' '||last_name INTO vdoc_name2 FROM doctors WHERE doctor_id = v_doc_highest_rev_id;
dbms_output.put_line('Doctor with highest revenue: ' || vdoc_name2 || ' (' || TO_CHAR(v_doc_highest_rev,'FM999,999,999') || ')');
END;
END IF;
dbms_output.put_line('Total clinic revenue from consultations: ' || TO_CHAR(v_total_clinic_revenue,'FM999,999,999'));
IF v_total_appointments_all > 0 THEN
dbms_output.put_line('Overall appointment completion rate: ' || TO_CHAR((v_total_completed_all / v_total_appointments_all)*100,'FM990.00') || '%');
END IF;
END;
/

--CURSOR; Patient Medical History Cursor
-- SET SERVEROUTPUT ON;
DECLARE
CURSOR c_patients IS
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS full_name, p.blood_group, p.date_of_birth
FROM patients p
WHERE EXISTS (SELECT 1 FROM appointments a WHERE a.patient_id = p.patient_id AND a.status = 'COMPLETED');

v_total_visits NUMBER;
v_last_visit DATE;
v_primary_doctor VARCHAR2(100);
v_total_spent NUMBER;
v_outstanding NUMBER;

BEGIN
FOR r IN c_patients LOOP
SELECT COUNT(*) INTO v_total_visits FROM appointments WHERE patient_id = r.patient_id;
SELECT MAX(appointment_date) INTO v_last_visit FROM appointments WHERE patient_id = r.patient_id;
-- primary doctor: doctor with most visits by this patient
SELECT d.first_name||' '||d.last_name INTO v_primary_doctor FROM (
SELECT a.doctor_id, COUNT(*) AS cnt FROM appointments a WHERE a.patient_id = r.patient_id GROUP BY a.doctor_id ORDER BY cnt DESC
) ad JOIN doctors d ON ad.doctor_id = d.doctor_id WHERE ROWNUM = 1;
SELECT NVL(SUM(b.total_amount),0) INTO v_total_spent FROM billing b WHERE b.patient_id = r.patient_id AND b.payment_status = 'PAID';
SELECT NVL(SUM(CASE WHEN b.payment_status IN ('PENDING','PARTIALLY_PAID') THEN b.total_amount - NVL(0,0) ELSE 0 END),0) INTO v_outstanding FROM billing b WHERE b.patient_id = r.patient_id AND b.payment_status IN ('PENDING','PARTIALLY_PAID');


dbms_output.put_line('----------------------------------------');
dbms_output.put_line('Patient: ' || r.full_name || ' | Blood group: ' || r.blood_group);
dbms_output.put_line('Total visits: ' || v_total_visits);
dbms_output.put_line('Last visit: ' || TO_CHAR(v_last_visit,'YYYY-MM-DD'));
dbms_output.put_line('Primary doctor: ' || v_primary_doctor);
dbms_output.put_line('Total spent: ' || TO_CHAR(v_total_spent,'FM999,999'));
dbms_output.put_line('Outstanding balance: ' || TO_CHAR(v_outstanding,'FM999,999'));


-- categorize
IF v_total_visits > 10 OR v_total_spent > 500000 THEN
dbms_output.put_line('Category: VIP');
ELSIF v_total_visits BETWEEN 5 AND 10 THEN
dbms_output.put_line('Category: Regular');
ELSE
dbms_output.put_line('Category: New');
END IF;


IF v_outstanding > 0 THEN
dbms_output.put_line('*** Has pending payments ***');
END IF;

-- list prescriptions
dbms_output.put_line('Prescriptions:');
FOR rx IN (SELECT medication_name||' ('||dosage||', '||duration_days||' days)' AS med FROM prescriptions WHERE patient_id = r.patient_id) LOOP
dbms_output.put_line(' - ' || rx.med);
END LOOP;
END LOOP;
END;
/


--bonus doctor_performance_report procedure.

-- SET SERVEROUTPUT ON;
-- SET VERIFY OFF;

create or replace PROCEDURE doctor_performance_report IS
  -- Cursor to fetch Top 3 Doctors
  CURSOR c_ranks IS
    SELECT d.first_name,
           d.last_name,
           d.specialization,
           COUNT(a.appointment_id) AS completed_count,
           NVL(SUM(b.consultation_fee), 0) AS revenue_generated
    FROM DOCTORS d
    JOIN APPOINTMENTS a ON d.doctor_id = a.doctor_id
    LEFT JOIN BILLING b ON a.appointment_id = b.appointment_id
    WHERE a.status = 'COMPLETED'
    GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
    ORDER BY revenue_generated DESC, completed_count DESC;

  v_rank NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('     TOP PERFORMING DOCTORS       ');
  DBMS_OUTPUT.PUT_LINE('==================================');

  FOR r_doc IN (SELECT * FROM (
                  SELECT d.first_name,
                         d.last_name,
                         d.specialization,
                         COUNT(a.appointment_id) AS completed_count,
                         NVL(SUM(b.consultation_fee), 0) AS revenue_generated
                  FROM DOCTORS d
                  JOIN APPOINTMENTS a ON d.doctor_id = a.doctor_id
                  LEFT JOIN BILLING b ON a.appointment_id = b.appointment_id
                  WHERE a.status = 'COMPLETED'
                  GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
                  ORDER BY revenue_generated DESC, completed_count DESC
                )
                WHERE ROWNUM <= 3)
  LOOP
    v_rank := v_rank + 1;
    DBMS_OUTPUT.PUT_LINE('#' || v_rank || ': Dr. ' || r_doc.first_name || ' ' || r_doc.last_name);
    DBMS_OUTPUT.PUT_LINE('   Specialization: ' || r_doc.specialization);
    DBMS_OUTPUT.PUT_LINE('   Patients Seen: ' || r_doc.completed_count);
    DBMS_OUTPUT.PUT_LINE('   Revenue Generated: ' || r_doc.revenue_generated || ' RWF');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
  END LOOP;
END;

BEGIN
  doctor_performance_report;
END;
/


select table_name From user_tables;

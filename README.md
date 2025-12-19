# 🏥 Clinic Patient Urgency Check System

**Repository Name:** `Clinic_Patient_Urgency_Check_System`  
**Author:** **Schimea NIYITWUMVA**  
**Student ID:** **28424**

---

## 1️⃣ Project Overview

The **Clinic Patient Urgency Check System** is a database-driven clinic management system designed to manage patients, doctors, appointments, prescriptions, billing, and clinical workflows efficiently.

The system is implemented using **Oracle SQL and PL/SQL**, with a strong focus on:
- Data integrity  
- Business rule enforcement  
- Automation using triggers  
- Realistic clinic workflows such as scheduling, billing, and reporting  

This project demonstrates **advanced relational database design and PL/SQL programming**.

---

## 2️⃣ Problem Statement

Clinics often face challenges such as:
- Poor tracking of patient appointments and urgency  
- Scheduling conflicts between doctors and patients  
- Manual and error-prone billing processes  
- Lack of auditing for appointment changes  
- Inconsistent enforcement of clinic rules  

These challenges lead to inefficiency, revenue loss, and poor patient service.

---

## 3️⃣ Proposed Solution

The proposed solution is a **centralized Oracle database system** that:
- Automates patient and appointment management  
- Enforces scheduling and availability rules  
- Handles billing and payments securely  
- Logs all critical actions for auditing  
- Provides analytical and operational reports  

All business logic is enforced **inside the database** using PL/SQL.

---

## 4️⃣ System Features

✔ Patient registration and validation  
✔ Doctor availability management  
✔ Appointment scheduling with conflict detection  
✔ Appointment completion and cancellation  
✔ Prescription management  
✔ Automated billing and payment processing  
✔ Appointment history auditing  
✔ Doctor performance and revenue reporting  
✔ SMS reminder simulation (via `DBMS_OUTPUT`)  

---

## 5️⃣ Database Design (ER Diagram & Relationships)

The system follows a **relational ER model** with the following key relationships:

- **Patients → Appointments** (One-to-Many)  
- **Doctors → Appointments** (One-to-Many)  
- **Appointments → Prescriptions** (One-to-Many)  
- **Appointments → Billing** (One-to-One / One-to-Many)  
- **Appointments → Appointment_History** (One-to-Many)  
- **Specializations → Doctors** (Logical One-to-Many)

📌 The ER Diagram is provided using **draw.io XML**, matching the implemented schema.

---

## 6️⃣ Database Tables Implemented

The following tables are implemented:

- `PATIENTS`
- `DOCTORS`
- `APPOINTMENTS`
- `PRESCRIPTIONS`
- `BILLING`
- `SPECIALIZATIONS`
- `APPOINTMENT_HISTORY`

Each table includes:
- Primary keys  
- Foreign key relationships  
- Check constraints  
- Meaningful default values  

---

## 7️⃣ PL/SQL Implementation

### Standalone Procedure
- `doctor_performance_report`

### Package: `CLINIC_MGT_PKG`

Procedures:
- `register_patient`
- `schedule_appointment`
- `complete_appointment`
- `cancel_appointment`
- `process_payment`

Functions:
- `get_patient_age`
- `is_doctor_available`
- `get_patient_balance`
- `get_doctor_daily_schedule`

This package-based design ensures **modularity, reusability, and maintainability**.

---

## 8️⃣ Exception Handling

The system uses robust exception handling with:
- `RAISE_APPLICATION_ERROR`
- Custom error codes (`-20001` to `-20099`)
- Proper `COMMIT` and `ROLLBACK` control  

Handled scenarios include:
- Invalid appointment times  
- Scheduling conflicts  
- Invalid appointment completion  
- Cancellation rule violations  
- Payment errors  

All errors return **clear and meaningful messages**.

---

## 9️⃣ Business Rules & Triggers

### Business Rules
- Appointments must be between **08:00 and 17:00**
- Appointments cannot be scheduled in the past
- Only **AVAILABLE** doctors can be booked
- Patients with excessive unpaid bills cannot book
- Cancellation fees apply within 24 hours

### Triggers Implemented
- `trg_validate_appointment`
- `trg_calculate_bill_total`
- `trg_log_appointment_changes`

Triggers ensure rules are enforced **automatically**.

---

## 🔟 Auditing

Auditing is handled using the `APPOINTMENT_HISTORY` table.

Tracked actions include:
- Appointment scheduling
- Completion
- Cancellation
- Status changes  

This provides **full traceability and accountability**.

---

## 1️⃣1️⃣ Screenshots

📸 Screenshots will be added later and will include:
- Procedure execution outputs
- Error handling demonstrations
- Appointment scheduling results
- Reporting outputs (`DBMS_OUTPUT`)

All screenshots will be generated from the provided SQL scripts.

---

## 1️⃣2️⃣ How to Run the Project

1. Open **DataGrip**
2. Connect to an **Oracle Database**
3. Open the provided SQL script
4. Run the script **from top to bottom**
5. Enable `DBMS_OUTPUT` where required
6. Execute the included test scenarios

⚠️ If objects are dropped, rerun the full script to reinitialize the database.

---

## 1️⃣3️⃣ Conclusion

The **Clinic Patient Urgency Check System** demonstrates:
- Strong relational database design
- Advanced PL/SQL programming
- Automated business rule enforcement
- Auditable clinical workflows
- Real-world applicability in clinic environments  

This project showcases practical and professional database engineering skills.

---

## 1️⃣4️⃣ Technologies Used

- **Oracle SQL**
- **PL/SQL**
- **DataGrip**
- **draw.io (ER Diagram Design)**

---

### 👤 Author
**Schimea NIYITWUMVA**  
**Student ID:** 28424

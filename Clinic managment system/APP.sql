-- Enforce foreign key constraints in SQLite
PRAGMA foreign_keys = ON;

-- ==========================================
-- 1. CLINIC STAFF & ATTENDING DOCTORS MANAGEMENT
-- ==========================================
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('Admin', 'Doctor', 'Pharmacist', 'Receptionist')),
    specialization TEXT, -- e.g., 'General Medicine', 'Pediatrics' (Only for doctors)
    is_active INTEGER DEFAULT 1 -- 1 for True, 0 for False
);

-- ==========================================
-- 2. PATIENT RECORDS MANAGEMENT
-- ==========================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    dob DATE NOT NULL,
    gender TEXT CHECK(gender IN ('Male', 'Female', 'Other')),
    phone TEXT,
    allergies TEXT DEFAULT 'None' -- Critical flag for doctors
);

-- ==========================================
-- 3. PATIENT VISITS (The Queue & Vitals Coordinator)
-- ==========================================
CREATE TABLE IF NOT EXISTS visits (
    visit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    visit_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Vitals collected at triage
    blood_pressure TEXT,  -- e.g., '120/80'
    temperature_c REAL,    -- e.g., 36.8
    heart_rate_bpm INTEGER,
    
    -- Doctor's findings
    clinical_notes TEXT,
    diagnosis TEXT,
    
    -- Workflow status flags
    status TEXT NOT NULL CHECK(status IN ('Waiting', 'In-Consultation', 'To-Pharmacy', 'Completed')) DEFAULT 'Waiting',
    
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES users(user_id)
);

-- ==========================================
-- 4. PHARMACY INVENTORY (Drug Management)
-- ==========================================
CREATE TABLE IF NOT EXISTS drugs (
    drug_id INTEGER PRIMARY KEY AUTOINCREMENT,
    drug_name TEXT NOT NULL,
    generic_name TEXT,
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    expiry_date DATE NOT NULL
);

-- ==========================================
-- 5. DRUG SELL & PRESCRIPTIONS (Fulfillment System)
-- ==========================================
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id INTEGER PRIMARY KEY AUTOINCREMENT,
    visit_id INTEGER NOT NULL,
    drug_id INTEGER NOT NULL,
    quantity_prescribed INTEGER NOT NULL,
    dosage_instructions TEXT NOT NULL, -- e.g., '1 tab 3x daily'
    status TEXT NOT NULL CHECK(status IN ('Pending', 'Dispensed')) DEFAULT 'Pending',
    
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON DELETE CASCADE,
    FOREIGN KEY (drug_id) REFERENCES drugs(drug_id)
);
-- FitLife360 Wellness Metrics Database Schema
-- Created: 2026-05-05
-- Purpose: Store and manage wellness metrics for the FitLife360 audit system

-- ============================================================
-- Users Table
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- ============================================================
-- Daily Metrics Table
-- ============================================================
CREATE TABLE IF NOT EXISTS daily_metrics (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    metric_date DATE NOT NULL,
    steps INT,
    calories_burned DECIMAL(10, 2),
    distance_miles DECIMAL(10, 2),
    active_minutes INT,
    sleep_hours DECIMAL(5, 2),
    sleep_quality VARCHAR(50),
    heart_rate_avg INT,
    heart_rate_min INT,
    heart_rate_max INT,
    water_intake_ml INT,
    mood_rating INT CHECK (mood_rating BETWEEN 1 AND 10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_user_date (user_id, metric_date),
    INDEX idx_user_date (user_id, metric_date),
    INDEX idx_metric_date (metric_date)
);

-- ============================================================
-- Exercise Log Table
-- ============================================================
CREATE TABLE IF NOT EXISTS exercise_log (
    exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    exercise_date DATE NOT NULL,
    exercise_time TIME,
    exercise_type VARCHAR(100) NOT NULL,
    duration_minutes INT NOT NULL,
    intensity VARCHAR(50),
    calories_burned DECIMAL(10, 2),
    distance_km DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_date (user_id, exercise_date),
    INDEX idx_exercise_type (exercise_type)
);

-- ============================================================
-- Nutrition Table
-- ============================================================
CREATE TABLE IF NOT EXISTS nutrition (
    nutrition_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    nutrition_date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL,
    meal_time TIME,
    food_item VARCHAR(255),
    quantity DECIMAL(10, 2),
    unit VARCHAR(50),
    calories INT,
    protein_g DECIMAL(10, 2),
    carbs_g DECIMAL(10, 2),
    fat_g DECIMAL(10, 2),
    fiber_g DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_date (user_id, nutrition_date),
    INDEX idx_meal_type (meal_type)
);

-- ============================================================
-- Health Vitals Table
-- ============================================================
CREATE TABLE IF NOT EXISTS health_vitals (
    vital_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    vital_date DATE NOT NULL,
    vital_time TIME,
    systolic_bp INT,
    diastolic_bp INT,
    blood_glucose_mg_dl DECIMAL(10, 2),
    weight_kg DECIMAL(10, 2),
    bmi DECIMAL(10, 2),
    temperature_c DECIMAL(5, 2),
    oxygen_saturation_percent DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_date (user_id, vital_date),
    INDEX idx_vital_date (vital_date)
);

-- ============================================================
-- Goals Table
-- ============================================================
CREATE TABLE IF NOT EXISTS goals (
    goal_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    goal_type VARCHAR(100) NOT NULL,
    goal_name VARCHAR(255) NOT NULL,
    target_value DECIMAL(10, 2),
    current_value DECIMAL(10, 2),
    unit VARCHAR(50),
    start_date DATE NOT NULL,
    target_date DATE,
    status VARCHAR(50) DEFAULT 'active',
    priority VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_goal_type (goal_type)
);

-- ============================================================
-- Indexes for Performance
-- ============================================================
CREATE INDEX idx_users_created ON users(created_at);
CREATE INDEX idx_daily_metrics_user ON daily_metrics(user_id);
CREATE INDEX idx_daily_metrics_date ON daily_metrics(metric_date);
CREATE INDEX idx_exercise_user ON exercise_log(user_id);
CREATE INDEX idx_nutrition_user ON nutrition(user_id);
CREATE INDEX idx_vitals_user ON health_vitals(user_id);
CREATE INDEX idx_goals_user ON goals(user_id);

-- ============================================================
-- Sample Audit View
-- ============================================================
CREATE OR REPLACE VIEW user_metrics_summary AS
SELECT 
    u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    COUNT(DISTINCT dm.metric_date) as total_metric_days,
    COUNT(DISTINCT el.exercise_id) as total_exercises,
    AVG(dm.steps) as avg_steps,
    AVG(dm.sleep_hours) as avg_sleep_hours,
    MAX(dm.created_at) as last_metric_recorded
FROM users u
LEFT JOIN daily_metrics dm ON u.user_id = dm.user_id
LEFT JOIN exercise_log el ON u.user_id = el.user_id
GROUP BY u.user_id, u.email, u.first_name, u.last_name;

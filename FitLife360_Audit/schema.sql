-- FitLife360_Audit Database Schema
-- Wellness metrics tracking and audit system

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- Wellness metrics table
CREATE TABLE IF NOT EXISTS wellness_metrics (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    metric_date DATE NOT NULL,
    weight_kg DECIMAL(5, 2),
    height_cm DECIMAL(5, 1),
    steps INT,
    heart_rate_bpm INT,
    sleep_hours DECIMAL(3, 1),
    water_intake_ml INT,
    calories_burned INT,
    systolic_bp INT,
    diastolic_bp INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, metric_date),
    INDEX idx_metric_date (metric_date)
);

-- Audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    old_value JSON,
    new_value JSON,
    performed_by INT,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user_action (user_id, action),
    INDEX idx_performed_at (performed_at)
);

-- Wellness goals table
CREATE TABLE IF NOT EXISTS wellness_goals (
    goal_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    goal_type VARCHAR(50) NOT NULL,
    target_value DECIMAL(10, 2),
    current_value DECIMAL(10, 2),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status),
    INDEX idx_goal_type (goal_type)
);

-- Metrics summary table (aggregated data for analytics)
CREATE TABLE IF NOT EXISTS metrics_summary (
    summary_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    summary_date DATE NOT NULL,
    avg_weight_kg DECIMAL(5, 2),
    avg_steps INT,
    avg_heart_rate_bpm INT,
    avg_sleep_hours DECIMAL(3, 1),
    total_water_intake_ml INT,
    total_calories_burned INT,
    avg_systolic_bp INT,
    avg_diastolic_bp INT,
    metric_count INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_summary (user_id, summary_date),
    INDEX idx_user_summary_date (user_id, summary_date)
);

-- Indexes for performance optimization
CREATE INDEX idx_wellness_metrics_user ON wellness_metrics(user_id);
CREATE INDEX idx_wellness_metrics_date ON wellness_metrics(metric_date);
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_table ON audit_log(table_name);
CREATE INDEX idx_wellness_goals_user ON wellness_goals(user_id);
CREATE INDEX idx_metrics_summary_user ON metrics_summary(user_id);

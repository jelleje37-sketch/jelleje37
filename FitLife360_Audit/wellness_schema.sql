-- Table for metabolic and activity tracking
CREATE TABLE wellness_metrics (
    entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL,
    user_id TEXT,
    metabolic_rate INTEGER, -- e.g., BMR or RMR
    activity_level TEXT,    -- e.g., 'Sedentary', 'Active', 'Very Active'
    daily_steps INTEGER,
    sleep_score INTEGER,
    processed_food_intake_pct INTEGER -- Percentage of daily calories from UPF
);

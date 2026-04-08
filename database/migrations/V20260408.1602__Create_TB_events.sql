-- Create Events Table
-- Stores get-together events organized by DevOps Porto
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    max_attendees INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on event_date for efficient event queries
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_events_location ON events(location);

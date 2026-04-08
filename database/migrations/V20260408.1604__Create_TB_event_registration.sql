-- Create Event Registrations Table
-- Junction table linking members to events (many-to-many relationship)
CREATE TABLE IF NOT EXISTS event_registrations (
    id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(member_id, event_id)
);

-- Create indexes for efficient joins
CREATE INDEX idx_registrations_member_id ON event_registrations(member_id);
CREATE INDEX idx_registrations_event_id ON event_registrations(event_id);
CREATE INDEX idx_registrations_date ON event_registrations(registration_date);

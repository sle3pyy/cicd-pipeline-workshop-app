-- Seed sample event registrations for development and testing
-- Links members to events they registered for
INSERT INTO event_registrations (member_id, event_id) VALUES
-- DevOps Porto Kickoff: João, Maria, Pedro
(1, 1), (2, 1), (3, 1),
-- Kubernetes Best Practices: João, Ana
(1, 2), (4, 2),
-- CI/CD Pipeline Workshop: Maria, Pedro
(2, 3), (3, 3);

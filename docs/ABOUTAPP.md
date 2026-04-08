# About the Application: DevOps Porto Get-Together

## Overview

The **DevOps Porto Get-Together** is a comprehensive web application designed to help organize and manage the DevOps Porto community get-togethers. This application serves as the practical example for the CI/CD workshop, demonstrating real-world DevOps practices through the development of a community management system.

## 🎯 Application Purpose

DevOps Porto is a vibrant community of technology professionals in Porto, Portugal, focused on DevOps practices, tools, and culture. The get-together manager application addresses the community's need for:

- **Centralized member management** for tracking community growth
- **Event organization** for planning and promoting get-togethers
- **Registration system** for managing event attendance
- **Community engagement** through easy access to information

## 🏗️ Core Features (WORK IN PROGRESS)

### 1. Member Management
- **Registration**: Allow new community members to join
- **Profile Management**: Store member information (name, email, join date)
- **Status Tracking**: Track active/inactive member status
- **Community Statistics**: View member growth and engagement metrics

### 2. Get-Together Events
- **Event Creation**: Schedule new get-together events with details
- **Event Information**: Store title, description, date, location, capacity
- **Event Management**: Update event details and track status
- **Event History**: Maintain archive of past events

### 3. Event Registration
- **Registration System**: Allow members to register for events
- **Capacity Management**: Track available spots and waitlists
- **Attendance Tracking**: Monitor who registered vs. who attended
- **Registration Analytics**: View registration trends

### 4. Dashboard & Analytics
- **Community Overview**: Total members, active events, upcoming get-togethers
- **Event Statistics**: Registration rates, attendance patterns
- **Member Insights**: Join dates, activity levels
- **Reporting**: Generate reports for community growth


## 📊 Data Model (WORK IN PROGRESS)

### Members Table
```sql
- id: Primary key
- name: Member full name
- email: Unique email address
- join_date: When member joined community
- is_active: Current membership status
- created_at/updated_at: Audit timestamps
```

### Get-Together Events Table
```sql
- id: Primary key
- title: Event title
- description: Detailed event description
- event_date: When the event occurs
- location: Venue information
- max_attendees: Capacity limit
- created_at/updated_at: Audit timestamps
```

### Event Registrations Table
```sql
- id: Primary key
- member_id: Foreign key to members
- event_id: Foreign key to get_together_events
- registration_date: When registration occurred
- UNIQUE constraint: Prevent duplicate registrations
```

## 🚀 Development Roadmap (WORK IN PROGRESS)

### Phase 1: Core Functionality (Workshop Focus)
- [ ] Member registration and management
- [ ] Basic event creation and listing
- [ ] Simple registration system
- [ ] Database schema and relationships

### Phase 2: Enhanced Features
- [ ] User authentication and authorization
- [ ] Event waitlists for oversubscribed events
- [ ] Email notifications for registrations
- [ ] Member profile management

### Phase 3: Analytics & Reporting
- [ ] Advanced dashboard with charts
- [ ] Attendance tracking and analytics
- [ ] Community growth reports
- [ ] Event performance metrics

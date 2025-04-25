# LedgerFlow Product Context

## Core Purpose
LedgerFlow is a financial transaction management and categorization system that helps businesses track and categorize their expenses.

## Critical Safety Requirements
- **Production Data Protection**: Production database volumes must NEVER be deleted accidentally
- **Environment Isolation**: Development and production environments must be strictly separated
- **Backup Integrity**: All backups must be verified for size and content
- **Service Isolation**: Different services (e.g., core app vs SearXNG) must run in separate compose stacks

## Recent Incidents
- 2025-04-22: Production DB volume wiped (3rd occurrence) during SearXNG configuration
- Impact: 3-day data loss, recovered from Apr 19 backup
- Root Cause: Lack of safeguards against volume deletion and inadequate backup verification

## Current Status
- Emergency recovery completed with 3-day-old backup
- Implementing critical safety measures before resuming feature work
- All feature work (including SearXNG) is blocked until safety measures are in place

## Product Overview

LedgerFlow is a Django-based application designed to manage and streamline financial ledger operations. The system provides a robust platform for tracking, managing, and analyzing financial transactions and documents.

### Purpose

The primary purpose of LedgerFlow is to:
- Automate financial ledger management
- Provide accurate transaction tracking
- Facilitate document management
- Enable efficient financial reporting
- Streamline workflow processes

### Problems Solved

1. Transaction Management
   - Automated transaction recording
   - Real-time balance tracking
   - Transaction categorization
   - Multi-currency support

2. Document Handling
   - Secure document storage
   - Document version control
   - Automated document processing
   - Document search and retrieval

3. Reporting & Analysis
   - Custom report generation
   - Financial analytics
   - Audit trail maintenance
   - Data visualization

4. Workflow Automation
   - Automated approval processes
   - Task management
   - Notification system
   - Status tracking

### How It Works

#### User Interface
- Clean, intuitive web interface
- Role-based access control
- Responsive design
- Real-time updates

#### Core Functionality
1. Transaction Processing
   - Transaction entry
   - Validation rules
   - Categorization
   - Balance calculation

2. Document Management
   - Upload interface
   - Storage system
   - Version control
   - Search functionality

3. Reporting System
   - Report templates
   - Custom report builder
   - Export options
   - Scheduling

4. Workflow Engine
   - Process definition
   - Task assignment
   - Status tracking
   - Notifications

### Integration Points

- Database (PostgreSQL)
- Authentication system
- File storage
- External APIs (as needed)

### Security Considerations

- Role-based access
- Data encryption
- Audit logging
- Backup systems

### Future Enhancements

1. Planned Features
   - Advanced analytics
   - Mobile application
   - API integrations
   - Automated reconciliation

2. Scalability
   - Performance optimization
   - Infrastructure scaling
   - Feature expansion
   - User base growth

## Key Requirements
1. Development Environment
   - Django 5.0+
   - PostgreSQL 15
   - Python 3.12
   - Docker-based deployment

2. Security
   - Secure file handling
   - Database encryption
   - User authentication
   - Access control

3. Performance
   - Fast PDF processing
   - Efficient database queries
   - Scalable architecture 
# Smart Site Task Manager Walkthrough

I have generated the complete codebase for the "Smart Site Task Manager" as requested.

## 1. Database Schema
Location: `database/schema.sql`
- Created `tasks` table with all specified columns including `extracted_entities` and `suggested_actions` (JSONB).
- Created `task_history` table for audit logs.
- Added a trigger for `updated_at` timestamps.

## 2. Backend API
Location: `backend/server.js`
- **Tech Stack**: Node.js, Express, Supabase Client.
- **Auto-Classification Logic**:
  - Implemented regex-based detection for **Category** (Scheduling, Finance, Technical, Safety).
  - Implemented **Priority** detection (Urgent keywords -> High).
  - Implemented **Entity Extraction** for dates, names, and locations.
  - Implemented **Suggested Actions** mapping based on category.
- **Endpoints**: Implemented all 5 CRUD endpoints.

## 3. Frontend (Flutter)
Location: `frontend/lib/`
- **Tech Stack**: Flutter, Riverpod, Dio.
- **Structure**:
  - `main.dart`: Entry point.
  - `models/task_model.dart`: JSON serialization.
  - `services/api_service.dart`: HTTP calls to backend.
  - `providers/task_provider.dart`: State management.
  - `screens/dashboard_screen.dart`: UI with Summary Cards and Task List with Category Chips and Priority Badges.

## 4. Documentation
Location: `README.md`
- Included setup instructions and API documentation.

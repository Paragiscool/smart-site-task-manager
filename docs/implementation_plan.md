# Smart Site Task Manager Implementation Plan

## Goal Description
Build a "Smart Site Task Manager" system comprising a Node.js backend with auto-classification logic, a Supabase PostgreSQL database, and a Flutter mobile app dashboard.

## Proposed Changes

### Project Structure
Create a root directory `smart_site_task_manager` with subdirectories: `backend`, `frontend`, `database`.

### Database (Supabase/PostgreSQL)
#### [NEW] [schema.sql](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/database/schema.sql)
- Define `tasks` table with fields: id, title, description, category, priority, status, assigned_to, due_date, extracted_entities, suggested_actions, timestamps.
- Define `task_history` table for audit logs.

### Backend API (Node.js)
#### [NEW] [package.json](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/backend/package.json)
- Dependencies: `express`, `cors`, `body-parser`, `pg` (or `output` logic depending on if we mock DB logic or provide real connection code. Prompt implies "Generate the code", so I'll assume standard pg/supabase-js).

#### [NEW] [server.js](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/backend/server.js)
- **Auto-Classification Logic**:
    - **Category**: Regex matches for keywords (meeting -> scheduling, budget -> finance, etc).
    - **Priority**: Regex matches (urgent -> high, etc).
    - **Entity Extraction**: Regex for dates and names.
    - **Suggested Actions**: Map based on category.
- **Endpoints**:
    - `POST /api/tasks`: Apply logic -> Insert to DB.
    - `GET /api/tasks`: Select with filters.
    - `GET /api/tasks/:id`: Select one.
    - `PATCH /api/tasks/:id`: Update.
    - `DELETE /api/tasks/:id`: Delete.

### Flutter Mobile App
#### [NEW] [main.dart](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/frontend/lib/main.dart)
- App entry point, Riverpod `ProviderScope`.

#### [NEW] [task_model.dart](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/frontend/lib/models/task_model.dart)
- Data class for Task.

#### [NEW] [api_service.dart](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/frontend/lib/services/api_service.dart)
- Dio setup for API calls.

#### [NEW] [task_provider.dart](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/frontend/lib/providers/task_provider.dart)
- Riverpod state management.

#### [NEW] [dashboard_screen.dart](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/frontend/lib/screens/dashboard_screen.dart)
- UI: Summary cards, Task List, FAB.

### Documentation
#### [NEW] [README.md](file:///C:/Users/patle/.gemini/antigravity/scratch/smart_site_task_manager/README.md)
- Setup instructions and API docs.

## Verification Plan
### Automated Tests
- N/A for this generation task (User asked for code generation). 
### Manual Verification
- Review generated code against the prompt requirements (specific columns, specific keyword logic).

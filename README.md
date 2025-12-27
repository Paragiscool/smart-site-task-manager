# Smart Site Task Manager

A comprehensive full-stack task management system with auto-classification features.

## Project Overview
This project consists of:
1.  **Database**: Supabase (PostgreSQL) for data storage and audit logs.
2.  **Backend**: Node.js/Express API with logic to auto-classify tasks (Category & Priority) and extract entities.
3.  **Frontend**: Flutter mobile app dashboard for task management.

## Setup Instructions

### Backend
1.  Navigate to `backend` directory.
2.  Run `npm install` to install dependencies.
3.  Create a `.env` file with your Supabase credentials:
    ```
    SUPABASE_URL=your_url
    SUPABASE_KEY=your_key
    PORT=3000
    ```
4.  Run `node server.js` to start the server.

### Database
1.  Run the SQL script in `database/schema.sql` in your Supabase SQL Editor to create the `tasks` and `task_history` tables.

### Frontend (Flutter)
1.  Navigate to `frontend` directory.
2.  Run `flutter pub get` to install dependencies (Riverpod, Dio).
3.  Update `lib/services/api_service.dart` with your local IP or backend URL (default `http://localhost:3000/api`).
4.  Run `flutter run` to launch the app.

## API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/tasks` | Create a task. **Auto-Classification triggers here.** |
| GET | `/api/tasks` | List all tasks. Supports filtering by `status`, `category`, `priority`. |
| GET | `/api/tasks/:id` | Get details of a specific task. |
| PATCH | `/api/tasks/:id` | Update a task (status, etc). |
| DELETE | `/api/tasks/:id` | Delete a task. |

### JSON Example (Task Object)
```json
{
  "id": "uuid...",
  "title": "Fix leaking pipe in basement",
  "description": "Urgent repair needed",
  "category": "technical",
  "priority": "high",
  "status": "pending",
  "extracted_entities": {
    "dates": [],
    "locations": ["basement"]
  },
  "suggested_actions": ["Diagnose issue", "Check resources", "Assign technician", "Document fix"]
}
```

## Architecture Decisions
-   **Supabase**: Chosen for quick setup of a robust PostgreSQL DB with built-in Auth capabilities (though Auth is optional in this specific scope).
-   **Node.js/Express**: Lightweight middleware to handle the custom "Auto-Classification" logic before data reaches the DB.
-   **Flutter + Riverpod**: Separation of UI and business logic using Providers for efficient state management.

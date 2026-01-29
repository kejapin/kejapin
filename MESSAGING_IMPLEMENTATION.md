# Messaging and Notifications Implementation

## Overview
Implemented a complete messaging and notifications system for the kejapin app, including backend API, database models, and Flutter UI screens.

## Backend Implementation

### 1. Database Models (`server/internal/core/domain/messaging.go`)
- **Message**: Stores messages between users
  - Fields: ID, SenderID, RecipientID, PropertyID, Content, IsRead, CreatedAt
- **Notification**: Stores system notifications
  - Fields: ID, UserID, Title, Message, Type, IsRead, CreatedAt
  - Types: MESSAGE, FINANCIAL, SYSTEM

### 2. Repositories (`server/internal/repositories/messaging_repo.go`)
- **MessageRepository**: CRUD operations for messages
  - `CreateMessage()`: Create new message
  - `GetMessagesForUser()`: Fetch all messages for a user
- **NotificationRepository**: CRUD operations for notifications
  - `CreateNotification()`: Create new notification
  - `GetNotificationsForUser()`: Fetch all notifications for a user

### 3. API Handlers (`server/internal/handlers/messaging_handler.go`)
- **GET /api/messaging/messages**: Fetch user messages
- **POST /api/messaging/messages**: Send a new message
- **GET /api/messaging/notifications**: Fetch user notifications

### 4. Routes (`server/cmd/api/main.go`)
- Added messaging group with temporary auth middleware using `X-User-ID` header
- Auto-migrates Message and Notification tables on startup

## Frontend Implementation

### 1. Domain Models
- **MessageEntity** and **NotificationEntity** (`client/lib/features/messages/domain/messaging_entity.dart`)
- **MessageModel** and **NotificationModel** (`client/lib/features/messages/data/messaging_model.dart`)

### 2. Repository (`client/lib/features/messages/data/messaging_repository.dart`)
- **MessagingRepository**: HTTP client for API calls
  - `getMessages()`: Fetch messages
  - `sendMessage()`: Send new message
  - `getNotifications()`: Fetch notifications
  - Uses `X-User-ID` header from SharedPreferences

### 3. UI Screens

#### Messages Screen (`client/lib/features/messages/presentation/screens/messages_screen.dart`)
- **Design**: Based on prototype (messages_inbox)
- **Features**:
  - Search bar for landlord/property search
  - Message tiles with avatar, sender name, property, time, and message preview
  - Unread indicator (gold dot) and online status (green dot)
  - Different styling for read/unread messages
  - Divider between recent and older messages

#### Notifications Screen (`client/lib/features/messages/presentation/screens/notifications_screen.dart`)
- **Design**: Based on prototype (notification_center)
- **Features**:
  - "Mark All Read" button
  - Grouped by categories: Messages, Financial, System
  - Icon-based notification cards
  - Unread indicator (gold dot)
  - Time stamps (relative time)
  - Clean, sectioned layout

#### Profile & Settings Screen (`client/lib/features/profile/presentation/screens/profile_screen.dart`)
- **Design**: Based on prototype (profile_settings)
- **Features**:
  - Profile header with avatar and verified badge
  - Settings groups:
    - Account Security
    - Notification Preferences
    - Payment Methods
    - Help & Support
  - Logout button
  - Version number footer
  - Smooth transitions and hover states

### 4. Navigation Updates
- Added `/notifications` route outside ShellRoute (full-screen experience)
- Updated `CustomAppBar` to navigate to notifications on bell icon tap
- Added gold notification badge indicator

### 5. API Endpoints (`client/lib/core/constants/api_endpoints.dart`)
- `messages`: `/api/messaging/messages`
- `notifications`: `/api/messaging/notifications`

## Authentication Flow
- Modified `AuthRepository` to save `user_id` on login for use in messaging APIs
- Backend uses temporary `X-User-ID` header for authentication (TODO: Replace with JWT)

## Next Steps (TODO)

### Real-time with Centrifugo
1. **Install Centrifugo**: Docker container or binary
2. **Backend Integration**:
   - Add Centrifugo client library to Go
   - Publish message events on create
   - Publish notification events
3. **Frontend Integration**:
   - Add `centrifuge` Dart package
   - Connect to Centrifugo WebSocket
   - Subscribe to user-specific channels
   - Update UI on real-time events

### Security
- Replace `X-User-ID` header with proper JWT authentication
- Add JWT middleware to messaging routes
- Secure Centrifugo channels with JWT tokens

### Features to Implement
- Message threading/conversations (group by property or participant)
- Mark messages as read
- Mark notifications as read
- Delete messages/notifications
- Message search functionality
- Push notifications (FCM/APNs)
- Message delivery status
- Typing indicators

## Testing
- Test messages API: Send `X-User-ID` header with registered user ID
- Test notifications API: Create sample notifications via backend
- Navigate between screens using bottom nav and notification button

## Database Schema
```sql
-- Messages table
CREATE TABLE messages (
  id VARCHAR(36) PRIMARY KEY,
  sender_id VARCHAR(36) NOT NULL,
  recipient_id VARCHAR(36) NOT NULL,
  property_id VARCHAR(36),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Design Consistency
- ✅ All screens follow kejapin design system
- ✅ Uses GoogleFonts (Work Sans, Montserrat)
- ✅ Structural Brown (#4B3621), Muted Gold (#E6AF2E), Alabaster (#F4F1EA)
- ✅ Responsive layouts matching prototypes
- ✅ Consistent shadows, borders, and spacing

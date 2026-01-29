# Kejapin Technology Stack

> **kejapin** - Premium Real Estate & Property Management Platform for Kenya
> Version: 2.4.0 | Last Updated: January 23, 2026

---

## 📱 Frontend

### **Mobile & Web**
- **Flutter** `3.32.5`
  - Cross-platform framework (iOS, Android, Web, Windows, macOS, Linux)
  - Single codebase for all platforms
  - Hot reload for rapid development
  - Material Design 3 components

### **State Management**
- **flutter_bloc** `^9.1.1`
  - Business logic separation
  - Predictable state management
  - Easy testing and debugging

### **Routing & Navigation**
- **go_router** `^17.0.1`
  - Declarative routing
  - Deep linking support
  - Web URL management
  - Nested navigation with ShellRoute

### **UI & Styling**
- **google_fonts** `^7.1.0` - Typography (Montserrat, Work Sans, Lato)
- **flutter_svg** `^2.2.3` - Vector graphics support
- **mesh_gradient** `^1.3.8` - Advanced gradient backgrounds
- **glassmorphism** `^3.0.0` - Modern glass effects

### **Maps & Location**
- **flutter_map** `^8.2.2` - Interactive map display
- **latlong2** `^0.9.1` - Coordinate management

### **Media**
- **video_player** `^2.9.2` - Property video tours
- **image_picker** (planned) - Photo uploads

### **Storage & State Persistence**
- **shared_preferences** `^2.5.4` - Local data storage
  - Auth tokens
  - User preferences
  - Offline cache

---

## ⚙️ Backend (Supabase)

### **Platform**
- **Supabase**
  - Managed Backend-as-a-Service
  - **Database**: PostgreSQL 16+
  - **Auth**: Supabase Auth (Email/Password)
  - **API**: PostgREST (Auto-generated from schema)

### **Database**
- **PostgreSQL** `16+` (via Supabase)
  - ACID compliance
  - Spatial data support (PostGIS ready)
  - Real-time subscriptions
  
### **Authentication & Security**
- **Supabase Auth**
  - Email/Password Sign-in
  - Row Level Security (RLS) for data protection
  - JWT Tokens (handled by Supabase SDK)

### **File Storage & CDN**
- **Backblaze B2** - Primary object storage
  - **Bucket ID**: 9eb4752867e7e4a297b10f12
  - **Type**: Private bucket
  - **Compression**: Gzip compression for all uploads
  - **Library**: `github.com/kurin/blazer/b2`
  - Cost-effective S3-compatible storage
  - Built-in CDN
  - 99.9% uptime SLA

### **Utilities**
- **google/uuid** `v1.6.0` - UUID generation
- **joho/godotenv** `v1.5.1` - Environment variable management

---

## 🔔 Real-Time Communication

### **Centrifugo** (Planned)
- WebSocket server for real-time features
- **Use Cases**:
  - Live chat/messaging
  - Property updates
  - Notification delivery
  - Online presence indicators

- **Client Libraries**:
  - Go: `github.com/centrifugal/gocent`
  - Dart: `centrifuge ^0.11.0`

---

## 🗄️ Database Schema

### **Core Tables**
1. **users**
   - id, email, password_hash, role (TENANT/LANDLORD/ADMIN)
   - created_at, updated_at

2. **properties**
   - id, title, description, property_type, listing_type
   - price_amount, currency, location_name, latitude, longitude
   - photos (JSON array), bedrooms, bathrooms
   - landlord_id, created_at, updated_at

3. **messages**
   - id, sender_id, recipient_id, property_id
   - content, is_read, created_at

4. **notifications**
   - id, user_id, title, message, type
   - is_read, created_at

### **Planned Tables**
- bookings
- payments
- reviews
- maintenance_requests
- documents

---

## 🎨 Design System

### **Color Palette**
- **Primary**: Structural Brown `#4B3621`
- **Secondary**: Muted Gold `#E6AF2E`
- **Background**: Alabaster `#F4F1EA`
- **Surface**: Pure White `#FFFFFF`
- **Text**: Dark Grey `#333333`
- **Accent**: Sage Green `#6B8E23`
- **Error**: Brick Red `#B22222`

### **Typography**
- **Headings**: Montserrat (Bold, 400-700)
- **Body**: Lato (Regular, 300-500)
- **UI Labels**: Work Sans (Medium, 400-600)

### **Spacing System**
- Base unit: 8px
- Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64

### **Border Radius**
- Small: 4px
- Medium: 8px
- Large: 12px
- Extra Large: 16px
- Full: 9999px (circular)

---

## 🛠️ Development Tools

### **Version Control**
- **Git** - Source control
- **GitHub** - Repository hosting

### **IDE & Extensions**
- **VS Code** - Primary IDE
- **Flutter DevTools** - Debugging & profiling
- **Postman** - API testing

### **Build Tools**
- **Flutter CLI** - App compilation
- **Go Build** - Backend compilation
- **Docker** (Planned) - Containerization

### **Testing**
- **flutter_test** - Widget & unit tests
- **Go testing** - Backend unit tests
- Integration tests (planned)

---

## 🌐 Deployment & Infrastructure

### **Hosting**
- **Backend**: 
  - Planned: Render / Railway / Fly.io
  - Database: Managed PostgreSQL (Neon / Supabase)
  
- **Mobile Apps**:
  - iOS: Apple App Store
  - Android: Google Play Store
  
- **Web**:
  - Netlify / Vercel / Firebase Hosting
  - Custom domain with SSL

### **CI/CD** (Planned)
- GitHub Actions
- Automated testing
- Build & deployment pipelines

### **Monitoring** (Planned)
- Sentry - Error tracking
- Google Analytics - User analytics
- Backend logs - Structured logging

---

## 📦 File Structure

```
kejapin/
├── client/                    # Flutter frontend
│   ├── lib/
│   │   ├── core/             # Shared utilities
│   │   │   ├── constants/
│   │   │   ├── theme/
│   │   │   └── widgets/
│   │   ├── features/         # Feature modules
│   │   │   ├── auth/
│   │   │   ├── marketplace/
│   │   │   ├── messages/
│   │   │   └── profile/
│   │   └── main.dart
│   ├── assets/
│   └── pubspec.yaml
│
├── server/                    # Go backend
│   ├── cmd/
│   │   ├── api/              # Main entry point
│   │   └── seed/             # Database seeder
│   ├── config/               # Configuration
│   ├── internal/
│   │   ├── core/
│   │   │   └── domain/       # Domain models
│   │   ├── handlers/         # HTTP handlers
│   │   ├── repositories/     # Data access
│   │   ├── services/         # Business logic
│   │   └── storage/          # File storage (B2)
│   ├── migrations/           # SQL migrations
│   ├── go.mod
│   └── .env
│
├── ui/                        # Design prototypes
│   └── stitch_kejapin_splash_screen/
│
├── start-all.bat             # Multi-platform launcher
├── start-web.bat             # Web-only launcher
├── start-phone.bat           # Mobile launcher
└── stop-all.bat              # Stop all services
```

---

## 🔐 Security Features

### **Implemented**
- ✅ Password hashing (bcrypt)
- ✅ JWT token authentication
- ✅ CORS configuration
- ✅ Input validation
- ✅ SQL injection prevention (GORM)

### **Planned**
- 🔄 Rate limiting
- 🔄 API key authentication
- 🔄 OAuth 2.0 (Google, Facebook)
- 🔄 Two-factor authentication
- 🔄 Encryption at rest
- 🔄 Regular security audits

---

## 📊 Performance Optimizations

### **Backend**
- Gzip compression for file uploads
- Database indexing on frequently queried fields
- Connection pooling
- Caching layer (planned: Redis)

### **Frontend**
- Image lazy loading
- Code splitting
- Asset optimization
- Offline-first architecture (local caching)

### **Storage**
- CDN delivery (Backblaze B2)
- Image resizing and optimization
- Compressed uploads (Gzip)

---

## 🚀 API Endpoints

### **Authentication**
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### **Properties**
- `GET /api/marketplace/listings` - Get all properties
- `GET /api/marketplace/listings/:id` - Get property details
- `POST /api/marketplace/listings` - Create property (landlord)
- `PUT /api/marketplace/listings/:id` - Update property
- `DELETE /api/marketplace/listings/:id` - Delete property

### **Messaging**
- `GET /api/messaging/messages` - Get user messages
- `POST /api/messaging/messages` - Send message
- `GET /api/messaging/notifications` - Get notifications

### **Uploads**
- `POST /api/uploads/image` - Upload single image
- `POST /api/uploads/images` - Upload multiple images

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Active | minSdkVersion: 21 (Android 5.0+) |
| iOS | ✅ Planned | iOS 12.0+ |
| Web | ✅ Active | Chrome, Firefox, Safari, Edge |
| Windows | ✅ Active | Windows 10+ |
| macOS | 🔄 Planned | macOS 10.14+ |
| Linux | 🔄 Planned | Ubuntu 18.04+ |

---

## 🌍 Localization (Future)

- **English** (Primary)
- **Swahili** (Planned)
- Multi-currency support (KES, USD, EUR)
- Date/time formatting

---

## 📄 License

Proprietary - © 2026 kejapin. All rights reserved.

---

## 👥 Team & Contact

**Project**: kejapin Real Estate Platform  
**Version**: 2.4.0  
**Status**: Active Development  
**Last Updated**: January 23, 2026

---

## 📚 Documentation

- [API Documentation](./API_REFERENCE.md) (Planned)
- [Deployment Guide](./DEPLOYMENT.md) (Planned)
- [Contributing Guidelines](./CONTRIBUTING.md) (Planned)
- [Launcher Scripts Guide](./LAUNCHER_GUIDE.md) ✅
- [Messaging Implementation](./MESSAGING_IMPLEMENTATION.md) ✅

---

**Built with ❤️ for the Kenyan real estate market**

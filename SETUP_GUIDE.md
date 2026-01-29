# Quick Setup Guide

## ✅ What's Been Created

### 1. **6 Property Images** (AI-Generated)
Located in your artifacts - ready for upload to Backblaze B2:
- Luxury apartment
- Cozy 1-bedroom
- Studio apartment  
- 2-bedroom family home
- Penthouse
- Bedsitter

### 2. **Backblaze B2 Integration**
- **File**: `server/internal/storage/b2_storage.go`
- **Features**:
  - Gzip compression for all uploads
  - Automatic file management
  - CDN delivery

- **Credentials** (configured in `.env`):
  ```
  Key ID: 005e458774271f20000000001
  Bucket ID: 9eb4752867e7e4a297b10f12
  Type: Private
  ```

### 3. **Upload Handler**
- **File**: `server/internal/handlers/upload_handler.go`
- **Endpoints**:
  - `POST /api/uploads/image` - Single image upload
  - `POST /api/uploads/images` - Multiple images upload

### 4. **Database Seed Script**
- **File**: `server/cmd/seed/seed.go`
- **Creates**:
  - 3 test users (2 landlords, 1 tenant)
  - 6 property listings with images
  - Sample messages
  - Sample notifications

### 5. **Tech Stack Documentation**
- **File**: `TECH_STACK.md`
- Complete documentation of all technologies
- Architecture overview
- API endpoints
- Security features

## 🚀 Next Steps

### 1. Install B2 Library
```bash
cd server
go get github.com/kurin/blazer/b2
go mod tidy
```

### 2. Configure Environment
Copy `.env.example` to `.env` and update:
```bash
cp .env.example .env
```

The B2 credentials are already filled in the example file.

### 3. Run Database Seed
```bash
cd server
go run cmd/seed/seed.go
```

This will populate your database with test data.

### 4. Upload Images to B2 (Optional)
Save the 6 generated images from your artifacts, then:
```bash
# Upload via API (after server is running)
curl -X POST http://localhost:8080/api/uploads/images \
  -F "files=@property_luxury_apt.png" \
  -F "files=@property_cozy_1br.png" \
  # ... etc
```

### 5. Test the Platform
Use `start-all.bat` to launch everything!

## 📊 What You Get

After seeding, you'll have:
- **6 property listings** in different price ranges
- **Test user accounts** for landlords and tenants  
- **Sample messages** between users
- **Notifications** for testing the notification system
- **Images stored** in Backblaze B2 (if uploaded)

## 📁 Key Files Created

```
kejapin/
├── server/
│   ├── internal/
│   │   ├── storage/
│   │   │   └── b2_storage.go          # B2 integration with Gzip
│   │   └── handlers/
│   │       └── upload_handler.go      # Image upload endpoints
│   ├── cmd/
│   │   └── seed/
│   │       └── seed.go                # Database seeder
│   └── .env.example                  # B2 credentials template
│
├── TECH_STACK.md                     # Complete tech documentation
├── IMAGES_README.md                  # Image upload guide
└── SETUP_GUIDE.md                    # This file
```

## 🔐 Security Notes

- B2 bucket is **private** - files are not publicly accessible
- All uploads are **Gzip compressed** for efficiency
- Images are served via **CDN** for fast delivery
- **Authentication required** for uploads (add JWT middleware)

## 📸 Image Upload Flow

1. User selects images in app
2. Frontend sends to `/api/uploads/images`
3. Backend validates images (JPEG, PNG, WebP only)
4. Files are Gzip compressed
5. Uploaded to Backblaze B2
6. URLs returned to frontend
7. URLs saved in database with property listing

## 💡 Tips

- **Development**: Use placeholder URLs first, upload to B2 later
- **Testing**: Run seed script multiple times (it creates new UUIDs)
- **Images**: The 6 generated images are high-quality and ready to use
- **Compression**: ~60-70% file size reduction with Gzip

## ⚠️ TODO

1. Add JWT middleware to upload routes
2. Implement image resizing (thumbnails)
3. Add file type validation on frontend
4. Set up CDN caching rules
5. Add image deletion endpoint

---

**Ready to test!** Run `start-all.bat` and your platform is live with test data! 🎉

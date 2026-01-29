# Generated Property Images

This folder contains 6 AI-generated property images for testing the kejapin platform.

## Images

1. **property_luxury_apt** - Modern luxury apartment with city views
2. **property_cozy_1br** - Cozy one-bedroom apartment  
3. **property_studio_apt** - Efficient studio apartment
4. **property_2br_family** - Spacious two-bedroom family home
5. **property_penthouse** - Premium penthouse with panoramic views
6. **property_bedsitter** - Affordable bedsitter apartment

## Usage

These images are used in the database seed script (`server/cmd/seed/seed.go`) to create test property listings.

### Upload to Backblaze B2

To upload these images to your Backblaze B2 storage:

1. Set up your B2 credentials in `.env`:
```env
B2_KEY_ID=005e458774271f20000000001
B2_KEY_NAME=keja-pin-dev
B2_APPLICATION_KEY=K005kRLqQmOD0Lx5w0Bbp5rNHKyZ/TM
B2_BUCKET_ID=9eb4752867e7e4a297b10f12
B2_BUCKET_NAME=kejapin-storage
```

2. Use the upload API endpoint:
```bash
curl -X POST http://localhost:8080/api/uploads/image \
  -F "file=@property_luxury_apt.png" \
  -H "Content-Type: multipart/form-data"
```

3. Or upload multiple at once:
```bash
curl -X POST http://localhost:8080/api/uploads/images \
  -F "files=@property_luxury_apt.png" \
  -F "files=@property_cozy_1br.png" \
  -F "files=@property_studio_apt.png" \
  -F "files=@property_2br_family.png" \
  -F "files=@property_penthouse.png" \
  -F "files=@property_bedsitter.png"
```

### Features

- **Gzip Compression**: All uploads are automatically compressed
- **CDN Delivery**: Served via Backblaze B2 CDN
- **Private Bucket**: Secure storage with access control

### Image Details

All images are:
- **Format**: PNG
- **Use Case**: Real estate property listings
- **Quality**: High resolution for showcasing properties
- **Compression**: Gzip compressed on upload

## Seed Database

To create test listings with these images:

```bash
cd server
go run cmd/seed/seed.go
```

This will create:
- 3 test users (2 landlords, 1 tenant)
- 6 property listings with the images
- Sample messages and notifications

## Notes

- Images are AI-generated for demonstration purposes
- Replace with real property photos in production
- Ensure proper licensing for any real images used

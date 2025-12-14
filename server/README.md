# Trekka Server - Backend API

Backend API cho ứng dụng Trekka - Nền tảng khám phá và lập kế hoạch du lịch thông minh với AI.

## 📋 Tổng quan

Server được xây dựng với:
- **Node.js** + **Express.js**
- **PostgreSQL** với **PostGIS** extension (geospatial queries)
- **Sequelize ORM**
- **JWT Authentication**
- **Swagger** API Documentation

## 🚀 Cài đặt

### 1. Clone repository và cài đặt dependencies

```bash
cd server
npm install
```

### 2. Cấu hình môi trường

Tạo file `.env` trong thư mục `server/`:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=trekka_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_REFRESH_SECRET=your_refresh_secret_key
JWT_EXPIRES_IN=1d
JWT_REFRESH_EXPIRES_IN=7d

# Server
PORT=3000
NODE_ENV=development

# Email (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

### 3. Setup Database

Đảm bảo PostgreSQL đã cài đặt và enable PostGIS extension:

```sql
CREATE DATABASE trekka_db;
\c trekka_db;
CREATE EXTENSION postgis;
```

### 4. Chạy server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại `http://localhost:3000`

## 📚 API Documentation

Chi tiết đầy đủ về API: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

Swagger UI: `http://localhost:3000/api-docs`

## 🗂️ Cấu trúc thư mục

```
server/
├── config/                 # Configuration files
│   └── travelConstants.js  # Travel style constants
├── controllers/            # Request handlers
│   ├── auth.controller.js
│   ├── destination.controller.js
│   ├── event.controller.js
│   ├── group.controller.js
│   ├── notification.controller.js
│   ├── review.controller.js
│   ├── trip.controller.js
│   └── user.controller.js
├── database/              # Database connection & seeds
│   ├── db.js
│   └── seed.js
├── middleware/            # Express middlewares
│   ├── authenticate.js    # JWT verification
│   ├── authorize.js       # Role-based access
│   └── errorHandler.js    # Global error handler
├── models/                # Sequelize models
│   ├── associations.js    # Model relationships
│   ├── destination.model.js
│   ├── destinationCategory.model.js
│   ├── event.model.js
│   ├── group.model.js
│   ├── groupComment.model.js
│   ├── groupMember.model.js
│   ├── notification.model.js
│   ├── profile.model.js
│   ├── review.model.js
│   ├── trip.model.js
│   ├── tripDestination.model.js
│   ├── tripEvent.model.js
│   ├── tripShare.model.js
│   ├── userFeedback.model.js
│   ├── aiRequest.model.js
│   ├── aiResponse.model.js
│   ├── searchLog.model.js
│   └── tokenBlacklist.model.js
├── routes/                # API routes
│   ├── auth.routes.js
│   ├── destination.routes.js
│   ├── event.routes.js
│   ├── group.routes.js
│   ├── main.routes.js
│   ├── notification.routes.js
│   ├── review.routes.js
│   ├── trip.routes.js
│   └── user.routes.js
├── services/              # Business logic
│   ├── destination.service.js
│   ├── event.service.js
│   ├── group.service.js
│   ├── notification.service.js
│   ├── review.service.js
│   ├── trip.service.js
│   └── user.service.js
├── utils/                 # Utility functions
│   ├── logger.js
│   └── validator.js
├── index.js              # Entry point
├── swagger.js            # Swagger configuration
└── package.json
```

## 🎯 Modules chính

### 1. Authentication & User Management
- Đăng ký, đăng nhập, đăng xuất
- JWT token + Refresh token
- Password reset
- Profile management
- Track total_likes và total_checkins

### 2. Destinations (Địa điểm)
- CRUD destinations
- Filter nâng cao (location, price, category, context)
- Geospatial search với PostGIS
- Like/Unlike (toggle)
- Check-in tracking
- AI recommendations

### 3. Events (Sự kiện)
- CRUD events
- Filter theo time, location, type
- Like events
- Upcoming events near location

### 4. Trips (Quản lý chuyến đi)
- Tạo, sửa, xóa trips
- Thêm destinations & events vào trip
- Reorder items trong trip
- Change trip status (draft → active → completed)
- Timeline view với thời gian và khoảng cách

### 5. Reviews (Đánh giá)
- Review destinations & events
- Sentiment analysis (positive/negative/neutral)
- Rating aggregation
- Helpful votes

### 6. Groups & Social
- Tạo và quản lý nhóm
- Thêm/xóa members
- Share trips to groups
- Comment & discuss trips

### 7. Notifications
- Reminder notifications (trips, events)
- Progress notifications
- Social notifications (comments, invitations)
- Mark as read/unread
- Scheduled notifications

## 🔑 Key Features

### Like = Save
- Like một địa điểm = Lưu vào yêu thích
- Toggle: Click lại để unlike
- **Đã bỏ tính năng "save" riêng biệt**

### User Feedback System
- Like: Thích địa điểm/sự kiện
- Check-in: Xác nhận đã đến thực tế
- Track trong bảng `user_feedback`
- Tự động update counters trong `profiles`

### Geospatial Queries
- PostGIS extension
- ST_Distance: Tính khoảng cách
- ST_DWithin: Filter theo bán kính
- Sort by distance

### AI Integration Ready
- Bảng `ai_requests` & `ai_responses`
- Log mọi interaction với AI
- Sẵn sàng cho fine-tuning models
- Sentiment analysis trong reviews

## 📊 Database Models

### Core Tables
- **profiles**: User accounts + preferences + stats
- **destinations**: POI với geolocation
- **destination_categories**: Categories & travel styles
- **events**: Events/activities
- **reviews**: User reviews với sentiment
- **trips**: Trip itineraries
- **trip_destinations**: N-N relation
- **trip_events**: N-N relation
- **user_feedback**: Likes & check-ins

### Social Tables
- **groups**: User groups
- **group_members**: Group membership
- **trip_shares**: Shared trips
- **group_comments**: Comments & replies

### System Tables
- **notifications**: Notification queue
- **token_blacklist**: Revoked tokens
- **ai_requests**: AI request logs
- **ai_responses**: AI response logs
- **search_logs**: Search analytics

## 🔒 Security

- **JWT Authentication**: Access token + Refresh token
- **Password Hashing**: bcrypt
- **Token Blacklist**: Logout token revocation
- **CORS Configuration**: Whitelist origins
- **Input Validation**: Sanitize user inputs
- **Role-based Access**: Admin vs User

## 🧪 Testing

```bash
# Run tests (if available)
npm test
```

## 📝 API Endpoints Summary

| Module | Endpoint | Method | Auth |
|--------|----------|--------|------|
| **Auth** | `/auth/register` | POST | ❌ |
| | `/auth/login` | POST | ❌ |
| | `/auth/logout` | POST | ✅ |
| **Destinations** | `/destinations` | GET | ❌ |
| | `/destinations/:id` | GET | ❌ |
| | `/destinations/:id/like` | POST | ✅ |
| | `/destinations/:id/checkin` | POST | ✅ |
| **Events** | `/events` | GET | ❌ |
| | `/events/:id/like` | POST | ✅ |
| **Trips** | `/trips` | GET | ✅ |
| | `/trips` | POST | ✅ |
| | `/trips/:id/destinations` | POST | ✅ |
| **Reviews** | `/reviews` | POST | ✅ |
| | `/reviews/destinations/:destId` | GET | ❌ |
| **Groups** | `/groups` | POST | ✅ |
| | `/groups/:id/members` | POST | ✅ |
| | `/groups/share-trip` | POST | ✅ |
| **Notifications** | `/notifications` | GET | ✅ |

Xem chi tiết: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## 🛠️ Development

### Code Style
- Clean Architecture
- Service Layer Pattern
- Controller → Service → Model
- Consistent error handling

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature
```

## 📈 Performance Tips

1. **Database Indexing**: Đã add indexes cho geospatial queries
2. **Pagination**: Luôn dùng page/limit
3. **Select Fields**: Chỉ lấy fields cần thiết
4. **Caching**: TODO - Redis cache
5. **Connection Pooling**: Sequelize pool config

## 🐛 Troubleshooting

### PostGIS not found
```sql
CREATE EXTENSION postgis;
```

### Port already in use
```bash
# Kill process on port 3000
npx kill-port 3000
```

### Database connection error
- Check PostgreSQL service đang chạy
- Verify credentials trong `.env`
- Check firewall settings

## 📞 Support

- **Documentation**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Issues**: Create GitHub issue
- **Email**: support@trekka.com

## 📄 License

MIT License - Trekka Team 2025

---

**Happy Coding! 🚀**


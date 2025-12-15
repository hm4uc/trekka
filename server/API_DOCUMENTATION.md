# TREKKA API DOCUMENTATION

## Tổng quan
API Backend cho ứng dụng Trekka - Nền tảng khám phá và lập kế hoạch du lịch thông minh với AI.

**Base URL:** `http://localhost:3000`  
**API Version:** 1.0.0

---

## Authentication

Tất cả các endpoint có đánh dấu 🔒 yêu cầu JWT token trong header:
```
Authorization: Bearer <token>
```

---

## 1. MODULE: AUTHENTICATION & USER MANAGEMENT

### 1.1. Auth Routes (`/auth`)

#### **POST /auth/register**
Đăng ký tài khoản mới

**Request Body:**
```json
{
  "usr_fullname": "Nguyễn Minh Anh",
  "usr_email": "minhanh@example.com",
  "usr_password": "password123",
  "usr_gender": "female",
  "usr_age": 24,
  "usr_job": "marketing",
  "usr_preferences": ["nature", "food_drink"],
  "usr_budget": 600000
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "uuid",
      "usr_fullname": "Nguyễn Minh Anh",
      "usr_email": "minhanh@example.com"
    },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

---

#### **POST /auth/login**
Đăng nhập

**Request Body:**
```json
{
  "usr_email": "minhanh@example.com",
  "usr_password": "password123"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "uuid",
      "usr_fullname": "Nguyễn Minh Anh",
      "usr_email": "minhanh@example.com",
      "usr_preferences": ["nature", "food_drink"],
      "total_likes": 0,
      "total_checkins": 0
    },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

---

#### **POST /auth/refresh**
Làm mới access token

**Request Body:**
```json
{
  "refreshToken": "refresh_token"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "accessToken": "new_jwt_token"
  }
}
```

---

#### **POST /auth/logout** 🔒
Đăng xuất

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

---

### 1.2. User Routes (`/user`)

#### **GET /user/profile** 🔒
Lấy thông tin profile người dùng

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "usr_fullname": "Nguyễn Minh Anh",
    "usr_email": "minhanh@example.com",
    "usr_gender": "female",
    "usr_age": 24,
    "usr_job": "marketing",
    "usr_preferences": ["nature", "food_drink"],
    "usr_budget": 600000,
    "usr_avatar": "url",
    "usr_bio": "Bio text",
    "total_likes": 15,
    "total_checkins": 8,
    "usr_created_at": "2025-01-01T00:00:00.000Z"
  }
}
```

---

#### **PUT /user/profile** 🔒
Cập nhật profile

**Request Body:**
```json
{
  "usr_fullname": "Nguyễn Minh Anh",
  "usr_bio": "Travel enthusiast",
  "usr_preferences": ["nature", "culture_history"],
  "usr_budget": 800000
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Profile updated successfully",
  "data": {
    "id": "uuid",
    "usr_fullname": "Nguyễn Minh Anh",
    "usr_bio": "Travel enthusiast"
  }
}
```

---

## 2. MODULE: DESTINATIONS

### 2.1. Destination Routes (`/destinations`)

#### **GET /destinations**
Lấy danh sách địa điểm (có filter & search)

**Query Parameters:**
- `page` (number): Trang hiện tại (default: 1)
- `limit` (number): Số items per page (default: 10)
- `search` (string): Tìm kiếm theo tên
- `categoryId` (uuid): Filter theo category
- `minPrice` (number): Giá tối thiểu
- `maxPrice` (number): Giá tối đa
- `lat` (number): Vĩ độ
- `lng` (number): Kinh độ
- `radius` (number): Bán kính tìm kiếm (meters, default: 5000)
- `isOpenNow` (boolean): Chỉ lấy địa điểm đang mở cửa
- `context` (string): Context tag (solo, couple, friends...)
- `sortBy` (string): distance | rating | price_asc | price_desc | popularity
- `hiddenGemsOnly` (boolean): Chỉ lấy hidden gems

**Example:**
```
GET /destinations?lat=21.0285&lng=105.8542&radius=5000&sortBy=distance&limit=10
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 50,
    "currentPage": 1,
    "totalPages": 5,
    "data": [
      {
        "id": "uuid",
        "name": "The Ylang Coffee",
        "description": "Quán cafe view Hồ Gươm",
        "address": "Hà Nội",
        "lat": 21.0285,
        "lng": 105.8542,
        "avg_cost": 80000,
        "rating": 4.3,
        "total_reviews": 120,
        "total_likes": 450,
        "total_checkins": 300,
        "tags": ["cafe", "view", "romantic"],
        "opening_hours": {
          "mon": "8:00-22:00",
          "tue": "8:00-22:00"
        },
        "images": ["url1", "url2"],
        "ai_summary": "Yên tĩnh, phù hợp làm việc, giá trung bình",
        "is_hidden_gem": false,
        "category": {
          "id": "uuid",
          "name": "Cafe",
          "icon": "coffee"
        }
      }
    ]
  }
}
```

---

#### **GET /destinations/:id**
Lấy chi tiết 1 địa điểm

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "name": "The Ylang Coffee",
    "description": "Quán cafe view Hồ Gươm đẹp nhất Hà Nội...",
    "address": "Số 1 Lê Thái Tổ, Hoàn Kiếm, Hà Nội",
    "lat": 21.0285,
    "lng": 105.8542,
    "avg_cost": 80000,
    "rating": 4.3,
    "total_reviews": 120,
    "total_likes": 450,
    "total_checkins": 300,
    "tags": ["cafe", "view", "romantic", "work-friendly"],
    "opening_hours": {
      "mon": "8:00-22:00",
      "tue": "8:00-22:00",
      "wed": "8:00-22:00",
      "thu": "8:00-22:00",
      "fri": "8:00-23:00",
      "sat": "8:00-23:00",
      "sun": "8:00-22:00"
    },
    "images": ["url1", "url2", "url3"],
    "ai_summary": "Quán cafe yên tĩnh, view đẹp, phù hợp cho làm việc hoặc hẹn hò. Giá trung bình.",
    "best_time_to_visit": "Buổi chiều 16:00-18:00",
    "recommended_duration": 90,
    "contact_info": {
      "phone": "0123456789",
      "website": "https://ylangcoffee.com"
    },
    "category": {
      "id": "uuid",
      "name": "Cafe",
      "icon": "coffee",
      "description": "Các quán cafe đẹp"
    }
  }
}
```

---

#### **GET /destinations/:id/nearby**
Lấy danh sách địa điểm gần đó

**Query Parameters:**
- `limit` (number): Số lượng kết quả (default: 5)
- `radius` (number): Bán kính (meters, default: 2000)

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "name": "Bảo tàng Lịch sử",
      "lat": 21.0290,
      "lng": 105.8550,
      "avg_cost": 50000,
      "rating": 4.5
    }
  ]
}
```

---

#### **POST /destinations/:id/like** 🔒
Like/Unlike địa điểm (toggle)

**Response:**
```json
{
  "status": "success",
  "message": "Đã like địa điểm", // hoặc "Đã bỏ like địa điểm"
  "data": {
    "isLiked": true,
    "total_likes": 451
  }
}
```

---

#### **POST /destinations/:id/checkin** 🔒
Check-in tại địa điểm

**Response:**
```json
{
  "status": "success",
  "message": "Đã check-in thành công",
  "data": {
    "total_checkins": 301
  }
}
```

---

#### **GET /destinations/categories**
Lấy tất cả categories

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "name": "Cafe",
      "icon": "coffee",
      "description": "Các quán cafe đẹp",
      "travel_style_id": "food_drink",
      "context_tags": ["solo", "couple", "friends"],
      "avg_visit_duration": 60
    }
  ]
}
```

---

#### **GET /destinations/categories/travel-style/:travelStyle**
Lấy categories theo travel style

**Path Params:**
- `travelStyle`: nature | culture_history | food_drink | chill_relax | adventure | shopping_entertainment | luxury | local_life

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "name": "Cafe",
      "icon": "coffee",
      "travel_style_id": "food_drink"
    }
  ]
}
```

---

#### **GET /destinations/ai-picks** 🔒
Lấy gợi ý địa điểm AI cá nhân hóa

**Query Parameters:**
- `lat` (number): Vĩ độ
- `lng` (number): Kinh độ
- `limit` (number): Số lượng (default: 10)

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "name": "The Ylang Coffee",
      "rating": 4.3,
      "total_likes": 450
    }
  ]
}
```

---

## 3. MODULE: EVENTS

### 3.1. Event Routes (`/events`)

#### **GET /events**
Lấy danh sách sự kiện

**Query Parameters:**
- `page`, `limit`: Phân trang
- `search`: Tìm kiếm
- `eventType`: concert | exhibition | festival | workshop
- `lat`, `lng`, `radius`: Vị trí
- `startDate`, `endDate`: Khoảng thời gian
- `minPrice`, `maxPrice`: Khoảng giá
- `sortBy`: date | popularity | price_asc | price_desc | distance

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 20,
    "currentPage": 1,
    "totalPages": 2,
    "data": [
      {
        "id": "uuid",
        "event_name": "Hanoi Art Exhibition 2025",
        "event_description": "Triển lãm nghệ thuật...",
        "event_location": "Tràng Tiền Plaza",
        "lat": 21.0245,
        "lng": 105.8512,
        "event_start": "2025-01-15T15:00:00.000Z",
        "event_end": "2025-01-15T20:00:00.000Z",
        "event_ticket_price": 50000,
        "event_type": "exhibition",
        "images": ["url1"],
        "total_likes": 80
      }
    ]
  }
}
```

---

#### **GET /events/:id**
Lấy chi tiết sự kiện

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "event_name": "Hanoi Art Exhibition 2025",
    "event_description": "Triển lãm nghệ thuật hiện đại...",
    "event_location": "Tràng Tiền Plaza",
    "lat": 21.0245,
    "lng": 105.8512,
    "event_start": "2025-01-15T15:00:00.000Z",
    "event_end": "2025-01-15T20:00:00.000Z",
    "event_ticket_price": 50000,
    "event_type": "exhibition",
    "event_organizer": "Hanoi Art Center",
    "event_capacity": 200,
    "event_tags": ["art", "culture", "indoor"],
    "images": ["url1", "url2"],
    "contact_info": {
      "phone": "0987654321",
      "email": "info@hanoiart.com"
    },
    "total_attendees": 150,
    "total_likes": 80,
    "is_featured": true
  }
}
```

---

#### **GET /events/upcoming**
Lấy sự kiện sắp diễn ra

**Query Parameters:**
- `lat`, `lng`: Vị trí
- `radius` (default: 5000)
- `limit` (default: 10)

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "event_name": "Hanoi Art Exhibition 2025",
      "event_start": "2025-01-15T15:00:00.000Z"
    }
  ]
}
```

---

#### **POST /events/:id/like** 🔒
Like/Unlike sự kiện (toggle)

**Response:**
```json
{
  "status": "success",
  "message": "Đã like sự kiện",
  "data": {
    "isLiked": true,
    "total_likes": 81
  }
}
```

---

#### **POST /events/:id/checkin** 🔒
Check-in tại sự kiện

**Response:**
```json
{
  "status": "success",
  "message": "Đã check-in tại sự kiện",
  "data": {
    "id": "uuid",
    "event_name": "Hanoi Art Exhibition 2025",
    "total_attendees": 151
  }
}
```

**Error (400):**
```json
{
  "status": "error",
  "message": "Already checked in at this event"
}
```

---

### 3.2. User Activity Routes (`/user`)

#### **GET /user/liked** 🔒
Lấy danh sách địa điểm và sự kiện đã like

**Query Parameters:**
- `page` (default: 1): Số trang
- `limit` (default: 10): Số lượng items mỗi trang
- `type`: destination | event (optional - không truyền sẽ lấy cả 2)

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 25,
    "currentPage": 1,
    "totalPages": 3,
    "data": [
      {
        "type": "destination",
        "liked_at": "2025-01-14T10:30:00.000Z",
        "id": "uuid",
        "dest_name": "The Ylang Coffee",
        "dest_description": "Quán cafe view Hồ Gươm",
        "dest_avg_cost": 80000,
        "dest_category_id": "cafe",
        "lat": 21.0285,
        "lng": 105.8542,
        "total_likes": 150,
        "total_checkins": 80
      },
      {
        "type": "event",
        "liked_at": "2025-01-13T15:20:00.000Z",
        "id": "uuid",
        "event_name": "Hanoi Art Exhibition 2025",
        "event_description": "Triển lãm nghệ thuật hiện đại",
        "event_ticket_price": 50000,
        "event_start": "2025-01-15T15:00:00.000Z",
        "event_end": "2025-01-15T20:00:00.000Z",
        "total_likes": 81,
        "total_attendees": 151
      }
    ]
  }
}
```

**Example with type filter:**
```
GET /user/liked?type=destination&page=1&limit=10
```

---

#### **GET /user/checkins** 🔒
Lấy danh sách địa điểm và sự kiện đã check-in

**Query Parameters:**
- `page` (default: 1): Số trang
- `limit` (default: 10): Số lượng items mỗi trang
- `type`: destination | event (optional - không truyền sẽ lấy cả 2)

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 15,
    "currentPage": 1,
    "totalPages": 2,
    "data": [
      {
        "type": "destination",
        "checkin_at": "2025-01-14T14:30:00.000Z",
        "checkin_metadata": {
          "checkin_time": "2025-01-14T14:30:00.000Z",
          "lat": 21.0285,
          "lng": 105.8542
        },
        "id": "uuid",
        "dest_name": "The Ylang Coffee",
        "dest_description": "Quán cafe view Hồ Gươm",
        "dest_avg_cost": 80000,
        "total_likes": 150,
        "total_checkins": 81
      },
      {
        "type": "event",
        "checkin_at": "2025-01-15T15:00:00.000Z",
        "checkin_metadata": {
          "checkin_time": "2025-01-15T15:00:00.000Z",
          "lat": 21.0245,
          "lng": 105.8512
        },
        "id": "uuid",
        "event_name": "Hanoi Art Exhibition 2025",
        "event_ticket_price": 50000,
        "event_start": "2025-01-15T15:00:00.000Z",
        "total_attendees": 151
      }
    ]
  }
}
```

**Example with type filter:**
```
GET /user/checkins?type=event&page=1&limit=5
```

---

## 4. MODULE: TRIPS (Quản lý chuyến đi)

### 4.1. Trip Routes (`/trips`)

#### **GET /trips** 🔒
Lấy danh sách chuyến đi của user

**Query Parameters:**
- `page`, `limit`: Phân trang
- `status`: draft | active | completed | cancelled

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 5,
    "currentPage": 1,
    "totalPages": 1,
    "data": [
      {
        "id": "uuid",
        "trip_title": "Một ngày khám phá Hà Nội",
        "trip_description": null,
        "trip_start_date": "2025-01-15T00:00:00.000Z",
        "trip_end_date": "2025-01-15T00:00:00.000Z",
        "trip_budget": 600000,
        "trip_actual_cost": 0,
        "trip_status": "draft",
        "trip_transport": "walking",
        "trip_type": "solo",
        "participant_count": 1,
        "visibility": "private",
        "total_distance": 0,
        "total_duration": 0,
        "tripDestinations": [
          {
            "id": "uuid",
            "visit_order": 1,
            "estimated_time": 90,
            "destination": {
              "id": "uuid",
              "name": "The Ylang Coffee",
              "images": ["url1"],
              "avg_cost": 80000
            }
          }
        ],
        "tripEvents": []
      }
    ]
  }
}
```

---

#### **GET /trips/:id** 🔒
Lấy chi tiết 1 chuyến đi

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "trip_title": "Một ngày khám phá Hà Nội",
    "trip_start_date": "2025-01-15T00:00:00.000Z",
    "trip_end_date": "2025-01-15T00:00:00.000Z",
    "trip_budget": 600000,
    "trip_status": "draft",
    "user": {
      "id": "uuid",
      "usr_fullname": "Nguyễn Minh Anh",
      "usr_avatar": "url"
    },
    "tripDestinations": [
      {
        "id": "uuid",
        "visit_order": 1,
        "estimated_time": 90,
        "visit_date": "2025-01-15",
        "start_time": "08:00:00",
        "notes": "Ghé sáng sớm",
        "destination": {
          "id": "uuid",
          "name": "The Ylang Coffee",
          "lat": 21.0285,
          "lng": 105.8542,
          "avg_cost": 80000
        }
      }
    ],
    "tripEvents": []
  }
}
```

---

#### **POST /trips** 🔒
Tạo chuyến đi mới

**Request Body:**
```json
{
  "trip_title": "Một ngày khám phá Hà Nội",
  "trip_description": "Chuyến đi chill cuối tuần",
  "trip_start_date": "2025-01-15",
  "trip_end_date": "2025-01-15",
  "trip_budget": 600000,
  "trip_transport": "walking",
  "trip_type": "solo",
  "participant_count": 1,
  "visibility": "private"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Trip created successfully",
  "data": {
    "id": "uuid",
    "trip_title": "Một ngày khám phá Hà Nội",
    "trip_status": "draft"
  }
}
```

---

#### **PUT /trips/:id** 🔒
Cập nhật chuyến đi

**Request Body:**
```json
{
  "trip_title": "Hai ngày khám phá Hà Nội",
  "trip_budget": 800000,
  "participant_count": 2
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Trip updated successfully",
  "data": {
    "id": "uuid",
    "trip_title": "Hai ngày khám phá Hà Nội"
  }
}
```

---

#### **DELETE /trips/:id** 🔒
Xóa chuyến đi

**Response:**
```json
{
  "status": "success",
  "message": "Trip deleted successfully"
}
```

---

#### **PATCH /trips/:id/status** 🔒
Thay đổi trạng thái chuyến đi

**Request Body:**
```json
{
  "status": "active"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Trip status updated",
  "data": {
    "id": "uuid",
    "trip_status": "active"
  }
}
```

---

#### **POST /trips/:id/destinations** 🔒
Thêm địa điểm vào chuyến đi

**Request Body:**
```json
{
  "destId": "uuid",
  "visitOrder": 1,
  "estimatedTime": 90,
  "visitDate": "2025-01-15",
  "startTime": "08:00",
  "notes": "Ghé sáng sớm"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Destination added to trip",
  "data": {
    "id": "uuid",
    "trip_id": "uuid",
    "dest_id": "uuid",
    "visit_order": 1
  }
}
```

---

#### **DELETE /trips/:id/destinations/:destId** 🔒
Xóa địa điểm khỏi chuyến đi

**Response:**
```json
{
  "status": "success",
  "message": "Destination removed from trip"
}
```

---

#### **PUT /trips/:id/destinations/reorder** 🔒
Sắp xếp lại thứ tự các địa điểm

**Request Body:**
```json
{
  "destinationOrders": [
    {"dest_id": "uuid1", "visit_order": 1},
    {"dest_id": "uuid2", "visit_order": 2},
    {"dest_id": "uuid3", "visit_order": 3}
  ]
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Destinations reordered successfully"
}
```

---

#### **POST /trips/:id/events** 🔒
Thêm sự kiện vào chuyến đi

**Request Body:**
```json
{
  "eventId": "uuid",
  "visitOrder": 3,
  "notes": "Tham dự triển lãm"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Event added to trip",
  "data": {
    "id": "uuid",
    "trip_id": "uuid",
    "event_id": "uuid"
  }
}
```

---

#### **DELETE /trips/:id/events/:eventId** 🔒
Xóa sự kiện khỏi chuyến đi

**Response:**
```json
{
  "status": "success",
  "message": "Event removed from trip"
}
```

---

## 5. MODULE: REVIEWS (Đánh giá)

### 5.1. Review Routes (`/reviews`)

#### **POST /reviews** 🔒
Tạo đánh giá mới

**Request Body:**
```json
{
  "destId": "uuid",
  "rating": 5,
  "comment": "Không gian đẹp, nhiều tranh ấn tượng!",
  "images": ["url1", "url2"]
}
```
*Hoặc review event:*
```json
{
  "eventId": "uuid",
  "rating": 4,
  "comment": "Sự kiện tuyệt vời!"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Review created successfully",
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "dest_id": "uuid",
    "rating": 5,
    "comment": "Không gian đẹp, nhiều tranh ấn tượng!",
    "sentiment": "positive",
    "images": ["url1", "url2"]
  }
}
```

---

#### **GET /reviews/destinations/:destId**
Lấy danh sách đánh giá cho địa điểm

**Query Parameters:**
- `page`, `limit`: Phân trang
- `sortBy`: recent | rating_high | rating_low | helpful

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 120,
    "currentPage": 1,
    "totalPages": 12,
    "data": [
      {
        "id": "uuid",
        "rating": 5,
        "comment": "Không gian đẹp, nhiều tranh ấn tượng!",
        "sentiment": "positive",
        "images": ["url1"],
        "helpful_count": 10,
        "is_verified_visit": true,
        "createdAt": "2025-01-15T10:00:00.000Z",
        "user": {
          "id": "uuid",
          "usr_fullname": "Nguyễn Minh Anh",
          "usr_avatar": "url"
        }
      }
    ]
  }
}
```

---

#### **GET /reviews/events/:eventId**
Lấy danh sách đánh giá cho sự kiện

**Query Parameters:**
- `page`, `limit`

**Response:** (Tương tự reviews destinations)

---

#### **GET /reviews/my-reviews** 🔒
Lấy danh sách đánh giá của user

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 5,
    "data": [
      {
        "id": "uuid",
        "rating": 5,
        "comment": "Tuyệt vời!",
        "destination": {
          "id": "uuid",
          "name": "The Ylang Coffee",
          "images": ["url1"]
        },
        "event": null
      }
    ]
  }
}
```

---

#### **PUT /reviews/:id** 🔒
Cập nhật đánh giá

**Request Body:**
```json
{
  "rating": 4,
  "comment": "Updated comment"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Review updated successfully",
  "data": {
    "id": "uuid",
    "rating": 4,
    "comment": "Updated comment"
  }
}
```

---

#### **DELETE /reviews/:id** 🔒
Xóa đánh giá

**Response:**
```json
{
  "status": "success",
  "message": "Review deleted successfully"
}
```

---

#### **POST /reviews/:id/helpful**
Đánh dấu review hữu ích

**Response:**
```json
{
  "status": "success",
  "message": "Marked as helpful",
  "data": {
    "id": "uuid",
    "helpful_count": 11
  }
}
```

---

## 6. MODULE: GROUPS (Nhóm & Chia sẻ)

### 6.1. Group Routes (`/groups`)

#### **POST /groups** 🔒
Tạo nhóm mới

**Request Body:**
```json
{
  "group_name": "Team Marketing Hà Nội",
  "group_description": "Nhóm đi du lịch cuối tuần",
  "group_avatar": "url"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Group created successfully",
  "data": {
    "id": "uuid",
    "group_name": "Team Marketing Hà Nội",
    "created_by": "uuid"
  }
}
```

---

#### **GET /groups** 🔒
Lấy danh sách nhóm của user

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "group_name": "Team Marketing Hà Nội",
      "group_description": "Nhóm đi du lịch cuối tuần",
      "group_avatar": "url",
      "creator": {
        "id": "uuid",
        "usr_fullname": "Nguyễn Minh Anh"
      },
      "userRole": "admin"
    }
  ]
}
```

---

#### **GET /groups/:id** 🔒
Lấy chi tiết nhóm

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "group_name": "Team Marketing Hà Nội",
    "group_description": "Nhóm đi du lịch cuối tuần",
    "creator": {
      "id": "uuid",
      "usr_fullname": "Nguyễn Minh Anh"
    },
    "members": [
      {
        "id": "uuid",
        "user_id": "uuid",
        "role": "admin",
        "user": {
          "id": "uuid",
          "usr_fullname": "Nguyễn Minh Anh",
          "usr_avatar": "url"
        }
      }
    ]
  }
}
```

---

#### **PUT /groups/:id** 🔒
Cập nhật thông tin nhóm (Admin only)

**Request Body:**
```json
{
  "group_name": "Updated Name",
  "group_description": "Updated description"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Group updated successfully",
  "data": {
    "id": "uuid",
    "group_name": "Updated Name"
  }
}
```

---

#### **DELETE /groups/:id** 🔒
Xóa nhóm (Creator only)

**Response:**
```json
{
  "status": "success",
  "message": "Group deleted successfully"
}
```

---

#### **POST /groups/:id/members** 🔒
Thêm thành viên vào nhóm (Admin only)

**Request Body:**
```json
{
  "memberEmail": "user@example.com"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Member added successfully",
  "data": {
    "id": "uuid",
    "group_id": "uuid",
    "user_id": "uuid",
    "role": "member"
  }
}
```

---

#### **DELETE /groups/:id/members/:memberId** 🔒
Xóa thành viên khỏi nhóm (Admin only)

**Response:**
```json
{
  "status": "success",
  "message": "Member removed successfully"
}
```

---

#### **POST /groups/share-trip** 🔒
Chia sẻ chuyến đi vào nhóm

**Request Body:**
```json
{
  "tripId": "uuid",
  "groupId": "uuid",
  "message": "Các bạn xem lịch trình này nhé!"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Trip shared successfully",
  "data": {
    "id": "uuid",
    "trip_id": "uuid",
    "group_id": "uuid",
    "shared_by": "uuid"
  }
}
```

---

#### **GET /groups/:id/shared-trips** 🔒
Lấy danh sách chuyến đi đã chia sẻ trong nhóm

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "shared_at": "2025-01-15T10:00:00.000Z",
      "message": "Các bạn xem lịch trình này nhé!",
      "trip": {
        "id": "uuid",
        "trip_title": "Một ngày khám phá Hà Nội"
      },
      "sharedBy": {
        "id": "uuid",
        "usr_fullname": "Nguyễn Minh Anh"
      }
    }
  ]
}
```

---

#### **POST /groups/comments** 🔒
Thêm bình luận vào chuyến đi đã chia sẻ

**Request Body:**
```json
{
  "tripShareId": "uuid",
  "comment": "Tuần sau đi nữa không?",
  "parentCommentId": null
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Comment added successfully",
  "data": {
    "id": "uuid",
    "trip_share_id": "uuid",
    "user_id": "uuid",
    "comment": "Tuần sau đi nữa không?"
  }
}
```

---

#### **GET /groups/trip-shares/:tripShareId/comments** 🔒
Lấy danh sách bình luận

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "uuid",
      "comment": "Tuần sau đi nữa không?",
      "createdAt": "2025-01-15T11:00:00.000Z",
      "user": {
        "id": "uuid",
        "usr_fullname": "Nguyễn Văn B"
      },
      "replies": [
        {
          "id": "uuid",
          "comment": "OK luôn!",
          "user": {
            "id": "uuid",
            "usr_fullname": "Nguyễn Minh Anh"
          }
        }
      ]
    }
  ]
}
```

---

## 7. MODULE: NOTIFICATIONS

### 7.1. Notification Routes (`/notifications`)

#### **GET /notifications** 🔒
Lấy danh sách thông báo

**Query Parameters:**
- `page`, `limit`: Phân trang
- `status`: pending | sent | read
- `type`: reminder | progress | social | system | event

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 15,
    "currentPage": 1,
    "totalPages": 1,
    "data": [
      {
        "id": "uuid",
        "noti_type": "reminder",
        "noti_title": "Nhắc nhở chuyến đi",
        "noti_message": "Chuyến đi 'Một ngày khám phá Hà Nội' của bạn sắp bắt đầu!",
        "noti_status": "sent",
        "noti_data": {
          "trip_id": "uuid"
        },
        "sent_at": "2025-01-15T07:00:00.000Z",
        "read_at": null,
        "createdAt": "2025-01-14T20:00:00.000Z"
      }
    ]
  }
}
```

---

#### **GET /notifications/unread-count** 🔒
Lấy số lượng thông báo chưa đọc

**Response:**
```json
{
  "status": "success",
  "data": {
    "unreadCount": 5
  }
}
```

---

#### **PATCH /notifications/:id/read** 🔒
Đánh dấu đã đọc

**Response:**
```json
{
  "status": "success",
  "message": "Notification marked as read",
  "data": {
    "id": "uuid",
    "noti_status": "read",
    "read_at": "2025-01-15T12:00:00.000Z"
  }
}
```

---

#### **PATCH /notifications/read-all** 🔒
Đánh dấu tất cả đã đọc

**Response:**
```json
{
  "status": "success",
  "message": "All notifications marked as read"
}
```

---

#### **DELETE /notifications/:id** 🔒
Xóa thông báo

**Response:**
```json
{
  "status": "success",
  "message": "Notification deleted successfully"
}
```

---

## Error Responses

Tất cả các lỗi đều trả về format:

```json
{
  "status": "error",
  "message": "Error message",
  "statusCode": 400
}
```

**Common Status Codes:**
- `400` - Bad Request (dữ liệu không hợp lệ)
- `401` - Unauthorized (chưa đăng nhập)
- `403` - Forbidden (không có quyền)
- `404` - Not Found (không tìm thấy resource)
- `500` - Internal Server Error

---

## Changelog

### Version 1.0.0 (2025-01-15)
- ✅ Authentication & User Management
- ✅ Destinations với filter nâng cao
- ✅ Events management
- ✅ Trip planning & management
- ✅ Reviews & Ratings với sentiment analysis
- ✅ Groups & Social features
- ✅ Notifications system
- ✅ Like/Unlike toggle cho destinations & events
- ✅ Check-in tracking
- ✅ Removed "save" feature (like = save)

---

## Database Schema Overview

**Core Tables:**
- `profiles` - User profiles (thêm total_likes, total_checkins)
- `destinations` - POI data
- `destination_categories` - Categories
- `events` - Events/Activities
- `reviews` - User reviews
- `trips` - Trip itineraries
- `trip_destinations` - N-N relation
- `trip_events` - N-N relation
- `user_feedback` - Likes & Check-ins (không còn save)
- `notifications` - Notification system
- `groups` - User groups
- `group_members` - Group membership
- `trip_shares` - Shared trips
- `group_comments` - Comments on shared trips

**AI/Analytics Tables:**
- `ai_requests` - AI request logs
- `ai_responses` - AI response logs
- `search_logs` - Search analytics

---

## Notes

1. **Like = Save**: Like một địa điểm đồng nghĩa với việc lưu nó vào danh sách yêu thích
2. **Toggle Like**: Nhấn like lần nữa sẽ bỏ like
3. **Check-in**: Chỉ được check-in 1 lần tại mỗi địa điểm
4. **Profile Stats**: `total_likes` và `total_checkins` được tự động cập nhật
5. **Sentiment Analysis**: Review tự động phân tích cảm xúc (positive/negative/neutral)
6. **Geospatial**: Sử dụng PostGIS cho tính toán khoảng cách

---

**Developed by:** Trekka Team  
**Last Updated:** January 15, 2025


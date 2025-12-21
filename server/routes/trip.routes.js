import express from 'express';
import tripController from '../controllers/trip.controller.js';
import {authenticate} from '../middleware/authenticate.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Trips
 *   description: API quản lý chuyến đi
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Trip:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         user_id:
 *           type: string
 *           format: uuid
 *         trip_title:
 *           type: string
 *           example: "Một ngày khám phá Hà Nội"
 *         trip_description:
 *           type: string
 *         trip_start_date:
 *           type: string
 *           format: date
 *         trip_end_date:
 *           type: string
 *           format: date
 *         trip_budget:
 *           type: number
 *           example: 600000
 *         trip_actual_cost:
 *           type: number
 *         trip_status:
 *           type: string
 *           enum: [draft, active, completed, cancelled]
 *         trip_transport:
 *           type: string
 *           enum: [walking, bike, motorbike, car, bus, taxi, mixed]
 *         trip_type:
 *           type: string
 *           enum: [solo, couple, family, friends, group]
 *           description: |
 *             Loại chuyến đi (phải phù hợp với participant_count):
 *             - solo: 1 người
 *             - couple: 2 người
 *             - family: >= 3 người
 *             - friends: >= 2 người
 *             - group: >= 3 người
 *         participant_count:
 *           type: integer
 *           minimum: 1
 *           example: 2
 *           description: |
 *             Số lượng người tham gia chuyến đi (phải phù hợp với trip_type):
 *             - Nếu trip_type là 'solo': phải là 1
 *             - Nếu trip_type là 'couple': phải là 2
 *             - Nếu trip_type là 'family': tối thiểu 3
 *             - Nếu trip_type là 'friends': tối thiểu 2
 *             - Nếu trip_type là 'group': tối thiểu 3
 *         visibility:
 *           type: string
 *           enum: [private, friends, public]
 *         cover_image:
 *           type: string
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *         ai_generated:
 *           type: boolean
 *         total_distance:
 *           type: number
 *         total_duration:
 *           type: integer
 */

/**
 * @swagger
 * /trips:
 *   get:
 *     summary: Lấy danh sách chuyến đi của user
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [draft, active, completed, cancelled]
 *     responses:
 *       200:
 *         description: Success
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                     currentPage:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *                     data:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Trip'
 */
router.get('/', authenticate, tripController.getUserTrips);

/**
 * @swagger
 * /trips/{id}:
 *   get:
 *     summary: Lấy chi tiết chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 *       403:
 *         description: Access denied
 *       404:
 *         description: Trip not found
 */
router.get('/:id', authenticate, tripController.getTripById);

/**
 * @swagger
 * /trips:
 *   post:
 *     summary: Tạo chuyến đi mới
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - trip_title
 *               - trip_start_date
 *               - trip_end_date
 *             properties:
 *               trip_title:
 *                 type: string
 *                 example: "Một ngày khám phá Hà Nội"
 *               trip_description:
 *                 type: string
 *               trip_start_date:
 *                 type: string
 *                 format: date
 *               trip_end_date:
 *                 type: string
 *                 format: date
 *               trip_budget:
 *                 type: number
 *               trip_transport:
 *                 type: string
 *                 enum: [walking, bike, motorbike, car, bus, taxi, mixed]
 *               trip_type:
 *                 type: string
 *                 enum: [solo, couple, family, friends, group]
 *                 description: |
 *                   Loại chuyến đi. Quy tắc với participant_count:
 *                   - solo: chỉ 1 người
 *                   - couple: chỉ 2 người
 *                   - family: tối thiểu 3 người
 *                   - friends: tối thiểu 2 người
 *                   - group: tối thiểu 3 người
 *               participant_count:
 *                 type: integer
 *                 minimum: 1
 *                 example: 2
 *                 description: |
 *                   Số lượng người tham gia. Phải phù hợp với trip_type:
 *                   - solo: phải là 1
 *                   - couple: phải là 2
 *                   - family: >= 3
 *                   - friends: >= 2
 *                   - group: >= 3
 *               visibility:
 *                 type: string
 *                 enum: [private, friends, public]
 *     responses:
 *       201:
 *         description: Created
 *       400:
 *         description: Validation error (trip_type và participant_count không phù hợp)
 */
router.post('/', authenticate, tripController.createTrip);

/**
 * @swagger
 * /trips/{id}:
 *   put:
 *     summary: Cập nhật chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               trip_title:
 *                 type: string
 *               trip_budget:
 *                 type: number
 *               trip_type:
 *                 type: string
 *                 enum: [solo, couple, family, friends, group]
 *                 description: Nếu thay đổi trip_type, phải đảm bảo participant_count phù hợp
 *               participant_count:
 *                 type: integer
 *                 minimum: 1
 *                 description: Nếu thay đổi participant_count, phải đảm bảo phù hợp với trip_type
 *     responses:
 *       200:
 *         description: Success
 *       400:
 *         description: Validation error (trip_type và participant_count không phù hợp)
 *       404:
 *         description: Trip not found
 */
router.put('/:id', authenticate, tripController.updateTrip);

/**
 * @swagger
 * /trips/{id}:
 *   delete:
 *     summary: Xóa chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 *       404:
 *         description: Trip not found
 */
router.delete('/:id', authenticate, tripController.deleteTrip);

/**
 * @swagger
 * /trips/{id}/status:
 *   patch:
 *     summary: Thay đổi trạng thái chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [draft, active, completed, cancelled]
 *     responses:
 *       200:
 *         description: Success
 */
router.patch('/:id/status', authenticate, tripController.changeTripStatus);

/**
 * @swagger
 * /trips/{id}/destinations:
 *   post:
 *     summary: Thêm địa điểm vào chuyến đi
 *     description: |
 *       Thêm một địa điểm (destination) vào chuyến đi.
 *       Khác với sự kiện (event), địa điểm cho phép thiết lập:
 *       - Thời gian ước tính (estimatedTime)
 *       - Ngày ghé thăm cụ thể (visitDate)
 *       - Giờ bắt đầu (startTime)
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID của chuyến đi
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - destId
 *             properties:
 *               destId:
 *                 type: string
 *                 format: uuid
 *                 description: ID của địa điểm cần thêm
 *                 example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
 *               visitOrder:
 *                 type: integer
 *                 description: Thứ tự ghé thăm trong chuyến đi (tự động tăng nếu không cung cấp)
 *                 example: 1
 *               estimatedTime:
 *                 type: integer
 *                 description: Thời gian ước tính tại địa điểm (phút). Sử dụng recommended_duration của địa điểm nếu không cung cấp
 *                 example: 90
 *                 minimum: 0
 *               visitDate:
 *                 type: string
 *                 format: date
 *                 description: Ngày dự định ghé thăm
 *                 example: "2025-12-25"
 *               startTime:
 *                 type: string
 *                 description: Giờ bắt đầu ghé thăm (HH:MM:SS hoặc HH:MM)
 *                 example: "09:00:00"
 *               notes:
 *                 type: string
 *                 description: Ghi chú về địa điểm
 *                 example: "Nhớ mang theo máy ảnh"
 *           example:
 *             destId: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
 *             visitOrder: 1
 *             estimatedTime: 90
 *             visitDate: "2025-12-25"
 *             startTime: "09:00:00"
 *             notes: "Ghé thăm vào buổi sáng"
 *     responses:
 *       201:
 *         description: Thêm địa điểm thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Destination added to trip"
 *                 data:
 *                   type: object
 *       400:
 *         description: Địa điểm đã tồn tại trong chuyến đi hoặc dữ liệu không hợp lệ
 *       404:
 *         description: Chuyến đi hoặc địa điểm không tìm thấy
 */
router.post('/:id/destinations', authenticate, tripController.addDestinationToTrip);

/**
 * @swagger
 * /trips/{id}/destinations/{destId}:
 *   delete:
 *     summary: Xóa địa điểm khỏi chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *       - in: path
 *         name: destId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 */
router.delete('/:id/destinations/:destId', authenticate, tripController.removeDestinationFromTrip);

/**
 * @swagger
 * /trips/{id}/destinations/reorder:
 *   put:
 *     summary: Sắp xếp lại thứ tự các địa điểm
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               destinationOrders:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     destId:
 *                       type: string
 *                       format: uuid
 *                     visitOrder:
 *                       type: integer
 *     responses:
 *       200:
 *         description: Success
 */
router.put('/:id/destinations/reorder', authenticate, tripController.reorderDestinations);

/**
 * @swagger
 * /trips/{id}/events:
 *   post:
 *     summary: Thêm sự kiện vào chuyến đi
 *     description: |
 *       Thêm một sự kiện (event) vào chuyến đi.
 *       Khác với địa điểm (destination), sự kiện chỉ có:
 *       - Thứ tự ghé thăm (visitOrder)
 *       - Ghi chú (notes)
 *
 *       Thời gian của sự kiện được xác định bởi event_start và event_end trong dữ liệu sự kiện.
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID của chuyến đi
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - eventId
 *             properties:
 *               eventId:
 *                 type: string
 *                 format: uuid
 *                 description: ID của sự kiện cần thêm
 *                 example: "b2c3d4e5-f6a7-8901-bcde-f12345678901"
 *               visitOrder:
 *                 type: integer
 *                 description: Thứ tự trong chuyến đi (tự động tăng nếu không cung cấp)
 *                 example: 2
 *               notes:
 *                 type: string
 *                 description: Ghi chú về sự kiện
 *                 example: "Nhớ đặt vé trước"
 *           example:
 *             eventId: "b2c3d4e5-f6a7-8901-bcde-f12345678901"
 *             visitOrder: 2
 *             notes: "Sự kiện buổi chiều"
 *     responses:
 *       201:
 *         description: Thêm sự kiện thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Event added to trip"
 *                 data:
 *                   type: object
 *       400:
 *         description: Sự kiện đã tồn tại trong chuyến đi hoặc dữ liệu không hợp lệ
 *       404:
 *         description: Chuyến đi hoặc sự kiện không tìm thấy
 */
router.post('/:id/events', authenticate, tripController.addEventToTrip);

/**
 * @swagger
 * /trips/{id}/events/{eventId}:
 *   delete:
 *     summary: Xóa sự kiện khỏi chuyến đi
 *     tags: [Trips]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *       - in: path
 *         name: eventId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 */
router.delete('/:id/events/:eventId', authenticate, tripController.removeEventFromTrip);

export default router;


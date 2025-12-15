import express from 'express';
import userActivityController from '../controllers/userActivity.controller.js';
import {authenticate} from '../middleware/authenticate.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: User Activity
 *   description: API quản lý hoạt động người dùng (liked, checked-in)
 */

/**
 * @swagger
 * /user/liked:
 *   get:
 *     summary: Lấy danh sách địa điểm và sự kiện đã like
 *     tags: [User Activity]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Số trang
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Số lượng items mỗi trang
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [destination, event]
 *         description: Lọc theo loại (destination hoặc event). Nếu không truyền sẽ lấy cả 2
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
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                       example: 25
 *                     currentPage:
 *                       type: integer
 *                       example: 1
 *                     totalPages:
 *                       type: integer
 *                       example: 3
 *                     data:
 *                       type: array
 *                       items:
 *                         oneOf:
 *                           - type: object
 *                             properties:
 *                               type:
 *                                 type: string
 *                                 example: destination
 *                               liked_at:
 *                                 type: string
 *                                 format: date-time
 *                               id:
 *                                 type: string
 *                                 format: uuid
 *                               dest_name:
 *                                 type: string
 *                               dest_description:
 *                                 type: string
 *                               dest_avg_cost:
 *                                 type: number
 *                               total_likes:
 *                                 type: integer
 *                               total_checkins:
 *                                 type: integer
 *                           - type: object
 *                             properties:
 *                               type:
 *                                 type: string
 *                                 example: event
 *                               liked_at:
 *                                 type: string
 *                                 format: date-time
 *                               id:
 *                                 type: string
 *                                 format: uuid
 *                               event_name:
 *                                 type: string
 *                               event_description:
 *                                 type: string
 *                               event_ticket_price:
 *                                 type: number
 *                               total_likes:
 *                                 type: integer
 *                               total_attendees:
 *                                 type: integer
 *       401:
 *         description: Unauthorized
 */
router.get('/liked', authenticate, userActivityController.getLikedItems);

/**
 * @swagger
 * /user/checkins:
 *   get:
 *     summary: Lấy danh sách địa điểm và sự kiện đã check-in
 *     tags: [User Activity]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Số trang
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Số lượng items mỗi trang
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [destination, event]
 *         description: Lọc theo loại (destination hoặc event). Nếu không truyền sẽ lấy cả 2
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
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                       example: 15
 *                     currentPage:
 *                       type: integer
 *                       example: 1
 *                     totalPages:
 *                       type: integer
 *                       example: 2
 *                     data:
 *                       type: array
 *                       items:
 *                         oneOf:
 *                           - type: object
 *                             properties:
 *                               type:
 *                                 type: string
 *                                 example: destination
 *                               checkin_at:
 *                                 type: string
 *                                 format: date-time
 *                               checkin_metadata:
 *                                 type: object
 *                                 properties:
 *                                   checkin_time:
 *                                     type: string
 *                                     format: date-time
 *                                   lat:
 *                                     type: number
 *                                   lng:
 *                                     type: number
 *                               id:
 *                                 type: string
 *                                 format: uuid
 *                               dest_name:
 *                                 type: string
 *                               dest_description:
 *                                 type: string
 *                               dest_avg_cost:
 *                                 type: number
 *                               total_likes:
 *                                 type: integer
 *                               total_checkins:
 *                                 type: integer
 *                           - type: object
 *                             properties:
 *                               type:
 *                                 type: string
 *                                 example: event
 *                               checkin_at:
 *                                 type: string
 *                                 format: date-time
 *                               checkin_metadata:
 *                                 type: object
 *                                 properties:
 *                                   checkin_time:
 *                                     type: string
 *                                     format: date-time
 *                                   lat:
 *                                     type: number
 *                                   lng:
 *                                     type: number
 *                               id:
 *                                 type: string
 *                                 format: uuid
 *                               event_name:
 *                                 type: string
 *                               event_description:
 *                                 type: string
 *                               event_ticket_price:
 *                                 type: number
 *                               total_likes:
 *                                 type: integer
 *                               total_attendees:
 *                                 type: integer
 *       401:
 *         description: Unauthorized
 */
router.get('/checkins', authenticate, userActivityController.getCheckedInItems);

export default router;


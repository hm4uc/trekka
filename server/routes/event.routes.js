import express from 'express';
import eventController from '../controllers/event.controller.js';
import {authenticate} from '../middleware/authenticate.js';
import {authorize} from '../middleware/authorize.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Events
 *   description: API quản lý sự kiện
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Event:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         event_name:
 *           type: string
 *           example: "Hanoi Art Exhibition 2025"
 *         event_description:
 *           type: string
 *           example: "Triển lãm nghệ thuật hiện đại"
 *         event_location:
 *           type: string
 *           example: "Tràng Tiền Plaza"
 *         lat:
 *           type: number
 *           example: 21.0245
 *         lng:
 *           type: number
 *           example: 105.8512
 *         event_start:
 *           type: string
 *           format: date-time
 *           example: "2025-01-15T15:00:00.000Z"
 *         event_end:
 *           type: string
 *           format: date-time
 *           example: "2025-01-15T20:00:00.000Z"
 *         event_ticket_price:
 *           type: number
 *           example: 50000
 *         event_type:
 *           type: string
 *           example: "exhibition"
 *         event_organizer:
 *           type: string
 *           example: "Hanoi Art Center"
 *         event_capacity:
 *           type: integer
 *           example: 200
 *         event_tags:
 *           type: array
 *           items:
 *             type: string
 *           example: ["art", "culture", "indoor"]
 *         images:
 *           type: array
 *           items:
 *             type: string
 *           example: ["url1", "url2"]
 *         total_attendees:
 *           type: integer
 *           example: 150
 *         total_likes:
 *           type: integer
 *           example: 80
 *         is_featured:
 *           type: boolean
 *           example: true
 *         is_active:
 *           type: boolean
 *           example: true
 */

/**
 * @swagger
 * /events:
 *   get:
 *     summary: Lấy danh sách sự kiện
 *     tags: [Events]
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
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: eventType
 *         schema:
 *           type: string
 *           enum: [concert, exhibition, festival, workshop]
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *       - in: query
 *         name: lng
 *         schema:
 *           type: number
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *           default: 5000
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: minPrice
 *         schema:
 *           type: number
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [date, popularity, price_asc, price_desc, distance]
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
 *                     currentPage:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *                     data:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Event'
 */
router.get('/', eventController.getAllEvents);

/**
 * @swagger
 * /events/upcoming:
 *   get:
 *     summary: Lấy sự kiện sắp diễn ra
 *     tags: [Events]
 *     parameters:
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *       - in: query
 *         name: lng
 *         schema:
 *           type: number
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *           default: 5000
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
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
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Event'
 */
router.get('/upcoming', eventController.getUpcomingEvents);

/**
 * @swagger
 * /events/{id}:
 *   get:
 *     summary: Lấy chi tiết sự kiện
 *     tags: [Events]
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
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 data:
 *                   $ref: '#/components/schemas/Event'
 *       404:
 *         description: Event not found
 */
router.get('/:id', eventController.getEventById);

/**
 * @swagger
 * /events/{id}/like:
 *   post:
 *     summary: Like/Unlike sự kiện (toggle)
 *     tags: [Events]
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
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 message:
 *                   type: string
 *                   example: "Đã like sự kiện"
 *                 data:
 *                   type: object
 *                   properties:
 *                     isLiked:
 *                       type: boolean
 *                     total_likes:
 *                       type: integer
 *       401:
 *         description: Unauthorized
 */
router.post('/:id/like', authenticate, eventController.likeEvent);

/**
 * @swagger
 * /events:
 *   post:
 *     summary: Tạo sự kiện mới (Admin)
 *     tags: [Events]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - event_name
 *               - event_start
 *               - event_end
 *             properties:
 *               event_name:
 *                 type: string
 *               event_description:
 *                 type: string
 *               event_location:
 *                 type: string
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               event_start:
 *                 type: string
 *                 format: date-time
 *               event_end:
 *                 type: string
 *                 format: date-time
 *               event_ticket_price:
 *                 type: number
 *               event_type:
 *                 type: string
 *               event_organizer:
 *                 type: string
 *               event_capacity:
 *                 type: integer
 *               event_tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Created
 *       403:
 *         description: Forbidden - Admin only
 */
router.post('/', authenticate, authorize(['admin']), eventController.createEvent);

/**
 * @swagger
 * /events/{id}:
 *   put:
 *     summary: Cập nhật sự kiện (Admin)
 *     tags: [Events]
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
 *               event_name:
 *                 type: string
 *               event_description:
 *                 type: string
 *               event_ticket_price:
 *                 type: number
 *     responses:
 *       200:
 *         description: Success
 *       403:
 *         description: Forbidden - Admin only
 */
router.put('/:id', authenticate, authorize(['admin']), eventController.updateEvent);

export default router;


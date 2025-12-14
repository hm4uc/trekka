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
 *               visibility:
 *                 type: string
 *                 enum: [private, friends, public]
 *     responses:
 *       201:
 *         description: Created
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
 *     responses:
 *       200:
 *         description: Success
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
 *             required:
 *               - destId
 *             properties:
 *               destId:
 *                 type: string
 *                 format: uuid
 *               visitOrder:
 *                 type: integer
 *               estimatedTime:
 *                 type: integer
 *                 description: Thời gian ước tính (phút)
 *               visitDate:
 *                 type: string
 *                 format: date
 *               startTime:
 *                 type: string
 *                 format: time
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Created
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
 *                     dest_id:
 *                       type: string
 *                       format: uuid
 *                     visit_order:
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
 *             required:
 *               - eventId
 *             properties:
 *               eventId:
 *                 type: string
 *                 format: uuid
 *               visitOrder:
 *                 type: integer
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Created
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


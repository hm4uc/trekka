import express from 'express';
import reviewController from '../controllers/review.controller.js';
import {authenticate} from '../middleware/authenticate.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Reviews
 *   description: API quản lý đánh giá
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Review:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         user_id:
 *           type: string
 *           format: uuid
 *         dest_id:
 *           type: string
 *           format: uuid
 *         event_id:
 *           type: string
 *           format: uuid
 *         rating:
 *           type: integer
 *           minimum: 1
 *           maximum: 5
 *           example: 5
 *         comment:
 *           type: string
 *           example: "Không gian đẹp, nhiều tranh ấn tượng!"
 *         sentiment:
 *           type: string
 *           enum: [positive, negative, neutral]
 *         images:
 *           type: array
 *           items:
 *             type: string
 *         helpful_count:
 *           type: integer
 *         is_verified_visit:
 *           type: boolean
 *         is_active:
 *           type: boolean
 *         createdAt:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /reviews:
 *   post:
 *     summary: Tạo đánh giá mới
 *     description: |
 *       Tạo đánh giá cho địa điểm HOẶC sự kiện (chỉ chọn 1 trong 2).
 *
 *       **LƯU Ý**: Chỉ gửi field bạn cần (destId hoặc eventId), KHÔNG gửi field kia hoặc để null.
 *       KHÔNG sử dụng chuỗi rỗng ("").
 *     tags: [Reviews]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - rating
 *             properties:
 *               destId:
 *                 type: string
 *                 format: uuid
 *                 nullable: true
 *                 description: ID địa điểm (chọn destId HOẶC eventId, không được cả 2). Bỏ qua field này khi đánh giá event.
 *               eventId:
 *                 type: string
 *                 format: uuid
 *                 nullable: true
 *                 description: ID sự kiện (chọn destId HOẶC eventId, không được cả 2). Bỏ qua field này khi đánh giá destination.
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 5
 *               comment:
 *                 type: string
 *                 example: "Không gian đẹp, nhiều tranh ấn tượng!"
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["https://example.com/image1.jpg"]
 *           examples:
 *             reviewDestination:
 *               summary: Đánh giá địa điểm (chỉ gửi destId)
 *               value:
 *                 destId: "123e4567-e89b-12d3-a456-426614174000"
 *                 rating: 5
 *                 comment: "Quán cafe rất đẹp!"
 *                 images: []
 *             reviewEvent:
 *               summary: Đánh giá sự kiện (chỉ gửi eventId)
 *               value:
 *                 eventId: "123e4567-e89b-12d3-a456-426614174001"
 *                 rating: 4
 *                 comment: "Sự kiện tổ chức tốt!"
 *                 images: []
 *     responses:
 *       201:
 *         description: Created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: Review created successfully
 *                 data:
 *                   $ref: '#/components/schemas/Review'
 *       400:
 *         description: Bad request - Either destId or eventId must be provided (not both)
 */
router.post('/', authenticate, reviewController.createReview);

/**
 * @swagger
 * /reviews/destinations/{destId}:
 *   get:
 *     summary: Lấy danh sách đánh giá cho địa điểm
 *     tags: [Reviews]
 *     parameters:
 *       - in: path
 *         name: destId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
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
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [recent, rating_high, rating_low, helpful]
 *           default: recent
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
 *                         $ref: '#/components/schemas/Review'
 */
router.get('/destinations/:destId', reviewController.getDestinationReviews);

/**
 * @swagger
 * /reviews/events/{eventId}:
 *   get:
 *     summary: Lấy danh sách đánh giá cho sự kiện
 *     tags: [Reviews]
 *     parameters:
 *       - in: path
 *         name: eventId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
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
 *     responses:
 *       200:
 *         description: Success
 */
router.get('/events/:eventId', reviewController.getEventReviews);

/**
 * @swagger
 * /reviews/my-reviews:
 *   get:
 *     summary: Lấy danh sách đánh giá của user
 *     tags: [Reviews]
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
 *     responses:
 *       200:
 *         description: Success
 */
router.get('/my-reviews', authenticate, reviewController.getUserReviews);

/**
 * @swagger
 * /reviews/{id}:
 *   put:
 *     summary: Cập nhật đánh giá
 *     tags: [Reviews]
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
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *               comment:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Success
 *       404:
 *         description: Review not found
 */
router.put('/:id', authenticate, reviewController.updateReview);

/**
 * @swagger
 * /reviews/{id}:
 *   delete:
 *     summary: Xóa đánh giá
 *     tags: [Reviews]
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
 *         description: Review not found
 */
router.delete('/:id', authenticate, reviewController.deleteReview);

/**
 * @swagger
 * /reviews/{id}/helpful:
 *   post:
 *     summary: Đánh dấu đánh giá hữu ích
 *     tags: [Reviews]
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
 *                 data:
 *                   type: object
 *                   properties:
 *                     helpful_count:
 *                       type: integer
 */
router.post('/:id/helpful', reviewController.markReviewHelpful);

export default router;


import express from 'express';
import destinationController from '../controllers/destination.controller.js';
import {authenticate} from '../middleware/authenticate.js';
import {authorize} from '../middleware/authorize.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: Destinations
 *     description: API quản lý địa điểm du lịch
 *   - name: Categories
 *     description: API quản lý danh mục địa điểm
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Category:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *           example: "Cafe"
 *         icon:
 *           type: string
 *           example: "coffee"
 *         description:
 *           type: string
 *           example: "Các quán cafe đẹp"
 *         travel_style_id:
 *           type: string
 *           example: "food_drink"
 *         context_tags:
 *           type: array
 *           items:
 *             type: string
 *           example: ["solo", "couple"]
 *         avg_visit_duration:
 *           type: integer
 *           example: 60
 *         is_active:
 *           type: boolean
 *           example: true
 *
 *     Destination:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         categoryId:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *           example: "The Ylang Coffee"
 *         description:
 *           type: string
 *           example: "Quán cafe view hồ đẹp"
 *         address:
 *           type: string
 *           example: "2 Le Thach, Hoan Kiem, Hanoi"
 *         lat:
 *           type: number
 *           format: float
 *           example: 21.0285
 *         lng:
 *           type: number
 *           format: float
 *           example: 105.8542
 *         avg_cost:
 *           type: number
 *           example: 50000
 *         rating:
 *           type: number
 *           example: 4.5
 *         total_reviews:
 *           type: integer
 *           example: 120
 *         total_likes:
 *           type: integer
 *           example: 45
 *         total_saves:
 *           type: integer
 *           example: 30
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           example: ["wifi", "view", "quiet"]
 *         opening_hours:
 *           type: object
 *           example: {"mon": "8:00-22:00", "tue": "8:00-22:00"}
 *         images:
 *           type: array
 *           items:
 *             type: string
 *           example: ["https://example.com/image1.jpg"]
 *         ai_summary:
 *           type: string
 *           example: "Không gian yên tĩnh, phù hợp làm việc"
 *         is_hidden_gem:
 *           type: boolean
 *           example: false
 *         is_verified:
 *           type: boolean
 *           example: true
 *         is_active:
 *           type: boolean
 *           example: true
 *         category:
 *           $ref: '#/components/schemas/Category'
 *
 *     DestinationCreate:
 *       type: object
 *       required:
 *         - name
 *         - categoryId
 *         - lat
 *         - lng
 *       properties:
 *         name:
 *           type: string
 *         categoryId:
 *           type: string
 *           format: uuid
 *         description:
 *           type: string
 *         address:
 *           type: string
 *         lat:
 *           type: number
 *         lng:
 *           type: number
 *         avg_cost:
 *           type: number
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *         opening_hours:
 *           type: object
 *         images:
 *           type: array
 *           items:
 *             type: string
 *
 *     PaginatedResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         data:
 *           type: object
 *           properties:
 *             total:
 *               type: integer
 *               example: 100
 *             currentPage:
 *               type: integer
 *               example: 1
 *             totalPages:
 *               type: integer
 *               example: 10
 *             data:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Destination'
 */

// === PUBLIC ROUTES ===

/**
 * @swagger
 * /destinations/categories:
 *   get:
 *     summary: Lấy danh sách danh mục địa điểm
 *     tags: [Categories]
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
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Category'
 */
router.get('/categories', destinationController.getCategories);

/**
 * @swagger
 * /destinations/categories/{travelStyle}:
 *   get:
 *     summary: Lấy danh mục theo phong cách du lịch
 *     tags: [Categories]
 *     parameters:
 *       - in: path
 *         name: travelStyle
 *         required: true
 *         schema:
 *           type: string
 *         description: ID phong cách du lịch (nature, food_drink, etc.)
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
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Category'
 */
router.get('/categories/:travelStyle', destinationController.getCategoriesByTravelStyle);

/**
 * @swagger
 * /destinations:
 *   get:
 *     summary: Tìm kiếm và lọc địa điểm
 *     tags: [Destinations]
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
 *         description: Số lượng item mỗi trang
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Tìm kiếm theo tên
 *       - in: query
 *         name: categoryId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Lọc theo ID danh mục
 *       - in: query
 *         name: minPrice
 *         schema:
 *           type: number
 *         description: Giá thấp nhất
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *         description: Giá cao nhất
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         description: Vĩ độ hiện tại
 *       - in: query
 *         name: lng
 *         schema:
 *           type: number
 *         description: Kinh độ hiện tại
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *           default: 5000
 *         description: Bán kính tìm kiếm (mét)
 *       - in: query
 *         name: isOpenNow
 *         schema:
 *           type: boolean
 *         description: Lọc địa điểm đang mở cửa
 *       - in: query
 *         name: context
 *         schema:
 *           type: string
 *           enum: [solo, couple, family, friends]
 *         description: Ngữ cảnh du lịch
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [distance, rating, price_asc, price_desc, popularity]
 *           default: distance
 *         description: Tiêu chí sắp xếp
 *       - in: query
 *         name: hiddenGemsOnly
 *         schema:
 *           type: boolean
 *         description: Chỉ hiển thị hidden gems
 *     responses:
 *       200:
 *         description: Success
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PaginatedResponse'
 */
router.get('/', destinationController.getDestinations);

/**
 * @swagger
 * /destinations/ai-picks:
 *   get:
 *     summary: Lấy danh sách địa điểm AI đề xuất (cần đăng nhập)
 *     tags: [Destinations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Số lượng item
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         description: Vĩ độ hiện tại
 *       - in: query
 *         name: lng
 *         schema:
 *           type: number
 *         description: Kinh độ hiện tại
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
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Destination'
 */
router.get('/ai-picks', authenticate, destinationController.getAiPicks);

/**
 * @swagger
 * /destinations/{id}:
 *   get:
 *     summary: Lấy chi tiết địa điểm
 *     tags: [Destinations]
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
 *                   example: success
 *                 data:
 *                   $ref: '#/components/schemas/Destination'
 *       404:
 *         description: Destination not found
 */
router.get('/:id', destinationController.getDestinationDetail);

/**
 * @swagger
 * /destinations/{id}/nearby:
 *   get:
 *     summary: Lấy địa điểm gần đó
 *     tags: [Destinations]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 5
 *         description: Số lượng địa điểm gần đó
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *           default: 2000
 *         description: Bán kính tìm kiếm (mét)
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
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Destination'
 */
router.get('/:id/nearby', destinationController.getNearbyDestinations);

// === PROTECTED ROUTES ===

/**
 * @swagger
 * /destinations/{id}/like:
 *   post:
 *     summary: Like địa điểm
 *     tags: [Destinations]
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
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: "Đã like địa điểm"
 */
router.post('/:id/like', authenticate, destinationController.likeDestination);


/**
 * @swagger
 * /destinations/{id}/checkin:
 *   post:
 *     summary: Check-in tại địa điểm
 *     tags: [Destinations]
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
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: "Đã check-in thành công"
 */
router.post('/:id/checkin', authenticate, destinationController.checkinDestination);

// === ADMIN ROUTES ===

/**
 * @swagger
 * /destinations:
 *   post:
 *     summary: Tạo địa điểm mới (Admin only)
 *     tags: [Destinations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DestinationCreate'
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
 *                 data:
 *                   $ref: '#/components/schemas/Destination'
 */
router.post('/', authenticate, authorize(['admin']), destinationController.createDestination);

/**
 * @swagger
 * /destinations/{id}:
 *   put:
 *     summary: Cập nhật địa điểm (Admin only)
 *     tags: [Destinations]
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
 *             $ref: '#/components/schemas/DestinationCreate'
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
 *                   $ref: '#/components/schemas/Destination'
 */
router.put('/:id', authenticate, authorize(['admin']), destinationController.updateDestination);

export default router;
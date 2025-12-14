import express from 'express';
import groupController from '../controllers/group.controller.js';
import {authenticate} from '../middleware/authenticate.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Groups
 *   description: API quản lý nhóm và chia sẻ chuyến đi
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Group:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         group_name:
 *           type: string
 *           example: "Team Marketing Hà Nội"
 *         group_description:
 *           type: string
 *         created_by:
 *           type: string
 *           format: uuid
 *         group_avatar:
 *           type: string
 *         is_active:
 *           type: boolean
 */

/**
 * @swagger
 * /groups:
 *   post:
 *     summary: Tạo nhóm mới
 *     tags: [Groups]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - group_name
 *             properties:
 *               group_name:
 *                 type: string
 *                 example: "Team Marketing Hà Nội"
 *               group_description:
 *                 type: string
 *               group_avatar:
 *                 type: string
 *     responses:
 *       201:
 *         description: Created
 */
router.post('/', authenticate, groupController.createGroup);

/**
 * @swagger
 * /groups:
 *   get:
 *     summary: Lấy danh sách nhóm của user
 *     tags: [Groups]
 *     security:
 *       - bearerAuth: []
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
 *                     allOf:
 *                       - $ref: '#/components/schemas/Group'
 *                       - type: object
 *                         properties:
 *                           userRole:
 *                             type: string
 *                             enum: [admin, member]
 */
router.get('/', authenticate, groupController.getUserGroups);

/**
 * @swagger
 * /groups/{id}:
 *   get:
 *     summary: Lấy chi tiết nhóm
 *     tags: [Groups]
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
 *         description: Not a member
 *       404:
 *         description: Group not found
 */
router.get('/:id', authenticate, groupController.getGroupById);

/**
 * @swagger
 * /groups/{id}:
 *   put:
 *     summary: Cập nhật thông tin nhóm (Admin only)
 *     tags: [Groups]
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
 *               group_name:
 *                 type: string
 *               group_description:
 *                 type: string
 *               group_avatar:
 *                 type: string
 *     responses:
 *       200:
 *         description: Success
 *       403:
 *         description: Only admin can update
 */
router.put('/:id', authenticate, groupController.updateGroup);

/**
 * @swagger
 * /groups/{id}:
 *   delete:
 *     summary: Xóa nhóm (Creator only)
 *     tags: [Groups]
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
 *         description: Group not found
 */
router.delete('/:id', authenticate, groupController.deleteGroup);

/**
 * @swagger
 * /groups/{id}/members:
 *   post:
 *     summary: Thêm thành viên vào nhóm (Admin only)
 *     tags: [Groups]
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
 *               - memberEmail
 *             properties:
 *               memberEmail:
 *                 type: string
 *                 format: email
 *     responses:
 *       201:
 *         description: Member added
 *       400:
 *         description: User already a member
 *       403:
 *         description: Only admin can add members
 *       404:
 *         description: User not found
 */
router.post('/:id/members', authenticate, groupController.addMember);

/**
 * @swagger
 * /groups/{id}/members/{memberId}:
 *   delete:
 *     summary: Xóa thành viên khỏi nhóm (Admin only)
 *     tags: [Groups]
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
 *         name: memberId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 *       400:
 *         description: Cannot remove creator
 *       403:
 *         description: Only admin can remove members
 */
router.delete('/:id/members/:memberId', authenticate, groupController.removeMember);

/**
 * @swagger
 * /groups/share-trip:
 *   post:
 *     summary: Chia sẻ chuyến đi vào nhóm
 *     tags: [Groups]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - tripId
 *               - groupId
 *             properties:
 *               tripId:
 *                 type: string
 *                 format: uuid
 *               groupId:
 *                 type: string
 *                 format: uuid
 *               message:
 *                 type: string
 *                 example: "Các bạn xem lịch trình này nhé!"
 *     responses:
 *       201:
 *         description: Trip shared successfully
 *       400:
 *         description: Trip already shared
 *       403:
 *         description: Not a member or not trip owner
 *       404:
 *         description: Trip or group not found
 */
router.post('/share-trip', authenticate, groupController.shareTrip);

/**
 * @swagger
 * /groups/{id}/shared-trips:
 *   get:
 *     summary: Lấy danh sách chuyến đi đã chia sẻ trong nhóm
 *     tags: [Groups]
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
 *         description: Not a member
 */
router.get('/:id/shared-trips', authenticate, groupController.getSharedTrips);

/**
 * @swagger
 * /groups/comments:
 *   post:
 *     summary: Thêm bình luận vào chuyến đi đã chia sẻ
 *     tags: [Groups]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - tripShareId
 *               - comment
 *             properties:
 *               tripShareId:
 *                 type: string
 *                 format: uuid
 *               comment:
 *                 type: string
 *               parentCommentId:
 *                 type: string
 *                 format: uuid
 *                 description: ID của comment cha (để reply)
 *     responses:
 *       201:
 *         description: Comment added
 *       403:
 *         description: Not a member
 */
router.post('/comments', authenticate, groupController.addComment);

/**
 * @swagger
 * /groups/trip-shares/{tripShareId}/comments:
 *   get:
 *     summary: Lấy danh sách bình luận
 *     tags: [Groups]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: tripShareId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Success
 *       403:
 *         description: Not a member
 */
router.get('/trip-shares/:tripShareId/comments', authenticate, groupController.getComments);

export default router;


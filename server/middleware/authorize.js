import { StatusCodes } from 'http-status-codes';

export function authorize(roles = []) {
    return (req, res, next) => {
        // TODO: Lấy role của user từ database
        // Hiện tại giả sử user có thuộc tính role trong JWT
        const userRole = req.user?.role || 'user';

        if (roles.length && !roles.includes(userRole)) {
            return res.status(StatusCodes.FORBIDDEN).json({
                status: 'error',
                message: 'Bạn không có quyền thực hiện hành động này'
            });
        }

        next();
    };
}
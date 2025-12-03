// config/travelConstants.js

export const TRAVEL_STYLES = [
    {
        id: "nature",
        label: "Thiên nhiên & Cảnh quan",
        icon: "mountain", // Dùng để map icon ở FE
        description: "Yêu thích núi non, biển đảo và phong cảnh hùng vĩ"
    },
    {
        id: "culture_history",
        label: "Văn hóa & Lịch sử",
        icon: "temple",
        description: "Khám phá di tích, bảo tàng và văn hóa địa phương"
    },
    {
        id: "food_drink",
        label: "Ẩm thực & Đồ uống",
        icon: "utensils",
        description: "Thưởng thức món ngon đường phố và các quán cafe đẹp"
    },
    {
        id: "chill_relax",
        label: "Chill & Thư giãn",
        icon: "umbrella-beach",
        description: "Nghỉ dưỡng nhẹ nhàng, healing, không di chuyển nhiều"
    },
    {
        id: "adventure",
        label: "Mạo hiểm & Thể thao",
        icon: "hiking",
        description: "Trekking, leo núi, chèo thuyền và các hoạt động mạnh"
    },
    {
        id: "shopping_entertainment",
        label: "Mua sắm & Giải trí",
        icon: "shopping-bag",
        description: "Trung tâm thương mại, khu vui chơi và cuộc sống về đêm"
    },
    {
        id: "luxury",
        label: "Sang trọng",
        icon: "gem",
        description: "Dịch vụ cao cấp, resort 5 sao và trải nghiệm độc bản"
    },
    {
        id: "local_life",
        label: "Đời sống bản địa",
        icon: "home",
        description: "Homestay, cùng sống và sinh hoạt với người dân"
    }
];

// Chỉ lấy danh sách các ID để validate trong code
export const VALID_TRAVEL_STYLES = TRAVEL_STYLES.map(style => style.label);

export const BUDGET_CONFIG = {
    MIN: 0,                 // Tối thiểu 0 đồng
    MAX: 50000000,          // Tối đa 50 triệu (Frontend có thể để max là 50tr+)
    STEP: 100000,           // Mỗi bước nhảy là 100k -> Dễ kéo chọn số chẵn
    DEFAULT: 1000000,       // Mặc định để thanh trượt ở mức 1 triệu
    CURRENCY: "VND"
};

// Helper function
export const isValidTravelStyle = (style) => {
    return VALID_TRAVEL_STYLES.includes(style);
};
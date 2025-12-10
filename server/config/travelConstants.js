// config/travelConstants.js

export const TRAVEL_STYLES = [
    {
        id: "nature",
        label: "Thiên nhiên & Cảnh quan",
        icon: "mountain",
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

// Danh sách ID hợp lệ để validate trong code
export const VALID_TRAVEL_STYLE_IDS = TRAVEL_STYLES.map(style => style.id);

// Danh sách label để hiển thị (nếu cần)
export const VALID_TRAVEL_STYLE_LABELS = TRAVEL_STYLES.map(style => style.label);

export const BUDGET_CONFIG = {
    MIN: 0,
    MAX: 50000000,
    STEP: 100000,
    DEFAULT: 1000000,
    CURRENCY: "VND"
};

// Helper function
export const isValidTravelStyle = (styleId) => {
    return VALID_TRAVEL_STYLE_IDS.includes(styleId);
};

export const AGE_GROUPS = [
    "15-25",
    "26-35",
    "36-50",
    "50+"
];

export const AGE_MIN = 15;
export const AGE_MAX = 150;

export const JOBS = [
    "student",
    "teacher",
    "engineer",
    "doctor",
    "nurse",
    "accountant",
    "lawyer",
    "artist",
    "designer",
    "developer",
    "manager",
    "entrepreneur",
    "freelancer",
    "marketing",
    "sales",
    "consultant",
    "researcher",
    "writer",
    "chef",
    "photographer",
    "pilot",
    "architect",
    "civil_servant",
    "military",
    "retired",
    "unemployed",
    "other"
]
export const TRAVEL_STYLES = [
    "Du lịch nghỉ dưỡng",
    "Du lịch khám phá",
    "Du lịch mạo hiểm",
    "Du lịch văn hóa",
    "Du lịch ẩm thực",
    "Du lịch sinh thái",
    "Du lịch thể thao",
    "Du lịch tâm linh",
    "Du lịch shopping",
    "Du lịch gia đình",
    "Du lịch một mình",
    "Du lịch cặp đôi",
    "Du lịch với bạn bè",
    "Du lịch công tác"
];

export const BUDGET_LEVELS = {
    LOW: { min: 0, max: 3000000, label: "Tiết kiệm (0-3 triệu)" },
    MEDIUM: { min: 3000000, max: 7000000, label: "Trung bình (3-7 triệu)" },
    HIGH: { min: 7000000, max: 15000000, label: "Cao cấp (7-15 triệu)" },
    LUXURY: { min: 15000000, max: 50000000, label: "Sang trọng (15-50 triệu)" }
};

// Helper function để validate travel preferences
export const isValidTravelStyle = (style) => {
    return TRAVEL_STYLES.includes(style);
};

// Helper function để get budget level từ số tiền
export const getBudgetLevel = (amount) => {
    for (const [level, range] of Object.entries(BUDGET_LEVELS)) {
        if (amount >= range.min && amount <= range.max) {
            return level;
        }
    }
    return null;
};
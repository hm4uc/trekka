import sequelize from './db.js';
import { Destination, DestinationCategory } from '../models/associations.js';
import { TRAVEL_STYLES } from '../config/travelConstants.js';

// === 1. CATEGORIES DATA (Giữ nguyên) ===
const categories = [
    {
        name: 'Cafe',
        icon: 'coffee',
        description: 'Các quán cafe đẹp, yên tĩnh, view đẹp',
        travel_style_id: 'food_drink',
        context_tags: ['solo', 'couple', 'friends', 'work'],
        avg_visit_duration: 90,
        popularity_score: 4.5
    },
    {
        name: 'Nhà hàng',
        icon: 'utensils',
        description: 'Nhà hàng, quán ăn ngon',
        travel_style_id: 'food_drink',
        context_tags: ['couple', 'family', 'friends'],
        avg_visit_duration: 120,
        popularity_score: 4.8
    },
    {
        name: 'Bảo tàng',
        icon: 'landmark',
        description: 'Bảo tàng, di tích lịch sử',
        travel_style_id: 'culture_history',
        context_tags: ['solo', 'family', 'educational'],
        avg_visit_duration: 180,
        popularity_score: 4.0
    },
    {
        name: 'Công viên',
        icon: 'tree',
        description: 'Công viên, không gian xanh',
        travel_style_id: 'nature',
        context_tags: ['family', 'couple', 'friends', 'solo'],
        avg_visit_duration: 120,
        popularity_score: 4.3
    },
    {
        name: 'Chợ đêm',
        icon: 'shopping-bag',
        description: 'Khu chợ đêm, ẩm thực đường phố',
        travel_style_id: 'food_drink',
        context_tags: ['friends', 'couple', 'family'],
        avg_visit_duration: 90,
        popularity_score: 4.7
    },
    {
        name: 'Hồ nước',
        icon: 'water',
        description: 'Hồ, sông, địa điểm ngắm cảnh',
        travel_style_id: 'nature',
        context_tags: ['couple', 'solo', 'chill'],
        avg_visit_duration: 60,
        popularity_score: 4.2
    },
    {
        name: 'Đền chùa',
        icon: 'temple',
        description: 'Đền, chùa, nơi tâm linh',
        travel_style_id: 'culture_history',
        context_tags: ['family', 'solo', 'spiritual'],
        avg_visit_duration: 60,
        popularity_score: 4.4
    },
    {
        name: 'Viewpoint',
        icon: 'mountain',
        description: 'Điểm ngắm cảnh đẹp',
        travel_style_id: 'nature',
        context_tags: ['couple', 'photography', 'adventure'],
        avg_visit_duration: 45,
        popularity_score: 4.6
    },
    {
        name: 'Trung tâm mua sắm',
        icon: 'store',
        description: 'Mall, trung tâm thương mại',
        travel_style_id: 'shopping_entertainment',
        context_tags: ['family', 'friends', 'shopping'],
        avg_visit_duration: 180,
        popularity_score: 4.5
    },
    {
        name: 'Phố cổ',
        icon: 'city',
        description: 'Phố cổ, khu phố lịch sử',
        travel_style_id: 'culture_history',
        context_tags: ['solo', 'couple', 'walking'],
        avg_visit_duration: 150,
        popularity_score: 4.8
    },
    {
        name: 'Bãi biển',
        icon: 'umbrella-beach',
        description: 'Bãi biển đẹp',
        travel_style_id: 'chill_relax',
        context_tags: ['family', 'couple', 'friends'],
        avg_visit_duration: 240,
        popularity_score: 4.9
    },
    {
        name: 'Núi',
        icon: 'mountain',
        description: 'Núi, trekking',
        travel_style_id: 'adventure',
        context_tags: ['adventure', 'friends', 'active'],
        avg_visit_duration: 360,
        popularity_score: 4.7
    },
    {
        name: 'Quán bar',
        icon: 'cocktail',
        description: 'Quán bar, pub',
        travel_style_id: 'shopping_entertainment',
        context_tags: ['friends', 'nightlife', 'couple'],
        avg_visit_duration: 120,
        popularity_score: 4.3
    },
    {
        name: 'Spa/Massage',
        icon: 'spa',
        description: 'Spa, massage thư giãn',
        travel_style_id: 'chill_relax',
        context_tags: ['couple', 'solo', 'luxury'],
        avg_visit_duration: 90,
        popularity_score: 4.6
    },
    {
        name: 'Khu giải trí',
        icon: 'film',
        description: 'Khu vui chơi giải trí',
        travel_style_id: 'shopping_entertainment',
        context_tags: ['family', 'friends', 'kids'],
        avg_visit_duration: 180,
        popularity_score: 4.4
    }
];

// === 2. GENERATE 100+ DESTINATIONS ===

// 2.1 CAFE HA NOI (30+ quán cafe cho section "Cafe đẹp")
const hanoiCafes = [
    {
        name: 'The Ylang Coffee',
        description: 'Quán cafe view hồ Tây tuyệt đẹp, không gian sang trọng phù hợp làm việc và hẹn hò.',
        address: '44 Phan Đình Phùng, Ba Đình, Hà Nội',
        lat: 21.0415,
        lng: 105.8320,
        avg_cost: 85000,
        rating: 4.6,
        total_reviews: 3200,
        tags: ['cafe', 'view hồ', 'wifi mạnh', 'yên tĩnh', 'làm việc'],
        ai_summary: 'View hồ Tây đẹp nhất Hà Nội, không gian thiết kế tinh tế, phù hợp hẹn hò và làm việc.',
        is_featured: true,
        images: [
            'https://images.unsplash.com/photo-1498804103079-a6351b050096?ixlib=rb-4.0.3&w=800&q=80',
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&w=800&q=80'
        ]
    },
    {
        name: 'Loading T Cafe',
        description: 'Quán cafe vintage ẩn mình trong ngõ nhỏ, không gian ấm cúng như trong phim Hàn.',
        address: '8B Hàng Tre, Hoàn Kiếm, Hà Nội',
        lat: 21.0340,
        lng: 105.8505,
        avg_cost: 65000,
        rating: 4.8,
        total_reviews: 1800,
        tags: ['cafe vintage', 'hidden gem', 'chụp ảnh', 'yên tĩnh', 'đọc sách'],
        ai_summary: 'Hidden gem với không gian vintage độc đáo, ẩn trong ngõ nhỏ phố cổ.',
        is_hidden_gem: true,
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1445116572660-236099ec97a0?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Cafe Giảng',
        description: 'Quán cafe lâu đời từ 1946, nổi tiếng với cà phê trứng - đặc sản Hà Nội.',
        address: '39 Nguyễn Hữu Huân, Hoàn Kiếm, Hà Nội',
        lat: 21.0335,
        lng: 105.8520,
        avg_cost: 45000,
        rating: 4.7,
        total_reviews: 2500,
        tags: ['cafe trứng', 'truyền thống', 'ẩm thực', 'đặc sản', 'lâu đời'],
        ai_summary: 'Nơi khởi nguồn của cà phê trứng Hà Nội, hương vị truyền thống không thể bỏ qua.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Cộng Cafe',
        description: 'Không gian mang đậm phong cách thời bao cấp, nhạc xưa, decor retro độc đáo.',
        address: '27 P. Nhà Thờ, Hàng Trống, Hoàn Kiếm, Hà Nội',
        lat: 21.0288,
        lng: 105.8492,
        avg_cost: 55000,
        rating: 4.4,
        total_reviews: 2100,
        tags: ['retro', 'bao cấp', 'chụp ảnh', 'độc đáo', 'nhạc xưa'],
        ai_summary: 'Trải nghiệm không khí thời bao cấp với decor retro và nhạc xưa đặc trưng.',
        images: ['https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'The Note Coffee',
        description: 'Quán cafe nổi tiếng với hàng ngàn mảnh giấy note đầy màu sắc trên tường.',
        address: '64 P. Lương Văn Can, Hàng Đào, Hoàn Kiếm, Hà Nội',
        lat: 21.0352,
        lng: 105.8508,
        avg_cost: 60000,
        rating: 4.9,
        total_reviews: 3800,
        tags: ['note', 'chụp ảnh', 'instagram', 'màu sắc', 'du khách'],
        ai_summary: 'Điểm check-in sống ảo với hàng ngàn mảnh giấy note đầy cảm xúc từ du khách.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Blackbird Coffee',
        description: 'Quán cafe nhỏ với view nhà thờ lớn, không gian châu Âu lãng mạn.',
        address: '5 P. Nhà Thờ, Hàng Trống, Hoàn Kiếm, Hà Nội',
        lat: 21.0289,
        lng: 105.8489,
        avg_cost: 70000,
        rating: 4.5,
        total_reviews: 1600,
        tags: ['view nhà thờ', 'lãng mạn', 'châu Âu', 'yên tĩnh', 'hẹn hò'],
        ai_summary: 'View nhà thờ lớn tuyệt đẹp, không gian lãng mạn như ở châu Âu.',
        images: ['https://images.unsplash.com/photo-1554118811-1e0d58224f24?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Hanoi House Cafe',
        description: 'Quán cafe trong ngôi nhà Pháp cổ 4 tầng, view phố cổ tuyệt đẹp.',
        address: '48A P. Hàng Bông, Hoàn Kiếm, Hà Nội',
        lat: 21.0305,
        lng: 105.8498,
        avg_cost: 75000,
        rating: 4.7,
        total_reviews: 1900,
        tags: ['nhà pháp cổ', 'view đẹp', 'kiến trúc', 'tầng cao', 'chụp ảnh'],
        ai_summary: 'Ngôi nhà Pháp cổ 4 tầng với view toàn cảnh phố cổ từ tầng thượng.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1512486130939-2c4f79935e4f?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Tired City',
        description: 'Không gian làm việc và cafe cho giới trẻ, decor công nghiệp phong cách.',
        address: '105 P. Bà Triệu, Hai Bà Trưng, Hà Nội',
        lat: 21.0139,
        lng: 105.8522,
        avg_cost: 50000,
        rating: 4.3,
        total_reviews: 1200,
        tags: ['làm việc', 'công nghiệp', 'giới trẻ', 'wifi', 'sáng tạo'],
        ai_summary: 'Không gian công nghiệp phong cách, lý tưởng cho freelancer và sinh viên.',
        images: ['https://images.unsplash.com/photo-1487958449943-2429e8be8625?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Kafen Coffee',
        description: 'Chuỗi cafe phong cách minimal, đồ uống chất lượng và bánh ngon.',
        address: '156 P. Thái Hà, Đống Đa, Hà Nội',
        lat: 21.0168,
        lng: 105.8204,
        avg_cost: 60000,
        rating: 4.4,
        total_reviews: 1800,
        tags: ['minimal', 'chuỗi', 'bánh ngon', 'chất lượng', 'hiện đại'],
        ai_summary: 'Phong cách minimal tinh tế, đồ uống và bánh chất lượng ổn định.',
        images: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Hidden Gem Coffee',
        description: 'Quán cafe nhỏ ẩn trong con hẻm, chỉ người trong ngành mới biết.',
        address: 'Ngõ 12 P. Lý Quốc Sư, Hoàn Kiếm, Hà Nội',
        lat: 21.0310,
        lng: 105.8515,
        avg_cost: 40000,
        rating: 4.8,
        total_reviews: 850,
        tags: ['hidden gem', 'hẻm nhỏ', 'người địa phương', 'giá rẻ', 'chất'],
        ai_summary: 'Quán cafe bí mật chỉ dân địa phương biết, giá rẻ nhưng chất lượng tuyệt vời.',
        is_hidden_gem: true,
        images: ['https://images.unsplash.com/photo-1461988320302-91bde64fc8e4?ixlib=rb-4.0.3&w=800&q=80']
    }
];

// Thêm 20 cafe nữa
const moreHanoiCafes = Array.from({ length: 20 }, (_, i) => {
    const cafeNames = [
        'Lofi Cafe', 'Zen Coffee', 'Cloud 9 Cafe', 'Sunrise Coffee', 'Moment Cafe',
        'The Workshop', 'Dots Cafe', 'Hanoi Social Club', 'Cafe Dinh', 'Maison de Tet',
        'Tranquil Books & Coffee', 'Oasis Cafe', 'The Cart Coffee', 'Ca Phe Pho Co',
        'Metanoia Cafe', 'The Hideaway', 'Paper & Press', 'Atelier Cafe', 'Hanoi Roastery',
        'The Morning Cafe'
    ];

    const adjectives = ['yên tĩnh', 'view đẹp', 'wifi mạnh', 'bánh ngon', 'chụp ảnh đẹp', 'lãng mạn', 'làm việc'];

    return {
        name: cafeNames[i],
        description: `Quán cafe với không gian ${adjectives[i % adjectives.length]}, phù hợp cho ${i % 3 === 0 ? 'làm việc' : i % 3 === 1 ? 'hẹn hò' : 'đọc sách'}.`,
        address: `${i + 100} ${i % 2 === 0 ? 'Phố cổ' : 'Tây Hồ'}, Hà Nội`,
        lat: 21.025 + (Math.random() * 0.03),
        lng: 105.85 + (Math.random() * 0.03),
        avg_cost: 40000 + (i * 2000),
        rating: 3.8 + (Math.random() * 1.2),
        total_reviews: 100 + (i * 50),
        tags: ['cafe', adjectives[i % adjectives.length], i % 2 === 0 ? 'view' : 'yên tĩnh'],
        images: ['https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&w=800&q=80']
    };
});

// 2.2 FOOD & RESTAURANTS (30+ địa điểm cho section "Foodtour không lối về")
const hanoiFoods = [
    {
        name: 'Phở Thìn 13 Lò Đúc',
        description: 'Quán phở nổi tiếng bậc nhất Hà Nội, nước dùng đậm đà, thơm ngon.',
        address: '13 P. Lò Đúc, Hai Bà Trưng, Hà Nội',
        lat: 21.0145,
        lng: 105.8543,
        avg_cost: 60000,
        rating: 4.8,
        total_reviews: 5200,
        tags: ['phở', 'ẩm thực', 'truyền thống', 'nổi tiếng', 'bò'],
        ai_summary: 'Phở bò chín tái thơm ngon, nước dùng đậm đà đúng chuẩn Hà Nội.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1563245372-f21724e3856d?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Bún Chả Hàng Mành',
        description: 'Bún chả ngon nức tiếng phố cổ, được Tổng thống Obama thưởng thức.',
        address: '1 P. Hàng Mành, Hoàn Kiếm, Hà Nội',
        lat: 21.0358,
        lng: 105.8489,
        avg_cost: 55000,
        rating: 4.9,
        total_reviews: 4800,
        tags: ['bún chả', 'obama', 'ẩm thực', 'nổi tiếng', 'phố cổ'],
        ai_summary: 'Bún chả ngon nức tiếng từng được Tổng thống Obama thưởng thức.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1559054663-e8d23213f55c?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Bánh Mì Phố',
        description: 'Bánh mì với nhiều loại nhân độc đáo, đặc biệt là pate tự làm.',
        address: '25 P. Hàng Cá, Hoàn Kiếm, Hà Nội',
        lat: 21.0345,
        lng: 105.8512,
        avg_cost: 35000,
        rating: 4.6,
        total_reviews: 2100,
        tags: ['bánh mì', 'street food', 'pate', 'giá rẻ', 'ngon'],
        ai_summary: 'Bánh mì với pate tự làm thơm ngon, nhiều loại nhân độc đáo.',
        images: ['https://images.unsplash.com/photo-1559054663-e8d23213f55c?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Chả Cá Lã Vọng',
        description: 'Món chả cá truyền thống gia truyền hơn 100 năm tuổi.',
        address: '14 P. Chả Cá, Hoàn Kiếm, Hà Nội',
        lat: 21.0328,
        lng: 105.8501,
        avg_cost: 180000,
        rating: 4.7,
        total_reviews: 3200,
        tags: ['chả cá', 'gia truyền', 'đặc sản', 'lâu đời', 'hải sản'],
        ai_summary: 'Món chả cá gia truyền nổi tiếng với công thức hơn 100 năm.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1565958011703-44f9829ba187?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Bún Riêu Cua Hàng Lược',
        description: 'Bún riêu cua nóng hổi, nước dùng ngọt thanh từ cua đồng.',
        address: '40 P. Hàng Lược, Hoàn Kiếm, Hà Nội',
        lat: 21.0372,
        lng: 105.8495,
        avg_cost: 45000,
        rating: 4.5,
        total_reviews: 1800,
        tags: ['bún riêu', 'cua đồng', 'ăn sáng', 'truyền thống', 'ngon'],
        ai_summary: 'Bún riêu cua nước dùng ngọt thanh, thích hợp cho bữa sáng.',
        images: ['https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Xôi Yến',
        description: 'Xôi gấc, xôi đỗ đen, xôi ngũ sắc với nhiều topping hấp dẫn.',
        address: '35B P. Nguyễn Hữu Huân, Hoàn Kiếm, Hà Nội',
        lat: 21.0330,
        lng: 105.8518,
        avg_cost: 40000,
        rating: 4.4,
        total_reviews: 1500,
        tags: ['xôi', 'ăn sáng', 'vặt', 'ngũ sắc', 'gấc'],
        ai_summary: 'Xôi nhiều loại với màu sắc bắt mắt, topping đa dạng.',
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Nem Cua Bể Hải Phòng',
        description: 'Nem cua bể giòn tan, nhân thơm ngon đúng chuẩn Hải Phòng.',
        address: '12 P. Hàng Bồ, Hoàn Kiếm, Hà Nội',
        lat: 21.0365,
        lng: 105.8490,
        avg_cost: 25000,
        rating: 4.3,
        total_reviews: 1200,
        tags: ['nem', 'hải sản', 'vặt', 'giòn', 'Hải Phòng'],
        ai_summary: 'Nem cua bể giòn rụm, nhân thơm ngon đặc trưng Hải Phòng.',
        images: ['https://images.unsplash.com/photo-1563379091339-03246963d9d6?ixlib=rb-4.0.3&w=800&q=80']
    }
];

// Thêm 20 quán ăn nữa
const moreHanoiFoods = Array.from({ length: 20 }, (_, i) => {
    const foodNames = [
        'Bánh Cuốn Thanh Trì', 'Bánh Tôm Hồ Tây', 'Bún Đậu Mắm Tôm', 'Cốm Làng Vòng',
        'Bánh Gối Hà Nội', 'Bánh Tráng Trộn', 'Trà Sữa Xingfu Tang', 'Kem Tràng Tiền',
        'Bánh Bao Chiên', 'Chè Bốn Mùa', 'Bánh Mì Que', 'Bánh Xèo Miền Nam',
        'Lẩu Thái Tom Yum', 'Sushi Nhật Bản', 'Pizza Ý', 'Burger Mỹ',
        'Dimsum Hồng Kông', 'Cơm Tấm Sài Gòn', 'Bún Bò Huế', 'Mì Quảng'
    ];

    const types = ['ăn sáng', 'ăn trưa', 'ăn tối', 'ăn vặt', 'lẩu', 'món nước', 'món khô'];
    const tags = ['ngon', 'giá rẻ', 'đông khách', 'nổi tiếng', 'hidden gem'];

    return {
        name: foodNames[i],
        description: `${foodNames[i]} ngon đúng điệu, ${i % 2 === 0 ? 'phù hợp ăn sáng' : 'lý tưởng cho bữa tối'}.`,
        address: `${i + 50} ${i % 3 === 0 ? 'Phố cổ' : i % 3 === 1 ? 'Tây Hồ' : 'Cầu Giấy'}, Hà Nội`,
        lat: 21.02 + (Math.random() * 0.05),
        lng: 105.83 + (Math.random() * 0.05),
        avg_cost: 30000 + (i * 5000),
        rating: 3.9 + (Math.random() * 1.1),
        total_reviews: 200 + (i * 40),
        tags: [types[i % types.length], tags[i % tags.length], 'ẩm thực'],
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-4.0.3&w=800&q=80']
    };
});

// 2.3 TOURIST ATTRACTIONS (30+ địa điểm du lịch)
const attractions = [
    {
        name: 'Hồ Gươm',
        description: 'Trái tim của Hà Nội với Tháp Rùa cổ kính và cầu Thê Húc đỏ rực.',
        address: 'Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
        lat: 21.0285,
        lng: 105.8542,
        avg_cost: 0,
        rating: 4.8,
        total_reviews: 12500,
        tags: ['hồ', 'lịch sử', 'dạo bộ', 'chụp ảnh', 'biểu tượng'],
        ai_summary: 'Trái tim Hà Nội với cảnh đẹp bình minh và hoàng hôn, lý tưởng cho những buổi dạo bộ.',
        is_featured: true,
        images: [
            'https://images.unsplash.com/photo-1548013146-72479768bada?ixlib=rb-4.0.3&w=800&q=80',
            'https://images.unsplash.com/photo-1528181304800-259b08848526?ixlib=rb-4.0.3&w=800&q=80'
        ]
    },
    {
        name: 'Văn Miếu - Quốc Tử Giám',
        description: 'Trường đại học đầu tiên của Việt Nam, di tích lịch sử hơn 1000 năm.',
        address: '58 Quốc Tử Giám, Đống Đa, Hà Nội',
        lat: 21.0283,
        lng: 105.8357,
        avg_cost: 30000,
        rating: 4.7,
        total_reviews: 8500,
        tags: ['di tích', 'lịch sử', 'văn hóa', 'kiến trúc', 'unesco'],
        ai_summary: 'Di tích lịch sử quan trọng với kiến trúc cổ kính và 82 bia tiến sĩ.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1597236182633-0c0132155e8e?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Lăng Chủ tịch Hồ Chí Minh',
        description: 'Nơi an nghỉ của Chủ tịch Hồ Chí Minh, công trình kiến trúc độc đáo.',
        address: '19 Ngọc Hà, Ba Đình, Hà Nội',
        lat: 21.0368,
        lng: 105.8342,
        avg_cost: 0,
        rating: 4.8,
        total_reviews: 9200,
        tags: ['lăng', 'lịch sử', 'văn hóa', 'quốc gia', 'trang nghiêm'],
        ai_summary: 'Công trình kiến trúc độc đáo, nơi tưởng niệm vị lãnh tụ kính yêu của dân tộc.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1552465011-b4e30bf7349d?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Chùa Một Cột',
        description: 'Biểu tượng kiến trúc độc đáo hình đóa sen của Hà Nội.',
        address: 'Chùa Một Cột, Đội Cấn, Ba Đình, Hà Nội',
        lat: 21.0365,
        lng: 105.8346,
        avg_cost: 0,
        rating: 4.4,
        total_reviews: 4800,
        tags: ['chùa', 'kiến trúc', 'lịch sử', 'tâm linh', 'biểu tượng'],
        ai_summary: 'Kiến trúc độc đáo hình đóa sen mọc lên từ mặt nước, biểu tượng của Hà Nội.',
        images: ['https://images.unsplash.com/photo-1545569341-9eb8b30979d9?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Phố cổ Hà Nội',
        description: '36 phố phường với kiến trúc Pháp cổ và những con phố chuyên doanh.',
        address: 'Phố cổ, Hoàn Kiếm, Hà Nội',
        lat: 21.0350,
        lng: 105.8510,
        avg_cost: 200000,
        rating: 4.9,
        total_reviews: 9800,
        tags: ['phố cổ', 'ẩm thực', 'mua sắm', 'lịch sử', 'đi bộ'],
        ai_summary: 'Khu phố cổ nhộn nhịp với các con phố chuyên bán từng mặt hàng riêng biệt.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1528127269322-539801943592?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Nhà hát Lớn Hà Nội',
        description: 'Công trình kiến trúc Pháp cổ đẹp nhất, nơi biểu diễn nghệ thuật đỉnh cao.',
        address: '1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
        lat: 21.0245,
        lng: 105.8582,
        avg_cost: 200000,
        rating: 4.6,
        total_reviews: 3200,
        tags: ['nhà hát', 'kiến trúc', 'nghệ thuật', 'lịch sử', 'pháp cổ'],
        ai_summary: 'Kiến trúc Pháp cổ tuyệt đẹp, thường xuyên có các buổi biểu diễn nghệ thuật.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1519677100203-8c0a78842b5e?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Bảo tàng Dân tộc học',
        description: 'Bảo tàng trưng bày văn hóa 54 dân tộc với kiến trúc hình trống đồng độc đáo.',
        address: 'Nguyễn Văn Huyên, Cầu Giấy, Hà Nội',
        lat: 21.0405,
        lng: 105.7993,
        avg_cost: 40000,
        rating: 4.5,
        total_reviews: 4500,
        tags: ['bảo tàng', 'văn hóa', 'giáo dục', 'kiến trúc', '54 dân tộc'],
        ai_summary: 'Kiến trúc hình trống đồng độc đáo, nơi tìm hiểu văn hóa đa dạng các dân tộc.',
        images: ['https://images.unsplash.com/photo-1588614959060-4d144f28b207?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Công viên Thủ Lệ',
        description: 'Công viên giải trí và vườn thú ở trung tâm thành phố.',
        address: 'Đường Bưởi, Ba Đình, Hà Nội',
        lat: 21.0320,
        lng: 105.8042,
        avg_cost: 50000,
        rating: 4.2,
        total_reviews: 3200,
        tags: ['công viên', 'vườn thú', 'gia đình', 'giải trí', 'trẻ em'],
        ai_summary: 'Công viên giải trí với vườn thú, phù hợp cho các gia đình có trẻ nhỏ.',
        images: ['https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Hồ Tây',
        description: 'Hồ nước ngọt tự nhiên lớn nhất Hà Nội, view hoàng hôn tuyệt đẹp.',
        address: 'Hồ Tây, Tây Hồ, Hà Nội',
        lat: 21.0545,
        lng: 105.8201,
        avg_cost: 0,
        rating: 4.6,
        total_reviews: 6800,
        tags: ['hồ', 'hoàng hôn', 'dạo bộ', 'đạp xe', 'cafe view'],
        ai_summary: 'Hồ nước lớn với cảnh hoàng hôn tuyệt đẹp, nhiều quán cafe view hồ.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1523059623039-a9ed027e7fad?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Đền Ngọc Sơn',
        description: 'Ngôi đền nằm trên đảo Ngọc của Hồ Gươm, kiến trúc cổ độc đáo.',
        address: 'Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
        lat: 21.0290,
        lng: 105.8535,
        avg_cost: 30000,
        rating: 4.5,
        total_reviews: 4200,
        tags: ['đền', 'tâm linh', 'kiến trúc', 'hồ gươm', 'lịch sử'],
        ai_summary: 'Ngôi đền cổ trên đảo Ngọc, kiến trúc hài hòa với thiên nhiên.',
        images: ['https://images.unsplash.com/photo-1552465011-b4e30bf7349d?ixlib=rb-4.0.3&w=800&q=80']
    }
];

// Thêm 20 điểm tham quan nữa
const moreAttractions = Array.from({ length: 20 }, (_, i) => {
    const attractionNames = [
        'Vườn hoa Chí Linh', 'Cột cờ Hà Nội', 'Bảo tàng Hồ Chí Minh', 'Bảo tàng Lịch sử Quân sự',
        'Nhà tù Hỏa Lò', 'Chợ Đồng Xuân', 'Chợ Hôm', 'Phố đi bộ Hồ Gươm',
        'Phố sách Đinh Lễ', 'Cầu Long Biên', 'Chùa Trấn Quốc', 'Chùa Quán Sứ',
        'Nhà thờ Lớn Hà Nội', 'Bảo tàng Phụ nữ Việt Nam', 'Công viên nước Hồ Tây',
        'Royal City Vincom', 'Aeon Mall Long Biên', 'Trung tâm thương mại Tràng Tiền Plaza',
        'Bitexco Financial Tower', 'Landmark 81'
    ];

    const types = ['di tích', 'bảo tàng', 'chợ', 'công viên', 'trung tâm thương mại', 'tôn giáo'];

    return {
        name: attractionNames[i],
        description: `${attractionNames[i]} - ${i % 3 === 0 ? 'điểm đến không thể bỏ qua' : i % 3 === 1 ? 'nơi lý tưởng cho du khách' : 'địa điểm check-in đẹp'}.`,
        address: `Hà Nội`,
        lat: 21.01 + (Math.random() * 0.08),
        lng: 105.80 + (Math.random() * 0.08),
        avg_cost: i % 4 === 0 ? 0 : 50000 + (i * 5000),
        rating: 3.7 + (Math.random() * 1.3),
        total_reviews: 800 + (i * 100),
        tags: [types[i % types.length], i % 2 === 0 ? 'miễn phí' : 'có phí', 'tham quan'],
        images: ['https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&w=800&q=80']
    };
});

// 2.4 BARS & NIGHTLIFE (15+ địa điểm)
const bars = Array.from({ length: 15 }, (_, i) => {
    const barNames = [
        'The Lighthouse', 'Polar Bear Bar', 'The Republic', 'Malt South',
        'Neo Cafe & Bar', 'Turtle Lake Brewery', 'The Tipsy Unicorn', 'Whisky & Wits',
        'Rooftop Bar 1900', 'The Social Club', 'Jazz Club Minh', 'Acoustic Bar',
        'The Lab Cocktails', 'Speakeasy Hanoi', 'Beer Street Tavern'
    ];

    const themes = ['jazz', 'cocktail', 'craft beer', 'rooftop', 'speakeasy', 'live music'];

    return {
        name: barNames[i],
        description: `${barNames[i]} - ${themes[i % themes.length]} bar với không gian ${i % 2 === 0 ? 'sang trọng' : 'thân thiện'}.`,
        address: `${i + 30} ${i % 3 === 0 ? 'Tây Hồ' : i % 3 === 1 ? 'Ba Đình' : 'Hai Bà Trưng'}, Hà Nội`,
        lat: 21.03 + (Math.random() * 0.02),
        lng: 105.84 + (Math.random() * 0.02),
        avg_cost: 120000 + (i * 10000),
        rating: 4.0 + (Math.random() * 1.0),
        total_reviews: 300 + (i * 50),
        tags: ['bar', themes[i % themes.length], 'nightlife', i % 2 === 0 ? 'sang trọng' : 'bình dân'],
        opening_hours: {
            monday: '18:00-02:00',
            tuesday: '18:00-02:00',
            wednesday: '18:00-02:00',
            thursday: '18:00-02:00',
            friday: '18:00-04:00',
            saturday: '18:00-04:00',
            sunday: '18:00-00:00'
        },
        images: ['https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&w=800&q=80']
    };
});

// 2.5 OTHER REGIONS (25+ địa điểm khác ở Việt Nam)
const otherRegions = [
    // Miền Bắc
    {
        name: 'Vịnh Hạ Long',
        description: 'Di sản thiên nhiên thế giới với hàng nghìn hòn đảo đá vôi tuyệt đẹp.',
        address: 'Vịnh Hạ Long, Quảng Ninh',
        lat: 20.9500,
        lng: 107.0667,
        avg_cost: 500000,
        rating: 4.9,
        total_reviews: 15600,
        tags: ['di sản', 'biển', 'du thuyền', 'thiên nhiên', 'unesco'],
        ai_summary: 'Kỳ quan thiên nhiên thế giới với cảnh quan núi đá vôi trên biển độc đáo.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1552465011-b4e30bf7349d?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Sa Pa',
        description: 'Thị trấn vùng cao với ruộng bậc thang và văn hóa dân tộc thiểu số.',
        address: 'Sa Pa, Lào Cai',
        lat: 22.3364,
        lng: 103.8441,
        avg_cost: 300000,
        rating: 4.8,
        total_reviews: 9800,
        tags: ['núi', 'trekking', 'văn hóa', 'homestay', 'ruộng bậc thang'],
        ai_summary: 'Thị trấn vùng cao nổi tiếng với cảnh quan ruộng bậc thang và văn hóa các dân tộc.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1523059623039-a9ed027e7fad?ixlib=rb-4.0.3&w=800&q=80']
    },
    // Miền Trung
    {
        name: 'Phố cổ Hội An',
        description: 'Phố cổ được UNESCO công nhận với kiến trúc Nhật - Hoa - Việt độc đáo.',
        address: 'Hội An, Quảng Nam',
        lat: 15.8801,
        lng: 108.3380,
        avg_cost: 200000,
        rating: 4.9,
        total_reviews: 12800,
        tags: ['phố cổ', 'unesco', 'đèn lồng', 'ẩm thực', 'di sản'],
        ai_summary: 'Phố cổ với kiến trúc độc đáo, nổi tiếng với những chiếc đèn lồng vào buổi tối.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1523413363576-54b2c8df8857?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Cố đô Huế',
        description: 'Kinh đô cuối cùng của Việt Nam với hệ thống đền đài, lăng tẩm cổ kính.',
        address: 'Thành phố Huế, Thừa Thiên Huế',
        lat: 16.4637,
        lng: 107.5909,
        avg_cost: 250000,
        rating: 4.7,
        total_reviews: 9500,
        tags: ['cố đô', 'lăng tẩm', 'di sản', 'lịch sử', 'unesco'],
        ai_summary: 'Kinh đô cổ với kiến trúc cung đình độc đáo và ẩm thực cung đình nổi tiếng.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1528181304800-259b08848526?ixlib=rb-4.0.3&w=800&q=80']
    },
    // Miền Nam
    {
        name: 'Chợ Bến Thành',
        description: 'Biểu tượng của Sài Gòn với hơn 100 năm lịch sử.',
        address: 'Lê Lợi, Bến Thành, Quận 1, TP.HCM',
        lat: 10.7720,
        lng: 106.6983,
        avg_cost: 150000,
        rating: 4.5,
        total_reviews: 11200,
        tags: ['chợ', 'mua sắm', 'ẩm thực', 'biểu tượng', 'sài gòn'],
        ai_summary: 'Biểu tượng của Sài Gòn với hơn 100 năm lịch sử, nơi mua sắm và ẩm thực đa dạng.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1580655653885-65763b2597d0?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Nhà thờ Đức Bà Sài Gòn',
        description: 'Nhà thờ Công giáo lớn nhất và đặc sắc nhất tại Thành phố Hồ Chí Minh.',
        address: 'Công xã Paris, Bến Nghé, Quận 1, TP.HCM',
        lat: 10.7797,
        lng: 106.6991,
        avg_cost: 0,
        rating: 4.7,
        total_reviews: 8500,
        tags: ['nhà thờ', 'kiến trúc', 'lịch sử', 'tôn giáo', 'pháp cổ'],
        ai_summary: 'Kiến trúc Pháp cổ đẹp nhất Sài Gòn, được xây dựng từ cuối thế kỷ 19.',
        is_featured: true,
        images: ['https://images.unsplash.com/photo-1588614959060-4d144f28b207?ixlib=rb-4.0.3&w=800&q=80']
    },
    {
        name: 'Cafe Apartments',
        description: 'Toà nhà chung cư cũ được cải tạo thành không gian cafe, ăn uống độc đáo.',
        address: '42 Nguyễn Huệ, Quận 1, TP.HCM',
        lat: 10.7730,
        lng: 106.7035,
        avg_cost: 75000,
        rating: 4.6,
        total_reviews: 3200,
        tags: ['cafe', 'kiến trúc', 'check-in', 'độc đáo', 'sáng tạo'],
        ai_summary: 'Toà nhà chung cư cũ được cải tạo thành không gian sáng tạo với nhiều quán cafe độc đáo.',
        is_hidden_gem: true,
        images: ['https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&w=800&q=80']
    }
];

// Thêm 18 địa điểm khác ở các vùng
const moreOtherRegions = Array.from({ length: 18 }, (_, i) => {
    const regionNames = [
        'Đà Lạt', 'Nha Trang', 'Phú Quốc', 'Đà Nẵng', 'Cần Thơ',
        'Vũng Tàu', 'Mũi Né', 'Tam Đảo', 'Mai Châu', 'Cát Bà',
        'Mộc Châu', 'Ba Vì', 'Cao Bằng', 'Yên Tử', 'Tràng An',
        'Tam Cốc - Bích Động', 'Chùa Hương', 'Pù Luông'
    ];

    const regions = [
        { name: 'Đà Lạt', lat: 11.9404, lng: 108.4583 },
        { name: 'Nha Trang', lat: 12.2388, lng: 109.1967 },
        { name: 'Phú Quốc', lat: 10.2270, lng: 103.9676 },
        { name: 'Đà Nẵng', lat: 16.0544, lng: 108.2022 },
        { name: 'Cần Thơ', lat: 10.0452, lng: 105.7469 },
        { name: 'Vũng Tàu', lat: 10.3460, lng: 107.0843 },
        { name: 'Mũi Né', lat: 10.9574, lng: 108.2940 },
        { name: 'Tam Đảo', lat: 21.4547, lng: 105.6436 },
        { name: 'Mai Châu', lat: 20.6594, lng: 105.0880 },
        { name: 'Cát Bà', lat: 20.8000, lng: 107.0167 },
        { name: 'Mộc Châu', lat: 20.8500, lng: 104.6333 },
        { name: 'Ba Vì', lat: 21.2000, lng: 105.4333 },
        { name: 'Cao Bằng', lat: 22.6667, lng: 106.2500 },
        { name: 'Yên Tử', lat: 21.1333, lng: 106.6333 },
        { name: 'Tràng An', lat: 20.2581, lng: 105.9136 },
        { name: 'Tam Cốc', lat: 20.2167, lng: 105.9167 },
        { name: 'Chùa Hương', lat: 20.6231, lng: 105.7225 },
        { name: 'Pù Luông', lat: 20.4667, lng: 105.1667 }
    ];

    const region = regions[i];
    const types = ['núi', 'biển', 'đảo', 'thành phố', 'nông thôn', 'di tích', 'tâm linh'];

    return {
        name: region.name,
        description: `${region.name} - ${i % 3 === 0 ? 'điểm đến tuyệt vời cho kỳ nghỉ' : i % 3 === 1 ? 'nơi khám phá văn hóa và thiên nhiên' : 'địa điểm lý tưởng cho chuyến phượt'}.`,
        address: region.name,
        lat: region.lat,
        lng: region.lng,
        avg_cost: 200000 + (i * 50000),
        rating: 4.0 + (Math.random() * 1.0),
        total_reviews: 1000 + (i * 200),
        tags: [types[i % types.length], i % 2 === 0 ? 'du lịch' : 'nghỉ dưỡng', 'Việt Nam'],
        images: ['https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&w=800&q=80']
    };
});

// === 3. COMBINE ALL DESTINATIONS ===
const allDestinations = [
    ...hanoiCafes,
    ...moreHanoiCafes,
    ...hanoiFoods,
    ...moreHanoiFoods,
    ...attractions,
    ...moreAttractions,
    ...bars,
    ...otherRegions,
    ...moreOtherRegions
];

// === 4. SEED FUNCTION ===
async function seedLargeDatabase() {
    try {
        console.log('🌱 Bắt đầu seed database lớn (100+ destinations)...');

        // Kiểm tra kết nối database
        await sequelize.authenticate();
        console.log('✅ Đã kết nối database');

        // Đồng bộ model với database (không dùng alter: true)
        // Chỉ tạo bảng nếu chưa có, không thay đổi cấu trúc
        await sequelize.sync({ force: false });
        console.log('✅ Đã đồng bộ model');

        // Xóa dữ liệu cũ
        console.log('🗑️  Xóa dữ liệu cũ...');
        await Destination.destroy({ where: {}, truncate: true, cascade: true });
        await DestinationCategory.destroy({ where: {}, truncate: true, cascade: true });
        console.log('✅ Đã xóa dữ liệu cũ');

        // Tạo categories
        console.log('📁 Đang tạo categories...');
        const createdCategories = [];

        for (const categoryData of categories) {
            try {
                const category = await DestinationCategory.create(categoryData);
                createdCategories.push(category);
                console.log(`✅ Đã tạo category: ${category.name}`);
            } catch (error) {
                console.error(`❌ Lỗi khi tạo category ${categoryData.name}:`, error.message);
            }
        }

        console.log(`✅ Đã tạo ${createdCategories.length} categories`);

        // Lấy ID của các category
        const categoryMap = {};
        createdCategories.forEach(cat => {
            categoryMap[cat.name] = cat.id;
        });

        // Tạo destinations
        console.log(`📍 Đang tạo ${allDestinations.length} destinations...`);
        let createdCount = 0;
        let errorCount = 0;

        for (const destData of allDestinations) {
            try {
                // Xác định category dựa trên tags và name
                let categoryId;

                // Logic phân loại category
                if (destData.tags?.includes('cafe') || destData.name?.toLowerCase().includes('cafe') || destData.name?.toLowerCase().includes('coffee')) {
                    categoryId = categoryMap['Cafe'];
                } else if (destData.tags?.includes('nhà hàng') || destData.tags?.includes('ăn') || destData.tags?.includes('phở') || destData.tags?.includes('bún') || destData.tags?.includes('bánh')) {
                    categoryId = categoryMap['Nhà hàng'];
                } else if (destData.tags?.includes('bar') || destData.tags?.includes('nightlife')) {
                    categoryId = categoryMap['Quán bar'];
                } else if (destData.tags?.includes('bảo tàng') || destData.tags?.includes('di tích') || destData.tags?.includes('lịch sử')) {
                    categoryId = categoryMap['Bảo tàng'];
                } else if (destData.tags?.includes('công viên') || destData.tags?.includes('vườn')) {
                    categoryId = categoryMap['Công viên'];
                } else if (destData.tags?.includes('hồ') || destData.tags?.includes('sông')) {
                    categoryId = categoryMap['Hồ nước'];
                } else if (destData.tags?.includes('chùa') || destData.tags?.includes('đền') || destData.tags?.includes('tâm linh')) {
                    categoryId = categoryMap['Đền chùa'];
                } else if (destData.tags?.includes('view') || destData.tags?.includes('ngắm cảnh')) {
                    categoryId = categoryMap['Viewpoint'];
                } else if (destData.tags?.includes('chợ') || destData.tags?.includes('mua sắm')) {
                    categoryId = destData.tags?.includes('đêm') ? categoryMap['Chợ đêm'] : categoryMap['Trung tâm mua sắm'];
                } else if (destData.tags?.includes('phố cổ')) {
                    categoryId = categoryMap['Phố cổ'];
                } else if (destData.tags?.includes('biển') || destData.tags?.includes('bãi')) {
                    categoryId = categoryMap['Bãi biển'];
                } else if (destData.tags?.includes('núi') || destData.tags?.includes('trekking')) {
                    categoryId = categoryMap['Núi'];
                } else if (destData.tags?.includes('spa') || destData.tags?.includes('massage')) {
                    categoryId = categoryMap['Spa/Massage'];
                } else if (destData.tags?.includes('giải trí') || destData.tags?.includes('vui chơi')) {
                    categoryId = categoryMap['Khu giải trí'];
                } else {
                    // Mặc định là Cafe
                    categoryId = categoryMap['Cafe'] || createdCategories[0]?.id;
                }

                // Tạo destination
                await Destination.create({
                    ...destData,
                    categoryId: categoryId,
                    is_active: true,
                    // Thêm thông tin mặc định nếu thiếu
                    opening_hours: destData.opening_hours || {
                        monday: '08:00-22:00',
                        tuesday: '08:00-22:00',
                        wednesday: '08:00-22:00',
                        thursday: '08:00-22:00',
                        friday: '08:00-23:00',
                        saturday: '08:00-23:00',
                        sunday: '08:00-22:00'
                    },
                    images: destData.images || ['https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&w=800&q=80'],
                    // Tạo geometry từ lat/lng
                    geom: sequelize.fn('ST_SetSRID',
                        sequelize.fn('ST_MakePoint', destData.lng, destData.lat),
                        4326
                    )
                });

                createdCount++;
                if (createdCount % 20 === 0) {
                    console.log(`✅ Đã tạo ${createdCount} destinations...`);
                }
            } catch (error) {
                errorCount++;
                console.error(`❌ Lỗi khi tạo destination ${destData.name}:`, error.message);
            }
        }

        console.log(`🎉 ĐÃ HOÀN THÀNH SEED LỚN!`);
        console.log('\n📊 THỐNG KÊ DỮ LIỆU:');
        console.log(`- Categories: ${createdCategories.length}`);
        console.log(`- Destinations: ${createdCount} (thành công) / ${errorCount} (lỗi)`);
        console.log(`- Tổng số địa điểm: ${allDestinations.length}`);

        // Phân tích theo khu vực
        const hanoiCount = allDestinations.filter(d =>
            d.address?.includes('Hà Nội') || (d.lat > 20.9 && d.lat < 21.1 && d.lng > 105.7 && d.lng < 106.0)
        ).length;

        const northCount = allDestinations.filter(d =>
            !d.address?.includes('Hà Nội') && d.lat > 20.0 && d.lat < 23.5
        ).length;

        const centralCount = allDestinations.filter(d =>
            d.lat > 15.0 && d.lat < 20.0
        ).length;

        const southCount = allDestinations.filter(d =>
            d.lat < 15.0
        ).length;

        console.log(`\n📍 PHÂN BỐ THEO KHU VỰC:`);
        console.log(`- Hà Nội: ${hanoiCount} địa điểm`);
        console.log(`- Miền Bắc khác: ${northCount} địa điểm`);
        console.log(`- Miền Trung: ${centralCount} địa điểm`);
        console.log(`- Miền Nam: ${southCount} địa điểm`);

        console.log(`\n🏷️  PHÂN BỐ THEO LOẠI (ước tính):`);
        console.log(`- Cafe: ~${hanoiCafes.length + moreHanoiCafes.length} địa điểm`);
        console.log(`- Nhà hàng/Quán ăn: ~${hanoiFoods.length + moreHanoiFoods.length} địa điểm`);
        console.log(`- Điểm tham quan: ~${attractions.length + moreAttractions.length} địa điểm`);
        console.log(`- Bar/Nightlife: ~${bars.length} địa điểm`);
        console.log(`- Các vùng khác: ~${otherRegions.length + moreOtherRegions.length} địa điểm`);

        console.log('\n🚀 Dữ liệu đã sẵn sàng cho app!');
        console.log('👉 Truy cập http://localhost:3000/api-docs để test API');

        process.exit(0);

    } catch (error) {
        console.error('❌ Lỗi khi seed database:', error);
        console.error('Chi tiết lỗi:', error.message);
        process.exit(1);
    }
}

// Chạy seed
seedLargeDatabase();
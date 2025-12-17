import { fakerVI as faker } from '@faker-js/faker';
import sequelize from './db.js';
import {
    DestinationCategory,
    Destination,
    Event
} from '../models/associations.js';

// Helper to generate geometry point
const point = (lat, lng) => {
    return {type: 'Point', coordinates: [lng, lat]};
};

const seed = async () => {
    try {
        console.log('🌱 Starting seed...');
        await sequelize.authenticate();

        // Recreate database schema
        await sequelize.sync({force: true});
        console.log('✅ Database synced');

        // 1. Create Categories
        console.log('Creating categories...');
        const categoriesData = [
            {name: 'Cafe', icon: 'coffee', travel_style_id: 'food_drink', context_tags: ['solo', 'couple', 'friends']},
            {name: 'Museum', icon: 'landmark', travel_style_id: 'culture_history', context_tags: ['family', 'solo']},
            {name: 'Park', icon: 'tree', travel_style_id: 'nature', context_tags: ['family', 'friends', 'couple']},
            {name: 'Restaurant', icon: 'utensils', travel_style_id: 'food_drink', context_tags: ['family', 'friends', 'couple']},
            {name: 'Shopping Mall', icon: 'shopping-bag', travel_style_id: 'shopping_entertainment', context_tags: ['friends', 'family']},
            {name: 'Historical Site', icon: 'monument', travel_style_id: 'culture_history', context_tags: ['solo', 'family']},
            {name: 'Bar/Pub', icon: 'glass-cheers', travel_style_id: 'shopping_entertainment', context_tags: ['friends', 'couple']},
            {name: 'Art Gallery', icon: 'palette', travel_style_id: 'culture_history', context_tags: ['solo', 'couple']},
            {name: 'Street Food', icon: 'hamburger', travel_style_id: 'local_life', context_tags: ['friends', 'solo']},
            {name: 'Lake', icon: 'water', travel_style_id: 'nature', context_tags: ['couple', 'solo']},
            {name: 'Religious Site', icon: 'place-of-worship', travel_style_id: 'culture_history', context_tags: ['family', 'solo']},
            {name: 'Entertainment', icon: 'theater-masks', travel_style_id: 'shopping_entertainment', context_tags: ['friends', 'family', 'couple']}
        ].map(c => ({...c, id: faker.string.uuid()}));

        await DestinationCategory.bulkCreate(categoriesData);
        console.log(`✅ Created ${categoriesData.length} categories`);

        // Helper to find category ID
        const getCatId = (name) => {
            const cat = categoriesData.find(c => c.name === name);
            return cat ? cat.id : categoriesData[0].id;
        };

        // 2. Create Destinations (Hanoi)
        console.log('Creating destinations...');
        const hanoiDestinations = [
            {
                name: "Hồ Hoàn Kiếm",
                categoryName: "Lake",
                address: "Hoàn Kiếm, Hà Nội",
                lat: 21.0286,
                lng: 105.8521,
                description: "Trái tim của thủ đô Hà Nội, nổi tiếng với Tháp Rùa và Cầu Thê Húc. Nơi lý tưởng để đi dạo và ngắm cảnh.",
                avg_cost: 0,
                opening_hours: { mon: "00:00-23:59", tue: "00:00-23:59", wed: "00:00-23:59", thu: "00:00-23:59", fri: "00:00-23:59", sat: "00:00-23:59", sun: "00:00-23:59" },
                images: ["https://images.unsplash.com/photo-1599835669876-6a8359539679?q=80&w=1000&auto=format&fit=crop"],
                tags: ["walking", "scenic", "landmark", "history"]
            },
            {
                name: "Văn Miếu - Quốc Tử Giám",
                categoryName: "Historical Site",
                address: "58 Quốc Tử Giám, Đống Đa, Hà Nội",
                lat: 21.0293,
                lng: 105.8360,
                description: "Trường đại học đầu tiên của Việt Nam, nơi lưu giữ những giá trị văn hóa và lịch sử lâu đời.",
                avg_cost: 30000,
                opening_hours: { mon: "08:00-17:00", tue: "08:00-17:00", wed: "08:00-17:00", thu: "08:00-17:00", fri: "08:00-17:00", sat: "08:00-17:00", sun: "08:00-17:00" },
                images: ["https://images.unsplash.com/photo-1583417319070-4a69db38a482?q=80&w=1000&auto=format&fit=crop"],
                tags: ["culture", "history", "architecture", "learning"]
            },
            {
                name: "Lăng Chủ tịch Hồ Chí Minh",
                categoryName: "Historical Site",
                address: "2 Hùng Vương, Ba Đình, Hà Nội",
                lat: 21.0368,
                lng: 105.8346,
                description: "Nơi an nghỉ của Chủ tịch Hồ Chí Minh, vị lãnh tụ kính yêu của dân tộc Việt Nam.",
                avg_cost: 0,
                opening_hours: { mon: "Closed", tue: "07:30-10:30", wed: "07:30-10:30", thu: "07:30-10:30", fri: "Closed", sat: "07:30-11:00", sun: "07:30-11:00" },
                images: ["https://images.unsplash.com/photo-1557750255-c76072a7aad1?q=80&w=1000&auto=format&fit=crop"],
                tags: ["history", "politics", "landmark"]
            },
            {
                name: "Hoàng thành Thăng Long",
                categoryName: "Historical Site",
                address: "19C Hoàng Diệu, Ba Đình, Hà Nội",
                lat: 21.0341,
                lng: 105.8413,
                description: "Di sản văn hóa thế giới được UNESCO công nhận, minh chứng cho lịch sử ngàn năm văn hiến.",
                avg_cost: 30000,
                opening_hours: { mon: "Closed", tue: "08:00-17:00", wed: "08:00-17:00", thu: "08:00-17:00", fri: "08:00-17:00", sat: "08:00-17:00", sun: "08:00-17:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Doan_Mon_Gate_-_Imperial_Citadel_of_Thang_Long.jpg/1200px-Doan_Mon_Gate_-_Imperial_Citadel_of_Thang_Long.jpg"],
                tags: ["history", "unesco", "architecture"]
            },
            {
                name: "Phố Cổ Hà Nội",
                categoryName: "Historical Site",
                address: "Hoàn Kiếm, Hà Nội",
                lat: 21.0343,
                lng: 105.8515,
                description: "Khu phố cổ kính với 36 phố phường sầm uất, nơi lưu giữ nét văn hóa truyền thống của người Hà Nội.",
                avg_cost: 0,
                opening_hours: { mon: "00:00-23:59", tue: "00:00-23:59", wed: "00:00-23:59", thu: "00:00-23:59", fri: "00:00-23:59", sat: "00:00-23:59", sun: "00:00-23:59" },
                images: ["https://images.unsplash.com/photo-1509064794184-da9e98584617?q=80&w=1000&auto=format&fit=crop"],
                tags: ["culture", "shopping", "food", "walking"]
            },
            {
                name: "Nhà thờ Lớn Hà Nội",
                categoryName: "Religious Site",
                address: "40 Nhà Chung, Hoàn Kiếm, Hà Nội",
                lat: 21.0288,
                lng: 105.8490,
                description: "Công trình kiến trúc Gothic đặc sắc, điểm check-in quen thuộc của giới trẻ và du khách.",
                avg_cost: 0,
                opening_hours: { mon: "08:00-11:00, 14:00-17:00", tue: "08:00-11:00, 14:00-17:00", wed: "08:00-11:00, 14:00-17:00", thu: "08:00-11:00, 14:00-17:00", fri: "08:00-11:00, 14:00-17:00", sat: "08:00-11:00, 14:00-17:00", sun: "07:00-11:30, 15:00-21:00" },
                images: ["https://images.unsplash.com/photo-1565622638868-5633392b0e4d?q=80&w=1000&auto=format&fit=crop"],
                tags: ["architecture", "religion", "photo"]
            },
            {
                name: "Chùa Trấn Quốc",
                categoryName: "Religious Site",
                address: "Thanh Niên, Tây Hồ, Hà Nội",
                lat: 21.0480,
                lng: 105.8369,
                description: "Ngôi chùa cổ nhất Hà Nội, nằm trên một hòn đảo nhỏ xinh đẹp ở Hồ Tây.",
                avg_cost: 0,
                opening_hours: { mon: "08:00-16:00", tue: "08:00-16:00", wed: "08:00-16:00", thu: "08:00-16:00", fri: "08:00-16:00", sat: "08:00-16:00", sun: "08:00-16:00" },
                images: ["https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=1000&auto=format&fit=crop"],
                tags: ["religion", "history", "scenic"]
            },
            {
                name: "Hồ Tây",
                categoryName: "Lake",
                address: "Tây Hồ, Hà Nội",
                lat: 21.0567,
                lng: 105.8244,
                description: "Hồ nước ngọt lớn nhất Hà Nội, không gian thoáng đãng, lãng mạn, thích hợp ngắm hoàng hôn.",
                avg_cost: 0,
                opening_hours: { mon: "00:00-23:59", tue: "00:00-23:59", wed: "00:00-23:59", thu: "00:00-23:59", fri: "00:00-23:59", sat: "00:00-23:59", sun: "00:00-23:59" },
                images: ["https://images.unsplash.com/photo-1558612616-24571461b0e4?q=80&w=1000&auto=format&fit=crop"],
                tags: ["nature", "relax", "sunset", "couple"]
            },
            {
                name: "Nhà hát Lớn Hà Nội",
                categoryName: "Historical Site",
                address: "1 Tràng Tiền, Hoàn Kiếm, Hà Nội",
                lat: 21.0256,
                lng: 105.8575,
                description: "Công trình kiến trúc Pháp kinh điển, nơi diễn ra các sự kiện văn hóa nghệ thuật lớn.",
                avg_cost: 300000,
                opening_hours: { mon: "Varies", tue: "Varies", wed: "Varies", thu: "Varies", fri: "Varies", sat: "Varies", sun: "Varies" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Hanoi_Opera_House_2014.jpg/1200px-Hanoi_Opera_House_2014.jpg"],
                tags: ["architecture", "art", "music"]
            },
            {
                name: "Di tích Nhà tù Hỏa Lò",
                categoryName: "Museum",
                address: "1 Hỏa Lò, Hoàn Kiếm, Hà Nội",
                lat: 21.0253,
                lng: 105.8464,
                description: "Minh chứng lịch sử về sự kiên cường của các chiến sĩ cách mạng Việt Nam.",
                avg_cost: 30000,
                opening_hours: { mon: "08:00-17:00", tue: "08:00-17:00", wed: "08:00-17:00", thu: "08:00-17:00", fri: "08:00-17:00", sat: "08:00-17:00", sun: "08:00-17:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Maison_Centrale_gate.jpg/1200px-Maison_Centrale_gate.jpg"],
                tags: ["history", "museum", "war"]
            },
            {
                name: "Bảo tàng Dân tộc học Việt Nam",
                categoryName: "Museum",
                address: "Nguyễn Văn Huyên, Cầu Giấy, Hà Nội",
                lat: 21.0405,
                lng: 105.7985,
                description: "Nơi trưng bày, giới thiệu văn hóa của 54 dân tộc anh em Việt Nam.",
                avg_cost: 40000,
                opening_hours: { mon: "Closed", tue: "08:30-17:30", wed: "08:30-17:30", thu: "08:30-17:30", fri: "08:30-17:30", sat: "08:30-17:30", sun: "08:30-17:30" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Vietnam_Museum_of_Ethnology_-_main_building.jpg/1200px-Vietnam_Museum_of_Ethnology_-_main_building.jpg"],
                tags: ["culture", "museum", "learning", "family"]
            },
            {
                name: "Chợ Đồng Xuân",
                categoryName: "Shopping Mall",
                address: "Đồng Xuân, Hoàn Kiếm, Hà Nội",
                lat: 21.0383,
                lng: 105.8503,
                description: "Khu chợ đầu mối lớn nhất Hà Nội, sầm uất và đa dạng hàng hóa.",
                avg_cost: 0,
                opening_hours: { mon: "06:00-18:00", tue: "06:00-18:00", wed: "06:00-18:00", thu: "06:00-18:00", fri: "06:00-18:00", sat: "06:00-18:00", sun: "06:00-18:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Cho_Dong_Xuan.jpg/1200px-Cho_Dong_Xuan.jpg"],
                tags: ["shopping", "local", "market"]
            },
            {
                name: "Cầu Long Biên",
                categoryName: "Historical Site",
                address: "Long Biên, Hà Nội",
                lat: 21.0427,
                lng: 105.8586,
                description: "Chứng nhân lịch sử vắt ngang sông Hồng, điểm chụp ảnh hoài cổ tuyệt đẹp.",
                avg_cost: 0,
                opening_hours: { mon: "00:00-23:59", tue: "00:00-23:59", wed: "00:00-23:59", thu: "00:00-23:59", fri: "00:00-23:59", sat: "00:00-23:59", sun: "00:00-23:59" },
                images: ["https://images.unsplash.com/photo-1616485962373-48e862496b04?q=80&w=1000&auto=format&fit=crop"],
                tags: ["history", "bridge", "photo", "sunset"]
            },
            {
                name: "Đền Ngọc Sơn",
                categoryName: "Religious Site",
                address: "Hồ Hoàn Kiếm, Hà Nội",
                lat: 21.0307,
                lng: 105.8524,
                description: "Ngôi đền linh thiêng nằm trên đảo Ngọc giữa hồ Hoàn Kiếm.",
                avg_cost: 30000,
                opening_hours: { mon: "08:00-18:00", tue: "08:00-18:00", wed: "08:00-18:00", thu: "08:00-18:00", fri: "08:00-18:00", sat: "08:00-18:00", sun: "08:00-18:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/The_Huc_Bridge_-_Ngoc_Son_Temple.jpg/1200px-The_Huc_Bridge_-_Ngoc_Son_Temple.jpg"],
                tags: ["religion", "history", "culture"]
            },
            {
                name: "Nhà hát Múa rối Thăng Long",
                categoryName: "Entertainment",
                address: "57B Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội",
                lat: 21.0303,
                lng: 105.8533,
                description: "Nơi thưởng thức nghệ thuật múa rối nước truyền thống độc đáo.",
                avg_cost: 100000,
                opening_hours: { mon: "13:00-20:00", tue: "13:00-20:00", wed: "13:00-20:00", thu: "13:00-20:00", fri: "13:00-20:00", sat: "13:00-20:00", sun: "13:00-20:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Water_Puppet_Theatre_Hanoi.jpg/1200px-Water_Puppet_Theatre_Hanoi.jpg"],
                tags: ["art", "culture", "show"]
            },
            {
                name: "Bảo tàng Mỹ thuật Việt Nam",
                categoryName: "Museum",
                address: "66 Nguyễn Thái Học, Ba Đình, Hà Nội",
                lat: 21.0296,
                lng: 105.8374,
                description: "Kho tàng nghệ thuật tạo hình của Việt Nam từ thời tiền sử đến nay.",
                avg_cost: 40000,
                opening_hours: { mon: "08:30-17:00", tue: "08:30-17:00", wed: "08:30-17:00", thu: "08:30-17:00", fri: "08:30-17:00", sat: "08:30-17:00", sun: "08:30-17:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Vietnam_National_Museum_of_Fine_Arts.jpg/1200px-Vietnam_National_Museum_of_Fine_Arts.jpg"],
                tags: ["art", "museum", "culture"]
            },
            {
                name: "Phố Đường Tàu",
                categoryName: "Cafe",
                address: "Trần Phú, Hoàn Kiếm, Hà Nội",
                lat: 21.0300,
                lng: 105.8430,
                description: "Địa điểm check-in độc đáo với đường tàu chạy sát nhà dân và các quán cafe.",
                avg_cost: 50000,
                opening_hours: { mon: "08:00-22:00", tue: "08:00-22:00", wed: "08:00-22:00", thu: "08:00-22:00", fri: "08:00-22:00", sat: "08:00-22:00", sun: "08:00-22:00" },
                images: ["https://images.unsplash.com/photo-1595322728368-0260f4053348?q=80&w=1000&auto=format&fit=crop"],
                tags: ["cafe", "photo", "unique"]
            },
            {
                name: "Lotte Center Hà Nội (Đài quan sát)",
                categoryName: "Entertainment",
                address: "54 Liễu Giai, Ba Đình, Hà Nội",
                lat: 21.0320,
                lng: 105.8125,
                description: "Ngắm toàn cảnh Hà Nội từ trên cao tại đài quan sát Lotte.",
                avg_cost: 230000,
                opening_hours: { mon: "09:00-23:00", tue: "09:00-23:00", wed: "09:00-23:00", thu: "09:00-23:00", fri: "09:00-23:00", sat: "09:00-23:00", sun: "09:00-23:00" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Lotte_Center_Hanoi.jpg/1200px-Lotte_Center_Hanoi.jpg"],
                tags: ["view", "modern", "luxury"]
            },
            {
                name: "Làng gốm Bát Tràng",
                categoryName: "Historical Site",
                address: "Bát Tràng, Gia Lâm, Hà Nội",
                lat: 20.9750,
                lng: 105.9130,
                description: "Làng nghề gốm sứ truyền thống nổi tiếng lâu đời.",
                avg_cost: 0,
                opening_hours: { mon: "08:00-17:30", tue: "08:00-17:30", wed: "08:00-17:30", thu: "08:00-17:30", fri: "08:00-17:30", sat: "08:00-17:30", sun: "08:00-17:30" },
                images: ["https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Bat_Trang_Pottery_Village.jpg/1200px-Bat_Trang_Pottery_Village.jpg"],
                tags: ["craft", "culture", "shopping"]
            }
        ];

        const destinationsData = hanoiDestinations.map(dest => ({
            id: faker.string.uuid(),
            categoryId: getCatId(dest.categoryName),
            name: dest.name,
            description: dest.description,
            address: dest.address,
            lat: dest.lat,
            lng: dest.lng,
            geom: point(dest.lat, dest.lng),
            avg_cost: dest.avg_cost,
            rating: faker.number.float({min: 4.0, max: 5.0, precision: 0.1}),
            total_reviews: 0,
            total_likes: 0,
            total_checkins: 0,
            tags: dest.tags,
            opening_hours: dest.opening_hours,
            images: dest.images,
            ai_summary: `AI Summary for ${dest.name}: ${dest.description}`,
            best_time_to_visit: '09:00-11:00',
            recommended_duration: 90,
            is_hidden_gem: false,
            is_active: true
        }));

        await Destination.bulkCreate(destinationsData);
        console.log(`✅ Created ${destinationsData.length} destinations`);

        // 3. Create Events (Hanoi)
        console.log('Creating events...');
        const hanoiEvents = [
            {
                name: "Hanoi Marathon 2025",
                description: "Giải chạy marathon quốc tế thường niên tại Hà Nội, quy tụ hàng nghìn vận động viên.",
                location: "Hồ Hoàn Kiếm, Hà Nội",
                lat: 21.0286,
                lng: 105.8521,
                type: "workshop", // Using 'workshop' as 'sport' is not in enum if strict, but let's assume flexible or map to closest
                price: 500000,
                images: ["https://images.unsplash.com/photo-1552674605-46d536d2e609?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Lễ hội Âm nhạc Gió Mùa (Monsoon)",
                description: "Lễ hội âm nhạc quốc tế lớn nhất Hà Nội với sự tham gia của nhiều nghệ sĩ nổi tiếng.",
                location: "Hoàng thành Thăng Long, Hà Nội",
                lat: 21.0341,
                lng: 105.8413,
                type: "concert",
                price: 1000000,
                images: ["https://images.unsplash.com/photo-1459749411177-0473ef71607b?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Hội sách Công viên Thống Nhất",
                description: "Ngày hội văn hóa đọc với hàng ngàn đầu sách và các hoạt động giao lưu tác giả.",
                location: "Công viên Thống Nhất, Hà Nội",
                lat: 21.0167,
                lng: 105.8433,
                type: "exhibition",
                price: 0,
                images: ["https://images.unsplash.com/photo-1524578271613-d550eacf6090?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Triển lãm Nghệ thuật Đương đại",
                description: "Trưng bày các tác phẩm nghệ thuật độc đáo của các nghệ sĩ trẻ Việt Nam.",
                location: "VCCA, Royal City, Hà Nội",
                lat: 21.0031,
                lng: 105.8153,
                type: "exhibition",
                price: 0,
                images: ["https://images.unsplash.com/photo-1518998053901-5348d3969105?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Đêm nhạc Jazz tại Nhà hát Lớn",
                description: "Thưởng thức những giai điệu Jazz cổ điển trong không gian sang trọng.",
                location: "Nhà hát Lớn Hà Nội",
                lat: 21.0256,
                lng: 105.8575,
                type: "concert",
                price: 1500000,
                images: ["https://images.unsplash.com/photo-1511192336575-5a79af67a629?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Lễ hội Ẩm thực Hồ Tây",
                description: "Khám phá tinh hoa ẩm thực Hà Nội và quốc tế bên bờ Hồ Tây lộng gió.",
                location: "Công viên nước Hồ Tây, Hà Nội",
                lat: 21.0620,
                lng: 105.8170,
                type: "festival",
                price: 100000,
                images: ["https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Chợ hoa Tết Hàng Lược",
                description: "Chợ hoa truyền thống lâu đời, mang đậm không khí Tết của người Hà Nội.",
                location: "Hàng Lược, Hoàn Kiếm, Hà Nội",
                lat: 21.0380,
                lng: 105.8480,
                type: "festival",
                price: 0,
                images: ["https://images.unsplash.com/photo-1548625361-18886594166d?q=80&w=1000&auto=format&fit=crop"]
            },
            {
                name: "Workshop Làm gốm Bát Tràng",
                description: "Trải nghiệm tự tay làm ra những sản phẩm gốm sứ độc đáo.",
                location: "Làng gốm Bát Tràng, Hà Nội",
                lat: 20.9750,
                lng: 105.9130,
                type: "workshop",
                price: 200000,
                images: ["https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?q=80&w=1000&auto=format&fit=crop"]
            }
        ];

        const eventsData = hanoiEvents.map(evt => {
            const startDate = faker.date.future();
            return {
                id: faker.string.uuid(),
                event_name: evt.name,
                event_description: evt.description,
                event_location: evt.location,
                lat: evt.lat,
                lng: evt.lng,
                geom: point(evt.lat, evt.lng),
                event_start: startDate,
                event_end: new Date(startDate.getTime() + 4 * 60 * 60 * 1000),
                event_ticket_price: evt.price,
                event_type: evt.type,
                event_organizer: "Trekka Events",
                event_capacity: 500,
                event_tags: ["culture", "entertainment"],
                images: evt.images,
                total_attendees: 0,
                total_likes: 0,
                is_active: true,
                is_featured: true
            };
        });

        await Event.bulkCreate(eventsData);
        console.log(`✅ Created ${eventsData.length} events`);

        console.log('✨ Seed completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seed failed:', error);
        process.exit(1);
    }
};

seed();


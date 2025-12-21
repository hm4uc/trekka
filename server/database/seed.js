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
                images: ["https://pixabay.com/vi/photos/hanoi-city-vietnam-lake-red-leaves-4166172"],
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
                images: ["https://pixabay.com/vi/photos/hanoi-city-vietnam-lake-red-leaves-4166172"],
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
                images: ["https://pixabay.com/vi/photos/hanoi-city-vietnam-lake-red-leaves-4166172"],
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
                images: ["https://pixabay.com/vi/photos/ho%c3%a0ng-th%c3%a0nh-th%c4%83ng-long-hanoi-7202348"],
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
                images: ["https://tl.cdnchinhphu.vn/zoom/700_438/Uploads/images/pho%20co(2).jpg"],
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
                images: ["https://pixabay.com/vi/photos/nh%c3%a0-th%e1%bb%9d-c%c3%b4ng-gi%c3%a1o-nh%c3%a0-th%e1%bb%9d-l%e1%bb%9bn-h%c3%a0-n%e1%bb%99i-7589133"],
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
                images: ["https://www.pexels.com/photo/tran-quoc-pagoda-in-hanoi-vietnam-25851510"],
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
                images: ["https://www.pexels.com/photo/lake-and-city-behind-16705654"],
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
                images: ["https://www.pexels.com/photo/facade-of-hanoi-opera-house-in-vietnam-under-gray-sky-11712728/"],
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
                images: ["https://vj-prod-website-cms.s3.ap-southeast-1.amazonaws.com/akjsld-1755241485697.jpg"],
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
                images: ["https://upload.wikimedia.org/wikipedia/commons/f/f3/Dan_toc_hoc_1.jpg"],
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
                images: ["https://danviet.ex-cdn.com/resize/800x550/files/f1/296231569849192448/2024/7/16/hinh-anh-cho-dong-xuan-co-tich-trong-toi-17211210467121587947688.jpg"],
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
                images: ["https://www.pexels.com/photo/people-riding-motorcycles-near-train-3300834/"],
                tags: ["history", "bridge", "photo", "sunset"]
            },
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
                images: ["https://www.pexels.com/photo/energetic-marathon-in-h-i-phong-vietnam-29485297/"]
            },
            {
                name: "Hội sách Công viên Thống Nhất",
                description: "Ngày hội văn hóa đọc với hàng ngàn đầu sách và các hoạt động giao lưu tác giả.",
                location: "Công viên Thống Nhất, Hà Nội",
                lat: 21.0167,
                lng: 105.8433,
                type: "exhibition",
                price: 0,
                images: ["https://pixabay.com/vi/photos/s%c3%a1ch-b%c3%bccherstapel-c%c3%a2y-r%c6%a1m-v%c4%83n-h%e1%bb%8dc-2085589/"]
            },
            {
                name: "Triển lãm Nghệ thuật Đương đại",
                description: "Trưng bày các tác phẩm nghệ thuật độc đáo của các nghệ sĩ trẻ Việt Nam.",
                location: "VCCA, Royal City, Hà Nội",
                lat: 21.0031,
                lng: 105.8153,
                type: "exhibition",
                price: 0,
                images: ["https://pixabay.com/vi/photos/tri%e1%bb%83n-l%c3%a3m-vi%e1%bb%87t-nam-7632297/"]
            },
            {
                name: "Chợ hoa Tết Hàng Lược",
                description: "Chợ hoa truyền thống lâu đời, mang đậm không khí Tết của người Hà Nội.",
                location: "Hàng Lược, Hoàn Kiếm, Hà Nội",
                lat: 21.0380,
                lng: 105.8480,
                type: "festival",
                price: 0,
                images: ["https://pixabay.com/vi/photos/con-g%c3%a1i-nh%e1%bb%afng-b%c3%b4ng-hoa-t%e1%ba%bft-ng%c3%a0y-t%e1%ba%bft-8351533/"]
            },
            {
                name: "Workshop Làm gốm Bát Tràng",
                description: "Trải nghiệm tự tay làm ra những sản phẩm gốm sứ độc đáo.",
                location: "Làng gốm Bát Tràng, Hà Nội",
                lat: 20.9750,
                lng: 105.9130,
                type: "workshop",
                price: 200000,
                images: ["https://pixabay.com/vi/photos/b%c3%acnh-%c4%91%e1%bb%93-g%e1%bb%91m-g%e1%bb%91m-s%e1%bb%a9-%c4%91%e1%ba%a5t-nung-64975/"]
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


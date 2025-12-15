import { fakerVI as faker } from '@faker-js/faker';
import sequelize from './db.js';
import {
    Profile,
    DestinationCategory,
    Destination,
    Event,
    Review,
    Trip,
    TripDestination,
    TripEvent,
    Group,
    GroupMember,
    Notification,
    UserFeedback,
    TripShare,
    GroupComment,
    AIRequest,
    AIResponse,
    SearchLog
} from '../models/associations.js';
import bcrypt from 'bcrypt';

// Configuration
const TOTAL_USERS = 20;
const TOTAL_DESTINATIONS = 100;
const TOTAL_EVENTS = 30;
const TOTAL_REVIEWS = 300;
const TOTAL_TRIPS = 30;

// Cities Configuration
const CITIES = [
    { name: "Hà Nội", lat: 21.0285, lng: 105.8542 },
    { name: "Hồ Chí Minh", lat: 10.8231, lng: 106.6297 },
    { name: "Đà Nẵng", lat: 16.0544, lng: 108.2022 },
    { name: "Hội An", lat: 15.8801, lng: 108.3380 },
    { name: "Đà Lạt", lat: 11.9404, lng: 108.4583 },
    { name: "Nha Trang", lat: 12.2388, lng: 109.1967 },
    { name: "Huế", lat: 16.4637, lng: 107.5909 },
    { name: "Sa Pa", lat: 22.3364, lng: 103.8438 },
    { name: "Hạ Long", lat: 20.9069, lng: 107.0734 },
    { name: "Phú Quốc", lat: 10.2899, lng: 103.9840 }
];

// Real Data for Vietnam
const REAL_DESTINATIONS = [
    // Hanoi
    { name: "Hồ Hoàn Kiếm", categoryName: "Lake", address: "Hoàn Kiếm, Hà Nội", lat: 21.0286, lng: 105.8521, description: "Trái tim của thủ đô Hà Nội, nổi tiếng với Tháp Rùa và Cầu Thê Húc." },
    { name: "Văn Miếu - Quốc Tử Giám", categoryName: "Historical Site", address: "58 Quốc Tử Giám, Đống Đa, Hà Nội", lat: 21.0293, lng: 105.8360, description: "Trường đại học đầu tiên của Việt Nam." },
    { name: "Lăng Chủ tịch Hồ Chí Minh", categoryName: "Historical Site", address: "2 Hùng Vương, Ba Đình, Hà Nội", lat: 21.0368, lng: 105.8346, description: "Nơi an nghỉ của Chủ tịch Hồ Chí Minh." },
    { name: "Hoàng thành Thăng Long", categoryName: "Historical Site", address: "19C Hoàng Diệu, Ba Đình, Hà Nội", lat: 21.0341, lng: 105.8413, description: "Di sản văn hóa thế giới được UNESCO công nhận." },
    { name: "Phố Cổ Hà Nội", categoryName: "Historical Site", address: "Hoàn Kiếm, Hà Nội", lat: 21.0343, lng: 105.8515, description: "Khu phố cổ kính với 36 phố phường sầm uất." },

    // Ho Chi Minh City
    { name: "Chợ Bến Thành", categoryName: "Shopping Mall", address: "Lê Lợi, Quận 1, TP. HCM", lat: 10.7725, lng: 106.6980, description: "Biểu tượng của Sài Gòn, nơi buôn bán sầm uất." },
    { name: "Dinh Độc Lập", categoryName: "Historical Site", address: "135 Nam Kỳ Khởi Nghĩa, Quận 1, TP. HCM", lat: 10.7770, lng: 106.6953, description: "Di tích lịch sử quan trọng, từng là nơi ở của Tổng thống VNCH." },
    { name: "Nhà thờ Đức Bà", categoryName: "Historical Site", address: "01 Công xã Paris, Quận 1, TP. HCM", lat: 10.7798, lng: 106.6990, description: "Kiến trúc Pháp cổ kính giữa lòng Sài Gòn." },
    { name: "Phố đi bộ Nguyễn Huệ", categoryName: "Park", address: "Nguyễn Huệ, Quận 1, TP. HCM", lat: 10.7744, lng: 106.7035, description: "Nơi vui chơi, giải trí sầm uất về đêm." },
    { name: "Landmark 81", categoryName: "Shopping Mall", address: "Bình Thạnh, TP. HCM", lat: 10.7950, lng: 106.7218, description: "Tòa nhà cao nhất Việt Nam." },

    // Da Nang
    { name: "Cầu Rồng", categoryName: "Historical Site", address: "Sơn Trà, Đà Nẵng", lat: 16.0610, lng: 108.2270, description: "Cây cầu có thiết kế hình rồng độc đáo, phun lửa và nước vào cuối tuần." },
    { name: "Bà Nà Hills", categoryName: "Park", address: "Hòa Vang, Đà Nẵng", lat: 15.9955, lng: 107.9955, description: "Khu du lịch nổi tiếng với Cầu Vàng và làng Pháp." },
    { name: "Biển Mỹ Khê", categoryName: "Lake", address: "Sơn Trà, Đà Nẵng", lat: 16.0599, lng: 108.2436, description: "Một trong những bãi biển đẹp nhất hành tinh." },
    { name: "Ngũ Hành Sơn", categoryName: "Historical Site", address: "Ngũ Hành Sơn, Đà Nẵng", lat: 16.0047, lng: 108.2633, description: "Quần thể 5 ngọn núi đá vôi với nhiều hang động và chùa chiền." },

    // Hoi An
    { name: "Phố cổ Hội An", categoryName: "Historical Site", address: "Minh An, Hội An", lat: 15.8771, lng: 108.3260, description: "Di sản văn hóa thế giới với những ngôi nhà cổ màu vàng đặc trưng." },
    { name: "Chùa Cầu", categoryName: "Historical Site", address: "Nguyễn Thị Minh Khai, Hội An", lat: 15.8772, lng: 108.3261, description: "Biểu tượng của Hội An." },
    { name: "Biển An Bàng", categoryName: "Lake", address: "Cẩm An, Hội An", lat: 15.9097, lng: 108.3380, description: "Bãi biển yên bình và hoang sơ." },

    // Ha Long
    { name: "Vịnh Hạ Long", categoryName: "Lake", address: "Hạ Long, Quảng Ninh", lat: 20.9101, lng: 107.1839, description: "Kỳ quan thiên nhiên thế giới với hàng nghìn đảo đá vôi." },
    { name: "Sun World Ha Long", categoryName: "Park", address: "Bãi Cháy, Hạ Long", lat: 20.9550, lng: 107.0430, description: "Tổ hợp vui chơi giải trí lớn nhất miền Bắc." },

    // Da Lat
    { name: "Hồ Xuân Hương", categoryName: "Lake", address: "Phường 1, Đà Lạt", lat: 11.9424, lng: 108.4433, description: "Trái tim của thành phố ngàn hoa." },
    { name: "Quảng trường Lâm Viên", categoryName: "Park", address: "Phường 10, Đà Lạt", lat: 11.9388, lng: 108.4445, description: "Nổi bật với nụ hoa Atiso và hoa Dã Quỳ khổng lồ." },
    { name: "Thung lũng Tình Yêu", categoryName: "Park", address: "Phường 8, Đà Lạt", lat: 11.9833, lng: 108.4483, description: "Điểm đến lãng mạn cho các cặp đôi." },

    // Nha Trang
    { name: "VinWonders Nha Trang", categoryName: "Park", address: "Đảo Hòn Tre, Nha Trang", lat: 12.2183, lng: 109.2433, description: "Công viên giải trí đẳng cấp quốc tế." },
    { name: "Tháp Bà Ponagar", categoryName: "Historical Site", address: "Vĩnh Phước, Nha Trang", lat: 12.2654, lng: 109.1960, description: "Quần thể kiến trúc Chăm Pa cổ kính." },

    // Hue
    { name: "Đại Nội Huế", categoryName: "Historical Site", address: "Phú Hậu, Huế", lat: 16.4690, lng: 107.5776, description: "Hoàng cung của triều đại nhà Nguyễn." },
    { name: "Chùa Thiên Mụ", categoryName: "Historical Site", address: "Hương Hòa, Huế", lat: 16.4534, lng: 107.5449, description: "Ngôi chùa cổ linh thiêng bên dòng sông Hương." },

    // Sapa
    { name: "Đỉnh Fansipan", categoryName: "Historical Site", address: "Sa Pa, Lào Cai", lat: 22.3034, lng: 103.7752, description: "Nóc nhà Đông Dương." },
    { name: "Bản Cát Cát", categoryName: "Historical Site", address: "San Sả Hồ, Sa Pa", lat: 22.3294, lng: 103.8333, description: "Ngôi làng của người H'Mông với vẻ đẹp đơn sơ." },

    // Phu Quoc
    { name: "VinWonders Phú Quốc", categoryName: "Park", address: "Gành Dầu, Phú Quốc", lat: 10.3367, lng: 103.8583, description: "Công viên chủ đề lớn nhất Việt Nam." },
    { name: "Bãi Sao", categoryName: "Lake", address: "An Thới, Phú Quốc", lat: 10.0533, lng: 104.0383, description: "Bãi biển cát trắng mịn đẹp nhất Phú Quốc." }
];

const REAL_EVENTS = [
    { name: "Lễ hội Pháo hoa Quốc tế Đà Nẵng (DIFF)", type: "festival", location: "Sông Hàn, Đà Nẵng", lat: 16.0718, lng: 108.2234, description: "Lễ hội pháo hoa lớn nhất khu vực." },
    { name: "Festival Huế", type: "festival", location: "Đại Nội, Huế", lat: 16.4690, lng: 107.5776, description: "Lễ hội văn hóa nghệ thuật tầm cỡ quốc gia." },
    { name: "Carnival Hạ Long", type: "festival", location: "Bãi Cháy, Hạ Long", lat: 20.9550, lng: 107.0430, description: "Lễ hội đường phố sôi động chào hè." },
    { name: "Lễ hội Hoa Đà Lạt", type: "festival", location: "Quảng trường Lâm Viên, Đà Lạt", lat: 11.9388, lng: 108.4445, description: "Tôn vinh vẻ đẹp của các loài hoa." },
    { name: "Countdown Lights", type: "concert", location: "Phố đi bộ Nguyễn Huệ, TP. HCM", lat: 10.7744, lng: 106.7035, description: "Sự kiện âm nhạc đếm ngược chào năm mới." },
    { name: "Lễ hội Âm nhạc Gió Mùa (Monsoon)", type: "festival", location: "Hoàng thành Thăng Long, Hà Nội", lat: 21.0341, lng: 105.8413, description: "Lễ hội âm nhạc quốc tế lớn nhất Hà Nội." },
    { name: "Giải chạy VnExpress Marathon Quy Nhơn", type: "workshop", location: "Quy Nhơn, Bình Định", lat: 13.7820, lng: 109.2190, description: "Giải chạy marathon bên bờ biển." },
    { name: "Lễ hội Chùa Hương", type: "festival", location: "Hương Sơn, Mỹ Đức, Hà Nội", lat: 20.6170, lng: 105.7330, description: "Lễ hội Phật giáo lớn nhất miền Bắc." },
    { name: "Lễ hội Cà phê Buôn Ma Thuột", type: "festival", location: "Buôn Ma Thuột, Đắk Lắk", lat: 12.6667, lng: 108.0500, description: "Quảng bá thương hiệu cà phê Việt Nam." },
    { name: "Ironman 70.3 Vietnam", type: "workshop", location: "Đà Nẵng", lat: 16.0544, lng: 108.2022, description: "Cuộc thi ba môn phối hợp quốc tế." }
];

// Helper to generate random location around a city
const getRandomLocation = (city) => {
    const radius = 0.05; // ~5km
    const lat = city.lat + (Math.random() - 0.5) * radius;
    const lng = city.lng + (Math.random() - 0.5) * radius;
    return {lat, lng};
};

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
            {
                name: 'Restaurant',
                icon: 'utensils',
                travel_style_id: 'food_drink',
                context_tags: ['family', 'friends', 'couple']
            },
            {
                name: 'Shopping Mall',
                icon: 'shopping-bag',
                travel_style_id: 'shopping_entertainment',
                context_tags: ['friends', 'family']
            },
            {
                name: 'Historical Site',
                icon: 'monument',
                travel_style_id: 'culture_history',
                context_tags: ['solo', 'family']
            },
            {
                name: 'Bar/Pub',
                icon: 'glass-cheers',
                travel_style_id: 'shopping_entertainment',
                context_tags: ['friends', 'couple']
            },
            {
                name: 'Art Gallery',
                icon: 'palette',
                travel_style_id: 'culture_history',
                context_tags: ['solo', 'couple']
            },
            {name: 'Street Food', icon: 'hamburger', travel_style_id: 'local_life', context_tags: ['friends', 'solo']},
            {name: 'Lake', icon: 'water', travel_style_id: 'nature', context_tags: ['couple', 'solo']}
        ].map(c => ({...c, id: faker.string.uuid()}));

        await DestinationCategory.bulkCreate(categoriesData);
        const categories = categoriesData;
        console.log(`✅ Created ${categories.length} categories`);

        // 2. Create Users
        console.log('Creating users...');
        const passwordHash = await bcrypt.hash('password123', 10);
        const usersData = [];

        // Create specific test user
        usersData.push({
            id: faker.string.uuid(),
            usr_fullname: 'Nguyễn Minh Anh',
            usr_email: 'minhanh@example.com',
            usr_password_hash: passwordHash,
            usr_gender: 'female',
            usr_age: 24,
            usr_job: 'marketing',
            usr_preferences: ['nature', 'food_drink', 'culture_history'],
            usr_budget: 5000000,
            usr_avatar: faker.image.avatar(),
            usr_bio: 'Yêu du lịch, thích khám phá những quán cafe đẹp và yên tĩnh.',
            total_likes: 0,
            total_checkins: 0
        });

        // Create random users
        for (let i = 0; i < TOTAL_USERS - 1; i++) {
            usersData.push({
                id: faker.string.uuid(),
                usr_fullname: faker.person.fullName(),
                usr_email: faker.internet.email(),
                usr_password_hash: passwordHash,
                usr_gender: faker.person.sex(),
                usr_age: faker.number.int({min: 18, max: 60}),
                usr_job: 'student', // Simplified
                usr_preferences: faker.helpers.arrayElements(['nature', 'food_drink', 'culture_history', 'adventure'], 2),
                usr_budget: faker.number.int({min: 1000000, max: 20000000}),
                usr_avatar: faker.image.avatar(),
                usr_bio: faker.lorem.sentence(),
                total_likes: 0,
                total_checkins: 0
            });
        }

        const rawUsers = [...usersData];
        await Profile.bulkCreate(usersData);
        const users = rawUsers;
        console.log(`✅ Created ${users.length} users`);

        // 3. Create Destinations
        console.log('Creating destinations...');
        const destinationsData = [];

        for (let i = 0; i < TOTAL_DESTINATIONS; i++) {
            const loc = getRandomLocation(faker.helpers.arrayElement(CITIES));
            let category, name, description, address;
            let isReal = false;

            if (i < REAL_DESTINATIONS.length) {
                const realDest = REAL_DESTINATIONS[i];
                category = categories.find(c => c.name === realDest.categoryName) || faker.helpers.arrayElement(categories);
                name = realDest.name;
                description = realDest.description;
                address = realDest.address;
                isReal = true;
            } else {
                category = faker.helpers.arrayElement(categories);
                name = faker.company.name() + ' ' + category.name;
                description = faker.lorem.paragraph();
                address = faker.location.streetAddress() + ', Hà Nội';
            }

            const isLarge = isReal || faker.datatype.boolean(); // Real places are considered large/popular

            destinationsData.push({
                id: faker.string.uuid(),
                categoryId: category.id,
                name: name,
                description: description,
                address: address,
                lat: loc.lat,
                lng: loc.lng,
                geom: point(loc.lat, loc.lng),
                avg_cost: isLarge
                    ? faker.number.int({min: 200000, max: 2000000})
                    : faker.number.int({min: 20000, max: 150000}),
                rating: faker.number.float({min: 3.5, max: 5.0, precision: 0.1}),
                total_reviews: isLarge
                    ? faker.number.int({min: 100, max: 1000})
                    : faker.number.int({min: 0, max: 50}),
                total_likes: isLarge
                    ? faker.number.int({min: 500, max: 5000})
                    : faker.number.int({min: 0, max: 100}),
                total_checkins: isLarge
                    ? faker.number.int({min: 1000, max: 10000})
                    : faker.number.int({min: 0, max: 200}),
                tags: faker.helpers.arrayElements(['wifi', 'parking', 'ac', 'outdoor', 'live_music', 'pet_friendly', 'credit_card'], 3),
                opening_hours: {
                    mon: "08:00-22:00",
                    tue: "08:00-22:00",
                    wed: "08:00-22:00",
                    thu: "08:00-22:00",
                    fri: "08:00-23:00",
                    sat: "08:00-23:00",
                    sun: "08:00-22:00"
                },
                images: [faker.image.urlLoremFlickr({category: 'city'}), faker.image.urlLoremFlickr({category: 'food'})],
                ai_summary: faker.lorem.sentence(),
                best_time_to_visit: '16:00-18:00',
                recommended_duration: faker.number.int({min: 30, max: 180}),
                is_hidden_gem: !isLarge && faker.datatype.boolean(0.5), // Small places have 50% chance to be hidden gems
                is_active: true
            });
        }

        const rawDestinations = [...destinationsData];
        await Destination.bulkCreate(destinationsData);
        const destinations = rawDestinations;
        console.log(`✅ Created ${destinations.length} destinations`);

        // 4. Create Events
        console.log('Creating events...');
        const eventsData = [];

        for (let i = 0; i < TOTAL_EVENTS; i++) {
            const loc = getRandomLocation(faker.helpers.arrayElement(CITIES));
            const startDate = faker.date.future();
            const endDate = new Date(startDate.getTime() + 2 * 60 * 60 * 1000); // 2 hours later

            let name, description, location, type;
            let isReal = false;

            if (i < REAL_EVENTS.length) {
                const realEvent = REAL_EVENTS[i];
                name = realEvent.name;
                description = realEvent.description;
                location = realEvent.location;
                type = realEvent.type;
                isReal = true;
            } else {
                name = faker.company.catchPhrase();
                description = faker.lorem.paragraph();
                location = faker.location.streetAddress() + ', Hà Nội';
                type = faker.helpers.arrayElement(['concert', 'exhibition', 'workshop', 'festival']);
            }

            const isLarge = isReal || faker.datatype.boolean();

            eventsData.push({
                id: faker.string.uuid(),
                event_name: name,
                event_description: description,
                event_location: location,
                lat: loc.lat,
                lng: loc.lng,
                geom: point(loc.lat, loc.lng),
                event_start: startDate,
                event_end: endDate,
                event_ticket_price: isLarge
                    ? faker.number.int({min: 500000, max: 5000000})
                    : faker.number.int({min: 0, max: 200000}),
                event_type: type,
                event_organizer: faker.company.name(),
                event_capacity: isLarge
                    ? faker.number.int({min: 1000, max: 20000})
                    : faker.number.int({min: 20, max: 200}),
                event_tags: faker.helpers.arrayElements(['music', 'art', 'education', 'food'], 2),
                images: [faker.image.urlLoremFlickr({category: 'nightlife'})],
                total_attendees: isLarge
                    ? faker.number.int({min: 500, max: 10000})
                    : faker.number.int({min: 0, max: 100}),
                total_likes: isLarge
                    ? faker.number.int({min: 200, max: 5000})
                    : faker.number.int({min: 0, max: 50}),
                is_active: true,
                is_featured: isLarge && faker.datatype.boolean(0.3) // Large events have 30% chance to be featured
            });
        }

        const rawEvents = [...eventsData];
        await Event.bulkCreate(eventsData);
        const events = rawEvents;
        console.log(`✅ Created ${events.length} events`);

        // 5. Create Reviews
        console.log('Creating reviews...');
        const reviewsData = [];

        for (let i = 0; i < TOTAL_REVIEWS; i++) {
            const user = faker.helpers.arrayElement(users);
            const isDest = faker.datatype.boolean();
            const target = isDest ? faker.helpers.arrayElement(destinations) : faker.helpers.arrayElement(events);

            reviewsData.push({
                user_id: user.id,
                dest_id: isDest ? target.id : null,
                event_id: !isDest ? target.id : null,
                rating: faker.number.int({min: 3, max: 5}),
                comment: faker.lorem.sentence(),
                sentiment: faker.helpers.arrayElement(['positive', 'neutral']),
                images: [],
                helpful_count: faker.number.int({min: 0, max: 50}),
                is_verified_visit: faker.datatype.boolean()
            });
        }

        await Review.bulkCreate(reviewsData);
        console.log(`✅ Created ${reviewsData.length} reviews`);

        // 6. Create Trips
        console.log('Creating trips...');
        const tripsData = [];

        for (let i = 0; i < TOTAL_TRIPS; i++) {
            const user = faker.helpers.arrayElement(users);
            const startDate = faker.date.future();
            const endDate = new Date(startDate.getTime() + 24 * 60 * 60 * 1000); // 1 day
            const tripType = faker.helpers.arrayElement(['solo', 'couple', 'family', 'friends', 'group']);

            // Set participant count based on trip type
            let participantCount = 1;
            if (tripType === 'couple') participantCount = 2;
            else if (tripType === 'family') participantCount = faker.number.int({min: 3});
            else if (tripType === 'friends') participantCount = faker.number.int({min: 2});
            else if (tripType === 'group') participantCount = faker.number.int({min: 3});

            tripsData.push({
                id: faker.string.uuid(),
                user_id: user.id,
                trip_title: `Chuyến đi ${faker.location.city()}`,
                trip_description: faker.lorem.sentence(),
                trip_start_date: startDate,
                trip_end_date: endDate,
                trip_budget: faker.number.int({min: 1000000, max: 5000000}),
                trip_status: faker.helpers.arrayElement(['draft', 'active', 'completed']),
                trip_transport: 'motorbike',
                trip_type: tripType,
                participant_count: participantCount,
                visibility: 'public'
            });
        }

        const rawTrips = [...tripsData];
        await Trip.bulkCreate(tripsData);
        const trips = rawTrips;
        console.log(`✅ Created ${trips.length} trips`);

        // 7. Add Destinations to Trips
        console.log('Adding destinations to trips...');
        const tripDestinationsData = [];

        for (const trip of trips) {
            const tripDests = faker.helpers.arrayElements(destinations, 3);
            tripDests.forEach((dest, index) => {
                tripDestinationsData.push({
                    trip_id: trip.id,
                    dest_id: dest.id,
                    visit_order: index + 1,
                    estimated_time: 60,
                    notes: faker.lorem.sentence()
                });
            });
        }

        await TripDestination.bulkCreate(tripDestinationsData);
        console.log(`✅ Added ${tripDestinationsData.length} destinations to trips`);

        // 7b. Add Events to Trips
        console.log('Adding events to trips...');
        const tripEventsData = [];

        for (const trip of trips) {
            // 30% chance a trip has events
            if (faker.datatype.boolean(0.3)) {
                const tripEvts = faker.helpers.arrayElements(events, faker.number.int({min: 1, max: 2}));
                tripEvts.forEach((evt, index) => {
                    tripEventsData.push({
                        trip_id: trip.id,
                        event_id: evt.id,
                        visit_order: index + 1,
                        notes: faker.lorem.sentence()
                    });
                });
            }
        }

        if (tripEventsData.length > 0) {
            await TripEvent.bulkCreate(tripEventsData);
            console.log(`✅ Added ${tripEventsData.length} events to trips`);
        }

        // 8. Create Groups
        console.log('Creating groups...');
        const groupsData = [];

        for (let i = 0; i < 5; i++) {
            const creator = faker.helpers.arrayElement(users);
            groupsData.push({
                id: faker.string.uuid(),
                group_name: `Team ${faker.commerce.department()}`,
                group_description: faker.lorem.sentence(),
                created_by: creator.id,
                group_avatar: faker.image.avatar()
            });
        }

        const rawGroups = [...groupsData];
        await Group.bulkCreate(groupsData);
        const groups = rawGroups;

        // Add members to groups
        const groupMembersData = [];
        for (const group of groups) {
            // Add creator as admin
            groupMembersData.push({
                group_id: group.id,
                user_id: group.created_by,
                role: 'admin'
            });

            // Add random members
            const members = faker.helpers.arrayElements(users, 3);
            for (const member of members) {
                if (member.id !== group.created_by) {
                    groupMembersData.push({
                        group_id: group.id,
                        user_id: member.id,
                        role: 'member'
                    });
                }
            }
        }

        await GroupMember.bulkCreate(groupMembersData);
        console.log(`✅ Created ${groups.length} groups with members`);

        // 8b. Share Trips to Groups
        console.log('Sharing trips to groups...');
        const tripSharesData = [];

        for (const group of groups) {
            // Pick a random member of the group to share a trip
            const members = groupMembersData.filter(gm => gm.group_id === group.id);
            if (members.length > 0) {
                const sharer = faker.helpers.arrayElement(members);
                // Find a trip belonging to this user
                const userTrips = trips.filter(t => t.user_id === sharer.user_id);

                if (userTrips.length > 0) {
                    const tripToShare = faker.helpers.arrayElement(userTrips);
                    tripSharesData.push({
                        id: faker.string.uuid(),
                        trip_id: tripToShare.id,
                        group_id: group.id,
                        shared_by: sharer.user_id,
                        message: faker.lorem.sentence()
                    });
                }
            }
        }

        const rawTripShares = [...tripSharesData];
        await TripShare.bulkCreate(tripSharesData);
        const tripShares = rawTripShares;
        console.log(`✅ Created ${tripShares.length} trip shares`);

        // 8c. Create Group Comments
        console.log('Creating group comments...');
        const groupCommentsData = [];

        for (const share of tripShares) {
            // Get group members
            const members = groupMembersData.filter(gm => gm.group_id === share.group_id);

            // Create 0-5 comments per share
            const numComments = faker.number.int({min: 0, max: 5});
            for (let i = 0; i < numComments; i++) {
                const commenter = faker.helpers.arrayElement(members);
                groupCommentsData.push({
                    trip_share_id: share.id,
                    user_id: commenter.user_id,
                    content: faker.lorem.sentence()
                });
            }
        }

        await GroupComment.bulkCreate(groupCommentsData);
        console.log(`✅ Created ${groupCommentsData.length} group comments`);

        // 8d. Create User Feedback
        console.log('Creating user feedback...');
        const feedbackData = [];

        // 20% of users leave feedback
        const feedbackUsers = faker.helpers.arrayElements(users, Math.floor(users.length * 0.2));

        for (const user of feedbackUsers) {
            feedbackData.push({
                user_id: user.id,
                feedback_type: faker.helpers.arrayElement(['bug', 'feature_request', 'general']),
                subject: faker.lorem.sentence(),
                message: faker.lorem.paragraph(),
                status: 'pending'
            });
        }

        await UserFeedback.bulkCreate(feedbackData);
        console.log(`✅ Created ${feedbackData.length} user feedbacks`);

        // 9. Create Notifications
        console.log('Creating notifications...');
        const notificationsData = [];

        for (const user of users) {
            notificationsData.push({
                user_id: user.id,
                noti_type: 'system',
                noti_title: 'Chào mừng đến với Trekka!',
                noti_message: 'Hãy bắt đầu khám phá ngay hôm nay.',
                noti_status: 'read'
            });
        }

        await Notification.bulkCreate(notificationsData);
        console.log(`✅ Created ${notificationsData.length} notifications`);

        // 10. Create AI Requests & Responses
        console.log('Creating AI requests & responses...');
        const aiRequestsData = [];
        const aiResponsesData = [];

        for (let i = 0; i < 50; i++) {
            const user = faker.helpers.arrayElement(users);
            const type = faker.helpers.arrayElement(['trip_plan', 'suggestion', 'summary', 'chat']);

            const reqId = faker.string.uuid();
            aiRequestsData.push({
                id: reqId,
                user_id: user.id,
                request_type: type,
                payload: {
                    prompt: faker.lorem.sentence(),
                    preferences: user.usr_preferences,
                    budget: user.usr_budget
                },
                model_name: faker.helpers.arrayElement(['gpt-4o', 'gemini-pro']),
                req_created_at: faker.date.recent()
            });

            aiResponsesData.push({
                req_id: reqId,
                response_json: {
                    text: faker.lorem.paragraph(),
                    suggestions: faker.helpers.arrayElements(destinations.map(d => d.id), 3)
                },
                model_version: 'v1.0',
                latency_ms: faker.number.int({min: 500, max: 5000}),
                success: true,
                res_created_at: faker.date.recent()
            });
        }

        await AIRequest.bulkCreate(aiRequestsData);
        await AIResponse.bulkCreate(aiResponsesData);
        console.log(`✅ Created ${aiRequestsData.length} AI requests and responses`);

        // 11. Create Search Logs
        console.log('Creating search logs...');
        const searchLogsData = [];

        for (let i = 0; i < 100; i++) {
            const user = faker.helpers.arrayElement(users);
            const searchResults = faker.helpers.arrayElements(destinations, faker.number.int({min: 0, max: 10}));
            const resultIds = searchResults.map(d => d.id);
            const clickedId = resultIds.length > 0 && faker.datatype.boolean()
                ? faker.helpers.arrayElement(resultIds)
                : null;

            const searchCity = faker.helpers.arrayElement(CITIES);

            searchLogsData.push({
                user_id: user.id,
                query: faker.lorem.words(3),
                context: {
                    lat: searchCity.lat,
                    lng: searchCity.lng,
                    device: 'mobile'
                },
                filters: {
                    category: faker.helpers.arrayElement(categories).id,
                    price_range: 'medium'
                },
                results: resultIds,
                result_count: resultIds.length,
                clicked_result_id: clickedId,
                clicked_position: clickedId ? resultIds.indexOf(clickedId) : null
            });
        }

        await SearchLog.bulkCreate(searchLogsData);
        console.log(`✅ Created ${searchLogsData.length} search logs`);

        console.log('✨ Seed completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seed failed:', error);
        process.exit(1);
    }
};

seed();


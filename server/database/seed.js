import { faker } from '@faker-js/faker';
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
const TOTAL_DESTINATIONS = 160;
const TOTAL_EVENTS = 40;
const TOTAL_REVIEWS = 300;
const TOTAL_TRIPS = 30;

// Hanoi Coordinates
const HANOI_LAT = 21.0285;
const HANOI_LNG = 105.8542;
const RADIUS = 0.1; // ~10km

// Helper to generate random location around Hanoi
const randomLocation = () => {
    const lat = HANOI_LAT + (Math.random() - 0.5) * RADIUS;
    const lng = HANOI_LNG + (Math.random() - 0.5) * RADIUS;
    return { lat, lng };
};

// Helper to generate geometry point
const point = (lat, lng) => {
    return { type: 'Point', coordinates: [lng, lat] };
};

const seed = async () => {
    try {
        console.log('🌱 Starting seed...');
        await sequelize.authenticate();

        // Recreate database schema
        await sequelize.sync({ force: true });
        console.log('✅ Database synced');

        // 1. Create Categories
        console.log('Creating categories...');
        const categoriesData = [
            { name: 'Cafe', icon: 'coffee', travel_style_id: 'food_drink', context_tags: ['solo', 'couple', 'friends'] },
            { name: 'Museum', icon: 'landmark', travel_style_id: 'culture_history', context_tags: ['family', 'solo'] },
            { name: 'Park', icon: 'tree', travel_style_id: 'nature', context_tags: ['family', 'friends', 'couple'] },
            { name: 'Restaurant', icon: 'utensils', travel_style_id: 'food_drink', context_tags: ['family', 'friends', 'couple'] },
            { name: 'Shopping Mall', icon: 'shopping-bag', travel_style_id: 'shopping_entertainment', context_tags: ['friends', 'family'] },
            { name: 'Historical Site', icon: 'monument', travel_style_id: 'culture_history', context_tags: ['solo', 'family'] },
            { name: 'Bar/Pub', icon: 'glass-cheers', travel_style_id: 'shopping_entertainment', context_tags: ['friends', 'couple'] },
            { name: 'Art Gallery', icon: 'palette', travel_style_id: 'culture_history', context_tags: ['solo', 'couple'] },
            { name: 'Street Food', icon: 'hamburger', travel_style_id: 'local_life', context_tags: ['friends', 'solo'] },
            { name: 'Lake', icon: 'water', travel_style_id: 'nature', context_tags: ['couple', 'solo'] }
        ].map(c => ({ ...c, id: faker.string.uuid() }));

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
                usr_age: faker.number.int({ min: 18, max: 60 }),
                usr_job: 'student', // Simplified
                usr_preferences: faker.helpers.arrayElements(['nature', 'food_drink', 'culture_history', 'adventure'], 2),
                usr_budget: faker.number.int({ min: 1000000, max: 20000000 }),
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
            const loc = randomLocation();
            const category = faker.helpers.arrayElement(categories);
            const isLarge = faker.datatype.boolean(); // 50% chance of being large/popular

            destinationsData.push({
                id: faker.string.uuid(),
                categoryId: category.id,
                name: faker.company.name() + ' ' + category.name,
                description: faker.lorem.paragraph(),
                address: faker.location.streetAddress() + ', Hà Nội',
                lat: loc.lat,
                lng: loc.lng,
                geom: point(loc.lat, loc.lng),
                avg_cost: isLarge
                    ? faker.number.int({ min: 200000, max: 2000000 })
                    : faker.number.int({ min: 20000, max: 150000 }),
                rating: faker.number.float({ min: 3.5, max: 5.0, precision: 0.1 }),
                total_reviews: isLarge
                    ? faker.number.int({ min: 100, max: 1000 })
                    : faker.number.int({ min: 0, max: 50 }),
                total_likes: isLarge
                    ? faker.number.int({ min: 500, max: 5000 })
                    : faker.number.int({ min: 0, max: 100 }),
                total_checkins: isLarge
                    ? faker.number.int({ min: 1000, max: 10000 })
                    : faker.number.int({ min: 0, max: 200 }),
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
                images: [faker.image.urlLoremFlickr({ category: 'city' }), faker.image.urlLoremFlickr({ category: 'food' })],
                ai_summary: faker.lorem.sentence(),
                best_time_to_visit: '16:00-18:00',
                recommended_duration: faker.number.int({ min: 30, max: 180 }),
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
            const loc = randomLocation();
            const startDate = faker.date.future();
            const endDate = new Date(startDate.getTime() + 2 * 60 * 60 * 1000); // 2 hours later
            const isLarge = faker.datatype.boolean();

            eventsData.push({
                id: faker.string.uuid(),
                event_name: faker.company.catchPhrase(),
                event_description: faker.lorem.paragraph(),
                event_location: faker.location.streetAddress() + ', Hà Nội',
                lat: loc.lat,
                lng: loc.lng,
                geom: point(loc.lat, loc.lng),
                event_start: startDate,
                event_end: endDate,
                event_ticket_price: isLarge
                    ? faker.number.int({ min: 500000, max: 5000000 })
                    : faker.number.int({ min: 0, max: 200000 }),
                event_type: faker.helpers.arrayElement(['concert', 'exhibition', 'workshop', 'festival']),
                event_organizer: faker.company.name(),
                event_capacity: isLarge
                    ? faker.number.int({ min: 1000, max: 20000 })
                    : faker.number.int({ min: 20, max: 200 }),
                event_tags: faker.helpers.arrayElements(['music', 'art', 'education', 'food'], 2),
                images: [faker.image.urlLoremFlickr({ category: 'nightlife' })],
                total_attendees: isLarge
                    ? faker.number.int({ min: 500, max: 10000 })
                    : faker.number.int({ min: 0, max: 100 }),
                total_likes: isLarge
                    ? faker.number.int({ min: 200, max: 5000 })
                    : faker.number.int({ min: 0, max: 50 }),
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
                rating: faker.number.int({ min: 3, max: 5 }),
                comment: faker.lorem.sentence(),
                sentiment: faker.helpers.arrayElement(['positive', 'neutral']),
                images: [],
                helpful_count: faker.number.int({ min: 0, max: 50 }),
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

            tripsData.push({
                id: faker.string.uuid(),
                user_id: user.id,
                trip_title: `Chuyến đi ${faker.location.city()}`,
                trip_description: faker.lorem.sentence(),
                trip_start_date: startDate,
                trip_end_date: endDate,
                trip_budget: faker.number.int({ min: 1000000, max: 5000000 }),
                trip_status: faker.helpers.arrayElement(['draft', 'active', 'completed']),
                trip_transport: 'motorbike',
                trip_type: 'friends',
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
                const tripEvts = faker.helpers.arrayElements(events, faker.number.int({ min: 1, max: 2 }));
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
            const numComments = faker.number.int({ min: 0, max: 5 });
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
                latency_ms: faker.number.int({ min: 500, max: 5000 }),
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
            const searchResults = faker.helpers.arrayElements(destinations, faker.number.int({ min: 0, max: 10 }));
            const resultIds = searchResults.map(d => d.id);
            const clickedId = resultIds.length > 0 && faker.datatype.boolean()
                ? faker.helpers.arrayElement(resultIds)
                : null;

            searchLogsData.push({
                user_id: user.id,
                query: faker.lorem.words(3),
                context: {
                    lat: HANOI_LAT,
                    lng: HANOI_LNG,
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


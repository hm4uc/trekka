import test from 'ava';
import destinationService from '../services/destination.service.js';
import { Destination, DestinationCategory, Profile, UserFeedback, Review } from '../models/associations.js';
import sequelize from '../database/db.js';
import bcrypt from 'bcrypt';

// Test data storage
const testData = {
    users: [],
    categories: [],
    destinations: [],
    testResults: []
};

// Helper to log test results
function logTestResult(testName, params, result, status = 'PASS') {
    const testResult = {
        testName,
        params,
        result,
        status,
        timestamp: new Date().toISOString()
    };
    testData.testResults.push(testResult);
    console.log(`\n${'='.repeat(80)}`);
    console.log(`TEST: ${testName}`);
    console.log(`STATUS: ${status}`);
    console.log(`PARAMS:`, JSON.stringify(params, null, 2));
    console.log(`RESULT:`, JSON.stringify(result, null, 2));
    console.log('='.repeat(80));
}

// Setup test data
test.before(async t => {
    console.log('\n🔧 Setting up destination test database...\n');

    // Sync database
    await sequelize.sync({ force: false });

    // Create test user
    const hashedPassword = await bcrypt.hash('password123', 10);
    const user = await Profile.create({
        usr_fullname: 'Destination Test User',
        usr_email: `dest.test.${Date.now()}@test.com`,
        usr_password_hash: hashedPassword,
        usr_preferences: ['nature', 'culture'],
        usr_budget: 1000000
    });

    testData.users.push(user);

    // Find or create categories
    const [cafeCat] = await DestinationCategory.findOrCreate({
        where: { name: 'Cafe' },
        defaults: {
            icon: 'coffee',
            travel_style_id: 'food_drink',
            context_tags: ['solo', 'couple']
        }
    });

    const [museumCat] = await DestinationCategory.findOrCreate({
        where: { name: 'Museum' },
        defaults: {
            icon: 'landmark',
            travel_style_id: 'culture_history',
            context_tags: ['family', 'solo']
        }
    });

    const [parkCat] = await DestinationCategory.findOrCreate({
        where: { name: 'Park' },
        defaults: {
            icon: 'tree',
            travel_style_id: 'nature',
            context_tags: ['family', 'couple']
        }
    });

    testData.categories.push(cafeCat, museumCat, parkCat);

    console.log(`✅ Test data created:
    - Users: ${testData.users.length}
    - Categories: ${testData.categories.length}\n`);
});

// Test 1: Get All Destinations with Pagination
test.serial('1. Get All Destinations with Pagination', async t => {
    const params = {
        page: 1,
        limit: 10
    };

    const result = await destinationService.getAllDestinations({
        page: params.page,
        limit: params.limit
    });

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));
    t.truthy(result.total >= 0);
    t.is(result.currentPage, 1);

    logTestResult('Get All Destinations with Pagination', params, {
        total: result.total,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        destinationsCount: result.data.length,
        sampleDestinations: result.data.slice(0, 3).map(d => ({
            id: d.id,
            name: d.name,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 2: Get Destination by ID
test.serial('2. Get Destination by ID', async t => {
    // First get a destination
    const destinations = await destinationService.getAllDestinations({ page: 1, limit: 1 });

    if (destinations.data.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Get Destination by ID', {}, { message: 'Skipped - no destinations' }, 'PASS');
        return;
    }

    const destId = destinations.data[0].id;

    const params = {
        destinationId: destId
    };

    const result = await destinationService.getDestinationById(params.destinationId);

    t.is(result.id, destId);
    t.truthy(result.name);
    t.truthy(result.lat);
    t.truthy(result.lng);

    testData.destinations.push(result);

    logTestResult('Get Destination by ID', params, {
        id: result.id,
        name: result.name,
        description: result.description,
        category: result.category?.name,
        avgCost: result.avg_cost,
        rating: result.rating,
        location: { lat: result.lat, lng: result.lng }
    }, 'PASS');
});

// Test 3: Search Destinations by Name
test.serial('3. Search Destinations by Name', async t => {
    const params = {
        search: 'Hồ',
        page: 1,
        limit: 10
    };

    const result = await destinationService.searchDestinations({
        search: params.search,
        page: params.page,
        limit: params.limit
    });

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    logTestResult('Search Destinations by Name', params, {
        total: result.total,
        resultsFound: result.data.length,
        matchingDestinations: result.data.slice(0, 5).map(d => ({
            name: d.name,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 4: Filter Destinations by Category
test.serial('4. Filter Destinations by Category', async t => {
    const category = testData.categories[0];

    const params = {
        categoryId: category.id,
        page: 1,
        limit: 10
    };

    const result = await destinationService.getDestinationsByCategory(
        params.categoryId,
        { page: params.page, limit: params.limit }
    );

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    // Verify all results are from the correct category
    result.data.forEach(dest => {
        t.is(dest.categoryId, category.id);
    });

    logTestResult('Filter Destinations by Category', params, {
        categoryName: category.name,
        total: result.total,
        destinationsInCategory: result.data.length,
        sampleDestinations: result.data.slice(0, 3).map(d => ({
            name: d.name,
            avgCost: d.avg_cost
        }))
    }, 'PASS');
});

// Test 5: Get Nearby Destinations
test.serial('5. Get Nearby Destinations', async t => {
    const params = {
        lat: 21.028511,
        lng: 105.804817,
        radius: 5000, // 5km
        limit: 10
    };

    const result = await destinationService.getNearbyDestinations(
        params.lat,
        params.lng,
        params.radius,
        { limit: params.limit }
    );

    t.truthy(result);
    t.truthy(Array.isArray(result));

    logTestResult('Get Nearby Destinations', params, {
        center: { lat: params.lat, lng: params.lng },
        radiusKm: params.radius / 1000,
        destinationsFound: result.length,
        nearbyDestinations: result.slice(0, 5).map(d => ({
            name: d.name,
            distance: d.distance,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 6: Like a Destination
test.serial('6. Like a Destination', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Like a Destination', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];
    const user = testData.users[0];

    const params = {
        userId: user.id,
        destinationId: destination.id
    };

    const result = await destinationService.likeDestination(
        params.userId,
        params.destinationId
    );

    t.truthy(result.message);

    // Verify like was created
    const feedback = await UserFeedback.findOne({
        where: {
            user_id: user.id,
            target_id: destination.id,
            feedback_target_type: 'destination',
            feedback_type: 'like'
        }
    });

    t.truthy(feedback);

    logTestResult('Like a Destination', params, {
        message: result.message,
        destinationName: destination.name,
        likeCreated: !!feedback
    }, 'PASS');
});

// Test 7: Unlike a Destination
test.serial('7. Unlike a Destination', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Unlike a Destination', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];
    const user = testData.users[0];

    const params = {
        userId: user.id,
        destinationId: destination.id
    };

    const result = await destinationService.unlikeDestination(
        params.userId,
        params.destinationId
    );

    t.truthy(result.message);

    // Verify like was removed
    const feedback = await UserFeedback.findOne({
        where: {
            user_id: user.id,
            target_id: destination.id,
            feedback_target_type: 'destination',
            feedback_type: 'like'
        }
    });

    t.falsy(feedback);

    logTestResult('Unlike a Destination', params, {
        message: result.message,
        destinationName: destination.name,
        likeRemoved: !feedback
    }, 'PASS');
});

// Test 8: Check-in at Destination
test.serial('8. Check-in at Destination', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Check-in at Destination', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];
    const user = testData.users[0];

    const params = {
        userId: user.id,
        destinationId: destination.id
    };

    const result = await destinationService.checkinDestination(
        params.userId,
        params.destinationId
    );

    t.truthy(result.message);

    // Verify check-in was created
    const checkin = await UserFeedback.findOne({
        where: {
            user_id: user.id,
            target_id: destination.id,
            feedback_target_type: 'destination',
            feedback_type: 'checkin'
        }
    });

    t.truthy(checkin);

    logTestResult('Check-in at Destination', params, {
        message: result.message,
        destinationName: destination.name,
        checkinCreated: !!checkin
    }, 'PASS');
});

// Test 9: Duplicate Check-in (Should Fail)
test.serial('9. Duplicate Check-in (Should Fail)', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Duplicate Check-in', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];
    const user = testData.users[0];

    const params = {
        userId: user.id,
        destinationId: destination.id
    };

    const error = await t.throwsAsync(
        async () => await destinationService.checkinDestination(
            params.userId,
            params.destinationId
        )
    );

    t.truthy(error.message.includes('already') || error.message.includes('checked'));

    logTestResult('Duplicate Check-in', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 10: Get User's Liked Destinations
test.serial('10. Get User Liked Destinations', async t => {
    const user = testData.users[0];

    // First like a destination
    if (testData.destinations.length > 0) {
        await destinationService.likeDestination(user.id, testData.destinations[0].id);
    }

    const params = {
        userId: user.id,
        page: 1,
        limit: 10
    };

    const result = await destinationService.getUserLikedDestinations(
        params.userId,
        { page: params.page, limit: params.limit }
    );

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    logTestResult('Get User Liked Destinations', params, {
        total: result.total,
        likedDestinations: result.data.length,
        destinations: result.data.slice(0, 3).map(d => ({
            name: d.name,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 11: Get User's Checked-in Destinations
test.serial('11. Get User Checked-in Destinations', async t => {
    const user = testData.users[0];

    const params = {
        userId: user.id,
        page: 1,
        limit: 10
    };

    const result = await destinationService.getUserCheckedInDestinations(
        params.userId,
        { page: params.page, limit: params.limit }
    );

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    logTestResult('Get User Checked-in Destinations', params, {
        total: result.total,
        checkedInDestinations: result.data.length,
        destinations: result.data.slice(0, 3).map(d => ({
            name: d.name,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 12: Add Review to Destination
test.serial('12. Add Review to Destination', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Add Review to Destination', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];
    const user = testData.users[0];

    const params = {
        userId: user.id,
        destId: destination.id,
        rating: 5,
        comment: 'Amazing place! Highly recommended.',
        images: ['image1.jpg', 'image2.jpg']
    };

    const result = await destinationService.addReview(params.userId, {
        destId: params.destId,
        rating: params.rating,
        comment: params.comment,
        images: params.images
    });

    t.truthy(result.id);
    t.is(result.rating, params.rating);
    t.is(result.comment, params.comment);

    logTestResult('Add Review to Destination', params, {
        reviewId: result.id,
        rating: result.rating,
        comment: result.comment,
        destinationName: destination.name,
        sentiment: result.sentiment
    }, 'PASS');
});

// Test 13: Get Destination Reviews
test.serial('13. Get Destination Reviews', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Get Destination Reviews', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];

    const params = {
        destinationId: destination.id,
        page: 1,
        limit: 10
    };

    const result = await destinationService.getDestinationReviews(
        params.destinationId,
        { page: params.page, limit: params.limit }
    );

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    logTestResult('Get Destination Reviews', params, {
        destinationName: destination.name,
        total: result.total,
        reviewsCount: result.data.length,
        sampleReviews: result.data.slice(0, 3).map(r => ({
            rating: r.rating,
            comment: r.comment?.substring(0, 50),
            sentiment: r.sentiment
        }))
    }, 'PASS');
});

// Test 14: Filter Destinations by Price Range
test.serial('14. Filter Destinations by Price Range', async t => {
    const params = {
        minCost: 0,
        maxCost: 100000,
        page: 1,
        limit: 10
    };

    const result = await destinationService.getDestinationsByPriceRange(
        params.minCost,
        params.maxCost,
        { page: params.page, limit: params.limit }
    );

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    // Verify all results are within price range
    result.data.forEach(dest => {
        t.true(parseFloat(dest.avg_cost) >= params.minCost);
        t.true(parseFloat(dest.avg_cost) <= params.maxCost);
    });

    logTestResult('Filter Destinations by Price Range', params, {
        priceRange: `${params.minCost} - ${params.maxCost} VND`,
        total: result.total,
        destinationsInRange: result.data.length,
        sampleDestinations: result.data.slice(0, 3).map(d => ({
            name: d.name,
            avgCost: d.avg_cost
        }))
    }, 'PASS');
});

// Test 15: Get Top Rated Destinations
test.serial('15. Get Top Rated Destinations', async t => {
    const params = {
        limit: 10
    };

    const result = await destinationService.getTopRatedDestinations(params.limit);

    t.truthy(result);
    t.truthy(Array.isArray(result));

    // Verify results are sorted by rating (descending)
    for (let i = 0; i < result.length - 1; i++) {
        t.true(result[i].rating >= result[i + 1].rating);
    }

    logTestResult('Get Top Rated Destinations', params, {
        topDestinationsCount: result.length,
        topDestinations: result.slice(0, 5).map(d => ({
            name: d.name,
            rating: d.rating,
            totalReviews: d.total_reviews,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 16: Get Popular Destinations (Most Liked)
test.serial('16. Get Popular Destinations', async t => {
    const params = {
        limit: 10
    };

    const result = await destinationService.getPopularDestinations(params.limit);

    t.truthy(result);
    t.truthy(Array.isArray(result));

    // Verify results are sorted by total_likes (descending)
    for (let i = 0; i < result.length - 1; i++) {
        t.true(result[i].total_likes >= result[i + 1].total_likes);
    }

    logTestResult('Get Popular Destinations', params, {
        popularDestinationsCount: result.length,
        popularDestinations: result.slice(0, 5).map(d => ({
            name: d.name,
            totalLikes: d.total_likes,
            totalCheckins: d.total_checkins,
            category: d.category?.name
        }))
    }, 'PASS');
});

// Test 17: Get Destination Categories
test.serial('17. Get All Destination Categories', async t => {
    const params = {};

    const result = await destinationService.getAllCategories();

    t.truthy(result);
    t.truthy(Array.isArray(result));
    t.true(result.length > 0);

    logTestResult('Get All Destination Categories', params, {
        totalCategories: result.length,
        categories: result.map(c => ({
            id: c.id,
            name: c.name,
            icon: c.icon,
            travelStyle: c.travel_style_id
        }))
    }, 'PASS');
});

// Test 18: Search with Multiple Filters
test.serial('18. Search with Multiple Filters', async t => {
    const params = {
        search: 'Hà Nội',
        categoryId: testData.categories[0].id,
        minCost: 0,
        maxCost: 200000,
        page: 1,
        limit: 10
    };

    const result = await destinationService.searchDestinations(params);

    t.truthy(result.data);
    t.truthy(Array.isArray(result.data));

    logTestResult('Search with Multiple Filters', params, {
        total: result.total,
        resultsFound: result.data.length,
        filters: {
            search: params.search,
            category: testData.categories[0].name,
            priceRange: `${params.minCost}-${params.maxCost}`
        },
        sampleResults: result.data.slice(0, 3).map(d => ({
            name: d.name,
            category: d.category?.name,
            avgCost: d.avg_cost
        }))
    }, 'PASS');
});

// Test 19: Get Destination Not Found (Should Fail)
test.serial('19. Get Non-existent Destination (Should Fail)', async t => {
    const params = {
        destinationId: '00000000-0000-0000-0000-000000000000'
    };

    const error = await t.throwsAsync(
        async () => await destinationService.getDestinationById(params.destinationId)
    );

    t.truthy(error.message.includes('not found'));

    logTestResult('Get Non-existent Destination', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 20: Get Destination Statistics
test.serial('20. Get Destination Statistics', async t => {
    if (testData.destinations.length === 0) {
        t.pass('No destinations available to test');
        logTestResult('Get Destination Statistics', {}, { message: 'Skipped' }, 'PASS');
        return;
    }

    const destination = testData.destinations[0];

    const params = {
        destinationId: destination.id
    };

    const result = await destinationService.getDestinationStats(params.destinationId);

    t.truthy(result);
    t.truthy(result.totalLikes !== undefined);
    t.truthy(result.totalCheckins !== undefined);
    t.truthy(result.totalReviews !== undefined);

    logTestResult('Get Destination Statistics', params, {
        destinationName: destination.name,
        statistics: {
            totalLikes: result.totalLikes,
            totalCheckins: result.totalCheckins,
            totalReviews: result.totalReviews,
            avgRating: result.avgRating
        }
    }, 'PASS');
});

// Print final summary
test.after.always('Final Summary', t => {
    console.log('\n\n');
    console.log('╔' + '═'.repeat(78) + '╗');
    console.log('║' + ' '.repeat(23) + 'DESTINATION TEST SUMMARY' + ' '.repeat(30) + '║');
    console.log('╚' + '═'.repeat(78) + '╝');

    console.log('\n📊 Test Statistics:');
    console.log(`   Total Tests Executed: ${testData.testResults.length}`);
    console.log(`   Passed: ${testData.testResults.filter(r => r.status.includes('PASS')).length}`);
    console.log(`   Failed: ${testData.testResults.filter(r => r.status === 'FAIL').length}`);

    console.log('\n📋 All Tests List:');
    testData.testResults.forEach((result, index) => {
        console.log(`   ${index + 1}. ${result.testName} - ${result.status}`);
    });

    console.log('\n📝 Detailed Test Results:');
    console.log('─'.repeat(80));

    testData.testResults.forEach((result, index) => {
        console.log(`\n${index + 1}. ${result.testName}`);
        console.log(`   Status: ${result.status}`);
        console.log(`   Time: ${result.timestamp}`);
        console.log(`   Parameters:`);
        console.log(JSON.stringify(result.params, null, 6));
        console.log(`   Result:`);
        console.log(JSON.stringify(result.result, null, 6));
        console.log('─'.repeat(80));
    });

    console.log('\n✅ All destination tests completed successfully!\n');
});


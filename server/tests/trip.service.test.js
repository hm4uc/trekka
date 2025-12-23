import test from 'ava';
import bcrypt from 'bcrypt';
import tripService from '../services/trip.service.js';
import { Trip, TripDestination, TripEvent, Destination, Event, Profile, DestinationCategory } from '../models/associations.js';
import sequelize from '../database/db.js';

// Test data storage
const testData = {
    users: [],
    categories: [],
    destinations: [],
    events: [],
    trips: [],
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
    console.log('\n🔧 Setting up test database...\n');

    // Sync database
    await sequelize.sync({ force: false });

    // Hash password for test users
    const hashedPassword = await bcrypt.hash('password123', 10);

    // Create test users
    const user1 = await Profile.create({
        usr_fullname: 'Test User 1',
        usr_email: `test1_${Date.now()}@test.com`,
        usr_password_hash: hashedPassword,
        usr_preferences: ['nature', 'culture'],
        usr_budget: 1000000
    });

    const user2 = await Profile.create({
        usr_fullname: 'Test User 2',
        usr_email: `test2_${Date.now()}@test.com`,
        usr_password_hash: hashedPassword,
        usr_preferences: ['food', 'shopping'],
        usr_budget: 500000
    });

    testData.users.push(user1, user2);

    // Find or create test categories
    const [cat1] = await DestinationCategory.findOrCreate({
        where: { name: 'Museum' },
        defaults: {
            icon: 'landmark',
            travel_style_id: 'culture_history',
            context_tags: ['family', 'solo']
        }
    });

    const [cat2] = await DestinationCategory.findOrCreate({
        where: { name: 'Cafe' },
        defaults: {
            icon: 'coffee',
            travel_style_id: 'food_drink',
            context_tags: ['solo', 'couple', 'friends']
        }
    });

    testData.categories.push(cat1, cat2);

    // Create test destinations
    const dest1 = await Destination.create({
        name: 'Test Museum',
        description: 'A beautiful museum',
        categoryId: cat1.id,
        lat: 21.028511,
        lng: 105.804817,
        address: 'Hanoi, Vietnam',
        avg_cost: 50000,
        recommended_duration: 120,
        is_active: true
    });

    const dest2 = await Destination.create({
        name: 'Test Coffee Shop',
        description: 'Cozy coffee place',
        categoryId: cat2.id,
        lat: 21.027764,
        lng: 105.834160,
        address: 'Hanoi, Vietnam',
        avg_cost: 80000,
        recommended_duration: 60,
        is_active: true
    });

    testData.destinations.push(dest1, dest2);

    // Create test events
    const event1 = await Event.create({
        event_name: 'Art Exhibition',
        event_description: 'Contemporary art show',
        event_start: new Date('2025-12-25 10:00:00'),
        event_end: new Date('2025-12-25 18:00:00'),
        event_ticket_price: 100000,
        lat: 21.028511,
        lng: 105.804817,
        is_active: true
    });

    testData.events.push(event1);

    console.log(`✅ Test data created:
    - Users: ${testData.users.length}
    - Categories: ${testData.categories.length}
    - Destinations: ${testData.destinations.length}
    - Events: ${testData.events.length}\n`);
});

// Test 1: Create Trip - Solo
test.serial('1. Create Solo Trip', async t => {
    const params = {
        userId: testData.users[0].id,
        data: {
            trip_title: 'Solo Adventure in Hanoi',
            trip_description: 'Exploring Hanoi alone',
            trip_start_date: '2025-12-25',
            trip_end_date: '2025-12-25',
            trip_budget: 500000,
            trip_type: 'solo',
            participant_count: 1,
            trip_transport: 'walking',
            visibility: 'private'
        }
    };

    const trip = await tripService.createTrip(params.userId, params.data);
    testData.trips.push(trip);

    t.truthy(trip.id);
    t.is(trip.trip_type, 'solo');
    t.is(trip.participant_count, 1);

    logTestResult('Create Solo Trip', params, {
        tripId: trip.id,
        tripTitle: trip.trip_title,
        tripType: trip.trip_type,
        participantCount: trip.participant_count
    }, 'PASS');
});

// Test 2: Create Trip - Couple
test.serial('2. Create Couple Trip', async t => {
    const params = {
        userId: testData.users[0].id,
        data: {
            trip_title: 'Romantic Getaway',
            trip_description: 'Weekend with partner',
            trip_start_date: '2025-12-28',
            trip_end_date: '2025-12-29',
            trip_budget: 1000000,
            trip_type: 'couple',
            participant_count: 2
        }
    };

    const trip = await tripService.createTrip(params.userId, params.data);
    testData.trips.push(trip);

    t.is(trip.trip_type, 'couple');
    t.is(trip.participant_count, 2);

    logTestResult('Create Couple Trip', params, {
        tripId: trip.id,
        tripTitle: trip.trip_title,
        tripType: trip.trip_type,
        participantCount: trip.participant_count
    }, 'PASS');
});

// Test 3: Create Trip - Group
test.serial('3. Create Group Trip', async t => {
    const params = {
        userId: testData.users[1].id,
        data: {
            trip_title: 'Friends Reunion Trip',
            trip_description: 'Trip with old friends',
            trip_start_date: '2026-01-05',
            trip_end_date: '2026-01-07',
            trip_budget: 2000000,
            trip_type: 'group',
            participant_count: 5
        }
    };

    const trip = await tripService.createTrip(params.userId, params.data);
    testData.trips.push(trip);

    t.is(trip.trip_type, 'group');
    t.is(trip.participant_count, 5);

    logTestResult('Create Group Trip', params, {
        tripId: trip.id,
        tripTitle: trip.trip_title,
        tripType: trip.trip_type,
        participantCount: trip.participant_count
    }, 'PASS');
});

// Test 4: Validate Trip Type - Solo with wrong participant count
test.serial('4. Validate Solo Trip - Wrong Participant Count (Should Fail)', async t => {
    const params = {
        userId: testData.users[0].id,
        data: {
            trip_title: 'Invalid Solo Trip',
            trip_start_date: '2025-12-30',
            trip_end_date: '2025-12-30',
            trip_type: 'solo',
            participant_count: 2
        }
    };

    const error = await t.throwsAsync(
        async () => await tripService.createTrip(params.userId, params.data)
    );

    t.truthy(error.message.includes('participant_count'));

    logTestResult('Validate Solo Trip - Wrong Participant Count', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 5: Validate Trip Type - Couple with wrong participant count
test.serial('5. Validate Couple Trip - Wrong Participant Count (Should Fail)', async t => {
    const params = {
        userId: testData.users[0].id,
        data: {
            trip_title: 'Invalid Couple Trip',
            trip_start_date: '2025-12-30',
            trip_end_date: '2025-12-30',
            trip_type: 'couple',
            participant_count: 3
        }
    };

    const error = await t.throwsAsync(
        async () => await tripService.createTrip(params.userId, params.data)
    );

    t.truthy(error.message.includes('participant_count'));

    logTestResult('Validate Couple Trip - Wrong Participant Count', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 6: Add Destination to Trip
test.serial('6. Add Destination to Trip', async t => {
    const trip = testData.trips[0];
    const destination = testData.destinations[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        destId: destination.id,
        visitOrder: 1,
        estimatedTime: 120,
        visitDate: '2025-12-25',
        startTime: '09:00:00',
        notes: 'Morning visit'
    };

    const tripDest = await tripService.addDestinationToTrip(
        params.tripId,
        params.userId,
        {
            destId: params.destId,
            visitOrder: params.visitOrder,
            estimatedTime: params.estimatedTime,
            visitDate: params.visitDate,
            startTime: params.startTime,
            notes: params.notes
        }
    );

    t.truthy(tripDest.id);
    t.is(tripDest.dest_id, destination.id);

    logTestResult('Add Destination to Trip', params, {
        tripDestinationId: tripDest.id,
        destinationName: destination.name,
        visitOrder: tripDest.visit_order,
        estimatedTime: tripDest.estimated_time
    }, 'PASS');
});

// Test 7: Add Multiple Destinations to Trip
test.serial('7. Add Second Destination to Trip', async t => {
    const trip = testData.trips[0];
    const destination = testData.destinations[1];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        destId: destination.id,
        visitOrder: 2,
        estimatedTime: 60,
        visitDate: '2025-12-25',
        startTime: '14:00:00',
        notes: 'Afternoon coffee'
    };

    const tripDest = await tripService.addDestinationToTrip(
        params.tripId,
        params.userId,
        {
            destId: params.destId,
            visitOrder: params.visitOrder,
            estimatedTime: params.estimatedTime,
            visitDate: params.visitDate,
            startTime: params.startTime,
            notes: params.notes
        }
    );

    t.is(tripDest.visit_order, 2);

    logTestResult('Add Second Destination to Trip', params, {
        tripDestinationId: tripDest.id,
        destinationName: destination.name,
        visitOrder: tripDest.visit_order
    }, 'PASS');
});

// Test 8: Add Event to Trip
test.serial('8. Add Event to Trip', async t => {
    const trip = testData.trips[0];
    const event = testData.events[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        eventId: event.id,
        visitOrder: 3,
        notes: 'Evening event'
    };

    const tripEvent = await tripService.addEventToTrip(
        params.tripId,
        params.userId,
        {
            eventId: params.eventId,
            visitOrder: params.visitOrder,
            notes: params.notes
        }
    );

    t.truthy(tripEvent.id);
    t.is(tripEvent.event_id, event.id);

    logTestResult('Add Event to Trip', params, {
        tripEventId: tripEvent.id,
        eventName: event.event_name,
        visitOrder: tripEvent.visit_order
    }, 'PASS');
});

// Test 9: Get Trip by ID with all items
test.serial('9. Get Trip Details with Destinations and Events', async t => {
    const trip = testData.trips[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id
    };

    const result = await tripService.getTripById(params.tripId, params.userId);

    t.is(result.id, trip.id);
    t.truthy(result.tripDestinations);
    t.truthy(result.tripEvents);
    t.true(result.tripDestinations.length >= 2);
    t.true(result.tripEvents.length >= 1);

    logTestResult('Get Trip Details', params, {
        tripId: result.id,
        tripTitle: result.trip_title,
        totalDestinations: result.tripDestinations.length,
        totalEvents: result.tripEvents.length,
        destinations: result.tripDestinations.map(td => ({
            name: td.destination?.name,
            visitOrder: td.visit_order,
            estimatedTime: td.estimated_time
        })),
        events: result.tripEvents.map(te => ({
            name: te.event?.event_name,
            visitOrder: te.visit_order
        }))
    }, 'PASS');
});

// Test 10: Get User Trips with Pagination
test.serial('10. Get User Trips with Pagination', async t => {
    const params = {
        userId: testData.users[0].id,
        page: 1,
        limit: 10,
        status: undefined
    };

    const result = await tripService.getUserTrips(params.userId, {
        page: params.page,
        limit: params.limit
    });

    t.truthy(result.data);
    t.true(result.data.length > 0);
    t.is(result.currentPage, 1);

    logTestResult('Get User Trips with Pagination', params, {
        total: result.total,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        trips: result.data.map(trip => ({
            id: trip.id,
            title: trip.trip_title,
            status: trip.trip_status,
            destinationsCount: trip.tripDestinations?.length || 0,
            eventsCount: trip.tripEvents?.length || 0
        }))
    }, 'PASS');
});

// Test 11: Get User Trips by Status
test.serial('11. Get User Trips by Status (draft)', async t => {
    const params = {
        userId: testData.users[0].id,
        page: 1,
        limit: 10,
        status: 'draft'
    };

    const result = await tripService.getUserTrips(params.userId, {
        page: params.page,
        limit: params.limit,
        status: params.status
    });

    t.truthy(result.data);
    result.data.forEach(trip => {
        t.is(trip.trip_status, 'draft');
    });

    logTestResult('Get User Trips by Status', params, {
        total: result.total,
        status: params.status,
        trips: result.data.map(trip => ({
            id: trip.id,
            title: trip.trip_title,
            status: trip.trip_status
        }))
    }, 'PASS');
});

// Test 12: Update Trip
test.serial('12. Update Trip Details', async t => {
    const trip = testData.trips[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        data: {
            trip_title: 'Updated Solo Adventure',
            trip_budget: 600000,
            trip_description: 'Updated description'
        }
    };

    const result = await tripService.updateTrip(params.tripId, params.userId, params.data);

    t.is(result.trip_title, params.data.trip_title);
    t.is(parseFloat(result.trip_budget), params.data.trip_budget);

    logTestResult('Update Trip Details', params, {
        tripId: result.id,
        oldTitle: trip.trip_title,
        newTitle: result.trip_title,
        oldBudget: trip.trip_budget,
        newBudget: result.trip_budget
    }, 'PASS');
});

// Test 13: Change Trip Status
test.serial('13. Change Trip Status to Active', async t => {
    const trip = testData.trips[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        status: 'active'
    };

    const result = await tripService.changeTripStatus(params.tripId, params.userId, params.status);

    t.is(result.trip_status, 'active');

    logTestResult('Change Trip Status', params, {
        tripId: result.id,
        oldStatus: trip.trip_status,
        newStatus: result.trip_status
    }, 'PASS');
});

// Test 14: Reorder Destinations
test.serial('14. Reorder Destinations in Trip', async t => {
    const trip = testData.trips[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        destinationOrders: [
            { destId: testData.destinations[1].id, visitOrder: 1 },
            { destId: testData.destinations[0].id, visitOrder: 2 }
        ]
    };

    const result = await tripService.reorderDestinations(
        params.tripId,
        params.userId,
        params.destinationOrders
    );

    t.truthy(result.message);

    logTestResult('Reorder Destinations', params, result, 'PASS');
});

// Test 15: Remove Destination from Trip
test.serial('15. Remove Destination from Trip', async t => {
    const trip = testData.trips[1]; // Use second trip
    const destination = testData.destinations[0];

    // First add a destination
    await tripService.addDestinationToTrip(
        trip.id,
        testData.users[0].id,
        {
            destId: destination.id,
            visitOrder: 1
        }
    );

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        destId: destination.id
    };

    const result = await tripService.removeDestinationFromTrip(
        params.tripId,
        params.userId,
        params.destId
    );

    t.truthy(result.message);

    logTestResult('Remove Destination from Trip', params, result, 'PASS');
});

// Test 16: Remove Event from Trip
test.serial('16. Remove Event from Trip', async t => {
    const trip = testData.trips[0];
    const event = testData.events[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        eventId: event.id
    };

    const result = await tripService.removeEventFromTrip(
        params.tripId,
        params.userId,
        params.eventId
    );

    t.truthy(result.message);

    logTestResult('Remove Event from Trip', params, result, 'PASS');
});

// Test 17: Access Denied - Wrong User
test.serial('17. Access Denied - Get Trip by Wrong User (Should Fail)', async t => {
    const trip = testData.trips[0]; // Created by user1

    const params = {
        tripId: trip.id,
        userId: testData.users[1].id // user2 trying to access
    };

    const error = await t.throwsAsync(
        async () => await tripService.getTripById(params.tripId, params.userId)
    );

    t.truthy(error.message.includes('denied') || error.message.includes('not found'));

    logTestResult('Access Denied - Wrong User', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 18: Delete Trip
test.serial('18. Delete Trip', async t => {
    const trip = testData.trips[2]; // Use third trip

    const params = {
        tripId: trip.id,
        userId: testData.users[1].id
    };

    const result = await tripService.deleteTrip(params.tripId, params.userId);

    t.truthy(result.message);

    logTestResult('Delete Trip', params, result, 'PASS');
});

// Test 19: Trip Not Found After Delete
test.serial('19. Trip Not Found After Delete (Should Fail)', async t => {
    const trip = testData.trips[2];

    const params = {
        tripId: trip.id,
        userId: testData.users[1].id
    };

    const error = await t.throwsAsync(
        async () => await tripService.getTripById(params.tripId, params.userId)
    );

    t.truthy(error.message.includes('not found'));

    logTestResult('Trip Not Found After Delete', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 20: Duplicate Destination (Should Fail)
test.serial('20. Add Duplicate Destination to Trip (Should Fail)', async t => {
    const trip = testData.trips[0];
    const destination = testData.destinations[0];

    const params = {
        tripId: trip.id,
        userId: testData.users[0].id,
        destId: destination.id
    };

    const error = await t.throwsAsync(
        async () => await tripService.addDestinationToTrip(
            params.tripId,
            params.userId,
            { destId: params.destId }
        )
    );

    t.truthy(error.message.includes('already added'));

    logTestResult('Add Duplicate Destination', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Print final summary
test.after.always('Final Summary', t => {
    console.log('\n\n');
    console.log('╔' + '═'.repeat(78) + '╗');
    console.log('║' + ' '.repeat(25) + 'TEST EXECUTION SUMMARY' + ' '.repeat(30) + '║');
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

    console.log('\n✅ All tests completed successfully!\n');
});


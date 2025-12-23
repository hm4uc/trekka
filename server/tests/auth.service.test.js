import test from 'ava';
import bcrypt from 'bcrypt';
import authService from '../services/auth.service.js';
import { Profile, TokenBlacklist } from '../models/associations.js';
import sequelize from '../database/db.js';

// Test data storage
const testData = {
    users: [],
    tokens: [],
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
    console.log('\n🔧 Setting up authentication test database...\n');

    // Sync database
    await sequelize.sync({ force: false });

    console.log('✅ Database ready for authentication tests\n');
});

// Test 1: Register New User
test.serial('1. Register New User', async t => {
    const params = {
        usr_fullname: 'John Doe',
        usr_email: `john.doe.${Date.now()}@test.com`,
        usr_password: 'SecurePassword123!',
        usr_preferences: ['nature', 'culture'],
        usr_budget: 1000000
    };

    const result = await authService.register(params);
    testData.users.push(result.user);
    testData.tokens.push(result.token);

    t.truthy(result.user);
    t.truthy(result.token);
    t.is(result.user.usr_email, params.usr_email);
    t.is(result.user.usr_fullname, params.usr_fullname);
    t.falsy(result.user.usr_password_hash); // Should not return password hash

    logTestResult('Register New User', params, {
        userId: result.user.id,
        userEmail: result.user.usr_email,
        userFullname: result.user.usr_fullname,
        tokenReceived: !!result.token
    }, 'PASS');
});

// Test 2: Register with Duplicate Email
test.serial('2. Register with Duplicate Email (Should Fail)', async t => {
    const existingUser = testData.users[0];

    const params = {
        usr_fullname: 'Jane Doe',
        usr_email: existingUser.usr_email,
        usr_password: 'AnotherPassword123!'
    };

    const error = await t.throwsAsync(
        async () => await authService.register(params)
    );

    t.truthy(error.message.includes('email') || error.message.includes('exist'));

    logTestResult('Register with Duplicate Email', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 3: Register with Invalid Email Format
test.serial('3. Register with Invalid Email (Should Fail)', async t => {
    const params = {
        usr_fullname: 'Invalid User',
        usr_email: 'not-an-email',
        usr_password: 'Password123!'
    };

    const error = await t.throwsAsync(
        async () => await authService.register(params)
    );

    t.truthy(error);

    logTestResult('Register with Invalid Email', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 4: Login with Correct Credentials
test.serial('4. Login with Correct Credentials', async t => {
    const user = testData.users[0];

    const params = {
        usr_email: user.usr_email,
        usr_password: 'SecurePassword123!'
    };

    const result = await authService.login(params);

    t.truthy(result.user);
    t.truthy(result.token);
    t.is(result.user.usr_email, params.usr_email);

    logTestResult('Login with Correct Credentials', params, {
        userId: result.user.id,
        userEmail: result.user.usr_email,
        tokenReceived: !!result.token
    }, 'PASS');
});

// Test 5: Login with Wrong Password
test.serial('5. Login with Wrong Password (Should Fail)', async t => {
    const user = testData.users[0];

    const params = {
        usr_email: user.usr_email,
        usr_password: 'WrongPassword123!'
    };

    const error = await t.throwsAsync(
        async () => await authService.login(params)
    );

    t.truthy(error.message.includes('Invalid') || error.message.includes('password'));

    logTestResult('Login with Wrong Password', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 6: Login with Non-existent Email
test.serial('6. Login with Non-existent Email (Should Fail)', async t => {
    const params = {
        usr_email: 'nonexistent@test.com',
        usr_password: 'Password123!'
    };

    const error = await t.throwsAsync(
        async () => await authService.login(params)
    );

    t.truthy(error.message.includes('Invalid') || error.message.includes('not found'));

    logTestResult('Login with Non-existent Email', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 7: Get User Profile
test.serial('7. Get User Profile', async t => {
    const user = testData.users[0];

    const params = {
        userId: user.id
    };

    const result = await authService.getProfile(params.userId);

    t.is(result.id, user.id);
    t.is(result.usr_email, user.usr_email);
    t.falsy(result.usr_password_hash); // Should not return password hash

    logTestResult('Get User Profile', params, {
        userId: result.id,
        userEmail: result.usr_email,
        userFullname: result.usr_fullname,
        preferences: result.usr_preferences,
        budget: result.usr_budget
    }, 'PASS');
});

// Test 8: Update User Profile
test.serial('8. Update User Profile', async t => {
    const user = testData.users[0];

    const params = {
        userId: user.id,
        data: {
            usr_fullname: 'John Updated Doe',
            usr_budget: 1500000,
            usr_preferences: ['nature', 'culture', 'food']
        }
    };

    const result = await authService.updateProfile(params.userId, params.data);

    t.is(result.usr_fullname, params.data.usr_fullname);
    t.is(parseFloat(result.usr_budget), params.data.usr_budget);
    t.deepEqual(result.usr_preferences, params.data.usr_preferences);

    logTestResult('Update User Profile', params, {
        userId: result.id,
        oldFullname: user.usr_fullname,
        newFullname: result.usr_fullname,
        oldBudget: user.usr_budget,
        newBudget: result.usr_budget,
        preferences: result.usr_preferences
    }, 'PASS');
});

// Test 9: Change Password
test.serial('9. Change Password', async t => {
    const user = testData.users[0];

    const params = {
        userId: user.id,
        oldPassword: 'SecurePassword123!',
        newPassword: 'NewSecurePassword456!'
    };

    const result = await authService.changePassword(
        params.userId,
        params.oldPassword,
        params.newPassword
    );

    t.truthy(result.message);

    // Verify new password works
    const loginResult = await authService.login({
        usr_email: user.usr_email,
        usr_password: params.newPassword
    });

    t.truthy(loginResult.token);

    logTestResult('Change Password', params, {
        message: result.message,
        newPasswordWorks: !!loginResult.token
    }, 'PASS');
});

// Test 10: Change Password with Wrong Old Password
test.serial('10. Change Password with Wrong Old Password (Should Fail)', async t => {
    const user = testData.users[0];

    const params = {
        userId: user.id,
        oldPassword: 'WrongOldPassword123!',
        newPassword: 'NewPassword789!'
    };

    const error = await t.throwsAsync(
        async () => await authService.changePassword(
            params.userId,
            params.oldPassword,
            params.newPassword
        )
    );

    t.truthy(error.message.includes('password') || error.message.includes('incorrect'));

    logTestResult('Change Password with Wrong Old Password', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Test 11: Request Password Reset
test.serial('11. Request Password Reset', async t => {
    const user = testData.users[0];

    const params = {
        usr_email: user.usr_email
    };

    const result = await authService.requestPasswordReset(params.usr_email);

    t.truthy(result.message);

    // Verify reset token was created
    const updatedUser = await Profile.findByPk(user.id);
    t.truthy(updatedUser.reset_password_token);
    t.truthy(updatedUser.reset_password_expires);

    logTestResult('Request Password Reset', params, {
        message: result.message,
        tokenCreated: !!updatedUser.reset_password_token
    }, 'PASS');
});

// Test 12: Logout
test.serial('12. Logout (Blacklist Token)', async t => {
    const token = testData.tokens[0];

    const params = {
        token: token
    };

    const result = await authService.logout(params.token);

    t.truthy(result.message);

    // Verify token is blacklisted
    const blacklisted = await TokenBlacklist.findOne({
        where: { token: params.token }
    });

    t.truthy(blacklisted);

    logTestResult('Logout (Blacklist Token)', params, {
        message: result.message,
        tokenBlacklisted: !!blacklisted
    }, 'PASS');
});

// Test 13: Register Multiple Users with Different Data
test.serial('13. Register Multiple Users', async t => {
    const users = [
        {
            usr_fullname: 'Alice Smith',
            usr_email: `alice.smith.${Date.now()}@test.com`,
            usr_password: 'AlicePass123!',
            usr_age: 25,
            usr_gender: 'female'
        },
        {
            usr_fullname: 'Bob Johnson',
            usr_email: `bob.johnson.${Date.now()}@test.com`,
            usr_password: 'BobPass123!',
            usr_age: 30,
            usr_gender: 'male'
        }
    ];

    const results = [];

    for (const userData of users) {
        const result = await authService.register(userData);
        results.push(result);
        t.truthy(result.user);
        t.truthy(result.token);
    }

    logTestResult('Register Multiple Users', { count: users.length }, {
        usersCreated: results.length,
        users: results.map(r => ({
            email: r.user.usr_email,
            fullname: r.user.usr_fullname
        }))
    }, 'PASS');
});

// Test 14: Verify Token is Valid
test.serial('14. Verify Valid Token', async t => {
    // Register new user to get fresh token
    const registerResult = await authService.register({
        usr_fullname: 'Token Test User',
        usr_email: `token.test.${Date.now()}@test.com`,
        usr_password: 'TokenTest123!'
    });

    const params = {
        token: registerResult.token
    };

    const result = await authService.verifyToken(params.token);

    t.truthy(result.profileId);
    t.is(result.usr_email, registerResult.user.usr_email);

    logTestResult('Verify Valid Token', params, {
        profileId: result.profileId,
        email: result.usr_email,
        valid: true
    }, 'PASS');
});

// Test 15: Verify Invalid/Blacklisted Token
test.serial('15. Verify Blacklisted Token (Should Fail)', async t => {
    const blacklistedToken = testData.tokens[0]; // This was blacklisted in test 12

    const params = {
        token: blacklistedToken
    };

    const error = await t.throwsAsync(
        async () => await authService.verifyToken(params.token)
    );

    t.truthy(error.message.includes('blacklist') || error.message.includes('invalid'));

    logTestResult('Verify Blacklisted Token', params, {
        error: error.message
    }, 'PASS (Expected Error)');
});

// Print final summary
test.after.always('Final Summary', t => {
    console.log('\n\n');
    console.log('╔' + '═'.repeat(78) + '╗');
    console.log('║' + ' '.repeat(25) + 'AUTH TEST SUMMARY' + ' '.repeat(33) + '║');
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

    console.log('\n✅ All authentication tests completed successfully!\n');
});


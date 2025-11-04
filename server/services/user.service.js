const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

async function register(userData) {
    const { name, email, password } = userData;

    try {
        console.log('🔍 Checking if user exists...');
        // Check if user already exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            console.log('❌ User already exists');
            const error = new Error('Email already exists');
            error.statusCode = 409;
            throw error;
        }

        console.log('🔐 Hashing password...');
        // Hash password
        const saltRounds = 10;
        const password_hash = await bcrypt.hash(password, saltRounds);

        console.log('👤 Creating user...');
        // Create user
        const user = await User.create({
            name,
            email,
            password_hash
        });

        console.log('🎫 Generating JWT token...');
        // Generate JWT token
        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        console.log('✅ User registered successfully');
        // Return user data without password
        return {
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                avatar_url: user.avatar_url,
                created_at: user.created_at
            },
            token
        };
    } catch (error) {
        console.error('❌ Error in register service:', error);
        throw error;
    }
}

async function login(loginData) {
    const { email, password } = loginData;

    try {
        console.log('🔍 Finding user for login...');
        // Find user
        const user = await User.findOne({ where: { email } });
        if (!user) {
            console.log('❌ User not found');
            const error = new Error('Invalid email or password');
            error.statusCode = 401;
            throw error;
        }

        console.log('🔐 Comparing passwords...');
        // Check password
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);
        if (!isPasswordValid) {
            console.log('❌ Invalid password');
            const error = new Error('Invalid email or password');
            error.statusCode = 401;
            throw error;
        }

        console.log('🎫 Generating JWT token for login...');
        // Generate JWT token
        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        console.log('✅ User logged in successfully');
        // Return user data without password
        return {
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                avatar_url: user.avatar_url,
                created_at: user.created_at
            },
            token
        };
    } catch (error) {
        console.error('❌ Error in login service:', error);
        throw error;
    }
}

async function getUserById(userId) {
    const user = await User.findByPk(userId, {
        attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
    }

    return user;
}

module.exports = {
    register,
    login,
    getUserById
};
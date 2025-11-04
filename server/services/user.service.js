import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import Profile from '../models/profile.model.js';

async function register(userData) {
    const { usr_fullname, usr_email, password, usr_gender, usr_age, usr_job, usr_preferences, usr_budget } = userData;

    try {
        console.log('🔍 Checking if profile exists...');
        const existingProfile = await Profile.findOne({ where: { usr_email } });
        if (existingProfile) {
            console.log('❌ Profile already exists');
            const error = new Error('Email already exists');
            error.statusCode = 409;
            throw error;
        }

        console.log('🔐 Hashing password...');
        const saltRounds = 10;
        const usr_password_hash = await bcrypt.hash(password, saltRounds);

        console.log('👤 Creating profile...');
        const profile = await Profile.create({
            usr_fullname,
            usr_email,
            usr_password_hash,
            usr_gender,
            usr_age,
            usr_job,
            usr_preferences,
            usr_budget
        });

        console.log('🎫 Generating JWT token...');
        const token = jwt.sign(
            { profileId: profile.id, usr_email: profile.usr_email },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        console.log('✅ Profile registered successfully');
        return {
            profile: {
                id: profile.id,
                usr_fullname: profile.usr_fullname,
                usr_email: profile.usr_email,
                usr_gender: profile.usr_gender,
                usr_age: profile.usr_age,
                usr_job: profile.usr_job,
                usr_preferences: profile.usr_preferences,
                usr_budget: profile.usr_budget,
                usr_avatar: profile.usr_avatar,
                usr_bio: profile.usr_bio,
                is_active: profile.is_active,
                usr_created_at: profile.usr_created_at
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
        console.log('🔍 Finding profile for login...');
        const profile = await Profile.findOne({ where: { usr_email: email } });
        if (!profile) {
            console.log('❌ Profile not found');
            const error = new Error('Invalid email or password');
            error.statusCode = 401;
            throw error;
        }

        console.log('🔐 Comparing passwords...');
        const isPasswordValid = await bcrypt.compare(password, profile.usr_password_hash);
        if (!isPasswordValid) {
            console.log('❌ Invalid password');
            const error = new Error('Invalid email or password');
            error.statusCode = 401;
            throw error;
        }

        console.log('🎫 Generating JWT token for login...');
        const token = jwt.sign(
            { profileId: profile.id, usr_email: profile.usr_email },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        console.log('✅ Profile logged in successfully');
        return {
            profile: {
                id: profile.id,
                usr_fullname: profile.usr_fullname,
                usr_email: profile.usr_email,
                usr_gender: profile.usr_gender,
                usr_age: profile.usr_age,
                usr_job: profile.usr_job,
                usr_preferences: profile.usr_preferences,
                usr_budget: profile.usr_budget,
                usr_avatar: profile.usr_avatar,
                usr_bio: profile.usr_bio,
                is_active: profile.is_active,
                usr_created_at: profile.usr_created_at
            },
            token
        };
    } catch (error) {
        console.error('❌ Error in login service:', error);
        throw error;
    }
}

async function getProfileById(profileId) {
    const profile = await Profile.findByPk(profileId, {
        attributes: { exclude: ['usr_password_hash'] }
    });

    if (!profile) {
        const error = new Error('Profile not found');
        error.statusCode = 404;
        throw error;
    }

    return profile;
}

export default { register, login, getProfileById };
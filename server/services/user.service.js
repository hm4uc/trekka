import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Op } from 'sequelize';
import Profile from '../models/profile.model.js';
import {TRAVEL_STYLES, BUDGET_CONFIG, AGE_GROUPS} from '../config/travelConstants.js';

async function register(userData) {
    const { usr_fullname, usr_email, password, usr_gender, usr_age_group } = userData;

    try {
        const existingProfile = await Profile.findOne({ where: { usr_email } });
        if (existingProfile) {
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
            usr_age_group,
        });

        console.log('🎫 Generating JWT token...');
        const token = jwt.sign(
            { profileId: profile.id, usr_email: profile.usr_email },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        console.log('✅ Profile registered successfully');
        return {
            profile: sanitizeProfile(profile),
            token
        };
    } catch (error) {
        console.error('❌ Error in register service:', error);
        throw error;
    }
}

async function updateProfile(profileId, updateData) {
    try {
        console.log('🔍 Finding profile for update...');
        const profile = await Profile.findByPk(profileId);
        if (!profile) {
            console.log('❌ Profile not found');
            const error = new Error('Profile not found');
            error.statusCode = 404;
            throw error;
        }

        console.log('🔄 Updating profile...');

        // Cập nhật các trường được phép
        const allowedFields = ['usr_fullname', 'usr_gender', 'usr_age_group', 'usr_avatar', 'usr_bio'];
        allowedFields.forEach(field => {
            if (updateData[field] !== undefined) {
                profile[field] = updateData[field];
            }
        });

        // Cập nhật thời gian update
        profile.usr_updated_at = new Date();

        await profile.save();

        return sanitizeProfile(profile);
    } catch (error) {
        console.error('❌ Error updating profile:', error);
        throw error;
    }
}

async function updatePreferencesAndBudget(profileId, { usr_preferences, usr_budget }) {
    try {
        console.log('🔍 Finding profile for update...');
        const profile = await Profile.findByPk(profileId);
        if (!profile) {
            console.log('❌ Profile not found');
            const error = new Error('Profile not found');
            error.statusCode = 404;
            throw error;
        }

        console.log('🔄 Updating preferences and budget...');

        // Validate travel preferences - sửa lại để so sánh với id
        if (usr_preferences !== undefined) {
            const validStyleIds = TRAVEL_STYLES.map(style => style.id);
            const invalidPreferences = usr_preferences.filter(pref => !validStyleIds.includes(pref));
            if (invalidPreferences.length > 0) {
                const error = new Error(`Invalid travel style IDs: ${invalidPreferences.join(', ')}. Valid styles: ${validStyleIds.join(', ')}`);
                error.statusCode = 400;
                throw error;
            }
            profile.usr_preferences = usr_preferences;
        }

        // Validate budget
        if (usr_budget !== undefined) {
            if (usr_budget < BUDGET_CONFIG.MIN || usr_budget > BUDGET_CONFIG.MAX) {
                const error = new Error(`Budget must be between ${BUDGET_CONFIG.MIN} and ${BUDGET_CONFIG.MAX}`);
                error.statusCode = 400;
                throw error;
            }
            profile.usr_budget = usr_budget;
        }

        // Cập nhật thời gian update
        profile.usr_updated_at = new Date();

        await profile.save();

        console.log('✅ Preferences and budget updated successfully');
        return {
            id: profile.id,
            usr_preferences: profile.usr_preferences,
            usr_budget: profile.usr_budget,
            meta: {
                travel_styles: TRAVEL_STYLES,
                budget_config: BUDGET_CONFIG
            }
        };
    } catch (error) {
        console.error('❌ Error updating preferences and budget:', error);
        throw error;
    }
}

async function deleteProfile(profileId) {
    try {
        console.log('🔍 Finding profile for deletion...');
        const profile = await Profile.findByPk(profileId);
        if (!profile) {
            console.log('❌ Profile not found');
            const error = new Error('Profile not found');
            error.statusCode = 404;
            throw error;
        }

        console.log('🗑️ Deleting profile...');
        await profile.destroy();

        console.log('✅ Profile deleted successfully');
        return true;
    } catch (error) {
        console.error('❌ Error deleting profile:', error);
        throw error;
    }
}

async function login(loginData) {
    const { usr_email, password } = loginData;

    try {
        const profile = await Profile.findOne({ where: { usr_email } });
        if (!profile) {
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
            profile: sanitizeProfile(profile),
            token
        };
    } catch (error) {
        console.error('❌ Error in login service:', error);
        throw error;
    }
}

async function getProfileById(profileId) {
    const profile = await Profile.findByPk(profileId, {
        attributes: { exclude: ['usr_password_hash', 'reset_password_token', 'reset_password_expires'] }
    });

    if (!profile) {
        const error = new Error('Profile not found');
        error.statusCode = 404;
        throw error;
    }

    return profile;
}

// Cập nhật hàm lấy constants cho FE lúc khởi động app
async function getTravelConstants() {
    return {
        travel_styles: TRAVEL_STYLES,
        budget_config: BUDGET_CONFIG,
        age_groups: AGE_GROUPS
    };
}

async function logout() {
    // Với JWT stateless, logout chủ yếu xử lý ở Client (xóa token).
    // Nếu muốn chặt chẽ, cần dùng Redis để blacklist token.
    // Ở đây ta trả về success để FE biết quy trình hoàn tất.
    return true;
}

// Helper function để loại bỏ password hash khi trả về
function sanitizeProfile(profile) {
    const p = profile.toJSON ? profile.toJSON() : profile;
    const { usr_password_hash, reset_password_token, reset_password_expires, ...rest } = p;
    return rest;
}

export default {
    register,
    login,
    getProfileById,
    updateProfile,
    updatePreferencesAndBudget,
    deleteProfile,
    getTravelConstants,
    logout
};
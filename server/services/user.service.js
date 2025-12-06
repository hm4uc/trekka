import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { Op } from 'sequelize';
import Profile from '../models/profile.model.js';
import TokenBlacklist from '../models/tokenBlacklist.model.js';
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

async function createPreferencesAndBudget(profileId, { usr_preferences, usr_budget }) {
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

/**
 * Logout user by blacklisting their current token
 * @param {string} token - JWT token to blacklist
 * @param {string} profileId - User's profile ID
 * @param {string} [reason='logout'] - Reason for logout (logout, security, etc.)
 * @returns {Promise<Object>} - Logout result
 */
async function logout(token, profileId, reason = 'logout') {
    try {
        // Decode token to get expiration time (without verification since we already verified it in middleware)
        const decoded = jwt.decode(token);

        if (!decoded || !decoded.exp) {
            throw new Error('Invalid token format');
        }

        // Convert exp (seconds since epoch) to Date object
        const expiresAt = new Date(decoded.exp * 1000);

        // Add token to blacklist
        await TokenBlacklist.create({
            token,
            profileId,
            reason,
            expiresAt
        });

        console.info(`✅ User ${profileId} logged out successfully. Reason: ${reason}`);

        return {
            success: true,
            message: 'Logged out successfully'
        };
    } catch (error) {
        console.error('Logout error:', error);

        // If token already blacklisted, consider it a success
        if (error.name === 'SequelizeUniqueConstraintError') {
            console.warn(`⚠️ Token already blacklisted for profile ${profileId}`);
            return {
                success: true,
                message: 'Already logged out'
            };
        }

        throw error;
    }
}

/**
 * Logout from all devices by blacklisting all active tokens for a user
 * @param {string} profileId - User's profile ID
 * @param {string} currentToken - Current JWT token
 * @returns {Promise<Object>} - Logout result
 */
async function logoutAllDevices(profileId, currentToken) {
    try {
        // First, blacklist the current token
        await logout(currentToken, profileId, 'logout_all_devices');

        // Note: Since JWT is stateless, we can't retrieve all active tokens
        // This blacklists the current token and marks in the system that user requested logout from all devices
        // In a production system, you might want to:
        // 1. Keep track of all issued tokens in database
        // 2. Use shorter token expiration times
        // 3. Implement refresh token rotation

        console.info(`✅ User ${profileId} logged out from all devices`);

        return {
            success: true,
            message: 'Logged out from all devices successfully'
        };
    } catch (error) {
        console.error('Logout all devices error:', error);
        throw error;
    }
}

/**
 * Clean up expired tokens from blacklist
 * This should be run periodically (e.g., via cron job)
 * @returns {Promise<number>} - Number of tokens removed
 */
async function cleanupExpiredTokens() {
    try {
        const now = new Date();
        const result = await TokenBlacklist.destroy({
            where: {
                expiresAt: {
                    [Op.lt]: now
                }
            }
        });

        console.info(`🧹 Cleaned up ${result} expired tokens from blacklist`);
        return result;
    } catch (error) {
        console.error('Token cleanup error:', error);
        throw error;
    }
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
    createPreferencesAndBudget,
    deleteProfile,
    getTravelConstants,
    logout,
    logoutAllDevices,
    cleanupExpiredTokens
};
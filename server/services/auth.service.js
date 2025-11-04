import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

async function register({ name, email, password }) {
    const existing = await User.findOne({ where: { email }});
    if (existing) throw new Error('Email exists');
    const hash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password_hash: hash });
    return { id: user.id, email: user.email, name: user.name };
}

async function login({ email, password }) {
    const user = await User.findOne({ where: { email }});
    if (!user) throw new Error('Invalid credentials');
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) throw new Error('Invalid credentials');
    const token = jwt.sign({ userId: user.id }, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
    return { token, user: { id: user.id, email: user.email, name: user.name } };
}

export default {register, login};

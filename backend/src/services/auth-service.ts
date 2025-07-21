import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { Pool } from 'pg';

const pool = new Pool({
  // Database connection details will be environment variables
  connectionString: process.env.DATABASE_URL,
});

const saltRounds = 10;
const jwtSecret = process.env.JWT_SECRET || 'your_jwt_secret';

export class AuthService {
  async register(email: string, password: string): Promise<any> {
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const result = await pool.query(
      'INSERT INTO users (email, password_hash) VALUES ($1, $2) RETURNING *',
      [email, hashedPassword]
    );
    return result.rows[0];
  }

  async login(email: string, password: string): Promise<string | null> {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (user && (await bcrypt.compare(password, user.password_hash))) {
      const token = jwt.sign({ userId: user.id }, jwtSecret, { expiresIn: '1h' });
      return token;
    }

    return null;
  }
}

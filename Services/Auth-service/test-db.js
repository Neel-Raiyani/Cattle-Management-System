import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const uri = process.env.DATABASE_URL;

if (!uri) {
    console.error('DATABASE_URL is not defined in .env');
    process.exit(1);
}

console.log('Testing connection to:', uri.replace(/:([^:@]+)@/, ':****@'));

const client = new MongoClient(uri);

async function run() {
    try {
        await client.connect();
        console.log('Successfully connected to MongoDB Atlas');
        const db = client.db('CMS');
        const collections = await db.listCollections().toArray();
        console.log('Collections in CMS:', collections.map(c => c.name));
    } catch (err) {
        console.error('Connection failed:');
        console.error(err);
    } finally {
        await client.close();
    }
}

run();

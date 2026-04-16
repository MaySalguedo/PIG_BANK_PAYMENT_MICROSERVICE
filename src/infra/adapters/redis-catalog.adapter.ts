import { Redis } from 'ioredis';

export class RedisCatalogAdapter {
    private redis: Redis;

    constructor() {
        this.redis = new Redis({
            host: process.env.REDIS_HOST,
            port: Number(process.env.REDIS_PORT)
        });
    }

    public async saveCatalog(services: any[]): Promise<void> {
        await this.redis.set('pigbank:catalog', JSON.stringify(services));
		await redis.quit();
    }

    public async getCatalog(): Promise<any[]> {
        const data = await this.redis.get('pigbank:catalog');
        return data ? JSON.parse(data) : [];
    }
}
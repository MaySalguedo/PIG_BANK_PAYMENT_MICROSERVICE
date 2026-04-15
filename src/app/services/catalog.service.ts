import { parse } from 'csv-parse/sync';
import { RedisCatalogAdapter } from '@adapters/redis-catalog.adapter';

export class CatalogService {
	constructor(private readonly redisAdapter: RedisCatalogAdapter) {}

	public async syncCatalog(csvBuffer: Buffer): Promise<void> {
		const records = parse(csvBuffer, {
			columns: true,
			skip_empty_lines: true,
		});

		const catalog = records.map((row: any) => ({
			id: Number(row.ID),
			category: row.Categoría,
			provider: row.Proveedor,
			service: row.Servicio,
			plan: row.Plan,
			monthly_price: Number(row['Precio Mensual'].replace(/[^0-9.-]+/g, "")),
			details: row['Velocidad/Detalles'],
			status: row.Estado === 'Activo' ? 'Active' : 'Inactive'
		}));

		await this.redisAdapter.saveCatalog(catalog);
	}

	public async listServices(): Promise<any[]> {
		return await this.redisAdapter.getCatalog();
	}
}
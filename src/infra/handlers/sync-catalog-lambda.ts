import { S3Event } from "aws-lambda";
import { S3Adapter } from "@adapters/s3.adapter";
import { RedisCatalogAdapter } from "@adapters/redis-catalog.adapter";
import { CatalogService } from "@services/catalog.service";

const s3Adapter = new S3Adapter();
const redisAdapter = new RedisCatalogAdapter();
const catalogService = new CatalogService(redisAdapter);

export const handler = async (event: S3Event): Promise<void> => {
	try {
		for (const record of event.Records) {
			const bucketName = record.s3.bucket.name;
			const fileKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

			console.log(`Processing file: ${fileKey} from bucket: ${bucketName}`);

			const csvBuffer = await s3Adapter.getFileBuffer(bucketName, fileKey);

			await catalogService.syncCatalog(csvBuffer);

			console.log(`Catalog sync completed successfully for ${fileKey}`);
		}
	} catch (error) {
		console.error("Error in SyncCatalogLambda:", error);
		throw error; 
	}
};
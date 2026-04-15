// src/infra/handlers/get-catalog-lambda.ts
import { APIGatewayProxyResult } from "aws-lambda";
import { RedisCatalogAdapter } from "@adapters/redis-catalog.adapter";
import { CatalogService } from "@services/catalog.service";

const redisAdapter = new RedisCatalogAdapter();
const catalogService = new CatalogService(redisAdapter);

export const handler = async (): Promise<APIGatewayProxyResult> => {
	try {
		const services = await catalogService.listServices();
		
		return {
			statusCode: 200,
			body: JSON.stringify(services),
		};
	} catch (error) {
		return {
			statusCode: 500,
			body: JSON.stringify({ message: "Error fetching catalog" }),
		};
	}
};
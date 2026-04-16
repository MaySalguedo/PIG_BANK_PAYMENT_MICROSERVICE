// src/infra/handlers/get-catalog-lambda.ts
import { APIGatewayProxyResult } from "aws-lambda";
import { RedisCatalogAdapter } from "@adapters/redis-catalog.adapter";
import { CatalogService } from "@services/catalog.service";
	
const redisAdapter = new RedisCatalogAdapter();
const catalogService = new CatalogService(redisAdapter);

export const handler = async (event: any) => {
	console.log("Evento recibido:", JSON.stringify(event));
	console.log("Intentando conectar a Redis en:", process.env.REDIS_HOST);

	try {

		const services = await catalogService.listServices(); 
		console.log("Servicios obtenidos con éxito");
		
		return {
			statusCode: 200,
			body: JSON.stringify(services),
		};
	} catch (error) {
		console.error("Error detallado:", error);
		return {
			statusCode: 500,
			body: JSON.stringify({ message: "Error interno", detail: error.message }),
		};
	}
};
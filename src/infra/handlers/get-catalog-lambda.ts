// src/infra/handlers/get-catalog-lambda.ts
import { APIGatewayProxyResult } from "aws-lambda";
import { RedisCatalogAdapter } from "@adapters/redis-catalog.adapter";
import { CatalogService } from "@services/catalog.service";
import { jsonResponse } from "../http/cors";
	
const redisAdapter = new RedisCatalogAdapter();
const catalogService = new CatalogService(redisAdapter);

export const handler = async (event: any) => {
	console.log("Evento recibido:", JSON.stringify(event));
	console.log("Intentando conectar a Redis en:", process.env.REDIS_HOST);

	try {

		const services = await catalogService.listServices(); 
		console.log("Servicios obtenidos con éxito");
		
		return jsonResponse(200, services);
	} catch (error) {
		console.error("Error detallado:", error);
		return jsonResponse(500, { message: "Error interno", detail: error.message });
	}
};

import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";
import { SqsNotificationAdapter } from "@adapters/sqs-notification.adapter";
import { PaymentService } from "@services/payment.service";
import { jsonResponse } from "../http/cors";

const paymentRepository = new DynamoDbPaymentAdapter();
const notificationAdapter = new SqsNotificationAdapter();

const paymentService = new PaymentService(paymentRepository, notificationAdapter);

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
	try {
		const body = JSON.parse(event.body || "{}");
		const { cardId, service } = body;

		const traceId = await paymentService.startPayment(cardId, service);

		return jsonResponse(201, { traceId });
	} catch (error: any) {
		return jsonResponse(500, { message: error.message });
	}
};

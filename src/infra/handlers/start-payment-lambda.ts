import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";
import { SqsNotificationAdapter } from "@adapters/sqs-notification.adapter";
import { PaymentService } from "@services/payment.service";

const paymentRepository = new DynamoDbPaymentAdapter();
const notificationAdapter = new SqsNotificationAdapter();

const paymentService = new PaymentService(paymentRepository, notificationAdapter);

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
	try {
		const body = JSON.parse(event.body || "{}");
		const { cardId, service } = body;

		const traceId = await paymentService.startPayment(cardId, service);

		return {
			statusCode: 201,
			body: JSON.stringify({ traceId })
		};
	} catch (error: any) {
		return {
			statusCode: 500,
			body: JSON.stringify({ message: error.message })
		};
	}
};
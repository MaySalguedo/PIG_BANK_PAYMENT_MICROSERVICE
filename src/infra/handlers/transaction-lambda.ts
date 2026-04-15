import { SQSEvent } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";
import { SqsNotificationAdapter } from "@adapters/sqs-notification.adapter";
import { BankApiAdapter } from "@adapters/bank-api.adapter";
import { PaymentService } from "@services/payment.service";

const paymentRepo = new DynamoDbPaymentAdapter();
const notificationAdapter = new SqsNotificationAdapter();
const bankAdapter = new BankApiAdapter();

const paymentService = new PaymentService(paymentRepo, notificationAdapter, bankAdapter);

export const handler = async (event: SQSEvent): Promise<void> => {
	for (const record of event.Records) {
		const { data } = JSON.parse(record.body);
		await paymentService.processTransaction(data.traceId);
	}
};
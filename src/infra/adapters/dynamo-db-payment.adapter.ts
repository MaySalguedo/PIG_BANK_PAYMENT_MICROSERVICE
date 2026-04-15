import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
import { Payment } from "@entities/payment.entity";
import { PaymentRepository } from "@typos/payment-repository.type";

export class DynamoDbPaymentAdapter implements PaymentRepository {
	private readonly docClient: DynamoDBDocumentClient;
	private readonly tableName = "payment-table";

	public constructor() {
		const client = new DynamoDBClient({});
		this.docClient = DynamoDBDocumentClient.from(client);
	}

	public async save(payment: Payment): Promise<void> {
		await this.docClient.send(new PutCommand({
			TableName: this.tableName,
			Item: payment
		}));
	}

	public async findByTraceId(traceId: string): Promise<Payment | undefined> {
		const result = await this.docClient.send(new GetCommand({
			TableName: this.tableName,
			Key: { traceId }
		}));
		return (result.Item as Payment) || undefined;
	}
}
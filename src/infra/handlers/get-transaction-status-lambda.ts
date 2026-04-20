import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";

const paymentRepo = new DynamoDbPaymentAdapter();

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const traceId = event.pathParameters?.traceId;

    if (!traceId) {
        return { statusCode: 400, body: JSON.stringify({ message: "traceId required" }) };
    }

    const transaction = await paymentRepo.findByTraceId(traceId);

    if (!transaction) {
        return { statusCode: 404, body: JSON.stringify({ message: "Transaction not found" }) };
    }

    return {
        statusCode: 200,
        body: JSON.stringify(transaction)
    };
};
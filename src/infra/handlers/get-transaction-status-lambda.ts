import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";
import { jsonResponse } from "../http/cors";

const paymentRepo = new DynamoDbPaymentAdapter();

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const traceId = event.pathParameters?.traceId;

    if (!traceId) {
        return jsonResponse(400, { message: "traceId required" });
    }

    const transaction = await paymentRepo.findByTraceId(traceId);

    if (!transaction) {
        return jsonResponse(404, { message: "Transaction not found" });
    }

    return jsonResponse(200, transaction);
};

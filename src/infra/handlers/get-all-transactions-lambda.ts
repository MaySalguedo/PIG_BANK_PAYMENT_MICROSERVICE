import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";
import { jsonResponse } from "../http/cors";

const paymentRepo = new DynamoDbPaymentAdapter();

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const transactions = await paymentRepo.findAll();

    return jsonResponse(200, transactions);
};

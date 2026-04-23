import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDbPaymentAdapter } from "@adapters/dynamo-db-payment.adapter";

const paymentRepo = new DynamoDbPaymentAdapter();

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const transactions = await paymentRepo.findAll();

    return {
        statusCode: 200,
        body: JSON.stringify(transactions)
    };
};
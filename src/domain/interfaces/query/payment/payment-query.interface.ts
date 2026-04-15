import { Payment } from "@entities/payment.entity";
 
export interface IPaymentQuery {
	findByTraceId(traceId: string): Promise<Payment | undefined>;
}
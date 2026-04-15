import { IPaymentQuery } from "@query/payment/payment-query.interface";
import { IPaymentStatement } from "@statement/payment/payment-statement.interface";
 
export type PaymentRepository = IPaymentQuery & IPaymentStatement;
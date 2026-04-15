import { ServiceCatalog } from "@entities/service-catalog.entity";
import { PaymentStatus } from "@typos/payment-status.type";
 
/**
 * Transient payment state stored in Redis.
 * Propagated through each Lambda in the SQS chain using the traceId.
 */
export interface PaymentState {
	traceId: string;
	cardId: string;
	userId?: string;
	service?: ServiceCatalog;
	status: PaymentStatus;
	error?: string;
	timestamp: string;
}
 
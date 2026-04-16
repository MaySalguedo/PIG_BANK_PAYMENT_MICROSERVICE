import { ServiceCatalog } from "@entities/service-catalog.entity";
import { PaymentStatus } from "@typos/payment-status.type";
 
export interface PaymentState {
	traceId: string;
	cardId: string;
	userId?: string;
	service?: ServiceCatalog;
	status: PaymentStatus;
	error?: string;
	timestamp: string;
}
 
import { Entity } from "@models/entity.model";
import { ServiceCatalog } from "@entities/service-catalog.entity";
import { PaymentStatus } from "@typos/payment-status.type";

 
export interface Payment extends Entity {
	traceId: string,
	userId: string,
	cardId: string,
	service: ServiceCatalog,
	status: PaymentStatus,
	error?: string,
	timestamp: string
}
 
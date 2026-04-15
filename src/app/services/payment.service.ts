import { v4 as uuidv4 } from "uuid";
import { Payment } from "@entities/payment.entity";
import { PaymentRepository } from "@typos/payment-repository.type";
import { INotificationStatement } from "@statement/notification/notification-statement.interface";
import { NotificationEvent } from "@models/notification-event.model";
import { IBankStatement } from "@statement/bank/bank-statement.interface";

export class PaymentService<
	P extends PaymentRepository,
	N extends INotificationStatement<NotificationEvent<string, any>>,
	B extends IBankStatement
> {
	public constructor(
		private readonly paymentRepository: P,
		private readonly notificationPort: N,
		private readonly bankPort: B
	) {}

	public async startPayment(cardId: string, serviceData: any): Promise<Payment['traceId']> {
		const traceId = uuidv4();
		const timestamp = new Date().getTime().toString();
		const service = {
			id: serviceData.id,
			category: serviceData.category,
			provider: serviceData.provider,
			service: serviceData.service,
			plan: serviceData.plan,
			monthly_price: serviceData.monthly_price,
			details: serviceData.details,
			status: serviceData.status
		}
		
		const payment: Payment = {
			uuid: traceId,
			traceId,
			userId: uuidv4(),
			cardId,
			service,
			status: 'INITIAL',
			timestamp,
			createdAt: timestamp
		};

		await this.paymentRepository.save(payment);

		await this.notificationPort.send({
			type: "PAYMENT.START",
			data: { traceId }
		});

		return traceId;
	}

	public async processTransaction(traceId: string): Promise<void> {
		const payment = await this.paymentRepository.findByTraceId(traceId);
		if (!payment) throw new Error("Payment record not found");

		try {

			await this.bankPort.processPurchase(
				payment.cardId,
				payment.service.provider,
				payment.service.monthlyPrice
			);

			payment.status = 'FINISH';
		} catch (error: any) {
			payment.status = 'FAILED';
			payment.error = error.message;
		}

		await this.paymentRepository.save(payment);
	}
}
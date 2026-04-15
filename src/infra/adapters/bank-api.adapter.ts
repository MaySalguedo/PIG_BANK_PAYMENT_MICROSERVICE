import { IBankStatement } from "@statement/bank/bank-statement.interface";

export class BankApiAdapter implements IBankStatement {
	private readonly baseUrl = process.env.CARD_SERVICE_URL;

	public async processPurchase(cardId: string, merchant: string, amount: number): Promise<string> {
		const response = await fetch(`${this.baseUrl}/transactions/purchase`, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({ cardId, merchant, amount })
		});

		if (!response.ok) {
			const error = await response.json();
			throw new Error(error.message || "Core Banking transaction failed");
		}

		const data = await response.json();
		return data.transaction_uuid;
	}
}
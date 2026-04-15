
export interface IBankStatement {
	processPurchase(cardId: string, merchant: string, amount: number): Promise<string>;
}
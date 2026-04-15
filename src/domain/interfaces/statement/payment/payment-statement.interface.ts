import { Payment } from "@entities/payment.entity";
import { IStatement } from '@statement/statement.interface';

export interface IPaymentStatement<T extends Payment = Payment> extends IStatement<T> {}
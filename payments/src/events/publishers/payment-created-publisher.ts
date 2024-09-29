import { Subjects, Publisher, PaymentCreatedEvent } from '@microsampleticket/common';

export class PaymentCreatedPublisher extends Publisher<PaymentCreatedEvent> {
  subject: Subjects.PaymentCreated = Subjects.PaymentCreated;
}

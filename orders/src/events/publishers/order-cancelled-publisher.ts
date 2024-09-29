import { Subjects, Publisher, OrderCancelledEvent } from '@microsampleticket/common';

export class OrderCancelledPublisher extends Publisher<OrderCancelledEvent> {
  subject: Subjects.OrderCancelled = Subjects.OrderCancelled;
}

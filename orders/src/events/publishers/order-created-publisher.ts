import { Publisher, OrderCreatedEvent, Subjects } from '@microsampleticket/common';

export class OrderCreatedPublisher extends Publisher<OrderCreatedEvent> {
  subject: Subjects.OrderCreated = Subjects.OrderCreated;
}

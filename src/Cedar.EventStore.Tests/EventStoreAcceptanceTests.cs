﻿namespace Cedar.EventStore
{
    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using FluentAssertions;
    using Xunit;

    public abstract partial class EventStoreAcceptanceTests
    {
        protected abstract EventStoreAcceptanceTestFixture GetFixture();

        private static NewStreamEvent[] CreateNewStreamEvents(params int[] eventNumbers)
        {
            return eventNumbers
                .Select(eventNumber =>
                {
                    var eventId = Guid.Parse("00000000-0000-0000-0000-" + eventNumber.ToString().PadLeft(12, '0'));
                    return new NewStreamEvent(eventId, "data", new byte[] { 3, 4 });
                })
                .ToArray();
        }

        private static StreamEvent ExpectedStreamEvent(
            string streamId,
            int eventNumber,
            int sequenceNumber)
        {
            var eventId = Guid.Parse("00000000-0000-0000-0000-" + eventNumber.ToString().PadLeft(12, '0'));
            return new StreamEvent(streamId, eventId, sequenceNumber, null, "\"data\"", new byte[] { 3, 4 });
        }

        [Fact]
        public async Task When_dispose_and_read_then_should_throw_ObjectDisposedException()
        {
            using(var fixture = GetFixture())
            {
                var store = await fixture.GetEventStore();
                store.Dispose();

                Func<Task> act = () => store.ReadAll(null, 10);

                act.ShouldThrow<ObjectDisposedException>();
            }
        }

        [Fact]
        public async Task Can_dispose_more_than_once()
        {
            using (var fixture = GetFixture())
            {
                var store = await fixture.GetEventStore();
                store.Dispose();

                Action act = store.Dispose;

                act.ShouldNotThrow();
            }
        }
    }
}
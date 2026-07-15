import EventKit
import Foundation

let store = EKEventStore()
let sema = DispatchSemaphore(value: 0)
var lines: [String] = []

func fetchEvents() {
    let now = Date()
    let windowStart = now.addingTimeInterval(-5 * 60)
    let windowEnd = now.addingTimeInterval(15 * 60)
    let predicate = store.predicateForEvents(withStart: windowStart, end: windowEnd, calendars: nil)
    let events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
    for event in events {
        let ts = Int(event.startDate.timeIntervalSince1970)
        lines.append("\(ts)|||" + (event.title ?? ""))
    }
}

if #available(macOS 14.0, *) {
    Task {
        try? await store.requestFullAccessToEvents()
        store.refreshSourcesIfNecessary()
        fetchEvents()
        sema.signal()
    }
} else {
    store.requestAccess(to: .event) { granted, _ in
        if granted {
            store.refreshSourcesIfNecessary()
            fetchEvents()
        }
        sema.signal()
    }
}

sema.wait()
lines.forEach { print($0) }

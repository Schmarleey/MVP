//
//  DateBlockEditorView.swift
//  MVP
//
//  Editor für Datum-Blöcke. Ermöglicht das Bearbeiten von Start- und (optional) Enddatum sowie einen „Ganztägig“‑Toggle.
import SwiftUI

struct DateBlockEditorView: View {
    @Binding var block: EventBlock?
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay: Bool = false
    @State private var hasEndDate: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datum & Zeit")) {
                    Toggle("Ganztägig", isOn: $isAllDay)
                    DatePicker("Startdatum", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    if !isAllDay {
                        Toggle("Enddatum angeben", isOn: $hasEndDate)
                        if hasEndDate {
                            DatePicker("Enddatum", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                }
            }
            .navigationTitle("Datum bearbeiten")
            .navigationBarItems(trailing: Button("Fertig") {
                if var dateBlock = block, dateBlock.type == .date {
                    dateBlock.startDate = startDate
                    dateBlock.endDate = hasEndDate ? endDate : nil
                    dateBlock.isAllDay = isAllDay
                    block = dateBlock
                }
            })
            .onAppear {
                if let dateBlock = block, dateBlock.type == .date {
                    startDate = dateBlock.startDate ?? Date()
                    endDate = dateBlock.endDate ?? Date()
                    isAllDay = dateBlock.isAllDay
                    hasEndDate = dateBlock.endDate != nil
                }
            }
        }
    }
}

struct DateBlockEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DateBlockEditorView(block: .constant(EventBlock(type: .date, gridSize: CGSize(width: 2, height: 2), startDate: Date(), isAllDay: false)))
    }
}

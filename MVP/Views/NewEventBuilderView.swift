//
//  NewEventBuilderView.swift
//  MVP
//
//  Der modulare Baukasten für die Event-Erstellung.
//  Das Raster (LazyVGrid) zeigt einen sichtbaren, gestrichelten Hintergrund.
//  In der ersten Zeile erscheint ein "Add Block"-Feld, das beim Tippen eine Auswahl an Blocktypen öffnet.
//  Blöcke können per langem Drücken per Drag & Drop verschoben werden.
import SwiftUI

enum EventBlockType: String, CaseIterable, Identifiable {
    case image, date, title, todo, infobox, weather, mediaUpload, mapRoute, subEvents, participants, ticket, linkPreview
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .image: return "Bild/Video"
        case .date: return "Datum"
        case .title: return "Titel"
        case .todo: return "To-Do"
        case .infobox: return "Infobox"
        case .weather: return "Wetter"
        case .mediaUpload: return "Medien"
        case .mapRoute: return "Route"
        case .subEvents: return "Aktivitäten"
        case .participants: return "Teilnehmer"
        case .ticket: return "Ticket"
        case .linkPreview: return "Link"
        }
    }
}

struct EventBlock: Identifiable, Equatable {
    let id = UUID()
    var type: EventBlockType
    var content: String = ""
    var gridSize: CGSize  // z. B. (width: 2, height: 2)
    // Für Datum-Blöcke:
    var startDate: Date? = nil
    var endDate: Date? = nil
    var isAllDay: Bool = false
}

struct NewEventBuilderView: View {
    @State private var blocks: [EventBlock] = [
        // Standard: in der ersten Zeile soll ein Add Block-Feld stehen
        // Hier fügen wir als erstes Element ein spezielles "Add Block" ein.
        EventBlock(type: .image, content: "Add Block", gridSize: CGSize(width: 4, height: 2)),
        // Danach folgen Standardblöcke:
        EventBlock(type: .image, gridSize: CGSize(width: 2, height: 2)),
        EventBlock(type: .date, gridSize: CGSize(width: 2, height: 2), startDate: Date(), isAllDay: false),
        EventBlock(type: .title, content: "Event Titel", gridSize: CGSize(width: 4, height: 1))
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showBlockSelection = false
    @State private var editingBlock: EventBlock? = nil
    @State private var showDateEditor: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(blocks) { block in
                        DraggableBlockView(block: block, blocks: $blocks)
                            .onTapGesture {
                                if block.type == .date {
                                    editingBlock = block
                                    showDateEditor = true
                                } else if block.content == "Add Block" {
                                    showBlockSelection = true
                                }
                            }
                    }
                }
                .padding()
                .overlay(
                    // Sichtbares Raster: gestrichelte Linie
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray)
                )
            }
            .navigationTitle("Event Builder")
            .sheet(isPresented: $showBlockSelection) {
                BlockSelectionView { selectedType in
                    // Füge einen neuen Block hinzu
                    let newBlock = EventBlock(type: selectedType, content: selectedType.displayName, gridSize: defaultGridSize(for: selectedType))
                    blocks.append(newBlock)
                    showBlockSelection = false
                }
            }
            .sheet(isPresented: $showDateEditor, onDismiss: {
                if let edited = editingBlock {
                    updateBlock(edited)
                }
            }) {
                if let _ = editingBlock {
                    DateBlockEditorView(block: $editingBlock)
                } else {
                    Text("No block selected")
                }
            }
        }
    }
    
    func defaultGridSize(for type: EventBlockType) -> CGSize {
        switch type {
        case .image:
            return CGSize(width: 2, height: 2)
        case .date:
            return CGSize(width: 2, height: 2)
        case .title:
            return CGSize(width: 4, height: 1)
        default:
            return CGSize(width: 2, height: 1)
        }
    }
    
    func updateBlock(_ edited: EventBlock) {
        if let index = blocks.firstIndex(of: edited) {
            blocks[index] = edited
        }
    }
}

// DraggableBlockView: Ermöglicht das Verschieben eines Blocks per Drag & Drop (ein simpler Ansatz)
struct DraggableBlockView: View {
    var block: EventBlock
    @Binding var blocks: [EventBlock]
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        EventBlockView(block: block)
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .shadow(radius: isDragging ? 8 : 4)
            .offset(dragOffset)
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .sequenced(before: DragGesture())
                    .onChanged { value in
                        switch value {
                        case .second(true, let drag?):
                            isDragging = true
                            dragOffset = drag.translation
                        default:
                            break
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        withAnimation {
                            reorderBlock(with: dragOffset)
                            dragOffset = .zero
                        }
                    }
            )
    }
    
    func reorderBlock(with offset: CGSize) {
        guard let currentIndex = blocks.firstIndex(of: block) else { return }
        if offset.width > 50, currentIndex < blocks.count - 1 {
            withAnimation {
                blocks.swapAt(currentIndex, currentIndex + 1)
            }
        } else if offset.width < -50, currentIndex > 0 {
            withAnimation {
                blocks.swapAt(currentIndex, currentIndex - 1)
            }
        }
    }
}

// EventBlockView: Darstellung eines Blocks mit 3D‑Effekt und einem dezenten Farbverlauf
struct EventBlockView: View {
    var block: EventBlock
    var body: some View {
        VStack {
            Text(block.type.displayName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            if block.type == .title {
                Text(block.content)
                    .font(.body)
                    .foregroundColor(.white)
            } else if block.type == .date, let start = block.startDate {
                Text("Start: \(start, formatter: dateFormatter)")
                    .font(.caption2)
                    .foregroundColor(.white)
            } else {
                Text(block.content)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("#204039"), Color("#f7b32b")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 4)
        .rotation3DEffect(.degrees(5), axis: (x: 1, y: 0, z: 0))
    }
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }
}

// BlockSelectionView: Zeigt eine Auswahl an Blocktypen, wenn "Add Block" angetippt wird.
struct BlockSelectionView: View {
    var onSelect: (EventBlockType) -> Void
    var body: some View {
        NavigationView {
            List(EventBlockType.allCases) { type in
                Button(action: { onSelect(type) }) {
                    Text(type.displayName)
                }
            }
            .navigationTitle("Blocktyp auswählen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                // Dismiss action in der Sheet-Umgebung
            })
        }
    }
}

struct NewEventBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventBuilderView()
    }
}

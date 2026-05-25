import SwiftUI
import SwiftData

struct TagsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Query private var sessions: [PomodoroSession]
    @State private var newTagName = ""
    @State private var selectedColorHex = Tag.defaultColors.first ?? "#FF6B6B"
    @State private var showingAddTag = false

    var body: some View {
        List {
            ForEach(tags, id: \.id) { tag in
                HStack {
                    Circle()
                        .fill(tag.color)
                        .frame(width: 12, height: 12)

                    Text(tag.name)

                    Spacer()

                    Text("\(sessionsCount(for: tag.id))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: deleteTags)
        }
        .navigationTitle("Etiquetas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTag = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Nueva etiqueta", isPresented: $showingAddTag) {
            TextField("Nombre", text: $newTagName)

            HStack {
                ForEach(Tag.defaultColors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color) ?? .red)
                        .frame(width: 28, height: 28)
                        .overlay {
                            if color == selectedColorHex {
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                                Circle()
                                    .strokeBorder(Color(hex: color) ?? .red, lineWidth: 2)
                            }
                        }
                        .onTapGesture { selectedColorHex = color }
                }
            }
            .padding(.vertical, 4)

            Button("Cancelar", role: .cancel) {
                newTagName = ""
            }
            Button("Guardar") {
                addTag()
            }
        }
    }

    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let tag = Tag(name: name, colorHex: selectedColorHex)
        modelContext.insert(tag)
        newTagName = ""
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tags[index])
        }
    }

    private func sessionsCount(for tagID: UUID) -> Int {
        sessions.filter { $0.tagID == tagID }.count
    }
}

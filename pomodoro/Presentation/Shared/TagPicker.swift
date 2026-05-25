import SwiftUI
import SwiftData

struct TagPicker: View {
    @Query(sort: \Tag.name) var tags: [Tag]
    @Binding var selectedTag: Tag?

    var body: some View {
        Menu {
            Button("Sin etiqueta") {
                selectedTag = nil
            }

            Divider()

            ForEach(tags) { tag in
                Button {
                    selectedTag = tag
                } label: {
                    HStack {
                        Circle().fill(tag.color).frame(width: 12, height: 12)
                        Text(tag.name)
                        if selectedTag?.id == tag.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let tag = selectedTag {
                    Circle().fill(tag.color).frame(width: 8, height: 8)
                    Text(tag.name)
                } else {
                    Image(systemName: "tag")
                    Text("Etiqueta")
                }
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

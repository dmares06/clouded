import SwiftUI

struct NotesView: View {
    @ObservedObject var dataStore: DataStore
    @State private var editingID: UUID?
    @State private var editText = ""
    @State private var expandedNoteIDs: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Text("Notes")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(CloudTheme.gradient)
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            let note = dataStore.addNote()
                            editingID = note.id
                            editText = ""
                        }
                    }
            }

            if dataStore.notes.isEmpty {
                Text("Tap + to jot something down")
                    .font(.system(size: 11))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(dataStore.notes) { note in
                            noteRow(note)
                        }
                    }
                }
            }
        }
    }

    private func noteRow(_ note: NoteItem) -> some View {
        let isExpanded = expandedNoteIDs.contains(note.id)
        let isEditing = editingID == note.id

        return VStack(alignment: .leading, spacing: 0) {
            if isEditing {
                HStack(spacing: 6) {
                    TextField("Type a note...", text: $editText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .lineLimit(1...8)
                        .onSubmit {
                            dataStore.updateNote(note, content: editText)
                            editingID = nil
                        }

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(CloudTheme.checkGreen)
                        .onTapGesture {
                            dataStore.updateNote(note, content: editText)
                            editingID = nil
                        }
                }
            } else {
                HStack(alignment: .top, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.content.isEmpty ? "Empty note" : note.content)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(note.content.isEmpty ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                            .lineLimit(isExpanded ? nil : 1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isExpanded {
                            Text(note.updatedAt, style: .relative)
                                .font(.system(size: 9))
                                .foregroundStyle(CloudTheme.textSecondary)
                                .padding(.top, 2)

                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 9, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundStyle(CloudTheme.accentBlue)
                            .padding(.top, 4)
                            .onTapGesture {
                                editingID = note.id
                                editText = note.content
                            }
                        }
                    }

                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(CloudTheme.accentBlue.opacity(0.4))
                        .onTapGesture {
                            withAnimation(CloudTheme.springAnimation) {
                                dataStore.deleteNote(note)
                            }
                        }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(CloudTheme.springAnimation) {
                        if isExpanded {
                            expandedNoteIDs.remove(note.id)
                        } else {
                            expandedNoteIDs.insert(note.id)
                        }
                    }
                }
            }
        }
        .padding(7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke((isExpanded || isEditing) ? CloudTheme.accentBlue.opacity(0.3) : CloudTheme.borderBlue, lineWidth: 1)
        )
    }
}

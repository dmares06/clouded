import SwiftUI

struct BrainDumpView: View {
    @ObservedObject var dataStore: DataStore
    @StateObject private var speechManager = SpeechManager()
    @State private var manualText = ""
    @State private var openDumpID: UUID?
    @FocusState private var textFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Input area (always visible at top)
            inputSection

            // List or detail
            if let dumpID = openDumpID,
               let dump = dataStore.brainDumps.first(where: { $0.id == dumpID }) {
                dumpDetailView(dump)
            } else {
                dumpListView
            }
        }
        .onAppear {
            speechManager.onTranscriptReady = { text in
                withAnimation(CloudTheme.springAnimation) {
                    dataStore.addBrainDump(rawText: text)
                }
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 6) {
            // Voice record button
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(speechManager.isRecording
                              ? Color.red.opacity(0.15)
                              : CloudTheme.accentBlue.opacity(0.1))
                        .frame(width: 32, height: 32)

                    if speechManager.isRecording {
                        Circle()
                            .stroke(Color.red.opacity(0.4), lineWidth: 2)
                            .frame(width: 38, height: 38)
                            .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                            .opacity(speechManager.isRecording ? 0.0 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: speechManager.isRecording)
                            .allowsHitTesting(false)
                    }

                    Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(speechManager.isRecording ? .red : CloudTheme.accentBlue)
                }
                .frame(width: 38, height: 38)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !speechManager.isAuthorized {
                        speechManager.requestPermission()
                    } else {
                        speechManager.toggleRecording()
                    }
                }

                if speechManager.isRecording {
                    Text("Listening...")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.red)
                } else {
                    Text(speechManager.isAuthorized ? "Tap to talk or type below" : "Tap mic to enable voice")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(CloudTheme.textSecondary)
                }

                Spacer()
            }

            // Live transcript
            if speechManager.isRecording && !speechManager.transcript.isEmpty {
                Text(speechManager.transcript)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(7)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(CloudTheme.accentBlue.opacity(0.3), lineWidth: 1)
                    )
            }

            // Text input
            HStack(spacing: 6) {
                TextField("Type your thoughts...", text: $manualText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .lineLimit(1...4)
                    .focused($textFocused)
                    .onSubmit { saveDump() }

                if !currentText.isEmpty {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(CloudTheme.gradient)
                        .contentShape(Circle())
                        .onTapGesture { saveDump() }
                }
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(textFocused ? CloudTheme.accentBlue : CloudTheme.borderBlue, lineWidth: 1)
            )
        }
    }

    // MARK: - Dump List

    private var dumpListView: some View {
        Group {
            if dataStore.brainDumps.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
                        .foregroundStyle(CloudTheme.gradient)
                    Text("No brain dumps yet")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(CloudTheme.textSecondary)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(dataStore.brainDumps) { dump in
                            dumpRow(dump)
                        }
                    }
                }
            }
        }
    }

    private func dumpRow(_ dump: BrainDump) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 12))
                .foregroundStyle(CloudTheme.gradient)

            VStack(alignment: .leading, spacing: 1) {
                Text(dump.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .lineLimit(1)

                Text(formatDate(dump.createdAt))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
            }

            Spacer()

            if !dump.structuredItems.isEmpty {
                Text("\(dump.structuredItems.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(CloudTheme.accentBlue)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(CloudTheme.accentBlue.opacity(0.1))
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(CloudTheme.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(CloudTheme.springAnimation) {
                openDumpID = dump.id
            }
        }
    }

    // MARK: - Dump Detail

    private func dumpDetailView(_ dump: BrainDump) -> some View {
        VStack(spacing: 6) {
            // Back button
            HStack {
                Button {
                    withAnimation(CloudTheme.springAnimation) {
                        openDumpID = nil
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 9, weight: .bold))
                        Text("All Dumps")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(CloudTheme.accentBlue)
                }
                .buttonStyle(.plain)

                Spacer()

                // Delete
                Image(systemName: "trash")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.6))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            openDumpID = nil
                            dataStore.deleteBrainDump(dump)
                        }
                    }
            }

            // Title + timestamp
            VStack(alignment: .leading, spacing: 2) {
                Text(dump.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(formatDate(dump.createdAt))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(CloudTheme.borderBlue, lineWidth: 1)
            )

            // Structured items or raw text
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    if !dump.structuredItems.isEmpty {
                        ForEach(Array(dump.structuredItems.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 6) {
                                Circle()
                                    .fill(CloudTheme.primaryBlue)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 5)

                                Text(item)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(CloudTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Convert to task
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 11))
                                    .foregroundStyle(CloudTheme.accentBlue)
                                    .contentShape(Circle())
                                    .onTapGesture {
                                        withAnimation(CloudTheme.springAnimation) {
                                            dataStore.convertDumpItemToTask(item)
                                        }
                                    }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(CloudTheme.borderBlue, lineWidth: 1)
                            )
                        }
                    } else {
                        Text(dump.rawText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(CloudTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(CloudTheme.borderBlue, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var currentText: String {
        if !speechManager.transcript.isEmpty { return speechManager.transcript }
        return manualText
    }

    private func saveDump() {
        // If recording, stop it — the callback will auto-save the transcript
        if speechManager.isRecording {
            speechManager.stopRecording()
            manualText = ""
            return
        }

        // Otherwise save manual text
        let text = manualText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        withAnimation(CloudTheme.springAnimation) {
            dataStore.addBrainDump(rawText: text)
            manualText = ""
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        }
        return formatter.string(from: date)
    }
}

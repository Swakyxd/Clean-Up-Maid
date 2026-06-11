import SwiftUI

/// The main control window: pick your maid, pick a duration, start cleaning.
struct ContentView: View {
    @ObservedObject var controller = LockController.shared
    @AppStorage("selectedMaid") private var selectedMaidID = "sakura"
    @State private var selectedMinutes = 1.0

    private var character: MaidCharacter { .named(selectedMaidID) }

    private let durations: [(label: String, minutes: Double)] = [
        ("30 sec", 0.5),
        ("1 min", 1),
        ("2 min", 2),
        ("5 min", 5),
    ]

    var body: some View {
        VStack(spacing: 20) {
            MaidView(character: character)
                .scaleEffect(0.62)
                .frame(width: 230, height: 260)
                .id(selectedMaidID)

            Text("CleanUpMaid")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("Lock your keyboard, trackpad & mouse\nso you can clean without the chaos.")
                .font(.system(size: 14, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            // Character picker
            HStack(spacing: 18) {
                ForEach(MaidCharacter.all) { c in
                    Button {
                        selectedMaidID = c.id
                    } label: {
                        VStack(spacing: 5) {
                            ZStack {
                                Circle().fill(c.hair).frame(width: 36, height: 36)
                                // Tiny headband frill
                                HStack(spacing: 1) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        Circle().fill(.white).frame(width: 7, height: 7)
                                    }
                                }
                                .offset(y: -13)
                            }
                            .overlay(
                                Circle().stroke(
                                    c.id == selectedMaidID ? c.accent : .clear,
                                    lineWidth: 3
                                )
                            )
                            Text(c.name)
                                .font(.system(
                                    size: 11,
                                    weight: c.id == selectedMaidID ? .bold : .regular,
                                    design: .rounded
                                ))
                                .foregroundStyle(c.id == selectedMaidID ? .primary : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Picker("Duration", selection: $selectedMinutes) {
                ForEach(durations, id: \.minutes) { d in
                    Text(d.label).tag(d.minutes)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 280)

            Button {
                controller.startLock(duration: selectedMinutes * 60)
            } label: {
                Label("Start Cleaning", systemImage: "sparkles")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(width: 220, height: 30)
            }
            .buttonStyle(.borderedProminent)
            .tint(character.accent)

            Text("Unlock early anytime by typing  M · A · I · D")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(30)
        .frame(width: 380)
    }
}

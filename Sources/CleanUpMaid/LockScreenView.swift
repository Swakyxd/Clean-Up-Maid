import SwiftUI

/// Fullscreen overlay shown while input is locked.
struct LockScreenView: View {
    @ObservedObject var controller: LockController
    @AppStorage("selectedMaid") private var selectedMaidID = "sakura"

    private var character: MaidCharacter { .named(selectedMaidID) }
    private let letters = ["M", "A", "I", "D"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.05, blue: 0.12),
                    Color(red: 0.16, green: 0.09, blue: 0.2),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Cleaning in progress…")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                MaidView(character: character)

                Text("「 \(character.catchphrase) 」")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .italic()
                    .foregroundStyle(character.accent)

                Text(timeString)
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.98, green: 0.62, blue: 0.72))

                Text("Keyboard & trackpad are locked — wipe away! 🧽")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                VStack(spacing: 10) {
                    Text("Type to unlock early:")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))

                    HStack(spacing: 14) {
                        ForEach(letters.indices, id: \.self) { i in
                            Text(letters[i])
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .frame(width: 54, height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(i < controller.unlockProgress
                                              ? Color(red: 0.98, green: 0.62, blue: 0.72)
                                              : .white.opacity(0.12))
                                )
                                .foregroundStyle(i < controller.unlockProgress ? .black : .white.opacity(0.85))
                                .animation(.spring(duration: 0.3), value: controller.unlockProgress)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private var timeString: String {
        let s = max(controller.secondsRemaining, 0)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

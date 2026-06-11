import SwiftUI

// MARK: - Characters

struct MaidCharacter: Identifiable, Equatable {
    enum Hairstyle { case twinTails, longStraight, bob }

    let id: String
    let name: String
    let catchphrase: String
    let hair: Color
    let eyes: Color
    let dress: Color
    let accent: Color
    let hairstyle: Hairstyle

    static let all: [MaidCharacter] = [
        MaidCharacter(
            id: "sakura", name: "Sakura",
            catchphrase: "Dust bunnies, begone~! ✨",
            hair: Color(red: 0.99, green: 0.66, blue: 0.76),
            eyes: Color(red: 0.18, green: 0.68, blue: 0.45),
            dress: Color(red: 0.16, green: 0.16, blue: 0.22),
            accent: Color(red: 0.95, green: 0.4, blue: 0.58),
            hairstyle: .twinTails
        ),
        MaidCharacter(
            id: "rei", name: "Rei",
            catchphrase: "Cleaning protocol… engaged.",
            hair: Color(red: 0.85, green: 0.87, blue: 0.93),
            eyes: Color(red: 0.45, green: 0.7, blue: 0.95),
            dress: Color(red: 0.19, green: 0.2, blue: 0.3),
            accent: Color(red: 0.6, green: 0.65, blue: 0.95),
            hairstyle: .longStraight
        ),
        MaidCharacter(
            id: "hana", name: "Hana",
            catchphrase: "Ehehe~ let's make it sparkle!",
            hair: Color(red: 0.45, green: 0.29, blue: 0.18),
            eyes: Color(red: 0.85, green: 0.6, blue: 0.2),
            dress: Color(red: 0.13, green: 0.13, blue: 0.16),
            accent: Color(red: 0.9, green: 0.33, blue: 0.33),
            hairstyle: .bob
        ),
        MaidCharacter(
            id: "miyu", name: "Miyu",
            catchphrase: "Leave it to me, goshujin-sama!",
            hair: Color(red: 0.72, green: 0.6, blue: 0.92),
            eyes: Color(red: 0.58, green: 0.4, blue: 0.9),
            dress: Color(red: 0.22, green: 0.16, blue: 0.28),
            accent: Color(red: 0.85, green: 0.5, blue: 0.9),
            hairstyle: .twinTails
        ),
    ]

    static func named(_ id: String) -> MaidCharacter {
        all.first { $0.id == id } ?? all[0]
    }
}

// MARK: - Maid view

/// An anime-style maid: big gradient eyes that blink, character-specific
/// hairstyle, bobbing gently while sweeping a feather duster back and forth.
struct MaidView: View {
    var character: MaidCharacter = .all[0]

    @State private var sweeping = false
    @State private var bobbing = false
    @State private var blink = false

    var body: some View {
        ZStack {
            SparkleField()

            maidBody
                .offset(y: bobbing ? -8 : 8)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bobbing)
        }
        .frame(width: 360, height: 420)
        .onAppear {
            sweeping = true
            bobbing = true
        }
        .task {
            // Occasional blink
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64.random(in: 2_400...4_200) * 1_000_000)
                withAnimation(.easeIn(duration: 0.06)) { blink = true }
                try? await Task.sleep(nanoseconds: 130_000_000)
                withAnimation(.easeOut(duration: 0.09)) { blink = false }
            }
        }
    }

    private var maidBody: some View {
        ZStack {
            // Hairstyle layers that sit behind the body
            if character.hairstyle == .longStraight {
                RoundedRectangle(cornerRadius: 55)
                    .fill(character.hair)
                    .frame(width: 150, height: 250)
                    .offset(y: 30)
            }
            if character.hairstyle == .twinTails {
                twinTail(side: -1)
                twinTail(side: 1)
            }

            // Dress
            DressShape()
                .fill(character.dress)
                .frame(width: 190, height: 170)
                .offset(y: 110)

            // Apron
            DressShape()
                .fill(.white)
                .frame(width: 110, height: 130)
                .offset(y: 125)

            // Apron waist bow
            Circle().fill(.white).frame(width: 26, height: 26).offset(x: -18, y: 62)
            Circle().fill(.white).frame(width: 26, height: 26).offset(x: 18, y: 62)
            Circle().fill(character.accent).frame(width: 14, height: 14).offset(y: 62)

            // Left arm (resting)
            Capsule()
                .fill(character.dress)
                .frame(width: 22, height: 80)
                .rotationEffect(.degrees(30), anchor: .top)
                .offset(x: -75, y: 70)

            // Right arm + feather duster, sweeping together
            duster
                .rotationEffect(.degrees(sweeping ? 18 : -22), anchor: .init(x: 0.3, y: 0.2))
                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: sweeping)
                .offset(x: 70, y: 60)

            // Hair behind head
            Ellipse()
                .fill(character.hair)
                .frame(width: character.hairstyle == .bob ? 146 : 130,
                       height: character.hairstyle == .bob ? 138 : 140)
                .offset(y: character.hairstyle == .bob ? -56 : -60)

            // Face
            Circle()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.78))
                .frame(width: 100, height: 100)
                .offset(y: -50)

            // Bangs
            HairBangs()
                .fill(character.hair)
                .frame(width: 104, height: 46)
                .offset(y: -82)

            // Side strands framing the face
            if character.hairstyle == .longStraight {
                Capsule().fill(character.hair).frame(width: 22, height: 105).offset(x: -50, y: -28)
                Capsule().fill(character.hair).frame(width: 22, height: 105).offset(x: 50, y: -28)
            }
            if character.hairstyle == .bob {
                Capsule().fill(character.hair).frame(width: 20, height: 62).offset(x: -52, y: -48)
                Capsule().fill(character.hair).frame(width: 20, height: 62).offset(x: 52, y: -48)
                AhogeShape()
                    .stroke(character.hair, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 30, height: 26)
                    .offset(x: 6, y: -124)
            }

            // Frilly headband
            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { _ in
                    Circle().fill(.white).frame(width: 16, height: 16)
                }
            }
            .offset(y: -102)

            // Big anime eyes
            animeEye(x: -22)
            animeEye(x: 22)

            // Eyebrows
            HappyEye().stroke(.black.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 16, height: 5).offset(x: -22, y: -74)
            HappyEye().stroke(.black.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 16, height: 5).offset(x: 22, y: -74)

            // Blush
            Ellipse().fill(Color(red: 1.0, green: 0.7, blue: 0.75).opacity(0.7))
                .frame(width: 18, height: 10).offset(x: -36, y: -36)
            Ellipse().fill(Color(red: 1.0, green: 0.7, blue: 0.75).opacity(0.7))
                .frame(width: 18, height: 10).offset(x: 36, y: -36)

            // Smile
            SmileShape().stroke(.black, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 22, height: 10).offset(y: -28)

            // Collar
            Circle().fill(.white).frame(width: 30, height: 30).offset(y: 8)
        }
    }

    private func animeEye(x: CGFloat) -> some View {
        ZStack {
            // Sclera
            Ellipse().fill(.white).frame(width: 22, height: 25)
            // Iris with vertical gradient
            Ellipse()
                .fill(LinearGradient(
                    colors: [character.eyes, character.eyes.opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 17, height: 21)
                .offset(y: 1)
            // Pupil
            Ellipse().fill(.black.opacity(0.85)).frame(width: 8, height: 11).offset(y: 2)
            // Highlights
            Circle().fill(.white).frame(width: 6.5, height: 6.5).offset(x: -3.5, y: -4)
            Circle().fill(.white.opacity(0.85)).frame(width: 3, height: 3).offset(x: 4, y: 5)
            // Upper lash line
            HappyEye().stroke(.black, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: 25, height: 7).offset(y: -11)
        }
        .scaleEffect(y: blink ? 0.06 : 1)
        .offset(x: x, y: -52)
    }

    private func twinTail(side: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(character.hair)
                .frame(width: 36, height: 165)
            // Inner shading strand
            Capsule()
                .fill(.black.opacity(0.08))
                .frame(width: 12, height: 138)
                .offset(x: side * -8)
            // Scrunchie
            Circle().fill(character.accent).frame(width: 16, height: 16).offset(y: -74)
        }
        .rotationEffect(.degrees(Double(side) * (bobbing ? 13 : 7)), anchor: .top)
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bobbing)
        .offset(x: side * 78, y: -18)
    }

    private var duster: some View {
        ZStack {
            // Arm
            Capsule()
                .fill(character.dress)
                .frame(width: 22, height: 75)
                .rotationEffect(.degrees(-35), anchor: .top)
                .offset(x: 12, y: 10)

            // Handle
            Capsule()
                .fill(Color(red: 0.55, green: 0.4, blue: 0.28))
                .frame(width: 9, height: 110)
                .rotationEffect(.degrees(-35))
                .offset(x: 48, y: -20)

            // Feathers
            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .fill(character.accent.opacity(0.9))
                    .frame(width: 22, height: 52)
                    .rotationEffect(.degrees(Double(i - 2) * 18 - 35))
                    .offset(x: 78 + CGFloat(i - 2) * 7, y: -68)
            }
        }
    }
}

// MARK: - Custom shapes

struct DressShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + rect.width * 0.18, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX + rect.width * 0.42, y: rect.midY)
        )
        // Scalloped hem
        let scallops = 5
        let step = rect.width / CGFloat(scallops)
        for i in stride(from: scallops - 1, through: 0, by: -1) {
            let x = rect.minX + step * CGFloat(i)
            p.addQuadCurve(
                to: CGPoint(x: x, y: rect.maxY),
                control: CGPoint(x: x + step / 2, y: rect.maxY - 12)
            )
        }
        p.addQuadCurve(
            to: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.minY),
            control: CGPoint(x: rect.midX - rect.width * 0.42, y: rect.midY)
        )
        return p
    }
}

struct HairBangs: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.4))
        p.addQuadCurve(to: CGPoint(x: rect.midX + rect.width * 0.2, y: rect.maxY - 4),
                       control: CGPoint(x: rect.midX + rect.width * 0.32, y: rect.maxY + 8))
        p.addQuadCurve(to: CGPoint(x: rect.midX - rect.width * 0.2, y: rect.maxY - 4),
                       control: CGPoint(x: rect.midX, y: rect.maxY + 10))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                       control: CGPoint(x: rect.midX - rect.width * 0.32, y: rect.maxY + 8))
        return p
    }
}

/// The little gravity-defying strand of hair on top of a bob cut.
struct AhogeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                       control: CGPoint(x: rect.minX - rect.width * 0.2, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

struct HappyEye: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height))
        return p
    }
}

struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.midX, y: rect.maxY + rect.height))
        return p
    }
}

// MARK: - Sparkles

struct SparkleField: View {
    private struct Sparkle: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let delay: Double
        let symbol: String
    }

    private let sparkles: [Sparkle] = (0..<10).map { i in
        Sparkle(
            id: i,
            x: CGFloat.random(in: -160...160),
            y: CGFloat.random(in: -190...190),
            size: CGFloat.random(in: 14...30),
            delay: Double.random(in: 0...2),
            symbol: ["✨", "🫧", "✨", "💫"].randomElement()!
        )
    }

    @State private var twinkle = false

    var body: some View {
        ZStack {
            ForEach(sparkles) { s in
                Text(s.symbol)
                    .font(.system(size: s.size))
                    .opacity(twinkle ? 0.9 : 0.15)
                    .scaleEffect(twinkle ? 1.0 : 0.6)
                    .offset(x: s.x, y: s.y)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(s.delay),
                        value: twinkle
                    )
            }
        }
        .onAppear { twinkle = true }
    }
}

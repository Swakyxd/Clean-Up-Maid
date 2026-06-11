// Renders the CleanUpMaid app icon (Sakura's face on a plum squircle) to icon_1024.png.
// Run with: swift scripts/generate-icon.swift
import AppKit

let size = 1024

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// Palette
let hair = NSColor(red: 0.99, green: 0.66, blue: 0.76, alpha: 1)
let hairShade = NSColor(red: 0.93, green: 0.55, blue: 0.67, alpha: 1)
let skin = NSColor(red: 1.0, green: 0.88, blue: 0.78, alpha: 1)
let accent = NSColor(red: 0.95, green: 0.4, blue: 0.58, alpha: 1)
let eyeGreen = NSColor(red: 0.18, green: 0.68, blue: 0.45, alpha: 1)
let blushPink = NSColor(red: 1.0, green: 0.6, blue: 0.68, alpha: 0.75)

func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)).fill()
}

func capsule(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h),
                 xRadius: w / 2, yRadius: w / 2).fill()
}

func arc(_ cx: CGFloat, _ cy: CGFloat, radius: CGFloat, from: CGFloat, to: CGFloat,
         width: CGFloat, _ color: NSColor) {
    let p = NSBezierPath()
    p.appendArc(withCenter: CGPoint(x: cx, y: cy), radius: radius,
                startAngle: from, endAngle: to)
    p.lineWidth = width
    p.lineCapStyle = .round
    color.setStroke()
    p.stroke()
}

func sparkle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ color: NSColor) {
    let p = NSBezierPath()
    p.move(to: CGPoint(x: cx, y: cy + r))
    p.curve(to: CGPoint(x: cx + r, y: cy),
            controlPoint1: CGPoint(x: cx + r * 0.12, y: cy + r * 0.12),
            controlPoint2: CGPoint(x: cx + r * 0.12, y: cy + r * 0.12))
    p.curve(to: CGPoint(x: cx, y: cy - r),
            controlPoint1: CGPoint(x: cx + r * 0.12, y: cy - r * 0.12),
            controlPoint2: CGPoint(x: cx + r * 0.12, y: cy - r * 0.12))
    p.curve(to: CGPoint(x: cx - r, y: cy),
            controlPoint1: CGPoint(x: cx - r * 0.12, y: cy - r * 0.12),
            controlPoint2: CGPoint(x: cx - r * 0.12, y: cy - r * 0.12))
    p.curve(to: CGPoint(x: cx, y: cy + r),
            controlPoint1: CGPoint(x: cx - r * 0.12, y: cy + r * 0.12),
            controlPoint2: CGPoint(x: cx - r * 0.12, y: cy + r * 0.12))
    p.close()
    color.setFill()
    p.fill()
}

// --- Squircle background (everything clips to it) ---
let bgRect = CGRect(x: 64, y: 64, width: 896, height: 896)
NSBezierPath(roundedRect: bgRect, xRadius: 200, yRadius: 200).addClip()
NSGradient(colors: [
    NSColor(red: 0.33, green: 0.21, blue: 0.42, alpha: 1),
    NSColor(red: 0.12, green: 0.09, blue: 0.19, alpha: 1),
])!.draw(in: bgRect, angle: -90)

// --- Twin tails ---
capsule(182, 430, 125, 390, hair)
capsule(842, 430, 125, 390, hair)
capsule(182, 430, 40, 330, hairShade)
capsule(842, 430, 40, 330, hairShade)
ellipse(182, 600, 64, 64, accent)
ellipse(842, 600, 64, 64, accent)

// --- Hair behind face (top crescent shows as bangs) ---
ellipse(512, 545, 600, 600, hair)

// --- Face ---
ellipse(512, 478, 495, 495, skin)

// --- Headband frills along the hair arc ---
for angle in [55.0, 72.5, 90.0, 107.5, 125.0] {
    let rad = angle * .pi / 180
    let x = 512 + 305 * CGFloat(cos(rad))
    let y = 545 + 305 * CGFloat(sin(rad))
    ellipse(x, y, 78, 78, .white)
}

// --- Eyes ---
for sideX in [412.0, 612.0] {
    let cx = CGFloat(sideX)
    ellipse(cx, 460, 108, 128, .white)
    ellipse(cx, 455, 82, 102, eyeGreen)
    ellipse(cx, 452, 38, 54, .black)
    ellipse(cx - 16, 488, 30, 30, .white)
    ellipse(cx + 18, 428, 14, 14, NSColor.white.withAlphaComponent(0.9))
    arc(cx, 452, radius: 62, from: 35, to: 145, width: 17, .black)
}

// --- Blush ---
ellipse(345, 388, 80, 38, blushPink)
ellipse(679, 388, 80, 38, blushPink)

// --- Smile ---
arc(512, 392, radius: 44, from: 205, to: 335, width: 15, .black)

// --- Sparkles ---
sparkle(205, 805, 52, NSColor.white.withAlphaComponent(0.95))
sparkle(835, 770, 36, NSColor.white.withAlphaComponent(0.85))
sparkle(800, 195, 46, NSColor.white.withAlphaComponent(0.9))
sparkle(225, 215, 30, NSColor.white.withAlphaComponent(0.8))

NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
let out = URL(fileURLWithPath: "icon_1024.png")
try! png.write(to: out)
print("Wrote \(out.path)")

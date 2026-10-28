// Draws the "Download for Mac / Windows" buttons used in the READMEs, in English and Portuguese.
// Usage: swift Tools/download-buttons.swift   (writes docs/images/download-*.png)
import AppKit

let root = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().deletingLastPathComponent()
let images = root.appendingPathComponent("docs/images")

// Brand colors (the same as in Branding/README.md).
let blueTop = NSColor(srgbRed: 0x3B / 255, green: 0x62 / 255, blue: 0xF4 / 255, alpha: 1)    // #3B62F4
let blueBottom = NSColor(srgbRed: 0x28 / 255, green: 0x45 / 255, blue: 0xC9 / 255, alpha: 1) // #2845C9
let cyan = NSColor(srgbRed: 0x7F / 255, green: 0xE3 / 255, blue: 0xFF / 255, alpha: 1)       // #7FE3FF

struct Button {
    let file: String
    let title: String
    let subtitle: String
}

let buttons = [
    Button(file: "download-mac", title: "Download for Mac", subtitle: "macOS 14 or later · free"),
    Button(file: "download-mac-pt-BR", title: "Baixar para Mac", subtitle: "macOS 14 ou mais novo · grátis"),
    Button(file: "download-windows", title: "Download for Windows", subtitle: "Windows 10 and 11 · free"),
    Button(file: "download-windows-pt-BR", title: "Baixar para Windows", subtitle: "Windows 10 e 11 · grátis"),
]

let titleFont = NSFont.systemFont(ofSize: 19, weight: .bold)
let subtitleFont = NSFont.systemFont(ofSize: 13, weight: .medium)
let titleStyle: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: NSColor.white]
let subtitleStyle: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: cyan]
let icon = NSImage(contentsOf: root.appendingPathComponent("Branding/quadra-icon-1024.png"))!

// Every button gets the same size, so they line up side by side.
let textWidth = buttons.map { max(($0.title as NSString).size(withAttributes: titleStyle).width,
                                  ($0.subtitle as NSString).size(withAttributes: subtitleStyle).width) }.max()!
let size = CGSize(width: (14 + 40 + 12 + textWidth + 18 + 30 + 16).rounded(.up), height: 64)
let scale = 2

for button in buttons {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width) * scale,
                               pixelsHigh: Int(size.height) * scale, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let shape = NSBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 1, dy: 1),
                             xRadius: 14, yRadius: 14)
    NSGradient(starting: blueTop, ending: blueBottom)!.draw(in: shape, angle: -90)
    NSColor.white.withAlphaComponent(0.22).setStroke()
    shape.lineWidth = 1
    shape.stroke()

    // The Quadra icon on the left, with a soft shadow so it stands out from the blue.
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
    shadow.shadowBlurRadius = 4
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    shadow.set()
    icon.draw(in: CGRect(x: 14, y: 12, width: 40, height: 40))
    NSGraphicsContext.restoreGraphicsState()

    (button.title as NSString).draw(at: CGPoint(x: 66, y: 29), withAttributes: titleStyle)
    (button.subtitle as NSString).draw(at: CGPoint(x: 66, y: 12), withAttributes: subtitleStyle)

    // A download arrow in a light circle on the right.
    let circle = CGRect(x: size.width - 16 - 30, y: 17, width: 30, height: 30)
    NSColor.white.withAlphaComponent(0.2).setFill()
    NSBezierPath(ovalIn: circle).fill()
    let arrow = NSBezierPath()
    arrow.move(to: CGPoint(x: circle.midX, y: circle.maxY - 8))
    arrow.line(to: CGPoint(x: circle.midX, y: circle.minY + 8))
    arrow.move(to: CGPoint(x: circle.midX - 6, y: circle.minY + 14))
    arrow.line(to: CGPoint(x: circle.midX, y: circle.minY + 8))
    arrow.line(to: CGPoint(x: circle.midX + 6, y: circle.minY + 14))
    arrow.lineWidth = 2.4
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    NSColor.white.setStroke()
    arrow.stroke()

    NSGraphicsContext.restoreGraphicsState()
    let url = images.appendingPathComponent("\(button.file).png")
    try! rep.representation(using: .png, properties: [:])!.write(to: url)
    print("\(url.lastPathComponent)  \(Int(size.width)) × \(Int(size.height)) points")
}

#!/usr/bin/swift
// Generates Blurt app icon PNGs in all required macOS sizes.
// Run: swift scripts/generate-icon.swift <output-dir>
import AppKit
import CoreGraphics

func makeIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    defer { image.unlockFocus() }

    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }

    let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
    let radius = size * 0.22

    // Rounded-rect clip
    let clipPath = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(clipPath)
    ctx.clip()

    // Background gradient: deep indigo → medium purple
    let bgColors = [
        CGColor(red: 0x10/255.0, green: 0x0A/255.0, blue: 0x28/255.0, alpha: 1),
        CGColor(red: 0x4A/255.0, green: 0x35/255.0, blue: 0x9C/255.0, alpha: 1),
    ] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let bgGrad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0, 1]) else { return image }
    ctx.drawLinearGradient(bgGrad,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: [])

    // Waveform bars — 7 bars with a symmetric height profile
    let barHeightRatios: [CGFloat] = [0.28, 0.52, 0.72, 1.0, 0.72, 0.52, 0.28]
    let barCount = CGFloat(barHeightRatios.count)
    let barW = size * 0.058
    let barGap = size * 0.038
    let totalW = barCount * barW + (barCount - 1) * barGap
    let originX = (size - totalW) / 2
    let maxBarH = size * 0.42
    let centerY = size * 0.5

    let barColors = [
        CGColor(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0, alpha: 1),
        CGColor(red: 0xBE/255.0, green: 0x9E/255.0, blue: 0xFF/255.0, alpha: 1),
    ] as CFArray
    guard let barGrad = CGGradient(colorsSpace: colorSpace, colors: barColors, locations: [0, 1]) else { return image }

    for (i, ratio) in barHeightRatios.enumerated() {
        let bh = maxBarH * ratio
        let bx = originX + CGFloat(i) * (barW + barGap)
        let by = centerY - bh / 2
        let br = barW / 2
        let barRect = CGRect(x: bx, y: by, width: barW, height: bh)
        let barPath = CGPath(roundedRect: barRect, cornerWidth: br, cornerHeight: br, transform: nil)
        ctx.saveGState()
        ctx.addPath(barPath)
        ctx.clip()
        ctx.drawLinearGradient(barGrad,
            start: CGPoint(x: bx, y: by),
            end: CGPoint(x: bx, y: by + bh),
            options: [])
        ctx.restoreGState()
    }

    return image
}

let outputDir: String
if CommandLine.arguments.count > 1 {
    outputDir = CommandLine.arguments[1]
} else {
    let url = URL(fileURLWithPath: #file).deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Blurt/Resources/Assets.xcassets/AppIcon.appiconset")
    outputDir = url.path
}

// (size, scale, idiom) → filename
let specs: [(size: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2),
]

for spec in specs {
    let px = spec.size * spec.scale
    let filename = spec.scale == 1
        ? "icon_\(spec.size)x\(spec.size).png"
        : "icon_\(spec.size)x\(spec.size)@\(spec.scale)x.png"
    let img = makeIcon(size: CGFloat(px))
    guard let tiff = img.tiffRepresentation,
          let bmp  = NSBitmapImageRep(data: tiff),
          let png  = bmp.representation(using: .png, properties: [:]) else {
        fputs("Failed: \(filename)\n", stderr)
        continue
    }
    let dest = URL(fileURLWithPath: outputDir).appendingPathComponent(filename)
    try? png.write(to: dest)
    print("✓ \(filename)  (\(px)×\(px)px)")
}
print("Done — icons written to \(outputDir)")

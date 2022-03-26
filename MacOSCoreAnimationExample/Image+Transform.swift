//
//  Image+Transform.swift
//  MacOSCoreAnimationExample
//
//  Created by nenhall on 2022/3/24.
//

import Foundation
import AppKit
import CoreGraphics

enum NSImageMirrorOrientation {
    case vertical
    case horizontal
}

extension NSImage {

    func transformMirror(_ orientation: NSImageMirrorOrientation) -> NSImage? {
        guard let data = tiffRepresentation else { return nil }
        guard let ciImage = CIImage(data: data) else { return nil }

        var transform: CGAffineTransform
        switch orientation {
        case .vertical:
            transform = CGAffineTransform(scaleX: 1, y: -1)
        case .horizontal:
            transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        return makeMirrorImage(from: ciImage, transform: transform)
    }

    private func makeMirrorImage(from image: CIImage, transform: CGAffineTransform) -> NSImage {
        let newCIImage = image.transformed(by: transform)
        let imageRep = NSBitmapImageRep(ciImage: newCIImage)
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        imageRep.draw(in: NSRect(origin: .zero, size: size))
        newImage.unlockFocus()
        return newImage
    }

}

extension NSImageView {

    func transformMirrorTheImage(_ orientation: NSImageMirrorOrientation) {
        guard let image = image else { return }
        self.image = image.transformMirror(orientation)
    }

}

extension NSImage {
    func transform(orientation: CGImagePropertyOrientation) -> NSImage? {
        guard let data = tiffRepresentation else { return nil }
        guard let ciImage = CIImage(data: data) else { return nil }

//        let orgTransform = ciImage.orientationTransform(for: orientation)
        var transform: CGAffineTransform
        switch orientation {
        case .up: transform = CGAffineTransform(scaleX: -1, y: -1)
        case .down: transform = CGAffineTransform(scaleX: -1, y: -1)
        case .left: transform = CGAffineTransform(scaleX: -1, y: -1)
        case .right: transform = CGAffineTransform(scaleX: -1, y: -1)
        case .upMirrored: transform = CGAffineTransform(scaleX: 1, y: -1)
        case .rightMirrored: transform = CGAffineTransform(scaleX: -1, y: 1)
        case .downMirrored: transform = CGAffineTransform(scaleX: 1, y: -1)
        case .leftMirrored: transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        return makeMirrorImage(from: ciImage, transform: transform)
    }
}

/**
extension NSImage {
    func mirrored() -> NSImage? {
        guard
            let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil),
            let colorSpace = cgImage.colorSpace else {
                return nil
        }

        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent),
                                          bitsPerPixel: UInt32(cgImage.bitsPerPixel),
                                          colorSpace: Unmanaged.passRetained(colorSpace),
                                          bitmapInfo: cgImage.bitmapInfo,
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: cgImage.renderingIntent)

        var source = vImage_Buffer()
        var result = vImageBuffer_InitWithCGImage(
            &source,
            &format,
            nil,
            cgImage,
            vImage_Flags(kvImageNoFlags))

        guard result == kvImageNoError else { return nil }

        defer { free(source.data) }

        var destination = vImage_Buffer()
        result = vImageBuffer_Init(
            &destination,
            vImagePixelCount(cgImage.height),
            vImagePixelCount(cgImage.width),
            UInt32(cgImage.bitsPerPixel),
            vImage_Flags(kvImageNoFlags))

        guard result == kvImageNoError else { return nil }

        result = vImageHorizontalReflect_ARGB8888(&source, &destination, vImage_Flags(kvImageNoFlags))
        guard result == kvImageNoError else { return nil }

        defer { free(destination.data) }

        return vImageCreateCGImageFromBuffer(&destination, &format, nil, nil, vImage_Flags(kvImageNoFlags), nil).map {
            NSImage(cgImage: $0.takeRetainedValue(), size: size)
        }
    }

}
*/

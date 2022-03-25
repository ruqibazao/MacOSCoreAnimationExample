//
//  AnimationView.swift
//  MacOSCoreAnimationExample
//
//  Created by nenhall on 2022/3/24.
//

import AppKit
import SnapKit

let image1 = NSImage(named: NSImage.Name("OpenPDF"))
let image2 = NSImage(named: NSImage.Name("PrintPDF"))
let image3 = NSImage(named: NSImage.Name("Button"))

class AnimationView: NSView {

    let imageView = NSImageView()
    let iconView = LayerView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor.darkGray.cgColor
        setUpSubviews()
    }

    func setUpSubviews() {
        addSubview(imageView)
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleAxesIndependently
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(20)
            make.width.equalTo(300)
            make.height.equalTo(300)
        }
        imageView.image = image3

        addSubview(iconView)
        iconView.wantsLayer = true
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        iconView.layer?.contents = image3
        iconView.layer?.contentsScale = 2
//        iconView.layer?.contentsGravity = .resizeAspect
//        iconView.layer?.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 0.8)
        iconView.layer?.contentsCenter = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
    }



    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LayerView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
//        layer?.backgroundColor = NSColor.white.cgColor
        layer?.borderColor = NSColor.white.cgColor
        layer?.borderWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

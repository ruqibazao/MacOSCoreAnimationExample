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
let image4 = NSImage(named: NSImage.Name("ailin"))
let image5 = NSImage(named: NSImage.Name("Digits"))
let image6 = NSImage(named: NSImage.Name("Snowman"))



class AnimationView: NSView {

    let imageView = NSImageView()
    let iconView = LayerView()
    @IBOutlet var digitView1: NSView!
    @IBOutlet var digitView2: NSView!
    @IBOutlet var digitView3: NSView!
    @IBOutlet var digitView4: NSView!
    @IBOutlet var digitView5: NSView!
    @IBOutlet var digitView6: NSView!
    @IBOutlet var digitView7: NSView!
    @IBOutlet var digitView8: NSView!
    @IBOutlet var digitView9: NSView!
    @IBOutlet var digitView0: NSView!
    let textLayer = CATextLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

//        shapeLayer()
    }

    func setUpSubviews() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.darkGray.cgColor
//        test1()
//        testMagnificationFilter()
//        shouldRasterize()
//        transform()
//        testTextLayer()
        testTransfromLayer()
    }

    func testTransfromLayer() {
        var c1t = CATransform3DIdentity
        c1t = CATransform3DTranslate(c1t, -100, 0, 0)
        let cube1 = cubeWithTransform(c1t)
        layer?.addSublayer(cube1)
    }

    func faceWithTransform(transform: CATransform3D) -> CATransformLayer {
        let face = CATransformLayer()
        face.frame = CGRect(x: -50, y: -50, width: 100, height: 100)
        face.backgroundColor = NSColor.green.cgColor
        face.transform = transform
        return face
    }

    func cubeWithTransform(_ transform: CATransform3D) -> CATransformLayer {
        let cube = CATransformLayer()
        var ct = CATransform3DMakeTranslation(0, 0, 50)
        cube.addSublayer(faceWithTransform(transform: ct))

        ct = CATransform3DMakeTranslation(50, 0, 0)
        ct = CATransform3DRotate(ct, CGFloat.pi * 0.5, 0, 1, 0)
        cube.addSublayer(faceWithTransform(transform: ct))
        cube.frame = CGRect(x: 20, y: 20, width: 100, height: 100)
        cube.position = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        cube.backgroundColor = NSColor.white.cgColor

        cube.transform = transform
        return cube
    }

    func testTextLayer() {
        textLayer.frame = NSRect(x: 50, y: 50, width: 100, height: 30)
        layer?.addSublayer(textLayer)
        textLayer.foregroundColor = NSColor.orange.cgColor
        textLayer.string = "CATextLayer"
        textLayer.fontSize = 13
        let font = NSFont.boldSystemFont(ofSize: 13)
        textLayer.font = font
        textLayer.alignmentMode = .center
        textLayer.contentsScale = 2
        textLayer.borderWidth = 1
        textLayer.borderColor = NSColor.white.cgColor
    }

    func shapeLayer() {
        addSubview(iconView)
        iconView.wantsLayer = true
        iconView.layer?.contentsScale = 2
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.top.equalTo(10)
            make.width.equalTo(375)
            make.height.equalTo(500)
        }
        //  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 175, y: 100))
        path.addArc(center: CGPoint(x: 150, y: 100), radius: 25, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.move(to: CGPoint(x: 150, y: 125))
        path.addLine(to: CGPoint(x: 150, y: 175))
        path.addLine(to: CGPoint(x: 125, y: 225))
        path.move(to: CGPoint(x: 150, y: 175))
        path.addLine(to: CGPoint(x: 175, y: 225))
        path.move(to: CGPoint(x: 100, y: 150))
        path.addLine(to: CGPoint(x: 200, y: 150))
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = NSColor.red.cgColor
        shapeLayer.fillColor = NSColor.clear.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        shapeLayer.path = path
        //add it to our view
        iconView.layer?.addSublayer(shapeLayer)
    }

    func transform() {
        addSubview(imageView)
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(20)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        imageView.image = image2
//        let t = CGAffineTransform(a: <#T##CGFloat#>, b: <#T##CGFloat#>, c: <#T##CGFloat#>, d: <#T##CGFloat#>, tx: <#T##CGFloat#>, ty: <#T##CGFloat#>)
//        imageView.layer?.setAffineTransform(CGAffineTransform.init(rotationAngle: CGFloat.pi * 0.5))
//        imageView.layer?.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 1, 1)

        var transform3d = CATransform3DIdentity
        transform3d.m34 = -1.0 / 1000
        transform3d = CATransform3DRotate(transform3d, CGFloat.pi * 0.25, 0, 1, 0)
        imageView.layer?.transform = transform3d
    }

    func shouldRasterize() {
        addSubview(iconView)
        iconView.wantsLayer = true
        iconView.layer?.backgroundColor = NSColor.white.cgColor
//        iconView.alphaValue = 0.5
        iconView.layer?.opacity = 0.5
        iconView.layer?.shouldRasterize = true
        iconView.layer?.contentsScale = 2
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.top.equalTo(10)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }

        iconView.addSubview(imageView)
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(0)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        imageView.image = image2
    }

    func testMagnificationFilter() {
        //set up digit views
        for (index, view) in [digitView0, digitView1, digitView2, digitView3, digitView4, digitView5, digitView6, digitView7, digitView8, digitView9].enumerated() {
            //set contents
            view?.wantsLayer = true
            view?.layer?.contents = image5
            debugPrint((Double(index) / 10.0))
            view?.layer?.contentsRect = CGRect(x: (Double(index) / 10.0), y: 0, width: 0.1, height: 1.0)
            view?.layer?.contentsGravity = .resizeAspect
            view?.layer?.minificationFilter = .nearest
            view?.layer?.magnificationFilter = .nearest
        }
    }

    func test1() {
        addSubview(imageView)
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleAxesIndependently
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(10)
            make.width.equalTo(300)
            make.height.equalTo(300)
        }
        imageView.image = image2

        addSubview(iconView)
        iconView.wantsLayer = true
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        iconView.layer?.contents = image2
        iconView.layer?.contentsScale = 2
        iconView.layer?.minificationFilter = .trilinear
        iconView.layer?.magnificationFilter = .trilinear
//        iconView.layer?.contentsGravity = .resizeAspect
//        iconView.layer?.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 0.8)
//        iconView.layer?.contentsCenter = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)

        iconView.layer?.shadowOpacity = 1.0
        iconView.layer?.shadowColor = NSColor.orange.cgColor
        iconView.layer?.shadowOffset = CGSize(width: 0, height: 0)
//        iconView.layer?.shadowRadius = 10
        let path = CGMutablePath()
        path.addRect(CGRect(x: 10, y: 10, width: 50, height: 50))
        iconView.layer?.shadowPath = path as! CGPath


        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        maskLayer.contents = image4
        maskLayer.contentsScale = 2
        imageView.layer?.mask = maskLayer
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
}

class LayerView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
//        layer?.backgroundColor = NSColor.white.cgColor
//        layer?.borderColor = NSColor.white.cgColor
//        layer?.borderWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

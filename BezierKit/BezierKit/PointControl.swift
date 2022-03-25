//
//  CurveDrawView.swift
//  BezierKit
//
//  Created by ws on 2021/7/28.
//

import Foundation
import AppKit

public class PointControl: NSView {

    public struct PointInfo {
        var value: Double = 1
        /// 1~100
        var ratio: Double = 1
        /// -1说明是假点，即与底层没有关联的点
        var tag: Int = -1
    }

    @objc public enum MenuType: Int {
        case none
        case delete
    }

    @objc public enum IndicatorType: Int {
        case rounded /// 圆形
        case quadrate /// 圆形
        case leadingArrows /// 左箭头
        case trailingArrows /// 右边箭头
    }

    public override var acceptsFirstResponder: Bool {
        return true
    }

    lazy private var customMenu: NSMenu = {
        let customMenu = NSMenu()
        customMenu.addItem(NSMenuItem(title: "Delete", action: #selector(clickDelete(item:)), keyEquivalent: ""))
        return customMenu
    }()

    public var cornerRadius: CGFloat = 5 {
        didSet { needsDisplay = true }
    }
    public var dragCallBack: ((_ pointControl: PointControl) -> Void)?
    public var clickMenuCallBack: ((_ menuType: MenuType, _ pointControl: PointControl) -> Void)?
    public var doubleClickCallBack: ((_ menuType: MenuType, _ pointControl: PointControl) -> Void)?
    public var clickCallBack: ((_ menuType: MenuType, _ pointControl: PointControl) -> Void)?

    public var fullColor: NSColor = .black {
        didSet { needsDisplay = true }
    }
    public var strokeColor: NSColor = .white {
        didSet { needsDisplay = true }
    }
    public var centerPoint: CGPoint {
        return CGPoint(x: frame.origin.x + bounds.width * 0.5, y: frame.origin.y + bounds.height * 0.5)
    }
    public var isSelected = false {
        didSet {
            needsDisplay = true
        }
    }
    public var selectedColor: NSColor = .controlColor
    public var indicatorType = IndicatorType.rounded {
        didSet {
            if indicatorType == .quadrate {
                cornerRadius = 0
            }
            needsDisplay = true
        }
    }
    /// 点的信息：相对父视图的比例，当前值，默认都是1
    public private(set) var info = PointInfo()
    public var needMenu = true {
        didSet {
            if needMenu {
                menu = customMenu
            } else {
                menu = nil
            }
        }
    }
    var drawPoint: Bool = true {
        didSet { needsDisplay = true }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        menu = customMenu

        let trackArea = NSTrackingArea(rect: bounds, options: [.activeInActiveApp, .mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(trackArea)
    }

    convenience init(size: NSSize) {
        self.init(frame: NSRect(origin: .zero, size: size))
    }

    @objc func clickDelete(item: NSMenuItem) {
        clickMenuCallBack?(.delete, self)
    }

    public override func mouseEntered(with event: NSEvent) {
        NSCursor.openHand.set()
        super.mouseEntered(with: event)
    }

    public override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
        super.mouseExited(with: event)
    }

    public override func mouseDown(with event: NSEvent) {
        NSCursor.closedHand.set()
        if event.clickCount == 1 {
            clickCallBack?(.none, self)
        } else if event.clickCount == 2 {
            doubleClickCallBack?(.none, self)
        }
        super.mouseDown(with: event)
    }

    public override func mouseUp(with event: NSEvent) {
        NSCursor.arrow.set()
        super.mouseUp(with: event)
    }

    func needUpdatePointInfo(_ pInfo: PointInfo) {
        info = pInfo
        info.tag = 1
    }

    public override func updateLayer() {
        super.updateLayer()

        layer?.cornerRadius = cornerRadius
    }

    public override func draw(_ dirtyRect: NSRect) {
        if drawPoint {
            drawPoints(dirtyRect)
        }
    }

    func drawPoints(_ dirtyRect: NSRect) {
        let roundPath = NSBezierPath()

        switch indicatorType {
        case .rounded:
            roundPath.appendRoundedRect(dirtyRect,
                                        xRadius: dirtyRect.size.width * 0.5,
                                        yRadius: dirtyRect.size.height * 0.5)
        case .quadrate:
            roundPath.appendRect(dirtyRect)

        case .leadingArrows:
            roundPath.move(to: NSPoint(x: 0, y: 0))
            roundPath.line(to: NSPoint(x: 0, y: bounds.size.height))
            /// 补偿1 是为了保证与曲线视觉上能完全重合
            roundPath.line(to: NSPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5 + 1))
            roundPath.line(to: NSPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5 - 1))
            roundPath.close()
        case .trailingArrows:
            roundPath.move(to: NSPoint(x: bounds.size.width * 0.5, y: 0))
            roundPath.line(to: NSPoint(x: bounds.size.width * 0.5, y: bounds.size.height))
            roundPath.line(to: NSPoint(x: bounds.size.width, y: bounds.size.height * 0.5))
            roundPath.close()
        }

        if isSelected {
            selectedColor.setFill()
        } else {
            fullColor.setFill()
        }
        strokeColor.setStroke()
        roundPath.fill()
    }

}


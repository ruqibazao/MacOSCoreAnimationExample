//
//  CurveDrawView.swift
//  BezierKit
//
//  Created by ws on 2021/7/28.
//

import Cocoa

fileprivate struct CurvePartDefault: CurvePartProtocol {
    let max: Describe = Describe(value: 100, scale: 1.0)
    let topHalf: Describe = Describe(value: 10, scale: 0.8)
    let mid: Describe = Describe(value: 1, scale: 0.5)
    let lowerHalf: Describe = Describe(value: 0.1, scale: 0.2)
    let min: Describe = Describe(value: 0.01, scale: 0.01)
}

open class CurveDrawView: NSView {
    private(set) var curve = NSBezierPath()
    private let shapeLayer = CAShapeLayer()
    @IBOutlet weak var marklineView: NSView?
    @IBOutlet weak var delegate: CurveDrawViewDelegate?
    @IBOutlet private(set) weak var marklineViewLeading: NSLayoutConstraint?

    private(set) var pointControls = [PointControl]()
    private var points = [CGPoint]()
    private(set) var currentPointControl: PointControl?
    private(set) var selectedIndex: Int = 0
    @IBInspectable var backgroundColor: NSColor = .lightGray {
        didSet { needsDisplay = true }
    }
    @IBInspectable var strokeColor: NSColor? {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var curveLineColor: NSColor = NSColor(red: 0.333, green: 0.898, blue: 0.773, alpha: 1)
    @IBInspectable public var splitLineColor: NSColor = .lightGray
    @IBInspectable public var pointSelectedColor: NSColor = .controlColor
    @IBInspectable public var pointFullColor: NSColor = .controlColor {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var pointStrokeColor: NSColor = .controlColor {
        didSet { needsDisplay = true }
    }
    /// 是否拖到过
    public var dragged: Bool = false
    @IBInspectable var enableDrag: Bool = true
    /// 自动zai `layout()` 更新点的位置，会影响性能，
    /// 非必要不建议开启，`default：false`，可以设定`defaultSize`
    @IBInspectable var autoUpdatePoint: Bool = false
    @IBInspectable var defaultSize: NSSize = NSSize(width: 60, height: 60)
    let layer0 = CAGradientLayer()
    /// 判断当前是否在 dragging
    public private(set) var isDragging: Bool = false
    @IBInspectable var pointSize: NSSize = NSSize(width: 16, height: 16)
    /// 控制点参考线的宽
    @IBInspectable var lineWidth: CGFloat = 2.0
    @IBInspectable var strokeWidth: CGFloat = 0.0
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var showPointControl: Bool = true
    private(set) var orignalPoints = [CGPoint]()

    /// 标记线视图再父视图的百分百位置 1~100
    public var markLinePositionRatio: Double {
        guard let x = marklineViewLeading?.constant else { return 0 }
        return (Double(x / bounds.width) * 100)
    }

    /// 变速分段点信息
    public var partInfo: CurvePartProtocol { return CurvePartDefault() }
    @IBInspectable var hiddenMarkView: Bool = false {
        didSet { marklineView?.isHidden = hiddenMarkView }
    }
    /// 画控制点，默认不画，以 view 的方式添加
    var drawPointControl: Bool = false {
        didSet { pointControls.forEach({ $0.drawPoint = !drawPointControl }) }
    }
    /// 可视画的有效区域，因为上下要留一定的间隙
    var drawValidRect: NSRect {
        return NSRect(x: 0, y: pointSize.height * 0.5, width: frame.size.width, height: frame.size.height - pointSize.height)
    }
    public var pointRadius: CGFloat {
        return pointSize.width * 0.5
    }
    var partY100x: CGFloat { return bounds.size.height - (pointSize.height * 0.5) }
    var partY10x:  CGFloat { return bounds.size.height * partInfo.topHalf.scale }
    var partY1x:   CGFloat { return bounds.size.height * partInfo.mid.scale }
    var partY01x:  CGFloat { return bounds.size.height * partInfo.lowerHalf.scale }
    var partY001x: CGFloat { return pointRadius }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        prepareSubviews()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareSubviews()
    }
    
    open override func layout() {
        super.layout()
        
        if autoUpdatePoint {
            updatePointFrame()
        }
    }
    
    
    private func prepareSubviews() {
        wantsLayer = true


    }
    
    public func createCurvePoints(_ points: [CGPoint]) {
        pointControls.removeAll()
        self.points = points
        var tempPoints = [PointControl]()
        for point in points  {
            let pointView = PointControl(size: NSSize(width: 10, height: 10))
            if bounds.size != .zero {
                pointView.autoresizingMask = [.minXMargin, .minYMargin, .maxXMargin, .maxYMargin]
            }
            pointView.frame.origin = point
            pointView.fullColor = .white
            addSubview(pointView)
            tempPoints.append(pointView)
        }
        pointControls = tempPoints
        updatePointFrame()
    }
    
    public func clearCurvePoints() {
        for item in pointControls {
            item.removeFromSuperview()
            needsDisplay = true
        }
    }
    
    private func updatePointFrame() {
        for (index, item) in pointControls.enumerated() {
//            item.frame.origin = points[index]
        }
//        needsDisplay = true
    }

    private func updateMarklinePostionXAndNotifiy(_ x: CGFloat) {
        marklineViewLeading?.constant = x
//        debugPrint("[曲线变速]: 游标的 X ", marklineViewLeading?.constant as Any)
        delegate?.curveDrawViewMarklineDidMoved(index: selectedIndex, pointControl: currentPointControl, curveDraw: self)
    }

    public func searchAndUpdateSelectedPoint() {
        let oldPointCtl = currentPointControl
        if showPointControl, isDragging == false {
            var existent = false
            for (index, pointView) in pointControls.enumerated() {
                if let constant = marklineViewLeading?.constant {
                    /// 标记线与控制点是否交叉
                    let isCross = constant >= pointView.frame.minX && constant <= pointView.frame.maxX
                    if isCross {
                        existent = true
//                        newSelectedIndex = index
                        if oldPointCtl != pointView {
                            selectedIndex = index
                        }
                    } else {
                        let oldSelected = pointView.isSelected
                        pointView.isSelected = false
                        if oldSelected {
                            if index == selectedIndex {
                                selectedIndex = -1
                            }
                            delegate?.curveDrawViewDidDeselectControlPoint(index: index, curveDraw: self)
                        }
                    }
                }
            }
            if existent == false {
//                newSelectedIndex = -1
                selectedIndex = -1
            }
        }
        /// 重绘制点
        needsDisplay = true
    }

    private func addShapeLayer() {
        shapeLayer.strokeColor = NSColor.blue.cgColor
        shapeLayer.fillColor = NSColor.black.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.frame = bounds
        let cgpath = curve.cgPath().takeRetainedValue()
        shapeLayer.path = cgpath
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        layer?.addSublayer(shapeLayer)
    }

    @discardableResult
    public func addPointOnMarkLine() -> Bool {
        let point = CGPoint(x: (marklineView?.frame.origin.x ?? pointSize.width) - pointRadius,
                            y: bounds.height * 0.5 - pointRadius)
        var newPoints = Array(points)
        newPoints.append(point)
        points = newPoints.sorted(by: {$0.x < $1.x})
        selectedIndex = points.firstIndex(of: point) ?? 0
        remakeCurvePoints(points)
        return true
    }

    @discardableResult
    public func addPoint(_ point: CGPoint) -> Bool {
        var newPoints = Array(points)
        newPoints.append(point)
        points = newPoints.sorted(by: {$0.x < $1.x})
        selectedIndex = points.firstIndex(of: point) ?? 0
        remakeCurvePoints(points)
        return true
    }

    public func removePoint(_ point: CGPoint) -> Bool {
        let newPoints = points
        for (index, item) in newPoints.enumerated() {
            if item == point {
                points.remove(at: index)
                remakeCurvePoints(points)
                return true
            }
        }
        return false
    }

    public func removePoint(_ index: Int) -> Bool {
        if index > points.count {
            return false
        }
        points.remove(at: index)
        remakeCurvePoints(points)
        return true
    }

    private func deletePoint(type: PointControl.MenuType, index: Int) {
       let result = self.delegate?.curveDrawViewDidClickMenu(menuType: type, index: index, curveDraw: self) ?? false
        if type == .delete, result {
            if pointControls.count > index {
                let item = pointControls[index]
                if item == currentPointControl {
                    selectedIndex = -1
                }
                points.remove(at: index)
                pointControls.remove(at: index)
                item.removeFromSuperview()
                needsDisplay = true
            }
        }
    }

    public func remakeCurvePoints(_ points: [CGPoint]) {
        clearCurvePoints()
        orignalPoints = points
        makeCurvePoints(points)
        searchAndUpdateSelectedPoint()
    }

    public func makeCurvePoints(_ points: [CGPoint]) {
        self.points = points
        if showPointControl {
            for (index, point) in points.enumerated() {
                let pointView = PointControl(size: NSSize(width: pointSize.width, height: pointSize.height))
                pointView.drawPoint = !drawPointControl
                pointView.autoresizingMask = [.minXMargin, .minYMargin, .maxXMargin, .maxYMargin]
                pointView.frame.origin = point.center(pointRadius)
                if let constant = marklineViewLeading?.constant {
                    /// 标记线与控制点是否交叉
                    let isCross = constant >= pointView.frame.minX && constant <= pointView.frame.maxX
                    if isCross {
                        pointView.isSelected = isCross
                        selectedIndex = index
                    } else {
                        if pointView.isSelected {
                            pointView.isSelected = false
                            delegate?.curveDrawViewDidDeselectControlPoint(index: index, curveDraw: self)
                        } else {
                            pointView.isSelected = false
                        }
                    }
                }
                if index == 0 || index == points.count - 1 {
                    pointView.needMenu = false
                }

                let type = delegate?.curveDrawViewControlPointWillDraw(index: index, pointControl: pointView, curveDraw: self) ?? .rounded
                pointView.indicatorType = type
                addSubview(pointView)
                pointControls.append(pointView)
                pointView.clickMenuCallBack = { [weak self] (type, pointControl) in
                    self?.deletePoint(type: type, index: index)
                }
                pointView.doubleClickCallBack = { [weak self] (type, pointControl) in
                    guard let self = self else { return }
                    self.delegate?.curveDrawViewControlDoubleClick(index: index, pointControl: pointView, curveDraw: self)
                }
            }
        }

        needsDisplay = true
    }


}

//MARK: Mouse 事件
extension CurveDrawView {

    public override func mouseUp(with event: NSEvent) {
//        speedPopover.close()
        if enableDrag, isDragging {
            isDragging = false
            if let control = currentPointControl {
                delegate?.curveDrawViewControlPointEndMove(index: selectedIndex, pointControl: control, curveDraw: self)
                delegate?.curveDrawViewMarklineDidMoved(index: selectedIndex, pointControl: currentPointControl, curveDraw: self)
            }
            needsDisplay = true

        } else {
            super.mouseUp(with: event)
        }
    }

    public override func mouseDown(with event: NSEvent) {
        /// 每次重新点击都有重设
        isDragging = false
//        newSelectedIndex = -1

        if enableDrag {
            let location = event.locationInWindow
            let newPoint = convert(location, from: nil)
            updateMarklinePostionXAndNotifiy(newPoint.x)
            searchAndUpdateSelectedPoint()

            if let control = currentPointControl, control.frame.contains(newPoint) {
//                userClickPointCtl = true
                if event.clickCount > 1 {
                    delegate?.curveDrawViewControlDoubleClick(index: selectedIndex, pointControl: control, curveDraw: self)
                } else {
//                    if speedPopover.isShown == false {
//                        let value = conversionSpeed(from: CGPoint(x: control.frame.midX, y: control.frame.midY))
//                        speedPopover.setSpeedValue(value)
//                        speedPopover.show(relativeTo: control.bounds, of: control, preferredEdge: .maxY)
//                    }
                }

            } else {
//                userClickPointCtl = false
            }
        } else {
            super.mouseDown(with: event)
        }
    }

    public override func mouseDragged(with event: NSEvent) {
        debugPrint("mouseDragged:",currentPointControl?.frame.origin as Any)
        if enableDrag, let control = currentPointControl {
            dragged = true
            let location = event.locationInWindow
            var newPoint = convert(location, from: nil)
            var value: Double = 1
            var frontPoint: CGPoint = .zero
            var nextPoint = NSPoint(x: drawValidRect.maxX, y: drawValidRect.maxY)

            let frontIndex = selectedIndex - 1
            if frontIndex > -1, points.count > frontIndex {
                frontPoint = CGPoint(x: points[frontIndex].x, y: points[frontIndex].y)
            }

            let nextIndex = selectedIndex + 1
            if points.count > nextIndex {
                let p = points[nextIndex]
                nextPoint = CGPoint(x: p.x, y: p.y)
            }

            /// 判断是否超出了前后的点,增加首尾点宽度为一半特殊处理
            if frontIndex != 0 && nextIndex != points.count - 1 {
                if newPoint.x < frontPoint.x + pointSize.width {
                    newPoint.x = frontPoint.x + pointSize.width
                }
                if newPoint.x > nextPoint.x - pointSize.width {
                    newPoint.x = nextPoint.x - pointSize.width
                }
            }else if frontIndex == 0 {
                if newPoint.x < frontPoint.x + pointSize.width * 0.5 {
                    newPoint.x = frontPoint.x + pointSize.width * 0.5
                }
                if newPoint.x > nextPoint.x - pointSize.width {
                    newPoint.x = nextPoint.x - pointSize.width
                }
            }else {
                if newPoint.x < frontPoint.x + pointSize.width {
                    newPoint.x = frontPoint.x + pointSize.width
                }
                if newPoint.x > nextPoint.x - pointSize.width * 0.5 {
                    newPoint.x = nextPoint.x - pointSize.width * 0.5
                }
            }

            /// 判断是否超出可视绘制区域
            if newPoint.y > drawValidRect.maxY {
                newPoint.y = drawValidRect.maxY
            } else if newPoint.y < drawValidRect.minY {
                newPoint.y = drawValidRect.minY
            }
            if newPoint.x > drawValidRect.maxX {
                newPoint.x = drawCurveMaxX
            } else if newPoint.x < drawValidRect.minX {
                newPoint.x = drawCurveMinX
            }

            /// 首尾点 x 坐标固定
            if selectedIndex == 0 {
                newPoint.x = pointRadius
            }
            if selectedIndex == points.count - 1 {
                newPoint.x = drawValidRect.size.width - pointRadius
            }

            let intValuePoint = NSPoint(x: Int(newPoint.x), y: Int(newPoint.y))
            newPoint = intValuePoint
            // 把鼠标的点转换成控制点的中心点
            control.setFrameOrigin(newPoint.center(pointRadius))
//            debugPrint("mouseDragged2:",control.frame.origin, newSelectedIndex, userClickPointCtl )

            points[selectedIndex].x = newPoint.x
            points[selectedIndex].y = newPoint.y

            value = conversionSpeed(from: newPoint)
//            speedPopover.setSpeedValue(value)

            control.needUpdatePointInfo(PointControl.PointInfo(value: value, ratio: currentPointControlRatio))

            if isDragging == false {
                delegate?.curveDrawViewControlPointWillMove(index: selectedIndex, pointControl: control, curveDraw: self)
                isDragging = true
            }

            updateMarklinePostionXAndNotifiy(newPoint.x)
            delegate?.curveDrawViewControlPointMoving(index: selectedIndex, pointControl: control, curveDraw: self)
            needsDisplay = true

        } else {
            super.mouseDragged(with: event)
        }
    }

}

//MARK: 绘制
extension CurveDrawView {

    public override func draw(_ dirtyRect2: NSRect) {
        let dirtyRect = self.bounds

        curve.removeAllPoints()

        /// 填充色
        drawBackgroundAndBorder(dirtyRect)

        /// 分割线
        drawSplitLine(dirtyRect)

        /// 曲线
        if points.isEmpty { return }
        if let path = NSBezierPath(quadCurve: points) {
            curve = path
        }
        curve.lineWidth = lineWidth
        curveLineColor.setStroke()
        curve.stroke()
        if drawPointControl {
            drawPoints(dirtyRect)
        }
    }

    /// 画点
    public func drawPoints(_ rect: NSRect) {
        var isCross = false
        let roundPath = NSBezierPath()
        var selectedPath: NSBezierPath?

        for (index, point) in points.enumerated() {
            var pointPath: NSBezierPath = roundPath
            let dirtyRect = NSRect(center: point, size: pointSize)
            if let constant = marklineViewLeading?.constant {
                isCross = constant >= dirtyRect.minX && constant <= dirtyRect.maxX
            }
            if isCross {
                let tempPath = NSBezierPath()
                pointPath = tempPath
                selectedPath = tempPath
            }

            let indicatorType = delegate?.curveDrawViewControlPointWillDraw(index: index, pointControl: PointControl(), curveDraw: self) ?? .rounded
            switch indicatorType {
            case .rounded:
                pointPath.appendRoundedRect(dirtyRect,
                                            xRadius: pointSize.width * 0.5,
                                            yRadius: pointSize.height * 0.5)
            case .quadrate:
                pointPath.appendRect(dirtyRect)
            case .leadingArrows:
                pointPath.move(to: dirtyRect.origin)
                pointPath.line(to: NSPoint(x: dirtyRect.minX, y: dirtyRect.maxY))
                /// 补偿1 是为了保证与曲线视觉上能完全重合
                pointPath.line(to: NSPoint(x: dirtyRect.minX + pointSize.width * 0.5, y: dirtyRect.minY + pointSize.height * 0.5 + 1))
                pointPath.line(to: NSPoint(x: dirtyRect.minX + pointSize.width * 0.5, y: dirtyRect.minY + pointSize.height * 0.5 - 1))
                pointPath.close()
            case .trailingArrows:
                pointPath.move(to: NSPoint(x: dirtyRect.minX + pointSize.width * 0.5, y: dirtyRect.minY))
                pointPath.line(to: NSPoint(x: dirtyRect.minX + pointSize.width * 0.5, y: dirtyRect.minY + pointSize.height))
                pointPath.line(to: NSPoint(x: dirtyRect.minX + pointSize.width, y: dirtyRect.minY + pointSize.height * 0.5))
                pointPath.close()
            }
        }

        pointStrokeColor.setStroke()
        if selectedPath != nil {
            pointSelectedColor.setFill()
            selectedPath?.fill()
        }
        NSGraphicsContext.current?.cgContext.setBlendMode(.sourceAtop)
        pointFullColor.setFill()
        roundPath.fill()
    }

    private func drawBackgroundAndBorder(_ dirtyRect: NSRect) {
        let fullPath = NSBezierPath()
        fullPath.appendRoundedRect(dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius)
        backgroundColor.setFill()
        fullPath.fill()
        if let strokeColor = strokeColor {
            fullPath.lineWidth = strokeWidth
            strokeColor.setStroke()
            fullPath.stroke()
        }
    }

    private func drawSplitLine(_ dirtyRect: NSRect) {
        splitLineColor.setStroke()

        do {
            // 实线
            let splitLine = NSBezierPath()
            splitLine.lineWidth = 1
            splitLine.move(to: NSPoint(x: 0, y: dirtyRect.height * 0.5))
            splitLine.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height * 0.5))
            splitLine.stroke()
            splitLine.close()
        }

        do {
            let space = pointRadius
            // 虚线
            let splitLine = NSBezierPath()
            let lineDash: [CGFloat] = [2.0, 2.0]
            splitLine.setLineDash(lineDash, count: 2, phase: 0.0)
            splitLine.move(to: NSPoint(x: 0, y: dirtyRect.height * partInfo.lowerHalf.scale))
            splitLine.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height * partInfo.lowerHalf.scale))

            splitLine.move(to: NSPoint(x: 0, y: dirtyRect.height * partInfo.topHalf.scale))
            splitLine.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height * partInfo.topHalf.scale))

            splitLine.move(to: NSPoint(x: 0, y: dirtyRect.height - space))
            splitLine.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height - space))

            splitLine.move(to: NSPoint(x: 0, y: space))
            splitLine.line(to: NSPoint(x: dirtyRect.width, y: space))

            splitLine.stroke()
            splitLine.close()
        }
    }
}

//MARK: 坐标点与速度点之间相互转换
extension CurveDrawView {

    /// 从坐标转换到速度值
    /// - Note: 因为速度从最小值到最大值，在view不是等比例的，所以需要额外计算
    func conversionSpeed(from point: NSPoint) -> Double {
//        return CurveSpeedManager.shared.conversionSpeed(from: point, rect: drawValidRect)

        var speed: CGFloat = 1.0
        let pointY = point.y
        var scale: CGFloat = 1.0

        if pointY >= partY001x && pointY <= partY01x {
            scale = (pointY - partY001x) / (partY01x - partY001x)
            speed = partInfo.valueAtSection(scale: scale, max: partInfo.lowerHalf, min: partInfo.min)
            speed += partInfo.min.value

        } else if pointY >= partY01x && pointY <= partY1x {
            scale = (pointY - partY01x) / (partY1x - partY01x)
            speed = partInfo.valueAtSection(scale: scale, max: partInfo.mid, min: partInfo.lowerHalf)
            speed += partInfo.lowerHalf.value

        } else if pointY >= partY1x && pointY <= partY10x {
            scale = (pointY - partY1x) / (partY10x - partY1x)
            speed = partInfo.valueAtSection(scale: scale, max: partInfo.topHalf, min: partInfo.mid)
            speed += partInfo.mid.value

        } else if pointY >= partY10x {
            scale = (pointY - partY10x) / (partY100x - partY10x)
            speed = partInfo.valueAtSection(scale: scale, max: partInfo.max, min: partInfo.topHalf)
            speed += partInfo.topHalf.value
        }

        return Double(speed)
    }

    /// 转换速度点到坐标
    /// - Note: 因为速度从最小值到最大值，在view不是等比例的，所以需要额外计算
    func conversionPoint(from items: [CurveSpeedPointProtocol], duration: Int64) -> [CGPoint] {
//        return CurveSpeedManager.shared.conversionPoint(from: items, duration: duration, rect: drawValidRect)
        var points = [CGPoint]()
        for (index, item) in items.enumerated() {
            let timeValue = item.time
            var x: CGFloat = pointRadius
            var y: CGFloat = 0
            /// 计算 x 坐标
            if index == items.count - 1 {
                x = drawCurveMaxX
            } else {
                if timeValue != 0 {
                    x += CGFloat(timeValue) * (drawCurveModificationWidth / CGFloat(duration))
                }
            }

            /// 计算 y 坐标
            var partHeight = bounds.size.height
            if item.speed >= partInfo.min.doubleValue && item.speed < partInfo.lowerHalf.doubleValue {
                partHeight = partY01x - partY001x
                let scale = partInfo.scaleAtSection(value: item.speed, max: partInfo.lowerHalf, min: partInfo.min)
                let offset = scale * partHeight
                y = partY001x + offset

            } else if item.speed >= partInfo.lowerHalf.doubleValue && item.speed < partInfo.mid.doubleValue {
                partHeight = partY1x - partY01x
                let scale = partInfo.scaleAtSection(value: item.speed, max: partInfo.mid, min: partInfo.lowerHalf)
                let offset = scale * partHeight
                y = partY01x + offset

            } else if item.speed >= partInfo.mid.doubleValue && item.speed < partInfo.topHalf.doubleValue {
                partHeight = partY10x - partY1x
                let scale = partInfo.scaleAtSection(value: item.speed, max: partInfo.topHalf, min: partInfo.mid)
                let offset = scale * partHeight
                y = partY1x + offset

            } else if item.speed >= partInfo.topHalf.doubleValue {
                partHeight = partY100x - partY10x
                let scale = partInfo.scaleAtSection(value: item.speed, max: partInfo.max, min: partInfo.topHalf)
                let offset = scale * partHeight
                y = partY10x + offset
            }

            if y > drawValidRect.maxY || x < drawValidRect.minX {
                print("[曲线变速]: 速度点值超出了最大值/最小值:", item.speed, index)
            }
            let point = CGPoint(x: x, y: y)
            item.debugDescription()
            debugPrint("[曲线变速]: VBL 速度转坐标：index:\(index) speed:\(item.speed) time:\(item.time) point:\(point)")
            points.append(point)
        }
        return points
    }

    /// 查找曲线与游标的交叉点对应的速度
    func findMarklinePointSpeed() -> Double {
        guard let x = marklineViewLeading?.constant else { return 1 }
//        return CurveSpeedManager.shared.getSpeedAtPointCross(positionX: x, points: points)
        var frontPoint: NSPoint = .zero
        var nextPoint: NSPoint = .zero

        for (index, point) in points.enumerated() {
            if points.count > index + 1 {
                nextPoint = points[index + 1]
            }
            if x > point.x && x < nextPoint.x {
                frontPoint = point
                break
            }
        }
        let newPoint = curve.findBezierCrossPointFrom(x: x, start: frontPoint, end: nextPoint)
        let speed = conversionSpeed(from: newPoint)
        debugPrint("[曲线变速]: 查找交叉点", speed, newPoint, frontPoint, nextPoint)
        return speed
    }

}

extension CurveDrawView {
    /// 当前控制点所在的位置比率
    private var currentPointControlRatio: Double {
        var ratio: Double = 1
        if points.count > selectedIndex && selectedIndex != -1 {
            ratio = Double((points[selectedIndex].x - pointRadius) / drawCurveModificationWidth) * 100
        }
        return ratio
    }

    /// 用于计算曲线所在比例系数的参考值宽
    private var drawCurveMinX: CGFloat {
        return pointRadius
    }

    /// 用于计算曲线所在比例系数的参考值宽
    private var drawCurveMaxX: CGFloat {
        return drawValidRect.size.width - pointRadius
    }

    /// 用于计算曲线所在比例系数的参考值宽
    public var drawCurveModificationWidth: CGFloat {
        return drawValidRect.size.width - pointSize.width
    }
}

/**
public override func draw(_ dirtyRect: NSRect) {
    layer?.backgroundColor = NSColor.gray.cgColor

    NSGraphicsContext.current?.cgContext.clear(dirtyRect)
    curve.removeAllPoints()

    drawSplitLine(dirtyRect)

    curveLineColor.setStroke()
    curve = NSBezierPath(quadCurve: pointControls.map({ $0.centerPoint }))!
//        curve.curve(points: pointControls.map({ $0.centerPoint }))
    curve.stroke()


    let arcPath = NSBezierPath()
    arcPath.lineWidth = 5
    arcPath.appendRoundedRect(NSRect(x: 2.5, y: 2.5, width: dirtyRect.width - 5, height: dirtyRect.height - 5), xRadius: 10, yRadius: 10)
    NSColor.red.setStroke()
    arcPath.stroke()
    arcPath.close()

    let colors = [
        NSColor(red: 0.674, green: 0.479, blue: 1, alpha: 1),
        NSColor(red: 0.451, green: 0.767, blue: 0.958, alpha: 1),
        NSColor(red: 0.333, green: 0.898, blue: 0.773, alpha: 1)
    ]

    let colors2 = [
        NSColor(red: 0.333, green: 0.898, blue: 0.773, alpha: 1),
        NSColor(red: 0.451, green: 0.767, blue: 0.958, alpha: 1),
        NSColor(red: 0.674, green: 0.479, blue: 1, alpha: 1)
    ]
    layer0.colors = colors.map({$0.cgColor})
    layer0.locations = [0, 0.66, 0.9]
    layer0.startPoint = CGPoint(x: 0, y: 0)
    layer0.endPoint = CGPoint(x: 0, y: 1)
    layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -1.08, b: -1.44, c: 0.67, d: -2.32, tx: 0.69, ty: 2.6))
    layer0.bounds = bounds
    layer0.position = NSPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
//        layer?.addSublayer(layer0)


//        let gradient = NSGradient(colors: colors, atLocations: [0, 0.34, 0.66], colorSpace: .deviceRGB)
//        gradient?.draw(in: bounds, angle: 135)

    let animation = CABasicAnimation()
    animation.fromValue = CGPoint(x: 0, y: 1)
    animation.toValue = CGPoint(x: 0, y: 0)
    animation.keyPath = "startPoint"
    animation.duration = 2.2
    animation.repeatCount = MAXFLOAT
    animation.autoreverses = true


    let animation2 = CABasicAnimation()
    animation2.fromValue = [0, 0.66, 0.9]
    animation2.toValue = [0, 0.2, 0.5]
    animation2.keyPath = "locations"
//        animation2.timeOffset = 1.2
    animation2.duration = 1.2
    animation2.repeatCount = MAXFLOAT
    animation2.autoreverses = true
    animation2.isRemovedOnCompletion = false



    let animation3 = CABasicAnimation()
    animation3.fromValue = colors.map({$0.cgColor})
    animation3.toValue = colors2.map({$0.cgColor})
    animation3.keyPath = "colors"
//        animation2.timeOffset = 1.2
    animation3.duration = 3.2
    animation3.repeatCount = MAXFLOAT
    animation3.autoreverses = true

    let group = CAAnimationGroup()
    group.duration = 1.2
    group.repeatCount = MAXFLOAT
    group.autoreverses = true
    group.animations = [animation]
//        layer0.add(group, forKey: "locations")

//        layer0.add(animation, forKey: "locations")
//        layer0.add(animation2, forKey: "locations2")
//        layer0.add(animation3, forKey: "locations3")

}
 */

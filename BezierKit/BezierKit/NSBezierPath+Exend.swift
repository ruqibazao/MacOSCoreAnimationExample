//
//  NSBezierPath+Exend.swift
//  BezierKit
//
//  Created by nenhall on 2021/8/2.
//

#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if os(macOS)
import AppKit
typealias BezierPath = NSBezierPath
#elseif os(iOS)
import UIKit
typealias BezierPath = UIBezierPath
#endif

private var _contractionFactor: CGFloat = 0.4

extension BezierPath {

    /// 曲线的弯曲水平。好值在0.6~0.8左右。默认值和推荐值是 0.7
    var contractionFactor: CGFloat {
        get { return _contractionFactor }
        set { _contractionFactor = max(0, newValue) }
    }

    func curve(points: [CGPoint]) {
        assert(points.count > 0, "你必须至少设定一个坐标点。")

        if points.count < 3 {
            switch points.count {
            case 1: line(to: points[0])
            case 2: line(to: points[1])
            default: break
            }
            return
        }

        var obliqueAngle = CGFloat()

        var lastPoint = CGPoint.zero
        var lastCenterPoint = CGPoint.zero

        var centerPoint = CGPoint.zero
        var centerPointDistance = CGFloat()

        var lastControlPoint1 = CGPoint.zero
        var lastControlPoint2 = CGPoint.zero
        var controlPoint1 = CGPoint.zero

        for (index, point) in points.enumerated() {
            if index == 0 {
                move(to: point)
            } else if index > 0 {
                lastCenterPoint = centerPointOf(currentPoint, lastPoint)
                centerPoint = centerPointOf(lastPoint, point)
                centerPointDistance = distanceBetween(lastCenterPoint, centerPoint)
                obliqueAngle = obliqueAngleOfStraightThrough(centerPoint, lastCenterPoint)

                let x2 = lastPoint.x - 0.5 * contractionFactor * centerPointDistance * cos(obliqueAngle)
                let y2 = lastPoint.y - 0.5 * contractionFactor * centerPointDistance * sin(obliqueAngle)
                lastControlPoint2 = CGPoint(x: x2, y: y2)

                let cx = lastPoint.x + 0.5 * contractionFactor * centerPointDistance * cos(obliqueAngle)
                let cy = lastPoint.y + 0.5 * contractionFactor * centerPointDistance * sin(obliqueAngle)
                controlPoint1 = CGPoint(x: cx, y: cy)
            }

            switch index {
            case 1:
                curve(to: lastPoint, controlPoint1: lastControlPoint2, controlPoint2: lastControlPoint2)
            case 2 ..< points.count - 1:
                curve(to: lastPoint, controlPoint1: lastControlPoint1, controlPoint2: lastControlPoint2)
            case points.count - 1:
                curve(to: lastPoint, controlPoint1: lastControlPoint1, controlPoint2: lastControlPoint2)
                curve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint1)
            default: break
            }

            lastControlPoint1 = controlPoint1
            lastPoint = point
        }
    }

    private func obliqueAngleOfStraightThrough(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        //  [-π/2, 3π/2)

        var obliqueRatio: CGFloat = 0
        var obliqueAngle: CGFloat = 0

        if point1.x == point2.x {
            obliqueAngle = 0
        } else if (point1.x > point2.x) {
            obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x)
            obliqueAngle = atan(obliqueRatio)

        } else if (point1.x < point2.x) {
            obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x)
            obliqueAngle = CGFloat(Double.pi) + atan(obliqueRatio)

        } else if (point2.y - point1.y >= 0) {
            obliqueAngle = CGFloat(Double.pi)/2

        } else {
            obliqueAngle = -CGFloat(Double.pi)/2
        }

        debugPrint(obliqueRatio, obliqueAngle)

        return obliqueAngle
    }

    private func controlPointForTheBezierCanThrough(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> CGPoint {
        return CGPoint(x: (2 * point2.x - (point1.x + point3.x) / 2), y: (2 * point2.y - (point1.y + point3.y) / 2));
    }

    private func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        return sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y))
    }

    private func centerPointOf(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }

}

extension BezierPath {

    public convenience init?(quadCurve points: [CGPoint]) {
        guard points.count > 1 else { return nil }

        self.init()

        var p1 = points[0]
        move(to: p1)

        for i in 0..<points.count {
            let mid = Self.midPoint(p1: p1, p2: points[i])
            let control = NSPoint(x: mid.x, y: p1.y)
            let control2 = NSPoint(x: mid.x, y: points[i].y)
            curve(to: points[i], controlPoint1: control, controlPoint2: control2)

            p1 = points[i]
        }
    }

    class func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    func controlPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        var controlPoint = Self.midPoint(p1: p1, p2: p2)
        let diffY = abs(p2.y - controlPoint.y)

        if p1.y < p2.y {
            controlPoint.y += diffY
        } else if p1.y > p2.y {
            controlPoint.y -= diffY
        }
        return controlPoint
    }

}

extension BezierPath {

    /* 获取三阶贝塞尔曲线方程上的某一点
     *
     * float t 指定的x坐标比例，取值范围是 0 ~ 1 之间
     * CGPoint startPoint 起始点
     * CGPoint controlPoint1 控制点1
     * CGPoint controlPoint2 控制点2
     * CGPoint endPoint 结束点
     * 返回值：返回指定x坐标的贝塞尔曲线上的某一点
     */
    class func cubicBezierPathThePoint(_ t: CGFloat, _ startPoint: CGPoint, _ controlPoint1: CGPoint, _ controlPoint2: CGPoint, _ endPoint: CGPoint) -> CGPoint {
        var point = CGPoint.zero
        let temp = 1 - t
        point.x = startPoint.x * temp * temp * temp + 3 * controlPoint1.x * t * temp * temp + 3 * controlPoint2.x * t * t * temp + endPoint.x * t * t * t
        point.y = startPoint.y * temp * temp * temp + 3 * controlPoint1.y * t * temp * temp + 3 * controlPoint2.y * t * t * temp + endPoint.y * t * t * t
        return point
    }


    /* 二分法求取 t 值
     *
     * float x 指定的x坐标
     * CGPoint startPoint 起始点
     * CGPoint controlPoint1 控制点1
     * CGPoint controlPoint2 控制点2
     * CGPoint endPoint 结束点
     * 返回值：返回指定x坐标的贝塞尔曲线方程的 t 值
     */
    class func tValueByBinarySort(_ x: CGFloat, _ startPoint: CGPoint, _ controlPoint1: CGPoint, _ controlPoint2: CGPoint, _ endPoint: CGPoint) -> CGFloat {
        var a: CGFloat = 0.0
        var b: CGFloat = 1.0
        var xa = cubicBezierPathThePoint(a, startPoint, controlPoint1, controlPoint2, endPoint).x
        var xb = cubicBezierPathThePoint(b, startPoint, controlPoint1, controlPoint2, endPoint).x
        var xt = cubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x
        //x 的取值误差范围在 0.1
        while fabsf(Float(x - xt)) > 0.1 {
            if x < xt && x > xa {
                b = (b + a) / 2.0
                xb = xt
                xt = cubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x
            } else if x > xt && x < xb {
                a = (b + a) / 2.0
                xa = xt
                xt = cubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x
            } else {
                break
            }
        }
        return (b + a) / 2.0
    }

    class func findBezierCrossPointFrom(x: CGFloat, start startPoint: NSPoint, end endPoint: NSPoint) -> NSPoint {
        let mid = midPoint(p1: startPoint, p2: endPoint)
        let control = NSPoint(x: mid.x, y: startPoint.y)
        let control2 = NSPoint(x: mid.x, y: endPoint.y)
        let by2 = tValueByBinarySort(x, startPoint, control, control2, endPoint)
        let tPoint = cubicBezierPathThePoint(by2, startPoint, control, control2, endPoint)
        return tPoint
    }

    func findBezierCrossPointFrom(x: CGFloat, start startPoint: NSPoint, end endPoint: NSPoint) -> NSPoint {
        return Self.findBezierCrossPointFrom(x: x, start: startPoint, end: endPoint)
    }

}

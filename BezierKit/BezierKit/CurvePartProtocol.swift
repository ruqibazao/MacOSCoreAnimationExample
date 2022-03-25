//
//  CurvePartProtocol.swift
//  BezierKit
//
//  Created by nenhall on 2022/3/25.
//

import Foundation

public protocol CurveSpeedPointProtocol {

    /// 速度点索引
    var index: Int { get }
    /// 当前速度值
    var speed: Double { get set }
    /// 速度点的时间位置
    var time: Int64 { get set }
    /// 速度点时长, 只对定帧点有效。非定帧点返回 0.
    var duration: Int64 { get set }
    /// 速度点的类型
    /// 0:离散，也就是普通变速  1:曲线变速  2:定帧
    var speedType: Int { get }
    /// 速度点的标签
    /// 1: 真实点  2:首部的假点  3:尾部假点
    var tag: Int { get }
    
}

public struct Describe {

    /// 分段值
    let value: CGFloat
    /// 分段比例
    let scale: CGFloat
    var doubleValue: Double {
        return Double(value)
    }

}

public protocol CurvePartProtocol {
    
    var max: Describe { get }
    /// 上半段的中间值
    var topHalf: Describe { get }
    var mid: Describe { get }
    /// 下半段的中间值
    var lowerHalf: Describe { get }
    var min: Describe { get }

}

extension CurvePartProtocol {

    /// 所在段的值
    func valueAtSection(scale: CGFloat, max: Describe, min: Describe) -> CGFloat {
        let value = scale * (max.value - min.value)
        return value
    }

    /// 所在段的比例
    func scaleAtSection(value: Double, max: Describe, min: Describe) -> CGFloat {
        let scale = (value - min.doubleValue) / (max.doubleValue - min.doubleValue)
        return CGFloat(scale)
    }

}

extension CurveSpeedPointProtocol {

    public func debugDescription() {
        debugPrint("[曲线变速] VBL 返回曲线信息 index:\(index) speed:\(speed) time:\(time) duration:\(duration) speedType:\(speedType) tag:\(tag)")
    }

}

@objc public protocol CurveDrawViewDelegate: NSObjectProtocol {

    func curveDrawViewDidClickMenu(menuType: PointControl.MenuType, index: Int, curveDraw: CurveDrawView) -> Bool
    func curveDrawViewDidSelectControlPoint(index: Int, curveDraw: CurveDrawView)
    func curveDrawViewDidDeselectControlPoint(index: Int, curveDraw: CurveDrawView)

    /// 标尺发生移动的回调
    /// - Parameters:
    ///   - index: 当前pointControl的索引, -1代表没有选中
    ///   - pointControl: 当前pointControl，为空则说明标尺不在控制点上,
    ///     - `PointControl` 信息可以从 `PointControl.info` 中获取
    ///   - curveDraw: CurveDrawView description
    func curveDrawViewMarklineDidMoved(index: Int, pointControl point: PointControl?, curveDraw: CurveDrawView)

    /// 控制点将要移动
    /// - Parameters:
    ///   - index: 当前pointControl的索引
    ///   - pointControl: 当前pointControl
    ///     - `PointControl` 信息可以从 `PointControl.info` 中获取
    ///   - curveDraw: CurveDrawView description
    func curveDrawViewControlPointWillMove(index: Int, pointControl point: PointControl, curveDraw: CurveDrawView)

    /// 控制点正在移动
    /// - Parameters:
    ///   - index: 当前pointControl的索引
    ///   - pointControl: 当前pointControl
    ///     - `PointControl` 信息可以从 `PointControl.info` 中获取
    ///   - curveDraw: CurveDrawView description
    func curveDrawViewControlPointMoving(index: Int, pointControl point: PointControl, curveDraw: CurveDrawView)

    /// 控制点结束移动
    /// - Parameters:
    ///   - index: 当前pointControl的索引
    ///   - pointControl: 当前pointControl
    ///     - `PointControl` 信息可以从 `PointControl.info` 中获取
    ///   - curveDraw: CurveDrawView description
    func curveDrawViewControlPointEndMove(index: Int, pointControl point: PointControl, curveDraw: CurveDrawView)

    /// 控制点将要绘制
    /// - Parameters:
    ///   - index: 当前pointControl的索引
    ///   - pointControl: 当前pointControl
    ///     - `PointControl` 信息可以从 `PointControl.info` 中获取
    ///   - curveDraw: CurveDrawView description
    /// - Returns: 控制点外观类型
    func curveDrawViewControlPointWillDraw(index: Int, pointControl point: PointControl, curveDraw: CurveDrawView) -> PointControl.IndicatorType

    /// 双击
    func curveDrawViewControlDoubleClick(index: Int, pointControl point: PointControl, curveDraw: CurveDrawView)

}

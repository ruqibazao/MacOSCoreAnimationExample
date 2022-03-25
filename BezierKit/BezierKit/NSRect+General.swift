//
//  NSRect.swift
//  BezierKit
//
//  Created by nenhall on 2022/3/25.
//

import Foundation

extension NSRect {

    /// 根据中心点和长宽创建矩形
    init(center: CGPoint, size: CGSize) {
        self.init()
        self.size = size
        self.center = center
    }

    /// rect中心点Point
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2)
        }
    }

}

extension NSPoint {

    @discardableResult
    func center(_ radius: CGFloat) -> NSPoint {
        let center = NSPoint(x: x - radius, y: y - radius)
        return center
    }

}

//
//  NSBezierPath+Exend.m
//  BezierKit
//
//  Created by nenhall on 2021/8/2.
//

#import "NSBezierPath+Exend.h"

@implementation NSBezierPath (Exend)

- (CGPathRef)cgPath {
    NSInteger i;
    CGPathRef immutablePath = NULL;
    NSInteger numElements = [self elementCount];
    
    if (numElements > 0) {
        CGMutablePathRef path = CGPathCreateMutable();
        NSPoint points[3];
        BOOL didClosePath = NO;

        for(i = 0; i < numElements; i++) {
            switch ([self elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path,NULL, points[0].x, points[0].y);
                    break;
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path,NULL, points[0].x, points[0].y);
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path,NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    break;
                case NSClosePathBezierPathElement:
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath) CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    return immutablePath;
}

@end

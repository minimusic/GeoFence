//
//  FenceView.swift
//  GeoFence
//
//  Created by Chad on 10/27/17.
//  Copyright © 2017 LintLabs. All rights reserved.
//

import UIKit

class FenceView: UIView {

    struct touchOnView {
        var touch: UITouch
        var offset: CGPoint // don't think this is used now
    }
    
    var trackedTouches = [touchOnView]()
    var touchAnchor: CGPoint = CGPoint()
    var xAxisLocked = false
    var stretchOffset: CGFloat = 0.0
    var stretchSize: CGSize = CGSize()
    var startAngle: CGFloat = 0.0
    var startTransform: CGAffineTransform = CGAffineTransform.identity
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubview(toFront: self)
        // Do we need to track offset for each touch? maybe not
        for touch in touches {
            let newPosition = touch.location(in: self.superview)
            let newOffset = CGPoint(x: self.center.x - newPosition.x, y: self.center.y - newPosition.y)
            let newTouch = touchOnView(touch: touch, offset: newOffset)
            if trackedTouches.count >= 1 {
                // We are already tracking at least one touch on this view
                
                // Set up for stretching on one axis
                let firstLocation = trackedTouches[0].touch.location(in: self)
                let newLocation = touch.location(in: self)
                let deltaLocation = CGPoint(x: newLocation.x - firstLocation.x, y: newLocation.y - firstLocation.y)
                if abs(deltaLocation.x) > abs(deltaLocation.y) {
                    //we are adjusting width
                    self.xAxisLocked = false
                    stretchOffset = abs(deltaLocation.x)
                }
                else {
                    // we are adjusting height
                    self.xAxisLocked = true
                    stretchOffset = abs(deltaLocation.y)
                }
                stretchSize = self.bounds.size
                
                // Set up for rotation
                let superPosition = trackedTouches[0].touch.location(in: self.superview)
                let deltaPosition = CGPoint(x: newPosition.x - superPosition.x, y: newPosition.y - superPosition.y)
                self.startAngle = CGFloat(atan2f(Float(deltaPosition.y), Float(deltaPosition.x)))
                self.startTransform = self.transform
            }
            trackedTouches.append(newTouch)
        }
        // put in "updateAnchor" func
        updateAnchor()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        for touch in touches {
            for existingTouch: touchOnView in trackedTouches {
                if existingTouch.touch == touch {
         
                }
            }
        }
         */
        
        // we only want to update view position once for all moved touches
        if trackedTouches.count == 1 {
            //let firstPoint = trackedTouches[0].touch.location(in: self.superview)
            let newPosition = trackedTouches[0].touch.location(in: self.superview)
            self.center = CGPoint(x: newPosition.x + touchAnchor.x, y: newPosition.y + touchAnchor.y)
        }
        else if trackedTouches.count > 1 {
            let firstPoint = trackedTouches[0].touch.location(in: self.superview)
            let secondPoint = trackedTouches[1].touch.location(in: self.superview)
            let firstLocal = trackedTouches[0].touch.location(in: self)
            let secondLocal = trackedTouches[1].touch.location(in: self)
            let newPosition = midPointBetween(firstPoint, and:secondPoint)
            self.center = CGPoint(x: newPosition.x + touchAnchor.x, y: newPosition.y + touchAnchor.y)
            // stretch
            let deltaLocal = CGPoint(x: secondLocal.x - firstLocal.x, y: secondLocal.y - firstLocal.y)
            if self.xAxisLocked {
                //we are adjusting height
                let newOffset = abs(deltaLocal.y)
                let deltaOffset = newOffset - stretchOffset
                self.bounds = CGRect(x: 0, y: 0, width: stretchSize.width, height: stretchSize.height + deltaOffset)
            }
            else {
                // we are adjusting width
                let newOffset = abs(deltaLocal.x)
                let deltaOffset = newOffset - stretchOffset
                self.bounds = CGRect(x: 0, y: 0, width: stretchSize.width + deltaOffset, height: stretchSize.height)
            }
            // rotation
            let deltaLocation = CGPoint(x: secondPoint.x - firstPoint.x, y: secondPoint.y - firstPoint.y)
            let newAngle: CGFloat = CGFloat(atan2f(Float(deltaLocation.y), Float(deltaLocation.x)))
            let rotationTransform = CGAffineTransform.init(rotationAngle: (newAngle - self.startAngle))
            self.transform = self.startTransform.concatenating(rotationTransform)

            //self.transform = rotationTransform
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // remove touch from array
        for touch in touches {
            var newTouches = [touchOnView]()
            for existingTouch: touchOnView in trackedTouches {
                if existingTouch.touch != touch {
                    newTouches.append(existingTouch)
                }
            }
            self.trackedTouches = newTouches
        }
        if trackedTouches.count == 0 {
            // delete if we're behind toolbar
            // call delegate func?
        }
        else {
            updateAnchor()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // remove touch from array
        for touch in touches {
            var newTouches = [touchOnView]()
            for existingTouch: touchOnView in trackedTouches {
                if existingTouch.touch != touch {
                    newTouches.append(existingTouch)
                }
            }
            self.trackedTouches = newTouches
        }
        updateAnchor()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if trackedTouches.count > 0 {
            // If we are already tracking 1+ touches on this view, extend touchable area
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    func updateAnchor() {
        // The offset used to move the view's center
        if trackedTouches.count == 1 {
            let newPosition = trackedTouches[0].touch.location(in: self.superview)
            touchAnchor = CGPoint(x: self.center.x - newPosition.x, y: self.center.y - newPosition.y)
        }
        else if trackedTouches.count > 1 {
            // If multi-touch, anchor translation by mid-point
            let firstPoint = trackedTouches[0].touch.location(in: self.superview)
            let secondPoint = trackedTouches[1].touch.location(in: self.superview)
            let midPoint = midPointBetween(firstPoint, and:secondPoint)
            touchAnchor = CGPoint(x: self.center.x - midPoint.x, y: self.center.y - midPoint.y)
        }
    }
    
    func midPointBetween(_ firstPoint: CGPoint, and secondPoint: CGPoint) -> CGPoint {
        let sumPosition = CGPoint(x: firstPoint.x + secondPoint.x, y: firstPoint.y + secondPoint.y)
        return (CGPoint(x: sumPosition.x * 0.5, y: sumPosition.y * 0.5))
    }
}

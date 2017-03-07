//
//  CircularLoaderView.swift
//  intervalClock
//
//  Created by David Milliner on 3/6/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit


class CircularLoaderView: UIView {
    
    let circlePathLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    func configure() {
        if(bounds.height > bounds.width){
            circlePathLayer.frame = CGRect(x: 0, y: 0, width: bounds.width-16, height: bounds.width-16)
        } else {
            circlePathLayer.frame = CGRect(x: 0, y: 0, width: bounds.height-16, height: bounds.height-16)
        }
        circlePathLayer.lineWidth = 14
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.white.cgColor
//        circlePathLayer.borderColor = UIColor.lightGray.cgColor
//        circlePathLayer.borderWidth = 2
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.clear
        progress = 0
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: bounds.width-16, height: bounds.width-16)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            circlePathLayer.strokeEnd = newValue > 1 ? 1 : newValue < 0 ? 0 : newValue
        }
    }
}


//
//  SnowView.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

//A subclass of UIView, shows a UIView with transparent background and falling snow
class SnowView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clear
        let emitter = layer as! CAEmitterLayer
        emitter.emitterPosition = CGPoint(x: bounds.size.width / 2, y: 0)
        emitter.emitterSize = bounds.size
        emitter.emitterShape = kCAEmitterLayerRectangle
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "snow")!.cgImage
        emitterCell.birthRate = 220
        emitterCell.lifetime = 4
        emitterCell.yAcceleration = 60
        emitterCell.xAcceleration = 0
        emitterCell.velocity = 10
        emitterCell.velocityRange = 500
        emitterCell.emissionRange = CGFloat(Double.pi)
        emitterCell.emissionLongitude = CGFloat(-Double.pi)

        emitterCell.scale = 0.4
        emitterCell.scaleRange = 1.20
        emitterCell.scaleSpeed = -0.25
        emitterCell.alphaRange = 0.5
        emitterCell.alphaSpeed = -0.2
        
        emitter.emitterCells = [emitterCell]
    }
    
    override class var layerClass: AnyClass {
        return CAEmitterLayer.self
    }
}


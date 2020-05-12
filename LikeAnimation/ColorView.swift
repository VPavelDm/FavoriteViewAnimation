//
//  ColorView.swift
//  LikeAnimation
//
//  Created by Pavel Vaitsikhouski on 5/12/20.
//  Copyright © 2020 Pavel Vaitsikhouski. All rights reserved.
//

import UIKit

class ColorView: UIView {
    // MARK: - Initializers
    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      commonInit()
    }
    
    private func commonInit() {
      layer.addSublayer(createReplicatorLayer())
    }

    // MARK: - Layers
    private func createSquareLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        layer.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor
        return layer
    }
    
    private func createReplicatorLayer() -> CAReplicatorLayer {
        let layer = CAReplicatorLayer()
        layer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 30)
        layer.addSublayer(createSquareLayer())
        let count = Int(bounds.size.width / 60)
        layer.instanceCount = count
        layer.instanceTransform = CATransform3DMakeTranslation(40, 0, 0)
        let offset = -1 / Float(count)
//        layer.instanceRedOffset = offset
        layer.instanceBlueOffset = offset
//        layer.instanceGreenOffset = offset
        return layer
    }
}

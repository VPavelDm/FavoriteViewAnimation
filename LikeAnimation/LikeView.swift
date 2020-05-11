//
//  LikeView.swift
//  LikeAnimation
//
//  Created by Pavel Vaitsikhouski on 5/11/20.
//  Copyright © 2020 Pavel Vaitsikhouski. All rights reserved.
//

import UIKit
import SnapKit

class LikeView: UIView {
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
    setupConstraints()
    addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Layers
  private lazy var redCircleLayer: CAShapeLayer = {
    createCircleLayer(with: .red)
  }()
  
  private lazy var whiteCircleLayer: CAShapeLayer = {
    createCircleLayer(with: .white)
  }()
  
  private func createCircleLayer(with color: UIColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(roundedRect: self.bounds,
                              cornerRadius: self.bounds.height / 2).cgPath
    layer.frame = self.bounds
    layer.fillColor = color.cgColor
    self.layer.addSublayer(layer)
    return layer
  }
  
  // MARK: - Views
  private lazy var likeIV: UIImageView = {
    let image = UIImage(named: "like")
    let imageView = UIImageView(image: image)
    
    addSubview(imageView)
    
    return imageView
  }()
  
  // MARK: - Constraints
  private func setupConstraints() {
    likeIV.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
    })
  }
  
  // MARK: - Gestures
  private lazy var tapGesture: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLikeView))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1
    return tap
  }()
  
  // MARK: - Actions
  @objc private func didTapLikeView() {
    fadeOutLikeView()
  }
  
  private func fadeOutLikeView() {
    let anim = CABasicAnimation(keyPath: "opacity")
    anim.delegate = self
    anim.toValue = 1 - likeIV.layer.opacity
    anim.duration = 0.5
    anim.fillMode = .both
    anim.setValue(AnimationKeys.fadeOutLike,
                  forKey: AnimationKeys.animationName.rawValue)
    likeIV.layer.add(anim, forKey: nil)
  }
  
  private func fadeInRedCircle() {
    let anim = CABasicAnimation(keyPath: "transform.scale")
    anim.delegate = self
    anim.fromValue = 0
    anim.toValue = 1
    anim.duration = 0.5
    anim.fillMode = .both
    anim.setValue(AnimationKeys.redCircleFadeIn,
                  forKey: AnimationKeys.animationName.rawValue)
    redCircleLayer.add(anim, forKey: nil)
  }
  
  private func fadeInWhiteCircle() {
    let anim = CABasicAnimation(keyPath: "transform.scale")
    anim.delegate = self
    anim.fromValue = 0
    anim.toValue = 1
    anim.duration = 0.5
    anim.fillMode = .both
    anim.setValue(AnimationKeys.whiteCircleFadeIn,
                  forKey: AnimationKeys.animationName.rawValue)
    whiteCircleLayer.add(anim, forKey: nil)
  }
  
  private func fadeInLikeView() {
    let anim = CABasicAnimation(keyPath: "transform.scale")
    anim.delegate = self
    anim.fromValue = 0
    anim.toValue = 1
    anim.duration = 0.5
    anim.fillMode = .both
    anim.setValue(AnimationKeys.whiteCircleFadeIn,
                  forKey: AnimationKeys.animationName.rawValue)
    likeIV.layer.add(anim, forKey: nil)
  }
}

extension LikeView: CAAnimationDelegate {
  enum AnimationKeys: String {
    case animationName
    case fadeOutLike
    case fadeInLike
    case redCircleFadeIn
    case whiteCircleFadeIn
  }
  
  func animationDidStart(_ anim: CAAnimation) {
    typealias Keys = AnimationKeys
    guard let key = anim.value(forKey: Keys.animationName.rawValue) as? Keys else {
      return
    }
    switch key {
    case .fadeInLike:
      likeIV.isHidden = false
    default:
      break
    }
  }
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    typealias Keys = AnimationKeys
    guard let key = anim.value(forKey: Keys.animationName.rawValue) as? Keys else {
      return
    }
    switch key {
    case .fadeOutLike:
      likeIV.isHidden = true
      fadeInRedCircle()
    case .redCircleFadeIn:
      fadeInWhiteCircle()
    case .whiteCircleFadeIn:
      redCircleLayer.isHidden = true
      whiteCircleLayer.isHidden = true
    default:
      break
    }
  }
}

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
    let likeFadeOut = CABasicAnimation(keyPath: "opacity")
    likeFadeOut.delegate = self
    likeFadeOut.toValue = 1 - likeIV.layer.opacity
    likeFadeOut.duration = 0.5
    likeFadeOut.fillMode = .both
    likeFadeOut.setValue(AnimationKeys.fadeOut.rawValue,
                         forKey: AnimationKeys.animationName.rawValue)
    likeIV.layer.add(likeFadeOut, forKey: nil)
  }
  
  private func fadeInRedCircle() {
    let redCircleSize = CABasicAnimation(keyPath: "transform.scale")
    redCircleSize.delegate = self
    redCircleSize.fromValue = 0
    redCircleSize.toValue = 1
    redCircleSize.duration = 0.5
    redCircleSize.fillMode = .both
    redCircleSize.setValue(AnimationKeys.redCircleFadeIn.rawValue,
                           forKey: AnimationKeys.animationName.rawValue)
    redCircleLayer.add(redCircleSize, forKey: nil)
  }
  
  private func fadeInWhiteCircle() {
    let whiteCircleSize = CABasicAnimation(keyPath: "transform.scale")
    whiteCircleSize.delegate = self
    whiteCircleSize.fromValue = 0
    whiteCircleSize.toValue = 1
    whiteCircleSize.duration = 0.5
    whiteCircleSize.fillMode = .both
    whiteCircleSize.setValue(AnimationKeys.whiteCircleFadeIn.rawValue,
                             forKey: AnimationKeys.animationName.rawValue)
    whiteCircleLayer.add(whiteCircleSize, forKey: nil)
  }
}

extension LikeView: CAAnimationDelegate {
  enum AnimationKeys: String {
    case animationName
    case fadeOut
    case redCircleFadeIn
    case whiteCircleFadeIn
  }
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    typealias Keys = AnimationKeys
    guard let name = anim.value(forKey: Keys.animationName.rawValue) as? String else {
      return
    }
    guard let key = Keys(rawValue: name) else {
      return
    }
    switch key {
    case .fadeOut:
      likeIV.layer.opacity = 1 - likeIV.layer.opacity
      fadeInRedCircle()
    case .redCircleFadeIn:
      fadeInWhiteCircle()
    case .whiteCircleFadeIn:
      break
    default:
      return
    }
  }
}

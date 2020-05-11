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
  // MARK: - Constraints
  private let duration: CFTimeInterval = 0.15
  
  // MARK: - Properties
  private var isAnimationInProgress = false
  var isFilled: Bool = false {
    didSet {
      changeLikeState(isFilled: isFilled)
    }
  }
  
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
    layer.addSublayer(likeLayer)
    layer.addSublayer(dotsLayer)
    changeLikeState(isFilled: isFilled)
    addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Layers
  private lazy var likeLayer: CALayer = CALayer()
  
  private lazy var redCircleLayer: CAShapeLayer = {
    createCircleLayer(with: .red)
  }()
  
  private lazy var whiteCircleLayer: CAShapeLayer = {
    createCircleLayer(with: .white)
  }()
  
  private lazy var dotsLayer: CALayer = {
    let layer = CAReplicatorLayer()
    layer.isHidden = true
    layer.frame = bounds
    layer.addSublayer(dotLayer)
    let dotsCount = 8
    layer.instanceCount = dotsCount
    let angle = CGFloat.pi * 2 / CGFloat(dotsCount)
    layer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    let colorOffset: Float = -0.5
    layer.instanceRedOffset = colorOffset
    layer.instanceGreenOffset = colorOffset
    layer.instanceBlueOffset = colorOffset
    return layer
  }()
  
  private lazy var dotLayer: CALayer = {
    let width: CGFloat = 5
    let height: CGFloat = 5
    let layer = CALayer()
    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    layer.backgroundColor = UIColor.red.cgColor
    layer.cornerRadius = width / 2
    return layer
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
  
  private func changeLikeState(isFilled: Bool) {
    let maskLayer = CALayer()
    maskLayer.frame = bounds
    maskLayer.contents = UIImage(named: isFilled ? "like.fill" : "like")?.cgImage
    likeLayer.frame = bounds
    likeLayer.mask = maskLayer
    likeLayer.backgroundColor = UIColor.red.cgColor
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
    guard !isAnimationInProgress else { return }
    if isFilled {
      isFilled.toggle()
    } else {
      fadeOutLikeView()
    }
  }
  
  private func fadeOutLikeView() {
    let anim = CABasicAnimation(keyPath: "opacity")
    anim.delegate = self
    anim.toValue = 1 - likeLayer.opacity
    anim.duration = duration
    anim.fillMode = .both
    anim.setValue(AnimationKeys.fadeOutLike,
                  forKey: AnimationKeys.animationName.rawValue)
    likeLayer.add(anim, forKey: nil)
  }
  
  private func fadeInRedCircle() {
    let anim = CABasicAnimation(keyPath: "transform.scale")
    anim.delegate = self
    anim.fromValue = 0
    anim.toValue = 1
    anim.duration = duration
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
    anim.duration = duration
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
    anim.duration = duration
    anim.fillMode = .both
    anim.setValue(AnimationKeys.fadeInLike,
                  forKey: AnimationKeys.animationName.rawValue)
    likeLayer.add(anim, forKey: nil)
  }
  
  private func makeFireworks() {
    let opacityAnim = CABasicAnimation(keyPath: "opacity")
    opacityAnim.toValue = 0
    
    let positionAnim = CABasicAnimation(keyPath: "position")
    let currentPosition = dotLayer.position
    positionAnim.toValue = NSValue(cgPoint: .init(x: currentPosition.x - 5,
                                                  y: currentPosition.y - 5))
    
    let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
    scaleAnim.fromValue = 0
    scaleAnim.toValue = 1.5
    
    let anim = CAAnimationGroup()
    anim.delegate = self
    anim.animations = [opacityAnim, positionAnim, scaleAnim]
    anim.duration = 2 * duration
    anim.fillMode = .both
    anim.setValue(AnimationKeys.moveFireworks,
                  forKey: AnimationKeys.animationName.rawValue)
    anim.isRemovedOnCompletion = false
    
    dotLayer.add(anim, forKey: nil)
  }
}

extension LikeView: CAAnimationDelegate {
  enum AnimationKeys: String {
    case animationName
    case fadeOutLike
    case fadeInLike
    case redCircleFadeIn
    case whiteCircleFadeIn
    case moveFireworks
  }
  
  func animationDidStart(_ anim: CAAnimation) {
    typealias Keys = AnimationKeys
    guard let key = anim.value(forKey: Keys.animationName.rawValue) as? Keys else {
      return
    }
    isAnimationInProgress = true
    switch key {
    case .fadeInLike:
      likeLayer.isHidden = false
      isFilled.toggle()
    case .redCircleFadeIn:
      redCircleLayer.isHidden = false
    case .whiteCircleFadeIn:
      whiteCircleLayer.isHidden = false
    case .moveFireworks:
      dotsLayer.isHidden = false
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
      likeLayer.isHidden = true
      fadeInRedCircle()
    case .redCircleFadeIn:
      fadeInWhiteCircle()
    case .whiteCircleFadeIn:
      redCircleLayer.isHidden = true
      whiteCircleLayer.isHidden = true
      fadeInLikeView()
    case .fadeInLike:
      makeFireworks()
    case .moveFireworks:
      dotsLayer.isHidden = true
      dotLayer.removeAllAnimations()
      isAnimationInProgress = false
    default:
      break
    }
  }
}

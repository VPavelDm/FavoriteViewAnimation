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
    movableDotsLayers.forEach({ layer in
      self.layer.addSublayer(layer)
    })
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
  
  private lazy var movableDotsLayers: [CALayer] = {
    movableDotLayers
      .enumerated()
      .map({ (index, dotLayer) -> CALayer in
        let layer = createDotsLayer(itemLayer: dotLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat.pi * 2 + CGFloat(index * 4), 0, 0, 1)
        return layer
      })
  }()
  
  private lazy var movableDotLayers: [CALayer] = {
    [createDotLayer(width: 5, height: 5),
     createDotLayer(width: 10, height: 10)]
  }()
  
  private func createDotLayer(width: CGFloat, height: CGFloat) -> CALayer {
    let layer = CALayer()
    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    layer.backgroundColor = UIColor.red.cgColor
    layer.cornerRadius = width / 2
    layer.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor
    return layer
  }
  
  private func createDotsLayer(itemLayer: CALayer) -> CAReplicatorLayer {
    let layer = CAReplicatorLayer()
    layer.isHidden = true
    layer.frame = bounds
    layer.addSublayer(itemLayer)
    let dotsCount = 7
    layer.instanceCount = dotsCount
    let angle = CGFloat.pi * 2 / CGFloat(dotsCount)
    layer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    let offset = -1 / Float(dotsCount)
    layer.instanceBlueOffset = offset
    return layer
  }
  
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
    movableDotLayers
      .enumerated()
      .forEach({ (index, dotLayer) in
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.toValue = 0.0
        
        let positionAnim = CAKeyframeAnimation(keyPath: "position")
        let currentPosition = dotLayer.position
        let fCoefficient = Int(bounds.width / 6)
        let sCoefficient = fCoefficient / 2
        let firstPosition = CGPoint(x: currentPosition.x - CGFloat(fCoefficient * (index + 1)),
                                    y: currentPosition.y - CGFloat(fCoefficient * (index + 1)))
        let secondPosition = CGPoint(x: firstPosition.x - CGFloat(sCoefficient * (index + 1)),
                                     y: firstPosition.y - CGFloat(sCoefficient * (index + 1)))
        positionAnim.values = [NSValue(cgPoint: firstPosition), NSValue(cgPoint: secondPosition)]
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 0.0
        
        let anim = CAAnimationGroup()
        anim.delegate = self
        anim.animations = [opacityAnim, positionAnim, scaleAnim]
        anim.duration = duration
        anim.speed = 0.2
        anim.fillMode = .both
        anim.setValue(AnimationKeys.moveFireworks,
                      forKey: AnimationKeys.animationName.rawValue)
        anim.isRemovedOnCompletion = false
        
        dotLayer.add(anim, forKey: nil)
      })
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
      movableDotsLayers.forEach({ layer in
        layer.isHidden = false
      })
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
      movableDotsLayers.forEach({ layer in
        layer.isHidden = true
      })
      movableDotLayers.forEach({ layer in
        layer.removeAllAnimations()
      })
      isAnimationInProgress = false
    default:
      break
    }
  }
}

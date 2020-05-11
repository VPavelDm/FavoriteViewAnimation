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
    print("Like view is clicked")
  }
}

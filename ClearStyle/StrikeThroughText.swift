//
//  StrikeThroughText.swift
//  ClearStyle
//
//  Created by Daniel Flax on 4/14/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import QuartzCore

// A UITextField subclass that can optionally have a strikethrough - and is editable
class StrikeThroughText: UITextField {

	let strikeThroughLayer: CALayer

	// A Boolean value that determines whether the label should have a strikethrough.
	var strikeThrough : Bool {
		didSet {
			strikeThroughLayer.hidden = !strikeThrough
			if strikeThrough {
				resizeStrikeThrough()
			}
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}

	override init(frame: CGRect) {
		strikeThroughLayer = CALayer()
		strikeThroughLayer.backgroundColor = UIColor.whiteColor().CGColor
		strikeThroughLayer.hidden = true
		strikeThrough = false

		super.init(frame: frame)
		layer.addSublayer(strikeThroughLayer)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		resizeStrikeThrough()
	}

	let kStrikeOutThickness: CGFloat = 2.0
	func resizeStrikeThrough() {
		let textSize = text!.sizeWithAttributes([NSFontAttributeName:font])
		strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2,
			width: textSize.width, height: kStrikeOutThickness)
	}

}
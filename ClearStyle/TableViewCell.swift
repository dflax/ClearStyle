//
//  TableViewCell.swift
//  ClearStyle
//
//  Created by Daniel Flax on 4/13/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import QuartzCore

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
	// indicates that the given item has been deleted
	func toDoItemDeleted(todoItem: ToDoItem)
}

class TableViewCell: UITableViewCell {

	// Gradient layer properties
	let gradientLayer = CAGradientLayer()

	// Gesture recognizer properties
	var originalCenter = CGPoint()

	// Whether to drag on release AND whether to complete on release - the left/right pan gesture results
	var deleteOnDragRelease = false, completeOnDragRelease = false

	// For strike through text
	let label: StrikeThroughText
	let itemCompleteLayer = CALayer()

	// will aid with the delegate protocol
	// The object that acts as delegate for this cell.
	var delegate: TableViewCellDelegate?

	// The item that this cell renders.
	var toDoItem: ToDoItem? {
		didSet {
			label.text = toDoItem!.text
			label.strikeThrough = toDoItem!.completed
			itemCompleteLayer.hidden = !label.strikeThrough
		}
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

		// create a label that renders the to-do item text
		label = StrikeThroughText(frame: CGRect.nullRect)
		label.textColor = UIColor.whiteColor()
		label.font = UIFont.boldSystemFontOfSize(16)
		label.backgroundColor = UIColor.clearColor()

		super.init(style: style, reuseIdentifier: reuseIdentifier)

		// set up the strike through text label
		addSubview(label)
		// remove the default blue highlight for selected cells
		selectionStyle = .None

		// Gradient layer for cell
		gradientLayer.frame = bounds
		let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
		let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
		let color3 = UIColor.clearColor().CGColor as CGColorRef
		let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
		gradientLayer.colors = [color1, color2, color3, color4]
		gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
		layer.insertSublayer(gradientLayer, atIndex: 0)

		// add a layer that renders a green background when an item is complete
		itemCompleteLayer = CALayer(layer: layer)
		itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
		itemCompleteLayer.hidden = true
		layer.insertSublayer(itemCompleteLayer, atIndex: 0)

		// add a pan recognizer
		var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
		recognizer.delegate = self
		addGestureRecognizer(recognizer)
	}

	// Layout the subviews
	let kLabelLeftMargin: CGFloat = 15.0
	override func layoutSubviews() {
		super.layoutSubviews()
		// ensure the gradient layer occupies the full bounds
		gradientLayer.frame = bounds
		itemCompleteLayer.frame = bounds
		label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
	}

	// MARK: - horizontal pan gesture methods
	func handlePan(recognizer: UIPanGestureRecognizer) {

		// 1
		if recognizer.state == .Began {
			// when the gesture begins, record the current center location
			originalCenter = center
		}

		// 2
		if recognizer.state == .Changed {
			let translation = recognizer.translationInView(self)
			center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
			// has the user dragged the item far enough to initiate a delete/complete?
			deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
			completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
		}

		// 3
		if recognizer.state == .Ended {
			let originalFrame = CGRect(x: 0, y: frame.origin.y,
				width: bounds.size.width, height: bounds.size.height)
			if deleteOnDragRelease {
				if delegate != nil && toDoItem != nil {
					// notify the delegate that this item should be deleted
					delegate!.toDoItemDeleted(toDoItem!)
				}
			} else if completeOnDragRelease {
				if toDoItem != nil {
					toDoItem!.completed = true
				}
				label.strikeThrough = true
				itemCompleteLayer.hidden = false
				UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
			} else {
				UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
			}
		}
	}

	override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
			let translation = panGestureRecognizer.translationInView(superview!)
			if fabs(translation.x) > fabs(translation.y) {
				return true
			}
			return false
		}
		return false
	}

}
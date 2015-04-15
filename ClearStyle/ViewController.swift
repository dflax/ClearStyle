//
//  ViewController.swift
//  ClearStyle
//
//  Created by Daniel Flax on 4/13/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {

	@IBOutlet weak var tableView: UITableView!
	var toDoItems = [ToDoItem]()

	// To enable pinch to add-new functionality
	let pinchRecognizer = UIPinchGestureRecognizer()

	override func viewDidLoad() {
		super.viewDidLoad()

		// For the pinch-to-add-new functionality
		pinchRecognizer.addTarget(self, action: "handlePinch:")
		tableView.addGestureRecognizer(pinchRecognizer)

		// Set up the TableView stuff
		tableView.dataSource = self
		tableView.delegate = self
		tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.separatorStyle = .None
		tableView.backgroundColor = UIColor.blackColor()
		tableView.rowHeight = 50.0

		if toDoItems.count > 0 {
			return
		}
		toDoItems.append(ToDoItem(text: "feed the cat"))
		toDoItems.append(ToDoItem(text: "buy eggs"))
		toDoItems.append(ToDoItem(text: "watch WWDC videos"))
		toDoItems.append(ToDoItem(text: "rule the Web"))
		toDoItems.append(ToDoItem(text: "buy a new iPhone"))
		toDoItems.append(ToDoItem(text: "darn holes in socks"))
		toDoItems.append(ToDoItem(text: "write this tutorial"))
		toDoItems.append(ToDoItem(text: "master Swift"))
		toDoItems.append(ToDoItem(text: "learn to draw"))
		toDoItems.append(ToDoItem(text: "get more exercise"))
		toDoItems.append(ToDoItem(text: "catch up with Mom"))
		toDoItems.append(ToDoItem(text: "get a hair cut"))
	}

	// MARK: - UITableView Data Source methods
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
 
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return toDoItems.count
	}
 
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as TableViewCell
		cell.selectionStyle = .None
//		cell.textLabel?.backgroundColor = UIColor.clearColor()

		let item = toDoItems[indexPath.row]
//		cell.textLabel?.text = item.text

		// For the TableViewCell delegate protocol
		cell.delegate = self
		cell.toDoItem = item

		return cell
	}

	// Necessary for older versions of iOS
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableView.rowHeight;
	}

	// MARK: - TableViewCellDelegate methods

	func toDoItemAdded() {
		let toDoItem = ToDoItem(text: "")
		toDoItems.insert(toDoItem, atIndex: 0)
		tableView.reloadData()

		// enter edit mode
		var editCell: TableViewCell
		let visibleCells = tableView.visibleCells() as [TableViewCell]
		for cell in visibleCells {
			if (cell.toDoItem === toDoItem) {
				editCell = cell
				editCell.label.becomeFirstResponder()
				break
			}
		}
	}

	func cellDidBeginEditing(editingCell: TableViewCell) {
		var editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
		let visibleCells = tableView.visibleCells() as [TableViewCell]
		for cell in visibleCells {
			UIView.animateWithDuration(0.3, animations: {() in
				cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
				if cell !== editingCell {
					cell.alpha = 0.3
				}
			})
		}
	}

	func cellDidEndEditing(editingCell: TableViewCell) {
		let visibleCells = tableView.visibleCells() as [TableViewCell]
		for cell: TableViewCell in visibleCells {
			UIView.animateWithDuration(0.3, animations: {() in
				cell.transform = CGAffineTransformIdentity
				if cell !== editingCell {
					cell.alpha = 1.0
				}
			})
		}
		if editingCell.toDoItem!.text == "" {
			toDoItemDeleted(editingCell.toDoItem!)
		}
	}

	func toDoItemDeleted(toDoItem: ToDoItem) {

		let index = (toDoItems as NSArray).indexOfObject(toDoItem)
		if index == NSNotFound { return }

		// could removeAtIndex in the loop but keep it here for when indexOfObject works
		toDoItems.removeAtIndex(index)

		// loop over the visible cells to animate delete
		let visibleCells = tableView.visibleCells() as [TableViewCell]
		let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
		var delay = 0.0
		var startAnimating = false

		for i in 0..<visibleCells.count {
			let cell = visibleCells[i]
			if startAnimating {
				UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut, animations: {() in
					cell.frame = CGRectOffset(cell.frame, 0.0, -cell.frame.size.height)}, completion: {(finished: Bool) in
						if (cell == lastView) {
							self.tableView.reloadData()
						}
					}
				)
				delay += 0.03
			}
			if cell.toDoItem === toDoItem {
				startAnimating = true
				cell.hidden = true
			}
		}

		// use the UITableView to animate the removal of this row
		tableView.beginUpdates()
		let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
		tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
		tableView.endUpdates()
	}

	// MARK: - pinch-to-add methods

	struct TouchPoints {
		var upper: CGPoint
		var lower: CGPoint
	}

	// the indices of the upper and lower cells that are being pinched
	var upperCellIndex = -100
	var lowerCellIndex = -100

	// the location of the touch points when the pinch began
	var initialTouchPoints: TouchPoints!

	// indicates that the pinch was big enough to cause a new item to be added
	var pinchExceededRequiredDistance = false

	// indicates that the pinch is in progress
	var pinchInProgress = false

	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		if recognizer.state == .Began {
			pinchStarted(recognizer)
		}

		if recognizer.state == .Changed && pinchInProgress && recognizer.numberOfTouches() == 2 {
			pinchChanged(recognizer)
		}

		if recognizer.state == .Ended {
			pinchEnded(recognizer)
		}
	}

	// Called when the pinch starts
	func pinchStarted(recognizer: UIPinchGestureRecognizer) {

		// find the touch-points
		initialTouchPoints = getNormalizedTouchPoints(recognizer)

		// locate the cells that these points touch
		upperCellIndex = -100
		lowerCellIndex = -100
		let visibleCells = tableView.visibleCells()  as [TableViewCell]
		for i in 0..<visibleCells.count {
			let cell = visibleCells[i]

			if viewContainsPoint(cell, point: initialTouchPoints.upper) {
				upperCellIndex = i

				// highlight the cell – just for debugging!
				cell.backgroundColor = UIColor.purpleColor()
			}

			if viewContainsPoint(cell, point: initialTouchPoints.lower) {
				lowerCellIndex = i

				// highlight the cell – just for debugging!
				cell.backgroundColor = UIColor.purpleColor()
			}
		}

		// check whether they are neighbors
		if abs(upperCellIndex - lowerCellIndex) == 1 {

			// initiate the pinch
			pinchInProgress = true

			// show placeholder cell
			let precedingCell = visibleCells[upperCellIndex]
			placeHolderCell.frame = CGRectOffset(precedingCell.frame, 0.0, tableView.rowHeight / 2.0)
			placeHolderCell.backgroundColor = UIColor.redColor()
			tableView.insertSubview(placeHolderCell, atIndex: 0)
		}
	}

	func pinchChanged(recognizer: UIPinchGestureRecognizer) {
	}

	func pinchEnded(recognizer: UIPinchGestureRecognizer) {
	}

	// returns the two touch points, ordering them to ensure that
	// upper and lower are correctly identified.
	func getNormalizedTouchPoints(recognizer: UIGestureRecognizer) -> TouchPoints {
		var pointOne = recognizer.locationOfTouch(0, inView: tableView)
		var pointTwo = recognizer.locationOfTouch(1, inView: tableView)

		// ensure pointOne is the top-most
		if pointOne.y > pointTwo.y {
			let temp = pointOne
			pointOne = pointTwo
			pointTwo = temp
		}
		return TouchPoints(upper: pointOne, lower: pointTwo)
	}

	func viewContainsPoint(view: UIView, point: CGPoint) -> Bool {
		let frame = view.frame
		return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
	}

	// MARK: - UIScrollViewDelegate methods
	// contains scrollViewDidScroll, and other methods, to keep track of dragging the scrollView

	// a cell that is rendered as a placeholder to indicate where a new item is added
	let placeHolderCell = TableViewCell(style: .Default, reuseIdentifier: "cell")

	// indicates the state of this behavior
	var pullDownInProgress = false

	func scrollViewWillBeginDragging(scrollView: UIScrollView!) {
		// this behavior starts when a user pulls down while at the top of the table
		pullDownInProgress = scrollView.contentOffset.y <= 0.0
		placeHolderCell.backgroundColor = UIColor.redColor()
		if pullDownInProgress {
			// add the placeholder
			tableView.insertSubview(placeHolderCell, atIndex: 0)
		}
	}

	func scrollViewDidScroll(scrollView: UIScrollView!) {
		var scrollViewContentOffsetY = scrollView.contentOffset.y

		if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
			// maintain the location of the placeholder
			placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight, width: tableView.frame.size.width, height: tableView.rowHeight)
			placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ? "Release to add item" : "Pull to add item"
			placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
		} else {
			pullDownInProgress = false
		}
	}

	func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {
		// check whether the user pulled down far enough
		if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
			if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
				toDoItemAdded()
			}
		}

		pullDownInProgress = false
		placeHolderCell.removeFromSuperview()
	}

	// MARK: - UITableView delegate methods
	func colorForIndex(index: Int) -> UIColor {
		let itemCount = toDoItems.count - 1
		let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
		return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
	}

	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndex(indexPath.row)
	}

}


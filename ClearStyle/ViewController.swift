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

	override func viewDidLoad() {
		super.viewDidLoad()

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


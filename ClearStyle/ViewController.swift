//
//  ViewController.swift
//  ClearStyle
//
//  Created by Daniel Flax on 4/13/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	var toDoItems = [ToDoItem]()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Set up the TableView stuff
		tableView.dataSource = self
		tableView.delegate = self
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

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

	// UITableView Data Source methods
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
 
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return toDoItems.count
	}
 
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
		let item = toDoItems[indexPath.row]
		cell.textLabel?.text = item.text
		return cell
	}


}


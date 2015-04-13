//
//  ToDoItem.swift
//  ClearStyle
//
//  Created by Daniel Flax on 4/13/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {

	// A text description of this item.
	var text: String

	// A Boolean value that determines the completed state of this item.
	var completed: Bool

	// Returns a ToDoItem initialized with the given text and default completed value.
	init(text: String) {
		self.text = text
		self.completed = false
	}

}

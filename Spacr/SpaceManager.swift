//
//  SpaceManager.swift
//  Spacr
//
//  Created by subli on 6/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

import Foundation
import AppKit

class SpaceManager {
	let conn = _CGSDefaultConnection()
	let maxSpaces = 16
	var count: Int = 0
	var current: Int = 0

	init() {
	}

	func update() -> Bool {
		let old_count = count
		let old_current = current
		updateSpaceInfo()
		
		if self.count != old_count || self.current != old_current {
			return true
		}
		return false
	}

	@objc func updateSpaceInfo() {
		let info = CGSCopyManagedDisplaySpaces(conn)
		print(info)
		let displayInfo = (info as! [NSDictionary])[0]
		print(displayInfo)
		let activeSpaceID = (displayInfo["Current Space"]! as! NSDictionary)["ManagedSpaceID"] as! Int
		let spaces = displayInfo["Spaces"] as! NSArray
		
		print(spaces)
		print("----------")
		for (index, space) in spaces.enumerated() {
			let spaceDict = (space as! NSDictionary)
			print(spaceDict)
			let spaceID = (space as! NSDictionary)["ManagedSpaceID"] as! Int
			print(spaceID)
			if spaceID == activeSpaceID {
				self.count = spaces.count
				self.current = index+1
//				break
			}
		}
		NSWorkspace.shared.setIcon(NSImage(named: "crescent"), forFile: /Users/, options: <#T##NSWorkspace.IconCreationOptions#>)
//		let screens = NSWorkspace.desktopImageURL(<#T##self: NSWorkspace##NSWorkspace#>)
//		for i in screens {
//			print(i)
//			let url = NSWorkspace.shared.desktopImageURL(for: i)
//			print(url)
//		}
	}
}

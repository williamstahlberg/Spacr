//
//  AppleScriptManager.swift
//  Spacr
//
//  Created by subli on 6/24/20.
//  Copyright © 2020 subli. All rights reserved.
//

import Foundation

//tell application "System Preferences" to set the bounds of the front window to {2048 / 4, 1280 / 4, 2048 / 4, 1280 / 4}

class AppleScriptManager {
	enum Modifier: String {
		case control = "control down"
		case controlOption = "{control down, option down}"
	}

	struct HotKey {
		let keyCode: Int
		let modifier: Modifier
	}
	
	static let spaceHotKeys = [
		 1: HotKey(keyCode: 18, modifier: .control),
		 2: HotKey(keyCode: 19, modifier: .control),
		 3: HotKey(keyCode: 20, modifier: .control),
		 4: HotKey(keyCode: 21, modifier: .control),
		 5: HotKey(keyCode: 23, modifier: .control),
		 6: HotKey(keyCode: 22, modifier: .control),
		 7: HotKey(keyCode: 26, modifier: .control),
		 8: HotKey(keyCode: 28, modifier: .control),
		 9: HotKey(keyCode: 25, modifier: .control),
		10: HotKey(keyCode: 29, modifier: .control),
		11: HotKey(keyCode: 18, modifier: .controlOption),
		12: HotKey(keyCode: 19, modifier: .controlOption),
		13: HotKey(keyCode: 20, modifier: .controlOption),
		14: HotKey(keyCode: 21, modifier: .controlOption),
		15: HotKey(keyCode: 23, modifier: .controlOption),
		16: HotKey(keyCode: 22, modifier: .controlOption)
	]
	
	private static func execute(script: String) {
		var error: NSDictionary?
		if let scriptObject = NSAppleScript(source: script) {
			if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
				print(outputString)
			} else if (error != nil) {
				print("AppleScript error: ", error!)
			}
		}
	}
	
	static func switchTo(space: Int) {
		guard let hotKey = spaceHotKeys[space] else {
			print("Invalid space \(space).")
			return
		}

		let script = """
			tell application "System Events"
				tell application "System Events" to key code \(hotKey.keyCode) using \(hotKey.modifier.rawValue)
			end tell
			"""
		
		execute(script: script)
	}
	
	static func activateIntroWindow() {
		let script = """
			tell application "Spacr"
				activate
			end tell
			"""
		
		execute(script: script)
	}
	
	static func openSystemPreferencesKeyboardShortcuts() {
//		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Keyboard.prefPane"))

		let script = """
			tell application "System Preferences"
				activate
				reveal anchor "shortcutsTab" of pane id "com.apple.preference.keyboard"
			end tell
			"""
		
		execute(script: script)
	}
}

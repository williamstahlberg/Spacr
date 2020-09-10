//
//  AppDelegate.swift
//  Spacr
//
//  Created by subli on 6/7/20.
//  Copyright © 2020 subli. All rights reserved.
//
// TODO:
//	* Fix licensing.
//  * Fix displayIntroWindow.

import Cocoa
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var menu: NSMenu!
	@IBOutlet weak var introductionView: NSView!
	let workspace = NSWorkspace.shared
	
	var statusBarItems: [NSStatusItem] = []
	let statusBar = NSStatusBar.system
	let spaceManager = SpaceManager()
	var timer: Timer?

	let introWindow = NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main!.frame.midX, NSScreen.main!.frame.midY), styleMask: [.closable, .miniaturizable, .titled], backing: .buffered, defer: false)

	func configureObservers() {
        workspace.notificationCenter.addObserver(
            self,
            selector: #selector(AppDelegate.update),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: workspace
        )
    }
	
	@objc func missionControlIsActive() -> Bool {
		guard let windowInfosRef = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) else {
			return false
		}
		
		var result: Bool = false
		let windowList: NSArray = windowInfosRef
		for entry in windowList {
			let e = entry as! NSDictionary
			if e["kCGWindowOwnerName"] as! String == "Dock" {
				let bounds = e["kCGWindowBounds"] as! NSDictionary
				if bounds["Y"] as! NSNumber != 0 {
					result = true
				}
			}
		}
		return result
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		initDisplay()
		updateDisplay()

		/* DEBUG */
//		UserDefaults.standard.removeObject(forKey: "launchedBefore")
//		var keys: [String] = []
//		for o in UserDefaults.standard.dictionaryRepresentation() {
//			if o.key.hasPrefix("NSStatusItem Preferred Position") {
//				keys.append(o.key)
//			}
//		}
//
//		for k in keys {
//			print(k)
//			UserDefaults.standard.removeObject(forKey: k)
//		}

		menu.removeItem(at: 0)
		/* END */
		
		let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
			displayIntroWindow()
			UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
		
		configureObservers()
		update()
		
		timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateNumberOfSpaces), userInfo: nil, repeats: true)
		timer?.fire()
		RunLoop.current.add(timer!, forMode: .common)
		
	}
	
	@objc func updateNumberOfSpaces() {
		if missionControlIsActive() {
			update()
		}
	}
	
	@objc func update() {
		let stateChanged = spaceManager.update()
		if stateChanged {
			updateDisplay()
		}
	}
	
	func displayIntroWindow() {
		introWindow.title = "Introduction"
		introWindow.isMovableByWindowBackground = true

		introWindow.makeKeyAndOrderFront(nil)
		introWindow.setFrame(introductionView.bounds, display: true)
		introWindow.center()

		introWindow.contentView?.addSubview(introductionView)
		
		AppleScriptManager.activateIntroWindow()
	}
	
	func initDisplay() {
		for i in (0..<spaceManager.maxSpaces).reversed() {
			let item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
			if i < spaceManager.count {
				item.length = 26
			} else {
				item.length = 0
			}
			item.button?.image = NSImage(named: "blank2")
			item.button?.attributedTitle = getAttributed(string: "\(i+1)")
			item.button?.action = #selector(AppDelegate.switchToSpace(sender:))
			item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
			
			statusBarItems.append(item)
		}
	}
	
	func updateDisplay() {
		for item in statusBarItems {
			if item.button?.title == "\(spaceManager.current)" {
				item.button?.image = NSImage(named: "blank2_outline")
			} else {
				item.button?.image = NSImage(named: "blank2")
			}
			
			let currentSpace = Int(item.button?.title ?? "0")!
			if currentSpace <= spaceManager.count {
				item.length = -1
			} else {
				item.length = 0
			}
		}
	}
	
	func getAttributed(string: String) -> NSAttributedString {
		let font = NSFont.systemFont(ofSize: 11)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = NSTextAlignment.center

		let attributes: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: font,
			NSAttributedString.Key.foregroundColor: NSColor.white,
			NSAttributedString.Key.baselineOffset: -1.0,
			NSAttributedString.Key.paragraphStyle: paragraphStyle,
		]
		
		let attributedString = NSAttributedString(string: string, attributes: attributes)

		return attributedString
	}
	
	@objc func switchToSpace(sender: NSStatusBarButton) {
		let event = NSApp.currentEvent!
		
		let i = (Int(sender.title) ?? 1 ) - 1
		spaceManager.updateSpaceInfo()
		
		if event.type == NSEvent.EventType.rightMouseUp || spaceManager.current == i+1 {
			for item in statusBarItems {
				if item.button === sender {
					item.menu = menu
					item.button?.performClick(nil)
					item.menu = nil
				}
			}
		} else {
			AppleScriptManager.switchTo(space: i+1)
		}
		
		update()
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
	
	func applicationWillTerminate(_ aNotification: Notification) {}
	
	@IBAction func openSysPrefsClicked(_ sender: Any) {
		AppleScriptManager.openSystemPreferencesKeyboardShortcuts()
	}
	
	@IBAction func quitClicked(_ sender: NSMenuItem) {
		NSApplication.shared.terminate(self)
	}
	
	@IBAction func showStartScreenClicked(_ sender: Any) {
		displayIntroWindow()
	}
	
	@IBAction func debugClicked(_ sender: NSMenuItem) {}
}

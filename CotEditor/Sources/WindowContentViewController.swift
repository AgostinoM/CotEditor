/*
 
 WindowContentViewController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-06-05.
 
 ------------------------------------------------------------------------------
 
 © 2016 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Cocoa

final class WindowContentViewController: NSSplitViewController {
    
    // MARK: Private Properties
    
    @IBOutlet private weak var mainViewItem: NSSplitViewItem?
    @IBOutlet private weak var sidebarViewItem: NSSplitViewItem?
    
    
    
    // MARK:
    // MARK: Split View Controller Methods
    
    /// setup view
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set behavior to glow window size on sidebar toggling rather than opening sidebar indraw (only on El Capitan or later)
        if #available(macOS 10.11, *) {
            self.sidebarViewItem?.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        }
        
        self.isSidebarShown = Defaults[.showDocumentInspector]
        self.sidebarThickness = Defaults[.sidebarWidth]
    }
    
    
    /// deliver represented object to child view controllers
    override var representedObject: Any? {
        
        didSet {
            for viewController in self.childViewControllers {
                viewController.representedObject = representedObject
            }
        }
    }
    
    
    /// store current sidebar width
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        
        if notification.userInfo?["NSSplitViewDividerIndex"] != nil {  // check wheter the change coused by user's divider dragging
            if self.isSidebarShown {
                Defaults[.sidebarWidth] = self.sidebarThickness
            }
        }
    }
    


    // MARK: Public Methods
    
    /// deliver editor to outer view controllers
    var editor: EditorWrapper? {
        
        return (self.mainViewItem?.viewController as? MainViewController)?.editor
    }
    
    
    /// display desired sidebar pane
    func showSidebarPane(index: SidebarViewController.TabIndex) {
        
        self.sidebarViewController?.tabView.selectTabViewItem(at: index.rawValue)
        self.sidebarViewItem?.animator().isCollapsed = false
    }
    
    
    
    // MARK: Action Messages
    
    /// toggle visibility of document inspector
    @IBAction func getInfo(_ sender: AnyObject?) {
        
        self.toggleVisibilityOfSidebarTabItem(index: .documentInspector)
    }
    
    
    /// toggle visibility of incompatible chars list view
    @IBAction func toggleIncompatibleCharList(_ sender: AnyObject?) {
        
        self.toggleVisibilityOfSidebarTabItem(index: .incompatibleCharacters)
    }
    
    
    
    // MARK: Private Methods
    
    /// split view item to view controller
    private var sidebarViewController: NSTabViewController? {
        
        return self.sidebarViewItem?.viewController as? NSTabViewController
    }
    
    
    /// sidebar thickness
    private var sidebarThickness: CGFloat {
        
        set (thickness) {
            self.sidebarViewController?.view.frame.size.width = thickness
        }
        get {
            return self.sidebarViewController?.view.frame.width ?? 0
        }
    }
    
    
    /// whether sidebar is opened
    private var isSidebarShown: Bool {
        
        set (shown) {
            self.siblings.forEach { sibling in
                sibling.sidebarViewItem?.isCollapsed = !shown
            }
        }
        get {
            return !(self.sidebarViewItem?.isCollapsed ?? true)
        }
    }
    
    
    /// toggle visibility of pane in sidebar
    private func toggleVisibilityOfSidebarTabItem(index: SidebarViewController.TabIndex) {
        
        let isCollapsed = self.isSidebarShown && (index.rawValue == self.sidebarViewController!.selectedTabViewItemIndex)
        
        self.siblings.forEach { sibling in
            sibling.sidebarViewController!.selectedTabViewItemIndex = index.rawValue
            sibling.sidebarViewItem!.animator().isCollapsed = isCollapsed
        }
    }
    
    
    /// window content view controllers in all tabs in the same window
    private var siblings: [WindowContentViewController]  {
        
        if #available(macOS 10.12, *) {
            return self.view.window?.tabbedWindows?.flatMap { ($0.windowController?.contentViewController as? WindowContentViewController) } ?? [self]
        } else {
            return [self]
        }
    }
    
}

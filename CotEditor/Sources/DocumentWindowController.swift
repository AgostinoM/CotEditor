/*
 
 DocumentWindowController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by nakamuxu on 2004-12-13.
 
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2013-2016 1024jp
 
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

final class DocumentWindowController: NSWindowController, NSWindowDelegate {
    
    // MARK: Private Properties
    
    @IBOutlet private var toolbarController: ToolbarController?
    
    
    
    // MARK:
    // MARK: Lifecycle
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: DefaultKeys.windowAlpha.rawValue)
    }
    
    
    
    // MARK: KVO
    
    /// apply user defaults change
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else { return }
        
        if keyPath == DefaultKeys.windowAlpha.rawValue {
            if let window = self.window as? AlphaWindow {
                window.backgroundAlpha = Defaults[.windowAlpha]
            }
        }
    }
    
    
    
    // MARK: Window Controller Methods
    
    /// prepare window
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // -> It's set as false by default if the window controller was invoked from a storyboard.
        self.shouldCascadeWindows = true
        
        let window = self.window as! AlphaWindow
        
        // set window size
        let contentSize = NSSize(width: Defaults[.windowWidth],
                                 height: Defaults[.windowHeight])
        window.setContentSize(contentSize)
        
        // setup background
        window.backgroundAlpha = Defaults[.windowAlpha]
        
        // observe opacity setting change
        UserDefaults.standard.addObserver(self, forKeyPath: DefaultKeys.windowAlpha.rawValue, context: nil)
    }
    
    
    /// apply passed-in document instance to window
    override var document: AnyObject? {
        didSet {
            guard let document = document as? Document else { return }
            
            self.toolbarController!.document = document
            self.contentViewController!.representedObject = document
            
            // apply document state to UI
            document.applyContentToWindow()
        }
    }
    
    
    
    // MARK: Public Methods
    
    /// pass editor instance to document
    var editor: EditorWrapper? {
        
        return (self.contentViewController as? WindowContentViewController)?.editor
    }
    
    
    /// show incompatible char list
    func showIncompatibleCharList() {
        
        guard let contentViewController = self.contentViewController as? WindowContentViewController else { return }
        
        contentViewController.showSidebarPane(index: .incompatibleCharacters)
    }
    
}

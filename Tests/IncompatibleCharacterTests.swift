/*
 
 IncompatibleCharacterTests.swift
 Tests
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-05-29.
 
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

import XCTest
@testable import CotEditor

final class IncompatibleCharacterTests: XCTestCase {
    
    func testIncompatibleCharacterScan() {
        
        let string = "abc\\ \n ¥ \n ~"
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.shiftJIS.rawValue)))
        let incompatibles = string.scanIncompatibleCharacters(for: encoding)
        
        XCTAssertEqual(incompatibles?.count, 2)
        
        guard let backslash = incompatibles?[0] else {
            return XCTFail()
        }
        XCTAssertEqual(backslash.character, "\\")
        XCTAssertEqual(backslash.convertedCharacter, "＼")
        XCTAssertEqual(backslash.location, 3)
        XCTAssertEqual(backslash.lineNumber, 1)
        
        guard let tilde = incompatibles?[1] else {
            return XCTFail()
        }
        XCTAssertEqual(tilde.character, "~")
        XCTAssertEqual(tilde.convertedCharacter, "?")
        XCTAssertEqual(tilde.location, 11)
        XCTAssertEqual(tilde.lineNumber, 3)
    }

}

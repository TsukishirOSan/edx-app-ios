//
//  SnapshotTestCase
//  edX
//
//  Created by Akiva Leffert on 5/14/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation

protocol SnapshotTestable {
    func snapshotTestWithCase(testCase : FBSnapshotTestCase, referenceImagesDirectory: String, identifier: String, error: NSErrorPointer) -> Bool
    
    var snapshotSize : CGSize { get }
}

extension UIView : SnapshotTestable {
    func snapshotTestWithCase(testCase : FBSnapshotTestCase, referenceImagesDirectory: String, identifier: String, error: NSErrorPointer) -> Bool {
        return testCase.compareSnapshotOfView(self, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, error: error)
    }
    
    var snapshotSize : CGSize {
        return bounds.size
    }
}

extension CALayer : SnapshotTestable {
    func snapshotTestWithCase(testCase : FBSnapshotTestCase, referenceImagesDirectory: String, identifier: String, error: NSErrorPointer) -> Bool  {
        return testCase.compareSnapshotOfLayer(self, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, error: error)
    }
    
    var snapshotSize : CGSize {
        return bounds.size
    }
}

extension UIViewController : SnapshotTestable {
    
    func prepareForSnapshot() {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = self
        window.makeKeyAndVisible()
    }
    
    func snapshotTestWithCase(testCase: FBSnapshotTestCase, referenceImagesDirectory: String, identifier: String, error: NSErrorPointer) -> Bool {
        
        let result = testCase.compareSnapshotOfView(self.view, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, error: error)
        return result
    }
    
    func finishSnapshot() {
        view.window?.removeFromSuperview()
    }
    
    var snapshotSize : CGSize {
        return view.bounds.size
    }
}

class SnapshotTestCase : FBSnapshotTestCase {
    
    var screenSize : CGSize {
        // Standardize on a size so we don't have to worry about different simulators
        // etc.
        return CGSizeMake(320, 568)
    }
    
    private final func qualifyIdentifier(identifier : String?, content : SnapshotTestable) -> String {
        let majorVersion = NSProcessInfo.processInfo().operatingSystemVersion.majorVersion
        let suffix = "ios\(majorVersion)_\(Int(content.snapshotSize.width))x\(Int(content.snapshotSize.height))"
        if let identifier = identifier {
            return identifier + suffix
        }
        else {
            return suffix
        }
    }
    
    // Asserts that a snapshot matches expectations
    // This is similar to the objc only FBSnapshotTest macros
    // But works in swift
    func assertSnapshotValidWithContent(content : SnapshotTestable, identifier : String? = nil, message : String? = nil, file : String = __FILE__, line : UInt = __LINE__) {
        var error : NSError?
        
        let qualifiedIdentifier = qualifyIdentifier(identifier, content : content)
        
        let equal = content.snapshotTestWithCase(self, referenceImagesDirectory: FB_REFERENCE_IMAGE_DIR, identifier: qualifiedIdentifier, error: &error)
        let unknownError = "Unknown Error"
        XCTAssertTrue(equal, "Snapshot comparison failed: \(error?.localizedDescription ?? unknownError)", file : file, line : line)
        XCTAssertFalse(recordMode, "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!", file : file, line : line)
        if let message = message {
            XCTAssertTrue(equal, message, file : file, line : line)
        }
        else {
            XCTAssertTrue(equal, file : file, line : line)
        }
    }
    
    func inScreenNavigationContext(controller : UIViewController, action : () -> ()) {
        let container = UINavigationController(rootViewController: controller)
        inScreenDisplayContext(container, action: action)
    }
    
    /// Makes a window and adds the controller to it
    /// to ensure that our controller actually loads properly
    /// Otherwise, sometimes viewWillAppear: type methods don't get called
    func inScreenDisplayContext(controller : UIViewController, action : () -> ()) {
        
        let window = UIWindow(frame: CGRectZero)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        controller.view.bounds = CGRectMake(0, 0, screenSize.width, screenSize.height)
        controller.view.layoutIfNeeded()
        
        action()
        
        window.removeFromSuperview()
    }
    
}
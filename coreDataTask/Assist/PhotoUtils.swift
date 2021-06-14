//
//  AsyncPhotoUtils.swift
//  coreDataTask
//
//  Created by swamnx on 7.06.21.
//

import Foundation
import UIKit

struct PhotoUtils {
    
    static var shared = PhotoUtils()
    
    var photoDetailsUrl = URL(string: "https://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!
    
    private init() {
        
    }
    func getPhotoAlertController() -> UIAlertController {
        return CommonUtils.shared.getAlertController(title: "Oops!", message: "There was an error fetching photo details.")
    }
}

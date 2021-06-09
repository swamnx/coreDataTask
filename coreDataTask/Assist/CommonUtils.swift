//
//  CommonUtils.swift
//  coreDataTask
//
//  Created by swamnx on 7.06.21.
//

import Foundation
import UIKit

struct CommonUtils {
    
    static var shared = CommonUtils()
    
    func getHttpsValue(httpValue value: String) -> String {
        var httpsValue = value
        httpsValue.insert("s", at: httpsValue.index(httpsValue.startIndex, offsetBy: 4))
        return httpsValue
    }
    
    func getAlertController(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}

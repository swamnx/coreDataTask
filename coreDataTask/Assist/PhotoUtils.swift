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

class AsyncPhotoHandler {
    var tasks = [IndexPath: PhotoOperation]()
    var amountOfCompletedTasks = 0
    var semaphore = DispatchSemaphore(value: 1)
    var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 2
        return queue
      }()
}

class PhotoOperation: Operation {
    
    var naming: String?
    var url: URL
    var image: UIImage?
    var status = DownloadingStatus.initial
    
    init(name: String?, url: URL) {
        self.naming = name
        self.url = url
    }
    override func main() {
        if isCancelled { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        if isCancelled { return }
        if !imageData.isEmpty {
            image = UIImage(data: imageData)
            status = .downloaded
        } else {
            status = .failed
            image = UIImage(systemName: "house")
        }
    }
    
    enum DownloadingStatus {
        case initial, downloading, downloaded, failed
    }
}

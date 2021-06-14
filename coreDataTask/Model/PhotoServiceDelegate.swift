//
//  PhotoServiceDelegate.swift
//  coreDataTask
//
//  Created by swamnx on 14.06.21.
//

import Foundation
import UIKit
protocol PhotoServiceDelegate: AnyObject {
    
    func failedFetchingAllBasicPhotoDetails()
    func finishedFetchingAllBasicPhotoDetails()
    func finishedFetchingAllPhotoDetails()
    func finishedFetchingPhotoDetails(forIndexPath: IndexPath)
    func finishedLoadingInitialPhotos()
}

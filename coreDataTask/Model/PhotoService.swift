//
//  PhotoService.swift
//  coreDataTask
//
//  Created by swamnx on 8.06.21.
//

import Foundation
import UIKit
class PhotoService {
    
    weak var viewController: ViewController?
    private var apiPhotos: [PhotoApi]?
    private var initialPhotos: [Photo]?
    private var asyncPhotoHandler: AsyncPhotoHandler?
    private var initial = true
    
    init(_ controller: ViewController) {
        viewController = controller
        apiPhotos = [PhotoApi]()
        asyncPhotoHandler = AsyncPhotoHandler()
        initialPhotos = [Photo]()
    }
    
    func loadInitialPhotos() {
        initialPhotos = PhotoCoreService.shared.read()
        self.viewController?.galleryView.reloadData()
    }
    
    func getPhotosCount() -> Int {
        if initial {
            return initialPhotos?.count ?? 0
        }
        return apiPhotos?.count ?? 0
    }
    
    func needUpdateWithNewPhoto(indexPath: IndexPath) -> (Bool, Photo?) {
        if initial {
            return (true, initialPhotos?[indexPath.row])
        }
        guard let apiPhoto = apiPhotos?[indexPath.row] else {
            return (false, nil)
        }
        guard let task = asyncPhotoHandler?.tasks[indexPath] else {
            startDownload(indexPath, apiPhoto)
            return (true, Photo(name: apiPhoto.name, image: UIImage(systemName: "house")))
        }
        switch task.status {
        case .downloaded, .failed:
                return (true, Photo(name: task.naming, image: task.image))
        case .initial, .downloading:
                return (false, nil)
        }
    }
    
    func fetchPhotoDetails() {
        initial = false
        self.cancelPreviousDownloads()
        let request = URLRequest(url: PhotoUtils.shared.photoDetailsUrl)
        let task = URLSession(configuration: .default).dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data {
              do {
                guard let datasourceDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] else { return }
                for (name, value) in datasourceDictionary where value != "NO URL" {
                    self.apiPhotos?.append(PhotoApi(name: name, url: URL(string: CommonUtils.shared.getHttpsValue(httpValue: value))!))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.viewController?.galleryView.reloadData()
                }
              } catch {
                DispatchQueue.main.async {
                    self.viewController?.present(PhotoUtils.shared.getPhotoAlertController(), animated: true, completion: nil)
                }
              }
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.viewController?.present(PhotoUtils.shared.getPhotoAlertController(), animated: true, completion: nil)
                }
            }
      }
      task.resume()
    }
    
    private func cancelPreviousDownloads() {
        if let handler = asyncPhotoHandler {
            for (_, task) in handler.tasks {
                task.cancel()
            }
            handler.amountOfCompletedTasks = 0
            handler.tasks.removeAll()
            apiPhotos?.removeAll()
        }
        DispatchQueue.main.async {
            self.viewController?.activityIndicator.stopAnimating()
        }
    }
    
    private func startDownload(_ indexPath: IndexPath, _ photoApi: PhotoApi) {
        let operation = PhotoOperation(name: photoApi.name, url: photoApi.url)
        operation.completionBlock = { [weak self] in
            guard let self = self else { return }
            if operation.isCancelled { return }
            self.asyncPhotoHandler?.semaphore.wait()
            self.asyncPhotoHandler?.amountOfCompletedTasks+=1
            self.asyncPhotoHandler?.semaphore.signal()
            var allTaskCompleted = false
            if let photosCount = self.apiPhotos?.count,
               let amountOfCompletedTasks = self.asyncPhotoHandler?.amountOfCompletedTasks,
               amountOfCompletedTasks == photosCount {
                allTaskCompleted = true
            }
            if allTaskCompleted {
                if let photoForSaving = self.asyncPhotoHandler?.tasks.map({ Photo.init(name: $1.naming, image: $1.image) }) {
                    PhotoCoreService.shared.save(photos: photoForSaving)
                }
            }
            DispatchQueue.main.async {
                if allTaskCompleted {
                    self.viewController?.activityIndicator.stopAnimating()
                }
                self.viewController?.galleryView.reloadItems(at: [indexPath])
            }
        }
        if asyncPhotoHandler?.tasks.count == 0 {
            DispatchQueue.main.async {
                self.viewController?.activityIndicator.startAnimating()
            }
        }
        asyncPhotoHandler?.tasks[indexPath] = operation
        operation.status = .downloading
        asyncPhotoHandler?.queue.addOperation(operation)
    }
    
}

//
//  PhotoCoreService.swift
//  coreDataTask
//
//  Created by swamnx on 8.06.21.
//

import Foundation
import CoreData
import UIKit

struct PhotoCoreService {
    
    static var shared = PhotoCoreService()
    var context: NSManagedObjectContext?
    
    private init() {
    }
    
    func save(photos: [Photo]) {
        guard let managedContext = context else {return}
        let entity = NSEntityDescription.entity(forEntityName: "PhotoCore", in: managedContext)!
        for photo in photos {
            if let image = photo.image {
                let photoCore = NSManagedObject(entity: entity, insertInto: managedContext)
                let data = image.jpegData(compressionQuality: 1)
                photoCore.setValue(data, forKeyPath: "photoImage")
                if let photoName = photo.name {
                    photoCore.setValue(photoName, forKeyPath: "photoName")
                }
            }
        }
        do {
            let fetchForDeleteRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PhotoCore")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchForDeleteRequest)
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func read() -> [Photo]? {
        guard let managedContext = context else {return nil}
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PhotoCore")
        do {
            let corePhotos = try managedContext.fetch(fetchRequest)
            var photos = [Photo]()
            for corePhoto in corePhotos {
                if let data = corePhoto.value(forKey: "photoImage") as? Data,
                   let image = UIImage.init(data: data) {
                    photos.append(Photo.init(name: corePhoto.value(forKey: "photoName") as? String, image: image))
                }
            }
            return photos
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
}

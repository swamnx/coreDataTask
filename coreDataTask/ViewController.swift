//
//  ViewController.swift
//  coreDataTask
//
//  Created by swamnx on 7.06.21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var galleryView: UICollectionView!
    
    var photoService: PhotoService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryView.delegate = self
        galleryView.dataSource = self
        activityIndicator.hidesWhenStopped = true
        photoService = PhotoService(delegate: self)
        photoService?.loadInitialPhotos()
    }
    
    @IBAction func reloadTouched(_ sender: UIButton) {
        activityIndicator.startAnimating()
        photoService?.fetchPhotoDetails()
    }
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoService?.getPhotosCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellID", for: indexPath) as? PhotoCellView
        if let (update, photo) = photoService?.needUpdateWithNewPhoto(indexPath: indexPath), update {
            cell?.photo.image = photo?.image
        }
        return cell ?? PhotoCellView()
    }

}

extension ViewController: PhotoServiceDelegate {
    
    func failedFetchingAllBasicPhotoDetails() {
        activityIndicator.stopAnimating()
        present(PhotoUtils.shared.getPhotoAlertController(), animated: true, completion: nil)
    }
    func finishedFetchingAllBasicPhotoDetails() {
        galleryView?.reloadData()
    }
    
    func finishedFetchingAllPhotoDetails() {
        activityIndicator.stopAnimating()
    }
    
    func finishedFetchingPhotoDetails(forIndexPath: IndexPath) {
        galleryView?.reloadItems(at: [forIndexPath])
    }
    
    func finishedLoadingInitialPhotos() {
        galleryView?.reloadData()
    }
    
}

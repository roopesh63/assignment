//
//  ResourceViewController.swift
//  Q2 CollectionView Project
//
//  Created by Roopesh on 11/09/19.
//  Copyright © 2019 Roopesh. All rights reserved.
//

import UIKit
import QuickLook
import AVKit

class ResourceViewController: UIViewController {
    
    @IBOutlet weak var resourceListCollectionView: UICollectionView!
    
    private var quickLookController = QLPreviewController()
    
    private var cellID = "resourceCell"
    private var resources = [
        Resource(title: "Sample Video", type: .video, filename: "SampleVideo", extension: "mp4", thumbnailImage: "VideoImage"),
        Resource(title: "Sample Image", type: .image, filename: "Nature", extension: "jpeg", thumbnailImage: "Nature"),
        Resource(title: "Sample Document", type: .doc, filename: "SampleDocument", extension: "doc", thumbnailImage: "DocImage"),
        Resource(title: "Sample PDF", type: .pdf, filename: "SamplePDF", extension: "pdf", thumbnailImage: "PDFImage")
    ]
    
    private var documentsURLs = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        quickLookController.dataSource = self
        prepareDocURLs()
    }
    
    private func prepareDocURLs() {
        let quickLookResourceTypes: [ResourceType] = [.doc, .pdf, .image]
        resources.filter { quickLookResourceTypes.contains($0.type) }.forEach { (resource) in
            if let url = Bundle.main.url(forResource: resource.filename, withExtension: resource.extension) {
                documentsURLs.append(url)
            }
        }
    }

}

// Mark: - CollectionView Delegates
extension ResourceViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ResourceCollectionViewCell
        cell?.configureCell(data: resources[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 250.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let resource = resources[indexPath.row]
            if let videoURL = Bundle.main.url(forResource: resource.filename, withExtension: resource.extension) {
                let player = AVPlayer(url: videoURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                self.present(playerVC, animated: true) {
                    playerVC.player?.play()
                }
            }
        case 1,2,3:
            let currentDocIndex = indexPath.row - 1
            if QLPreviewController.canPreview(documentsURLs[currentDocIndex] as QLPreviewItem) {
                quickLookController.currentPreviewItemIndex = currentDocIndex
                navigationController?.pushViewController(quickLookController, animated: true)
            }
        default:
            break
        }
    }
    
}

extension ResourceViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return documentsURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentsURLs[index] as QLPreviewItem
    }
}

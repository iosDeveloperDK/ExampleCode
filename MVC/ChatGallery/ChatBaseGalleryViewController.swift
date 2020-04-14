//
//  ChatBaseGalleryViewController.swift
//  Example
//
//  Created by Denis Koltovich on 30/06/2017.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData
import XCGLogger
import AVKit
import AVFoundation


class ChatBaseGalleryViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let commonSpacing: CGFloat = 7.5
    fileprivate let regularColomnsCount = 3
    fileprivate let compactColomnsCount = 4
    
    fileprivate let dataBaseService = DatabaseService.shared
    
    fileprivate var fetchResultController: NSFetchedResultsController<MediaAttachment>!
    var chat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFetchResultController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func predicate()->NSFetchRequest<MediaAttachment> {
        let fetchedRequest: NSFetchRequest<MediaAttachment> = MediaAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "\(#keyPath(MediaAttachment.message.chat)) = %@", chat)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MediaAttachment.message.date), ascending: false)]
        
        return fetchedRequest
    }
    
    fileprivate func prepareFetchResultController() {
        fetchResultController = NSFetchedResultsController(fetchRequest: predicate(), managedObjectContext: dataBaseService.persistentContainer.viewContext, sectionNameKeyPath: #keyPath(MediaAttachment.message.dateString), cacheName: nil)
        do {
            try fetchResultController.performFetch()
        } catch let exception {
            XCGLogger.default.error(exception)
        }
        updateUI()
    }
    
    //MARK: Helpers
    fileprivate func updateUI() {
        collectionView?.reloadData()
    }
    
    func showAttachment(_ attach: MediaAttachment, attachments: [MediaAttachment]) {}
}

//MARK: - UICollectionViewDataSource
extension ChatBaseGalleryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ChatGalleryCollectionViewCell.self), for: indexPath) as? ChatGalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let media = fetchResultController.object(at: indexPath)
        cell.update(media: media)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(describing: ChatGalleryHeaderCollectionReusableView.self), for: indexPath) as? ChatGalleryHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        if let headerName = fetchResultController.sections?[section].name {
            header.labelTitle.text = headerName
        }
        
        return header
    }
}

//MARK: - UICollectionViewDelegate
extension ChatBaseGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let attachments = fetchResultController.fetchedObjects {
            showAttachment(attachments[indexPath.item], attachments: attachments)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ChatBaseGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edgeInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let minItemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let colomnCount = traitCollection.verticalSizeClass == .compact ? compactColomnsCount : regularColomnsCount
        let width = (collectionView.frame.size.width - edgeInsets.left - edgeInsets.right - ((CGFloat(colomnCount - 1)) * minItemSpacing)) / CGFloat(colomnCount)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return commonSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return commonSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: commonSpacing, bottom: commonSpacing, right: commonSpacing)
    }
}

extension ChatBaseGalleryViewController: PreviewImageViewControllerDelegate {
    func previewImageViewController(_ controller: PreviewImageViewController, didForwardAttachment attachment: BaseAttachment) {
        //TODO
    }
}

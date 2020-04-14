//
//  ChatImagesGalleryViewController.swift
//  Example
//
//  Created by Denis Koltovich on 30/06/2017.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData

class ChatImagesGalleryViewController: ChatBaseGalleryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func localize() {
        super.localize()
        title = L10n.cigVcTitle.string
    }
    
    //MARK: Helper
    override func predicate()->NSFetchRequest<MediaAttachment> {
        let fetchedRequest: NSFetchRequest<ImageAttachment> = ImageAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "\(#keyPath(ImageAttachment.message.chat)) = %@ OR \(#keyPath(ImageAttachment.message.chat.parent)) = %@", chat, chat)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ImageAttachment.message.date), ascending: false)]
        
        return fetchedRequest as! NSFetchRequest<MediaAttachment>
    }
    
    override func showAttachment(_ attach: MediaAttachment, attachments: [MediaAttachment]) {
        guard let imageAttach = attach as? ImageAttachment,
            let imageAttachments  = attachments as? [ImageAttachment] else {
                return
        }
        let previewController = StoryboardScene.PreviewImage.instantiatePreviewImageViewControllerIdentifier()
        previewController.attachments = imageAttachments
        previewController.currentAttachment = imageAttach
        previewController.delegate = self
        
        let navigation = TransparentNavigationController(rootViewController: previewController)
        present(navigation, animated: true, completion: nil)
    }
}




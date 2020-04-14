//
//  ChatAudioListViewController.swift
//  Example
//
//  Created by Denis Koltovich on 7/4/17.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData

class ChatAudioListViewController: ChatBaseListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func localize() {
        super.localize()
        title = L10n.calVcTitle.string
    }

    //MARK: Helper
    override func predicate()->NSFetchRequest<FileAttachment> {
        let fetchedRequest: NSFetchRequest<AudioAttachment> = AudioAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "\(#keyPath(AudioAttachment.message.chat)) = %@ OR \(#keyPath(AudioAttachment.message.chat.parent)) = %@", chat, chat)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(AudioAttachment.message.date), ascending: false)]
        
        return fetchedRequest as! NSFetchRequest<FileAttachment>
    }
    
    override func showAttachment(_ attachment: FileAttachment) {
        guard let url = FilesStorage.shared.fullPathFor(attachment)?.fileUrl else {
            return
        }
        
        let documentController = UIDocumentInteractionController.init(url: url)
        documentController.delegate = self
        documentController.presentPreview(animated: true)
    }
}

//MARK: - UIDocumentInteractionControllerDelegate
extension ChatAudioListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}


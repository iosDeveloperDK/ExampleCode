//
//  ChatFilesListViewController.swift
//  Example
//
//  Created by Denis Koltovich on 7/4/17.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData

class ChatFilesListViewController: ChatBaseListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func localize() {
        super.localize()
        title = L10n.cflVcTitle.string
    }
    
    //MARK: Helper
    override func predicate()->NSFetchRequest<FileAttachment> {
        let fetchedRequest: NSFetchRequest<FileAttachment> = FileAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "(\(#keyPath(FileAttachment.message.chat)) = %@ OR \(#keyPath(FileAttachment.message.chat.parent)) = %@) AND \(#keyPath(FileAttachment.type)) = %@", chat, chat, AttachmentType.file.rawValue)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FileAttachment.message.date), ascending: false)]
        
        return fetchedRequest
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
extension ChatFilesListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}


//
//  ChatVideosGalleryViewController.swift
//  Example
//
//  Created by Denis Koltovich on 30/06/2017.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class ChatVideosGalleryViewController: ChatBaseGalleryViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func localize() {
        super.localize()
        title = L10n.cvgVcTitle.string
    }
    
    //MARK: Helper
    override func predicate()->NSFetchRequest<MediaAttachment> {
        let fetchedRequest: NSFetchRequest<VideoAttachment> = VideoAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "\(#keyPath(VideoAttachment.message.chat)) = %@ OR \(#keyPath(VideoAttachment.message.chat.parent)) = %@", chat, chat)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(VideoAttachment.message.date), ascending: false)]
        
        return fetchedRequest as! NSFetchRequest<MediaAttachment>
    }

    override func showAttachment(_ attach: MediaAttachment, attachments: [MediaAttachment]) {
        if let videoURL = FilesStorage.shared.fullPathFor(attach)?.fileUrl {

            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true, completion: nil)
        }
    }
}

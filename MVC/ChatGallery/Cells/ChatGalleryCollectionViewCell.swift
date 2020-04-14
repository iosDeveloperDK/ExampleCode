//
//  AllMediaCollectionViewCell.swift
//  Example
//
//  Created by Denis Koltovich on 30/06/2017.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit

class ChatGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    func update(media: BaseAttachment) {
        if let imageAttachment = media as? ImageAttachment {
            let imageLocal = AttachmentFilesManager.shared.imageFor(imageAttachment)
            if imageLocal != nil {
                imageView.image = imageLocal
            }
        }
        if let videoAttachment = media as? VideoAttachment {
            let imageLocal = AttachmentFilesManager.shared.thumbnailFor(videoAttachment)
            if imageLocal != nil {
                imageView.image = imageLocal
            }
            labelTime.text = Int(videoAttachment.length).lengthString
        }
    }
}

//
//  ChatListTableViewCell.swift
//  Example
//
//  Created by Denis Koltovich on 7/4/17.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit

private enum FileType: String {
    case doc = "doc"
    case xls = "xls"
    case pdf = "pdf"
    case other = "other"
    
    var fileIconImage: UIImage {
        switch self {
        case .doc:
            return Image(asset: .docFileIcon)
        case .pdf:
            return Image(asset: .pdfFileIcon)
        case .xls:
            return Image(asset: .xlsFileIcon)
        default:
            return Image(asset: .otherFileIcon)
        }
    }
}

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    func update(media: BaseAttachment) {
        if let audioAttachment = media as? AudioAttachment {
            iconImageView.image =
                audioAttachment.audioType == AttachmentAudioType.record.rawValue ? Image(asset: .microPhone) : Image(asset: .headPhones)
            titleLabel.text = audioAttachment.name
            detailsLabel.text = Int(audioAttachment.length).lengthString
            return
        }
        if let fileAttachment = media as? FileAttachment {
            titleLabel.text = fileAttachment.name
            if let fileName = fileAttachment.name, let fileNameUrl = URL(string: fileName) {
                let fileExtension = fileNameUrl.pathExtension
                iconImageView.image = FileType(rawValue: fileExtension) != nil ? FileType(rawValue: fileExtension)?.fileIconImage : Image(asset: .otherFileIcon)
            }
        }
    }
}

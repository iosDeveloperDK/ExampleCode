//
//  ChatBaseListViewController.swift
//  Example
//
//  Created by Denis Koltovich on 7/4/17.
//  Copyright © 2017 Denis. All rights reserved.
//

import UIKit
import CoreData
import XCGLogger
import AVKit
import AVFoundation

class ChatBaseListViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate let dataBaseService = DatabaseService.shared
    fileprivate var fetchResultController: NSFetchedResultsController<FileAttachment>!
    fileprivate let headerSectionHeight: CGFloat = 34
    
    var chat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFetchResultController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func predicate()->NSFetchRequest<FileAttachment> {
        let fetchedRequest: NSFetchRequest<FileAttachment> = FileAttachment.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "\(#keyPath(FileAttachment.message.chat)) = %@", chat)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FileAttachment.message.date), ascending: false)]
        
        return fetchedRequest
    }
    
    fileprivate func prepareFetchResultController() {
        fetchResultController = NSFetchedResultsController(fetchRequest: predicate(), managedObjectContext: dataBaseService.persistentContainer.viewContext, sectionNameKeyPath: #keyPath(FileAttachment.message.dateString), cacheName: nil)
        do {
            try fetchResultController.performFetch()
        } catch let exception {
            XCGLogger.default.error(exception)
        }
        updateUI()
    }
    
    //MARK: Helpers
    fileprivate func updateUI() {
        tableView?.reloadData()
    }
    
    func showAttachment(_ attachment: FileAttachment) {
        
    }
}

//MARK: - UITableViewDataSource
extension ChatBaseListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListTableViewCell.self)) as? ChatListTableViewCell else {
            return UITableViewCell()
        }
        
        let media = fetchResultController.object(at: indexPath)
        
        cell.update(media: media)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerSectionHeight
    }
    
}

//MARK: - UITableViewDelegate
extension ChatBaseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed(String(describing: ChatListHeaderView.self), owner: self, options: nil)?[0] as! ChatListHeaderView
        
        if let headerName = fetchResultController.sections?[section].name {
            header.titleLabel.text = headerName
        }
    
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let attachments = fetchResultController.fetchedObjects {
            showAttachment(attachments[indexPath.item])
        }
    }
}

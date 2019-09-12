//
//  FilesTableViewController.swift
//  Q3 Wordpad
//
//  Created by Roopesh on 11/09/19.
//  Copyright © 2019 Roopesh. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController {
    
    @IBOutlet var noFilesLabel: UILabel!
    
    private let cellID = "fileNameCell"
    private var wordFiles = [String]()
    private var fileHandler = FileHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFilesList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    private func configureTableView() {
        setupNoFilesLabel()
        tableView.tableFooterView = UIView()
    }
    
    private func setupNoFilesLabel() {
        noFilesLabel.bounds = tableView.bounds
        noFilesLabel.frame.origin.y = -tableView.bounds.height / 4.0
        tableView.addSubview(noFilesLabel)
    }
    
    private func fetchFilesList() {
        wordFiles = fileHandler.fetchFilesList()
        noFilesLabel.isHidden = !wordFiles.isEmpty
        tableView.reloadData()
    }
    
    @IBAction func addFile(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create File", message: "Enter filename to create file", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Enter File Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let fileName = alert.textFields?.first?.text, !fileName.isEmpty else {
                return
            }
            self.fileHandler.createFile(fileName: fileName)
            self.fetchFilesList()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            guard let editVC = segue.destination as? EditViewController else {
                return
            }
            let index = tableView.indexPathForSelectedRow?.row ?? 0
            editVC.fileName = wordFiles[index]
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !wordFiles.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            setupNoFilesLabel()
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = wordFiles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let isDeleted = fileHandler.deleteFile(fileName: wordFiles[indexPath.row])
            if isDeleted {
                wordFiles.remove(at: indexPath.row)
                noFilesLabel.isHidden = !wordFiles.isEmpty
                tableView.reloadData()
            }
        }
    }
    
}

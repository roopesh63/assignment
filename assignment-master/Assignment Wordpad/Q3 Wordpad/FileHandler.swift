//
//  FileHandler.swift
//  Q3 Wordpad
//
//  Created by Roopesh on 11/09/19.
//  Copyright © 2019 Roopesh. All rights reserved.
//

import Foundation

struct FileHandler {
    private let fileManager = FileManager.default
    private let folderName = "DocFiles"
    
    private var documentsDirPath: String {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    }
    
    func createFolder() {
        let folderPath = getFilePath(fileName: folderName)
        if !fileManager.fileExists(atPath: folderPath) {
            do {
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Folder Creation Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getFilePath(fileName: String, inDirectory dirName: String = "") -> String {
        if dirName.isEmpty {
            return (documentsDirPath as NSString).appendingPathComponent(fileName)
        }
        let dirPath = getFilePath(fileName: dirName)
        return (dirPath as NSString).appendingPathComponent(fileName)
    }
    
    func fetchFilesList() -> [String]{
        let folderPath = getFilePath(fileName: folderName)
        do {
            let filesList = try fileManager.contentsOfDirectory(atPath: folderPath)
            return filesList
        } catch let error {
            print("Fetching Files List Error: \(error.localizedDescription)")
        }
        return []
    }
    
    func createFile(fileName: String) {
        let filePath = getFilePath(fileName: fileName, inDirectory: folderName)
        if !fileManager.fileExists(atPath: filePath) {
            _ = writeToFile(fileName: fileName, content: NSMutableAttributedString(string: ""))
        }
    }
    
    func writeToFile(fileName: String, content: NSMutableAttributedString, atCreation: Bool = false) -> Bool{
        let filePath = getFilePath(fileName: fileName, inDirectory: folderName)
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            let range = NSRange(location: 0, length: content.length)
            let attributes = [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.rtfd]
            let fileWrapper = try content.fileWrapper(from: range, documentAttributes: attributes)
            try fileWrapper.write(to: fileURL, options: .atomic, originalContentsURL: nil)
            return true
        } catch let error {
            print("File Writing error: \(error.localizedDescription)")
        }
        return false
    }
    
    func getContentsOfFile(fileName: String) -> NSMutableAttributedString {
        let filePath = getFilePath(fileName: fileName, inDirectory: folderName)
        do {
            let text = try NSMutableAttributedString(url: URL(fileURLWithPath: filePath), options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            return text
        } catch let error {
            print("File Reading Error: \(error.localizedDescription)")
        }
        return NSMutableAttributedString(string: "")
    }
    
    func deleteFile(fileName: String) -> Bool{
        let filePath = getFilePath(fileName: fileName, inDirectory: folderName)
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
                return true
            } catch let error {
                print("File deletion Error: \(error.localizedDescription)")
            }
        }
        return false
    }
}

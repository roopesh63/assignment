//
//  EditViewController.swift
//  Q3 Wordpad
//
//  Created by Roopesh on 11/09/19.
//  Copyright © 2019 Roopesh. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet var accessoryView: UIView!
    
    private var fileHandler = FileHandler()
    var fileName: String?
    private var isDisappearing = false
    private var originContent = NSMutableAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisappearing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isDisappearing = true
        saveToFile()
    }
    
    private func setupView() {
        guard let fileName = fileName else { return }
        title = fileName
        let contentText = fileHandler.getContentsOfFile(fileName: fileName)
        contentTextView.attributedText = contentText
        contentTextView.inputAccessoryView = accessoryView
        originContent = contentText
    }
    
    private func saveToFile() {
        guard let content = contentTextView.attributedText else { return }
        if content == originContent {
            showAlert(title: "No Changes", message: "Please make changes to save")
            return
        }
        originContent = NSMutableAttributedString(attributedString: content)
        if let fileName = fileName {
            let success = fileHandler.writeToFile(fileName: fileName, content: NSMutableAttributedString(attributedString: content))
            let alertTitle = success ? "File saved successfully" : "File saving failed"
            showAlert(title: alertTitle, message: "")
        }
    }
    
    private func showAlert(title: String, message: String) {
        if !isDisappearing {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func showImageInTextView(image: UIImage) {
        let width = contentTextView.frame.width - 16
        if let scaledImage = resizeImage(image: image, newWidth: width) , let encodedImgStr = scaledImage.pngData()?.base64EncodedString(),
            let attrText = NSMutableAttributedString(base64EndodedImageString: encodedImgStr) {
            
            let attrString = NSMutableAttributedString(attributedString: contentTextView.attributedText)
            attrString.append(attrText)
            attrString.append(NSAttributedString(string: "\n"))
            contentTextView.attributedText = attrString
        }
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func doneEditing(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveToFile(_ sender: UIButton) {
        saveToFile()
    }
    
}

// UIImagePicker Delegates
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            showImageInTextView(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}



extension NSAttributedString {
    convenience init?(base64EndodedImageString encodedImageString: String) {
        var html = """
        <!DOCTYPE html>
        <html>
        <body>
        <img src="data:image/png;base64,\(encodedImageString)">
        </body>
        </html>
        """
        let data = Data(html.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        try? self.init(data: data, options: options, documentAttributes: nil)
    }
}

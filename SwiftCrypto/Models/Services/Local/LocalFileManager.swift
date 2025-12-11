//
//  LocalFileManager.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import SwiftUI

protocol LocalFileManagerProtocol {
    func saveImage(image: UIImage, imageName: String, folderName: String)
    func getImage(imageName: String, folderName: String) -> UIImage?
}

final class LocalFileManager: LocalFileManagerProtocol {
    static let instance = LocalFileManager()
    private let baseDirectory: URL?
    
    init(baseDirectory: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first) {
        self.baseDirectory = baseDirectory
    }
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        // create folder
        createFolderIfNeeded(folderName: folderName)
        
        // get path for image
        guard
            let data = image.pngData(),
            let url = getUrlForImage(imageName: imageName, folderName: folderName) else { return }
        
        // save the image data to path
        do {
            try data.write(to: url)
        } catch let error {
            print("Error saving image. ImageName: \(imageName). \(error)")
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        guard
            let url = getUrlForImage(imageName: imageName, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }
        
        return UIImage(contentsOfFile: url.path())
    }
    
    private func createFolderIfNeeded(folderName: String) {
        guard let folderUrl = getUrlForFolder(folderName: folderName) else { return }
        
        if !FileManager.default.fileExists(atPath: folderUrl.path()) {
            do {
                try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error creating directory. FolderName: \(folderName). Error: \(error)")
            }
        }
    }
    
    private func getUrlForFolder(folderName: String) -> URL? {
        guard let baseDirectory = self.baseDirectory else {
            return nil
        }
        return baseDirectory.appending(path: folderName)
    }
    
    private func getUrlForImage(imageName: String, folderName: String) -> URL? {
        guard let folderUrl = getUrlForFolder(folderName: folderName) else {
            return nil
        }
        return folderUrl.appending(path: "\(imageName).png")
    }
}

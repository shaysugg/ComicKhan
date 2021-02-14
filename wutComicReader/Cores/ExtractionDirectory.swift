//
//  ExtractionDirectory.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/25/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import Foundation

struct ExtractionDirectory {
    let baseURL: URL
    
    struct MetaData: Codable {
        let groupName: String
    }
    
    init(directoryName: String, baseURL: URL? = nil) {
        let url = baseURL != nil ? baseURL! : URL.comicDiractory
        self.baseURL = url.appendingPathComponent(directoryName)
    }
    
    var originalImagesDirectoryURL: URL {
        baseURL.appendingPathComponent(ExtractionDirectory.originalImagesDirectoryName)
    }
    var thumbnailImagesDirectoryURL: URL {
        baseURL.appendingPathComponent(ExtractionDirectory.thumbnailImagesDirectoryName)
    }
    var metaDataURL: URL {
        baseURL.appendingPathComponent(ExtractionDirectory.metaDataFileName).appendingPathExtension("json")
    }
    
    static var originalImagesDirectoryName = "original"
    static var thumbnailImagesDirectoryName = "thumbnail"
    static private var metaDataFileName = "metadata"
    
    func createDirectories() throws {
        
        try FileManager.default.createDirectory(at: baseURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try FileManager.default.createDirectory(at: originalImagesDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try FileManager.default.createDirectory(at: thumbnailImagesDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        
    }
    
    func write(metaData: MetaData) throws {
        let data = try JSONEncoder().encode(metaData)
        try data.write(to: metaDataURL)
    }
    
    func readMetaData() throws -> MetaData {
        let data = try Data(contentsOf: metaDataURL)
        return try JSONDecoder().decode(MetaData.self, from: data)
    }
}

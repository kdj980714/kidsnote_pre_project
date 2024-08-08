import UIKit

final class ImageFetcher {
    private var task: Task<UIImage?, Error>?
    private let dataCache = NSCache<NSString, NSData>()
    
    func fetchImage(by id: String, imageURL: String) async throws -> UIImage? {
        task = Task {
            guard let url = URL(string: imageURL) else {
                throw ImageFetch.invailURL
            }
            if let cachedData = dataCache.object(forKey: id as NSString) as? Data {
                return UIImage(data: cachedData)
            }
            if let imageData = try await findDataFromDisk(by: id) {
                dataCache.setObject(imageData as NSData, forKey: id as NSString)
                return UIImage(data: imageData)
            }
            try await downloadImageToDisk(by: id, imageURL: url)
            let imageData = try await findDataFromDisk(by: id)
            guard let imageData else {
                throw ImageFetch.findFromDiskFail
            }
            dataCache.setObject(imageData as NSData, forKey: id as NSString)
            return UIImage(data: imageData)
        }
        return try await task?.value
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    private func findDataFromDisk(by imageName: String) async throws -> Data? {
        let fileManager = FileManager()
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            throw ImageFetch.findFromDiskFail
        }
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(imageName)
        
        if fileManager.fileExists(atPath: filePath.path) {
            if let imageData = NSData(contentsOf: filePath) {
                return Data(imageData)
            }
        }
        return nil
    }
    
    private func downloadImageToDisk(by id: String, imageURL: URL) async throws {
        let downloadURL = try? await URLSession.shared.download(from: imageURL).0
        guard let downloadURL else {
            throw ImageFetch.downloadFail
        }
        
        let fileManager = FileManager.default
        let tempPath = downloadURL.path
        let imageName = id
        
        guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            throw ImageFetch.diskCachingFail
        }
        let finalPath = cacheDirectoryPath + "/" + imageName
        try? fileManager.moveItem(atPath: tempPath, toPath: finalPath)
        var filePath = URL(fileURLWithPath: cacheDirectoryPath)
        filePath.appendPathComponent(imageName)
    }
}
enum ImageFetch: Error {
    case invailURL
    case downloadFail
    case findFromDiskFail
    case diskCachingFail
    case memoryCachingFaile
}

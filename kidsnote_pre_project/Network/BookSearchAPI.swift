import Foundation

enum GoogleBookSearchAPI {
    case all(GoogleBookSearchAPI.Request)
    case free(GoogleBookSearchAPI.Request)
    case detail(String)
}
extension GoogleBookSearchAPI: BaseAPI {
    var baseURL: String {
        "https://www.googleapis.com"
    }
    
    var path: String {
        switch self {
        case .all, .free:
            return "/books/v1/volumes"
        case .detail(let id):
            return "/books/v1/volumes/\(id)"
        }
    }
    
    var method: Method {
        return .get
    }
    
    var parameters: [String: String?]? {
        switch self {
        case .all(let request):
            return [
                "q": request.bookName,
                "filter": request.filter.value,
                "startIndex": String(request.startIndex),
                "maxResults": String(request.maxResults),
            ]
        case .free(let request):
            return [
                "q": request.bookName,
                "filter": request.filter.value,
                "startIndex": String(request.startIndex),
                "maxResults": String(request.maxResults),
            ]
        case .detail(let id):
            return nil
        }
    }
}

import Foundation

protocol BaseAPI {
    var baseURL: String { get }
    var path: String { get }
    var method: Method { get }
    var parameters: [String: String?]? { get }
    
}
extension BaseAPI {
    var completeURL: URL? {
        let urlString = self.baseURL + self.path
        switch self.method {
        case .get:
            let withParameterURLString = urlString + "?" + "\(appendParameter() ?? "")&key=AIzaSyDoSbcx7XYPPbrp6AC72eLXYIN-ZLkCUxU"
            return URL(string: withParameterURLString)
        case .delete, .post, .update:
            return URL(string: urlString)
        }
    }
    
    private func appendParameter() -> String? {
        guard var urlComponents = URLComponents(string: self.baseURL) else { return nil }
            urlComponents.queryItems = appendQueryItems()
            return urlComponents.query
    }
    
    private func appendQueryItems() -> [URLQueryItem] {
        if let parameter = self.parameters {
            var queryItems = [URLQueryItem]()
            for key in parameter.keys {
                if let value = parameter[key] as? String {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            return queryItems
        }
        return []
    }
}
enum Method {
    case get
    case post
    case update
    case delete
}

enum NetworkError: Error {
    case nilTask
    case invailURL
    case jsonParsing
    case connection
    case network(String)
    
    var message: String {
        switch self {
        case .connection:
            "네트워크가 연결되어있지 않습니다."
        case .nilTask:
            "Task가 생성되지 않았습니다."
        case .invailURL:
            "URL이 유효하지 않습니다."
        case .jsonParsing:
            "JsonDecode에 실패하였습니다."
        case .network(let string):
            "네트워크 에러가 발생하였습니다. 코드 : \(string)"
        }
    }
}

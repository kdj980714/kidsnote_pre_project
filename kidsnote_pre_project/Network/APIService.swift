import Foundation

final class APIService {
    private let urlSession: URLSession
    private var task: Task<Any, Error>? = nil
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5.0
        configuration.timeoutIntervalForResource = 5.0
        self.urlSession = URLSession(configuration: configuration)
    }
    
    private func decodeData<T: Decodable>(dataType: T.Type, data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(dataType, from: data)
        } catch {
            throw NetworkError.jsonParsing
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    func makeRequestAPI<T: Decodable>(
        api: BaseAPI,
        url: String = "",
        responseType: T.Type
    ) async throws -> T
    {
        task?.cancel()
        task = Task {
            guard let url = api.completeURL else {
                throw NetworkError.invailURL
            }
            do {
                let (data, _) = try await urlSession.data(from: url)
                return try decodeData(dataType: responseType, data: data)
            } catch {
                if let networkError = error as? NetworkError {
                    throw networkError
                }
                KNLog.logging(message: error.localizedDescription)
                throw NetworkError.network(error.localizedDescription)
            }
        }
        guard
            let result = try await task?.value,
            let value = result as? T
        else {
            throw NetworkError.nilTask
        }
        return value
    }
}


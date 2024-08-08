import Foundation

struct SearchClient {
    static let requestCount = 30
    let searchBookByID: (String, EBookFilter) async throws -> [GoogleBookSearchAPI.BookSearchEntity]
    let searchBookAppend: (EBookFilter) async throws -> [GoogleBookSearchAPI.BookSearchEntity]
}
extension SearchClient {
    static let liveValue: Self = {
        let apiService = APIService()
        var cursorActors: [EBookFilter: BookSearchCursor] = [:]
        
        let searchBookByID: (String, EBookFilter) async throws -> [GoogleBookSearchAPI.BookSearchEntity] = { bookName, filter in
            do {
                try await NetworkMonitor.shared.checkInternet()
                let cursorActor = BookSearchCursor()
                cursorActors[filter] = cursorActor
                
                await updateCursor(
                    bookName: bookName,
                    filter: filter,
                    cursor: cursorActor
                )
                
                return try await requestSearchBookAPIAndUpdateCorsor(cursorActor: cursorActor, apiService: apiService)
            } catch {
                if let error = error as? NetworkError {
                    KNLog.logging(message: error.message)
                    throw error
                } else {
                    KNLog.logging(message: error.localizedDescription)
                }
                return []
            }
        }
        
        let searchBookAppend: (EBookFilter) async throws -> [GoogleBookSearchAPI.BookSearchEntity] = { ebookFilter in
            do {
                try await NetworkMonitor.shared.checkInternet()
                guard let cursorActor = cursorActors[ebookFilter] else { return [] }
                let isEndResult = await cursorActor.getIsEndResult()
                guard !isEndResult else {
                    KNLog.logging(message: "더이상 검색할 내용이 없습니다.")
                    return []
                }
                
                return try await requestSearchBookAPIAndUpdateCorsor(cursorActor: cursorActor, apiService: apiService)
            } catch {
                if let error = error as? NetworkError {
                    KNLog.logging(message: error.message)
                    throw error
                } else {
                    KNLog.logging(message: error.localizedDescription)
                }
            }
            return []
        }
        
        return Self(
            searchBookByID: searchBookByID,
            searchBookAppend: searchBookAppend
        )
    }()
}
private extension SearchClient {
    static func requestSearchBookAPIAndUpdateCorsor(cursorActor: BookSearchCursor, apiService: APIService) async throws -> [GoogleBookSearchAPI.BookSearchEntity] {
        let request = await cursorActor.getRequest()
        guard await !cursorActor.getIsEndResult() else {
            KNLog.logging(message: "더이상 검색할 내용이 없습니다.")
            return []
        }
        
        let result = try await apiService.makeRequestAPI(
            api: GoogleBookSearchAPI.all(
                .init(
                    bookName: request.bookName,
                    filter: request.filter,
                    startIndex: request.startIndex,
                    maxResults: request.maxResults
                )
            ),
            responseType: GoogleBookSearchAPI.BooksSearchResponse.self
        )
        
        requestCount > result.totalItems
        ? await cursorActor.setEndResult()
        : await cursorActor.incrementStartIndex()
        
        guard let items = result.items else { return [] }
        return items.map { .init(dto: $0) }
    }
    
    static func updateCursor(
        bookName: String,
        filter: EBookFilter,
        cursor: BookSearchCursor
    ) async {
        let keyword = await cursor.getKeyword()
        let ebookFilter = await cursor.getFilter()
        if keyword != bookName || ebookFilter != filter {
            await cursor.resetCursor()
            await cursor.setKeyword(keyword: bookName)
            await cursor.setFilter(filter: filter)
        }
    }
}
extension SearchClient {
    actor BookSearchCursor {
        private var startIndex = 0
        private var filter: EBookFilter = .free
        private var isEndResult = false
        private var keyword = ""
        
        func setKeyword(keyword: String) {
            self.keyword = keyword
        }
        
        func getKeyword() -> String {
            return keyword
        }
        
        func setFilter(filter: EBookFilter) {
            self.filter = filter
        }
        
        func getFilter() -> EBookFilter {
            return filter
        }
        
        func resetCursor() {
            startIndex = 0
            isEndResult = false
        }
        
        func setEndResult() {
            self.isEndResult = true
        }
        
        func getIsEndResult() -> Bool {
            return isEndResult
        }
        
        func incrementStartIndex() {
            startIndex += requestCount
        }
        
        func getRequest() -> GoogleBookSearchAPI.Request {
            .init(
                bookName: keyword,
                filter: filter,
                startIndex: startIndex,
                maxResults: requestCount
            )
        }
    }
}

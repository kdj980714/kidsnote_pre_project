import Combine
import Foundation

final class SearchViewModel {
    struct Input {
        let searchBackButtonTapped = PassthroughSubject<Void, Never>()
        let startedSearchViewInput = PassthroughSubject<Void, Never>()
        let scrolledLastContents = PassthroughSubject<Void, Never>()
        let searchFilterTapped = PassthroughSubject<EBookFilter, Never>()
        let searchButtonTapped = PassthroughSubject<String, Never>()
        let selectedBookCellTapped = PassthroughSubject<String, Never>()
    }
    
    final class Output {
        @Published var searchViewState: SearchViewState = .deactive
        @Published var bookSearchEntities: [GoogleBookSearchAPI.BookSearchEntity] = []
        @Published var currentSearchFilter: EBookFilter = .all
        @Published var resetDataSourcesTrigger: Bool = false
        @Published var resetSearchTextTrigger: Bool = false
        @Published var tableViewFirstLoadTrigger: Bool = false
        @Published var isAppendTrigger: Bool = false
        
        @Published var isShowNoSearchResult: Bool = false
        @Published var isShowInternetConnectionView: Bool = false
        @Published var isShowLoadingView: Bool = false
        @Published var isShowAPIFailView: Bool = false
        @Published var destination: Destination = .none
    }
    
    final class State {
        var searchKeyword: String = ""
        var bookSearchEntities: [EBookFilter: [GoogleBookSearchAPI.BookSearchEntity]] = [:]
    }
    
    private var cancelable: Set<AnyCancellable> = []
    private let output = Output()
    private let state = State()
    
    @Dependency(\.searchClient) private var searchClient
    
    func translate(input: Input) -> Output {
        input.searchBackButtonTapped
            .sink { _ in
                self.state.bookSearchEntities = [:]
                self.state.searchKeyword = ""
                self.output.resetDataSourcesTrigger.toggle()
                self.output.searchViewState = .deactive
                self.output.resetSearchTextTrigger.toggle()
            }
            .store(in: &cancelable)
        
        input.startedSearchViewInput
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    self.output.searchViewState = .active
                }
            }
            .store(in: &cancelable)
        
        input.searchButtonTapped
            .sink { [weak self] searchText in
                guard let self else { return }
                if self.state.searchKeyword != searchText {
                    self.state.searchKeyword = searchText
                    self.state.bookSearchEntities = [:]
                    self.output.resetDataSourcesTrigger.toggle()
                } else {
                    return
                }
                Task {
                    await self.requestSearchBook(by: searchText)
                }
            }
            .store(in: &cancelable)
        
        input.searchFilterTapped
            .sink { [weak self] ebookFilter in
                guard let self else { return }
                self.output.currentSearchFilter = ebookFilter
                if 
                    state.searchKeyword != "",
                    self.state.bookSearchEntities[ebookFilter] == nil
                {
                    Task {
                        await self.requestSearchBook(by: self.state.searchKeyword)
                    }
                } else {
                    output.bookSearchEntities =  self.state.bookSearchEntities[ebookFilter] ?? []
                }
            }
            .store(in: &cancelable)
        
        input.scrolledLastContents
            .throttle(for: 3, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let self else { return }
                if self.state.searchKeyword != "" {
                    Task {
                        await self.requestAppendSearchBook()
                    }
                }
            }
            .store(in: &cancelable)
        
        input.selectedBookCellTapped
            .sink { [weak self] id in
                guard let self else { return }
                if let selectedModel = self.state.bookSearchEntities[output.currentSearchFilter]?
                    .first(where: { $0.id == id }) {
                    self.output.destination = .searchDetail(selectedModel.id)
                }
                    
                
            }
            .store(in: &cancelable)
            
        return output
    }
}
private extension SearchViewModel {
    func requestSearchBook(by searchText: String) async {
        if !searchText.isEmpty {
            do {
                output.isShowLoadingView = true
                let bookSearchEntities = try await self.searchClient.searchBookByID(searchText, output.currentSearchFilter)
                if bookSearchEntities.isEmpty {
                    output.searchViewState = .emptyResult
                    return
                }
                state.bookSearchEntities[output.currentSearchFilter] = bookSearchEntities
                output.bookSearchEntities = bookSearchEntities
                output.tableViewFirstLoadTrigger.toggle()
                output.isShowLoadingView = false
                output.searchViewState = .active
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .connection:
                        output.searchViewState = .notConnectedNetwork
                    default:
                        output.searchViewState = .networkError
                    }
                }
                output.isShowLoadingView = false
            }
        }
    }
    
    func requestAppendSearchBook() async {
        do {
            output.isShowLoadingView = true
            let bookSearchEntities = try await self.searchClient.searchBookAppend(output.currentSearchFilter)
            if bookSearchEntities.isEmpty {
                output.isShowLoadingView = false
                return
            }
            state.bookSearchEntities[output.currentSearchFilter]?.append(contentsOf: bookSearchEntities)
            output.bookSearchEntities.append(contentsOf: bookSearchEntities)
            output.isAppendTrigger.toggle()
            output.isShowLoadingView = false
            output.searchViewState = .active
        } catch {
            if let error = error as? NetworkError {
                switch error {
                case .connection:
                    output.searchViewState = .notConnectedNetwork
                default:
                    output.searchViewState = .networkError
                }
            }
            output.isShowLoadingView = false
        }
    }
}

enum SearchViewState {
    case active
    case deactive
    case emptyResult
    case notConnectedNetwork
    case networkError
}

enum Destination {
    case none
    case searchDetail(String)
}

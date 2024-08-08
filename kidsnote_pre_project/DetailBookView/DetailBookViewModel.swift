import Combine
import Foundation
import UIKit

final class DetailBookViewModel {
    init(state: State) {
        self.state = state
    }
    
    struct Input { 
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let sampleButtonTapped = PassthroughSubject<Void, Never>()
        let shoppingButtonTapped = PassthroughSubject<Void, Never>()
    }
    final class Output {
        @Published var entity: GoogleBookSearchAPI.DetailBookEntity?
        
    }
    final class State {
        init(id: String) {
            self.id = id
        }
        
        let id: String
    }
    
    private var cancelable: Set<AnyCancellable> = []
    private let state: State
    private let output = Output()
    
    @Dependency(\.detailBookClient) private var detailBookClient
    
    func translate(input: Input) -> Output {
        input.viewDidLoad
            .first()
            .sink { [weak self] _ in
            guard let self else { return }
            Task {
                do {
                    let result = try await self.detailBookClient.requestDetail(self.state.id)
                    self.output.entity = result
                } catch {
                    if let error = error as? NetworkError {
                        KNLog.logging(message: "\(error.message)")
                    } else {
                        KNLog.logging(message: "\(error)")
                    }
                }
            }
        }
        .store(in: &cancelable)
        
        input.sampleButtonTapped
            .sink { [weak self] _ in
                guard let self else { return }
                self.openURL(by: self.output.entity?.sampleURL)
            }
            .store(in: &cancelable)
        
        input.shoppingButtonTapped
            .sink { [weak self] _ in
                guard let self else { return }
                self.openURL(by: self.output.entity?.buyURL)
            }
            .store(in: &cancelable)
        
        return output
    }
}
private extension DetailBookViewModel {
    func openURL(by url: String?) {
        guard
            let url = URL(string: url ?? ""),
            UIApplication.shared.canOpenURL(url)
        else {
            KNLog.logging(message: "URL을 열 수 없습니다.")
            return
        }
        UIApplication.shared.open(url)
    }
}

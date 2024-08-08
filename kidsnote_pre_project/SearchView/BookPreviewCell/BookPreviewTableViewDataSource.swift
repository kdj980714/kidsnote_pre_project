import UIKit

final class BookPreviewTableViewDataSource: NSObject {
    private(set) var cellViewModels: [GoogleBookSearchAPI.BookSearchEntity] = []
    var currentCellTotalCount: Int {
        cellViewModels.count
    }
}
extension BookPreviewTableViewDataSource {
    func updateViewModels(by cellViewModels: [GoogleBookSearchAPI.BookSearchEntity]) {
        self.cellViewModels = cellViewModels
    }
    
    func resetData() {
        self.cellViewModels = []
    }
}
extension BookPreviewTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCellTotalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookPreviewCell.id) as? BookPreviewCell else { return .init() }
        let viewModel = cellViewModels[indexPath.item]
        cell.configuration(with: viewModel)
        return cell
    }
}

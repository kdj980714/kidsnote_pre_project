import UIKit

final class BookPreviewTableViewDelegate: NSObject {
    private var scrollViewShowEndContents: (() -> ())?
    private var cellDidSelect: ((Int) -> ())?
}
extension BookPreviewTableViewDelegate {
    func setScrollViewShowEndContents(scrollViewShowEndContents: @escaping (() -> ())) {
        self.scrollViewShowEndContents = scrollViewShowEndContents
    }
    
    func setCellDidSelect(cellDidSelect: @escaping ((Int) -> ())) {
        self.cellDidSelect = cellDidSelect
    }
}
extension BookPreviewTableViewDelegate: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        if offsetY > contentHeight - screenHeight {
            self.scrollViewShowEndContents?()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.cellDidSelect?(indexPath.item)
    }
}

import UIKit
import SnapKit

final class IndicatorFooterView: UITableViewHeaderFooterView {
    static let id: String = String(describing: IndicatorFooterView.self)
    static let height: CGFloat = 40.0
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.backgroundColor = .clear
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
private extension IndicatorFooterView {
    func layout() {
        contentView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

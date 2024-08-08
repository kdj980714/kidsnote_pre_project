import UIKit
import SnapKit

extension TabMenuView {
    final class TabButton<ViewModel: TabViewType>: UIButton {
        let viewModel: ViewModel
        private(set) var isSelectedTab: Bool = false
        private let buttonText = UILabel()
        let bottomBar = UIView()
        
        init(viewModel: ViewModel, isSelectedTab: Bool) {
            self.viewModel = viewModel
            self.isSelectedTab = isSelectedTab
            super.init(frame: .zero)
            attribute()
            layout()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layout() {
            buttonText.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            bottomBar.snp.makeConstraints { make in
                make.top.equalTo(self.snp.bottom)
                make.width.equalTo(self.snp.width).dividedBy(2)
                make.height.equalTo(2)
                make.centerX.equalToSuperview()
            }
        }
        
        private func attribute() {
            addSubview(buttonText)
            addSubview(bottomBar)
            buttonText.font = .systemFont(ofSize: 12, weight: .semibold)
            buttonText.text = viewModel.displayTitle
            buttonText.textAlignment = .center
            bottomBar.backgroundColor = .systemBlue
            isSelectedTab ? updateSelectedUI() : updateDeSelectedUI()
        }
        
        private func updateSelectedUI() {
            bottomBar.isHidden = false
            buttonText.textColor = .systemBlue
        }
        
        private func updateDeSelectedUI() {
            bottomBar.isHidden = true
            buttonText.textColor = .systemGray4
        }
        
        func updateIsSelected(selectedViewModel: ViewModel) {
            if viewModel != selectedViewModel, isSelectedTab {
                isSelectedTab = false
            }
            if !isSelectedTab, viewModel == selectedViewModel {
               isSelectedTab = true
            }
            self.isSelectedTab ? updateSelectedUI() : updateDeSelectedUI()
        }
    }
}

import UIKit
import SnapKit

final class TabMenuView<Model: TabViewType>: UIView {
    private var viewModels: [Model] = []
    private var menuTapped: ((Model) -> Void)?
    private var selectedModel: Model?
    private var tabButtons: [TabButton<Model>] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attribute(
        viewModels: [Model],
        menuTapped: ((Model) -> Void)?,
        isSelected: Model? = nil
    ) {
        self.viewModels = viewModels
        self.menuTapped = menuTapped
        isSelected == nil
        ? (self.selectedModel = viewModels.first)
        : (self.selectedModel = isSelected)
        layout()
    }
    
    func updateIsSelected(selectedViewModel: Model) {
        tabButtons.forEach { tabButton in
            guard let selectedModel else { return }
            tabButton.updateIsSelected(selectedViewModel: selectedModel)
        }
    }
    
    private func layout() {
        let containerView = UIView()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let grayLine = UIView()
        grayLine.backgroundColor = .gray
        containerView.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(containerView)
            make.height.equalTo(1)
        }
        
        for viewModel in viewModels {
            let isSelected = viewModel == self.selectedModel
            let tabButton = TabButton(viewModel: viewModel, isSelectedTab: isSelected)
            tabButton.addAction(.init(handler: { [weak self] _ in
                guard
                    let self,
                    let selectedModel = self.selectedModel
                else {
                    return
                }
                self.selectedModel = viewModel
                self.menuTapped?(viewModel)
            }), for: .touchUpInside)
            stackView.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
        }
    }
}



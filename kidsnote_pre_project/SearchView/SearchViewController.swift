import Combine
import SnapKit
import UIKit


final class SearchViewController: UIViewController {
    private let searchTextField = UITextField()
    let backButton = UIButton(type: .system)
    let searchCancelButton = UIButton(type: .system)
    private let tabMenuView = TabMenuView<EBookFilter>(frame: .zero)
    
    private let  headerLabel = UILabel()
    private let footerIndicator = UIActivityIndicatorView()
    private let tableViews: [EBookFilter: UITableView] = {
        var tableViewDictionary: [EBookFilter: UITableView] = [:]
        let filters = EBookFilter.allCases
        for filter in filters {
            let tableView = UITableView()
            tableView.register(BookPreviewCell.self, forCellReuseIdentifier: BookPreviewCell.id)
            tableView.register(IndicatorFooterView.self, forHeaderFooterViewReuseIdentifier: IndicatorFooterView.id)
            tableView.rowHeight = BookPreviewCell.height
            tableViewDictionary[filter] = tableView
        }
        return tableViewDictionary
    }()
    
    private var currentTableView: UITableView?
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let viewModel = SearchViewModel()
    private let input = SearchViewModel.Input()
    private let searchTableDataSources: [EBookFilter: BookPreviewTableViewDataSource] = {
        var datasources: [EBookFilter: BookPreviewTableViewDataSource] = [:]
        let filters = EBookFilter.allCases
        for filter in filters {
            datasources[filter] = BookPreviewTableViewDataSource()
        }
        return datasources
    }()
    private var currentSearchTableDataSource: BookPreviewTableViewDataSource?
    
    private let searchTableDelegates: [EBookFilter: BookPreviewTableViewDelegate] = {
        var delegates: [EBookFilter: BookPreviewTableViewDelegate] = [:]
        let filters = EBookFilter.allCases
        for filter in filters {
            delegates[filter] = BookPreviewTableViewDelegate()
        }
        return delegates
    }()
    private var currentSearchTableDelegate: BookPreviewTableViewDelegate?
    private var cancelable: Set<AnyCancellable> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLayout()
        viewAttribute()
        binding()
    }
    
    private func viewLayout() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        view.addSubview(searchCancelButton)
        searchCancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
        
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(backButton.snp.trailing).offset(16)
            make.trailing.equalTo(searchCancelButton.snp.leading).offset(-16)
            make.height.equalTo(50)
        }
        
        view.addSubview(tabMenuView)
        tabMenuView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.top.equalTo(tabMenuView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableViews.forEach { (_, tableView) in
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(tabMenuView.snp.bottom).offset(15)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
    
    private func viewAttribute() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        headerLabel.text = "Google Play 검색결과"
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 8
        searchTextField.placeholder = "검색어를 입력해주세요."
        
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .gray
        searchCancelButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        searchCancelButton.tintColor = .gray
        footerIndicator.startAnimating()
        
        prepareTableViews()
        
        backButton.addAction(
            .init { [weak self] _ in
                guard let self else { return }
                self.input.searchBackButtonTapped.send(())
            },
            for: .touchUpInside
        )
        
        searchCancelButton.addAction(
            .init { [weak self] _ in
                guard let self else { return }
                self.searchTextField.text = ""
            },
            for: .touchUpInside
        )
        
        tabMenuView.attribute(viewModels: EBookFilter.allCases) { tappedModel in
            self.input.searchFilterTapped.send(
                EBookFilter(
                    rawValue: tappedModel.id
                ) ?? .all
            )
        }
    }
    
    private func binding() {
        let output = viewModel.translate(input: input)
        output.$searchViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchViewState in
                guard let self else { return }
                switch searchViewState {
                case .active:
                    self.backButton.isHidden = false
                    self.searchCancelButton.isHidden = false
                    self.tabMenuView.isHidden = false
                    self.currentTableView?.isHidden = false
                    self.noticeLabel.isHidden = true
                case .deactive:
                    self.backButton.isHidden = true
                    self.searchCancelButton.isHidden = true
                    self.tabMenuView.isHidden = true
                    self.currentTableView?.isHidden = true
                    self.noticeLabel.isHidden = true
                    view.endEditing(true)
                case .emptyResult:
                    self.noticeLabel.isHidden = false
                    self.noticeLabel.text = "검색결과가 없습니다."
                    self.currentTableView?.isHidden = true
                    view.endEditing(true)
                case .networkError:
                    self.noticeLabel.isHidden = false
                    self.noticeLabel.text = "데이터를 가져오는 중 에러가 발생하였습니다."
                    self.currentTableView?.isHidden = true
                    break
                case .notConnectedNetwork:
                    self.noticeLabel.text = "네트워크 연결을 확인해주세요."
                    self.noticeLabel.isHidden = false
                    self.currentTableView?.isHidden = true
                    break
                }
            }
            .store(in: &cancelable)
        
        output.$currentSearchFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ebookFilter in
                guard let self else { return }
                self.tabMenuView.updateIsSelected(selectedViewModel: ebookFilter)
                self.currentTableView = self.tableViews[ebookFilter]
                self.tableViews.forEach { (key, tableView) in
                    tableView.isHidden = key == ebookFilter ? false : true
                }
                self.currentSearchTableDataSource = self.searchTableDataSources[ebookFilter]
                self.currentSearchTableDelegate = self.searchTableDelegates[ebookFilter]
            }
            .store(in: &cancelable)
        
        output.$resetSearchTextTrigger
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.searchTextField.text = ""
            }
            .store(in: &cancelable)
        
        output.$resetDataSourcesTrigger
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.searchTableDataSources.forEach { (key, dataSource) in
                    dataSource.resetData()
                    self.tableViews[key]?.reloadData()
                }
            }
            .store(in: &cancelable)
        
        output.$tableViewFirstLoadTrigger
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let entities = output.bookSearchEntities
                self.currentSearchTableDataSource?.updateViewModels(by: entities)
                self.currentTableView?.reloadData()
            }
            .store(in: &cancelable)
        
        output.$bookSearchEntities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                guard let self else { return }
                if entities.isEmpty {
                    self.currentTableView?.tableHeaderView = nil
                } else {
                    self.addHeaderTitle()
                }
            }
            .store(in: &cancelable)
        
        output.$isAppendTrigger
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                guard let currentSearchTableDataSource = self.currentSearchTableDataSource else {
                    return
                }
                let beforeCellCount = currentSearchTableDataSource.currentCellTotalCount
                let updateCellCount = output.bookSearchEntities.count
                currentSearchTableDataSource.updateViewModels(by: output.bookSearchEntities)
                var indexPaths: [IndexPath] = []
                for index in beforeCellCount ..< updateCellCount {
                    indexPaths.append(.init(row: index, section: 0))
                }
                self.currentTableView?.insertRows(at: indexPaths, with: .automatic)
            }
            .store(in: &cancelable)
        
        output.$isShowLoadingView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                guard let currentTableView = self.currentTableView else { return }
                if isLoading {
                    currentTableView.tableFooterView = IndicatorFooterView(frame: .init(x: 0, y: 0, width: 0, height: 72))
                } else {
                    currentTableView.tableFooterView = nil
                }
            }
            .store(in: &cancelable)
        
        output.$destination
            .receive(on: DispatchQueue.main)
            .sink { destination in
                switch destination {
                case .searchDetail(let id):
                    let detailBookViewController = DetailBookViewController(
                        viewModel: DetailBookViewModel(
                            state: .init(
                                id: id
                            )
                        )
                    )
                    self.navigationController?.pushViewController(detailBookViewController, animated: true)
                default: break
                }
            }
            .store(in: &cancelable)
    }
    
    private func prepareTableViews() {
        tableViews.forEach { (_, tableView) in
            tableView.isHidden = true
        }
        
        searchTableDelegates.forEach { (key, delegate) in
            delegate.setScrollViewShowEndContents { [weak self] in
                guard let self else { return }
                self.input.scrolledLastContents.send(())
                //request append API
            }
            
            delegate.setCellDidSelect { index in
                //request cellTapped Event
                
                guard
                    let cellViewModels = self.currentSearchTableDataSource?.cellViewModels,
                cellViewModels.count > index
                else {
                    return
                }
                let selectedItem = cellViewModels[index]
                self.input.selectedBookCellTapped.send(selectedItem.id)
            }
        }
        
        for filter in EBookFilter.allCases {
            tableViews[filter]?.dataSource = searchTableDataSources[filter]
            tableViews[filter]?.delegate = searchTableDelegates[filter]
        }
    }
    
    private func addHeaderTitle() {
        guard let tableViewFrame = currentTableView?.frame.width else { return }
        let headerLabel = self.headerLabel
        headerLabel.frame = CGRect(x: 15, y: 0, width: tableViewFrame, height: 44)
        self.currentTableView?.tableHeaderView = headerLabel
    }
}
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.input.searchButtonTapped.send(textField.text ?? "")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.input.startedSearchViewInput.send(())
    }
}


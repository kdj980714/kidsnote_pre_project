import Combine
import UIKit
import SnapKit

final class DetailBookViewController: UIViewController {
    private let viewModel: DetailBookViewModel
    private let input = DetailBookViewModel.Input()
    private var cancelabel = Set<AnyCancellable>()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let bookThumbnailImageView = UIImageView()
    private let bookTitleLabel = UILabel()
    private let bookAuthorLabel = UILabel()
    private let bookPageAndKindLabel = UILabel()
    private let vline1 = UIView()
    private let vline2 = UIView()
    private let sampleButton = UIButton()
    private let shoppingButton = UIButton()
    private let starContainer = UIView()
    
    private let bookInfoTitleLabel = UILabel()
    private let bookDescriptionLabel = UILabel()
    private let publisherDateTitleLabel = UILabel()
    private let publisherDateLabel = UILabel()
    
    init(viewModel: DetailBookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        viewAttribute()
        layout()
        input.viewDidLoad.send(())
    }
    
    private func binding() {
        let output = viewModel.translate(input: input)
        
        output.$entity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entity in
                guard let self, let entity else { return }
                self.attributeDetailView(with: entity)
            }
            .store(in: &cancelabel)
    }
    
    private func layout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView) // Ensure contentView width matches scrollView width
        }
        
        contentView.addSubview(bookThumbnailImageView)
        bookThumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(120)
        }
        
        contentView.addSubview(bookTitleLabel)
        bookTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(15)
        }
        
        contentView.addSubview(bookAuthorLabel)
        bookAuthorLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitleLabel.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(15)
        }
        
        contentView.addSubview(bookPageAndKindLabel)
        bookPageAndKindLabel.snp.makeConstraints { make in
            make.top.equalTo(bookAuthorLabel.snp.bottom)
            make.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(15)
        }
        
        contentView.addSubview(vline1)
        vline1.snp.makeConstraints { make in
            make.top.equalTo(bookThumbnailImageView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.addSubview(sampleButton)
        let buttonHorizontalPadding = 15
        let buttonWidth = (UIScreen.main.bounds.width - CGFloat(buttonHorizontalPadding * 2)) / 2 - 15
        sampleButton.snp.makeConstraints { make in
            make.top.equalTo(vline1.snp.top).offset(20)
            make.leading.equalToSuperview().offset(buttonHorizontalPadding)
            make.height.equalTo(44)
            make.width.equalTo(buttonWidth)
        }
        
        sampleButton
            .addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                self.input.sampleButtonTapped.send(())
            }), for: .touchUpInside)
        
        contentView.addSubview(shoppingButton)
        shoppingButton.snp.makeConstraints { make in
            make.top.equalTo(vline1.snp.top).offset(20)
            make.trailing.equalToSuperview().offset(-buttonHorizontalPadding)
            make.height.equalTo(44)
            make.width.equalTo(buttonWidth)
        }
        
        shoppingButton
            .addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                self.input.shoppingButtonTapped.send(())
            }), for: .touchUpInside)
        
        contentView.addSubview(vline2)
        vline2.snp.makeConstraints { make in
            make.top.equalTo(sampleButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.addSubview(bookInfoTitleLabel)
        contentView.addSubview(bookDescriptionLabel)
        bookDescriptionLabel.numberOfLines = 0
        contentView.addSubview(publisherDateTitleLabel)
        contentView.addSubview(publisherDateLabel)
    }
    
    private func viewAttribute() {
        view.backgroundColor = .white
        title = "도서 정보"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        bookThumbnailImageView.contentMode = .scaleAspectFit
        bookTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        bookTitleLabel.textColor = .label
        bookTitleLabel.numberOfLines = 2
        bookAuthorLabel.font = .systemFont(ofSize: 14, weight: .light)
        bookAuthorLabel.textColor = .systemGray
        bookPageAndKindLabel.font = .systemFont(ofSize: 14, weight: .light)
        bookPageAndKindLabel.textColor = .systemGray
        sampleButton.setTitle("무료 샘플", for: .normal)
        sampleButton.backgroundColor = .systemBlue
        sampleButton.setTitleColor(.label, for: .normal)
        sampleButton.layer.cornerRadius = 7
        sampleButton.titleLabel?.font = .systemFont(ofSize: 16)
        shoppingButton.setTitle("전체 도서 구매하기", for: .normal)
        shoppingButton.setTitleColor(.systemBlue, for: .normal)
        shoppingButton.titleLabel?.font = .systemFont(ofSize: 16)
        shoppingButton.layer.borderColor = UIColor.gray.cgColor
        shoppingButton.layer.borderWidth = 1
        shoppingButton.layer.cornerRadius = 7
        vline1.backgroundColor = .systemGray
        vline2.backgroundColor = .systemGray
        bookInfoTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        bookInfoTitleLabel.text = "책 정보"
        bookInfoTitleLabel.textColor = .label
        bookDescriptionLabel.font = .systemFont(ofSize: 14, weight: .light)
        publisherDateTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        publisherDateTitleLabel.text = "게시일"
        publisherDateLabel.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private func attributeDetailView(with entity: GoogleBookSearchAPI.DetailBookEntity) {
        let imageFetcher = ImageFetcher()
        Task {
            if entity.id != "" {
                bookThumbnailImageView.image = try? await imageFetcher.fetchImage(by: entity.id, imageURL: entity.bookThumbnailURL)
            }
        }
        
        bookTitleLabel.text = entity.bookName
        bookAuthorLabel.text = entity.author
        bookPageAndKindLabel.text = "\(entity.bookKind.displayTitle) \(entity.totalPage)페이지"
        
        bookDescriptionLabel.text = entity.description
        publisherDateLabel.text = entity.publishedDate
        
        let isShowRatingContainer = entity.averageRating != -1
        if isShowRatingContainer {
            contentView.addSubview(starContainer)
            starContainer.snp.makeConstraints { make in
                make.top.equalTo(vline2.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(60)
            }
            
            let averageCount = entity.ratingsCount
            let averageRating = entity.averageRating
            let averageLabel = UILabel()
            starContainer.addSubview(averageLabel)
            averageLabel.text = "\(averageRating)"
            averageLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            averageLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            let fillStarImage = UIImage(systemName: "star.fill")
            let starImage = UIImage(systemName: "star")
            
            let stackView = UIStackView()
            starContainer.addSubview(stackView)
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 3
            stackView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalTo(averageLabel.snp.trailing).offset(10)
                make.height.equalTo(15)
            }
            
            for _ in 0 ..< Int(averageRating) {
                let fillStarImageView = UIImageView(image: fillStarImage)
                stackView.addArrangedSubview(fillStarImageView)
            }
            let percentage = entity.averageRating.truncatingRemainder(dividingBy: 1.0)
            if percentage != 0 {
                let starImageView = UIImageView()
                if percentage >= 0.5 {
                    starImageView.image = .init(systemName: "star.leadinghalf.filled")
                } else {
                    starImageView.image = starImage
                }
                stackView.addArrangedSubview(starImageView)
            }
            if averageCount > 0 {
                let allRatingCountLabel = UILabel()
                starContainer.addSubview(allRatingCountLabel)
                allRatingCountLabel.text = "Google Play 평점 \(averageCount)개"
                allRatingCountLabel.font = .systemFont(ofSize: 14, weight: .light)
                allRatingCountLabel.textColor = .systemGray
                allRatingCountLabel.snp.makeConstraints { make in
                    make.top.equalTo(averageLabel.snp.bottom).offset(5)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                }
            }
           
            bookInfoTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(starContainer.snp.bottom).offset(30)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
        } else {
            bookInfoTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(vline2.snp.bottom).offset(30)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
        }
        
        bookDescriptionLabel.text = entity.description
        bookDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(bookInfoTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        publisherDateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookDescriptionLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        publisherDateLabel.text = entity.publishedDate
        publisherDateLabel.snp.makeConstraints { make in
            make.top.equalTo(publisherDateTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }
}

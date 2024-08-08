import UIKit
import SnapKit

final class BookPreviewCell: UITableViewCell {
    static let id: String = String(describing: BookPreviewCell.self)
    static let height: CGFloat = 100
    private let thumbImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let contentsTypeLabel = UILabel()
    private let imageFetcher = ImageFetcher()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewAttribute()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        thumbImageView.image = nil
        imageFetcher.cancelTask()
        titleLabel.text = nil
        authorLabel.text = nil
        contentsTypeLabel.text = nil
    }
}
private extension BookPreviewCell {
    func viewAttribute() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(contentsTypeLabel)
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        authorLabel.font = .systemFont(ofSize: 10, weight: .light)
        contentsTypeLabel.font = .systemFont(ofSize: 10, weight: .light)
        titleLabel.textColor = .label
        authorLabel.textColor = .systemGray
        contentsTypeLabel.textColor = .systemGray
    }
    
    func layout() {
        thumbImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(15)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(15)
        }
        
        contentsTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(15)
        }
    }
}
extension BookPreviewCell {
    func configuration(with previewModel: GoogleBookSearchAPI.BookSearchEntity) {
        titleLabel.text = previewModel.bookName
        authorLabel.text = previewModel.author
        contentsTypeLabel.text = previewModel.bookKind.displayTitle
        Task { @MainActor in
            thumbImageView.image = try await imageFetcher.fetchImage(by: previewModel.id, imageURL: previewModel.bookThumbnailURL)
        }
    }
}

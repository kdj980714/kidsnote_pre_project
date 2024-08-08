extension GoogleBookSearchAPI {
    struct Request {
        let bookName: String
        let filter: EBookFilter
        let startIndex: Int
        let maxResults: Int
    }
}

extension GoogleBookSearchAPI {
    struct BooksSearchResponse: Codable {
        let kind: String
        let items: [BookSearchDTO]?
        let totalItems: Int
    }
    
    struct BookSearchDTO: Codable {
        let kind: String?
        let id: String?
        let etag: String?
        let selfLink: String?
        let volumeInfo: BookSimpleDTO?
    }

    struct BookSimpleDTO: Codable {
        let title: String?
        let authors: [String]?
    }
    
    struct BookSearchEntity {
        init(dto: BookSearchDTO) {
            id = dto.id ?? ""
            bookName = dto.volumeInfo?.title ?? ""
            author = dto.volumeInfo?.authors?.first ?? ""
            bookThumbnailURL = GoogleBookImageURL.thumbnail(id: dto.id ?? "")
            bookKind = ContentsType.init(value: dto.kind ?? "") ?? .none
        }
        
        let id: String
        let bookThumbnailURL: String
        let bookName: String
        let author: String
        let bookKind: ContentsType
    }
}

protocol TabViewType: Equatable, Identifiable {
    var displayTitle: String { get }
    var id: String { get }
}
enum EBookFilter: String, CaseIterable {
    case all = "ebooks"
    case free = "free-ebooks"
    
    var value: String {
        return rawValue
    }
}
extension EBookFilter: TabViewType {
    var displayTitle: String {
        switch self {
        case .all:
            return "전체 Ebook"
        case .free:
            return "무료 Ebook"
        }
    }
    
    var id: String { return rawValue }
}

enum ContentsType {
    case ebook
    case none
    init?(value: String) {
        switch value {
        case "books#volume":
            self = .ebook
        default: return nil
        }
    }
    
    var displayTitle: String {
        switch self {
        case .ebook:
            return "eBook"
        case .none:
            return "none"
        }
    }
}

enum GoogleBookImageURL {
    static func thumbnail(id: String) -> String {
        return "https://books.google.com/books?id=\(id)&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api"
    }
}

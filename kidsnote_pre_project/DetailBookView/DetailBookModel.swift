import Foundation

extension GoogleBookSearchAPI {
    struct DetailBookEntity {
        init(dto: DetailBookResponse) {
            id = dto.id ?? ""
            bookThumbnailURL = dto.volumeInfo?.imageLinks?.medium ?? ""
            bookName = dto.volumeInfo?.title ?? ""
            author = dto.volumeInfo?.authors?.first ?? ""
            bookKind = ContentsType.init(value: dto.kind ?? "") ?? .none
            totalPage = dto.volumeInfo?.pageCount ?? -1
            sampleURL = dto.accessInfo?.epub?.acsTokenLink ?? ""
            buyURL = dto.saleInfo?.buyLink ?? ""
            description = dto.volumeInfo?.description ?? ""
            averageRating = dto.volumeInfo?.averageRating ?? -1
            ratingsCount = dto.volumeInfo?.ratingsCount ?? -1
            publishedDate = dto.volumeInfo?.publishedDate ?? ""
        }
        
        let id: String
        let bookThumbnailURL: String
        let bookName: String
        let author: String
        let bookKind: ContentsType
        let totalPage: Int
        let sampleURL: String //acsTokenLink
        let buyURL: String //buyLink
        let description: String
        let averageRating: Double
        let ratingsCount: Int
        let publishedDate: String
    }
    
    struct DetailBookResponse: Codable {
        let kind: String?
        let id: String?
        let etag: String?
        let volumeInfo: VolumeInfo?
        let saleInfo: SaleInfo?
        let accessInfo: AccessInfo?
    }

    struct AccessInfo: Codable {
        let country: String?
        let viewability: String?
        let embeddable: Bool?
        let publicDomain: Bool?
        let textToSpeechPermission: String?
        let epub: Epub?
        let pdf: PDF?
        let accessViewStatus: String?
    }

    struct Epub: Codable {
        let isAvailable: Bool?
        let acsTokenLink: String?
    }

    struct PDF: Codable {
        let isAvailable: Bool?
    }

    struct SaleInfo: Codable {
        let country: String?
        let saleability: String?
        let isEbook: Bool?
        let listPrice: RetailPrice?
        let retailPrice: RetailPrice?
        let buyLink: String?
    }

    struct RetailPrice: Codable {
        let amount: Double?
        let currencyCode: String?
    }

    struct VolumeInfo: Codable {
        let title: String?
        let authors: [String]?
        let publisher: String?
        let publishedDate: String?
        let description: String?
        let industryIdentifiers: [IndustryIdentifier]?
        let pageCount: Int?
        let dimensions: Dimensions?
        let printType: String?
        let mainCategory: String?
        let categories: [String]?
        let averageRating: Double?
        let ratingsCount: Int?
        let contentVersion: String?
        let imageLinks: ImageLinks?
        let language: String?
        let infoLink: String?
        let canonicalVolumeLink: String?
    }

    struct Dimensions: Codable {
        let height: String?
        let width: String?
        let thickness: String?
    }

    struct ImageLinks: Codable {
        let medium: String?
    }

    struct IndustryIdentifier: Codable {
        let type: String?
        let identifier: String?
    }
}


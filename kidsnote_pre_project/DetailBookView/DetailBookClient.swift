import Foundation


struct DetailBookClient {
    let requestDetail: (String) async throws -> GoogleBookSearchAPI.DetailBookEntity?
}
extension DetailBookClient {
    static let liveValue: Self = {
        let apiService = APIService()
        
        let requestDetail: (String) async throws -> GoogleBookSearchAPI.DetailBookEntity? = { id in
            do {
                try await NetworkMonitor.shared.checkInternet()
                let result = try await apiService.makeRequestAPI(api: GoogleBookSearchAPI.detail(id), responseType: GoogleBookSearchAPI.DetailBookResponse.self)
                return .init(dto: result)
                } catch {
                if let error = error as? NetworkError {
                    KNLog.logging(message: error.message)
                    throw error
                } else {
                    KNLog.logging(message: error.localizedDescription)
                }
            }
            return nil
        }
        return Self(
            requestDetail: requestDetail
        )
    }()
    
    static let testValue: Self = {
        let requestDetail: (String) async throws -> GoogleBookSearchAPI.DetailBookEntity? = { id in
            
            let json = """
{
  "kind": "books#volume",
  "id": "Bm5KDgAAQBAJ",
  "etag": "MZsfVaddP+4",
  "selfLink": "https://www.googleapis.com/books/v1/volumes/Bm5KDgAAQBAJ",
  "volumeInfo": {
    "title": "Always On",
    "subtitle": "How the iPhone Unlocked the Anything-Anytime-Anywhere Future--and Locked Us In",
    "authors": [
      "Brian X. Chen"
    ],
    "publisher": "Hachette UK",
    "publishedDate": "2012-09-25",
    "description": "abcdsafjkdlsa;jfkdsla;jfkldsa;",
    "industryIdentifiers": [
      {
        "type": "ISBN_10",
        "identifier": "0306822105"
      },
      {
        "type": "ISBN_13",
        "identifier": "9780306822100"
      }
    ],
    "readingModes": {
      "text": true,
      "image": false
    },
    "pageCount": 256,
    "printedPageCount": 163,
    "dimensions": {
      "height": "21.00 cm"
    },
    "printType": "BOOK",
    "categories": [
      "Technology & Engineering / Electronics / Digital"
    ],
    "averageRating": 3.5,
  "ratingsCount": 136,
    "maturityRating": "NOT_MATURE",
    "allowAnonLogging": false,
    "contentVersion": "1.2.3.0.preview.2",
    "panelizationSummary": {
      "containsEpubBubbles": false,
      "containsImageBubbles": false
    },
    "imageLinks": {
      "smallThumbnail": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&imgtk=AFLRE72hlBUMSNCwVW6RVgNE_3EMbiv_BtnbhUYhE4aSOG14GDcAPci9v2Fl1naXCxGB5TKvasE8wOpxrSQCv0hiihK3A22thp1JN3sl3kYTx4a7CCCLzYHqSFJxNidUe93UC8kRwLsJ&source=gbs_api",
      "thumbnail": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE70JiWcIb9yaixFCbN7s-f7i_vBLIlibOaarywTNqKKTdeGpnNEv8G4qq9eY_KRqzVuaRTiV-Br3PuPShylL8mEl4LbCGvrSE6Kja9b3FOhzJCFLVyGPWu2c7I8mIr1g0p-eoG72&source=gbs_api",
      "small": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=2&edge=curl&imgtk=AFLRE737gmP2Ng8SzNqnGT8Z3MDiVbcIboRBRxKuf9Y2zAsEbWd8m9Kj_K0ASiRnrotzDvC1pWQbGdayCAbMgGepvv6dpW1Iwxd4B56a9fOgAzu7lMINiWrNvQxJqEgIiBWD6Z17jaf4&source=gbs_api",
      "medium": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=3&edge=curl&imgtk=AFLRE71MEtO9ew9Th2IYVVtqLHWYDKhzRM3CUfEc5GVI_S08fcoWDVjJFDioWmAS1G3L5_UGzQNJQ3ESUE2pTj3ATEJwYCtQoY8eRCqYt98sa86QM9-fxH0405rsrEDxRbP9goFmlt0-&source=gbs_api",
      "large": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=4&edge=curl&imgtk=AFLRE72rTo8Jtpm9cv2Cl1LOSbhZSjg0rGe9dvhklmoT5dnANbJqJU2dP7_3sR5bsDkWawS7hVNkrHZLaZkOvzO-HrRyTxcBG57aX1Pm2HSOH4oJPwBdPMiQgW5XkQ004ZR0RdSt-vir&source=gbs_api",
      "extraLarge": "http://books.google.com/books/publisher/content?id=Bm5KDgAAQBAJ&printsec=frontcover&img=1&zoom=6&edge=curl&imgtk=AFLRE73Pui9e3ekztDhJHhw6owIELnxZ3x5nLTVJZ-x5ONU1_datRQona25Lh3HhTp7mgoQr_LQHIjjkdhQI-2jmxQVwCItUcdKflLXOgmQoKNZVs3-_AxOjrbHmjJK_TtibrDQYxSSN&source=gbs_api"
    },
    "language": "en",
    "previewLink": "http://books.google.co.kr/books?id=Bm5KDgAAQBAJ&hl=&source=gbs_api",
    "infoLink": "https://play.google.com/store/books/details?id=Bm5KDgAAQBAJ&source=gbs_api",
    "canonicalVolumeLink": "https://play.google.com/store/books/details?id=Bm5KDgAAQBAJ"
  },
  "layerInfo": {
    "layers": [
      {
        "layerId": "geo",
        "volumeAnnotationsVersion": "6"
      }
    ]
  },
  "saleInfo": {
    "country": "KR",
    "saleability": "FOR_SALE",
    "isEbook": true,
    "listPrice": {
      "amount": 10481,
      "currencyCode": "KRW"
    },
    "retailPrice": {
      "amount": 9433,
      "currencyCode": "KRW"
    },
    "buyLink": "https://play.google.com/store/books/details?id=Bm5KDgAAQBAJ&rdid=book-Bm5KDgAAQBAJ&rdot=1&source=gbs_api",
    "offers": [
      {
        "finskyOfferType": 1,
        "listPrice": {
          "amountInMicros": 10481000000,
          "currencyCode": "KRW"
        },
        "retailPrice": {
          "amountInMicros": 9433000000,
          "currencyCode": "KRW"
        }
      }
    ]
  },
  "accessInfo": {
    "country": "KR",
    "viewability": "PARTIAL",
    "embeddable": true,
    "publicDomain": false,
    "textToSpeechPermission": "ALLOWED",
    "epub": {
      "isAvailable": true,
      "acsTokenLink": "http://books.google.co.kr/books/download/Always_On-sample-epub.acsm?id=Bm5KDgAAQBAJ&format=epub&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
    },
    "pdf": {
      "isAvailable": false
    },
    "webReaderLink": "http://play.google.com/books/reader?id=Bm5KDgAAQBAJ&hl=&source=gbs_api",
    "accessViewStatus": "SAMPLE",
    "quoteSharingAllowed": false
  }
}
"""
            let jsonData = json.data(using: .utf8)!
            let model = try JSONDecoder().decode(GoogleBookSearchAPI.DetailBookResponse.self, from: jsonData)
            
            
            return .init(dto: model)
        }
        return Self(
            requestDetail: requestDetail
        )
    }()
}

# kidsnote_pre_project

## 구조
<img width="828" alt="스크린샷 2024-08-08 21 09 09" src="https://github.com/user-attachments/assets/d79dd8d6-8c07-492a-883b-d952ea5b2762">

## 일정
8/2 - 설계 및 요구사항 파악
8/3 - SearchView 구현
8/4 - SearchView, previewCell 구현 마무리 및 Dependency와 네트워크 관련 api 구현.
8/5 - SearchView API붙이기 완료 및 pagenation 구현.
8/6 - DetailView 구현
8/7 - SearchView에서 DetailView로 이동하는 구조 고민 및 구현.
8/8 - git push 및 문서정리

## 개선할 점
- ViewModel 공통 추상화
  - translate 함수, input, output typealias로 공통 프로토콜 생성.
- MassiveView 분리.
  - 섹션 별 뷰 파일 분리 및 해당 뷰에서 사용하는 데이터 정형화 후 entity에서 분리하여 의존성 떨어뜨리기.
- Animatoin
  - 앱 실행 시 서치 뷰를 탭 하면 애니메이션 되도록 구현
- 책 리뷰 관련 API
  - 현재 GoogleBookAPI에서 해당 정보를 주지 않아, 알라딘API 혹은 인터파크API로 요청하여 해당 정보를 가져오는 로직.
  - 그렇기에 DetailClient의 .testValue를 반환시키면(mock객체 반환) 리뷰UI도 확인 가능합니다.
- DetailViewModel 에러처리
  - 디테일 화면 관련 에러처리가 필요합니다. SearchView에서 사용하는것과 동일한 로직을 구현해야 합니다.
 
## 참고.
- TCA애서 사용되는 Point-free의 [Dependencies](https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/dependencymanagement/) 참고.
- 해당 방식을 최대한 비슷하게 구현하여 사용하였습니다.

## 실행영상
![ezgif-7-c6cce1f37d](https://github.com/user-attachments/assets/9e74b4c7-0d6a-49c4-9d3b-a3e59c88c8fc)

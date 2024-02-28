# 사각형 촬영 앱
---

### Table of Content

> ** 1️⃣ OverView**
>
> - 프로젝트 기간 
>
> ** 2️⃣ 프로젝트 구현**
>
> - 프로젝트 설계
> - 사용 기술/구성
> - 프로젝트 파일 구조
> - 구현 기능
> - 구현 상세


## 1️⃣ OverView

### 📍 프로젝트 기간

> 2024년 2월 1일 ~ 2023년 2월 13 [13일]

## 2️⃣ 프로젝트 구현

### 📍 프로젝트 설계

- 디자인 패턴: `MVC`

### 📍 사용 기술/구성

- Swift 기반 어플리케이션 작성
- UIKit framework
- StoryBoard UI
- CoreImage
- AVFoundation

### 📍 구현 기능

#### 로그인 화면

| 이미지 크롭 | 반시계 회전 | Repoint |
|:-------:|:-------:|:-------:|
| <img src="https://github.com/ehdwns0814/OpticalCharacterRecognitionApp/assets/97822621/e3f3e976-63c9-4eeb-ae5e-d81207536ff0" width="300px"> | <img src="https://github.com/ehdwns0814/OpticalCharacterRecognitionApp/assets/97822621/5435e669-426a-4c21-9acc-184e89ad2b53" width="300px"> | <img src="https://github.com/ehdwns0814/OpticalCharacterRecognitionApp/assets/97822621/daa1d2fb-b1b8-4a81-82c8-fab006be616f" width="300px">

#### 전체 화면


| 전체 구현화면 |
|:----------------------------------:|
| <img width="280" height="auto" alt="Screenshot1" src="https://github.com/ehdwns0814/OpticalCharacterRecognitionApp/assets/97822621/4b96dae2-5984-4746-9d2c-18bad840f6ec"> | 


### 📍 구현 상세

- UISwipeGestureRecognizer을 사용하면 촬영된 이미지 스와이프
- AVFoundation 이용하여 카메라 촬영
- CoreImage의 좌표를 UIKit의 화면에 맞게 좌표 변환
- CIDetector를 사용하여 사각형 감지
- 사진 반시계 방향 회전
- 촬영화면 이미지의 크롭 화면 수동 설정
- 촬영화면 이미지 미리보기


- **커밋 규칙**
    - ✨ **Git Commit Convention**
        - Prefix 전체 소문자, **`prefix:`**
        - `Feat` = 주로 사용자에게 새로운 기능이 추가되는 경우
        - `Fix` = 사용자가 사용하는 부분에서 bug가 수정되는 경우
        - `Docs` = 문서에 변경 사항이 있는 경우
        - `Config` = 프로젝트 초기 설정 시
        - `Style` = 세미콜론을 까먹어서 추가하는 것 같이 형식적인 부분을 다루는 경우 (코드의 변화가 생산적인 것이 아닌 경우)
        - `Refactor` = production code를 수정하는 경우 (변수의 네이밍을 수정하는 경우)
        - `Test` = 테스트 코드를 수정하거나, 추가하는 경우 (코드의 변화가 생산적인 것이 아닌 경우)
        - `Chore` = 별로 중요하지 않은 일을 수정하는 경우 (코드의 변화가 생산적인 것이 아닌 경우)
        - +) `Design` = UI 디자인을 변경했을 때

<!-- BinGo Map README -->

<div align="center">

# 🗑️ BinGo Map

### **Clean & Gourmet**

**먹고, 걷고, 깔끔하게 여행하세요.**

일본 여행 중 필요한 **쓰레기통 위치와 주변 테이크아웃 맛집을 하나의 지도 경험으로 연결하는 여행 서비스**입니다.

<br>

<img src="./src/main/resources/static/images/banner_illustration.png" alt="BinGo Map banner" width="820">

<br><br>

[![Java](https://img.shields.io/badge/Java-17-007396?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1.1-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Gradle](https://img.shields.io/badge/Gradle-Build-02303A?logo=gradle&logoColor=white)](https://gradle.org/)
[![Oracle](https://img.shields.io/badge/Oracle-Database-F80000?logo=oracle&logoColor=white)](https://www.oracle.com/database/)
[![Leaflet](https://img.shields.io/badge/Leaflet-Map-199900?logo=leaflet&logoColor=white)](https://leafletjs.com/)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-Data-7EBC6F?logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)

</div>

---

## 🌿 About BinGo Map

일본 여행에서는 길거리 음식과 테이크아웃 문화를 즐길 기회가 많지만, **음식을 먹은 뒤 가까운 쓰레기통을 찾는 일은 생각보다 쉽지 않습니다.**

BinGo Map은 이 문제를 해결하기 위해,

> **맛집을 찾고 → 이동하고 → 음식을 즐기고 → 가까운 쓰레기통을 찾는 과정**

을 하나의 흐름으로 연결합니다.

여행자가 자주 방문하는 **도톤보리 · 오사카성 · 유니버셜 스튜디오**를 기준점으로 주변 정보를 탐색하고, 실제 사용자 리뷰와 제보를 통해 여행 정보를 함께 쌓아갈 수 있도록 설계했습니다.

---

## ✨ Core Features

<div align="center">

| 🗑️ **Smart Bin Map** | 🍴 **Take-out Restaurants** |
|:---:|:---:|
| 지도에서 쓰레기통 위치 확인 | 주변 테이크아웃 맛집 탐색 |
| 카테고리별 필터링 | 평점·리뷰 기반 정보 확인 |
| 회원 제보 위치 확인 | 식당 상세 정보 제공 |

| 🧭 **Route Guidance** | 💬 **Community** |
|:---:|:---:|
| 출발지 → 맛집 경로 안내 | 리뷰 및 커뮤니티 |
| 맛집 → 쓰레기통 경로 안내 | 쓰레기통 위치 제보 |
| 도보 · 자전거 · 자동차 | 사용자 정보 공유 |

</div>

---

## 🗺️ Service Flow

```mermaid
flowchart LR
    A["📍 여행지 선택"] --> B["🍴 주변 맛집 탐색"]
    B --> C["🔎 맛집 상세 확인"]
    C --> D["🧭 길찾기"]
    D --> E["🍢 테이크아웃 & 여행"]
    E --> F["🗑️ 가까운 쓰레기통 탐색"]
    F --> G["🌿 깔끔한 여행 완료"]
    C -. "리뷰 / 즐겨찾기" .-> H["❤️ My Page"]
    F -. "새 위치 발견" .-> I["📣 쓰레기통 제보"]
    H -. "여행 정보 공유" .-> J["💬 Community"]
```

---

## 🖥️ Product Preview

### 🗺️ 지도에서 한눈에

쓰레기통 위치를 지도에 표시하고, 현재 위치 또는 주요 관광지를 기준으로 주변 시설을 탐색합니다.

<div align="center">
<img src="./src/main/resources/static/images/feature-map.png" alt="지도 기능" width="720">
</div>

### 🍴 여행지 주변 맛집

테이크아웃에 적합한 주변 맛집을 확인하고, 평점·리뷰·메뉴·영업 정보 등을 살펴볼 수 있습니다.

<div align="center">
<img src="./src/main/resources/static/images/feature-food.png" alt="맛집 기능" width="720">
</div>

### 🧭 맛집에서 쓰레기통까지

맛집을 방문한 뒤 가까운 쓰레기통까지 이어지는 이동 흐름을 지도 안에서 확인할 수 있습니다.

<div align="center">
<img src="./src/main/resources/static/images/feature-route.png" alt="길찾기 기능" width="720">
</div>

### 💬 함께 만드는 여행 정보

리뷰와 커뮤니티, 쓰레기통 제보를 통해 다음 여행자에게 필요한 정보를 함께 쌓습니다.

<div align="center">
<img src="./src/main/resources/static/images/feature-community.png" alt="커뮤니티 기능" width="720">
</div>

---

## 🏗️ System Architecture

```mermaid
flowchart TB
    U["👤 User"]
    subgraph FRONT["Frontend"]
        H["HTML / CSS"]
        JS["JavaScript"]
        MAP["Leaflet"]
    end
    subgraph BACK["Spring Boot"]
        API["REST API"]
        DOMAIN["Domain Modules"]
        AUTH["Session / User"]
        ROUTE["Routing"]
    end
    DB[("🗄️ Oracle Database")]
    OSM["OpenStreetMap / Map Data"]
    U --> H
    H --> JS
    JS --> MAP
    JS --> API
    API --> DOMAIN
    API --> AUTH
    API --> ROUTE
    DOMAIN --> DB
    AUTH --> DB
    ROUTE --> OSM
    MAP --> OSM
```

---

## 🛠️ Tech Stack

| Category | Technology | Usage |
|---|---|---|
| **Language** | Java 17 | Backend |
| **Framework** | Spring Boot 4.1.1 | Web / REST API |
| **Persistence** | Spring Data JPA | Database access |
| **Database** | Oracle Database | User / Restaurant / Review / Community data |
| **Frontend** | HTML · CSS · JavaScript | UI / Interaction |
| **Map** | Leaflet | Interactive map |
| **Map Data** | OpenStreetMap / Overpass | Location & map-related data |
| **Build** | Gradle | Dependency / build management |
| **Security** | Spring Security Crypto | Password / security-related processing |

---

## 📦 Main Modules

```text
src/main/java/com/bingomap/bingo_map
├─ common
├─ community
├─ favorite
├─ map
├─ notice
├─ notification
├─ report
├─ restaurant
├─ restaurantmap
├─ review
├─ routing
└─ user
```

프론트엔드는 기능별 화면과 모듈을 분리해 관리합니다.

```text
src/main/resources/static
├─ admin
├─ auth
├─ community
├─ favorites
├─ images
├─ login
├─ map
├─ mypage
├─ notices
├─ password-reset
├─ report
├─ restaurants
├─ reviews
└─ signup
```

---

## 🔌 주요 API

### Restaurant

`GET /api/restaurants`  
`GET /api/restaurants/{id}`  
`GET /api/restaurants/{id}/nearby`  
`GET /api/restaurants/popular`

### Map

`GET /api/bins?city=osaka`  
`GET /api/map/restaurants`  
`GET /api/reports/approved`

### User / Session

`GET /api/session`

### Favorite

`GET /api/favorites/status`  
`POST /api/favorites`  
`DELETE /api/favorites/{id}`

---

## 🗄️ Database

프로젝트 데이터는 Oracle Database를 기준으로 관리하며, 주요 도메인은 다음과 같이 구성되어 있습니다.

- 사용자 / 세션
- 맛집 / 메뉴
- 리뷰 / 리뷰 추천
- 즐겨찾기
- 커뮤니티 / 댓글
- 쓰레기통 / 회원 제보
- 알림 / 신고 / 관리자 기능

ERD와 팀 공통 SQL은 [`DB/`](./DB) 디렉터리와 [`document/`](./document) 디렉터리에서 확인할 수 있습니다.

---

## 🚀 Getting Started

### Requirements

- Java 17
- Oracle Database
- Gradle

### Run

```bash
./gradlew bootRun
```

Windows:

```bash
gradlew.bat bootRun
```

DB 접속 정보와 실행 환경은 프로젝트 설정에 맞게 구성해야 합니다.

---

## 📚 Documentation

프로젝트 설계와 개발 관련 자료는 다음 위치에 정리되어 있습니다.

- [`document/프로젝트 작업 사양서 & 설계서.txt`](./document/프로젝트%20작업%20사양서%20%26%20설계서.txt)
- [`document/BinGoMap_개발프로세스_학습가이드 (1).md`](./document/BinGoMap_개발프로세스_학습가이드%20%281%29.md)
- [`document/AI_REBUILD_NOTES.md`](./document/AI_REBUILD_NOTES.md)

---

## 👥 Team

BinGo Map은 **지도 · 맛집 · 리뷰 · 커뮤니티 · 회원 기능을 하나의 서비스로 통합하는 팀 프로젝트**입니다.

GitHub에서 각자의 브랜치와 커밋을 통해 기능을 분리 개발하고, Pull Request를 통해 기능을 통합하는 방식으로 협업하고 있습니다.

> 팀원별 역할과 GitHub 계정은 프로젝트 종료 시 최종 정리 예정입니다.

---

## 🧹 Project Message

<div align="center">

### **Clean Trip, Better Taste.**

**여행은 즐겁게, 길은 편하게, 마무리는 깔끔하게.**

<br>

🗺️ &nbsp; 🍴 &nbsp; 🧭 &nbsp; 🗑️ &nbsp; 💬

<br>

`BinGo Map · Clean & Gourmet`

</div>
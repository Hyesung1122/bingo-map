\# \[Bingo-map] 프로젝트 개발일지

박주호
지도 기능 담당
쓰레기통 & 지도 api 연동해서 기능개발하기



\### ■ TIP:

작업물 확인 방법:

src>main>java>service>BingoMapApplication.java 에서 RUN

> localhost8080 주소창에 치고 접속



AI와 함께 개발을 하는 방법:

Claude, GPT, gemini를 사용한다.



Claude - 코드 설계, 실질적인 프로그래밍 담당.

//zip 파일 형태로 줘도 분석이 가능함.

클로드에게 프로젝트를 알집 형태로 만든다음 분석해달라고 요청한다.

이후 본인이 담당하는 개발 파트를 클로드와 함께 만들어 나간다.

개발일지를 꼭 쓰면서, 뭐라고 넣었고 뭐라고 나왔는지 기록한다.



GPT - 프론트엔드(화면), 이미지 생성등 활용



gemini - 연습장. 편하게, 대화체로 물어보고 깔끔하게 정리함.

이후, 정리한 요청을 GPT, Claude한테 줘서 결과물을 생성한다.



이렇게 하는 이유:

gemini는 사용량 제한이 없다.

하지만 GPT, Claude는 제한이 있다.

따라서 확신을 가지고 "결과물"을 만들때만 GPT, Claude를 사용하는게 좋다.



\## 09.10 
도톤보리 지역의 쓰레기통 위치를 테스트로 가져왔다.
1. 도톤보리의 실제 배경 지도가 보이도록 수정
2. 이미지를 불러오는 코드를 지도 타일 코드로 변경
3. 4개의 쓰레기통 조회완료 
4. 더 많은 쓰레기통 조회를 위해서 약 3.3km × 3.2km범위로 넓힘
5. 테스트로 도톤보리 주변 쓰레기통 조회완료


\### ■ 과제

뼈대 만들기:

주변맛집

즐겨찾기

리뷰

공지사항 페이지들 만들기



\### ■ 문제점

map의 html, css가 생각한 이미지와 다르다.

DO:

GPT랑 같이 map.css, map.html을 다시 만들었다.

> 맵 자체를 png로 만들어야 한다고 함.

>> 쓰레기통 참조 api에서 좀더 많은 정보를 가져와야 할까?

* 내 생각에는, 아이콘/영역/쓰레기통/등등 아이콘을 만들어놓고
* 지도를 그릴때마다 맞춰서 저장해둔 이미지로 그리는 식으로 해야할 것 같다.



\### ■ 공통 개발환경



\* IDE: IntelliJ IDEA 2026.1.4

\* OS: Windows

\* Java: 17.0.19

\* Spring Boot: 4.1.1

\* Build: Gradle

\* DB: Oracle Database 11g

\* Oracle Version: 11.2.0.1.0 (64-bit)

\* 연수원 교육환경과 동일한 DB 환경으로 통일



\### ■ GitHub



\* BinGo Map 대표 아이콘 변경 완료

\* GitHub Organization 생성 완료

\* 팀 프로젝트 Repository 생성 완료



\### ■ Spring Boot 프로젝트 환경 구축



\* Spring Boot 프로젝트 생성 및 기본 구조 설정 완료

\* Java 17 개발환경 설정 완료

\* Gradle 기반 프로젝트 구성 완료

\* Oracle JDBC 드라이버 설정 완료

\* `application.yml`에 Oracle DB 연결 정보 설정 완료

\* Spring Data JPA 기본 설정 완료

\* Spring Boot 실행 및 Oracle Database 연결 확인 완료

\* HikariCP 정상 작동 확인

\* Hibernate 정상 초기화 확인

\* Oracle Database 연결 정상 확인

\* 서버 `8080` 포트 정상 실행 확인



\### ■ 메인페이지 구현



\* BinGo Map 메인페이지 HTML/CSS 구현 완료

\* `src/main/resources/static/index.html` 구성

\* 메인페이지 디자인 및 레이아웃 구현 완료

\* Header / Hero 영역 구현

\* 주요 기능 영역 구현

\* 인기 테이크아웃 맛집 영역 구현

\* 이용 방법 영역 구현

\* Footer 구현

\* 메인페이지 이미지 리소스 구성 완료

\* `http://localhost:8080/` 접속 및 정상 출력 확인



\### ■ 지도 페이지 구현



\* 지도 페이지 기본 구조 구현

\* `src/main/resources/static/map/map.html` 생성

\* `src/main/resources/static/map/map.css` 생성

\* 메인페이지의 지도 메뉴와 지도 페이지 연결 준비

\* 오사카 도톤보리 지역을 지도 중심 지역으로 설정

\* 지도 중심 좌표 설정



&#x20; \* Latitude: `34.6687`

&#x20; \* Longitude: `135.5013`

\* Leaflet 기반 지도 구현

\* OpenStreetMap 지도 타일 연동

\* 지도 확대/축소 기능 구현

\* 현재 위치 버튼 구현

\* 좌측 검색 및 필터 UI 구현

\* 쓰레기통 목록 UI 구현

\* 지도 마커 및 마커 팝업 UI 구현



\### ■ 지도 URL 및 Controller



\* `/map` 경로로 지도 페이지에 접근하는 방식으로 변경

\* `MapController`를 통해 `/map` 요청 처리 예정

\* `/map` → `map/map.html` 연결 구조로 구성

\* `map.html`을 직접 입력하지 않고 `http://localhost:8080/map`으로 접근하는 구조로 변경



\### ■ OpenStreetMap / 쓰레기통 데이터 조사



\* 일본 정부 공공데이터 API가 아닌 \*\*OpenStreetMap 데이터 기반 방식\*\*으로 결정

\* OpenStreetMap의 \*\*Overpass API\*\*를 이용해 쓰레기통 위치 데이터 조회 예정

\* Overpass API Endpoint 확인

\* `amenity=waste\_basket` 태그를 여행자용 쓰레기통 데이터의 핵심 조건으로 선정

\* `amenity=recycling`은 재활용 시설 데이터이므로 별도 분류 대상으로 검토

\* Overpass Turbo를 이용하여 실제 OSM 쓰레기통 데이터가 존재하는지 확인하는 방식 검토 완료



\### ■ 지도 데이터 처리 방향



최종적으로 다음 구조로 개발하기로 결정:



```text

OpenStreetMap

&#x20;     ↓

Overpass API

&#x20;     ↓

Spring Boot

&#x20;     ↓

/api/bins

&#x20;     ↓

map.html

&#x20;     ↓

지도 위 실제 쓰레기통 마커

```



\* 지도 이미지를 직접 만들어서 사용하는 방식이 아니라 \*\*실제 지도 데이터를 받아서 표시하는 방식\*\*으로 결정

\* 지도 배경은 OpenStreetMap을 사용

\* 쓰레기통 위치는 Overpass API에서 실제 좌표 데이터를 받아 마커로 표시

\* 지도 UI는 BinGo Map에서 직접 HTML/CSS로 구현

\* 오사카 도톤보리 주변을 우선 테스트 지역으로 설정



\### ■ 현재 프로젝트 구조



```text

src

└── main

&#x20;   ├── java

&#x20;   │   └── com.bingomap.bingo\_map

&#x20;   │       └── BingoMapApplication.java

&#x20;   │

&#x20;   └── resources

&#x20;       ├── static

&#x20;       │   ├── css

&#x20;       │   │   └── main.css

&#x20;       │   │

&#x20;       │   ├── images

&#x20;       │   │   ├── feature-community.png

&#x20;       │   │   ├── feature-food.png

&#x20;       │   │   ├── feature-map.png

&#x20;       │   │   ├── feature-route.png

&#x20;       │   │   ├── food-karaage.png

&#x20;       │   │   ├── food-okonomiyaki.png

&#x20;       │   │   ├── food-taiyaki.png

&#x20;       │   │   ├── food-takoyaki.png

&#x20;       │   │   ├── food-yakisoba.png

&#x20;       │   │   └── hero-right.png

&#x20;       │   │

&#x20;       │   ├── map

&#x20;       │   │   ├── map.html

&#x20;       │   │   └── map.css

&#x20;       │   │

&#x20;       │   └── index.html

&#x20;       │

&#x20;       └── application.yml

```



\### ■ 다음 개발 예정



\* `/map` Controller 구현 및 정상 연결 확인

\* `/api/bins` API 구현

\* Overpass API 연동

\* 오사카 도톤보리 주변 `amenity=waste\_basket` 실제 데이터 조회

\* 조회한 쓰레기통 좌표를 JSON으로 반환

\* `map.html`에서 `/api/bins` 호출

\* 실제 쓰레기통 위치를 지도 위 마커로 표시

\* 마커 클릭 시 쓰레기통 정보 표시

\* 검색/필터 기능과 실제 데이터 연결

\* 지도 UI를 참고 이미지처럼 단순하고 깔끔한 형태로 조정

\* 메인페이지 → `/map` 이동 정상 작동 확인

\* 이후 Oracle DB 저장 구조 및 JPA 연동 검토



\### ■ 현재 핵심 목표



\*\*오사카 도톤보리의 실제 지도 위에 Overpass API에서 받아온 실제 쓰레기통 위치 데이터를 BinGo Map 자체 UI로 표시하는 것.\*\*




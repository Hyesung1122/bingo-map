# BinGo Map 식당 DB — SQL 2개로 적용하기

기존 17개 파일을 **SQL 2개 + 이 안내서 1개**로 합친 간단 버전입니다.
이번 ZIP만 사용하면 됩니다. 이전 묶음을 먼저 실행하거나 나중에 다시 실행할 필요는 없습니다.
집 Oracle 11g XE와 학원 Oracle 11g에서 같은 SQL을 사용하고, 연결 대상만 각각 선택합니다.

| 파일 | 역할 | 데이터 변경 |
| --- | --- | --- |
| `01_setup.sql` | 접속 확인 + 테이블 준비 + 문자열 길이 확장 + 결과 확인 | 구조 보완. 기존 식당 행/ID 보존 |
| `02_publication.sql` | 공개 예정 목록 + 선택적 적용 + 공개 결과 확인 | PREVIEW는 조회만, APPLY는 공개 Y/N 변경 |
| `README.md` | 순서, 검색/정보/사진 수정 예시, Java 연결 안내 | 설명 파일 |

## 학원에 이미 오사카 식당을 받아뒀다면

1. SQL Developer에서 **학원 프로젝트가 사용하는 DB 계정**에 접속합니다. 집의 XE 접속을 그대로 고르는 것이 아닙니다.
2. 웹 앱과 Loader를 중지하고 다른 미완료 SQL 작업을 저장하거나 취소합니다.
3. `01_setup.sql`을 UTF-8로 열어 **파일 전체 F5**로 실행합니다.
4. ORA- 오류 없이 `SETUP_OK`가 출력되고 `ROWS_BEFORE`와 `ROWS_AFTER`가 같은지 확인합니다.
5. `OSM_ROWS`가 기존 수집 건수를 보여주면 **RestaurantDbLoader 재실행을 건너뜁니다.**
6. `02_publication.sql`을 그대로 전체 F5로 실행합니다. 기본값 PREVIEW여서 공개값은 바뀌지 않습니다.
7. 첫 요약의 `PLANNED_PUBLIC`, `TO_PUBLISH`, `TO_HIDE`와 예정 목록을 확인합니다.
8. 그 목록을 적용할 때만 파일 상단의 한 줄을 아래처럼 바꿉니다.

```sql
-- 처음에는 이 상태: 조회만
DEFINE BINGO_RESTAURANT_MODE = PREVIEW

-- 적용할 때 그 한 줄을 이렇게 변경
DEFINE BINGO_RESTAURANT_MODE = APPLY
```

위 두 줄을 함께 넣는 것이 아닙니다. 원래 있는 DEFINE 한 줄의 마지막 단어만 바꿉니다.

9. SQL Developer 자동 커밋을 끄고, `02_publication.sql` 파일 전체를 다시 F5로 실행합니다.
10. ORA- 오류 없이 `CHANGED_ROWS`가 나오고, 마지막 요약의 `TO_PUBLISH=0`, `TO_HIDE=0`인지 확인합니다.
11. 결과가 맞으면 **같은 접속에서** 다음 한 문장만 실행합니다.

```sql
COMMIT;
```

잘못됐다면 COMMIT 전 같은 접속에서 `ROLLBACK;`을 실행합니다.
02는 구조 변경이나 자동 COMMIT을 하지 않습니다. 02 작업을 저장/취소하기 전에 01을 다시 실행하지 마세요.
12. 나중에도 미리보기부터 시작하도록 02 파일을 PREVIEW로 되돌려 저장합니다.
13. Java의 공개 조회 조건을 아래 안내와 비교하고 `BingoMapApplication`으로 웹 서버를 실행합니다.
14. `/api/map/restaurants`와 지도 페이지를 확인합니다.

## 기존 데이터가 있을 때 무엇이 유지되나요?

- `01`은 기존 식당의 ID, OSM_ID, 메뉴, 사진, 가격 등 행 내용을 삭제하거나 다시 입력하지 않습니다.
- 기존 `IS_PUBLISHED` 컬럼이 있으면 Y/N도 유지합니다.
- **그 컬럼이 처음 생기는 DB는 기존 행도 N으로 시작합니다.** 이후 02로 공개 대상을 정합니다.
- 기존 시퀀스는 재생성/초기화하지 않습니다. 시퀀스가 없을 때만 최대 식당 ID 다음에서 만듭니다.
- `02`의 PREVIEW는 기존 공개 상태를 유지합니다.
- `02`의 APPLY는 선별 범위 안의 상태를 새 기준에 맞추므로 **기존 Y도 N으로 바뀔 수 있습니다.** 행 삭제가 아닙니다.
- 이미 공개하던 명단을 그대로 유지하려면 PREVIEW까지만 실행합니다.

`01`은 기존 팀 RESTAURANT 구조를 기준으로 검사합니다. 컬럼 누락, 다른 자료형, 중복 OSM_ID,
잘못된 공개값 등 차이가 있으면 자동 삭제로 해결하지 않고 오류를 냅니다.
학원 DB의 현재 구조를 직접 확인한 것은 아니므로 모든 환경에서 오류가 없다고 보장할 수는 없습니다.
`01`의 CREATE/ALTER는 자동 커밋되며 전체 작업이 하나의 ROLLBACK으로 복구되는 것은 아닙니다.
오류가 있으면 다음 단계로 넘어가지 말고 해당 오류부터 확인합니다.

## 식당 테이블이나 후보가 전혀 없는 새 DB라면

01이 빈 RESTAURANT와 시퀀스를 준비합니다. 식당 데이터를 자동 생성하지는 않습니다.
아래 Java 변경을 확인한 뒤 학원은 RestaurantDbLoader, 집은 RestaurantDbLoaderHOME을 한 번 실행합니다.
수집 완료와 BUILD SUCCESSFUL을 확인한 다음 02를 PREVIEW -> APPLY -> COMMIT 순서로 적용합니다.
회원·쓰레기통·리뷰·별도 메뉴 테이블은 팀 공통 프로젝트의 설치 파일을 유지합니다.

## 평소 식당 검색·정보 수정

SQL Developer의 새 워크시트에서 실행합니다. 원본 테이블 생성 파일을 수정하여 재실행하는 작업이 아닙니다.

```sql
SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANT
WHERE UPPER(NAME) LIKE '%PABLO%'
ORDER BY RESTAURANT_ID;
```

아래는 설명용 예시입니다. `123`, 이름과 각 항목을 실제 확인한 값으로 바꾸고 모르는 SET 항목은 뺍니다.
같은 이름의 다른 지점과 혼동하지 않도록 주소/좌표까지 확인합니다.
WHERE는 반드시 유지하고, 1행 수정과 결과 확인 후 같은 접속에서 COMMIT합니다.

```sql
SET DEFINE OFF
UPDATE RESTAURANT
SET DESCRIPTION      = '확인한 실제 소개',
    ADDRESS          = '확인한 실제 주소',
    OPENING_HOURS    = '확인한 실제 영업시간',
    MENU_NAME        = '확인한 실제 대표 메뉴',
    MENU_DESCRIPTION = '확인한 실제 메뉴 설명',
    MENU_PRICE       = '확인한 실제 가격',
    MAIN_IMAGE_URL   = '/images/restaurants/shop-main.jpg',
    UPDATED_AT       = SYSTIMESTAMP
WHERE RESTAURANT_ID = 123
  AND NAME = '검색 결과에서 확인한 실제 이름';

SELECT * FROM RESTAURANT WHERE RESTAURANT_ID = 123;
-- 확인 후 별도로 COMMIT; 또는 ROLLBACK;
SET DEFINE ON
```

PHONE, WEBSITE_URL, PRICE_RANGE 등도 같은 방식으로 SET에 추가할 수 있습니다.
내용에 작은따옴표가 있으면 두 번 씁니다. 예: `'Bob''s Cafe'`.
정보 보강 뒤 공개 대상도 다시 맞추려면 02를 다시 PREVIEW -> APPLY -> COMMIT합니다.
DB 값만 수정했다면 COMMIT 후 지도 새로고침으로 확인하며 Loader는 다시 실행하지 않습니다.

특정 한 곳을 직접 공개하려면 실제 ID 확인 후 아래와 같이 실행할 수 있습니다.

```sql
UPDATE RESTAURANT
SET IS_PUBLISHED = 'Y', UPDATED_AT = SYSTIMESTAMP
WHERE RESTAURANT_ID = 123;
-- 조회로 확인한 다음 별도 COMMIT;
```

비공개는 Y 대신 N입니다. 이는 영구 고정/제외 설정이 아니며 다음 02 APPLY에서 다시 평가됩니다.

## 대표 사진

1. 사용할 실제 사진을 준비합니다.
2. IntelliJ에서 `src/main/resources/static/images` 안에 `restaurants` 폴더를 만듭니다.
3. 사진을 `shop-main.jpg` 같은 영문 파일명으로 넣습니다.
4. `RESTAURANT.MAIN_IMAGE_URL`에 `/images/restaurants/shop-main.jpg`를 저장합니다.
5. 새 파일을 빌드/실행에 반영하기 위해 `BingoMapApplication`을 재실행합니다.
6. `http://localhost:8080/images/restaurants/shop-main.jpg`에서 사진이 열리는지 확인합니다.
7. 지도 페이지를 새로고침합니다. 사진 URL이 맞아도 공개값이 N이면 식당은 지도에 안 나옵니다.

DB에 `C:\...` 같은 PC 경로나 `src/main/resources/static`을 포함한 경로를 저장하지 않습니다.
이전에 올린 지도 JS는 `/images/` 아래의 영문·숫자·밑줄·하이픈·하위 폴더 경로만 허용합니다.
확장자는 jpg/jpeg/png/webp를 사용합니다. 공백·한글 파일명·외부 사이트 URL·/uploads 경로는 그 코드에서 표시하지 않습니다.
사진을 같은 이름으로 바꿨는데 이전 이미지가 보이면 Ctrl+F5로 새로고침합니다.
이 ZIP에는 실제 가게 사진이 들어 있지 않습니다. SQL은 사진의 경로만 저장합니다.

## 대표 메뉴와 여러 메뉴의 차이

| 내용 | 현재 저장 위치 | 현재 코드의 동작 |
| --- | --- | --- |
| 대표 메뉴명·설명·가격 | RESTAURANT.MENU_NAME / MENU_DESCRIPTION / MENU_PRICE | 지도 팝업에서 표시 |
| 대표 사진 | RESTAURANT.MAIN_IMAGE_URL | 지도 사진에서 사용 |
| 대표 메뉴 사진 경로 | RESTAURANT.MENU_IMAGE_URL | 컬럼은 있지만 확인한 지도 JS에는 이미지 표시 코드가 없음 |
| 여러 메뉴 목록 | TB_RESTAURANT_MENU | 별도 메뉴 API에서 조회 |

RESTAURANT 대표 메뉴를 바꿔도 TB_RESTAURANT_MENU에 자동 복사되지 않습니다.
이 묶음은 별도 메뉴 테이블을 새로 만들거나 팀원 메뉴 관리 기능을 교체하지 않습니다.
여러 장의 사진이나 메뉴별 사진 표시는 최신 팀 화면 코드와 맞춘 별도 작업이 필요합니다.


## 친구와 학원에 전달할 것

- 기본은 이번 ZIP 하나입니다. SQL Developer로 실행하며 IntelliJ src에 통째로 붙여 넣지 않습니다.
- 실제로 보강한 UPDATE SQL과 사진은 별도로 전달합니다. 이 ZIP에는 집 Oracle 데이터 덤프나 실제 사진이 없습니다.
- 집/학원/친구 DB의 RESTAURANT_ID는 다를 수 있습니다. OSM_ID와 이름/주소를 확인해 해당 DB의 대상을 잡습니다.
- OSM_ID가 있는 같은 가게라면 확인 후 `WHERE OSM_ID = 실제OSM번호`로 수정 대상을 맞출 수 있습니다.
- 수기 가게의 OSM_ID는 NULL일 수 있으므로 상대 DB에서 이름/주소와 현지 ID를 확인합니다.
- Java 소스 변경은 feature 브랜치로 함께 전달합니다. SQL을 실행해도 Java 파일은 자동으로 바뀌지 않습니다.
- 집과 완전히 동일한 실제 데이터를 복사하려면 별도 DB 내보내기가 필요합니다.
  이미 데이터가 있는 팀 DB에 ID가 다른 INSERT를 무작정 실행하지 않습니다.

## Java 연결에서 확인할 부분

### Loader 저장 SQL

대상: `src/main/java/com/bingomap/bingo_map/restaurant/RestaurantDbLoaderHOME.java`와 학원용 `RestaurantDbLoader.java`.
Ctrl+F로 `String insertSql`을 찾아 해당 텍스트 블록만 아래로 맞춥니다. 이미 같다면 유지합니다.

```java
String insertSql = """
                    INSERT INTO RESTAURANT (
                        RESTAURANT_ID, OSM_ID, NAME, CATEGORY, TAGS,
                        ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, WEBSITE_URL,
                        IS_PUBLISHED, CREATED_AT, UPDATED_AT
                    )
                    SELECT SEQ_RESTAURANT.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                           'N', SYSTIMESTAMP, SYSTIMESTAMP
                    FROM DUAL
                    WHERE NOT EXISTS (
                        SELECT 1 FROM RESTAURANT WHERE OSM_ID = ?
                    )
                    """;

```

기존 ps 바인딩 1~11은 그대로입니다. 신규 후보는 N, 기존 OSM_ID는 건너뛰므로 이미 보강한 정보를 덮어쓰지 않습니다.
이는 오래된 OSM 정보 갱신 기능은 아닙니다. 집/학원 각각의 DB 접속 설정을 유지하세요.

### CATEGORY 정리

각 Loader의 기존 mapCategory를 아래로 맞추고, 기존 CUISINE_MAP과 TAGS 원본 저장은 유지합니다.

```java
private static String mapCategory(String cuisineRaw) {
    if (cuisineRaw == null || cuisineRaw.isBlank()) return "기타";
    String first = cuisineRaw.split(";", 2)[0]
            .trim().toLowerCase(java.util.Locale.ROOT);
    return CUISINE_MAP.getOrDefault(first, "기타");
}
```

### 지도 공개 필터

`src/main/java/com/bingomap/bingo_map/restaurantmap/RestaurantMapRepository.java`의 SQL 끝부분:

```sql
FROM RESTAURANT
WHERE IS_PUBLISHED = 'Y'
ORDER BY RESTAURANT_ID
```

이미 WHERE가 있으면 AND로 연결하고 OR는 괄호로 묶습니다. SELECT 컬럼/DTO는 유지합니다.
SQL Developer에서 별도로 저장하는 설정이 아니라 Java의 SQL 문자열입니다.
JDK 17 / 모듈 bingo-map.main을 사용하며 서버는 BingoMapApplication으로 실행합니다.
수집 Loader는 각 파일이 상수/환경 변수 중 무엇을 읽는지에 따라 접속하므로,
일반 main() JDBC 코드가 application.yaml을 자동으로 읽는다고 가정하지 않습니다.

## 공개 기준과 제한

- 기본정보형: 이름 + 좌표 범위 + 주소 + 영업시간.
- 상세정보형: 위 기본정보 + 기타가 아닌 분류 + 소개 + 메뉴명 + 숫자가 포함된 메뉴가격 + 대표사진 또는 메뉴사진 경로.
- 상세정보형 전부를 우선 공개하고 기본정보형으로 약 50곳까지 보충합니다.
- 상세정보형 60곳이면 60곳, 조건을 갖춘 후보 17곳뿐이면 17곳입니다.
- 기본정보형의 추가 점수: 전화/웹사이트 각 2, 분류/소개/메뉴/가격/대표사진/메뉴사진 각 1. 동점은 ID 순서입니다.
- 값이 채워져 있는지를 검사하며 실제 영업/가격/테이크아웃 가능 여부나 사진 응답을 검증하지 않습니다.
- 알려진 placeholder 이미지, '주소 정보 없음' 등의 값은 해당 정보로 인정하지 않습니다.
- 메뉴사진 경로가 있어 선별 기준을 통과해도 현재 지도에 그 사진 표시 코드가 없는 점은 위 설명과 같습니다.
- 위도 34.55~34.82 / 경도 135.35~135.65의 범위는 정확한 오사카시 경계가 아닙니다.
  현재 Loader가 오사카시에서 수집했다는 전제로 다른 도시/엉뚱한 좌표를 거르는 범위입니다.
- 범위 밖의 기존 Y는 바꾸지 않으므로 ALL_PUBLIC_ROWS는 50과 다를 수 있습니다.
- 카페의 테이크아웃 태그 누락, 일부 주소 태그만 추출하는 Loader 특성 때문에 별도 확인/보강이 필요할 수 있습니다.
- OSM_ID 중복은 건너뛰지만 OSM과 수기 행이 같은 실제 가게인지를 자동 병합하지 않습니다.
- 이미 있는 시퀀스가 실제 최대 ID보다 뒤처져 있으면 별도 점검이 필요하며 초기화로 해결하지 않습니다.
- Oracle 11g VARCHAR2는 CHAR 선언이어도 실제 값에 4000바이트 한계가 있습니다.

## 부록: 친구 담당 맛집 화면의 공개 조건

지도의 RestaurantMapRepository는 JDBC SQL이고, 주변 맛집 쪽은 별도의 JPA Repository를 사용합니다.
지도에만 WHERE를 추가하면 `/api/restaurants`나 `/restaurants`에는 후보가 계속 나올 수 있습니다.

아래는 09/20에 전달한 프로젝트를 기준으로 한 수정입니다.
오늘 팀원이 이미 같은 처리를 했다면 기존 필터를 유지하고 중복 추가하지 마세요.
DB에 `IS_PUBLISHED` 컬럼을 먼저 준비한 다음 Java를 바꿉니다.
현재 작업은 DB SQL로 공개 상태를 바꾸므로 Entity에 공개 여부 필드를 새로 추가하지 않아도 됩니다.
나중에 Java 관리 화면에서 공개 상태를 편집하려면 그때 Entity 필드와 관리 기능을 추가합니다.

### 1. RestaurantRepository.java

경로: `src/main/java/com/bingomap/bingo_map/restaurant/RestaurantRepository.java`

기존 메서드가 더 있다면 유지하고, 아래 import와 메서드 2개만 추가합니다.
`findAllPublished`는 이름만으로 추론하는 메서드가 아니라 @Query에 적은 실제 SQL을 실행합니다.

```java
package com.bingomap.bingo_map.restaurant;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {

    @Query(value = """
            SELECT * FROM RESTAURANT
            WHERE IS_PUBLISHED = 'Y'
            ORDER BY RESTAURANT_ID
            """, nativeQuery = true)
    List<Restaurant> findAllPublished();

    @Query(value = """
            SELECT * FROM RESTAURANT
            WHERE RESTAURANT_ID = :id AND IS_PUBLISHED = 'Y'
            """, nativeQuery = true)
    Optional<Restaurant> findPublishedById(@Param("id") Long id);
}
```

### 2. RestaurantService.java

경로: `src/main/java/com/bingomap/bingo_map/restaurant/RestaurantService.java`

import 추가:

```java
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
```

`findAll()` 안의 조회 한 줄만 변경합니다.

```java
// 기존
List<Restaurant> restaurantList = restaurantRepository.findAll();

// 수정
List<Restaurant> restaurantList = restaurantRepository.findAllPublished();
```

기존 `findById(Long id)` 메서드 전체를 아래로 교체합니다. toDto 등 다른 메서드는 유지합니다.

```java
public RestaurantDto findById(Long id) {
    if (id == null) {
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "공개된 식당을 찾을 수 없습니다.");
    }

    Restaurant restaurant = restaurantRepository.findPublishedById(id)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "공개된 식당을 찾을 수 없습니다."));

    return toDto(restaurant);
}
```

예전 코드의 '못 찾으면 첫 식당을 보여 주기'를 없앱니다.
비공개/존재하지 않는 식당 ID로 접근하면 404가 됩니다. 기존 공개 식당 ID와 DTO 변환은 유지합니다.

### 3. RestaurantApiController.java

경로: `src/main/java/com/bingomap/bingo_map/restaurant/RestaurantApiController.java`

import 추가:

```java
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
```

기존 클래스 안의 다음 3개 메서드를 아래처럼 바꿉니다. 클래스 선언/생성자/필드는 유지합니다.

```java
@GetMapping
public List<RestaurantDto> getRestaurants() {
    return restaurantRepository.findAllPublished().stream()
            .map(RestaurantDto::new)
            .toList();
}

@GetMapping("/{id:\\d+}")
public RestaurantDto getRestaurant(@PathVariable Long id) {
    return restaurantRepository.findPublishedById(id)
            .map(RestaurantDto::new)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "공개된 식당을 찾을 수 없습니다."));
}

@GetMapping("/{id:\\d+}/menu")
public List<MenuItemDto> getMenu(@PathVariable Long id) {
    restaurantRepository.findPublishedById(id)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "공개된 식당을 찾을 수 없습니다."));

    return menuItemRepository.findByRestaurantIdOrderByMenuIdAsc(id).stream()
            .map(MenuItemDto::new)
            .toList();
}
```

Java 소스의 경로 정규식에는 위 코드처럼 `\\d+`로 백슬래시 2개를 씁니다.
메뉴 테이블에는 그대로 두되, 공개 식당인지 먼저 확인한 뒤 메뉴를 읽습니다.
공개 식당이라도 별도 메뉴 테이블에 데이터가 없으면 빈 메뉴 목록이 나옵니다.
팀원 SQL의 MENU_NAME/MENU_PRICE는 RESTAURANT의 대표 메뉴 컬럼이며, 별도 메뉴 테이블을 자동으로 채우지 않습니다.

### 확인

1. 공개 식당: 지도/주변 맛집 목록/상세에서 확인 가능.
2. 비공개 식당: 두 목록에 없고, 직접 상세/메뉴 API로 요청해도 404.
3. 웹 페이지를 다시 열거나 새로고침해 확인. 이미 브라우저에 받아 둔 자료는 자동 회수되지 않습니다.
4. 최신 팀 프로젝트에 식당 검색·추천 등 다른 공개 조회 API가 추가됐다면 그 조회에도 같은 조건이 필요합니다.


## 검증 범위

공개 선별 SELECT/MERGE와 Loader의 SQL은 이전 통합본과 같은 로직입니다.
검사 결과는 이 안내서의 마지막에 기록합니다.
Oracle 11g/XE의 사용자 DB에 직접 접속한 검증은 아니며 실제 적용 시 SETUP_OK와 오류 유무를 확인해야 합니다.
준비·확장을 하나의 PL/SQL 블록으로 묶어 앞 단계 오류 후 다음 변경이 계속 실행되지 않게 했습니다.
02의 기본 PREVIEW에서는 변경 MERGE가 실행되지 않도록 조건을 두었습니다.
SELECT/MERGE 검사만으로 Oracle PL/SQL, 문자셋, SQL Developer 환경까지 보장할 수는 없습니다.
이전 팀 프로젝트 이후의 최신 Java 전체는 확인하지 않았으므로 부록 코드는 필요한 부분만 비교 적용하세요.

참고 문서:
- https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_3001.htm
- https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_9016.htm
- https://docs.oracle.com/cd/E11882_01/server.112/e16604/ch_twelve017.htm

이번 간단 버전 검사 결과(2026-09-23):
- 새 파일에서 추출한 테이블 정의·수집 INSERT·공개 SELECT/MERGE로 H2 Oracle 모드 검사 45개 통과.
- 기존 17개 묶음과 핵심 SQL 동작이 같은지 비교 완료.
- 02 기본값 PREVIEW, APPLY 분기 내부에만 MERGE가 있는지 확인.
- 01의 준비와 길이 확장은 하나의 PL/SQL 블록이며 성공 메시지는 맨 마지막에 출력.
- 실제 Oracle의 PL/SQL/DDL 및 SQL Developer 실행 검증은 미실시.
- H2 검사에서는 CHAR/BYTE 표기를 제거했으므로 Oracle 바이트 한계 검증이 아님.

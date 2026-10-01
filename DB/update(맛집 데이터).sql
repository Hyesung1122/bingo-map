-- ============================================================
-- BinGo Map RESTAURANTS 전체 50개 식당 통합 UPDATE SQL (최종본)
-- ============================================================

SET DEFINE OFF;

-- ============================================================
-- 1. 카페 / 디저트 (19개 매장)
-- ============================================================

-- 1. 파블로
UPDATE RESTAURANTS
SET
    NAME = '파블로',
    CATEGORY = '카페 / 디저트',
    TAGS = '치즈타르트,파블로,신사이바시디저트,오사카디저트,베이커리',
    DESCRIPTION = '부드럽고 사르르 녹는 식감으로 사랑받는 갓 구운 치즈타르트 전문점',
    ADDRESS = '1F, Shinsaibashi Zero One Bldg, 2 Chome-8-1 Shinsaibashisuji, Chuo Ward, Osaka, 542-0085',
    LATITUDE = 34.6704125,
    LONGITUDE = 135.501534,
    OPENING_HOURS = '10:00 - 21:00',
    PHONE = '+81 6-6211-8260',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'https://www.pablo3.com/shop/shinsaibashi',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 불가',
    RESERVATION_INFO = '예약 불가',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/Pablo shop.jpg',
    MENU_NAME = '갓 구운 파블로 치즈타르트',
    MENU_DESCRIPTION = '바삭한 타르트 쉘에 진한 치즈 필링과 상큼한 살구잼을 더한 대표 치즈타르트',
    MENU_PRICE = '¥980',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/Pablo menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 4853437322;

-- 2. 감메드 카페
UPDATE RESTAURANTS
SET
    NAME = '감메드 카페',
    CATEGORY = '카페 / 디저트',
    TAGS = '24시간카페,심야영업,신사이바시카페,커피,디저트',
    DESCRIPTION = '신사이바시 중심가에서 24시간 언제든 커피와 디저트를 즐길 수 있는 편안한 분위기의 카페',
    ADDRESS = '1F, 2 Chome-2-8 Higashishinsaibashi, Chuo Ward, Osaka, 542-0083',
    LATITUDE = 34.6704381,
    LONGITUDE = 135.5035624,
    OPENING_HOURS = '00:00 - 24:00 (24시간 영업)',
    PHONE = '+81 6-4708-6883',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '매장 내 식사, 테이크아웃, 배달 서비스 가능',
    RESERVATION_INFO = '예약 문의 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/ギャムドカフェcafe.jpg',
    MENU_NAME = '오므라이스 비프 카레',
    MENU_DESCRIPTION = '부드러운 계란 오므라이스에 진한 풍미의 특제 비프 카레 루를 듬뿍 올린 요리',
    MENU_PRICE = '¥650',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/ギャムドカフェcafe menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 8524899092;

-- 3. 포켓몬 카페
UPDATE RESTAURANTS
SET
    NAME = '포켓몬 카페',
    CATEGORY = '카페 / 디저트',
    TAGS = '포켓몬카페,신사이바시다이마루,캐릭터디저트,테마카페,오사카여행',
    DESCRIPTION = '귀여운 포켓몬 테마의 푸드와 디저트, 음료를 즐길 수 있는 다이마루 백화점 9층 캐릭터 테마 카페',
    ADDRESS = 'Main Building 9F, Daimaru Shinsaibashi, 1 Chome-7-1 Shinsaibashisuji, Chuo Ward, Osaka, 542-8501',
    LATITUDE = 34.6734125,
    LONGITUDE = 135.5009845,
    OPENING_HOURS = '10:00 - 20:00',
    PHONE = '+81 6-4256-1160',
    PRICE_RANGE = '¥2,000 - ¥6,000',
    WEBSITE_URL = 'https://osaka.pokemon-cafe.jp/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 불가',
    RESERVATION_INFO = '100% 사전 온라인 예약제 (공식 웹사이트)',
    PAYMENT_METHODS = '현금, 신용카드, 모바일 결제, 전자화폐',
    LANGUAGES = '일본어, 한국어, 영어, 중국어 (다국어 태블릿 주문)',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/ポケモンカフェpokemon shop.jpg',
    MENU_NAME = '모두를 미소 짓게 하는 피카츄 플레이트',
    MENU_DESCRIPTION = '피카츄 모양 오므라이스와 수제 함박스테이크를 함께 담아낸 대표 플레이트',
    MENU_PRICE = '¥1,980',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/ポケモンカフェ pokemon menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7012998620;

-- 4. 벤곤즈 티 오사카점
UPDATE RESTAURANTS
SET
    NAME = '벤곤즈 티 오사카점',
    CATEGORY = '카페 / 디저트',
    TAGS = '버블티,밀크티,스파클링티,시마노우치,나가호리바시카페',
    DESCRIPTION = '엄선된 프리미엄 찻잎과 쫄깃한 타피오카 펄, 신선한 과일 스파클링 티를 맛볼 수 있는 밀크티 전문점',
    ADDRESS = '1F, 1 Chome-21-30 Shimanouchi, Chuo Ward, Osaka, 542-0082',
    LATITUDE = 34.6738214,
    LONGITUDE = 135.5071253,
    OPENING_HOURS = '11:00 - 22:30',
    PHONE = '+81 6-4963-3250',
    PRICE_RANGE = '¥500 - ¥1,000',
    WEBSITE_URL = 'https://www.bengongstea-osaka.app/',
    SEAT_INFO = '매장 내 식사, 테이크아웃, 비대면 배달 가능',
    RESERVATION_INFO = '예약 불가',
    PAYMENT_METHODS = '현금, 신용카드, 모바일페이, 전자화폐',
    LANGUAGES = '일본어, 영어, 중국어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/本宮的茶 大阪｜タピオカミルクティー専門店｜BEN GONG’S TEA Osaka｜Boba & Chinese Style Tea shop.jpg',
    MENU_NAME = '흑당 버블 밀크티 (黑糖波波)',
    MENU_DESCRIPTION = '진한 흑당 시럽의 달콤함과 부드러운 우유에 쫀득한 타피오카 펄을 더한 대표 버블 밀크티',
    MENU_PRICE = '¥690',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/本宮的茶 大阪｜タピオカミルクティー専門店｜BEN GONG’S TEA Osaka｜Boba & Chinese Style Tea menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 12808803889;

-- 5. 마사히코 오즈미 파리
UPDATE RESTAURANTS
SET
    NAME = '마사히코 오즈미 파리',
    CATEGORY = '카페 / 디저트',
    TAGS = '털실케이크,몽블랑,오사카디저트,프랑스제과점,파티세리,인스타핫플',
    DESCRIPTION = '신개념의 프랑스풍 케이크와 쿠키, 털실 모양의 몽블랑 등 정교한 조형미를 자랑하는 고급 파티세리',
    ADDRESS = '1F, assess Otedori Bldg, 2 Chome-4-8 Otedori, Chuo Ward, Osaka, 540-0021',
    LATITUDE = 34.6862514,
    LONGITUDE = 135.514782,
    OPENING_HOURS = '10:00 - 19:00',
    PHONE = '+81 6-6355-4218',
    PRICE_RANGE = '¥1,000 - ¥3,000',
    WEBSITE_URL = 'https://masahiko-ozumi.com/',
    SEAT_INFO = '테이크아웃 전용 (매장 내 식사 공간 없음)',
    RESERVATION_INFO = '웹사이트 사전 예약 또는 당일 현장 구매',
    PAYMENT_METHODS = '신용카드, 전자화폐, 현금',
    LANGUAGES = '일본어, 영어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/癒ロイド 마사히코 shop.jpg',
    MENU_NAME = '자부통 몽블랑 (Zabuton Mont Blanc)',
    MENU_DESCRIPTION = '털실 모양으로 섬세하게 짠 진한 밤 크림과 부드러운 무스의 시그니처 디저트',
    MENU_PRICE = '¥950',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/癒ロイド 마사히코 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 2683072750;

-- 6. 그라후 스튜디오
UPDATE RESTAURANTS
SET
    NAME = '그라후 스튜디오',
    CATEGORY = '카페 / 디저트',
    TAGS = '디자인카페,까눌레,나카노시마,오사카디저트,카레맛집',
    DESCRIPTION = '가구 및 라이프스타일 디자인 스튜디오와 함께 운영되며 카놀레와 수제 디저트로 유명한 복합 문화 카페',
    ADDRESS = '4 Chome-1-9 Nakanoshima, Kita Ward, Osaka, 530-0005',
    LATITUDE = 34.6917412,
    LONGITUDE = 135.4901524,
    OPENING_HOURS = '11:30 - 18:00 (월요일 휴무)',
    PHONE = '+81 6-6459-2100',
    PRICE_RANGE = '¥1,000 - ¥1,999',
    WEBSITE_URL = 'https://www.graf-d3.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능 (테이블석, 테라스석)',
    RESERVATION_INFO = '예약 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/Grapt studio.jpg',
    MENU_NAME = '생딸기 머랭 타르트',
    MENU_DESCRIPTION = '바삭한 타르트 위에 신선한 생딸기와 생크림, 바삭한 수제 머랭을 얹은 타르트',
    MENU_PRICE = '¥1,100',
    MENU_IMAGE_URL = '/images/food-img/usj jp/Grapt studio menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 4193132897;

-- 7. 고칸 기타하마 본관
UPDATE RESTAURANTS
SET
    NAME = '고칸 기타하마 본관',
    CATEGORY = '카페 / 디저트',
    TAGS = '오사카디저트,기타하마카페,쌀롤케이크,서양과자,클래식살롱',
    DESCRIPTION = '등록유형문화재 건축물에서 일본산 쌀과 제철 재료로 만든 정통 양과자를 맛볼 수 있는 레트로 디저트 살롱',
    ADDRESS = '1F Arai Bldg, 2 Chome-1-1 Imabashi, Chuo Ward, Osaka, 541-0042',
    LATITUDE = 34.6908512,
    LONGITUDE = 135.5064218,
    OPENING_HOURS = '10:00 - 19:00',
    PHONE = '+81 6-4706-5160',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://shop.patisserie-gokan.co.jp/',
    SEAT_INFO = '매장 내 식사(2층 티살롱) 및 1층 테이크아웃 가능, 배달 불가',
    RESERVATION_INFO = '티살롱 현장 대기 접수',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/GOKAN.jpg',
    MENU_NAME = '클래식 쇼콜라 가나슈 케이크',
    MENU_DESCRIPTION = '초코 시트 사이에 진한 가나슈를 샌드하고 글라사주와 초코펄을 얹은 케이크',
    MENU_PRICE = '¥1,320',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/GOKAN menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 2398123196;

-- 8. 쿠지라 카페
UPDATE RESTAURANTS
SET
    NAME = '쿠지라 카페',
    CATEGORY = '카페 / 디저트',
    TAGS = '히메지마카페,레트로카페,가정식런치,수제푸딩,빈티지',
    DESCRIPTION = '고즈넉한 옛 민가를 개조해 정성스러운 가정식 런치와 수제 디저트를 선보였던 감성 카페',
    ADDRESS = 'Himejima, Nishiyodogawa Ward, Osaka, 555-0033',
    LATITUDE = 34.7082104,
    LONGITUDE = 135.4678125,
    OPENING_HOURS = '11:00 - 18:00 (휴업 확인 중)',
    PHONE = NULL,
    PRICE_RANGE = '¥1,000 - ¥1,999',
    WEBSITE_URL = 'https://tabelog.com/',
    SEAT_INFO = '매장 내 식사 가능 (테이블석, 다다미석)',
    RESERVATION_INFO = '현재 방문 전 확인 필요',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/くじらカフェ.jpg',
    MENU_NAME = '클래식 커스터드 푸딩 & 런치 플레이트',
    MENU_DESCRIPTION = '달콤쌉싸름한 카라멜 커스터드 푸딩과 담백한 가정식 런치를 함께 즐기는 세트',
    MENU_PRICE = '¥1,200',
    MENU_IMAGE_URL = '/images/food-img/usj jp/くじらカフェmenu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7491430886;

-- 9. 다이닝 도어즈
UPDATE RESTAURANTS
SET
    NAME = '다이닝 도어즈',
    CATEGORY = '카페 / 디저트',
    TAGS = '어반리서치,혼마치카페,자연식식당,브런치,오가닉푸드',
    DESCRIPTION = '의류 브랜드 어반리서치 도어즈가 운영하며 신선한 야채와 자연식 건강 식단을 선보였던 감성 라이프스타일 카페',
    ADDRESS = '3 Chome-2-6 Kyotarobashi, Chuo Ward, Osaka, 541-0056',
    LATITUDE = 34.683712,
    LONGITUDE = 135.5028451,
    OPENING_HOURS = '11:30 - 19:00 (운영 확인 요망)',
    PHONE = NULL,
    PRICE_RANGE = '¥1,000 - ¥1,999',
    WEBSITE_URL = 'https://media.urban-research.jp/brand/doors/',
    SEAT_INFO = '매장 내 식사 가능 (테이블석, 소파석)',
    RESERVATION_INFO = '예약 문의 요망',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/ダイニング ドアーズ.jpg',
    MENU_NAME = '마시멜로 코코아 & 딸기잼 생크림 스콘 플래터',
    MENU_DESCRIPTION = '바삭 촉촉한 수제 스콘에 딸기잼과 생크림을 올리고 따뜻한 마시멜로 음료를 곁들인 세트',
    MENU_PRICE = '¥1,350',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/ダイニング ドアーズ menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 4913961422;

-- 10. 안티코 카페 알 아비스
UPDATE RESTAURANTS
SET
    NAME = '안티코 카페 알 아비스',
    CATEGORY = '카페 / 디저트',
    TAGS = '우메다카페,파니니,에스프레소,슈크림,이탈리안바,허비스플라자',
    DESCRIPTION = '이탈리아 밀라노풍 바를 재현해 갓 구운 파니니와 진한 에스프레소, 디저트를 편안하게 즐길 수 있는 카페',
    ADDRESS = 'B2F, HERBIS PLAZA ENT, 2 Chome-2-22 Umeda, Kita Ward, Osaka, 530-0001',
    LATITUDE = 34.6989412,
    LONGITUDE = 135.4947214,
    OPENING_HOURS = '10:00 - 22:00',
    PHONE = '+81 6-6346-2588',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://anticocaffe.ne.jp/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '예약 불가',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/Antico Caffe Al Avis.jpg',
    MENU_NAME = '카포나타 파니니 & 비네 (슈크림)',
    MENU_DESCRIPTION = '풍성한 채소를 넣은 그릴 파니니와 바닐라빈 크림이 가득한 수제 슈크림 세트',
    MENU_PRICE = '¥1,100',
    MENU_IMAGE_URL = '/images/food-img/usj jp/Antico Caffe Al Avis menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 4572487893;

-- 11. 논샤라망
UPDATE RESTAURANTS
SET
    NAME = '논샤라망',
    CATEGORY = '카페 / 디저트',
    TAGS = '빈고마치카페,오사카킷사텐,핸드드립,레트로카페,디저트',
    DESCRIPTION = '빈고마치 골목에서 조용하고 여유롭게 즐기는 향긋한 커피와 디저트 공간',
    ADDRESS = '1 Chome-4-14 Bingomachi, Chuo Ward, Osaka, 541-0051',
    LATITUDE = 34.6851204,
    LONGITUDE = 135.5064512,
    OPENING_HOURS = '11:00 - 19:00',
    PHONE = NULL,
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'https://twitter.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '예약 불가',
    PAYMENT_METHODS = '현금, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/ノンシャラマンカフェ.jpg',
    MENU_NAME = '핸드드립 하우스 블렌드 커피',
    MENU_DESCRIPTION = '부드러운 산미와 깊은 바디감이 조화로운 정통 핸드드립 하우스 커피',
    MENU_PRICE = '¥550',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/ノンシャラマンカフェmenu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 6481984525;

-- 12. 카나리야 본점
UPDATE RESTAURANTS
SET
    NAME = '카나리야 본점',
    CATEGORY = '카페 / 디저트',
    TAGS = '파르페전문점,쓰루하시맛집,대용량파르페,디저트카페,가성비스위츠',
    DESCRIPTION = '압도적인 크기와 푸짐한 토핑으로 사랑받는 쓰루하시의 전설적인 원조 파르페 전문점',
    ADDRESS = '2-9 Shimoajiharacho, Tennoji Ward, Osaka, 543-0025',
    LATITUDE = 34.6663214,
    LONGITUDE = 135.5309851,
    OPENING_HOURS = '11:00 - 23:00',
    PHONE = '+81 6-6779-4582',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사 및 매장 밖 수령 가능, 배달 서비스 불가',
    RESERVATION_INFO = '현장 대기 접수 (전화 예약 문의)',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/KANARIYA.jpg',
    MENU_NAME = '점보 파르페',
    MENU_DESCRIPTION = '아이스크림과 생크림, 달콤한 토핑을 높게 쌓아 올린 원조 대용량 파르페',
    MENU_PRICE = '¥1,000',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/KANARIYA menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 10241857134;

-- 13. 모토커피 기타하마점
UPDATE RESTAURANTS
SET
    NAME = '모토커피 기타하마점',
    CATEGORY = '카페 / 디저트',
    TAGS = '기타하마카페,테라스카페,리버뷰,푸딩맛집,토스트,오사카여행핫플',
    DESCRIPTION = '토사보리 강변 테라스에서 나카노시마 공원 뷰를 바라보며 커피와 푸딩, 토스트를 즐길 수 있는 대표 리버뷰 카페',
    ADDRESS = 'Lion Bldg, 2 Chome-1-1 Kitahama, Chuo Ward, Osaka, 541-0041',
    LATITUDE = 34.6917215,
    LONGITUDE = 135.5065842,
    OPENING_HOURS = '11:00 - 18:00',
    PHONE = '+81 6-4706-3788',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://shelf-keybridge.com/',
    SEAT_INFO = '매장 내 식사 및 테라스석, 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '현장 대기 접수표 작성',
    PAYMENT_METHODS = '현금 전용 / 카드 확인 요망',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/모토커피.jpg',
    MENU_NAME = '핸드드립 커피',
    MENU_DESCRIPTION = '리버뷰와 함께 즐기는 깔끔하고 밸런스 좋은 스페셜티 핸드드립 커피',
    MENU_PRICE = '¥600',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/모토커피 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 4572487891;

-- 14. 닐 나카자키초
UPDATE RESTAURANTS
SET
    NAME = '닐 나카자키초',
    CATEGORY = '카페 / 디저트',
    TAGS = '나카자키초카페,크레페,카츠샌드,감성카페,우메다근처,인스타핫플',
    DESCRIPTION = '나카자키초 골목에서 바삭한 버터 슈가 크레페와 육즙 가득한 카츠샌드를 즐길 수 있는 감성 카페',
    ADDRESS = '4 Chome-1-13 Nakazakinishi, Kita Ward, Osaka, 530-0015',
    LATITUDE = 34.7063124,
    LONGITUDE = 135.5034125,
    OPENING_HOURS = '10:00 - 20:30',
    PHONE = '+81 6-6867-9996',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://neel.coffee/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '예약 불가 (현장 대기)',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/neel中崎町.jpg',
    MENU_NAME = '특제 로스 카츠샌드 & 스프 플레이트',
    MENU_DESCRIPTION = '두툼한 돈카츠 샌드위치에 따뜻한 수프와 웨지감자를 곁들인 브런치 플레이트',
    MENU_PRICE = '¥850',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/neel中崎町 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 11005365770;

-- 15. 우사기토보쿠
UPDATE RESTAURANTS
SET
    NAME = '우사기토보쿠',
    CATEGORY = '카페 / 디저트',
    TAGS = '아베노카페,토끼라떼아트,자가배전,스페셜티커피,조용한카페',
    DESCRIPTION = '아기자기한 토끼 라떼아트와 정성스럽게 직접 로스팅한 스페셜티 커피를 맛볼 수 있는 쇼와초 감성 킷사텐',
    ADDRESS = '3 Chome-9-10 Hannancho, Abeno Ward, Osaka, 545-0021',
    LATITUDE = 34.6298124,
    LONGITUDE = 135.5151240,
    OPENING_HOURS = '09:00 - 18:00',
    PHONE = '+81 6-7502-2155',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://usaboku-coffee.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '온라인 주문 및 방문 문의',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/うさぎとぼく shop.jpg',
    MENU_NAME = '우사기 카푸치노 & 토스트 세트',
    MENU_DESCRIPTION = '귀여운 토끼 라떼아트 카푸치노와 바삭한 버터 토스트로 구성된 카페 세트',
    MENU_PRICE = '¥1,500',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/うさぎとぼく.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 12946146782;

-- 16. 24시간 스위츠노키분
UPDATE RESTAURANTS
SET
    NAME = '24시간 스위츠노키분',
    CATEGORY = '카페 / 디저트',
    TAGS = '24시간디저트,무인아이스크림,이쿠노구,쇼지,무인매장',
    DESCRIPTION = '전국의 인기 캔케이크, 아이스크림, 마카롱 등 트렌디한 스위츠를 24시간 무인으로 구매할 수 있었던 디저트 전문점',
    ADDRESS = '1 Chome-1-23 Shojihigashi, Ikuno Ward, Osaka, 544-0003',
    LATITUDE = 34.6639120,
    LONGITUDE = 135.5566214,
    OPENING_HOURS = '폐업',
    PHONE = '+81 80-4707-0087',
    PRICE_RANGE = '¥500 - ¥1,500',
    WEBSITE_URL = NULL,
    SEAT_INFO = '테이크아웃 전용 (무인 판매기 운영)',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '현금, 전자화폐, 모바일페이',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/24 shop.jpg',
    MENU_NAME = '보틀 쇼트케이크 캔',
    MENU_DESCRIPTION = '투명 캔에 생크림과 과일을 층층이 담아낸 테이크아웃 전용 보틀 케이크',
    MENU_PRICE = '¥750',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/24 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 11407048000;

-- 17. 카페 태양의 탑 본점
UPDATE RESTAURANTS
SET
    NAME = '카페 태양의 탑 본점',
    CATEGORY = '카페 / 디저트',
    TAGS = '나카자키초카페,태양의탑,레트로감성,수제케이크,크림소다,오사카여행',
    DESCRIPTION = '빈티지 레트로 감성의 인테리어와 알록달록한 크림소다, 수제 케이크로 사랑받는 나카자키초 대표 카페',
    ADDRESS = '1F Pilot Bldg, 2 Chome-3-12 Nakazaki, Kita Ward, Osaka, 530-0016',
    LATITUDE = 34.7061204,
    LONGITUDE = 135.5057812,
    OPENING_HOURS = '09:00 - 22:00',
    PHONE = '+81 6-6374-3630',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://taiyounotou.com/',
    SEAT_INFO = '매장 내 식사, 매장 밖 수령, 배달 서비스 가능',
    RESERVATION_INFO = '공식 웹사이트를 통한 예약 및 온라인 주문 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/太陽ノ塔.jpg',
    MENU_NAME = '레트로 커스터드 푸딩',
    MENU_DESCRIPTION = '탱글탱글한 커스터드 푸딩에 진한 카라멜 시럽과 생크림, 체리를 올린 디저트',
    MENU_PRICE = '¥800',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/太陽ノ塔.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 3211790261;

-- 18. 유테
UPDATE RESTAURANTS
SET
    NAME = '유테',
    CATEGORY = '카페 / 디저트',
    TAGS = '요도가와카페,비건디저트,건강식런치,핸드드립,아늑한공간',
    DESCRIPTION = '신선한 채소와 건강한 식재료로 정성스럽게 차려내는 가정식 런치와 수제 구움과자 카페',
    ADDRESS = '2 Chome-24-18 Kikawanishi, Yodogawa Ward, Osaka, 532-0013',
    LATITUDE = 34.7228412,
    LONGITUDE = 135.4883124,
    OPENING_HOURS = '11:00 - 18:00',
    PHONE = NULL,
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사 가능 (배달 불가)',
    RESERVATION_INFO = '인스타그램 DM 문의',
    PAYMENT_METHODS = '현금, 모바일페이, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL ='/images/store-img/osaka castle/cafe yutte.jpg',
    MENU_NAME = '계절 채소 런치 플레이트',
    MENU_DESCRIPTION = '제철 채소와 건강한 반찬, 잡곡밥을 담백하게 차려낸 런치 플레이트',
    MENU_PRICE = '¥980',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/cafe yutte menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5875311485;

-- 19. 공차 우메다 차야마치점
UPDATE RESTAURANTS
SET
    NAME = '공차 우메다 차야마치점',
    CATEGORY = '카페 / 디저트',
    TAGS = '공차,우메다카페,차야마치,버블티,밀크티,테이크아웃',
    DESCRIPTION = '엄선된 오리지널 티 베이스에 타피오카 펄 등 취향에 맞는 토핑을 커스텀해 즐기는 글로벌 밀크티 전문점',
    ADDRESS = '1F, Espacion Umeda Bldg, 12-6 Chayamachi, Kita Ward, Osaka, 530-0013',
    LATITUDE = 34.7048512,
    LONGITUDE = 135.4988451,
    OPENING_HOURS = '10:00 - 22:00',
    PHONE = '+81 6-6467-8807',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'https://www.gongcha.co.jp/',
    SEAT_INFO = '매장 내 식사, 매장 밖 수령, 배달 서비스 가능',
    RESERVATION_INFO = '모바일 오더 및 온라인 주문 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐, 모바일페이',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/Gong Cha Umeda Chayamachi.jpg',
    MENU_NAME = '블랙 밀크티 & 펄',
    MENU_DESCRIPTION = '진한 블랙티와 부드러운 우유에 쫀득한 타피오카 펄을 더한 시그니처 밀크티',
    MENU_PRICE = '¥650',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/Gong Cha Umeda Chayamachi menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7477261131;

-- 20. 라 그란다 파밀리오 나카자키초
UPDATE RESTAURANTS
SET
    NAME = '라 그란다 파밀리오 나카자키초',
    CATEGORY = '카페 / 디저트',
    TAGS = '나카자키초카페,수제그래놀라,오가닉,비건디저트,건강식,감성카페',
    DESCRIPTION = '유기농 재료로 정성스럽게 구워낸 수제 그래놀라와 비건 디저트를 맛볼 수 있는 나카자키초 아늑한 카페',
    ADDRESS = '1 Chome-1-18 Nakazakinishi, Kita Ward, Osaka, 530-0015',
    LATITUDE = 34.7068521,
    LONGITUDE = 135.5042125,
    OPENING_HOURS = '10:30 - 18:00',
    PHONE = '+81 6-6136-7811',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://grandafamilio.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능 (배달 불가)',
    RESERVATION_INFO = '온라인 주문 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/La Granda Familio Nakazakicho.jpg',
    MENU_NAME = '유기농 수제 그래놀라 볼',
    MENU_DESCRIPTION = '바삭한 오가닉 그래놀라 위에 생과일과 플레인 요거트를 얹은 디저트',
    MENU_PRICE = '¥980',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/La Granda Familio Nakazakicho menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7477438893;

-- 21. 살롱 드 아만토
UPDATE RESTAURANTS
SET
    NAME = '살롱 드 아만토',
    CATEGORY = '카페 / 디저트',
    TAGS = '나카자키초카페,고민가카페,빈티지,문화복합공간,핸드드립,말차',
    DESCRIPTION = '담쟁이덩굴로 둘러싸인 100년 된 고민가를 재생하여 예술과 여유로운 티타임을 선사하는 레트로 아트 카페',
    ADDRESS = '1 Chome-7-26 Nakazakinishi, Kita Ward, Osaka, 530-0015',
    LATITUDE = 34.7055412,
    LONGITUDE = 135.5044218,
    OPENING_HOURS = '12:00 - 22:00',
    PHONE = '+81 6-6371-5840',
    PRICE_RANGE = '¥700 - ¥1,500',
    WEBSITE_URL = 'http://amanto.jp/',
    SEAT_INFO = '매장 내 식사 가능 (테이크아웃 및 배달 불가)',
    RESERVATION_INFO = '현장 방문',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/살롱 드 아만토.jpg',
    MENU_NAME = '아만토 수제 드립 커피 & 치즈케이크',
    MENU_DESCRIPTION = '빈티지 감성 공간에서 맛보는 깊은 풍미의 드립 커피와 수제 치즈케이크',
    MENU_PRICE = '¥850',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/살롱 드 아만토 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 3176116590;

-- 22. 보나본
UPDATE RESTAURANTS
SET
    NAME = '보나본',
    CATEGORY = '카페 / 디저트',
    TAGS = '주소카페,치즈케이크맛집,수제케이크,파스타런치,디저트다이닝',
    DESCRIPTION = '입안에서 녹아내리는 수제 치즈케이크와 정통 파스타 런치를 편안하게 즐길 수 있는 카페 다이닝',
    ADDRESS = '1F The Grandview Osaka, 1 Chome-20-3 Jusohigashi, Yodogawa Ward, Osaka, 532-0023',
    LATITUDE = 34.7198514,
    LONGITUDE = 135.4851240,
    OPENING_HOURS = '09:00 - 21:00',
    PHONE = '+81 6-4805-8780',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://bonandbon.owst.jp/',
    SEAT_INFO = '테이블석, 소파석 (매장 내 식사 및 테이크아웃 가능)',
    RESERVATION_INFO = '온라인 예약(웹사이트) 및 전화 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/Bon ''n'' Bon.jpg',
    MENU_NAME = '매직 치즈케이크 세트',
    MENU_DESCRIPTION = '입안에서 사르르 녹아내리는 부드럽고 진한 수플레 크림치즈 케이크',
    MENU_PRICE = '¥1,050',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/Bon ''n'' Bon menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 6984070689;

-- 23. 커피숍 혼다
UPDATE RESTAURANTS
SET
    NAME = '커피숍 혼다',
    CATEGORY = '카페 / 디저트',
    TAGS = '츠루미구,킷사텐,모닝세트,핸드드립,레트로다방,토스트',
    DESCRIPTION = '아침 6시부터 문을 열어 갓 내린 커피와 바삭한 모닝 토스트를 맛볼 수 있는 정겨운 로컬 킷사텐',
    ADDRESS = '5 Chome-17-6 Imazukita, Tsurumi Ward, Osaka, 538-0041',
    LATITUDE = 34.6932412,
    LONGITUDE = 135.5681240,
    OPENING_HOURS = '06:00 - 18:00',
    PHONE = '+81 6-6961-9412',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://www.hotpepper.jp/',
    SEAT_INFO = '매장 내 식사 가능 (배달 불가)',
    RESERVATION_INFO = '현장 방문',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/커피숍 혼다.jpg',
    MENU_NAME = '클래식 모닝 토스트 세트',
    MENU_DESCRIPTION = '갓 구운 버터 토스트와 삶은 달걀, 향긋한 블렌드 커피로 채운 아침 세트',
    MENU_PRICE = '¥600',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/커피숍 혼다 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 10555852925;


-- ============================================================
-- 2. 일식 / 면 요리 / 스시 (8개 매장)
-- ============================================================

-- 24. 야키토리주바 BOO
UPDATE RESTAURANTS
SET
    NAME = '야키토리주바 BOO',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '야키토리,닭꼬치,요도가와,츠카모토,퇴근길한잔,이자카야',
    DESCRIPTION = '비장탄 숯불에 정성스럽게 구워낸 신선한 토종닭 꼬치구이와 시원한 생맥주를 즐길 수 있는 닭요리 전문 주점',
    ADDRESS = '2 Chome-28-21 Tsukamoto, Yodogawa Ward, Osaka, 532-0026',
    LATITUDE = 34.7135824,
    LONGITUDE = 135.4716892,
    OPENING_HOURS = '18:00 - 24:00',
    PHONE = NULL,
    PRICE_RANGE = '¥1,000 - ¥4,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '카운터석, 테이블석 (매장 내 식사만 가능, 휠체어 이용 불가)',
    RESERVATION_INFO = '현장 방문 권장',
    PAYMENT_METHODS = '현금 전용 / 카드 확인 요망',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/焼き鳥酒場　BOO.jpg',
    MENU_NAME = '특선 숯불 야키토리 5종 모둠',
    MENU_DESCRIPTION = '비장탄에 바삭하게 구워 감칠맛 나는 타레 소스를 입힌 닭꼬치 모둠',
    MENU_PRICE = '¥980',
    MENU_IMAGE_URL = '/images/food-img/usj jp/焼き鳥酒場　BOO menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5385197034;

-- 25. 마이도! 토요토요
UPDATE RESTAURANTS
SET
    NAME = '마이도! 토요토요',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '요도가와,우동맛집,사누키우동,가성비맛집,면요리',
    DESCRIPTION = '쫄깃하고 탱탱한 자가제면 사누키 면발과 깔끔하고 깊은 다시 육수를 선보이는 로컬 우동집',
    ADDRESS = '1 Chome-5-21 Mitsuyanaka, Yodogawa Ward, Osaka, 532-0036',
    LATITUDE = 34.7178125,
    LONGITUDE = 135.4745120,
    OPENING_HOURS = '11:00 - 21:00',
    PHONE = NULL,
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '매장 내 식사 가능 (배달 불가)',
    RESERVATION_INFO = '예약 불가 (현장 방문)',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/まいど!とよとよ.jpg',
    MENU_NAME = '오로시 가라아게 & 미니 우동 정식',
    MENU_DESCRIPTION = '바삭한 가라아게에 폰즈 소스를 곁들인 튀김과 쫄깃한 미니 우동 정식',
    MENU_PRICE = '¥750',
    MENU_IMAGE_URL = '/images/food-img/usj jp/まいど!とよとよ menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7051512587;

-- 26. 카부키고멘 텐진바시 본점
UPDATE RESTAURANTS
SET
    NAME = '카부키고멘 텐진바시 본점',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '텐진바시상점가,츠케멘,돈코츠라멘,농후육수,차슈덮밥',
    DESCRIPTION = '덴고나카자키도리 상점가 입구에서 묵직하고 진한 돈코츠 어패류 육수로 인기를 끌었던 라멘 전문점',
    ADDRESS = '1F Dengo Nakazaki-dori Shopping Street, 4-23 Naniwacho, Kita Ward, Osaka, 530-0022',
    LATITUDE = 34.7076214,
    LONGITUDE = 135.5106512,
    OPENING_HOURS = '폐업',
    PHONE = '+81 6-6147-4446',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://kabuki-gomen.com/',
    SEAT_INFO = '카운터석 (상점가 1층 위치)',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '식권 자판기 (현금 전용)',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/傾奇御麺 天神橋・本店.jpg',
    MENU_NAME = '농후 어패 돈코츠 츠케멘',
    MENU_DESCRIPTION = '돼지뼈와 어패류를 진하게 우려낸 농후 소스에 극태면을 찍어 먹는 츠케멘',
    MENU_PRICE = '¥950',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/傾奇御麺 天神橋・本店 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7477484852;

-- 27. 시키슌사이 무라타
UPDATE RESTAURANTS
SET
    NAME = '시키슌사이 무라타',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '주소맛집,제철요리,사케,일식주점,계절생선회,모임장소',
    DESCRIPTION = '사계절 제철 생선회와 엄선된 신선한 채소 요리를 정갈하게 선보이는 주소역 인근 일식 주점',
    ADDRESS = '1 Chome-1-17 Jusohigashi, Yodogawa Ward, Osaka, 532-0023',
    LATITUDE = 34.7188120,
    LONGITUDE = 135.4851240,
    OPENING_HOURS = '17:00 - 23:00',
    PHONE = '+81 6-6770-9777',
    PRICE_RANGE = '¥5,000 - ¥6,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사 가능 (배달 서비스 불가)',
    RESERVATION_INFO = '전화 예약 권장',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/四季旬菜 むら田.jpg',
    MENU_NAME = '제철 모둠 사시미 5종',
    MENU_DESCRIPTION = '산지 직송 제철 생선 본연의 신선함과 기름진 맛을 담아낸 모둠 생선회',
    MENU_PRICE = '¥2,800',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/四季旬菜 むら田 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 2000000061;

-- 29. 스시 키노스케
UPDATE RESTAURANTS
SET
    NAME = '스시 키노스케',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '카미신조,스시오마카세,적초초밥,카운터스시,기념일,와인페어링',
    DESCRIPTION = '감칠맛을 극대화한 적초 밥과 신선한 제철 생선 니기리를 와인과 함께 편안하게 즐기는 8석 규모의 스시야',
    ADDRESS = 'Kamishinjo, Higashiyodogawa Ward, Osaka, 533-0006',
    LATITUDE = 34.7501254,
    LONGITUDE = 135.5348120,
    OPENING_HOURS = '18:00 - 22:00',
    PHONE = '050-5600-9106',
    PRICE_RANGE = '¥10,000 - ¥14,999',
    WEBSITE_URL = 'https://tabelog.com/',
    SEAT_INFO = '카운터 8석 (매장 내 식사 전용)',
    RESERVATION_INFO = '인터넷 사전 예약 필수 (당일 20시까지 즉시 예약 가능)',
    PAYMENT_METHODS = '신용카드, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/sushi karau.jpg',
    MENU_NAME = '셰프 오마카세 니기리 코스',
    MENU_DESCRIPTION = '감칠맛 도는 적초 샤리와 제철 생선의 조화가 돋보이는 에도마에 스시 코스',
    MENU_PRICE = '¥12,000',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/sushi karau menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7430418820;

-- 30. 아와한다 제면소
UPDATE RESTAURANTS
SET
    NAME = '아와한다 제면소',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '히가시요도가와,한다소면,자가제면,아침식사,우동맛집,가성비',
    DESCRIPTION = '도쿠시마 특산 한다 소면 스타일의 굵고 쫄깃한 자가제 면발과 맑은 육수를 맛볼 수 있는 제면소 직영 식당',
    ADDRESS = '2 Chome-5-5 Komatsu, Higashiyodogawa Ward, Osaka, 533-0004',
    LATITUDE = 34.7518420,
    LONGITUDE = 135.5361245,
    OPENING_HOURS = '07:00 - 20:00',
    PHONE = '+81 6-6326-1020',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '매장 내 식사, 테이크아웃, 배달 서비스 가능',
    RESERVATION_INFO = '예약 불가 (선착순 방문)',
    PAYMENT_METHODS = '현금 전용 / 자판기 식권',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/아와한다 제면소.jpg',
    MENU_NAME = '특제 자가제면 냉우동 & 튀김 세트',
    MENU_DESCRIPTION = '매끄럽고 탄력 있는 자가제 면에 시원한 쯔유와 튀김을 곁들인 냉우동 세트',
    MENU_PRICE = '¥700',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/아와한다 제면소 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5423722642;

-- 31. 비스트로 키친 히나타
UPDATE RESTAURANTS
SET
    NAME = '비스트로 키친 히나타',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '테이크아웃전문,저온조리스테이크,로스트비프,흑모와규함바그,요도가와',
    DESCRIPTION = '저온 조리 스테이크, 로스트비프, 흑모와규 100% 수제 함바그를 제공하는 테이크아웃 전문 비스트로',
    ADDRESS = 'San Heights 2, 1 Chome-1-3 Mitsuyakita, Yodogawa Ward, Osaka, 532-0032',
    LATITUDE = 34.7214152,
    LONGITUDE = 135.4768214,
    OPENING_HOURS = '11:00 - 20:00 (월요일 휴무)',
    PHONE = '+81 6-6307-6310',
    PRICE_RANGE = '¥1,000 - ¥3,000',
    WEBSITE_URL = 'https://www.facebook.com/',
    SEAT_INFO = '테이크아웃 전용 매장',
    RESERVATION_INFO = '전화 사전 예약 및 주문 가능',
    PAYMENT_METHODS = '현금, 신용카드, 모바일 결제',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/ビストロキッチン陽 (ひなた）.jpg',
    MENU_NAME = '흑모와규 특선 소고기 코마기레 플래터',
    MENU_DESCRIPTION = '부드러운 육질의 흑모와규를 얇게 썰어 수북하게 담아낸 소고기 플래터',
    MENU_PRICE = '¥1,400',
    MENU_IMAGE_URL = '/images/food-img/usj jp/ビストロキッチン陽 (ひなた） menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 9006517015;


-- ============================================================
-- 3. 양식 / 비스트로 / 스테이크 (6개 매장)
-- ============================================================

-- 32. 파르고로 (Pargolo)
UPDATE RESTAURANTS
SET
    NAME = '파르고로',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '이탈리안,생면파스타,화덕피자,코노하나구맛집,와인',
    DESCRIPTION = '신선한 해산물과 정통 화덕 피자, 자가제 파스타를 와인과 함께 즐기는 아늑한 이탈리안 비스트로',
    ADDRESS = '1 Chome-1-39 Shikanjima, Konohana Ward, Osaka, 554-0014',
    LATITUDE = 34.6833125,
    LONGITUDE = 135.4560124,
    OPENING_HOURS = '12:00 - 22:00',
    PHONE = '+81 6-6464-0651',
    PRICE_RANGE = '¥2,000 - ¥3,000',
    WEBSITE_URL = 'https://www.facebook.com/',
    SEAT_INFO = '매장 내 식사 가능 (테이블석), 배달 서비스 불가',
    RESERVATION_INFO = '전화 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/Pargolo shop.jpg',
    MENU_NAME = '정통 화덕 마르게리타 피자',
    MENU_DESCRIPTION = '화덕에 구워 쫄깃한 도우 위에 토마토소스, 모차렐라 치즈, 생바질을 올린 피자',
    MENU_PRICE = '¥2,500',
    MENU_IMAGE_URL = '/images/food-img/usj jp/Pargolo menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 3933150228;

-- 33. 카페 노스트라 (Cafe Nostra)
UPDATE RESTAURANTS
SET
    NAME = '카페 노스트라',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '키타구카페,스가하라초,분위기좋은,커피,디저트',
    DESCRIPTION = '키타구 스가하라초에 위치한 모던하고 아늑한 분위기의 로컬 감성 카페',
    ADDRESS = 'Genius Osaka 104, 10-26 Sugaharacho, Kita Ward, Osaka, 530-0046',
    LATITUDE = 34.6941205,
    LONGITUDE = 135.5089451,
    OPENING_HOURS = '11:00 - 17:00',
    PHONE = '+81 6-6311-2560',
    PRICE_RANGE = '¥1,000 - ¥5,000',
    WEBSITE_URL = 'https://k522500.gorp.jp/',
    SEAT_INFO = '매장 내 식사 가능, 배달 서비스 불가',
    RESERVATION_INFO = '온라인 및 전화 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/NOSTRA.jpg',
    MENU_NAME = '연어 아보카도 포케 라이스 플레이트 & 스프 세트',
    MENU_DESCRIPTION = '신선한 생연어와 아보카도 포케에 채소 샐러드와 수프를 곁들인 브런치 세트',
    MENU_PRICE = '¥1,200',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/NOSTRA.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5025047984;

-- 34. 삼십사 키친 (34 Kitchen)
UPDATE RESTAURANTS
SET
    NAME = '삼십사 키친',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '나카츠카페,브런치맛집,다이닝카페,수제디저트,내추럴와인',
    DESCRIPTION = '모던하고 감각적인 인테리어 속에서 정성 가득한 브런치 플레이트와 디저트, 커피를 즐길 수 있는 카페',
    ADDRESS = '1F, 3 Chome-23-8 Nakatsu, Kita Ward, Osaka, 531-0071',
    LATITUDE = 34.7120145,
    LONGITUDE = 135.4919541,
    OPENING_HOURS = '09:00 - 20:00',
    PHONE = '+81 6-4256-6915',
    PRICE_RANGE = '¥2,000 - ¥3,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능 (배달 불가)',
    RESERVATION_INFO = '인스타그램 DM 또는 전화 문의',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/34 kitchen.jpg',
    MENU_NAME = '34 시그니처 브런치 플레이트',
    MENU_DESCRIPTION = '바삭한 토스트와 육즙 가득한 소시지, 신선한 샐러드를 담은 올데이 브런치',
    MENU_PRICE = '¥1,600',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/34 kitchen menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 3432264291;

-- 35. 비스트로 소울 키친
UPDATE RESTAURANTS
SET
    NAME = '비스트로 소울 키친',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '주소맛집,이탈리안,와인바,수제파스타,소형비스트로,분위기좋은',
    DESCRIPTION = '주소역 골목에서 정성스레 만든 이탈리아 요리와 엄선된 와인을 아늑하고 편안하게 즐기는 비스트로',
    ADDRESS = 'No.102 Sanyo Mansion, 1 Chome-17-2 Jusohigashi, Yodogawa Ward, Osaka, 532-0023',
    LATITUDE = 34.7189124,
    LONGITUDE = 135.4859841,
    OPENING_HOURS = '18:00 - 24:00',
    PHONE = '+81 6-7708-7475',
    PRICE_RANGE = '¥2,000 - ¥3,000',
    WEBSITE_URL = 'https://www.facebook.com/',
    SEAT_INFO = '카운터석, 테이블석 (매장 내 식사 가능, 배달 불가)',
    RESERVATION_INFO = '온라인 주문 및 전화 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/비스트로.jpg',
    MENU_NAME = '특선 해산물 토마토 파스타 & 타파스 플래터',
    MENU_DESCRIPTION = '풍부한 해산물 풍미의 토마토 파스타',
    MENU_PRICE = '¥1,800',
    MENU_IMAGE_URL = '/images/food-img/usj jp/비스트로 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 6984112024;

-- 36. 일파운드 스테이크 앤 함바그 타케루 히가시미쿠니점
UPDATE RESTAURANTS
SET
    NAME = '일파운드 스테이크 앤 함바그 타케루 히가시미쿠니점',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '히가시미쿠니,1파운드스테이크,수제함바그,가성비스테이크,육즙폭발',
    DESCRIPTION = '뜨거운 철판에 푸짐한 1파운드 스테이크와 육즙 가득한 수제 함바그를 든든하게 즐길 수 있는 고기 전문점',
    ADDRESS = 'Dai 6 Enshin Kita Osaka Bldg, 4 Chome-2-18 Higashimikuni, Yodogawa Ward, Osaka, 532-0002',
    LATITUDE = 34.7412541,
    LONGITUDE = 135.4981452,
    OPENING_HOURS = '11:00 - 22:30',
    PHONE = '+81 6-4807-2929',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://steak-takeru.jp/',
    SEAT_INFO = '카운터석, 테이블석 (매장 식사, 테이크아웃, 배달 서비스 가능)',
    RESERVATION_INFO = '온라인 예약 및 포장 주문 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/일파운드 스테이크 앤 함바그 타케루.jpg',
    MENU_NAME = '타케루 특선 1파운드 스테이크',
    MENU_DESCRIPTION = '센 불에 구워낸 두툼한 소고기에 특제 소스와 마늘칩을 올린 대용량 스테이크',
    MENU_PRICE = '¥1,980',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/일파운드 스테이크 앤 함바그 타케루 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7510812999;

-- 37. 다이닝바 7
UPDATE RESTAURANTS
SET
    NAME = '다이닝바 7',
    CATEGORY = '양식 / 비스트로 / 스테이크',
    TAGS = '츠카모토술집,다이닝바,사케,하이볼,심야영업,분위기좋은',
    DESCRIPTION = '츠카모토역 앞 빌딩에서 다채로운 안주와 칵테일, 사케를 편안하게 즐길 수 있는 다이닝 바',
    ADDRESS = 'Tsukamoto Ekimae Bldg, 3 Chome-1-38 Kashiwazato, Nishiyodogawa Ward, Osaka, 555-0022',
    LATITUDE = 34.7123512,
    LONGITUDE = 135.469542,
    OPENING_HOURS = '17:30 - 02:00',
    PHONE = '+81 6-6477-7087',
    PRICE_RANGE = '¥3,000 - ¥4,000',
    WEBSITE_URL = 'https://www.hotpepper.jp/',
    SEAT_INFO = '카운터석, 테이블석 (매장 내 식사 가능, 배달 불가)',
    RESERVATION_INFO = '온라인 주문 및 핫페퍼 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드, 모바일 결제',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/ダイニングバー七.jpg',
    MENU_NAME = '칠(七) 특제 스테이크',
    MENU_DESCRIPTION = '풍부한 육즙과 부드러운 식감을 살려 그릴에 구워낸 시그니처 소고기 스테이크',
    MENU_PRICE = '¥1,980',
    MENU_IMAGE_URL = '/images/food-img/usj jp/ダイニングバー七 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7489012351;


-- ============================================================
-- 4. 바 / 펍 / 이자카야 (3개 매장)
-- ============================================================

-- 38. 에뮤 리본 라이브 카페앤바
UPDATE RESTAURANTS
SET
    NAME = '에뮤 리본 라이브 카페앤바',
    CATEGORY = '바 / 펍 / 이자카야',
    TAGS = '라이브카페,공연바,도톤보리,니시신사이바시,이색카페',
    DESCRIPTION = '음악 라이브 공연과 함께 음료 및 주류를 즐길 수 있었던 신사이바시 지하 라이브 카페 겸 바',
    ADDRESS = 'B1F, Riviere Dotonbori, 2 Chome-13-5 Nishishinsaibashi, Chuo Ward, Osaka, 542-0086',
    LATITUDE = 34.6698621,
    LONGITUDE = 135.4979854,
    OPENING_HOURS = '폐업',
    PHONE = NULL,
    PRICE_RANGE = '¥2,000 - ¥4,000',
    WEBSITE_URL = 'http://live-cafe-bar.aimyouribbon.com/',
    SEAT_INFO = '테이블석, 카운터석, 무대 관람석',
    RESERVATION_INFO = '영업 종료로 인한 예약 불가',
    PAYMENT_METHODS = '현금, 카드 결제',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/エミュリボン Aimyou Ribbon shop.jpg',
    MENU_NAME = '오리지널 칵테일 & 라이브 세트',
    MENU_DESCRIPTION = '공연 관람과 함께 마시기 좋은 시그니처 하우스 칵테일과 간단한 스낵 세트',
    MENU_PRICE = '¥1,500',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/エミュリボン Aimyou Ribbon menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5382170422;

-- 39. A35 히가시미쿠니 바르
UPDATE RESTAURANTS
SET
    NAME = 'A35 히가시미쿠니 바르',
    CATEGORY = '바 / 펍 / 이자카야',
    TAGS = '히가시미쿠니,타파스바,와인맛집,감바스,분위기좋은주점',
    DESCRIPTION = '합리적인 가격의 타파스 안주와 와인을 편안하게 즐길 수 있었던 히가시미쿠니의 로컬 바르',
    ADDRESS = '4 Chome-1-25 Higashimikuni, Yodogawa Ward, Osaka, 532-0002',
    LATITUDE = 34.7398514,
    LONGITUDE = 135.4981240,
    OPENING_HOURS = '폐업',
    PHONE = '+81 6-6350-4635',
    PRICE_RANGE = '¥2,000 - ¥5,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '카운터석, 테이블석',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/A35 東三国バル.jpg',
    MENU_NAME = '새우 알 아히요 & 하우스 와인',
    MENU_DESCRIPTION = '마늘과 올리브오일에 지글지글 끓여 바게트를 찍어 먹는 스페인식 새우 요리',
    MENU_PRICE = '¥1,680',
    MENU_IMAGE_URL = '/images/food-img/usj jp/A35 東三国バル menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7462735230;

-- 40. 카페 & 바 스웰
UPDATE RESTAURANTS
SET
    NAME = '카페 & 바 스웰',
    CATEGORY = '바 / 펍 / 이자카야',
    TAGS = '신오사카술집,미야하라,심야영업,칵테일바,수제안주,분위기좋은',
    DESCRIPTION = '신오사카 미야하라 지역에서 새벽 2시까지 다양한 주류와 맛있는 핑거푸드를 편안하게 즐길 수 있는 카페 겸 바',
    ADDRESS = '2 Chome-12-20 Miyahara, Yodogawa Ward, Osaka, 532-0003',
    LATITUDE = 34.7371420,
    LONGITUDE = 135.4973512,
    OPENING_HOURS = '18:00 - 02:00',
    PHONE = '+81 6-6868-9644',
    PRICE_RANGE = '¥2,000 - ¥3,000',
    WEBSITE_URL = 'https://www.hotpepper.jp/',
    SEAT_INFO = '매장 내 식사 가능 (테이크아웃 및 배달 서비스 불가)',
    RESERVATION_INFO = '핫페퍼 온라인 예약 및 전화 문의 가능',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/Swell.jpg',
    MENU_NAME = '세계 프리미엄 크래프트 & 보틀 비어 셀렉션',
    MENU_DESCRIPTION = '기린 이치방, 호가든, 독일 정통 흑맥주 등 취향별로 골라 마시는 세계 병맥주',
    MENU_PRICE = '¥1,800',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/Swell menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7430659981;


-- ============================================================
-- 5. 분식 / 길거리 간식 (4개 매장)
-- ============================================================

-- 42. 오코노미야끼 치보 도톤보리빌딩점
UPDATE RESTAURANTS
SET
    NAME = '오코노미야끼 치보 도톤보리빌딩점',
    CATEGORY = '분식 / 길거리 간식',
    TAGS = '오코노미야끼,철판구이,웨이팅맛집',
    DESCRIPTION = '풍미 가득한 일본식 오코노미야끼를 눈앞의 철판에서 구워 즐길 수 있는 전문점',
    ADDRESS = '1 Chome-5-5 Dotonbori, Chuo Ward, Osaka, 542-0071',
    LATITUDE = 34.668500,
    LONGITUDE = 135.503200,
    OPENING_HOURS = '11:00 - 21:30',
    PHONE = '+81 6-6212-2211',
    PRICE_RANGE = '¥1,000 - ¥2,500',
    WEBSITE_URL = 'https://www.chibo.com',
    SEAT_INFO = '50석 (테이블 및 다찌석)',
    RESERVATION_INFO = '전화 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드, 모바일페이',
    LANGUAGES = '한국어 지원 (다국어 키오스크)',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/chibo-okonomiyaki-shop.png',
    MENU_NAME = '믹스 파기야키',
    MENU_DESCRIPTION = '돼지고기와 통새우, 오징어, 송송 썬 파를 듬뿍 넣어 구운 인기 철판 메뉴',
    MENU_PRICE = '¥1,650',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/menu-chibo-okonomiyaki.png',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE (NAME LIKE '%치보%' OR NAME LIKE '%Chibo%') AND ROWNUM = 1;

-- 44. 히로시마풍 오코노미야키 플라자
UPDATE RESTAURANTS
SET
    NAME = '히로시마풍 오코노미야키 플라자',
    CATEGORY = '분식 / 길거리 간식',
    TAGS = '히가시미쿠니,히로시마풍,철판구이,야키소바,오코노미야키',
    DESCRIPTION = '양배추와 면, 계란을 겹겹이 쌓아 올려 철판에서 푸짐하게 구워내는 정통 히로시마풍 오코노미야키 전문점',
    ADDRESS = '1 Chome-1-2 Higashimikuni, Yodogawa Ward, Osaka, 532-0002',
    LATITUDE = 34.7402120,
    LONGITUDE = 135.5011452,
    OPENING_HOURS = '11:00 - 22:00',
    PHONE = '+81 6-6395-3312',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '철판 카운터석, 테이블석 (매장 식사, 테이크아웃, 배달 서비스 가능)',
    RESERVATION_INFO = '온라인 주문 및 현장 이용',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/히로시마풍 오코노미야키 플라자.jpg',
    MENU_NAME = '히로시마풍 스페셜 오코노미야키',
    MENU_DESCRIPTION = '양배추와 쫄깃한 소바면, 계란을 층층이 쌓아 구운 정통 히로시마풍 철판 요리',
    MENU_PRICE = '¥1,100',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/히로시마풍 오코노미야키 플라자 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7426338035;


-- ============================================================
-- 6. 아시안 / 카레 (3개 매장)
-- ============================================================

-- 45. 리카쇼쿠도 텐마본점
UPDATE RESTAURANTS
SET
    NAME = '리카쇼쿠도 텐마본점',
    CATEGORY = '아시안 / 카레',
    TAGS = '텐마맛집,오사카카레,일본식카레,텐진바시,로컬맛집',
    DESCRIPTION = '진하고 깊은 풍미의 특제 루와 다양한 토핑이 어우러진 텐진바시 상점가의 인기 일본식 카레 전문점',
    ADDRESS = 'Nakajima Building, 4 Chome-8-8-15 Tenjinbashi, Kita Ward, Osaka, 530-0041',
    LATITUDE = 34.7049812,
    LONGITUDE = 135.5121345,
    OPENING_HOURS = '10:30 - 21:00',
    PHONE = '+81 6-6358-0787',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://rikasyokudo.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능, 배달 서비스 불가',
    RESERVATION_INFO = '예약 불가',
    PAYMENT_METHODS = '현금 전용 / 전자화폐',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/梨花食堂.jpg',
    MENU_NAME = '치즈 돈카츠 카레',
    MENU_DESCRIPTION = '바삭한 수제 돈카츠 위에 녹아내린 치즈와 깊은 풍미의 일본식 카레 루를 얹은 메뉴',
    MENU_PRICE = '¥1,100',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/梨花食堂.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 2309355080;

-- 46. 다이아몬드 비리야니
UPDATE RESTAURANTS
SET
    NAME = '다이아몬드 비리야니',
    CATEGORY = '아시안 / 카레',
    TAGS = '나카츠맛집,비리야니,인도요리,솥밥비리야니,스파이스카레',
    DESCRIPTION = '한 솥씩 정성껏 지어내는 정통 인도식 솥밥 비리야니와 다채로운 향신료 반찬을 맛볼 수 있는 전문점',
    ADDRESS = '3 Chome-17-2 Nakatsu, Kita Ward, Osaka, 531-0071',
    LATITUDE = 34.7111245,
    LONGITUDE = 135.4935412,
    OPENING_HOURS = '11:00 - 21:30',
    PHONE = '+81 6-6225-7181',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://ja-jp.facebook.com/',
    SEAT_INFO = '매장 내 식사 및 테이크아웃 가능 (배달 불가)',
    RESERVATION_INFO = '방문 순서대로 안내',
    PAYMENT_METHODS = '현금, 신용카드, 모바일 결제',
    LANGUAGES = '일본어, 영어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/osaka castle/DIAMOND BIRYANI.jpg',
    MENU_NAME = '특제 철솥 치킨 비리야니 정식',
    MENU_DESCRIPTION = '바스마티 쌀과 향신료, 치킨을 무쇠솥에 직접 지어 카레를 곁들여 먹는 인도 정식',
    MENU_PRICE = '¥1,480',
    MENU_IMAGE_URL = '/images/food-img/osaka castle/DIAMOND BIRYANI menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7474703633;

-- 47. 카페 팬즈
UPDATE RESTAURANTS
SET
    NAME = '카페 팬즈',
    CATEGORY = '카레',
    TAGS = '주소카레,테이크아웃,배달카레,스파이스카레,가성비',
    DESCRIPTION = '정성껏 우려낸 깊은 풍미의 수제 카레를 테이크아웃과 배달로 편리하게 즐기는 카레 전문 카페',
    ADDRESS = '2 Chome-18-15 Jusomotoimazato, Yodogawa Ward, Osaka, 532-0028',
    LATITUDE = 34.7199412,
    LONGITUDE = 135.4801245,
    OPENING_HOURS = '11:00 - 20:00',
    PHONE = '+81 80-8534-2102',
    PRICE_RANGE = '¥800 - ¥1,500',
    WEBSITE_URL = 'http://cafefans-curry.com/',
    SEAT_INFO = '테이크아웃 및 비대면 배달 전용 (매장 내 식사 공간 확인 요망)',
    RESERVATION_INFO = '웹사이트 및 전화 주문 가능',
    PAYMENT_METHODS = '현금, 모바일페이, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/cafe fans.jpg',
    MENU_NAME = '팬즈 특제 스파이스 비프 카레',
    MENU_DESCRIPTION = '오랜 시간 푹 끓여 부드러운 소고기와 알싸한 향신료 풍미가 도는 시그니처 카레',
    MENU_PRICE = '¥950',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/cafe fans menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7456881887;


-- ============================================================
-- 7. 파인다이닝 / 코스 요리 (2개 매장)
-- ============================================================

-- 48. 우츠보혼마치 가쿠
UPDATE RESTAURANTS
SET
    NAME = '우츠보혼마치 가쿠',
    CATEGORY = '파인다이닝 / 코스 요리',
    TAGS = '파인다이닝,오마카세,가이세키,미식,우츠보공원맛집',
    DESCRIPTION = '제철 식재료 본연의 맛을 정갈하고 섬세하게 선보이는 우츠보공원 인근의 정통 일식 파인다이닝',
    ADDRESS = 'Honmachi Kuiba Bldg, 1 Chome-14-15 Utsubohonmachi, Nishi Ward, Osaka, 550-0004',
    LATITUDE = 34.6865123,
    LONGITUDE = 135.4981456,
    OPENING_HOURS = '17:00 - 23:00',
    PHONE = '+81 6-6479-3459',
    PRICE_RANGE = '¥10,000+',
    WEBSITE_URL = 'http://utsubo-gaku.com/',
    SEAT_INFO = '카운터석, 테이블석 (매장 내 식사만 가능, 테이크아웃/배달 불가)',
    RESERVATION_INFO = '사전 예약 필수 (온라인 예약 가능)',
    PAYMENT_METHODS = '신용카드, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/靭本町がく.jpg',
    MENU_NAME = '계절 가이세키 오마카세 코스',
    MENU_DESCRIPTION = '신선한 사시미와 제철 식재료 본연의 맛을 정갈하게 담아낸 일본식 가이세키 코스',
    MENU_PRICE = '¥12,000',
    MENU_IMAGE_URL = '/images/food-img/usj jp/靭本町がく.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 5623231721;

-- 50. 치로리 (Chirori / おうち居酒屋ちろり)
UPDATE RESTAURANTS
SET
    NAME = '치로리',
    CATEGORY = '바 / 펍 / 이자카야',
    TAGS = '키타구맛집,텐진니시마치,이자카야,가정식주점,사케,심야식당',
    DESCRIPTION = '텐진니시마치 골목 후지이 빌딩 1층에서 정갈한 수제 안주와 술을 편안하게 즐기는 가정식 이자카야',
    ADDRESS = '1F Fujii Bldg, 7-16 Tenjin Nishimachi, Kita Ward, Osaka, 530-0045',
    LATITUDE = 34.6982415,
    LONGITUDE = 135.5102541,
    OPENING_HOURS = '17:00 - 23:00',
    PHONE = '+81 6-6363-8088',
    PRICE_RANGE = '¥2,000 - ¥3,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '매장 내 식사 가능 (테이크아웃 및 배달 불가)',
    RESERVATION_INFO = '전화 문의 및 예약 가능',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/Chirori.jpg',
    MENU_NAME = '치로리 특선 오반자이 & 제철 안주 세트',
    MENU_DESCRIPTION = '정갈하게 차려낸 사시미 대표 안주 세트',
    MENU_PRICE = '¥1,500',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/Chirori menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7475686974;

SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%蜜家珈琲店%')
ORDER BY OSM_ID;

UPDATE RESTAURANTS
SET
    NAME = '미츠야 커피점 아베노 큐즈몰점',
    CATEGORY = '카페 / 디저트',
    TAGS = '아베노,큐즈몰,핸드드립,커피전문점,디저트,폐업',
    DESCRIPTION = '아베노 큐즈몰 지하 1층에서 향긋한 커피와 디저트를 선보였던 카페',
    ADDRESS = 'B1F, Abeno Q''s Mall, 1 Chome-6-1 Abenosuji, Abeno Ward, Osaka, 545-0052',
    LATITUDE = 34.6448120,
    LONGITUDE = 135.5126140,
    OPENING_HOURS = '폐업',
    PHONE = '+81 6-6536-8814',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'http://mitsuya.co.jp/',
    SEAT_INFO = '테이블석 (영업 종료로 이용 불가)',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '현금, 신용카드, 전자화폐',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/shinsaibashi mitsuya.jpg',
    MENU_NAME = '미츠야 하우스 블렌드 커피 & 디저트',
    MENU_DESCRIPTION = '부드러운 바디감의 오리지널 블렌드 커피와 달콤한 수제 디저트',
    MENU_PRICE = '¥650',
    MENU_IMAGE_URL = '/images/food-img/usj jp/shinsaibashi mitsuya menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 9317477404;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 9317477404;


SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%めがね製作所 カフェ 藍丸%')
ORDER BY OSM_ID;

-- 아이마루 메가네 카페 (폐업)
UPDATE RESTAURANTS
SET
    NAME = '아이마루 메가네 카페',
    CATEGORY = '카페 / 디저트',
    TAGS = '나카자키초,안경공방,테마카페,이색카페,디저트,폐업',
    DESCRIPTION = '안경 제작 공방과 아늑한 카페 공간이 어우러졌던 나카자키초의 이색 테마 카페',
    ADDRESS = '1 Chome-7-10 Nakazakinishi, Kita Ward, Osaka, 530-0015',
    LATITUDE = 34.7061450,
    LONGITUDE = 135.5039840,
    OPENING_HOURS = '폐업',
    PHONE = '+81 6-4980-2937',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'http://aimaru-megane-cafe.com/',
    SEAT_INFO = '카운터석, 테이블석 (영업 종료로 이용 불가)',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/aimaru.jpg',
    MENU_NAME = '수제 드립 커피 & 홈메이드 스위츠',
    MENU_DESCRIPTION = '정성스럽게 내린 핸드드립 커피와 달콤하고 부드러운 수제 케이크',
    MENU_PRICE = '¥800',
    MENU_IMAGE_URL = '/images/food-img/usj jp/aimaru menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7477432357;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 7477432357;


SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%スタンドカフェバー　FAT MOTHER%')
ORDER BY OSM_ID;

-- 팻 마더
UPDATE RESTAURANTS
SET
    NAME = '팻 마더',
    CATEGORY = '바 / 펍 / 이자카야',
    TAGS = '주소카페,심야카페,다이닝바,펍,주소역,분위기좋은',
    DESCRIPTION = '주소히가시 골목에서 늦은 밤부터 편안한 분위기에 음료와 주류를 즐길 수 있는 심야 다이닝 카페 겸 바',
    ADDRESS = '2 Chome-4-20 Jusohigashi, Yodogawa Ward, Osaka, 532-0023',
    LATITUDE = 34.7212450,
    LONGITUDE = 135.4839840,
    OPENING_HOURS = '21:00 - 03:00',
    PHONE = '+81 80-7024-9318',
    PRICE_RANGE = '¥1,000 - ¥2,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사, 테이크아웃, 배달 서비스 가능',
    RESERVATION_INFO = '인스타그램 DM 또는 전화 문의',
    PAYMENT_METHODS = '현금, 신용카드, 모바일 결제',
    LANGUAGES = '일본어, 영어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/fat.jpg',
    MENU_NAME = '하우스 칵테일 & 핑거푸드 플래터',
    MENU_DESCRIPTION = '가볍게 즐기기 좋은 시그니처 칵테일과 짭조름한 스낵 안주 세트',
    MENU_PRICE = '¥1,200',
    MENU_IMAGE_URL = '/images/food-img/usj jp/fat menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7473311049;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 7473311049;


SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%四季旬菜むら田%')
ORDER BY OSM_ID;

-- 시키슌사이 무라타
UPDATE RESTAURANTS
SET
    NAME = '시키슌사이 무라타 (四季旬菜 むら田)',
    CATEGORY = '일식 / 면 요리 / 스시',
    TAGS = '주소맛집,제철요리,일식주점,사케,계절생선회,모임장소',
    DESCRIPTION = '사계절 제철 생선회와 엄선된 신선한 채소 요리를 정갈하게 선보이는 주소역 인근 일식 주점',
    ADDRESS = '1 Chome-17-17 Jusohigashi, Yodogawa Ward, Osaka, 532-0023',
    LATITUDE = 34.7188120,
    LONGITUDE = 135.4851240,
    OPENING_HOURS = '17:00 - 23:00',
    PHONE = '+81 6-6770-9777',
    PRICE_RANGE = '¥5,000 - ¥6,000',
    WEBSITE_URL = 'https://www.instagram.com/',
    SEAT_INFO = '매장 내 식사 가능 (배달 서비스 불가)',
    RESERVATION_INFO = '전화 예약 권장',
    PAYMENT_METHODS = '현금, 신용카드',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/dotonbori/四季旬菜 むら田.jpg',
    MENU_NAME = '제철 모둠 사시미 5종',
    MENU_DESCRIPTION = '산지 직송 제철 생선 본연의 신선함과 기름진 맛을 담아낸 모둠 생선회',
    MENU_PRICE = '¥2,800',
    MENU_IMAGE_URL = '/images/food-img/dotonbori/四季旬菜 むら田 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 7413224976;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 7413224976;


SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%喫茶あおい%')
ORDER BY OSM_ID;

-- 킷사 아오이
UPDATE RESTAURANTS
SET
    NAME = 'Aoi (킷사 아오이 / 喫茶あおい)',
    CATEGORY = '카페 / 디저트',
    TAGS = '니시아와지,킷사텐,핸드드립,레트로카페,히가시요도가와,모닝세트',
    DESCRIPTION = '히가시요도가와구 니시아와지 주택가에서 차분하고 레트로한 무드로 커피를 음미할 수 있는 클래식 킷사텐',
    ADDRESS = '1F, MURAKAMI Mansion, 1 Chome-17-3 Nishiawaji, Higashiyodogawa Ward, Osaka, 533-0031',
    LATITUDE = 34.7391240,
    LONGITUDE = 135.5061450,
    OPENING_HOURS = '11:30 - 19:00',
    PHONE = '+81 90-1222-0237',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = 'https://kissaaoiclub.com/',
    SEAT_INFO = '카운터석, 테이블석 (매장 내 식사 가능, 배달 서비스 불가)',
    RESERVATION_INFO = '현장 방문',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어 메뉴',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/aoi.jpg',
    MENU_NAME = '아오이 클래식 블렌드 커피 & 토스트',
    MENU_DESCRIPTION = '정통 방식으로 진하게 추출한 드립 커피와 노릇노릇 구워낸 버터 토스트',
    MENU_PRICE = '¥650',
    MENU_IMAGE_URL = '/images/food-img/usj jp/aoi menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 10044742347;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 10044742347;


SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANTS
WHERE UPPER(NAME) LIKE UPPER('%珈琲家%')
ORDER BY OSM_ID;

-- 커피야 (珈琲家 / 폐업)
UPDATE RESTAURANTS
SET
    NAME = '커피야',
    CATEGORY = '카페 / 디저트',
    TAGS = '히가시스미요시,쿠와즈,킷사텐,핸드드립,레트로카페,폐업',
    DESCRIPTION = '히가시스미요시구 쿠와즈 나카가와 맨션 1층에서 정갈한 커피를 선보였던 클래식 킷사텐',
    ADDRESS = 'Nakagawa Mansion, 3 Chome-1-6 Kuwazu, Higashisumiyoshi Ward, Osaka, 546-0041',
    LATITUDE = 34.6402450,
    LONGITUDE = 135.5301840,
    OPENING_HOURS = '폐업',
    PHONE = '+81 6-6719-0102',
    PRICE_RANGE = '¥1 - ¥1,000',
    WEBSITE_URL = NULL,
    SEAT_INFO = '카운터석, 테이블석 (영업 종료로 이용 불가)',
    RESERVATION_INFO = '영업 종료로 인한 이용 불가',
    PAYMENT_METHODS = '현금 전용',
    LANGUAGES = '일본어',
    RATING = NULL,
    REVIEW_COUNT = NULL,
    MAIN_IMAGE_URL = '/images/store-img/usj jp/커피야.jpg',
    MENU_NAME = '커피야 클래식 드립 커피 & 토스트',
    MENU_DESCRIPTION = '정성스럽게 내린 클래식 드립 커피와 바삭한 모닝 토스트',
    MENU_PRICE = '¥500',
    MENU_IMAGE_URL = '/images/food-img/usj jp/커피야 menu.jpg',
    IS_PUBLISHED = 'Y',
    UPDATED_AT = SYSTIMESTAMP
WHERE OSM_ID = 10591126304;

SELECT
    RESTAURANT_ID, OSM_ID, NAME, CATEGORY,
    ADDRESS, LATITUDE, LONGITUDE,
    OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL,
    MENU_NAME, MENU_PRICE,
    MAIN_IMAGE_URL, MENU_IMAGE_URL,
    IS_PUBLISHED, UPDATED_AT
FROM RESTAURANTS
WHERE OSM_ID = 10591126304;


-- ============================================================
-- 최종 COMMIT
-- ============================================================
COMMIT;
SET DEFINE ON;

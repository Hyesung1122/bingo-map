SET SERVEROUTPUT ON
SET DEFINE OFF
SET VERIFY OFF

PROMPT ===== 49개 맛집 데이터 일괄 UPDATE 시작 =====

-- [데이터 1] '타코야끼 쿠쿠루 본점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집',
    ADDRESS          = '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−10−5 白亜ビル １階',
    OPENING_HOURS    = '10:30 - 21:30',
    PRICE_RANGE      = '¥500 - ¥1,500',
    MENU_NAME        = '타코야끼 (8개)',
    MENU_DESCRIPTION = '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴',
    MENU_PRICE       = '¥1,080',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/kukuru-takoyaki-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '타코야끼 쿠쿠루 본점';

-- [데이터 2] '호젠지 산페이'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점',
    ADDRESS          = '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−7−9 横丁ビル 日宝 1F',
    OPENING_HOURS    = '17:00 - 23:00',
    PRICE_RANGE      = '¥700 - ¥1,200',
    MENU_NAME        = '소 힘줄・파・곤약 야끼소바',
    MENU_DESCRIPTION = '진한 특제 소스와 쫄깃한 면발의 조화',
    MENU_PRICE       = '¥1,650',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/hochenji-yakisoba-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '호젠지 산페이';

-- [데이터 3] '오코노미야끼 치보 도톤보리빌딩점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장',
    ADDRESS          = '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−5−5 千房道頓堀ビル1～6F',
    OPENING_HOURS    = '11:00 - 21:30',
    PRICE_RANGE      = '¥1,000 - ¥2,500',
    MENU_NAME        = '믹스 파기야키',
    MENU_DESCRIPTION = '새우, 오징어, 돼지고기, 파가 모두 들어간 베스트 메뉴',
    MENU_PRICE       = '¥1,650',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/chibo-okonomiyaki-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '오코노미야끼 치보 도톤보리빌딩점';

-- [데이터 4] '나루토 타이야키 본점 센니치마에 아이조바시점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일본산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵',
    ADDRESS          = '1 Chome-4-10 Sennichimae, Chuo Ward, Osaka, 542-0074',
    OPENING_HOURS    = '11:00 - 05:00',
    PRICE_RANGE      = '¥300 - ¥600',
    MENU_NAME        = '통단팥 붕어빵',
    MENU_DESCRIPTION = '달콤하고 부드러운 팥이 꽉 찬 인기 간식',
    MENU_PRICE       = '¥300',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/naruto-taiyaki-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '나루토 타이야키 본점 센니치마에 아이조바시점';

-- [데이터 5] '호타루(쿠시카츠)'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일식 꼬치 및 튀김 전문점. 아늑하고 편안한 분위기에서 즐기는 정통 쿠시카츠',
    ADDRESS          = '3 Chome-3-3 Namba, Chuo Ward, Osaka, 542-0076 일본',
    OPENING_HOURS    = '12:00 - 22:30',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '모둠 쿠시카츠 세트',
    MENU_DESCRIPTION = '바삭하게 튀겨낸 다양한 수제 꼬치 세트',
    MENU_PRICE       = '¥2,500',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/hotaru-kushikatsu-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '호타루(쿠시카츠)';

-- [데이터 6] '오뎅야'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '깊고 진한 국물의 정통 어묵 전문 식당. 아늑한 분위기에서 즐기는 수제 오뎅과 술 한잔',
    ADDRESS          = '1 Chome-3-1 2 F, Dotonbori, Chuo Ward, Osaka 542-0071',
    OPENING_HOURS    = '금요일 오후 5:00에 영업 시작',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '모둠 오뎅 세트',
    MENU_DESCRIPTION = '부드럽게 우려낸 육수에 무, 스지, 각종 수제 어묵이 들어간 세트',
    MENU_PRICE       = '¥1,800',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/odenya-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '오뎅야';

-- [데이터 7] '아카오니 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '생문어를 사용해 신선한 맛을 유지하는 것으로 유명한 타코야끼 명가. 2016~2018년 미쉐린 가이드 3년 연속 소개.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '10:00 - 22:00',
    PRICE_RANGE      = '¥500 - ¥900',
    MENU_NAME        = '아카오니 타코야끼 (8개)',
    MENU_DESCRIPTION = '생문어를 큼직하게 넣은 시그니처 타코야끼',
    MENU_PRICE       = '¥750',
    MAIN_IMAGE_URL   = '/images/food-takoyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '아카오니 도톤보리점';

-- [데이터 8] '코가류 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '크기는 작지만 부드러운 식감과 저렴한 가격으로 유명한 타코야끼 전문점. 파를 듬뿍 올려 먹는 것이 포인트.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '10:00 - 21:00',
    PRICE_RANGE      = '¥400 - ¥700',
    MENU_NAME        = '소스마요 타코야끼 (8개)',
    MENU_DESCRIPTION = '소스와 마요네즈의 조화가 좋은 인기 메뉴',
    MENU_PRICE       = '¥500',
    MAIN_IMAGE_URL   = '/images/food-takoyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '코가류 도톤보리점';

-- [데이터 9] '오도리다코'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '타코야끼 1개마다 주꾸미를 통째로 넣어 SNS에서 화제가 된 곳. 소스/간장/암염 맛 선택 가능.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-8-26',
    OPENING_HOURS    = '11:00 - 21:00',
    PRICE_RANGE      = '¥600 - ¥1,200',
    MENU_NAME        = '오도리다코 타코야끼 (4개)',
    MENU_DESCRIPTION = '주꾸미 한 마리가 통째로 들어간 시그니처 메뉴',
    MENU_PRICE       = '¥600',
    MAIN_IMAGE_URL   = '/images/food-takoyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '오도리다코';

-- [데이터 10] '미즈노 도톤보리 본점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '오랜 역사를 자랑하는 오코노미야끼 노포. 야마이모(참마)를 넣어 폭신한 식감이 특징.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-4-15',
    OPENING_HOURS    = '11:00 - 22:00 (목요일 휴무)',
    PRICE_RANGE      = '¥1,200 - ¥2,500',
    MENU_NAME        = '야마이모야키',
    MENU_DESCRIPTION = '참마를 듬뿍 넣어 폭신하게 구운 미즈노 대표 메뉴',
    MENU_PRICE       = '¥1,800',
    MAIN_IMAGE_URL   = '/images/food-okonomiyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '미즈노 도톤보리 본점';

-- [데이터 11] '앗치치 혼포'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일반 구리 철판 대신 전문 조리 기술이 필요한 특수 철판을 사용하는 타코야끼 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '10:00 - 21:00',
    PRICE_RANGE      = '¥500 - ¥900',
    MENU_NAME        = '네기 타코야끼',
    MENU_DESCRIPTION = '파를 듬뿍 올린 달콤한 소스의 타코야끼',
    MENU_PRICE       = '¥600',
    MAIN_IMAGE_URL   = '/images/food-takoyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '앗치치 혼포';

-- [데이터 12] '주하치방 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '텐카스(튀김 부스러기)를 가득 넣어 바삭한 식감을 강조한 오사카 오랜 타코야끼 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 20:00',
    PRICE_RANGE      = '¥400 - ¥800',
    MENU_NAME        = '텐카스 타코야끼',
    MENU_DESCRIPTION = '텐카스를 가득 넣어 겉이 유난히 바삭한 타코야끼',
    MENU_PRICE       = '¥550',
    MAIN_IMAGE_URL   = '/images/food-takoyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '주하치방 도톤보리점';

-- [데이터 13] 'CREO-RU 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '오사카 3대 명물(타코야끼·오코노미야끼·쿠시카츠)을 한 곳에서 즐길 수 있는 120석 규모의 대형 매장.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥1,000 - ¥3,000',
    MENU_NAME        = '7종 반죽 타코야끼',
    MENU_DESCRIPTION = '7가지 가루를 혼합한 반죽으로 만든 겉바속촉 타코야끼',
    MENU_PRICE       = '¥900',
    MAIN_IMAGE_URL   = '/images/food-okonomiyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = 'CREO-RU 도톤보리점';

-- [데이터 14] '츠루하시 후게쓰 도톤보리 에비스바시점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '테이블마다 철판이 있어 눈앞에서 구워주는 오코노미야끼로 유명한 인기 이자카야 체인.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '부타타마 오코노미야끼',
    MENU_DESCRIPTION = '돼지고기와 계란이 들어간 대표 오코노미야끼',
    MENU_PRICE       = '¥1,050',
    MAIN_IMAGE_URL   = '/images/food-okonomiyaki.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '츠루하시 후게쓰 도톤보리 에비스바시점';

-- [데이터 15] '킹에몬 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '나니와 최강 간장 라멘으로 유명한 24시간 영업 라멘 전문점. 흑간장 스프에 해산물 감칠맛이 특징.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-4-17',
    OPENING_HOURS    = '11:00 - 익일 08:00',
    PRICE_RANGE      = '~¥1,000',
    MENU_NAME        = '킹에몬 흑간장 라멘',
    MENU_DESCRIPTION = '간장 풍미와 신선한 해산물이 어우러진 흑간장 라멘',
    MENU_PRICE       = '¥890',
    MAIN_IMAGE_URL   = '/images/food-ramen.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '킹에몬 도톤보리점';

-- [데이터 16] '킨류 라멘 도톤보리 본점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '주홍색 외벽과 거대한 용 오브제로 유명한 도톤보리의 랜드마크 라멘집. 진한 돈코츠 스프가 특징.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '24시간 영업',
    PRICE_RANGE      = '¥700 - ¥1,000',
    MENU_NAME        = '킨류 라멘',
    MENU_DESCRIPTION = '진한 돈코츠 스프에 부추와 마늘을 곁들이는 대표 메뉴',
    MENU_PRICE       = '¥800',
    MAIN_IMAGE_URL   = '/images/food-ramen.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '킨류 라멘 도톤보리 본점';

-- [데이터 17] '시센노 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '진한 미소(된장) 라멘으로 유명한 라멘 격전구 도톤보리의 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥800 - ¥1,100',
    MENU_NAME        = '시센노 미소라멘',
    MENU_DESCRIPTION = '진하고 깊은 맛의 미소 베이스 라멘',
    MENU_PRICE       = '¥950',
    MAIN_IMAGE_URL   = '/images/food-ramen.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '시센노 도톤보리점';

-- [데이터 18] '나니와 멘지로'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '2019년 오픈 이후 라멘 마니아의 성지가 된 곳. 조개 육수 베이스의 황금 조개 라멘이 대표 메뉴.',
    ADDRESS          = '오사카부 오사카시 주오구 난바',
    OPENING_HOURS    = '11:00 - 21:00',
    PRICE_RANGE      = '¥900 - ¥1,300',
    MENU_NAME        = '황금 조개 라멘',
    MENU_DESCRIPTION = '조개 육수 베이스의 투명한 황금빛 라멘',
    MENU_PRICE       = '¥1,050',
    MAIN_IMAGE_URL   = '/images/food-ramen.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '나니와 멘지로';

-- [데이터 19] '쿠시카츠 다루마 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '거대한 아저씨 간판으로 유명한 쿠시카츠 전문점. "두 번 찍기 금지"라는 오사카식 룰로도 유명.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 22:30',
    PRICE_RANGE      = '¥100 - ¥300 (꼬치 1개)',
    MENU_NAME        = '쿠시카츠 모둠 (10개)',
    MENU_DESCRIPTION = '소고기, 새우, 채소 등 다양한 재료의 꼬치튀김 모둠',
    MENU_PRICE       = '¥1,500',
    MAIN_IMAGE_URL   = '/images/food-kushikatsu.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '쿠시카츠 다루마 도톤보리점';

-- [데이터 20] '이치란 라멘 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일본을 대표하는 돈코츠 라멘 체인점. 1인 칸막이 좌석과 나만의 맛 주문표가 특징.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '24시간 영업',
    PRICE_RANGE      = '¥900 - ¥1,300',
    MENU_NAME        = '이치란 라멘',
    MENU_DESCRIPTION = '나만의 맛 주문표로 커스텀하는 돈코츠 라멘',
    MENU_PRICE       = '¥980',
    MAIN_IMAGE_URL   = '/images/food-ramen.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '이치란 라멘 도톤보리점';

-- [데이터 21] '카니도라쿠 도톤보리 본점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '다리가 움직이는 대형 게 간판으로 도톤보리를 상징하는 게요리 전문점. 회, 샤브샤브, 초밥 등 제공.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-6-18',
    OPENING_HOURS    = '11:00 - 22:00',
    PRICE_RANGE      = '¥3,000 - ¥10,000',
    MENU_NAME        = '게 코스 요리',
    MENU_DESCRIPTION = '바다참게·킹크랩·털게 중 선택하는 게 코스',
    MENU_PRICE       = '¥5,500',
    MAIN_IMAGE_URL   = '/images/food-crab.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '카니도라쿠 도톤보리 본점';

-- [데이터 22] '가무쿠라 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '가볍게 즐길 수 있는 테이크아웃 디저트/간식 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-7-25',
    OPENING_HOURS    = '10:00 - 20:00',
    PRICE_RANGE      = '¥300 - ¥700',
    MENU_NAME        = '시그니처 디저트 세트',
    MENU_DESCRIPTION = '가게 대표 디저트 메뉴',
    MENU_PRICE       = '¥450',
    MAIN_IMAGE_URL   = '/images/food-dessert.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '가무쿠라 도톤보리점';

-- [데이터 23] '마루요시 스시'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '난바 근처 사쿠라가와 지역의 가성비 좋은 초밥 세트 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 사쿠라가와',
    OPENING_HOURS    = '11:30 - 21:00',
    PRICE_RANGE      = '¥1,500 -',
    MENU_NAME        = '초밥 세트',
    MENU_DESCRIPTION = '저렴한 가격의 초밥 모둠 세트',
    MENU_PRICE       = '¥1,500',
    MAIN_IMAGE_URL   = '/images/food-sushi.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '마루요시 스시';

-- [데이터 24] '우오신 스시 미나미점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '보통 초밥의 세 배 크기 생선이 올라간 큼직한 초밥으로 유명한 전문점.',
    ADDRESS          = '오사카부 오사카시 주오구 난바',
    OPENING_HOURS    = '11:00 - 22:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '아나고 엔니기리',
    MENU_DESCRIPTION = '부드러운 붕장어에 구수한 소스를 곁들인 초밥',
    MENU_PRICE       = '¥600',
    MAIN_IMAGE_URL   = '/images/food-sushi.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '우오신 스시 미나미점';

-- [데이터 25] '스시로 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '도톤보리 한가운데 위치한 인기 회전초밥 체인점. 신선한 해산물과 합리적인 가격이 강점.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리 1-7-21',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥110 - ¥500 (접시당)',
    MENU_NAME        = '모둠 초밥 세트',
    MENU_DESCRIPTION = '마구로, 사케, 하마치, 에비 등 인기 메뉴 모둠',
    MENU_PRICE       = '¥980',
    MAIN_IMAGE_URL   = '/images/food-sushi.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '스시로 도톤보리점';

-- [데이터 26] '다이키 수산 회전초밥 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '오사카 대표 회전초밥 체인. 다국어 메뉴 제공으로 외국인 관광객에게 인기.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 22:00',
    PRICE_RANGE      = '¥100 - ¥400 (접시당)',
    MENU_NAME        = '참치·새우 모둠',
    MENU_DESCRIPTION = '참치, 새우(2개 100엔)부터 즐기는 인기 모둠',
    MENU_PRICE       = '¥600',
    MAIN_IMAGE_URL   = '/images/food-sushi.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '다이키 수산 회전초밥 도톤보리점';

-- [데이터 27] '하리주 카레'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '메이지 시대에 창업한 오사카 전통 카레 전문점. 일본 최초로 계란을 카레에 올린 곳으로 알려짐.',
    ADDRESS          = '오사카부 오사카시 주오구 난바 3-1-34',
    OPENING_HOURS    = '11:00 - 20:00 (월요일 휴무)',
    PRICE_RANGE      = '¥900 - ¥1,500',
    MENU_NAME        = '다마고 카레',
    MENU_DESCRIPTION = '일본 최초로 계란을 올린 시그니처 카레',
    MENU_PRICE       = '¥1,100',
    MAIN_IMAGE_URL   = '/images/food-curry.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '하리주 카레';

-- [데이터 28] '오사카 오쇼 도톤보리점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '오사카에서 인기 있는 교자(만두) 전문 중화요리 체인점. 도톤보리 매장은 큰 간판으로도 유명.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥700 - ¥1,500',
    MENU_NAME        = '야끼교자 (6개)',
    MENU_DESCRIPTION = '겉바속촉 육즙 가득한 오사카 오쇼 대표 만두',
    MENU_PRICE       = '¥250',
    MAIN_IMAGE_URL   = '/images/food-gyoza.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '오사카 오쇼 도톤보리점';

-- [데이터 29] '도톤보리 이마이'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '70년 이상의 역사를 자랑하는 오사카 우동 노포. 큼직한 유부를 올린 기츠네 우동이 간판 메뉴.',
    ADDRESS          = '오사카부 오사카시 주오구 도톤보리',
    OPENING_HOURS    = '11:00 - 22:00',
    PRICE_RANGE      = '¥900 - ¥1,500',
    MENU_NAME        = '기츠네 우동',
    MENU_DESCRIPTION = '홋카이도 다시마와 규슈 가다랑어포로 우려낸 국물의 유부우동',
    MENU_PRICE       = '¥1,050',
    MAIN_IMAGE_URL   = '/images/food-udon.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '도톤보리 이마이';

-- [데이터 30] '규카츠 모토무라 난바점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일본 각지에 체인을 둔 규카츠(소고기 커틀릿) 전문점 중 가장 인기 있는 난바점. 화로에 직접 구워 먹는 방식.',
    ADDRESS          = '오사카부 오사카시 주오구 난바',
    OPENING_HOURS    = '10:45 - 22:00',
    PRICE_RANGE      = '¥1,300 - ¥2,200',
    MENU_NAME        = '규카츠 정식',
    MENU_DESCRIPTION = '개인 화로에 취향껏 구워 먹는 소고기 커틀릿 정식',
    MENU_PRICE       = '¥1,780',
    MAIN_IMAGE_URL   = '/images/food-gyukatsu.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '규카츠 모토무라 난바점';

-- [데이터 31] '아부리야우메다점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '법, 채소와 함께 고기를 테이블에서 무한 리필로 구워 먹을 수 있는 편안한 식당입니다.',
    ADDRESS          = '일본 〒530-0057 Osaka, Kita Ward, Sonezaki, 2 Chome−15−20 SWINGうめだ 4階',
    OPENING_HOURS    = '11:00 - 24:00',
    PRICE_RANGE      = '¥5,000 - ¥8,000',
    MENU_NAME        = '국산규 야키니쿠 무한리필 코스',
    MENU_DESCRIPTION = '엄선된 소고기 구이 및 다양한 사이드 메뉴 무한리필',
    MENU_PRICE       = '¥6,500',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/couse-aburiya-low-kokusangyu-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '아부리야우메다점';

-- [데이터 32] '불고기 잭 우메다점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '야키니쿠 전문식당. 질 좋은 고기를 합리적인 가격에 즐길 수 있는 인기 매장.',
    ADDRESS          = '일본 〒530-0027 Osaka, Kita Ward, Doyamacho, 2-11 MKビートビル 3F',
    OPENING_HOURS    = '16:00 - 24:00',
    PRICE_RANGE      = '¥4,000 - ¥6,000',
    MENU_NAME        = '잭 프리미엄 세트',
    MENU_DESCRIPTION = '다양한 부위의 소고기를 맛볼 수 있는 모둠 세트',
    MENU_PRICE       = '¥4,980',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/bulgogi-jack-umeda-branch-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '불고기 잭 우메다점';

-- [데이터 33] '규카츠 교토가츠규 우메다점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '겉은 바삭하고 속은 촉촉한 부드러운 소고기 규카츠 전문점',
    ADDRESS          = '일본 〒530-0012 Osaka, Kita Ward, Shibata, 1 Chome−1−27 サセウメダビル B1F',
    OPENING_HOURS    = '11:00 - 22:00',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '살치살 규카츠 정식',
    MENU_DESCRIPTION = '특제 보리밥과 다채로운 소스와 함께 즐기는 규카츠 정식',
    MENU_PRICE       = '¥2,079',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/gyukatsu-kyoto-katsukyu-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '규카츠 교토가츠규 우메다점';

-- [데이터 34] '모헤지 우메다 루쿠아점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '철판 위에서 직접 조리해 먹는 독특하고 고소한 맛의 몬자야끼 전문점.',
    ADDRESS          = '10층 루쿠아 오사카, 일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome−1−3 ルクア大阪 10階',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '명란 명태알 몬자야끼',
    MENU_DESCRIPTION = '명란과 모짜렐라 치즈가 듬뿍 들어간 베스트 몬자야끼',
    MENU_PRICE       = '¥1,580',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/moheji-umeda-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '모헤지 우메다 루쿠아점';

-- [데이터 35] '하카타 모츠나베 오오야마 오사카역점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '진한 된장 베이스 육수와 고소한 소곱창이 어우러진 하카타 정통 모츠나베 전문점',
    ADDRESS          = '10층 · 루쿠아1100, 일본 〒530-8558 Osaka, Kita Ward, Umeda, 3 Chome−1−3 ルクアイーレ 10階',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '된장맛 모츠나베 세트',
    MENU_DESCRIPTION = '특제 된장 육수와 엄선된 한우 곱창의 깊은 맛',
    MENU_PRICE       = '¥1,980',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/hakata-motsunabe-ohyama-osaka-station-branch-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '하카타 모츠나베 오오야마 오사카역점';

-- [데이터 36] '스키야키 샤브샤브 츠카다 킷테오사카점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '정갈한 분위기에서 즐기는 고급 스키야키 및 샤브샤브 전문점',
    ADDRESS          = '1층 · 킷테 오사카, 일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome−2−2 KITTE大阪 5F',
    OPENING_HOURS    = '11:00 - 23:00',
    PRICE_RANGE      = '¥2,000 - ¥8,000',
    MENU_NAME        = '특선 스키야키 정식',
    MENU_DESCRIPTION = '달콤 짭조름한 특제 소스에 부드러운 소고기를 익혀 날계란에 찍어 먹는 정식',
    MENU_PRICE       = '¥3,200',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/sukiyaki-shabu-shabu-tsukada-kitage-osaka-branch-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '스키야키 샤브샤브 츠카다 킷테오사카점';

-- [데이터 37] '하나다코'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '문어가 들어간 둥근 반죽을 구워 파와 마요네즈를 얹은 음식인 다코야끼를 파는 식당입니다.',
    ADDRESS          = '일본 〒530-0017 Osaka, Kita Ward, Kakudacho, 9-26 大阪新梅田食道街 1 階',
    OPENING_HOURS    = '10:00 - 21:45',
    PRICE_RANGE      = '¥1 - ¥1,000',
    MENU_NAME        = '네기마요 타코야끼',
    MENU_DESCRIPTION = '알싸한 대파가 산더미처럼 올라간 특제 마요네즈 타코야끼',
    MENU_PRICE       = '¥780',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/hanadako-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '하나다코';

-- [데이터 38] '신세카이 칸칸'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '옛날 느낌의 카운터 주문형 식당으로 풍미 넘치는 재료를 넣어 동그란 모양으로 반죽한 튀김을 선보입니다.',
    ADDRESS          = '3 Chome-5-16 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본',
    OPENING_HOURS    = '9:30 - 18:00',
    PRICE_RANGE      = '¥1 - ¥1,000',
    MENU_NAME        = '타코야끼',
    MENU_DESCRIPTION = '겉은 바삭하고 속은 촉촉한 전통 타코야끼',
    MENU_PRICE       = '¥500',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/takoyaki-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '신세카이 칸칸';

-- [데이터 39] '신세계 꼬치 커틀릿·오코노미 야키 아파레'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일식 꼬치 및 튀김 전문점, 정통 쿠시카츠와 철판요리를 함께 즐길 수 있습니다.',
    ADDRESS          = '2 Chome-5-1 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본',
    OPENING_HOURS    = '11:00 - 02:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '모둠 쿠시카츠 5종',
    MENU_DESCRIPTION = '바삭하게 튀겨낸 신세카이 스타일의 수제 꼬치',
    MENU_PRICE       = '¥1,200',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/kushikatsu-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '신세계 꼬치 커틀릿·오코노미 야키 아파레';

-- [데이터 40] '호르몬 야키니쿠 시치푸쿠'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '쿠시카츠와 숯불 곱창을 포장해 주는 칠복을 전해드립니다!',
    ADDRESS          = '2 Chome-6-21 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본',
    OPENING_HOURS    = '11:30 - 24:00',
    PRICE_RANGE      = '¥1,000 - ¥4,000',
    MENU_NAME        = '호르몬 모둠구이',
    MENU_DESCRIPTION = '신선한 소 곱창과 내장을 숯불에 구워 먹는 대표 메뉴',
    MENU_PRICE       = '¥1,500',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/yakiniku-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '호르몬 야키니쿠 시치푸쿠';

-- [데이터 41] '쿠라스시 신세카이 츠텐카쿠점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '쓰텐카쿠 미나미도리 쇼점가에 위치한 인기 대형 회전초밥 체인점',
    ADDRESS          = '일본 〒556-0002 Osaka, Naniwa Ward, Ebisuhigashi, 2 Chome-6-3 2F',
    OPENING_HOURS    = '영업 중 · 오전 12:00에 영업 종료',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '초밥 접시 세트',
    MENU_DESCRIPTION = '다양한 신선한 초밥과 사이드 메뉴',
    MENU_PRICE       = '¥300 ~ 1,100',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/sushi-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '쿠라스시 신세카이 츠텐카쿠점';

-- [데이터 42] '곤베 호루몬 우동'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '곱창구이 전문점. 진한 국물과 쫄깃한 우동 면발에 고소한 곱창이 어우러진 별미 우동.',
    ADDRESS          = '1 Chome-23-5 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본',
    OPENING_HOURS    = '24:00 - 07:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '호루몬 우동',
    MENU_DESCRIPTION = '특제 소스로 볶아낸 곱창이 듬뿍 들어간 얼큰한 우동',
    MENU_PRICE       = '¥950',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/udon-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '곤베 호루몬 우동';

-- [데이터 43] 'Fumichan'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '다코야끼 전문점. 겉은 바삭하고 속은 부드러운 오사카 정통 길거리 간식.',
    ADDRESS          = '2 Chome-2-8 Ebisunishi, Naniwa Ward, Osaka, 556-0003 일본',
    OPENING_HOURS    = '영업 중 · 오전 12:00에 영업 종료',
    PRICE_RANGE      = '¥1 - ¥1,000',
    MENU_NAME        = '후미찬 타코야끼 (8개)',
    MENU_DESCRIPTION = '가성비 좋은 담백하고 고소한 타코야끼',
    MENU_PRICE       = '¥500',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/fumichan-takoyaki-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = 'Fumichan';

-- [데이터 44] '신세카이 쿠시카츠 잇토쿠 신세카이점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '일식 꼬치 및 튀김 전문점 바삭한 튀김옷과 특제 소스의 조화가 일품인 쿠시카츠 전문점.',
    ADDRESS          = '2 Chome-3-18 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본',
    OPENING_HOURS    = '11:00~23:00',
    PRICE_RANGE      = '¥2,000 - ¥3,000',
    MENU_NAME        = '잇토쿠 모둠 꼬치 세트',
    MENU_DESCRIPTION = '다양한 고기와 채소 튀김을 맛볼 수 있는 세트 메뉴',
    MENU_PRICE       = '¥1,600',
    MAIN_IMAGE_URL   = '/images/store-img/shinsaibashi/shin-kushikatsu-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '신세카이 쿠시카츠 잇토쿠 신세카이점';

-- [데이터 45] '오니기리 고리짱 난바점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '다양한 속재료가 들어간 맛있는 수제 오니기리와 일본 전통 음식을 즐길 수 있는 테이크아웃 전문 맛집.',
    ADDRESS          = '일본 〒542-0081 Osaka, Chuo Ward, Minamisenba, 3 Chome-5-28 富士ビル南船場 1階',
    OPENING_HOURS    = '10:00~21:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '시그니처 명란 오니기리',
    MENU_DESCRIPTION = '특제 소스와 듬뿍 올라간 명란이 조화로운 주먹밥',
    MENU_PRICE       = '¥450',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/onigiri-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '오니기리 고리짱 난바점';

-- [데이터 46] 'Kiiro'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '아늑한 분위기에서 다양한 안주와 주류를 즐길 수 있는 신사이바시 인근의 인기 이자카야.',
    ADDRESS          = 'Neo Minamisenba Bldg., 2 Chome-7-19 Minamisenba, Chuo Ward, Osaka, 542-0081 일본',
    OPENING_HOURS    = '11:30~23:00',
    PRICE_RANGE      = '¥1,000 - ¥1,000',
    MENU_NAME        = '모둠 사시미',
    MENU_DESCRIPTION = '신선한 제철 해산물을 맛볼 수 있는 대표 메뉴',
    MENU_PRICE       = '¥1,800',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/izakaya-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = 'Kiiro';

-- [데이터 47] '야타이탄탄멘 타부쨩'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '든든한 국수 요리를 파는 고풍스럽고 소박한 레스토랑으로 종이 등불과 복고풍 인테리어가 특징입니다.',
    ADDRESS          = '일본 〒542-0074 Osaka, Chuo Ward, Sennichimae, 1 Chome-6-1 山喜登会館 1층·百羅',
    OPENING_HOURS    = '17:00 - 01:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '오리지널 탄탄멘',
    MENU_DESCRIPTION = '깊고 진한 육수와 특제 고기 고명이 올라간 매콤한 탄탄멘',
    MENU_PRICE       = '¥950',
    MAIN_IMAGE_URL   = '/images/store-img/dotonbori/tabuchan-tantanmen-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '야타이탄탄멘 타부쨩';

-- [데이터 48] '코메다커피 KITTE오사카점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '우메다 킷테 오사카 내에 위치하여 편안한 분위기에서 커피와 디저트를 즐길 수 있는 유명 카페.',
    ADDRESS          = '일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome-2-2 KITTE大阪',
    OPENING_HOURS    = '08:00 - 21:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '시로누와르',
    MENU_DESCRIPTION = '따뜻한 데니쉬 페이스트리 위에 부드러운 소프트아이스크림이 올라간 디저트',
    MENU_PRICE       = '¥700',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/komeda-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '코메다커피 KITTE오사카점';

-- [데이터 49] '하브스 테이크아웃숍 다이마루 우메다점'
UPDATE RESTAURANT
SET
    DESCRIPTION      = '신선한 과일과 부드러운 크림이 가득 채워진 프리미엄 케이크를 테이크아웃할 수 있는 우메다 대표 디저트 맛집.',
    ADDRESS          = '일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome-1-1 大丸梅田店 B1F',
    OPENING_HOURS    = '10:00 - 20:00',
    PRICE_RANGE      = '¥1,000 - ¥2,000',
    MENU_NAME        = '과일 크레이프 케이크',
    MENU_DESCRIPTION = '얇은 크레이프 사이에 신선한 제철 과일과 생크림이 겹겹이 들어간 대표 케이크',
    MENU_PRICE       = '¥950',
    MAIN_IMAGE_URL   = '/images/store-img/umeda/crepe-shop.png',
    UPDATED_AT       = SYSTIMESTAMP
WHERE NAME = '하브스 테이크아웃숍 다이마루 우메다점';


PROMPT ===== 수정 결과 확인 및 반영 =====

SELECT COUNT(*) AS TOTAL_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' THEN 1 END) AS PUBLIC_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'N' THEN 1 END) AS PRIVATE_ROWS
FROM RESTAURANT;

SELECT RESTAURANT_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANT
ORDER BY RESTAURANT_ID;

commit;

select * from RESTAURANT;

PROMPT ===== UPDATE_DONE - REVIEW BEFORE COMMIT =====
SET VERIFY ON
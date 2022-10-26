## 602277103 김서연

### 10/26
### 1.좌표계와 지오 데이터 포맷
#### 1-1) 오픈스트리트맵
- 동적 지도 맵

#### 1-2) 지오 데이터 포맷
- sp 패키지 
> - 점, 선, 면 같은 공간 정보를 처리할 목적으로 만든 데이터 
> - 데이터 전체의 기하학 정보 처리할 때 유리 
> - 좌푯값을 할당 및 기준 좌표계를 정의할 때 사용
 
- sf 패키지 
> - sp의 한계를 극복, 기존 데이터프레임에 공간 속성을 가진 칼럼을 추가하여 편집 및 수정 가능
> - 공간도형은 sp가 빨라 대부분 sp와 sf를 같이 사용함
> - 부분적인 바이너리 정보처리가 빠르다고 알려짐
> -특정 부분 추출, 삭제 , 변형 시  사용

#### 1-3) 지오 데이터프라임 생성
- sp형을 sf형으로 변환
```javascript
#install.package('sp')
library(sp)

coordinates(apt_price) <- coord_x + coord_y //좌표값 할당
pro4string(apt_juso) <- "+pro=longlat +datum=WGS84 +no_defs" //좌표계(CRS) 정의

#library(sf)
apt <- st_as_sf(apt_price)
```

#### 1-4) 지오 데이터프레임 시각화
- 플룻을 그린 후,
- addCircleMarkers() 함수로 apt_price의 1~1,000번의 데이터 출력

#### 1-5) 지오 데이터프레임 저장하기
- '06_geodataframe' 폴더 생성
- '06_apt_price'이름의 파일로 저장


### 10/12
### 1. 지오코딩 준비
#### 1-1) 1단계 : 카카오 로컬 API키 발급받기
- developers.kakao.com 접속
- 내 애플리케이션 > 애플리케이션 추가하기 클릭
- 앱 이름/ 사업자 명 입력
- REST API 키 확인(888595a57b78a86188283cb34d850da4)

#### 1-2) 2단계: 중복된 주소 제거하기
- 수집한 자료에서 주소만 추출
- duplicated()를 이용해 똑같은 주소가 많아 중복된 주소는 제거하고 고유한 주소만 추출함


### 2. 주소를 좌표로 변환하는 지오코딩
#### 2-1) 1단계 : 지오코딩 준비
- httr, rjson, data.table, dplyr 4가지 패키지 사용

```javascript
for(i in 1:nrow(apt_juso)){
  # 에러처리 
  tryCatch({
    # 주소로 좌표값 요청
    lon_lat <- GET(url = '',
                   query = list(query = apt_juso[i,]),
                   add_headers(Authorization = paste0("kakaoAK", kakao_key)))
    # 위경도만 추출하여 저장
    coorbxy <- lon_lat %>% content(as = 'text') %>% RJSONIO::fromJSON()
    # 반복횟수 카운팅
    cnt = cnt + 1
    # 주소, 경도, 위도 정보를 리스트로 저장
    add_list[[cnt]] <- data.table(apt_juso = apt_juso[i,],
                                 coord_x = coordxy$documents[[1]]$x,
                                 coord_y = coordxy$documents[[1]]$y)
    # 진행상황 알림 메시지
    message <= paste0("[", i, "/", nrow(apt_juso), "] 번째 (",
                      round(i/nrow(apt_juso)*100, 2), "%) [", apt_juso[i,] ,"] 지오코딩 중입니다:
                      x = ", add_list[[cnt]]$coord_x, " / Y = ", add_list[[cnt]]$coord_y)
    cat(message, "\n\n")
    
    # 예외처리 구문 종료
    }, error = function(e){cat("ERROR : ", conditionMessage(e), "\n")}
  )
}
```

### 3단계 : 지오 코딩 결과 저장
- 리스트를 데이터프레임 변환
- 좌표값 숫자형 변환
- 결측치 제거 후 .csv, rdata 파일로 저장

### 3. 지오데이터 프레임 만들기

#### 1단계: 좌표계와 지오 데이터 포맷
- 좌표계 : 타원체의 실체 좌푯값을 표현하기 위해 투영 과정을 거쳐 하는 보정의 기준
- EPSG : 좌표계를 표준화한 코드
- 데이터 프레임 : 다양한 유형의 정보를 통합하여 저장하는 포맷
- 공간 속성을 가진 칼럼을 추가해 공간 데이터를 일반 데이터프라임과 비슷하게 편집 및 수정 가능
- 공간 도형을 다루기 위해 sp와 sf를 같이 사용함

#### sp 패키지 
- 데이터 전체의 기하학 정보 처리할 때 유리 
- 좌푯값을 할당 및 기준 좌표계를 정의할 때 사용

#### sf 패키지 
- 부분적인 바이너리 정보처리가 빠르다고 알려짐
-특정 부분 추출, 삭제 , 변형 시  사용





### 10/05
### 1. 불필요한 정보 지우기
#### 1-1) 1단계 : 수집한 데이터 불러오기
```javascript
// setwd(dirname(rstudioapi::getSourceEditorContext()$path))
options(warn=1) //경고 메세지 무시

load("./03_integrated/03_apt_price.rdata")
head(apt_price, 3)
```

#### 1-2) 2단계 : 공백제거
- NA가 있는지 없는지 확인 후 제거
- NA가 잘 제거됬는지 확인
- 시계열 데이터 : 주식이나 환율처럼 실시간으로 변화하는 데이터 분석에 사용
```javascript
// NA 제거
table(is.na(apt_price)) # NA가 있는지 없는지 확인
 
apt_price <- na.omit(apt_price)
table(is.na(apt_price)) # NA가 잘 제거됬는지 학인

// 공백제거
head(apt_price$price, 3) 

// install.packages("stringr")
library(stringr)
apt_price <- as.data.frame(apply(apt_price, 2, str_trim))
// apply([적용 테이블], [1:raw/ 2:col], [적용 함수])
```

### 2. 항목별 데이터 다듬기
#### 2-1) 1단계 : 메메 연월일 만들기
- 컬럼 추가 시 사용하는 mutate(연도, 월, 일)
- $ 컬럼이름 (ex. ymd, ym)
- 파이프라인 : %>%을 이용하여 계산식을 간단하고 직관적으로 표현가능함
```javascript
apt_price <- apt_price%>% mutate(ymd=make_date(year, month, day))
apt_price$ym <- floor_date(apt_price$ymd, "month")
```

#### 2-2) 2단계 : 매매가 변환
#### 2-3) 3단계 : 주소 조합하기
- gsub("\\(.*", "", apt_price$apt_nm)
- apt_price$apt_nm에 있는 데이터의 여는 괄호 이후의 모든 문자의 공백 제거
- 코드에서 특수문자 사용 시 "\\" 기호 사용
- \\( :여는 괄호
- 점(.): 이후 문자
- * : 모든 문자
- ""는 공백제거
- read.csv()로 지역 코드에 해당하는 시군구 정보를 불러온 후 지역 코드와 번지수를 조합하여 주소 생성
```javascript
apt_price$apt_nm <- gsub("\\(.*", "", apt_price$apt_nm)
```

#### 2-4) 4단계 : 건축연도, 전용면적 변환
- 오버라이트 되어 이미 변환 완료
- 파이프라인 이용하여 소수점 아래 숫자 제거거
```javascript
head(apt_price$con_year, 5)

// 건축 연도 변환
apt_price$con_year <- apt_price$con_year %>% as.numeric()

// 전용면적 변환
head(apt_price$area, 5)
apt_price$area <- apt_price$area %>% as.numeric() %>% round(0)
```

#### 2-5) 5단계 : 평당 매매가 계산
```javascript
apt_price$py <- round(((apt_price$price/apt_price$area)*3.3), 0)
head(apt_price$py, 5)
```

#### 2-6) 6단계 : 층수 변환
```javascript
min(apt_price$floor)

apt_price$floor <- apt_price$floor %>% as.numeric() %>% abs(0)
```

#### 2-7) 7단계 :



### 09/28
### 1. 크롤러 제작
#### 1-1) 3단계 : 전체 거래 건수 확인
- 전체 거래 내역 추출 후 size : 68L 확인
```javascript
items <- root_Node[[i]][[2]][['items']] 
size <- xmlSize(items) 
```

#### 1-2) 4단계 : 개별 거래 내역 추출
- list()로 전체 거래내역 (items)를 저장할 임시 리스트 작성 만듬
- data.table() 세부 거래 내역(item)을 저장할 임시 저장소 만듬
- rbindlist()나 ldppy()를 사용하면 리스트 안에 포함된 작업 데이터 프레임을 여러 개를 하나로 결합 가능

#### 1-3) 5단계 : 응답 내용 저장
- 파일이 저장되는 위치와 파일명 설정
- 2단계에서 작성한 for문에 포함되어야 함
- 실행 시 '/02_raw_data/서울_강동_202112.csv'파일로 저장됨
```javascript
region_nm <- subset(loc, code == str_sub(url_list[i], 115, 119))$addr_1
month <- str_sub(url_list[i], 130, 135)
path <- as.character(paste0("./02_raw_data/", region_nm, "_", month, ".csv"))
write.csv(apt_bind, path)
msg <- paste0("[", i, "/", length(url_list), "] 수집한 데이터를  [", path, "]에 저장합니다.")
cat(msg, "\n\n")
```

### 2. 자료 통합하기
#### 2-1) 1단계 : CSV파일 통합하기
- 3-3에서 만든 csv 파일 300개를 하나로 합치는 작업
- 트레픽 오류로 날짜를 조정해 100개의 파일만 저장되도록 수정함

#### 2-2) 2단계 : 통합 데이터 저장
- 디렉토리 생성 후 통합 파일에 데이터 저장장



### 09/21
### 1. 크롤링
- (rstudio::getSourceEditorContext()$path)  // (A :: b)
- b의 값을 A에 넣어줌


### 2. 자주 사용하는 함수
#### 2-1) paste()
- 공백을 넣어서 원소들을 묶어줌
```javascript
pate(1,2,3,4) -> [1]"1 2 3 4" // 원소 사이에 공백 추가
```

#### 2-2) paste() 옵션
- sep(seperate) : paste에 나열된 각각의 원소 사이에 옵션을 적용하여 구분함 
- collapse : 결과값이 두 개 이상일 때, 각각의 결과값에 옵션을 적용해 이어 붙임

### 3. 요청 목록 생성
#### 3-1) 1단계 : 요청 목록 만들기
```javascript
url_list <- list()
cnt <- 0
```

#### 3-2) 2단계 : 요청 목록 채우기
- paste0에서 주소 및 코드를 넣을 때 'LAWD_CD=', '&DEAL_YMD='에 공백없이 작성해야 오류가 나오지 않음
```javascript
for(i in 1:nrow(loc)) { //25개 자치구
  for(j in 1:length(datelist)) { // 12개월
    cnt <- cnt + 1
    // 요청목록 채우기 25 * 12 = 300개
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?",
                            "LAWD_CD=", loc[i, 1], //지역코드
                            "&DEAL_YMD=", datelist[j], //계약 년월
                            "&numOfLows=", 100, //한번에 가져올 최대 자료 수
                            "&serviceKey=", service_key) //Encoding 인증
  }
  Sys.sleep(0.1) //0.1초간 멈춤
  msg <- paste0("[", i, "/", nrow(loc), "]", loc[i, 3], "의 크롤릭 목록이 생성됨 => 총 [", cnt,"] 건") // 알림 메시지
  cat(msg, "\n\n")
}
```

#### 3-3) 3단계 : 요청 목록 확인
-브라우저에 띄워서 정상동작 확인
```javascript
length(url_list) // 목록 개수
browseURL(paste0(url_list[1])) 
```

### 4. 크롤러 제작
#### 4-1) 1단계 : 임시저장 리스트 생성
- install.packages로 XML, data.table, stringr을 install한다.
- dir.create("02_raw_data")로 '02_raw_data'이름의 폴더 생성



### 09/14
### 1. 크롤링
#### 1단계 : 작업 디렉토리 설정
```javascript
#install.packages("rstudioapi") // rstudioapi 설치
setwd(dirname(rstudio::getSourceEditorContext()$path)) // 작업 폴더 설정
getwd() // 작업 폴더 확인
```
- 터미널에서 ls() 함수 안에 있는 값을 삭제하려고 할때 아래 코드와 같이 사용용
```javascript
rm(list = ls()) // rm = remove
```

#### 2단계 : 수집 대상지역 설정
- head()는 맨 위 정보를 가져옴
- tail()은 맨 아래 정보를 가져옴
```javascript
loc <- read.csv("./sigun_code.csv", fileEncoding = "utf-8") // 지역코드
loc$code <- as.character(loc$code)
head(loc, 2) // 확인
```


#### 3단계 : 수집 기간 설정
- from ~ to : 수집 기간
- by : 수집 기간의 간격 설정 (ex. 1 month = 한 달)
- format () : 날짜 형식 설정
```javascript
datelist <- seq(from = as.Date('2021-01-01'),
                to = as.Date('2021-12-31'),
                by = '1 month')
datelist <- format(datelist, format = '%Y%m')
datelist[1:5]
```

#### 4단계 : 서비스키 설정



### 09/07
### 1. 공공데이터포털
- https://www.data.go.kr/
- "국토교통부_아파트매매 실거래자료" 검색 및 활용 신청
- 신청 후 1~2시간 정도 소요됨

- 공공데이터 상세페이지의 End Poing + 일반 인증키 url 주소를 붙여넣기 해서 데이터 나오는 것 확인 

### 2. 텍스트 마이닝
: 비정형 텍스트에서 의미있는 정보를 찾아내는 mining 기술
- 단어 분류나 문법적 구조 분석을 처리하는 기술
- 문서 분류, 관련 있는 문서들을 군집화, 정보 추출, 문서 요약 등에 활용됨

### 3. 워드 클라우드(Wordcloud)
```javascript
install.packages("wordcloud") // wordcloud 패키지 설치 및 로딩
library(wordcloud)

word <- c("인천광역시", "강화군", "웅진군")
frequency <- c(651, 85, 61)

wordcloud(word, frequency, colors=rainbow(length(word))) // 워드 클라우드 출력

```

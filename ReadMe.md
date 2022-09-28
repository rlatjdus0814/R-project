## 602277103 김서연

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
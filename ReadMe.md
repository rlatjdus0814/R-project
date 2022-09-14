## 602277103 김서연

### 09/14
### 3. 크롤링
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
loc <- read.csv("./sigun_code.csv", fileEncoding = "utf-8") # 지역코드
loc$code <- as.character(loc$code)
head(loc, 2) # 확인
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

#### 4단계 : 서비스키 설정정

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
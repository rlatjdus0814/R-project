## 602277103 김서연

### 11/30
### 1. ShinyApp 배포하기
- deployApp() 함수 사용하여 앱 배포하기
- 터미널 탭에서 나온 https://www.shinyapps.io/ 주소에서 배포된 것 확인
                                                  
### 2. 중간고사 코드 리뷰뷰 



### 11/23
### 1. 반응성 : 입력과 출력의 연결
#### 1-1) 1단계 : 데이터 준비
#### 1-2) 2단계 : 반응식 작성

### 2. 레이아웃 정의하기
- 레이아웃 : 제한된 화면안에 입력된 여러 위젯들을 배치하는 방식
#### 2-1) 1단계 : 단일 페이지 레이아웃
- 행 row 구성 정의
```javascript
ui <- fluidPage( 
  fluidRow( 
    # 첫 번째 열 : 붉은색(red) 박스로 높이 450, 폭 9
    column(9, div(style="height:450px; border:4px solid red;", "폭 9")),
    # 두 번째 열 : 보라색(purple) 박스로 높이 450, 폭 3
    column(3, div(style="height:450px; border:4px solid purple;", "폭 3")),
    # 세 번째 열 : 파란색(blue) 박스로 높이 400, 폭 12
    column(12, div(style="height:400px; border:4px solid blue;", "폭 12")),
  )
)
```

#### 2-2) 2단계 : 탭 페이지 추가하기
- tabsetPanel() 을 이용해 탭 패널 1~2번 추가
```javascript
tabsetPanel( 
      tabPanel("탭1",
                column(4, div(style="height:300px; border:4px solid red;", "폭 4")),
                column(4, div(style="height:300px; border:4px solid red;", "폭 4")), 
                column(4, div(style="height:300px; border:4px solid red;", "폭 4")),
               ),
      tabPanel("탭2", div(style="height:300px; border:4px solid blue;", "폭 12"))
    )
```

### 3. 반응형 지도 만들기
- leaflet 기반으로 반응형 지도 만들기
- leaflet : 반응형 지도를 만드는 자바스크립트 라이브러리
#### 1-1) 1단계 : 데이터 불러오기
- 6장에서 했던 아파트 실거래 데이터, 7장 최고가, 급등 래스터 이미지 불러오기
#### 1-2) 2단계 : 마커클러스터링 설정
- 하위 10%, 상위 10%, 마커 클러스터링 함수 사용
#### 1-3) 3단계 : 반응형 지도 만들기
- 오픈스트리트맵으로 기본 맵 설정
- 최고가, 급등 지역 KDE
- 레이어 스위치 메뉴
- 서울시 외곽 경계선
- 마커 클러스터링

### 4. 지도 애플리케이션 만들기
#### 1-1) 그리드 필터링
- 그리드를 불러와 필터링 하기
```javascript
grid <- st_read("./01_code/sigun_grid/seoul.shp") #그리드 불러오기
grid <- as(grid, "Spatial") 
grid <- as(grid, "sfc")
grid <- grid[which(sapply(st_contains(st_sf(grid), apt_price), length) > 0)] #필터링
plot(grid)
```

#### 1-2) 2단계 : 반응형 지도 모듈화 하기
- 이전 단계와 같이 leaflet() 사용

#### 1-3) 3단계 : 애플리케이션 구현하기
- 특정 지점을 선택하여 분석하는 기능을 구현하기 위해 mapedit 패키지 사용
- selectModUI() : 지도 입력 모듈, 지도에서 특정 지점이 선택될 때 입력값을 서버로 전달
- callModule() : 입력 결과를 처리하여 다시 화면으로 전달하는 출력 모듈듈

#### 1-4) 4단계 : 반응식 추가






### 11/16
### 1. 샤이니
- 분석 결과를 웹 애플리케이션으로 구현할 수 있는 샤이니 패키지 제공
- 기존 R을 사용하는 사람들을 고려해 만들어짐
#### 1-1) 1단게 : 샤이니 기본 구조 이해하기
- 사용자 인터페이스, 서버, 실행 구성요소를 작성하여 웹 애플리케이션 제작
- fluidPage() 안의 내용 출력
```javascript
# install.packages("shiny")
library(shiny)

ui <- fluidPage("사용자 인터페이스")
server <- function(input, output, session) { }
shinyApp (ui, server)
```

#### 1-2) 2단게 : 샘플 실행하기
- 데이터 분석은 명령형과 반응형 방식으로 구분됨
- 명령형 : 데이터 분석을 단계별로 진행함
- 반응형 : 분석을 진행하다가 조건이 바뀌면 되돌아가 다시 분석함
- 샤이니 애플리케이션은 반응형 방식으로 동작함

#### 1-3) 3단게 : 사용자 인터페이스
- 샤이니가 제공하는 기농과 동작원리 파악
- fluidPage()로 단일 페이지 화면 제작
- 사이드바 와 메인 패널을 나누기 위해 sidebarLayout() 이용하여 sidebarPanel(), mainPanel() 정의

#### 1-4) 4단게 : 서버
- session : 독립성을 확보하는 역할

```javascript
ui <- fluidPage(
  titlePanel("샤이니 1번 샘플"), // 타이틀 입력
  // 레이아웃 구성 : 사이드바 패널 + 메인 패널
  sidebarLayout(
    sidebarPanel( // 사이드바 패널 시작
      // 입력값 : input$bins 저장
      sliderInput(inputId = "bins", // 입력 아이디
                  label = "Number of bins:", // 텍스트 라벨
                  min = 1, max = 50, // 선택 범위 (1-50)
                  value = 30) // 기본 선택 값 30
    ),
    mainPanel( // 메인 패널 시작
      // 출력값 : output$disPlot 저장
      plotOutput(outputId = "distPlot") // 차트 출력
      
    )
  )
)

server <- function(input, output, session) {
  output$disPlot <- renderPlot({ // 랜더링한 플룻을 output 인자의 disPlot에 저장
    x <- faithful$waiting // 분출대기시간 정보 저장
    bins <- seq(min(x), max(x), length.out = input$bins +1) // input$bins을 플룻으로 랜더링
    hist(x, breaks = bins, col="#75AADB", border="white",
         xlab = "다음 분출때까지 대기시간(분)",
         main = "대기시간 히스토그램")
  })
}

shinyApp (ui, server)
```


### 2. 입력과 출력하기
#### 2-1) 1단게 : 입력받기 input$~
- 입력 위젯 : 사용자들이 입력하는 값을 받는 장치
- 샤이니에서 제공하는 함수 이름은 대부분 ~Input으로 끝남
```javascript
ui <- fluidPage(
  sliderInput("range", "연비", min=0, max=35, value=c(0, 10)) / 데이터 입력
)
server <- function(input, output, session) {} / 반응 업음
shinyApp(ui, server) / 실행
```

#### 2-2) 2단게 : 출력하기 output$~
```javascript
ui <- fluidPage(
  sliderInput("range", "연비", min=0, max=35, value=c(0, 10)), textOutput("value") // 데이터 입력
)
server <- function(input, output, session) {
  output$value <- renderText((input$range[1] + input$range[2]))
} 
shinyApp(ui, server)
```


### 11/09
### 1. 지도 시각화
#### 1-1) 6단게 : 불펼요한 부분 자르기

#### 1-2) 7단게 : 지도 시각화
- 기본 지도 불러온 후 서울시 경계선 불러오기
- 가격 상승 지역만 추출 -> 그리드에 결합
```javascript
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>% # 기본 지도 불러오기
  addPolygons(data = bnd, weight=3, color="red", fill=NA) %>% # 서울시 경계선 불러오기
  addResterImage(raster_high,
                 colors = colorNumeric(c("blue", "green", "yellow", "red"),
                                       values(raster_high), na.color = "transparent"), opacity=0.4)
```

#### 1-3) 8단계 : 평균 가격 정보 저장하기



### 2. 변화율 확인
#### 2-1) 1단계 : 데이터 준비
#### 2-2) 2단계 : 변화율 확인
- 이전과 이후 데이터를 필터링하여 평균 가격 출력
- 이전 + 이후 데이터 결합


#### 2-3) 3단계 : 가격이 오른 지역 찾기
- 가격이 오른 지역이 붉은색으로, 낮은 지역이 흰색으로 그라데이션 됨
- 가격 상승 지역만 추출 -> 그리드에 결합
```javascript
kde_diff <- kde_diff[kde_diff$diff >0,] 
kde_hot <- merge(grid, kde_diff, by="ID")
```

#### 2-4) 4단계 : 지도경계선 그리기
- 07-1의 4단계 변형하여 작성
- sp형으로환하여 그리드 중심 x(경도), y(위도) 좌표 추출
- 그리드를 기준으로 지점 설정
```javascript
kde_hot_sp <- as(st_geometry(kde_high), "Spatial") # sf형 => sp형 변환
x <- coordinates(kde_hot_sp)[,1] # 그리드 중심 x(경도), y(위도) 좌표 추출
y <- coordinates(kde_hot_sp)[,2]

# 기준 경계 설정
l1 <- bbox(kde_hot_sp)[1,1] - (bbox(kde_hot_sp)[1,1]*0.0001) # 그리드 기준 경계지점 설정
l2 <- bbox(kde_hot_sp)[1,2] + (bbox(kde_hikde_hot_spgh_sp)[1,2]*0.0001)
l3 <- bbox(kde_hot_sp)[2,1] - (bbox(kde_hot_sp)[2,1]*0.0001)
l4 <- bbox(kde_hot_sp)[2,2] + (bbox(kde_hot_sp)[1,1]*0.0001)
```

#### 2-5) 5단계 : 밀도 그래프 변환하기
- 경계선 위에 좌푯값 포인트 생성
- 커널 밀도 함수로 변환
```javascript
p <- ppp(x,y, window = win, marks=kde_hot$diff) # 경계선 위에 좌푯값 포인트 생성
d <- density.ppp(p, weights = kde_hot$diff, #커널 밀도 함수로 변환
                 sigma = bw.diggle(p),
                 kernel = 'gaussian')
```

#### 2-6) 6단계 : 픽셀 -> 레스터 변환
#### 2-7) 7단계 : 불펼요한 부분 자르기


### 3. 주변 지역과 특정 지역의 평균 가격 비교
- 마커 클러스터링 : 마커가 너무 많을 때 특정한 기준으로 마커를 하나로 묶어줌

#### 3-1) 1단계 : 데이터 준비하기
#### 3-2) 2단계 : 마커 클러스터링 옵션 설정
- 마커 클러스터링용 자바스크립트 사용

#### 3-2) 3단계 : 오픈 스트리트맵 불러오기
- 서울시 경계선, 최고가 래스터 이미지, 급등지 래스터 이미지 불러온 후
- 최고가/급등지 선택 옵션 추가, 마커 클러스터링 불러오기

```javascript
leaflet() %>%
  # 오픈 스트리트맵 불러오기
  addTiles() %>%
  # 서울시 경계선 불러오기
  addPolygons(data = bnd, weight=3, color="red", fill=NA) %>% 
  #최고가 래스터 이미지 불러오기
  addResterImage(raster_high,
                 colors = colorNumeric(c("blue", "green", "yellow", "red"),
                                    values(raster_high), na.color = "transparent"), opacity=0.4, group  = "2021 최고가") %>%
  
  # 급등지 래스터 이미지 불러오기  
  addResterImage(raster_hot,
                 colors = colorNumeric(c("blue", "green", "yellow", "red"),
                                       values(raster_hot), na.color = "transparent"), opacity=0.4, group  = "2021 급등지") %>%
  # 최고가/급등지 선택 옵션 추가하기
  addLayersControl(baseGroups = c("2021 최고가", "2021 급등지"),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  
  # 마커 클러스터링 불러오기
  addCircleMarkers(data = apt_price, lng=nulist(map(apt_price$geometry,1)),
                   lat = unlist(map(apt_price$geometry,2)), radius=10, stroke=FALSE,
                   fillOpacity=0.6, fillColor=circle.colors, weight=apt_price$py, # 가중치를 floor나 area로 바꾸면 마커 클러스터링 숫자가 달라짐짐
                   clusterOptions=markerClusterOptions(iconCreateFunction=JS(avg.formula)))
```



### 11/02
### 1. 지도 시각화
#### 1-1) 1단게 : 지역별 평균 가격 구하기
- 서울시 1km 그리드 불러오기
- 실거래 + 그리드 결합
-그리드별 평균 가격 노출

#### 1-2) 2단게 : 평균 가격 정보 표시하기
- 그리드(세이프 파일) + 평균 가격(속성 파일)의 결합
- 그래프를 시각화하여 하얀색(low)에서 붉은색(high)으로 나타냄
```javascript
kde_high <- merge(grid, kde_high, by="ID") // ID 기준으로 결합

kde_high %>% ggplot(aes(fill = avg_price)) +  // 그래프 시각화
                    geom_sf() + 
                    scale_fill_gradient(low = "white", high = "red")
```

#### 1-3) 3단게 : 지도 경계 그리기
- 제일 비싼 지역을 알기 위해 데이터가 집중된 곳을 찾아야 함함
- 커널 밀도 추정 : 커널 함수로 변수의 밀도를 추정하는 방벙
- 그리드의 경도(x), 위도(y) 추출
```javascript
kde_high_sp <- as(st_geometry(kde_high), "Spatial") // sf형 => sp형 변환
x <- coordinates(kde_high_sp)[,1] // 그리드 중심 x(경도), y(위도) 좌표 추출
y <- coordinates(kde_high_sp)[,2]
```

- 지도의 경계선 생성 후 변수 정리하기
```javascript
win <- owin(xrange=c(l1,l2), yrange=c(l3,l4))
plot(win) 
rm(list = c("kde_high_sp", "apt_price", "l1","l2","l3","l4"))
```

#### 1-4) 4단게 : 밀도 그래프 표시하기
- 지도 경계선(win) 내의 포인트 분포 데이터로 계산
- ppp() 함수 : 경도(x), 위도(y)를 포인트로 변환함
- density.ppp() : 생성한 포인트를 연속된 곡선을 가진 커널로 변환
```javascript
p <- ppp(x,y, window = win) # 경계선 위에 좌푯값 포인트 생성
d <- density.ppp(p, weights = kde_high$avg_price, #커널 밀도 함수로 변환
                 sigma = bw.diggle(p),
                 kernel = 'gaussian')
plot(d) # 밀도 그래프 확인
rm(list = c("x", "y", "win", "p")) # 변수 정리
```

#### 1-5) 5단게 : 래스터 이미지로 변환하기
- 노이즈 제거 후 raster()함수로 레스터 이미지 변환





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

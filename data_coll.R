############################
# 3-1 크롤링 준비

# 1단계: 작업 디렉토리리 설정
# install.packages("rstudioapi") # rstudioapi 설치
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) # 작업 폴더 설정
getwd() # 작업 폴더 확인

# 2단계 : 수정 대상지역 설정
loc <- read.csv("./sigun_code.csv", fileEncoding = "utf-8") # 지역코드
loc$code <- as.character(loc$code)
head(loc, 2) # 확인

# 3단계 : 수집 기간 설정
datelist <- seq(from = as.Date('2021-01-01'), #시작
                to = as.Date('2021-12-31'),   #종료
                by = '1 month')               #단위
datelist[1:3]
datelist <- format(datelist, format = '%Y%m') #(YYYY-MM-DD -> YYYYMM)
datelist[1:5]

# 4단계 : 서비스키 설정
service_key <- "F0%2BLRlPggAbwneXomkZ%2B8GCoZWLXN%2BXH1u3u7Ri%2BPb1co6gKTUjhD6UCw5BVssGXxS0FL%2FRa53V34y7kw2WY4Q%3D%3D"


############################
# 3-2 요청 목록 생성

# 1단계 : 요청 목록 만들기
url_list <- list()
cnt <- 0

# 2단계 : 요청 목록 채우기
for(i in 1:nrow(loc)) { #25개 자치구
  for(j in 1:length(datelist)) { # 12개월
    cnt <- cnt + 1
    # 요청목록 채우기 25 * 12 = 300개
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?",
                            "LAWD_CD=", loc[i, 1], #지역코드
                            "&DEAL_YMD=", datelist[j], #계약 년월
                            "&numOfLows=", 100, #한번에 가져올 최대 자료 수
                            "&serviceKey=", service_key) #Encoding 인증
  }
  Sys.sleep(0.1) #0.1초간 멈춤
  msg <- paste0("[", i, "/", nrow(loc), "]", loc[i, 3], "의 크롤릭 목록이 생성됨 => 총 [", cnt,"] 건") # 알림 메시지
  cat(msg, "\n\n")
}

# 3단계 : 요청 목록 확인
length(url_list) # 목록 개수
browseURL(paste0(url_list[1])) #브라우저에 띄워서 정상동작 확인


############################
# 3-3 크롤러 제작

# 1단계 : 임시 저장 리스트 생성
# install.packages("XML")
# install.packages("data.table")
# install.packages("stringr")
library(XML)
library(data.table)
library(stringr)

raw_data <- list() # XML 파일 저장소
root_Node <- list() # 거래 내역 추출 데이터 임시 저장
total <- list() # 거래 내역 정리 데이터 임시 저장
dir.create("02_raw_data") # 새로운 폴더 만들기

# 2단계 : 자료 요청 및 응답 받기기


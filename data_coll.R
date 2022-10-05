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
tail(loc, 5)

# 3단계 : 수집 기간 설정
datelist <- seq(from = as.Date('2021-01-01'), #시작
                to = as.Date('2021-04-30'),   #종료
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

# 2단계 : 자료 요청 및 응답 받기
for(i in 1:length(url_list)) {
  raw_data[[i]] <- xmlTreeParse(url_list[i], useInternalNodes = TRUE, encoding="utf-8")
  root_Node[[i]] <- xmlRoot(raw_data[[i]])


# 3단계 : 전체 거래 건수 확인
items <- root_Node[[i]][[2]][['items']] #전체 거래내역 추출
size <- xmlSize(items) #68L 확인

# 4단계 : 개별 거래 내역 추출
# - list()로 전체 거래내역 (items)를 저장할 임시 리스트 작성 만듬
# - data.table() 세부 거래 내역(item)을 저장할 임시 저장소 만듬
#rbindlist나 ldppy)를 사용하면 리스트 안에 포함된 작업 데이터 프레임을 여러 개를 하나로 결합 가능
item <- list()
item_temp_dt <- data.table()
Sys.sleep(.1)
for(m in 1:size) {
  item_temp <- xmlSApply(items[[m]], xmlValue)
  item_temp_dt <- data.table(year = item_temp[4], 
                             month = item_temp[7],
                             day = item_temp[8],
                             price = item_temp[1],
                             code = item_temp[12],
                             dong_nm = item_temp[5],
                             jiba = item_temp[11],
                             con_year = item_temp[3],
                             apt_nm = item_temp[6],
                             area = item_temp[9],
                             floor = item_temp[13])
  item[[m]] <- item_temp_dt
}
apt_bind <- rbindlist(item)

# 5단계 : 응답 내용 저장
region_nm <- subset(loc, code == str_sub(url_list[i], 115, 119))$addr_1
month <- str_sub(url_list[i], 130, 135)
path <- as.character(paste0("./02_raw_data/", region_nm, "_", month, ".csv"))
write.csv(apt_bind, path)
msg <- paste0("[", i, "/", length(url_list), "] 수집한 데이터를  [", path, "]에 저장합니다.")
cat(msg, "\n\n")
} # 2단계에 작성한 for문 닫기

 
############################
# 3-4 자료 통합하기

# 1단계 : CSV 파일 통합
# - 3-3에서 만든 csv 파일 300개를 하나로 합치는 작업
# - 
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
files <- dir("./02_raw_data")

install.packages("plyr")
library(plyr)
apt_price <- ldply(as.list(paste0("./02_raw_data/", files)), read.csv)
tail(apt_price, 3)

# 2단계 : 통합 데이터 저장
dir.create("./03_integrated") # 디렉토리 생성
save(apt_price, file = "./03_integrated/03_apt_price.rdata") # 파일 저장
write.csv(apt_price, "./03_integrated/03_apt_price.csv")







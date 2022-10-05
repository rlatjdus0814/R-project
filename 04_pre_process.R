############################
# 4-1 불필요한 정보 지우기

# 1단계: 수집한 데이터 불러오기
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))
options(warn=1) #경고 메세지 무시

load("./03_integrated/03_apt_price.rdata")
head(apt_price, 3)

# 2단계: 공백제거
# NA 제거
table(is.na(apt_price)) # NA가 있는지 없는지 확인
 
apt_price <- na.omit(apt_price)
table(is.na(apt_price)) # NA가 잘 제거됬는지 학인

# 공백제거
head(apt_price$price, 3) 

# install.packages("stringr")
library(stringr)
apt_price <- as.data.frame(apply(apt_price, 2, str_trim))
# apply([적용 테이블], [1:raw/ 2:col], [적용 함수])

#시계열 데이터 : 주식이나 환율처럼 실시간으로 변화하는 데이터 분석에 사용

############################
# 4-2 항목별 데이터 다듬기

# 1단계: 메메 연월일 만들기
install.packages("lubridate")
library(lubridate)
install.packages("dplyr")
library(dplyr)

apt_price <- apt_price%>% mutate(ymd=make_date(year, month, day))
apt_price$ym <- floor_date(apt_price$ymd, "month")
head(apt_price, 3)

# 2단계: 매매가 변환하기
head(apt_price$price, 3)

apt_price$price <- apt_price$price %>% sub(",", "",.) %>% as.numeric()
  
# 3단계: 주소 조합하기
head(apt_price$apt_nm, 100) # 확인

apt_price$apt_nm <- gsub("\\(.*", "", apt_price$apt_nm) #필요없는 ()안의 주소 삭제

loc <- read.csv("./sigun_code.csv", fileEncoding = "UTF-8")

apt_price <- merge(apt_price, loc, by='code')
apt_price$juso_jibun <- paste0(apt_price$code_2, " ", apt_price$dong_nm, " ", apt_price$jiban, " ", apt_price$apt_nm)

head(apt_price, 5)

# 4단계 : 건축연도, 전용면적 변환
head(apt_price$con_year, 5)

# 건축 연도 변환
apt_price$con_year <- apt_price$con_year %>% as.numeric()

# 전용면적 변환
head(apt_price$area, 5)
apt_price$area <- apt_price$area %>% as.numeric() %>% round(0)

# 5단계 : 평당 매매가 계산
apt_price$py <- round(((apt_price$price/apt_price$area)*3.3), 0)
head(apt_price$py, 5)

# 6단계 : 층수 변환
min(apt_price$floor)

apt_price$floor <- apt_price$floor %>% as.numeric() %>% abs(0)

apt_price$cnt <- 1 # 카운트 추가
head(apt_price, 5)


  
  
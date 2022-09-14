############################
# 3-1 크롤링 준비

# 1단계: 작업 디렉토리리 설정
# install.packages("rstudioapi") # rstudioapi 설치
setwd(dirname(rstudio::getSourceEditorContext()$path)) # 작업 폴더 설정
getwd() # 작업 폴더 확인

# 2단계 : 수정 대상지역 설정
loc <- read.csv("./sigun_code.csv", fileEncoding = "utf-8") # 지역코드
loc$code <- as.character(loc$code)
head(loc, 2) # 확인

# 3단계 : 수집 기간 설정
datelist <- seq(from = as.Date('2021-01-01'),
                to = as.Date('2021-12-31'),
                by = '1 month')
datelist <- format(datelist, format = '%Y%m')
datelist[1:5]

# 4단계 : 서비스키 설정정
service_key <- "F0%2BLRlPggAbwneXomkZ%2B8GCoZWLXN%2BXH1u3u7Ri%2BPb1co6gKTUjhD6UCw5BVssGXxS0FL%2FRa53V34y7kw2WY4Q%3D%3D"
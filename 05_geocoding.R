############################
# 5-1 Geocoding 준비

# 1단계: 카카오 로컬 API키 발급받기
# developers.kakao.com 접속
# 내 애플리케이션 > 애플리케이션 추가하기 클릭
# 앱 이름/ 사업자 명 입력
# REST API 키 확인

# 2단계: 중복된 주소 제거하기
# - 수집한 자료에서 주소만 추출
# - 똑같은 주소가 많아 중복된 주소는 제거하고 고유한 주소만 추출함
# install.packages("rstudio")

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
load("./04_preprocess/04_preprocess.rdata") # 실거래 불러오기
apt_juso <- data.frame(apt_price$juso_jibun) # 주소컬럼만 추출
apt_juso <- data.frame(apt_juso[!duplicated(apt_juso),])# unique 주소 추출
head(apt_juso, 2) # 추출결과 확인


############################
# 5-2 주소를 좌표로 변환하는 지오코딩

# 1단계 : 지오코딩 준비
# - httr, rjson, data.table, dplyr 4가지 패키지 사용
add_list <- list() # 빈 리스트 생성
cnt <- 0 # 반복문 카운팅 초기값 설정
kakao_key = "888595a57b78a86188283cb34d850da4" # 인증키

install.packages('httr')
 install.packages('RJSONIO')
 install.packages('data.table')
install.packages('dplyr')
library(httr)
library(RJSONIO)
library(data.table)
library(dplyr)

for(i in 100:nrow(apt_juso)){
  # 에러처리 
  tryCatch({
    # 주소로 좌표값 요청
    lon_lat <- GET(url = 'https://dapi.kakao.com/v2/local/search/address.json',
                   query = list(query = apt_juso[i,]),
                   add_headers(Authorization = paste0("KakaoAK", kakao_key)))
    # 위경도만 추출하여 저장
    coordxy <- lon_lat %>% content(as = 'text') %>% RJSONIO::fromJSON()
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

# 3단계 : 지오 코딩 결과 저장
juso_geocoding <= rbindlist(add_list) # 리스트를 데이터프레임 변환
juso_geocoding$coord_x <- as.numeric(juso_geocoding$coord_x) # 좌표값 숫자형 변환
juso_geocoding$coord_y <- as.numeric(juso_geocoding$coord_y)
juso_geocoding <- na.omit(juso_geocoding) #결측치 제거

dir.create("./05_geocoding")
save(juso_geocoding, file = "./05_geocoding/05_geocoding.rdata") # 파일 저장
write.csv(juso_geocoding, "./05_geocoding/05_geocoding.csv")  






















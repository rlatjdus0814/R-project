############################
# 6-1 지오데이터 프레임 만들기

# 1단계: 좌표계와 지오 데이터 포맷
# - 좌표계 : 타원체의 실체 좌푯값을 표현하기 위해 투영 과정을 거쳐 하는 보정의 기준
# - EPSG : 좌표계를 표준화한 코드
# - 데이터 프레임 : 다양한 유형의 정보를 통합하여 저장하는 포맷
# - 공간 속성을 가진 칼럼을 추가해 공간 데이터를 일반 데이터프라임과 비슷하게 편집 및 수정 가능
# - 공간 도형을 다루기 위해 sp와 sf를 같이 사용함

#### sp 패키지 
# - 데이터 전체의 기하학 정보 처리할 때 유리 
# - 좌푯값을 할당 및 기준 좌표계를 정의할 때 사용

#### sf 패키지 
# - 부분적인 바이너리 정보처리가 빠르다고 알려짐
# -특정 부분 추출, 삭제 , 변형 시  사용

###########################
# 6-2. 주소와 좌표 결합하기
# 1단계 : 데이터 불러오기
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
load("./04_preprocess/04_preprocess.rdata") #주소 불러오기
load("./05_geocoding/05_juso_geocoding.rdata") #좌표 불러오기

# 2단계 : 주소+좌표 결합
#install.packages('dplyr')
library(dplyr)
apt_price <- left_join(apt_price, juso_geocoding,
                       by = c("juso_jibun" = "apt_juso")) # 결합
apt_price <- na.omit(apt_price) # na 삭제

###########################
# 6-3. 지오 데이터프레임 만들기
# 1단계 : 지오 데이터프레임 생성하기
#install.packages("sp")
library(sp)

coordinates(apt_price) <- ~coord_x + coord_y # 좌표값 할당
proj4string(apt_price) <- "+pro=longlat +datum=WGS84 +no_defs" #좌표계(CRS) 정의

#install.packages("sf")
library(sf)
apt_price <- st_as_sf(apt_price) #sp형 => sf형 변환

# 2단계 : 지오 데이터프레임 시각화
plot(apt_price$geometry, axes = T, pch =1) # 플룻 그리기

#install.packages('leaflet')
library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(data= apt_price[1:1000,], label=~apt_nm) # 일부분(1000개)만 그리기)

# 3단계 : 지오 데이터프레임 저장하기
dir.create("06_geodataframe") # 새로운 폴더 생성
save(apt_price, file = "./06_geodataframe/06_apt_price.rdata") # 파일 저장
write.csv(apt_price, "./06_geodataframe/06_apt_price.csv")  


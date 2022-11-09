############################
# 7-1 

#############################

# 1단계 : 지역별 평균 가격 구하기
# 실거래 + 그리드 데이터 결합

setwd(dirname(rstudioapi::getSourceEditorContext()$path)) # 작업폴더 설정
load("./06_geodataframe/06_apt_price.rdata") # 실거래 불러오기

#install.packages("sf")
library(sf)

grid <- st_read("./01_code/01_code/sigun_grid/seoul.shp") #서울시 1km 그리드 불러오기
apt_price <- st_join(apt_price, grid, join = st_intersects) # 실거래 + 그리드 결합
head(apt_price)

# 그리드별 평균 가격(평당) 계산
kde_high <- aggregate(apt_price$py, by=list(apt_price$ID), mean) # 그리드별 평균가격
colnames(kde_high) <- c("ID", "avg_price") #컬럼명 변경
head(kde_high, 2) #확인


# 2단계 : 평균 가격 정보 표시하기
kde_high <- merge(grid, kde_high, by="ID") # ID 기준으로 결합
#install.packages("ggplot2")
#install.packages("dplyr")
library(ggplot2)
library(dplyr)

kde_high %>% ggplot(aes(fill = avg_price)) + # 그래프 시각화
                    geom_sf() + 
                    scale_fill_gradient(low = "white", high = "red")


# 3단계 : 지도 경계 그리기
#install.packages("sp")
library(sp)

kde_high_sp <- as(st_geometry(kde_high), "Spatial") # sf형 => sp형 변환
x <- coordinates(kde_high_sp)[,1] # 그리드 중심 x(경도), y(위도) 좌표 추출
y <- coordinates(kde_high_sp)[,2]

# 기준 경계 설정
l1 <- bbox(kde_high_sp)[1,1] - (bbox(kde_high_sp)[1,1]*0.0001) # 그리드 기준 경계지점 설정
l2 <- bbox(kde_high_sp)[1,2] + (bbox(kde_high_sp)[1,2]*0.0001)
l3 <- bbox(kde_high_sp)[2,1] - (bbox(kde_high_sp)[2,1]*0.0001)
l4 <- bbox(kde_high_sp)[2,2] + (bbox(kde_high_sp)[1,1]*0.0001)

# 지도 경계선 그리기
#install.packages("spatstat")
library(spatstat)

win <- owin(xrange=c(l1,l2), yrange=c(l3,l4)) # 지도 경계계선 생성
plot(win) # 지도 경계선 확인
rm(list = c("kde_high_sp", "apt_price", "l1","l2","l3","l4")) # 변수 정리


# 4단계 : 밀도 그래프 표시하기
p <- ppp(x,y, window = win) # 경계선 위에 좌푯값 포인트 생성
d <- density.ppp(p, weights = kde_high$avg_price, #커널 밀도 함수로 변환
                 sigma = bw.diggle(p),
                 kernel = 'gaussian')
plot(d) # 밀도 그래프 확인
rm(list = c("x", "y", "win", "p")) # 변수 정리


# 5단계 : 래스터 이미지로 변환하기
d[d<quantile(d)[4] + (quantile(d)[4]*0.1)] <- NA #노이즈 제거
#install.packages("raster")
library(raster)
raster_high <- raster(d) # 레스터 변환
plot(raster_high)


# 6단계 : 불펼요한 부분 자르기
bnd <- st_read("./01_code/01_code/sigun_grid/seoul.shp")
raster_high <- crop(raster_high, extent(bnd))
crs(raster_high) <- sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
plot(raster_high)
plot(bnd, col=NA, border="red", add=TRUE)


# 7단계 : 지도 시각화
#install.packages("rgdal")
library(rgdal)
#install.packages("leaflet")
library(leaflet)
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>% # 기본 지도 불러오기
  addPolygons(data = bnd, weight=3, color="red", fill=NA) %>% # 서울시 경계선 불러오기
  addResterImage(raster_high,
                 colors = colorNumeric(c("blue", "green", "yellow", "red"),
                                       values(raster_high), na.color = "transparent"), opacity=0.4)
                 
# 8단계 :  
dir.create("07_map")
save(raster_high, file="./07_map/07_kde_high.rdata")
rm(list=ls())
                 


#---------------------------------------------------------#
  
  # 1단계 : 데이터 준비
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
load("./06_geodataframe/06_apt_price.rdata")
grid <- st_read("./01_code/01_code/sigun_grid/seoul.shp")
apt_price <- st_join(apt_price, grid, join=st_intersects)

head(apt_price, 2)

# 2단계 : 변화율 확인
kde_before <- subset(apt_price, ymd < "2021-07-01") # 이전 데이터 필터링
kde_before <- aggregate(kde_before$py, by=list(kde_before$ID), mean) # 평균 가격
colnames(kde_before) <- c("ID", "before") # 칼럼명 변경

kde_after <- subset(apt_price, ymd < "2021-07-01") # 이후 데이터 필터링
kde_after <- aggregate(kde_after$py, by=list(kde_after$ID), mean) # 평균 가격
colnames(kde_after) <- c("ID", "after") # 칼럼명 변경

kde_diff <- merge(kde_before, kde_after, by="ID") # 이전+이후 데이터 결합
kde_diff$diff <- round((((kde_diff$after-kde_diff$before)/kde_diff$before) * 100), 0) # 변화율 계산

head(kde_diff, 2)


# 3단계 : 가격이 오른 지역 찾기
#install.packages("sf")
library(sf)

kde_diff <- kde_diff[kde_diff$diff >0,] # 상승 지역만 추출
kde_hot <- merge(grid, kde_diff, by="ID") #그리드에 상승 지역만 결합

#install.packages("ggplot2")
library(ggplot2)
#install.packages("dplyr")
library(dplyr)

kde_hot %>% # 그래프 시각화
  ggplot(aes(fill=diff)) + 
  geom_sf() + 
  scale_fill_gradient(low="white", high="red")


# 4단계 : 지도경계선 그리기
install.packages("sp")
library(sp)
kde_hot_sp <- as(st_geometry(kde_high), "Spatial") # sf형 => sp형 변환
x <- coordinates(kde_hot_sp)[,1] # 그리드 중심 x(경도), y(위도) 좌표 추출
y <- coordinates(kde_hot_sp)[,2]

# 기준 경계 설정
l1 <- bbox(kde_hot_sp)[1,1] - (bbox(kde_hot_sp)[1,1]*0.0001) # 그리드 기준 경계지점 설정
l2 <- bbox(kde_hot_sp)[1,2] + (bbox(kde_hikde_hot_spgh_sp)[1,2]*0.0001)
l3 <- bbox(kde_hot_sp)[2,1] - (bbox(kde_hot_sp)[2,1]*0.0001)
l4 <- bbox(kde_hot_sp)[2,2] + (bbox(kde_hot_sp)[1,1]*0.0001)
  
#install.packages("spatstat")
library(spatstat)

win <- owin(xrange=c(l1,l2), yrange=c(l3,l4)) # 지도 경계계선 생성
plot(win) # 지도 경계선 확인
rm(list = c("kde_hot_sp", "apt_price", "l1","l2","l3","l4")) # 변수 정리

# 5단계 : 밀도 그래프 변환하기
p <- ppp(x,y, window = win, marks=kde_hot$diff) # 경계선 위에 좌푯값 포인트 생성
d <- density.ppp(p, weights = kde_hot$diff, #커널 밀도 함수로 변환
                 sigma = bw.diggle(p),
                 kernel = 'gaussian')
plot(d) # 밀도 그래프 확인
rm(list = c("x", "y", "win", "p")) # 변수 정리


# 6단계 : 픽셀 -> 레스터 변환
d[d < quantile(d)[4] + (quantile(d)[4]*0.1)] <- NA #노이즈 제거
install.packages("raster")
library(raster)
raster_hot <- raster(d) #레스터 변환
plot(raster_hot) # 확인

# 7단계 : 불펼요한 부분 자르기
bnd <- st_read("./01_code/01_code/sigun_grid/seoul.shp")
raster_hot <- crop(raster_hot, extent(bnd))
crs(raster_hot) <- sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
plot(raster_hot)
plot(bnd, col=NA, border="red", add=TRUE)


# 8단계 
#install.packages("leaflet")
library(leaflet)
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>% # 기본 지도 불러오기
  addPolygons(data = bnd, weight=3, color="red", fill=NA) %>% # 서울시 경계선 불러오기
  addResterImage(raster_hot,
                 colors = colorNumeric(c("blue", "green", "yellow", "red"),
                                       values(raster_hot), na.color = "transparent"), opacity=0.4)


# 단계 :  평균 가격 변화율 정보 저장하기
save(raster_hot, file="./07_map/07_kde_hot.rdata")
rm(list=ls())



#-------------------------------------------#

#07-3 우리동네가 옆 동네보다 비쌀까?
# 특정 지역의 평균 가격을 주변 지역과 비교함

# 1단계 : 데이터 준비하기
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) # 작업폴더 설정
load("./06_geodataframe/06_apt_price.rdata") # 실거래 불러오기
load("./07_map/07_kde_high.rdata")# 최고가 래스터 이미지
load("./07_map/07_kde_hot.rdata") # 급등지 래스터 이미지

#install.packages("sf")
library(sf)

bnd <- st_read("./01_code/01_code/sigun_bnd/seoul.shp") #서울시 경계선
grid <- st_read("./01_code/01_code/sigun_grid/seoul.shp") # 서울시 그리드 파일

# 2단계 : 마커 클러스터링 옵션 설정
# 이상치 설정(하위 10%, 상위 90% 지점)
pcnt_10 <- as.numeric(quantile(apt_price$py, probs = seq(.1, .9, by=.1))[1])
pcnt_90 <- as.numeric(quantile(apt_price$py, probs = seq(.1, .9, by=.1))[9])

#마커 클러스터링 함수 등록
load("./01_code/01_code/sigun_grid/seoul.shp")

circle.colors <- sample(x=c("red"))


install.packages("purrr")
library(purrr)
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
# 메모리 정리하기기
rm(list=ls()) 














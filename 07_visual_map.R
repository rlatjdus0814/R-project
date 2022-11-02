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





install.packages("wordcloud") # wordcloud 패키지 설치 및 로딩
library(wordcloud)

word <- c("인천광역시", "강화군", "웅진군")
frequency <- c(651, 85, 61)

wordcloud(word, frequency, colors=rainbow(length(word))) # 워드 클라우드 출력

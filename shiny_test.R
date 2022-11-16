#=============================#
# 09-1 처음 만나는 샤이니
#=============================#

# 1단계 : 샤이니 기본 구조의 이해
# 실행 시 [Run App] 버튼 누르지 말고 Ctrl + Enter(실행단축키) 키를 사용하세요.
# install.packages("shiny")
library(shiny)

ui <- fluidPage("사용자 인터페이스")
server <- function(input, output, session) { }
shinyApp (ui, server)

# 2단계 : 샘플 실행하기
runExample("01_hello") # 샘플 보여주기

# 3단계 : 사용자 인터페이스 부분
ui <- fluidPage(
  titlePanel("샤이니 1번 샘플"), # 타이틀 입력
  # 레이아웃 구성 : 사이드바 패널 + 메인 패널
  sidebarLayout(
    sidebarPanel( # 사이드바 패널 시작
      # 입력값 : input$bins 저장
      sliderInput(inputId = "bins", # 입력 아이디
                  label = "Number of bins:", # 텍스트 라벨
                  min = 1, max = 50, # 선택 범위 (1-50)
                  value = 30) # 기본 선택 값 30
    ),
    mainPanel( # 메인 패널 시작
      # 출력값 : output$disPlot 저장
      plotOutput(outputId = "distPlot") # 차트 출력
      
    )
  )
)

# 4단계 : 01_hello 샘플의 서버 부분
server <- function(input, output, session) {
  output$disPlot <- renderPlot({ # 랜더링한 플룻을 output 인자의 disPlot에 저장
    x <- faithful$waiting # 분출대기시간 정보 저장
    bins <- seq(min(x), max(x), length.out = input$bins +1) # input$bins을 플룻으로 랜더링
    hist(x, breaks = bins, col="#75AADB", border="white",
         xlab = "다음 분출때까지 대기시간(분)",
         main = "대기시간 히스토그램")
  })
}

shinyApp (ui, server)


#=============================#
# 09-2 입력과 출력하기
#=============================#

# 1단계 : 입력받기 input$~
ui <- fluidPage(
  sliderInput("range", "연비", min=0, max=35, value=c(0, 10)) # 데이터 입력
)
server <- function(input, output, session) {} # 반응 업음
shinyApp(ui, server) # 실행

# 2단계 : 출력하기 output$~
ui <- fluidPage(
  sliderInput("range", "연비", min=0, max=35, value=c(0, 10)), textOutput("value") # 데이터 입력
)
server <- function(input, output, session) {
  output$value <- renderText((input$range[1] + input$range[2]))
} 
shinyApp(ui, server)






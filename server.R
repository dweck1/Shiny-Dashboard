library(shiny)
library(shinydashboard)
library(gbm)
library(Rborist)
library(DT)

source('data.R')

shinyServer(function(input, output, session) {

#EDA TAB ----------------------------------------------
  eda_team_data <- reactive({
    eda_team_data <- NFL %>% filter(team == input$eda_team)
  })
    
  #Boxplot on EDA tab
  output$boxplot <- renderPlotly({
    
    if(!input$team_bool){
    
      boxplot <- plot_ly(NFL, y = ~wins_next_year, type = 'box', color = ~team, colors= ~primary)
      boxplot <- boxplot %>% layout(xaxis = list(title = 'Team'), yaxis = list(title = 'Wins'))
      boxplot
    }
    else{
      boxplot <- plot_ly(eda_team_data(), y = ~wins_next_year, type = 'box', color = ~team, colors= ~primary)
      boxplot <- boxplot %>% layout(yaxis = list(title = 'Wins'))
      boxplot
    }
  })
  
  
  #Scatterplot on EDA tab
  output$scatter <- renderPlotly({
    
    if(!input$team_bool){
      scatter <- plot_ly(NFL, x = ~get(input$eda_var1), y = ~wins_next_year + rnorm(nrow(NFL), 0, .25),
                         type = 'scatter', mode = 'markers', color = ~team, colors = ~primary)
      scatter <- scatter %>% layout(xaxis = list(title = str_to_title(str_replace_all(input$eda_var1, '_', ' '))), 
                                    yaxis = list(title = 'Wins Next Year'))
      scatter
    }
    else{
      scatter <- plot_ly(eda_team_data(), x = ~get(input$eda_var1), y = ~wins_next_year + rnorm(nrow(eda_team_data()), 0, .25),
                         type = 'scatter', mode = 'markers', color = ~team, colors = ~secondary, size = I(100))
      scatter <- scatter %>% layout(xaxis = list(title = str_to_title(str_replace_all(input$eda_var1, '_', ' '))),
                                    yaxis = list(title = 'Wins Next Year'))
      scatter
    }

  })
  
  #Title for scatterplot
  output$scatter_title <- renderUI({
    paste('Scatterplot of Wins Next Year vs', str_to_title(str_replace_all(input$eda_var1,'_', ' ')), '(Jitter Added)')
    })
  
  #Summary stats for wins
  output$wins_table <- renderTable({
    
    if(!input$team_bool){
      
      t(as.matrix(summary(NFL$wins_next_year)))
      
    }
    else{
      t(as.matrix(summary(eda_team_data()$wins_next_year)))
    }
  })
  
  #Histogram for predictor variables
  output$hist <- renderPlotly({
    
    if(!input$team_bool){
      
      hist <- plot_ly(NFL, x = ~get(input$eda_var1), type = 'histogram')
      hist <- hist %>% layout(xaxis = list(title = str_to_title(str_replace_all(input$eda_var1, '_', ' '))),
                              yaxis = list(title = ''))
      hist
      
    }
    else{
      hist <- plot_ly(eda_team_data(), x = ~get(input$eda_var1), 
                      type = 'histogram', color = ~team, colors = ~secondary, nbinsx = 20)
      hist <- hist %>% layout(xaxis = list(title = str_to_title(str_replace_all(input$eda_var1, '_', ' '))),
                              yaxis = list(title = ''))
      hist
    }
  })
  
  #Title for histogram
  output$hist_title <- renderUI({
    paste('Histogram of', str_to_title(str_replace_all(input$eda_var1, '_', ' ')))
  })
  
  
#Clustering Tab --------------------------------------- 
  
  cluster_data <- reactive({
    NFL[, c(input$clustering_var1, input$clustering_var2)]
  })
  
  kmeans_clust <- reactive({
    kmeans(cluster_data(), centers = input$n_clusters)
  })
  
  output$clust_plot <- renderPlotly({
    
    clust_plot <- plot_ly(cluster_data(), x = ~get(input$clustering_var1), y = ~get(input$clustering_var2),
                          type = 'scatter', mode = 'markers',
                          color = kmeans_clust()$cluster, 
                          colors = c('#F5F91F', '#1F7EF9', '#F9261F', '#1FF92A', '#F91FE1',
                                     '#F99211', '#F9117D', '#11F9EB', '#192573', '#D81D15'),
                          size = I(50)) %>%
                  add_markers(kmeans_clust()$centers[,1], kmeans_clust()$centers[,2],
                              symbol = I(8), 
                              color = I('Black'),
                              alpha = I(1),
                              size = I(2000)) %>%
                  layout(xaxis = list(title = str_to_title(str_replace_all(input$clustering_var1, '_', ' '))),
                         yaxis = list(title = str_to_title(str_replace_all(input$clustering_var2, '_', ' '))),
                         showlegend = FALSE) %>%
                  hide_colorbar()
  })
  
  hclustering <- reactive({
    hclust(dist(cluster_data()), method = input$linkage)
  })
  
  output$dendrogram <- renderPlot({
    plot(as.dendrogram(hclustering()), xlab = 'Height', ylab = '', main = 'Dendrogram',
         nodePar = list(pch = 19, col = 2, cex = .2),
         edgePar = list(col = 4),
         leaflab = 'none',
         horiz = TRUE)
  })
  
#Modelling Tab ----------------------------------------
  
  output$model_title <- renderUI({
    
    if(input$ml_model == "Gradient Boosted Trees"){
      'Gradient Boosting Model for NFL Data'
    }
    else{'Random Forest Model for NFL Data'}
  })
  
  output$model_sub <- renderUI({

      withMathJax(
        helpText('Note: Both models attempt to minimize mean squared error: $$\\frac{1}{n}\\sum_{i=1}^{n}(y_{i} - \\hat{f}(x_{i})) ^ 2$$')
      )
    
  })
  
  model <- reactive({
    
    if(input$ml_model == 'Gradient Boosted Trees'){
      
        gbm(wins_next_year ~ ., data = NFL_df, distribution = 'gaussian', 
            n.trees = input$gbm_trees,
            shrinkage = input$shrinkage)
    }
    else {
      
        Rborist(x_vars, NFL_df$wins_next_year, nTree = input$rf_trees)
      
    }
  })

  pred_team_data <- reactive({filter(NFL_2019, team == input$prediction_team)})
  
  prediction <- reactive({
    if(input$ml_model == 'Gradient Boosted Trees'){
        predict(model(), newdata = pred_team_data(), n.trees = input$gbm_trees)
    }
    else{
        predict(model(), newdata = pred_team_data())
    }
    
  })

  output$pred <- renderUI({
    if(input$prediction_team %in% as.factor(NFL$team)){
      paste(input$prediction_team, 'is predicted to win', round(prediction(), 0), 'games')
    }
    else{
      'No team has been selected yet.'
    }
  })
  
#Data Tab ---------------------------------------------
  
  table_data <- reactive({
    
    if(input$data_team %in% as.factor(NFL$team)){
      filter(NFL, team == input$data_team)
    }
    else {
      NFL
    }
  })

  output$data_table <- renderDataTable({
    
    datatable(table_data(), options = list(scrollX = TRUE))
    
    })
  
  output$download_data <- downloadHandler(
    filename = "selected_NFL_data.csv",
    content = function(file) {
      write_csv(table_data(), file)
    },
    contentType = "text/csv"
  )
})
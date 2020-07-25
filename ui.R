library(shiny)
library(shinydashboard)

source('data.R')

dashboardPage(
    
# Header ----------------------------------------------
    dashboardHeader(title = 'NFL Win Predictions'),

#Sidebar ----------------------------------------------
    dashboardSidebar(
        sidebarMenu(id = 'sidebar',
            
            menuItem('Info',  
                     tabName = 'info', 
                     icon = icon('info-circle')
                    ),
            
            menuItem('EDA', 
                     tabName = 'eda', 
                     icon = icon('chart-bar')
                    ),
                conditionalPanel('input.sidebar == "eda"',
                    selectizeInput('eda_var1',
                                    'Select a predictor to explore',
                                    choices = colnames(x_vars),
                                    selected = 'points_scored'
                                    ),
                    checkboxInput('team_bool',
                                   'Explore a specific team'
                                  ),
                    conditionalPanel('input.team_bool',
                         selectizeInput('eda_team',
                                        'Select a team to explore',
                                        choices = as.factor(NFL$team),
                                        selected = NULL
                                        )
                    )
                ),
            
            
            menuItem('Clustering', 
                     tabName = 'clustering', 
                     icon = icon('object-group')
                    ),
                conditionalPanel('input.sidebar == "clustering"',
                     selectizeInput('clustering_var1',
                                    'Select the X variable',
                                    choices = colnames(x_vars),
                                    selected = 'points_scored'
                                    ),
                     selectizeInput('clustering_var2',
                                    'Select the Y variable',
                                    choices = colnames(x_vars),
                                    selected = 'yards_per_play'
                                    ),
                     sliderInput('n_clusters',
                                 'Select the number of clusters',
                                 min = 1,
                                 max = 10,
                                 value = 4
                                 ),
                     selectizeInput('linkage',
                                    'Select linkage for hierarchical clustering',
                                    choices = c('complete', 'single', 'average'),
                                    selected = 'complete'),
                ),
            
            menuItem('Modelling', 
                     tabName = 'modelling', 
                     icon = icon('project-diagram')
                    ),
                conditionalPanel('input.sidebar == "modelling"',
                     selectizeInput('ml_model',
                                    'Select the type of model',
                                    choices = c('Lasso', 'Random Forest'),
                                    selected = 'Lasso'
                                    ),
                     conditionalPanel('input.ml_model == "Lasso"',
                        sliderInput('lambda', 'Lambda',
                                    min = 0, 
                                    max = 1000,
                                    value = 0
                                    )
                        ),
                     conditionalPanel('input.ml_model == "Random Forest"',
                        selectizeInput('n_trees', 'Select the number of trees',
                                       choices = c(300, 400, 500, 600, 700, 800, 900, 100),
                                       selected = 500
                                       )
                        ),
                     checkboxGroupInput('ml_vars',
                                        'Which statistics would you like to use?',
                                        choices = list('Offensive' = 1,
                                                       'Defensive' = 2),
                                        selected = c(1,2)
                                        ),
                     checkboxInput('predictions',
                                   'Make predictions for 2020'
                                   ),
                     conditionalPanel('input.predictions',
                        selectizeInput('prediction_team',
                                       'Select which team to predict',
                                       choices = as.factor(NFL$team),
                                       selected = NULL)
                        )
                     
                 ),
            
            menuItem('Data', 
                     tabName = 'data', 
                     icon = icon('table')
                    )
            
                )
    ),

# Body ------------------------------------------------
    dashboardBody(
        tabItems(
            
            #- Info Tab--------------------------------
            tabItem('info', 
                fluidRow(
                    box(
                        title = 'About the Data',
                        width = "6 col-lg-4",
                        height = 570,
                        solidHeader = TRUE,
                        status = 'info',
                        p(class = 'text-center', img(src = 'nfl_teams.png', height = 200, width = 200)
                          ),
                        p('The data set used in the dashboard consists of season wins, losses, and various offensive',
                          'and defensive statistics for each NFL team dating back to the 1999 season. The full,',
                          'uncleaned dataset can be found', 
                          a(href = 'https://www.kaggle.com/ttalbitt/american-football-team-stats-1998-2019', 'here.'),
                          'I have adjusted the dataset so that for each year, the win total column represents the',
                          'number of wins the team had the', em('following'), 'year. The goal of this dashboard is',
                          'to predict how many games a team will win based on their statistics from the previous',
                          'year. It is important to note that these predictions will', strong('not'), 
                          'take into account drastic roster changes that may lead to significant changes in wins.',
                          'The dataset only contains stats such as total points scored, average yards per play, etc.',
                          'The full, cleaned dataset can be found on the Data tab.'
                          )
                        ),
                    
                    box(
                        title = 'About the Dashboard',
                        width = "6 col-lg-4",
                        height = 570,
                        solidHeader = TRUE,
                        status = 'info',
                        p(class = 'text-center', img(src = 'shiny2.webp', height = 200, width = 350)
                        ),
                        p('Beyond the home page, the dashboard consists of 4 interactive pages. On the',strong("EDA"),
                          'tab the user can generate various graphical and numerical summaries for the entire',
                          'league or for a selected team. On the', strong("Clustering"), 'tab, the user',
                          'can perform K-Means using selected variables and a selected number of clusters. A plot',
                          'displays the clusters and centroids created from the selected K-Means options. The user',
                          'can also perform hierarchical clustering and select which linkage method they would like.',
                          'A dendrogram is plotted with the result. On the', strong("Modelling"), 'tab, there',
                          'are options to create LASSO and Random Forest models to predict the total number of games',
                          'a team will win next year. The user has the option to adjust certain tuning parameters',
                          'for each model. Finally, on the', strong("Data"), 'tab, the user can view and download',
                          'the entire dataset or a dataset filtered by team.')
                    ),
                    
                    box(
                        title = 'About the Creator',
                        width = "6 col-lg-4",
                        height = 570,
                        solidHeader = TRUE,
                        status = 'info',
                        p(class = 'text-center', img(src = 'Capture.png', height = 200, width = 225)
                        ),
                        p('My name is David Weck. I recently graduated from', 
                        span("North Carolina State University", style = "color:red"), 'with a masters degree in',
                        'statistics. Prior to graduate school, I attended the', 
                        span("University of Florida", style = "color:blue"), 'and graduated with bachelors degrees',
                        'in statistics and finance.'
                        ),
                        p('I am an avid sports fan and especially love college football', 
                        'and the NFL. I stick to my undergraduate roots when it comes to my college football team.',
                        'I was born and raised a Florida Gator fan and bleed', span("orange", style = "color:orange"),
                        'and', span("blue.", style = "color:blue"), 'As for the NFL, my team is the Green Bay',
                        'Packers.'
                        ),
                        p('I had a lot of fun creating this application and hope you find it interesting to play',
                        'around with.', strong("Thank you!")
                        )
                    )
                )
            ),
            
            # EDA Tab ---------------------------------
            tabItem('eda',
                    h2('Graphical and Numerical Summaries of NFL Data'),
                    fluidRow(
                        column(width = 6, 
                               h4("Boxplot of Wins each Year", align = 'center'), 
                               plotlyOutput('boxplot')),
                        column(width = 6, 
                               h4(uiOutput('scatter_title'), align = 'center'), 
                               plotlyOutput('scatter'))
                    ),
                    fluidRow(
                        column(width = 4,
                               h4('Summary Statistics for Wins', align = 'center'),
                               tableOutput('wins_table')),
                        column(width = 2, 
                               h4('How to download a plot', align = 'center'),
                               p('1. Hover over plot you want to download'),
                               p('2. Locate menu icons in top right'),
                               p('3. Click on the camera icon (far left icon)')),
                        column(width = 6,
                               h4(uiOutput('hist_title'), align = 'center'),
                               plotlyOutput('hist'))
                    ) 
            ),
            
            # Clustering tab --------------------------
            tabItem('clustering',
                    h2('K-Means Clustering of 2 Predictors'),
                    plotlyOutput('clust_plot'),
                    h2('Dendrogram from Hierarchical Clustering of the 2 Predictors'),
                    plotOutput('dendrogram')
                    ),
            
            # Modelling tab ---------------------------
            tabItem('modelling'
                    )
        )
    )
)

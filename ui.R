library(shiny)
library(shinydashboard)

dashboardPage(
    
    dashboardHeader(title = 'NFL Win Predictions'),
    
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
            
            menuItem('Clustering', 
                     tabName = 'clustering', 
                     icon = icon('object-group')
            ),
            
            menuItem('Modelling', 
                     tabName = 'modelling', 
                     icon = icon('project-diagram')
            ),
            
            menuItem('Data', 
                     tabName = 'data', 
                     icon = icon('table')
            )
            
        )
    ),
    
    dashboardBody(
        tabItems(
            
            tabItem('info', 
                fluidRow(
                    box(
                        title = 'About the Data',
                        width = "6 col-lg-4",
                        solidHeader = TRUE,
                        status = 'info',
                        p(class = 'text-center', img(src = 'nfl_teams.png', height = 200, width = 200)
                          ),
                        p('The data set used in this dashboard consists of season wins, losses, and various offensive',
                          'and defensive statistics for each NFL team dating back to the 1999 season. The full,',
                          'uncleaned dataset can be found', 
                          a(href = 'https://www.kaggle.com/ttalbitt/american-football-team-stats-1998-2019', 'here.'),
                          'I have adjusted the dataset so that for each year, the win total column represents the',
                          'number of wins the team had the', em('following'), 'year. The goal of this dashboard is',                             'to predict how many games a team will win based on their statistics from the previous',
                          'year. It is important to note that these predictions will', strong('not'), 
                          'take into account drastic roster changes that may lead to significant changes in wins.',
                          'The dataset only contains stats such as total points scored, average yards per play, etc.',
                          'The full, cleaned dataset can be found on the Data tab.'
                          )
                        ),
                    
                    box(
                        title = 'About the Dashboard',
                        width = "6 col-lg-4",
                        solidHeader = TRUE,
                        status = 'info',
                        p(class = 'text-center', img(src = 'shiny2.webp', height = 200, width = 350)
                        ),
                        p('Beyond this home page, the dashboard consists of 4 interative pages. On the',strong("EDA"),
                          'tab the user can generate various graphical and numerical summaries for the entire',
                          'league, a single division, or a specific team. On the', strong("Clustering"), 'tab, the',
                          'user can perform K-Means clustering using selected variables and a selected number of',
                          'clusters. A plot displays the clusters and centroids created from the selected options.',
                          'On the', strong("Modelling"), 'tab, there are options to create LASSO and random forest',
                          'models to predict the total number of wins a team will win next year. The user has the',
                          'option to adjust certain tuning parameters for each model. Finally, on the', 
                          strong("Data"), 'tab, the user can view and download the entire dataset or a dataset',
                          'filtered by team.')
                    ),
                    box(
                        title = 'About the Creator',
                        width = "6 col-lg-4",
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
                        'Packers. '
                        ),
                        p('I had a lot of fun creating this application and hope you find it interesting to play',
                        'around with.', strong("Thank you!")
                        )
                    )
                )
            ),
            
            tabItem('eda',
                    p('EDA'))
        )
    )
)

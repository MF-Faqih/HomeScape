# HomeScape

![](https://github.com/MF-Faqih/HomeScape/blob/main/app-gif.gif)

HomeScape is an application designed to help anyone who looking for an apartment located in Jakarta. Here you can find various types of apartment spread in Jakarta, either if you want to choose them by their characteristic or by their location. This application is different than any other application that might be you know before, this not just provides a list of available apartments, but also equipped with machine learning to help users get better decisions before they buy an apartment. If summarized, the usefulness of this application includes:

- Providing various types of apartments around Jakarta
- Users can choose either by their location or their characteristics
- Using Machine Learning, this application can provide convenience for users before they made any decisions

If you want to see the HomeScape architecture, you can see it here: [HomeScape architecture](https://rpubs.com/MF-Faqih/HomeScape-Architecture)

If you want to try the apps, you can try them here: [HomeScape application](https://mffaqih.shinyapps.io/homescape/)

# A Little About HomeScape Architecture

HomeScape was built using [R](https://www.r-project.org/about.html) language, a language designed for statistical computing and graphics, then deploying the result in [shinyapps](https://www.rstudio.com/products/shiny/), an open-source R package that provides an elegant and powerful web framework for building web applications using R. The making of this project was going through several stages.

  - Data preparation
  - Data preprocessing
  - Machine learning
  - Data analysis

## Data Preparation

Here, I'm using two data to make HomeScape. The first data I obtained by doing web scrapping from [lamudi.co.od](https://www.lamudi.co.id/), this data was used for analysis and machine learning. The second data was map data with JSON data type that I obtained from [GADM](https://gadm.org/download_country_v3.html), this data was used to build an interactive map using a leaflet.

## Data Preprocessing

Before I'mm doing any analysis or prediction using machine learning, I need to clean my data to make sure it's quality, consistency, and compatibility. Anything that is done here such as handling outliers, handling abnormal values, and handling missing values.

## Machine Learning

Here I'm using two kinds of machine learning:

- **Classification Machine Learning** to make price predictions based on apartment characteristics. The two models are
  - [Decision Tree](https://www.mastersindatascience.org/learning/machine-learning-algorithms/decision-tree/)
  - [Random Forest](https://www.analyticsvidhya.com/blog/2021/06/understanding-random-forest/)
- [**K-Means Clustering**](https://towardsdatascience.com/understanding-k-means-clustering-in-machine-learning-6a6e67336aa1) to group each apartment into groups with similar characteristics



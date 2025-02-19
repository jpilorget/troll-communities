# An atempt to detect troll communities in Twitter

## Exploratory Data Analysis
1. Frequency and distributions of variables
2. Feature engineering (attribute selection and creation)
3. Descriptive analysis

## Analyze connections between users by looking at retweets
1. Establish the retweet criteria
2. Build an Adjacency Matrix
3. Build the graph
4. Plot it

## Analyze connections between users by looking at common words used
1. Build TermDocumentMatrix
2. Transform it into an Adjacency Matrix
3. Build the graph
4. Plot it

## Develop auxiliary metrics for troll detection
1. Clustering: k-means vs. DBSCAN
2. Tightely and loosely clustered tweets. How to detect them:

* Malicious accounts are likely newer than the average account.
* They follow way more people than they have followers.
* The do not enable geolocation.
* Suspicious users are between 500 and 20000. 
* They follow more than 1000 users

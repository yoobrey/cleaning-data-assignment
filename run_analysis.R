##
## This script takes the Human Activity Recognition dataset files to create a
## single unified data file. This joins the training set and test set together,
## and will include the following contents:
##  participant ID
##  set type
##  activity type
##  all mean values provided by the raw data
##  all standard deviation values provided by the raw data
##

## Check if raw data directory exists
if (!dir.exists("./data/raw/UCI HAR Dataset")) {
  dir.create("./data/raw/")
  rawurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  rawdest <- "./data/raw/UCI HAR Dataset.zip"
  
  download.file(rawurl, rawdest)
  unzip(rawdest, exdir = "./data/raw/")
}

## Create training data frame and test data frame as intermediate for
## aggregating the necessary data for the corresponding set type.
testdf <- read.table("./data/raw/UCI HAR Dataset/test/subject_test.txt")
traindf <- read.table("./data/raw/UCI HAR Dataset/train/subject_train.txt")

## Change the ID column name and create a column indicating set type for the
## data frames.
testdf[1:nrow(testdf), "SetType"] <- "test"
traindf[1:nrow(traindf), "SetType"] <- "training"

names(testdf)[1] <- "SubjectID"
names(traindf)[1] <- "SubjectID"

## Make data frames of the following files: activity type file, feature set file.
testset <- read.table("./data/raw/UCI HAR Dataset/test/X_test.txt")
testact <- read.table("./data/raw/UCI HAR Dataset/test/y_test.txt")

trainset <- read.table("./data/raw/UCI HAR Dataset/train/X_train.txt")
trainact <- read.table("./data/raw/UCI HAR Dataset/train/y_train.txt")

## Make data frames for the activity labels and features guide as references
## when transforming corresponding data.
activities <- read.table("./data/raw/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./data/raw/UCI HAR Dataset/features.txt")

## Append the activity levels column into the respective data frames. Convert
## the numbers into descriptive names as indicated in activity_labels.txt.
testdf[, "Activity"] <- as.character(testact[, 1])  # Make the columns
traindf[, "Activity"] <- as.character(trainact[, 1])

testdf$Activity <- sapply(testdf$Activity, function(x) {  # Sub names for numbers
  sub(x, activities[x, 2], x)
})

traindf$Activity <- sapply(traindf$Activity, function(x) {
  sub(x, activities[x, 2], x)
})

## Use grep to find all rows containing the pattern "mean()" and "std()", to be
## treated as indices, from features.txt.
featM <- grep("mean()", features$V2, fixed = T)  # Find indices from features.txt
featS <- grep("std()", features$V2, fixed = T)

features$V2 <- gsub("()", "", features$V2, fixed = T) # Clean the feature names

## Use the numbers to pick the appropriate columns and column names from the
## feature sets, and add those to the respective data frames.
for (col in featM) {
  testdf[, features[col, 2]] <- as.numeric(testset[, col])
  traindf[, features[col, 2]] <- as.numeric(trainset[, col])
}

for (col in featS) {
  testdf[, features[col, 2]] <- testset[, col]
  traindf[, features[col, 2]] <- trainset[, col]
}

## Merge the data sets into one cohesive data set.
unifiedset <- merge(testdf, traindf, all = T)

## Output as CSV to ./data directory.
write.csv(unifiedset, "./data/processed_data.csv", row.names = F)
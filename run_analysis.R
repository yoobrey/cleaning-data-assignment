##
## This script takes the Human Activity Recognition dataset files to create a
## single cleaned data file. This joins the training set and test set together,
## and will include the following contents:
##  participant ID
##  set type
##  activity type
##  mean average of all mean values provided by the raw data
##  mean average of all standard deviation values provided by the raw data
##

library(dplyr)

## Check if raw data directory exists

if (!dir.exists("./data/raw/UCI HAR Dataset")) {
  dir.create("./data/raw/")
  rawurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  rawdest <- "./data/raw/UCI HAR Dataset.zip"
  
  download.file(rawurl, rawdest)
  unzip(rawdest, exdir = "./data/raw/")
}

## Create training data frame and test data frame to which all other variables
## will be attached.

testdf <- read.table("./data/raw/UCI HAR Dataset/test/subject_test.txt")
traindf <- read.table("./data/raw/UCI HAR Dataset/train/subject_train.txt")

## Change the ID column name and create a column indicating set type for the
## data frames.

names(testdf)[1] <- "SubjectID"
names(traindf)[1] <- "SubjectID"

testdf[1:nrow(testdf), "SetType"] <- "test"
traindf[1:nrow(traindf), "SetType"] <- "training"

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

# Make the columns
testdf[, "Activity"] <- as.character(testact[, 1])
traindf[, "Activity"] <- as.character(trainact[, 1])

# Numbers --> names
testdf$Activity <- sapply(testdf$Activity, function(x) {
  sub(x, activities[x, 2], x)
})

traindf$Activity <- sapply(traindf$Activity, function(x) {
  sub(x, activities[x, 2], x)
})

## Use grep to find all rows containing the pattern "mean()" and "std()", to be
## treated as indices, from features.txt.

# Find indices from features.txt
featM <- grep("mean()", features$V2, fixed = T)
featS <- grep("std()", features$V2, fixed = T)

# Clean the feature names
features$V2 <- gsub("[()]", "", features$V2)

## Go through the column names from features.txt to serve as variable names,
## then index the corresponding column containing the actual values from the
## features set.

for (col in featM) {
  testdf[, features[col, 2]] <- as.numeric(testset[, col])
  traindf[, features[col, 2]] <- as.numeric(trainset[, col])
}

for (col in featS) {
  testdf[, features[col, 2]] <- testset[, col]
  traindf[, features[col, 2]] <- trainset[, col]
}

## Merge the test data frame and training data frame into one data set.

unifiedset <- merge(testdf, traindf, all = T)

## Group the data by subject, set type, and activity; compute all the means
## across all variables.

unifiedset <- 
  data.frame(unifiedset %>%
  group_by(SubjectID, SetType, Activity) %>%
  summarize(across(everything(), list(mean))))

## Final cleanup of variable names to make it easier to read and glance over,
## and change erratic var names to conform as described in features_info.txt
## (eg. "BodyBody" occurences).

names(unifiedset) <- gsub("[_1]", "", names(unifiedset))
names(unifiedset) <- gsub("^t", "time.", names(unifiedset))
names(unifiedset) <- gsub("^f", "freq.", names(unifiedset))
names(unifiedset) <- gsub("BodyBody", "Body", names(unifiedset))

## Output as text file to ./data directory.

write.table(unifiedset, "./data/processed_data.txt", row.names = F)
# Getting and Cleaning Data Course Project

This R script takes the [UCI HAR data set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and combines the subject IDs, activity types, and the measurement means and standard deviations from the training and test sets. The mean average for the provided measurement means and standard deviations was calculated across all subjects, activity types, and set types; the process results are outputted into a text file.

The repository should include:
* This README
* CodeBook.md describing the processed data
* `run_analysis.R` for the process, located in the `./data/` folder
* The processed data file

The raw data set, if not downloaded, will be downloaded automatically by the script when run. Opening the processed data file in R can be done with `read.table("./data/processed_data.txt", header = TRUE)`.

## R version

The data processed data provided in this repository was created using R version 4.0.3.

## Required packages

The script provided in this repository requires the `dplyr` package.

## Processes conducted

The important processes and transformations performed on the raw data to arrive with the tidy data are as follows:
1. The individual files for the subject IDs, activity types, and features measurements for both the training and test sets are read; each entry was given a proper label of what set they belong from within the data.
1. The mean and standard deviation measurements from the features set were selected and taken as a subset.
1. All relevant data for the test set and training set were combined (the training set and test set not yet merged); both sets were given proper and cleaned variable names.
1. The two sets are combined to form one unified set.
1. Subject IDs, set types, and activity types were grouped together, and the mean of all the obtained measurements across the groupings were computed through R.
1. The resulting data was written into a text file.
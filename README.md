==================================================================
Getting and Cleaning Data
Course Project
==================================================================
Dan Cogswell
==================================================================

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Here's how run_analysis.R works:
# 1. Merges the training and the test sets to create one data set.

#Identify the libraries needed
library(gdata)
library(reshape)
library(reshape2)

# Read the test data, test subject data and activity test data, merging into one
# dataframe named test.
test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
testSubject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test$subject <- testSubject$V1
testActivity <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
test$activityLevel <- testActivity$V1

# Read the train data, train subject data and activity train data, merging into one
# dataframe named train.
train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainSubject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train$subject <- trainSubject$V1
trainActivity <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
train$activityLevel <- trainActivity$V1

# merge test and train into a dataframe named merged.
merged <- merge(test, train, all=TRUE)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# Read the var names from features.txt.
features <- read.table("./data/UCI HAR Dataset/features.txt")
# Subset the dataframe by including only the mean and std. deviation columns.
featuresSubset <- subset(features, grepl(paste(c("-mean", "-std"), collapse= "|"), features$V2))
featuresSubset <- subset(featuresSubset, !grepl(paste(c("-meanFreq"), collapse= "|"), featuresSubset$V2))
# Make sure you keep the subject and activityLevel.
featuresSubset <- rbind(data.frame(V1 = nrow(features) + 1, V2 = "subject"), featuresSubset)
featuresSubset <- rbind(data.frame(V1 = nrow(features) + 2, V2 = "activityLevel"), featuresSubset)

# Apply the subset of column names to the merged dataframe.
merged <- merged[, featuresSubset$V1]

# 3. Uses descriptive activity names to name the activities in the data set
merged[merged$activityLevel=="1", 1] <- "WALKING"
merged[merged$activityLevel=="2", 1] <- "WALKING_UPSTAIRS"
merged[merged$activityLevel=="3", 1] <- "WALKING_DOWNSTAIRS"
merged[merged$activityLevel=="4", 1] <- "SITTING"
merged[merged$activityLevel=="5", 1] <- "STANDING"
merged[merged$activityLevel=="6", 1] <- "LAYING"

# 4. Appropriately labels the data set with descriptive variable names. 
colnames(merged) <- featuresSubset$V2

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
mMelt <- melt(merged, id=c("subject","activityLevel"))
tidyDS <- dcast(mMelt, subject + activityLevel ~ variable, mean, drop=FALSE)
write.table(tidyDS, "tidyDS.txt", row.names=FALSE) 


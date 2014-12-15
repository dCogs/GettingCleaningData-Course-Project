# run_analysis.R is the R script for the "Getting and Cleaning Data"
# Coursera course project. 
# It does the following. 

# 1. Merges the training and the test sets to create one data set.

library(gdata)
library(reshape)
library(reshape2)

test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
testSubject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test$subject <- testSubject$V1
testActivity <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
test$activityLevel <- testActivity$V1

train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainSubject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train$subject <- trainSubject$V1
trainActivity <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
train$activityLevel <- trainActivity$V1

merged <- merge(test, train, all=TRUE)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table("./data/UCI HAR Dataset/features.txt")
featuresSubset <- subset(features, grepl(paste(c("-mean", "-std"), collapse= "|"), features$V2))
featuresSubset <- subset(featuresSubset, !grepl(paste(c("-meanFreq"), collapse= "|"), featuresSubset$V2))
featuresSubset <- rbind(data.frame(V1 = nrow(features) + 1, V2 = "subject"), featuresSubset)
featuresSubset <- rbind(data.frame(V1 = nrow(features) + 2, V2 = "activityLevel"), featuresSubset)

merged <- merged[, featuresSubset$V1]

# 3. Uses descriptive activity names to name the activities in the data set
merged[merged$activityLevel=="1", 1] <- "WALKING"
merged[merged$activityLevel=="2", 1] <- "WALKING_UPSTAIRS"
merged[merged$activityLevel=="3", 1] <- "WALKING_DOWNSTAIRS"
merged[merged$activityLevel=="4", 1] <- "SITTING"
merged[merged$activityLevel=="5", 1] <- "STANDING"
merged[merged$activityLevel=="6", 1] <- "LAYING"

# 4. Appropriately labels the data set with descriptive variable names. 
#activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(merged) <- featuresSubset$V2

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
mMelt <- melt(merged, id=c("subject","activityLevel"))
mRecast <- dcast(mMelt, subject + activityLevel ~ variable, mean, 
                 value.var = "value", drop=FALSE, margins=TRUE)
#c("subject","activityLevel")

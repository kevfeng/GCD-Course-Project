setwd("./R/UCI HAR Dataset")
require(data.table)
require(plyr)

# Read and merge subject data into a table
testsubject <- read.table("./test/subject_test.txt")
trainsubject <- read.table("./train/subject_train.txt")
mergedsubject <- rbind(testsubject, trainsubject)
colnames(mergedsubject) <- "subject"

# Read and merge x data into a table
features <- as.vector(read.table("features.txt")[,2])
xtest <- read.table("./test/X_test.txt", as.is = TRUE, col.names = features, row.names = NULL)
xtrain <- read.table("./train/X_train.txt", as.is = TRUE, col.names = features, row.names = NULL)
mergedx <- rbind(xtest, xtrain)

# Read and merge y data into a table
ytest <- read.table("./test/Y_test.txt")
ytrain <- read.table("./train/Y_train.txt")
mergedy <- rbind(ytest, ytrain)
colnames(mergedy) <- "label"

# Add subject and label field to the x table and adds descriptive activity name to label
dfx <- cbind(mergedsubject, mergedy, mergedx)
dfx$label <- as.factor(dfx$label)
levels(dfx$label) <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")

# Identify and subset mean and standard deviation measurements
stdcol <- grep("std", colnames(dfx), value = TRUE)
meancol <- grep("mean", colnames(dfx), value = TRUE)
meancol <- meancol[! meancol %in% grep("Freq", meancol ,value = TRUE)]
keep <- c(stdcol, meancol, "subject", "label")
df <- dfx[,colnames(dfx) %in% keep]

# Averages each variable for each activity and subject
clean <- ddply(df, .(subject, label), numcolwise(mean))

# Exports the final tidy dataset as a txt file
write.table(clean, file = "cleanData.txt", row.names = FALSE)
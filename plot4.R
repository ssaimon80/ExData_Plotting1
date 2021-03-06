#our dataframe is stored in hpc_ssaimon80
#check if it exists already, and if not create it
if (!("hpc_ssaimon80" %in% ls())) {
  
  #download data file from the web into the ./download/ folder if it doesn't exist already
  if (!file.exists("./download/household_power_consumption.zip")) {
    if (!file.exists("./download")) {
      dir.create("./download");
    }
    download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",
                  "./download/household_power_consumption.zip", mode = "wb");
  }
  
  #load the dataset into a dataframe named hpc_ssaimon80
  #no need to close the connection since read.csv will do it
  message("Loading data in R ...");
  datacon <- unz("./download/household_power_consumption.zip", filename = "household_power_consumption.txt");
  hpc_ssaimon80 <- read.csv(datacon, sep = ";", header = T, stringsAsFactors = F, na.strings = "?");
  rm("datacon");
  
  #subset to only include dates 2007-02-01 and 2007-02-02
  message("Subsetting to relevant dates ...");
  hpc_ssaimon80 <- subset(hpc_ssaimon80, Date == "1/2/2007" | Date == "2/2/2007");
  
  #take the Date and Time columns and convert them into a datetime column
  message("Transforming data for processing ...");
  hpc_ssaimon80$datetime <- with(hpc_ssaimon80, strptime(paste(Date, Time), format = "%d/%m/%Y %T"));
  
  #remove the Date and Time
  hpc_ssaimon80$Date <- NULL;
  hpc_ssaimon80$Time <- NULL;
  
  #put datetime in first position just for convenience
  hpc_ssaimon80 <- hpc_ssaimon80[,c(8,1:7)];
}

# **** PLOT4 begins here ****

#create new png device
if (!file.exists("./ExploratoryDataAnalysis")) {
  dir.create("./ExploratoryDataAnalysis");
}
png("./ExploratoryDataAnalysis/plot4.png", width = 480, height = 480);

#this call necessary otherwise I get time labels in my own language ...
Sys.setlocale("LC_TIME", "C");

#set par so that 4 elements are drawn in col major order
par(mfcol = c(2,2));

#plot in position (1,1)
with(hpc_ssaimon80, plot(datetime, Global_active_power, type = "l", 
                         xlab = "", ylab = "Global Active Power (kilowatts)"));

#plot in position (2,1)
with(hpc_ssaimon80, plot(datetime, Sub_metering_1, type = "l", col = "black", 
                         xlab = "", ylab = "Energy sub metering"));
with(hpc_ssaimon80, lines(datetime, Sub_metering_2, col = "red"));
with(hpc_ssaimon80, lines(datetime, Sub_metering_3, col = "blue"));
legend("topright", col = c("black", "red", "blue"), lty = c(1,1,1),
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"));

#plot in position (1,2)
with(hpc_ssaimon80, plot(datetime, Voltage, type = "l"));

#plot in position (2,2)
with(hpc_ssaimon80, plot(datetime, Global_reactive_power, type = "l"));

#close the png device
dev.off();

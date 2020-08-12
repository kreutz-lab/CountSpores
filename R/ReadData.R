#' @name ReadData
#' @title reads in raw data and convert to useable format for analysis
#' @param file path to raw data file
#' @param sheets character vector with sheetnames of raw data file
#' @return One folder for each experiment where results are stored
#' @return Data_analysis  folder to store converted data files in excel format
#' @return data_proportional.xlsx columns with proportions, mean, sd, se, plotID added to raw data
#' @return data_prop_long.xlsx melted version of data_proportional
#' @export



ReadData = function(file){

  sheets <- openxlsx::getSheetNames(file)
  if (is.na(match('sheet', sheets)) == TRUE ){
    cat('Identified experiments: ', sheets, "\n")
  }
  else {
    print('Warning: Sheet name does not correspond to experiment.')
  }


  # Create output folder for each Experiment
  for (s in 1:length(sheets)){
      dir.create(paste(sheets)[s])
    }


  # Create folder for processed raw data, used in downstream analysis
  dir.create('Data_analysis')

  # Create Excel files
  wb1 = openxlsx::createWorkbook()
  wb2 = openxlsx::createWorkbook()



  # Set up list to store all results
  data_analysis = list()

  for (i in 1:length(sheets)){

    # Add proportions for each segment
    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheets[i]), rowNames=FALSE)

    # Check input
    if(all(c('Condition','Plate','Day') != colnames(data_raw[1:3]))==TRUE){
      stop('Error: First three columns need to be (Condition,Plate,Day)')
    }

    # How many segments per Plate?
    nseg = (ncol(data_raw)-3)/2
    l = seq(1, nseg, by=1)


    # Get segments and corresponding totals
    seg = data_raw[,c(4:(3+nseg))]
    total = data_raw[,c((4+nseg):ncol(data_raw))]

    # Colnames for proportion per segment
    proportions <- paste('Prop_', l, sep="")
    data_raw[proportions] <- NA

    # Calculate proportions
    data_raw[proportions] = seg/total*100


    # Add mean, sd & se
    data_raw$Mean = rowMeans(data_raw[proportions])
    data_raw$sd = apply(data_raw[proportions],1,sd)
    data_raw$se = data_raw$sd/sqrt(nseg)

    # Add ID for plots
    data_raw$plot_ID = paste(data_raw$Condition,data_raw$Plate,sep="")

    # Save raw data with proportions in new excel file
    openxlsx::addWorksheet(wb1, paste(sheets[i]))
    openxlsx::writeData(wb1,paste(sheets[i]), data_raw)

    # Convert to long format for input in linear mixed effects model
    data_prop = dplyr::filter(data_raw[,c('Condition','Plate','Day',proportions)])
    data_prop_long <- tidyr::gather(data_prop,Segment,Proportion,-c(Condition,Day,Plate))


    # Add dummy code for 'Condition'
    for (c in unique(data_prop_long$Condition)){
      col = paste('is',paste(c),sep="")
      data_prop_long$newcol = 0
      data_prop_long$newcol[data_prop_long$Condition==paste(c)] = 1
      colnames(data_prop_long)[colnames(data_prop_long)=='newcol'] = paste(col)

    }

    # Save raw data in long format in new excel file
    openxlsx::addWorksheet(wb2, paste(sheets[i]))
    openxlsx::writeData(wb2, paste(sheets[i]), data_prop_long)


    data_analysis[[i]] <- list(data_proportional = data_raw, data_prop_long = data_prop_long)
    names(data_analysis)[[i]] <- paste(sheets[i])
  }

  openxlsx::saveWorkbook(wb1, file='Data_analysis/data_proportional.xlsx', overwrite=TRUE)
  openxlsx::saveWorkbook(wb2, file='Data_analysis/data_prop_long.xlsx', overwrite=TRUE)

  return(data_analysis)



}



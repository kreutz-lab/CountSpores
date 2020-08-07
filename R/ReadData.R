#' @name ReadData
#' @title reads in raw data and convert to useable format for analysis
#' @param file path to raw data file
#' @param sheets character vector with sheetnames of raw data file
#' @return Data_analysis  folder to store converted data files in excel format
#' @return data_proportional.xlsx columns with proportions, mean, sd, se, plotID added to raw data
#' @return data_prop_long.xlsx melted version of data_proportional
#' @export



ReadData = function(file, sheets){

  # Create Data folder
  dir.create('Data_analysis')

  # Create Excel files
  wb1 = openxlsx::createWorkbook()
  wb2 = openxlsx::createWorkbook()


  for (i in 1:length(sheets)){

    # Add proportions for each segment
    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheets[i]))
    #data_raw[,c('Condition','Plate','Day')] = lapply( data_raw[,c('Condition','Plate','Day')], factor)
    data_raw$Prop1 = data_raw$Area1/data_raw$Area1_total*100
    data_raw$Prop2 = data_raw$Area2/data_raw$Area2_total*100
    data_raw$Prop3 = data_raw$Area3/data_raw$Area3_total*100
    data_raw$Mean = rowMeans(data_raw[,which(colnames(data_raw) %in% c('Prop1','Prop2','Prop3'))])
    data_raw$sd = apply(data_raw[,which(colnames(data_raw) %in% c('Prop1','Prop2','Prop3'))],1,sd)
    data_raw$se = data_raw$sd/sqrt(3)
    data_raw$plot_ID = paste(data_raw$Condition,data_raw$Plate,sep="")

    # Save raw data with proportions in new excel file
    openxlsx::addWorksheet(wb1, paste(sheets[i]))
    openxlsx::writeData(wb1,paste(sheets[i]), data_raw)

    # Convert to long format for input for linear mixed effects model
    data_prop = dplyr::filter(data_raw[,c('Condition','Plate','Day','Prop1','Prop2','Prop3')])
    data_prop_long <- tidyr::gather(data_prop,Fragment,Proportion,-c(Condition,Day,Plate))


    # Add dummy code for Condition
    for (c in unique(data_prop_long$Condition)){
      col = paste('is',paste(c),sep="")
      data_prop_long$newcol = 0
      data_prop_long$newcol[data_prop_long$Condition==paste(c)] = 1
      #data_prop_long$newcol = as.factor(data_prop_long$newcol)
      colnames(data_prop_long)[colnames(data_prop_long)=='newcol'] = paste(col)

    }

    # Save raw data in long format in new excel file
    openxlsx::addWorksheet(wb2, paste(sheets[i]))
    openxlsx::writeData(wb2, paste(sheets[i]), data_prop_long)
  }

  openxlsx::saveWorkbook(wb1, file='Data_analysis/data_proportional.xlsx', overwrite=TRUE)
  openxlsx::saveWorkbook(wb2, file='Data_analysis/data_prop_long.xlsx', overwrite=TRUE)



  #data_analysis = list(data_prop = data_prop, data_prop_long = data_prop_long)
  #return(data_analysis)

}



#' @name plotTimeCourse
#' @title plot raw data over time for each experiment
#' @param file path to data_proportional
#' @return 'sheetname'_timecourse.png in 'sheetname' folder
#' @export


plotTimeCourse = function(file='Data_analysis/data_proportional.xlsx',createDirs=FALSE){
  sheets <- openxlsx::getSheetNames(file)
  for (i in 1:length(sheets)){

    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheets[i]))

    if(!dir.exists(sheets[i]) && !createDirs)
      stop(paste0("Directory ",sheets[i]," does not exist which can occur if you didn't call ReadData(). Please call ReadData for data processing first or set argument createDirs=TRUE"))

    if(!dir.exists(sheets[i]) && createDirs)
      dir.create(sheets[i])

    if(!"Mean" %in% colnames(data_raw))
      stop(paste0("Column 'Mean' does not exist in the data. Please call ReadData() first and use the file Data_analysis/data_proportional.xlsx created as input here."))
    if(!"se" %in% colnames(data_raw))
      stop(paste0("Column 'se' does not exist in the data. Please call ReadData() first and use the file Data_analysis/data_proportional.xlsx created as input here."))
    if(!"plot_ID" %in% colnames(data_raw))
      stop(paste0("Column 'plot_ID' does not exist in the data. Please call ReadData() first and use the file Data_analysis/data_proportional.xlsx created as input here."))

    ggplot2::ggplot(data_raw, aes(x=Day, y=Mean, group=plot_ID, color=Condition)) +
      geom_point(size=0.1)+
      geom_line()+
      geom_pointrange(aes(ymin=Mean-se, ymax=Mean+se), size=0.5, fatten=0.2) +
      theme_bw()+
      ylab("Proportion")+
      ggtitle(paste(sheets[i]))+
      theme(plot.title=element_text(hjust=0.5, face='bold'))


    ggplot2::ggsave(paste(paste(sheets[i]),'/', paste(sheets[i]),'_timecourse.png',sep=""), height=4, width=5)

  }
}

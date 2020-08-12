#' @name plotTimeCourse
#' @title plot raw data over time for each experiment
#' @param file path to data_proportional
#' @return 'sheetname'_timecourse.png in 'sheetname' folder
#' @export


plotTimeCourse = function(file='Data_analysis/data_proportional.xlsx'){
  sheets <- openxlsx::getSheetNames(file)
  for (i in 1:length(sheets)){

    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheets[i]))

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

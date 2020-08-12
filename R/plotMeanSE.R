#' @name plotMeanSE
#' @title plot mean standard error relationship for each experiment
#' @param file path to data proportional
#' @return saves png file for each experiment
#' @export


plotMeanSE = function(file='Data_analysis/data_proportional.xlsx'){
  sheets <- openxlsx::getSheetNames(file)
  for (i in 1:length(sheets)){

    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheets[i]))

    ggplot2::ggplot(data_raw, aes(x=Mean, y=se, color=Condition)) +
      geom_point(size=0.5)+
      theme_bw()+
      ylab("SE")+
      ggtitle(paste(sheets[i]))+
      theme(plot.title=element_text(hjust=0.5, face='bold'))


    ggplot2::ggsave(paste(paste(sheets[i]),'/', paste(sheets[i]),'_mean_se.png',sep=""), height=4, width=5)

  }
}

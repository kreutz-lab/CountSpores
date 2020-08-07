#' @name plotMeanSE
#' @title plot mean standard error relationship for each experiment
#' @param file path to raw data file
#' @param sheetsnames character vector with sheetnames of raw data file
#' @return saves png file for each experiment
#' @export


plotMeanSE = function(file, sheetnames){

  for (i in 1:length(sheetnames)){

    data_raw = openxlsx::read.xlsx(file, sheet=paste(sheetnames[i]))
    #data_raw$Prop1 = data_raw$Area1/data_raw$Area1_total*100
    #data_raw$Prop2 = data_raw$Area2/data_raw$Area2_total*100
    #data_raw$Prop3 = data_raw$Area3/data_raw$Area3_total*100


    #data_raw$Mean = rowMeans(data_raw[,which(colnames(data_raw) %in% c('Prop1','Prop2','Prop3'))])
    #data_raw$sd = apply(data_raw[,which(colnames(data_raw) %in% c('Prop1','Prop2','Prop3'))],1,sd)
    #data_raw$se = data_raw$sd/sqrt(3)
    #data_raw$plot_ID = paste(data_raw$Condition,data_raw$Plate,sep="")

    ggplot2::ggplot(data_raw, aes(x=Mean, y=se, color=Condition)) +
      geom_point(size=0.5)+
      theme_bw()+
      ylab("SE")+
      ggtitle(paste(sheetnames[i]))+
      theme(plot.title=element_text(hjust=0.5, face='bold'))


    ggplot2::ggsave(paste(paste(sheetnames[i]),'/', paste(sheetnames[i]),'_mean_se.png',sep=""), height=4, width=5)

  }
}

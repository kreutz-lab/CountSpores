#' @name runCountSpores
#' @title Run complete CountSpores pipeline
#' @param file path to raw data
#' @return ReadData_out Output of ReadData
#' @return runAnova_out Output of runANOVA
#' @return One directory for each experiment with QC plots and test results
#' @export



runCountSpores = function(file){

  ReadData_out = ReadData(file)

  plotTimeCourse('Data_analysis/data_proportional.xlsx')

  plotMeanSE('Data_Analysis/data_proportional.xlsx')

  runANOVA_out = runANOVA('Data_Analysis/data_prop_long.xlsx')

  CountSpores_out <- list(ReadData_out = ReadData_out, runANOVA_out = runANOVA_out)

}

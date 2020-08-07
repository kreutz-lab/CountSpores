#' @name createOutputFolders
#' @title Create output directory for each experiment
#' @param sheets name of excel sheet, corresponding to the experiment
#' @return Directory for each experiment
#' @export



# Create output folder
CreateOutputFolders = function(sheets){
  for (s in 1:length(sheets)){
    dir.create(paste(sheets)[s])
  }
}

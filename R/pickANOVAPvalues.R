#' @name pickANOVAPvalues
#' @title Collects p-values form multiple ANOVA and arranges in readable format
#' @param anov result from ANOVA
#' @param refnames name of reference level used in ANOVA
#' @return panova symmetric table with p-values from multiple ANOVA
#' @export

pickAnovaPvalues = function(anov,refnames){

  panova = data.frame(matrix(NA, nrow = length(refnames), ncol = length(refnames)))


  for (i1 in 1:length(anov)){
    for (i2 in 1:length(refnames)){

      if (i1==i2) next
      else {
        pat = paste0('Day:',refnames[i2],sep="")
        res_anova = data.frame(anov[[i1]])
        ind = which(rownames(res_anova)==paste0(pat))

        panova[i1,i2] = res_anova$Pr..F.[ind]
        rownames(panova)[i1] = refnames[i1]
        colnames(panova)[i2] = refnames[i2]
      }
    }
  }

  # Make it symmetric
  panova = sqrt(panova*t(panova))
  return(panova=panova)
}


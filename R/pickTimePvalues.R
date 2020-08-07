#' @name pickTimePvalues
#' @title Collects estimated effects for multiple experiments and timepoints
#' @param fits results of linear mixed effects model
#' @param refnames name of reference level used in lme
#' @param times vector with timepoints of experiments
#' @return estTbl seTbl pTbl estimated effects, standard errors and p-values for all timepoints in each experiment
#' @export


pickTimePvalues = function(fits,refnames,times){

  estmatrix = list()
  sematrix = list()
  pmatrix = list()

  estTbl = list()
  seTbl = list()
  pTbl = list()



  for (t in 1:length(times)){
    estmatrix[[t]] = data.frame(matrix(NA, nrow = length(fits), ncol = length(fits)))
    sematrix[[t]] = data.frame(matrix(NA, nrow = length(fits), ncol = length(fits)))
    pmatrix[[t]] = data.frame(matrix(NA, nrow = length(fits), ncol = length(fits)))

    for (i1 in 1:length(refnames)){

      refnames=cname
      for (i2 in 1:length(refnames)){

        if (i1==i2) next
        else {
          pat = paste0('Day',paste0(times[t]),':',refnames[i2],'1',sep="")
          res_fixed = data.frame(coef(summary(fit[[i1]])))
          ind = which(rownames(res_fixed)==paste0(pat))

          estmatrix[[t]][i1,i2] = res_fixed$Estimate[ind]
          rownames(estmatrix[[t]])[i1] = refnames[i1]
          colnames(estmatrix[[t]])[i2] = refnames[i2]

          sematrix[[t]][i1,i2] = res_fixed$Std..Error[ind]
          rownames(sematrix[[t]])[i1] = refnames[i1]
          colnames(sematrix[[t]])[i2] = refnames[i2]

          pmatrix[[t]][i1,i2] = res_fixed$Pr...t..[ind]
          rownames(pmatrix[[t]])[i1] = refnames[i1]
          colnames(pmatrix[[t]])[i2] = refnames[i2]

        }

      }
    }

    # make it symmetric

    estTbl[[t]] = (estmatrix[[t]]-t(estmatrix[[t]]))/2   # unnoetig, kommt das gleiche raus, vorzeichen sind verschieden
    names(estTbl)[[t]] =paste0('Random effects model estimates for t = ', times[t], sep="")
    seTbl[[t]] = (sematrix[[t]]+t(sematrix[[t]]))/2
    names(seTbl)[[t]] =paste0('Random effects model standard errors for t = ', times[t], sep="")
    pTbl[[t]] = sqrt(pmatrix[[t]]*t(pmatrix[[t]]))
    names(pTbl)[[t]] =paste0('Random effects model p-values for t = ', times[t], sep="")


  }
  return(list(estTbl = estTbl,seTbl = seTbl,pTbl = pTbl))
}

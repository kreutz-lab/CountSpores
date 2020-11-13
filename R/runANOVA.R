#' @name runANOVA
#' @title fits lme-model to data, loops over all possible reference levels and runs ANOVA
#' @param file path to data_prop_long
#' @return Data_analysis  folder to store converted data files in excel format
#' @return results.txt Output of lme-model and ANOVA for all possible reference levels
#' @return summary_results.xlsx Excel file with complete test results and summarized views:
#' @return summary_results.xlsx sheet:LME-Model Complete output of lme-model
#' @return summary_results.xlsx sheet: ANOVA Complete output of ANOVA
#' @return summary_results.xlsx sheet: LME-Model_by_time Summary on Estimate, SE and pvalue for each timepoint
#' @return summary_results.xlsx sheet: ANOVA_summary Summarized ANOVA results based on 'Condition'
#' @return returns list of lists: aggregating for each experiment the result objects per reference level for lme-model & ANOVA
#' @export




runANOVA = function(file='Data_analysis/data_prop_long.xlsx'){

  sheets <- openxlsx::getSheetNames(file)
  runANOVA_out = vector(mode='list', length=length(sheets))
  names(runANOVA_out) = sheets

  for (s in 1:length(sheets)){

    # Read in data for main analysis - convert to correct format
    dat = read.xlsx(paste(file), sheet= paste(sheets)[s])
    dat[,-which(colnames(dat)%in% c('Proportion'))] = lapply(dat[,-which(colnames(dat)%in% c('Proportion'))], factor)

    # Get reference levels & corresponding names of design matrix
    clev <<- unique(dat$Condition)
    cname <<- paste('is', clev, sep="")


    # Save one txt file with all results
    # ______________________________________________________________________
    path = paste(paste(sheets)[s],'/results.txt',sep="")

    sink(file=path)
    writeLines(paste('*** Results for',paste(sheets)[s],' ***\n' ))

    fit <<- vector(mode='list', length=length(clev))
    names(fit) <<- clev
    anov <<- vector(mode='list', length=length(clev))
    names(anov)<<- clev

    # Loop over all possible reference levels
    for (c in 1:length(clev)){
      # Remove biasing zeros - remove data from day 1 with Prop=0 and not in reference condition
      dat1 = filter(dat, !(dat$Day==1 & dat[,which(colnames(dat)==cname[c])]==0 & dat$Proportion==0))

      # Relevel to given Condition c
      dat1$Condition = relevel(dat1$Condition, ref=paste(clev[c]))

      writeLines(paste("\n\n------------------------------------ \n", paste0('*** Take ', clev[c] ,' as intercept ***\n')))

      # Remove intercept condition
      c2 = cname[-c]
      # Define formula for lme-model
      formula = paste0("Proportion ~ Day +", paste0(paste0(c2,':Day',sep=""),collapse="+"),"+",paste0(paste0('(1|Plate:',c2,')',sep=""),collapse="+"),sep="")

      # Apply lme-model and save result
      withCallingHandlers({
        fit[[c]]<<- lmer(formula, dat1)
        print(summary(fit[[c]]))
        #Apply ANOVA and save result
        anov[[c]] <<- anova(fit[[c]])
        print(anov[[c]])
      },
      warning=function() {return(NULL)})


  }
    sink()
    # _____________________________________________________________________




    runANOVA_out[[s]] = list(lme = fit, anova = anov)


    # Save all results with summaries in one excel file
    # _____________________________________________________________________

    path = paste(paste(sheets)[s],'/summary_results.xlsx',sep="")
    wb = createWorkbook()
    addWorksheet(wb, 'LME-Model')
    addWorksheet(wb, 'ANOVA')
    addWorksheet(wb,'LME-Model_by_time')
    addWorksheet(wb, 'ANOVA_summary')



    # Save LME-Model results
    res_lme_list = list()

    for (c in 1: length(clev)){

      res_lme = data.frame(coefficients(summary(fit[[c]])))
    res_lme$refLevel = rep(paste(clev[c]), nrow(res_lme))
    res_lme_list[[c]] = res_lme
    }

    res_lme = do.call(rbind, res_lme_list)
    res_lme %>% dplyr::rename(SE = Std..Error,
                              tvalue = t.value,
                              pvalue = Pr...t..)
    res_lme %>% dplyr::relocate(refLevel)
    writeData(wb, 'LME-Model',res_lme, rowNames=TRUE)




    # Save ANOVA results
    res_anova_list = list()

    for (c in 1: length(clev)){

      res_anova = data.frame(anov[[c]])
      res_anova$refLevel = rep(paste(clev[c]), nrow(res_anova))
      res_anova_list[[c]] = res_anova
    }

    res_anova = do.call(rbind, res_anova_list)
    res_anova %>% dplyr::rename(Fvalue = F.value,
                                pvalue = Pr..F.)
    res_anova %>% dplyr::relocate(refLevel)
    writeData(wb, 'ANOVA',res_anova, rowNames=TRUE)




    # Save LME-Model results sorted by timepoints, aggregate all reference levels in one table
    times = c(2:length(unique(dat$Day)))

    random_effects <- pickTimePvalues(fit,cname,times)
    writeData(wb, 'LME-Model_by_time', paste('Analyzing data in sheet ', paste(sheets[s]), sep=""), startCol = 1, startRow = 1)

    curr_row=3
    for (t in 1:length(times)){
      curr_row = curr_row
      writeData(wb,'LME-Model_by_time',paste(' Testing the difference for time point ', times[t], sep=""),startCol=1, startRow=curr_row)

      writeData(wb,'LME-Model_by_time', paste('Estimated difference:'), startCol = 1, startRow = curr_row+2)
      est = data.frame(random_effects$estTbl[[t]])
      writeData(wb,'LME-Model_by_time', est ,rowNames=TRUE, startCol=1, startRow = curr_row+4)
      curr_row = curr_row + 6 + nrow(est)
      writeData(wb, 'LME-Model_by_time', paste('Standard Error (SE):'), startCol = 1, startRow = curr_row)
      se = data.frame(random_effects$seTbl[[t]])
      writeData(wb, 'LME-Model_by_time', se ,rowNames=TRUE, startCol = 1, startRow = curr_row+2)
      curr_row = curr_row+3+nrow(se)
      writeData(wb, 'LME-Model_by_time',paste('p-values:'), startCol = 1, startRow = curr_row+1)
      pdat = data.frame(random_effects$pTbl[[t]])
      writeData(wb, 'LME-Model_by_time',pdat ,rowNames=TRUE, startCol = 1, startRow = curr_row+3)
      curr_row = curr_row + 6 + nrow(pdat)
    }




    # Save ANOVA results, all reference levels aggregated in one table
    anova_res <- pickAnovaPvalues(anov,cname)

    writeData(wb, 'ANOVA_summary', paste('Analyzing data in sheet ', paste(sheets[s]), sep=""), startCol = 1, startRow = 1)
    writeData(wb, 'ANOVA_summary', paste('Testing for an impact on ALL time points: '), startCol = 1, startRow = 3)
    writeData(wb, 'ANOVA_summary', paste('p-values for ANOVA:'), startCol = 1, startRow = 4)
    writeData(wb, 'ANOVA_summary',anova_res, rowNames = TRUE, startCol = 1, startRow = 6)

    saveWorkbook(wb,path , overwrite = TRUE)

  }

return(runANOVA_out)

}

#' @name runANOVA
#' @title fits lme-model to data, loops over all reference levels and runs ANOVA
#' @param file path to raw data file
#' @param sheets character vector with sheetnames of raw data file
#' @return Data_analysis  folder to store converted data files in excel format
#' @return RandomEffectSummary.txt summarized output for effect, se and p-value for each condition and timepoint
#' @return ANOVAsummary.txt p-values for each condition, testing for effect on all timepoints
#' @export




runANOVA = function(file,sheets){
  for (s in 1:length(sheets)){

    #Read in data for main analysis - convert to correct format

    dat = read.xlsx(paste(file), sheet= paste(sheets)[s])
    #str(dat)
    #dat[,c('Condition','Plate','Day','is9650_KO','is11750_KO','is14620_KO','isRe_15','is9_14_DKO')] = lapply( dat[,c('Condition','Plate','Day','is9650_KO','is11750_KO','is14620_KO','isRe_15','is9_14_DKO')], factor)
    dat[,-which(colnames(dat)%in% c('Proportion'))] = lapply(dat[,-which(colnames(dat)%in% c('Proportion'))], factor)


    clev <<- unique(dat$Condition)
    cname <<- paste('is', clev, sep="")


    #create output file
    path = paste(paste(sheets)[s],'/ANOVA.txt',sep="")
    sink(file=path)

    writeLines(paste('*** Results for',paste(sheets)[s],' ***\n' ))

    fit <<- list()
    anov <<- list()

    for (c in 1:length(clev)){


      #Remove biasing zeros - remove data from day 1 with Prop=0 and not in reference condition
      dat1 = filter(dat, !(dat$Day==1 & dat[,which(colnames(dat)==cname[c])]==0 & dat$Proportion==0))

      #Relevel to given Condition c
      dat1$Condition = relevel(dat1$Condition, ref=paste(clev[c]))


      writeLines(paste("\n\n------------------------------------ \n", paste0('*** Take ', clev[c] ,' as intercept ***\n')))

      #Remove intercept condition
      c2 = cname[-c]
      formula = paste0("Proportion ~ Day +", paste0(paste0(c2,':Day',sep=""),collapse="+"),"+",paste0(paste0('(1|Plate:',c2,')',sep=""),collapse="+"),sep="")




      fit[[c]] <<- lmer(formula, dat1)

      print(summary(fit[[c]]))

      anov[[c]] <<- anova(fit[[c]])
      print(anov[[c]])


    }
    sink()



    # Time pvalues
    #path = paste(paste(sheets)[s],'/RandomEffectSummary.txt',sep="")

    #sink(file=path, type='output')
    #myfile <- file(path, 'w')

    times = c(2:7)


    random_effects <<- pickTimePvalues(fit,cname,times)


    # writeLines(paste('Analyzing data in sheet ', paste(sheets[s]), '\n------------------------------------\n', sep=""),myfile, sep='')
    #
    # for (t in 1:length(times)){
    #
    #
    #   writeLines(paste('\n Testing the difference for time point ', times[t] ,'\n', sep=""), myfile,sep='')
    #   writeLines(paste('\n Estimated difference: \n\n'), myfile,sep='')
    #   write.table(data.frame(random_effects$estTbl[[t]]), na='\t', sep='\t', col.names=NA, myfile)
    #   writeLines(paste('\n Standard Error (SE): \n\n'), myfile,sep='')
    #   write.csv(data.frame(random_effects$seTbl[[t]]), myfile)
    #   writeLines(paste('\n p-values: \n\n'), myfile,sep='')
    #   write.csv(data.frame(random_effects$pTbl[[t]]),myfile)
    #   writeLines(paste('\n\n--------------------------------------------\n'), myfile,sep='')
    # }

    #sink()


    path = paste(paste(sheets)[s],'/RandomEffectSummary.xlsx',sep="")
    wb = createWorkbook()
    addWorksheet(wb,'Random_Effects')
    addWorksheet(wb, 'ANOVA_summary')
    writeData(wb, 'Random_Effects', paste('Analyzing data in sheet ', paste(sheets[s]), sep=""), startCol = 1, startRow = 1)

    curr_row=3
    #test_style = openxlsx::createStyle(fontName='Calibri',fontSize = 13,fontColour = 'darkblue', textDecoration = 'bold', border='bottom', borderColour = 'darkblue')

    for (t in 1:length(times)){
      curr_row = curr_row
      writeData(wb,'Random_Effects',paste(' Testing the difference for time point ', times[t], sep=""),startCol=1, startRow=curr_row)

      writeData(wb,'Random_Effects', paste('Estimated difference:'), startCol = 1, startRow = curr_row+2)
      est = data.frame(random_effects$estTbl[[t]])
      writeData(wb,'Random_Effects', est ,rowNames=TRUE, startCol=1, startRow = curr_row+4)
      curr_row = curr_row + 6 + nrow(est)

      writeData(wb, 'Random_Effects', paste('Standard Error (SE):'), startCol = 1, startRow = curr_row)
      se = data.frame(random_effects$seTbl[[t]])
      writeData(wb, 'Random_Effects', se ,rowNames=TRUE, startCol = 1, startRow = curr_row+2)
      curr_row = curr_row+3+nrow(se)
      writeData(wb, 'Random_Effects',paste('p-values:'), startCol = 1, startRow = curr_row+1)
      pdat = data.frame(random_effects$pTbl[[t]])
      writeData(wb, 'Random_Effects',pdat ,rowNames=TRUE, startCol = 1, startRow = curr_row+3)
      curr_row = curr_row + 6 + nrow(pdat)


    }

    #saveWorkbook(wb,path , overwrite = TRUE)




    # ANOVA pvalues
    #path = paste(paste(sheets)[s],'/ANOVASummary.txt',sep="")
    #sink(file=path)


    anova_res <<- pickAnovaPvalues(anov,cname)


    #writeLines(paste('Analyzing data in sheet ', paste(sheets[s]), '\n------------------------------------\n', sep=""))

    #writeLines(paste('\n Testing for an impact on ALL time points:\n'))
    #writeLines(paste('\n p-values for ANOVA: \n\n'))
    #print(anova_res)

    writeData(wb, 'ANOVA_summary', paste('Analyzing data in sheet ', paste(sheets[s]), sep=""), startCol = 1, startRow = 1)
    writeData(wb, 'ANOVA_summary', paste('Testing for an impact on ALL time points: '), startCol = 1, startRow = 3)
    writeData(wb, 'ANOVA_summary', paste('p-values for ANOVA:'), startCol = 1, startRow = 4)
    writeData(wb, 'ANOVA_summary',anova_res, rowNames = TRUE, startCol = 1, startRow = 6)

    saveWorkbook(wb,path , overwrite = TRUE)
    #sink()

  }
}

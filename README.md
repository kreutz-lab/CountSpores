
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CountSpores

<!-- badges: start -->

<!-- badges: end -->

CountSpores is a customized analysis pipeline to estimate spore growth
over time for different conditions, taking technical and biological
replicates into account.

## Installation

Install from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kreutz-lab/CountSpores")
```

## Example

This is an example on how to use *CountSpores*, introducing
CountSpores’s functions and giving an overview on the output.

``` r
library(CountSpores)
```

## Data Input

The following line needs to be provided by the user  
**file: Path to the raw data file**

``` r
file = "exampleData/example.xlsx"
```

### Structur of raw data:

First 3 columns need to correspond to: **‘Condition’, ‘Plate’,‘Day’**  
Counts per segment should be followed by totals per segment and in
**same
order**

``` r
knitr::kable(head(read.xlsx(file, sheet='LD'),15))
```

| Condition | Plate | Day | Area1 | Area2 | Area3 | Area1\_total | Area2\_total | Area3\_total |
| :-------- | :---- | --: | ----: | ----: | ----: | -----------: | -----------: | -----------: |
| 9650\_KO  | A     |   1 |     0 |     0 |     0 |          862 |          694 |          796 |
| 9650\_KO  | A     |   2 |   157 |   125 |   147 |          862 |          694 |          796 |
| 9650\_KO  | A     |   3 |   808 |   641 |   759 |          862 |          694 |          796 |
| 9650\_KO  | A     |   4 |   818 |   664 |   774 |          862 |          694 |          796 |
| 9650\_KO  | A     |   5 |   843 |   679 |   782 |          862 |          694 |          796 |
| 9650\_KO  | A     |   6 |   862 |   694 |   796 |          862 |          694 |          796 |
| 9650\_KO  | A     |   7 |   862 |   694 |   796 |          862 |          694 |          796 |
| 9650\_KO  | B     |   1 |     0 |     0 |     0 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   2 |   221 |   282 |   259 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   3 |   554 |   748 |   714 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   4 |   832 |  1009 |   943 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   5 |   986 |  1233 |  1189 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   6 |  1132 |  1401 |  1307 |         1213 |         1507 |         1408 |
| 9650\_KO  | B     |   7 |  1213 |  1500 |  1367 |         1213 |         1507 |         1408 |
| 9650\_KO  | C     |   1 |     0 |     0 |     0 |         1937 |         1387 |         1428 |

## ReadData

*ReadData* first creates one directory for each experiment (sheet in
excel file)  
Then *ReadData* reads in the raw data, converts columns to factors for
analysis and calculates the corresponding proportions for each segment
on the plate. Additionally mean, sd and se are calculated for QC plots.
This new data file is saved as **‘data\_proportional.xlsx’** in the
**‘Data\_analysis’** directory, created by *ReadData*.  
To apply LME-Model *ReadData* converts the data frame in long format
**‘data\_prop\_long.xlsx’**, which is also saved in Data\_analysis
directory.  
*ReadData* returns a **list with data\_proportional & data\_prop\_long**

#### Files created by ReadData:

**data\_proportional:**

``` r
# Call directly in R
# ReadData_out$LD$data_proportional
# Or look at excel file
knitr::kable(head(read.xlsx('Data_analysis/data_proportional.xlsx',sheet='LD')))
```

| Condition | Plate | Day | Area1 | Area2 | Area3 | Area1\_total | Area2\_total | Area3\_total |   Prop\_1 |   Prop\_2 |   Prop\_3 |      Mean |        sd |        se | plot\_ID  |
| :-------- | :---- | --: | ----: | ----: | ----: | -----------: | -----------: | -----------: | --------: | --------: | --------: | --------: | --------: | --------: | :-------- |
| 9650\_KO  | A     |   1 |     0 |     0 |     0 |          862 |          694 |          796 |   0.00000 |   0.00000 |   0.00000 |   0.00000 | 0.0000000 | 0.0000000 | 9650\_KOA |
| 9650\_KO  | A     |   2 |   157 |   125 |   147 |          862 |          694 |          796 |  18.21346 |  18.01153 |  18.46734 |  18.23077 | 0.2283975 | 0.1318654 | 9650\_KOA |
| 9650\_KO  | A     |   3 |   808 |   641 |   759 |          862 |          694 |          796 |  93.73550 |  92.36311 |  95.35176 |  93.81679 | 1.4959806 | 0.8637048 | 9650\_KOA |
| 9650\_KO  | A     |   4 |   818 |   664 |   774 |          862 |          694 |          796 |  94.89559 |  95.67723 |  97.23618 |  95.93634 | 1.1916123 | 0.6879777 | 9650\_KOA |
| 9650\_KO  | A     |   5 |   843 |   679 |   782 |          862 |          694 |          796 |  97.79582 |  97.83862 |  98.24121 |  97.95855 | 0.2457217 | 0.1418675 | 9650\_KOA |
| 9650\_KO  | A     |   6 |   862 |   694 |   796 |          862 |          694 |          796 | 100.00000 | 100.00000 | 100.00000 | 100.00000 | 0.0000000 | 0.0000000 | 9650\_KOA |

**data\_prop\_long**

``` r
# Call directly in R
# ReadData_out$LD$data_prop_long
# Or look at excel file
knitr::kable(head(read.xlsx('Data_analysis/data_prop_long.xlsx',sheet='LD')))
```

| Condition | Plate | Day | Segment | Proportion | is9650\_KO | is11750\_KO | is14620\_KO | isRe\_15 | is9\_14\_DKO |
| :-------- | :---- | --: | :------ | ---------: | ---------: | ----------: | ----------: | -------: | -----------: |
| 9650\_KO  | A     |   1 | Prop\_1 |    0.00000 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   2 | Prop\_1 |   18.21346 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   3 | Prop\_1 |   93.73550 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   4 | Prop\_1 |   94.89559 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   5 | Prop\_1 |   97.79582 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   6 | Prop\_1 |  100.00000 |          1 |           0 |           0 |        0 |            0 |

## plotTimeCourse

Saves one png file for each experiment, plotting the raw data (mean
proportion & se) for each plate & condition over time.

``` r
plotTimeCourse(file='Data_analysis/data_proportional.xlsx')
```

**Output for ‘LD’ experiment:**

<img src="LD/LD_timecourse.png" width="50%" />

## plotMeanSE

Saves one png file for each experiment, plotting the raw data (se over
mean proportion) for each condition.

``` r
plotMeanSE(file='Data_analysis/data_proportional.xlsx')
```

**Output for ‘LD’ experiment:**

<img src="LD/LD_mean_se.png" width="50%" />

## runANOVA

Applies lme-models and runs ANOVA for each experiment separately and
returns results.  
**results.txt**: Complete collection lme-model & ANOVA results  
**summary\_results.xlsx**: Summarized results for lme-model and ANOVA

``` r
runANOVA_out = runANOVA(file='Data_analysis/data_prop_long.xlsx')
```

**results.txt for ‘LD’ experiment:**

``` r
cat(readLines('LD/results.txt',80), sep='\n')
*** Results for LD  ***



------------------------------------ 
 *** Take 9650_KO as intercept ***

Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: formula
   Data: dat1

REML criterion at convergence: 1802

Scaled residuals: 
    Min      1Q  Median      3Q     Max 
-3.5229 -0.5204  0.0428  0.4607  4.0436 

Random effects:
 Groups           Name        Variance Std.Dev.
 Plate:is11750_KO (Intercept) 149.51   12.228  
 Plate:is14620_KO (Intercept)  32.10    5.666  
 Plate:isRe_15    (Intercept)  39.32    6.270  
 Plate:is9_14_DKO (Intercept)  14.15    3.761  
 Residual                      55.38    7.442  
Number of obs: 279, groups:  
Plate:is11750_KO, 6; Plate:is14620_KO, 6; Plate:isRe_15, 6; Plate:is9_14_DKO, 6

Fixed effects:
                   Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)       2.122e-12  9.193e+00  6.640e+00   0.000 1.000000    
Day2              1.780e+01  3.508e+00  2.356e+02   5.074  7.9e-07 ***
Day3              5.583e+01  3.508e+00  2.356e+02  15.913  < 2e-16 ***
Day4              7.396e+01  3.508e+00  2.356e+02  21.081  < 2e-16 ***
Day5              8.849e+01  3.508e+00  2.356e+02  25.223  < 2e-16 ***
Day6              9.528e+01  3.508e+00  2.356e+02  27.159  < 2e-16 ***
Day7              9.839e+01  3.508e+00  2.356e+02  28.046  < 2e-16 ***
Day2:is11750_KO1  2.112e+00  1.058e+01  3.707e+00   0.200 0.852273    
Day3:is11750_KO1 -1.417e+01  1.058e+01  3.707e+00  -1.339 0.256732    
Day4:is11750_KO1 -7.397e+00  1.058e+01  3.707e+00  -0.699 0.525929    
Day5:is11750_KO1 -6.656e+00  1.058e+01  3.707e+00  -0.629 0.566022    
Day6:is11750_KO1 -3.403e+00  1.058e+01  3.707e+00  -0.322 0.765100    
Day7:is11750_KO1 -1.968e+00  1.058e+01  3.707e+00  -0.186 0.862214    
Day2:is14620_KO1  5.215e+00  5.806e+00  4.566e+00   0.898 0.413894    
Day3:is14620_KO1  1.275e+01  5.806e+00  4.566e+00   2.196 0.084693 .  
Day4:is14620_KO1  8.283e+00  5.806e+00  4.566e+00   1.427 0.218343    
Day5:is14620_KO1  4.557e-01  5.806e+00  4.566e+00   0.078 0.940755    
Day6:is14620_KO1 -2.768e+00  5.806e+00  4.566e+00  -0.477 0.655458    
Day7:is14620_KO1 -8.338e-01  5.806e+00  4.566e+00  -0.144 0.891920    
Day2:isRe_151    -6.763e+00  6.206e+00  4.254e+00  -1.090 0.333670    
Day3:isRe_151    -2.887e+01  6.206e+00  4.254e+00  -4.652 0.008316 ** 
Day4:isRe_151    -1.367e+01  6.206e+00  4.254e+00  -2.202 0.088353 .  
Day5:isRe_151    -1.465e+01  6.206e+00  4.254e+00  -2.360 0.073772 .  
Day6:isRe_151    -1.451e+01  6.206e+00  4.254e+00  -2.337 0.075715 .  
Day7:isRe_151    -7.994e+00  6.206e+00  4.254e+00  -1.288 0.263354    
Day2:is9_14_DKO1  1.180e+01  4.662e+00  7.621e+00   2.530 0.036607 *  
Day3:is9_14_DKO1  2.501e+01  4.662e+00  7.621e+00   5.365 0.000792 ***
Day4:is9_14_DKO1  1.843e+01  4.662e+00  7.621e+00   3.952 0.004654 ** 
Day5:is9_14_DKO1  4.507e+00  4.662e+00  7.621e+00   0.967 0.363336    
Day6:is9_14_DKO1  1.597e+00  4.662e+00  7.621e+00   0.343 0.741219    
Day7:is9_14_DKO1  1.611e+00  4.662e+00  7.621e+00   0.346 0.739017    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 4 columns / coefficients
Type III Analysis of Variance Table with Satterthwaite's method
               Sum Sq Mean Sq NumDF   DenDF  F value  Pr(>F)    
Day             81983 13663.8     6 235.620 246.7165 < 2e-16 ***
Day:is11750_KO    710   118.4     6   8.209   2.1380 0.15546    
Day:is14620_KO    836   139.3     6   3.248   2.5149 0.22728    
Day:isRe_15      1799   299.8     6   3.733   5.4140 0.06944 .  
Day:is9_14_DKO   2643   440.5     6   2.785   7.9531 0.06724 .  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1


------------------------------------ 
 *** Take 11750_KO as intercept ***

Linear mixed model fit by REML. t-tests use Satterthwaite's method [
```

**Time specific effects on the proportion of sprouted spores in each
condition - again for ‘LD’
experiment:**

``` r
time_effects = read.xlsx('LD/summary_results.xlsx', sheet='LME-Model_by_time')
options(knitr.kable.NA='')
knitr::kable(head(time_effects, 20))
```

| Analyzing.data.in.sheet.LD              | X2                 | X3                 | X4                 | X5                 | X6                 |
| :-------------------------------------- | :----------------- | :----------------- | :----------------- | :----------------- | :----------------- |
| Testing the difference for time point 2 |                    |                    |                    |                    |                    |
| Estimated difference:                   |                    |                    |                    |                    |                    |
|                                         | is9650\_KO         | is11750\_KO        | is14620\_KO        | isRe\_15           | is9\_14\_DKO       |
| is9650\_KO                              |                    | 2.11197413907851   | 5.21525557727255   | \-6.76340847588833 | 11.797631212549    |
| is11750\_KO                             | \-2.11197413907851 |                    | 3.10328143818912   | \-8.87538261497447 | 9.68565707346951   |
| is14620\_KO                             | \-5.21525557727255 | \-3.10328143818912 |                    | \-11.9786640531604 | 6.58237563527687   |
| isRe\_15                                | 6.76340847588833   | 8.87538261497447   | 11.9786640531604   |                    | 18.5610396884373   |
| is9\_14\_DKO                            | \-11.797631212549  | \-9.68565707346951 | \-6.58237563527687 | \-18.5610396884373 |                    |
| Standard Error (SE):                    |                    |                    |                    |                    |                    |
|                                         | is9650\_KO         | is11750\_KO        | is14620\_KO        | isRe\_15           | is9\_14\_DKO       |
| is9650\_KO                              |                    | 11.6380189351184   | 6.03993171752201   | 6.3551964764786    | 5.19986901729227   |
| is11750\_KO                             | 11.6380189351184   |                    | 7.82881799561647   | 11.2034608361025   | 7.60748577398648   |
| is14620\_KO                             | 6.03993171752201   | 7.82881799561647   |                    | 4.64952256020348   | 3.77556652738701   |
| isRe\_15                                | 6.3551964764786    | 11.2034608361025   | 4.64952256020348   |                    | 5.24902933098603   |
| is9\_14\_DKO                            | 5.19986901729227   | 7.60748577398648   | 3.77556652738701   | 5.24902933098603   |                    |
| p-values:                               |                    |                    |                    |                    |                    |
|                                         | is9650\_KO         | is11750\_KO        | is14620\_KO        | isRe\_15           | is9\_14\_DKO       |
| is9650\_KO                              |                    | 0.867515001811828  | 0.428570939051919  | 0.344732091991886  | 0.0564987420884185 |
| is11750\_KO                             | 0.867515001811828  |                    | 0.715197159129098  | 0.48698147535383   | 0.278210418087219  |
| is14620\_KO                             | 0.428570939051919  | 0.715197159129098  |                    | 0.0271367510554658 | 0.0947546643923612 |

**ANOVA summary for effect on all time points - again for ‘LD’
experiment:**

``` r
overall_effects = read.xlsx('LD/summary_results.xlsx', sheet='ANOVA_summary')
options(knitr.kable.NA='')
knitr::kable(overall_effects)
```

| Analyzing.data.in.sheet.LD                | X2                 | X3                  | X4                  | X5                  | X6                  |
| :---------------------------------------- | :----------------- | :------------------ | :------------------ | :------------------ | :------------------ |
| Testing for an impact on ALL time points: |                    |                     |                     |                     |                     |
| p-values for ANOVA:                       |                    |                     |                     |                     |                     |
|                                           | is9650\_KO         | is11750\_KO         | is14620\_KO         | isRe\_15            | is9\_14\_DKO        |
| is9650\_KO                                |                    | 0.2350868787843     | 0.164031568339199   | 0.0645828063751616  | 0.0235637579685602  |
| is11750\_KO                               | 0.2350868787843    |                     | 0.0173951386063154  | 0.587394981481784   | 0.00282105187320465 |
| is14620\_KO                               | 0.164031568339199  | 0.0173951386063154  |                     | 0.00822044976838394 | 0.170459821052227   |
| isRe\_15                                  | 0.0645828063751616 | 0.587394981481784   | 0.00822044976838394 |                     | 0.00220678479197313 |
| is9\_14\_DKO                              | 0.0235637579685602 | 0.00282105187320465 | 0.170459821052227   | 0.00220678479197313 |                     |

## Example code for complete analysis:

``` r

library(CountSpores)

file = "exampleData/example.xlsx"

example_result = runCountSpores(file)
#> Identified experiments:  GA3 ABA LD
```

All results from *CountSpores* pipeline are now saved in result folders
as described above.  
For further downstream analysis in *R*, data for analysis and results
from lme-model and ANOVA (stored all together in results.txt) can be
accessed like this:

Access **data\_prop\_long** for **GA3**
experiment

``` r
knitr::kable(head(example_result$ReadData_out$GA3$data_prop_long))
```

| Condition | Plate | Day | Segment | Proportion | is9650\_KO | is11750\_KO | is14620\_KO | isRe\_15 | is9\_14\_DKO |
| :-------- | :---- | --: | :------ | ---------: | ---------: | ----------: | ----------: | -------: | -----------: |
| 9650\_KO  | A     |   1 | Prop\_1 |   0.000000 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   2 | Prop\_1 |   8.994334 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   3 | Prop\_1 |  15.155807 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   4 | Prop\_1 |  93.767705 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   5 | Prop\_1 |  94.334278 |          1 |           0 |           0 |        0 |            0 |
| 9650\_KO  | A     |   6 | Prop\_1 |  95.042493 |          1 |           0 |           0 |        0 |            0 |

Access result from **linear mixed effects model** for **GA3** experiment
and **‘9650\_KO’** as reference level

``` r
example_result$runANOVA_out$GA3$lme$`9650_KO`
#> Linear mixed model fit by REML ['lmerModLmerTest']
#> Formula: formula
#>    Data: dat1
#> REML criterion at convergence: 1934.784
#> Random effects:
#>  Groups           Name        Std.Dev.
#>  Plate:is11750_KO (Intercept) 20.858  
#>  Plate:is14620_KO (Intercept) 14.763  
#>  Plate:isRe_15    (Intercept) 13.428  
#>  Plate:is9_14_DKO (Intercept) 11.788  
#>  Residual                      9.515  
#> Number of obs: 279, groups:  
#> Plate:is11750_KO, 6; Plate:is14620_KO, 6; Plate:isRe_15, 6; Plate:is9_14_DKO, 6
#> Fixed Effects:
#>      (Intercept)              Day2              Day3              Day4  
#>        3.784e-11         1.098e+01         2.783e+01         6.204e+01  
#>             Day5              Day6              Day7  Day2:is11750_KO1  
#>        7.812e+01         8.934e+01         9.574e+01        -2.896e+00  
#> Day3:is11750_KO1  Day4:is11750_KO1  Day5:is11750_KO1  Day6:is11750_KO1  
#>       -1.059e+01        -2.852e+01        -2.510e+01        -2.165e+01  
#> Day7:is11750_KO1  Day2:is14620_KO1  Day3:is14620_KO1  Day4:is14620_KO1  
#>       -2.019e+01         1.185e+01         4.862e+01         1.805e+01  
#> Day5:is14620_KO1  Day6:is14620_KO1  Day7:is14620_KO1     Day2:isRe_151  
#>        7.910e+00         6.829e-01        -2.212e-01         6.205e+00  
#>    Day3:isRe_151     Day4:isRe_151     Day5:isRe_151     Day6:isRe_151  
#>        2.089e+01         7.726e+00         5.836e+00         1.847e+00  
#>    Day7:isRe_151  Day2:is9_14_DKO1  Day3:is9_14_DKO1  Day4:is9_14_DKO1  
#>       -1.377e+00         1.662e+01         4.742e+01         2.608e+01  
#> Day5:is9_14_DKO1  Day6:is9_14_DKO1  Day7:is9_14_DKO1  
#>        1.327e+01         4.999e+00         1.323e+00  
#> fit warnings:
#> fixed-effect model matrix is rank deficient so dropping 4 columns / coefficients
```

Access result from **ANOVA** for **GA3** experiment and **‘9650\_KO’**
as reference level

``` r
example_result$runANOVA_out$GA3$anova$`9650_KO`
#> Type III Analysis of Variance Table with Satterthwaite's method
#>                Sum Sq Mean Sq NumDF   DenDF  F value  Pr(>F)    
#> Day             81559 13593.1     6 237.203 150.1501 < 2e-16 ***
#> Day:is11750_KO   2181   363.5     6   4.617   4.0157 0.08280 .  
#> Day:is14620_KO   7483  1247.2     6   2.833  13.7766 0.03182 *  
#> Day:isRe_15      1348   224.7     6   2.662   2.4826 0.26354    
#> Day:is9_14_DKO   6624  1103.9     6   2.467  12.1940 0.05106 .  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

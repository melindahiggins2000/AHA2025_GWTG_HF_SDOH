# Melinda Higgins
# proposal script for April 2025
# last updated 03/28/2025

# Executes the file db_connector.R, which contains pre-written functions to simplify connecting to and working with the data lake. 
#Running this file makes these functions available to you in this notebook, so you can easily access data without writing connection code from scratch.
source("/usr/local/bin/db_connector.R")

# print_databases() function helps you quickly see the databases you have access to, making it easier to decide where to start exploring data.
print_databases()

#Use print_tables(database_name) to display a list of tables available within a specific database.
#print_tables('gwtg-stroke-db')
#print_tables('gwtg-hf-synthetic-db')
print_tables('gwtg-hf-sdoh-db')


#The download_supplementary_files function downloads all available supplementary files to a specified local directory.
#download_supplementary_files(database_name = "gwtg-stroke-db")
#download_supplementary_files(database_name = 'gwtg-hf-synthetic-db')
download_supplementary_files(database_name = 'gwtg-hf-sdoh-db')

# #Use this functionality for querying smaller datasets!
# df_limited = read_data(
#   database_name='gwtg-stroke-db', 
#   table_name='v5_2024-03_2024_03_gwtg_stroke', 
#   limit_rows=100,
#   columns=c('AGE', 'UNIQUE_PATIENT_ID'),
#   save_to_csv = TRUE,
#   csv_file_name = 'test.csv')


# #Example for reading a smaller dataset 'stroke_certification'
# df_stroke_certification = read_data(
#   database_name='gwtg-stroke-db', 
#   table_name='v5_2024-03_2024_03_stroke_certification')

#Get a larger dataset using read_large_full_data()
#dataset <- read_large_full_data(database_name = 'gwtg-stroke-db', table_name="v5_2024-03_2024_03_gwtg_stroke")

# # SKIP THIS, 03/28/2025
# hfdf_main <- read_large_full_data(
#   database_name = 'gwtg-hf-sdoh-db',
#   table_name = 'v1_2024-06_gwtg_hf_sdoh_linked'
# )
# 
# hfdf_hosp <- read_large_full_data(
#   database_name = 'gwtg-hf-sdoh-db',
#   table_name = 'v1_2024-06_hf_amhosp_site_characteristics'
# )
# 
# # already saved
# save(hfdf_hosp, file = "hfdf_hosp.RData")

# # read in a limited amount of data
# # get all rows but selected vars
# 
# df_selectVars_hf_sdoh = read_data(
#   database_name='gwtg-hf-sdoh-db',
#   table_name='v1_2024-06_gwtg_hf_sdoh_linked',
#   #limit_rows=2600000,
#   columns=c(
#     "admyr",
#     "site_postal_code",
#     "zip",
#     "unique_record_id",
#     "rcrdnum",
#     "patient_display_id",
#     "facility_display_id",
#     "form_record_id_case",
#     "hf_standard"
#   ))
# 
# save(df_selectVars_hf_sdoh,
#      file = "df_selectVars_hf_sdoh.RData")

# # SELECTED VARS ALREADY SAVED, 03/28/2025
# # pull variable list out
# # vars 1 - 939 - main vars
# # vars 940 - 3235 SDOH added vars - maybe add some back later
# varlist <- df_names.df$df_names[1:939]
# 
# df_mainVars = read_data(
#   database_name='gwtg-hf-sdoh-db',
#   table_name='v1_2024-06_gwtg_hf_sdoh_linked',
#   #limit_rows=100,
#   columns=varlist
#   )
# 
# save(df_mainVars,
#      file = "df_mainVars.RData")

# 03/30/2025 - add IHME variables at PT Zip =========
# this takes 4+ hours
# note: next time only get new vars and then merge
library(readr)
df_names_df <- read_csv("df_names_df.csv")
df_names_df$df_names

varlist <- df_names_df$df_names[1:959]

df_mainVars = read_data(
  database_name='gwtg-hf-sdoh-db',
  table_name='v1_2024-06_gwtg_hf_sdoh_linked',
  #limit_rows=100,
  columns=varlist
  )

save(df_mainVars,
     file = "df_mainVars.RData")



# 03/25/2025 - load back saved datasets
# this mainVars takes 5-6min to load
load("df_mainVars.RData")
load("hfdf_hosp.RData")
load("hf_sdoh_names.RData")

# table(df_10000$site_postal_code, df_10000$rurali,
#       useNA = "ifany")
# table(df_10000$site_postal_code, df_10000$rurali_imp,
#       useNA = "ifany")

# get summary stats
library(dplyr)
df_mainVars %>%
  with(table(lvef, useNA = "ifany"))
df_mainVars$lvef.f <- factor(
  df_mainVars$lvef,
  levels = c(1, 2, 3),
  labels= c("1 = HFrEF (EF <=40)",
            "2 = HFmrEF (EF 41-49)",
            "3 = HFpEF (EF >=50)")
)
df_mainVars$genderi.f <- factor(
  df_mainVars$genderi,
  levels = c(0, 1),
  labels= c("0 = male",
            "1 = female")
)
df_mainVars %>%
  with(table(lvef.f, 	
             genderi.f,
             useNA = "ifany"))

df_mainVars_hfpef <- df_mainVars %>%
  filter(lvef == 3)
save(df_mainVars_hfpef, 
     file = "df_mainVars_hfpef.RData")
rm(df_mainVars)

# START HERE ===================================
# 03/29/2025

load("df_mainVars_hfpef.RData")
# takes 2-3 min to load

df_mainVars_hfpef$genderi.f <- factor(
  df_mainVars_hfpef$genderi,
  levels = c(0, 1),
  labels= c("0 = male",
            "1 = female")
)
df_mainVars_hfpef %>%
  with(table(lvef.f, 	
             genderi.f,
             useNA = "ifany"))

# 
# head(df_mainVars_hfpef$age)
# head(df_mainVars_hfpef$agei)

summary(as.numeric(df_mainVars_hfpef$agei))

hist(as.numeric(df_mainVars_hfpef$agei))

# redo this later - convert agei to numeric
# it is character at the moment
df_mainVars_hfpef <- df_mainVars_hfpef %>%
  mutate(agei_cat = case_when(
    (agei < 40) ~ 1,
    ((agei >= 40) & (agei < 50)) ~ 2,
    ((agei >= 50) & (agei < 60)) ~ 3,
    ((agei >= 60) & (agei < 70)) ~ 4,
    ((agei >= 70) & (agei < 80)) ~ 5,
    ((agei >= 80) & (agei < 90)) ~ 6,
    (agei >= 90) ~ 7,
    .default = NA_real_
  ))

df_mainVars_hfpef$agei_cat.f <- factor(
  df_mainVars_hfpef$agei_cat,
  levels = c(1,2,3,4,5,6,7),
  labels = c("1 = agei < 40",
             "2 = agei => 40 and < 50",
             "3 = agei => 50 and < 60",
             "4 = agei => 60 and < 70",
             "5 = agei => 70 and < 80",
             "6 = agei => 80 and < 90",
             "7 = agei => 90")
)

df_mainVars_hfpef %>%
  with(table(agei_cat.f, genderi.f, useNA = "ifany"))

table(df_mainVars_hfpef$admyr, useNA = "ifany")
hist(as.numeric(df_mainVars_hfpef$admyr))

# figure out repeat patients
df_mainVars_hfpef %>%
  select(rcrdnum, patient_display_id, facility_display_id) %>%
  arrange(facility_display_id, patient_display_id) %>%
  head(n=30)

# unique admissions
length(unique(df_mainVars_hfpef$rcrdnum))
length(unique(df_mainVars_hfpef$unique_record_id))

# look at multiple admissions
d1 <- df_mainVars_hfpef %>%
  select(rcrdnum, patient_display_id, facility_display_id,
         arrdti,
         admdti,
         disdti,
         arryr,
         admyr,
         disyr) %>%
  filter(duplicated(rcrdnum))

# look at deplicate rcrdnum

dupadm1 <- df_mainVars_hfpef %>%
  filter(rcrdnum == "798632.0")
dupadm1.t <- t(dupadm1)

dupadm2 <- df_mainVars_hfpef %>%
  filter(rcrdnum == "890716.0")
dupadm2.t <- t(dupadm2)

# pt id 4679191.0
d3 <- df_mainVars_hfpef %>%
  filter(patient_display_id == "4679191.0")
d3.t <- t(d3)

# pid id 1013188.0, has duplicate records
# and was readmitted
d4 <- df_mainVars_hfpef %>%
  filter(patient_display_id == "1013188.0")
d4.t <- t(d4)

sum(is.na(d1$arrdti))
sum(is.na(d1$admdti))

df_mainVars_hfpef$admdti.date <-
  as.Date(df_mainVars_hfpef$admdti,
          format = "%Y-%m-%d %H:%M:%S")

# keep unique rcrdnum
df_mainVars_hfpef_unircrd <- df_mainVars_hfpef %>% 
  group_by(rcrdnum) %>% 
  arrange(admdti.date) %>% 
  slice(1) %>% 
  ungroup()

# save unique records
save(df_mainVars_hfpef_unircrd,
     file = "df_mainVars_hfpef_unircrd.RData")

load("hf_sdoh_names.RData")

# look at duplicates for whole record - DO NOT RUN
# duprcrdnum <- duplicated(df_mainVars_hfpef)

# START HERE - unique records ============

# unique patients - not this
#length(unique(c(df_mainVars_hfpef_unircrd$patient_display_id,
#                df_mainVars_hfpef_unircrd$facility_display_id)))

# use this - merge first
df_mainVars_hfpef_unircrd$ptfacid <- 
  paste(df_mainVars_hfpef_unircrd$patient_display_id,
        df_mainVars_hfpef_unircrd$facility_display_id)

length(unique(df_mainVars_hfpef_unircrd$ptfacid))

# get unique patients at 1st admit date
df_mainVars_hfpef_unircrd.pt1 <- df_mainVars_hfpef_unircrd %>% 
  group_by(patient_display_id, 
           facility_display_id) %>% 
  arrange(admdti.date) %>% 
  slice(1) %>% 
  ungroup()

# save unique records
save(df_mainVars_hfpef_unircrd.pt1,
     file = "df_mainVars_hfpef_unircrd.pt1.RData")


# look at arrival categories:
table(df_mainVars_hfpef_unircrd.pt1$transothed, useNA = "ifany")
#      0      1   <NA> 
# 269908  11840 566990 
# 11840 yes transferred in
# rest are no or unknown

table(df_mainVars_hfpef_unircrd.pt1$admitsource, useNA = "ifany")
#     10     14      2      3      5      6      7      8   <NA> 
#   2372    232  84911  17076  16914  12145   5158 241487 468443 

# 2 = non-health care facility
# 3 = clinic
# 5 = transfer from hospital different
# 6 = transfer from skilled nursing facility
# 7 = transfer from other health care facilty
# 8 = ER
# 10 = info not available
# 14 = transfer from hospice, under hospice plan of care

table(df_mainVars_hfpef_unircrd.pt1$admitsource,
      df_mainVars_hfpef_unircrd.pt1$transothed,
      useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1$hfhospadm, useNA = "ifany")
# 1 = 0, 2 = 1, 3 = 2, 4 = >2, 5 = unknown
#      1      2      3      4      5   <NA> 
#  87142  26436   7153   5667  43417 678923 

table(df_mainVars_hfpef_unircrd.pt1$priorhf, useNA = "ifany")
# 0=no, 1=yes, rest unknown
#      0      1   <NA> 
# 173316 389140 286282 

table(df_mainVars_hfpef_unircrd.pt1$dschstati, useNA = "ifany")
#      1      2      3      4      5      6      7      8   <NA> 
# 604473  13648   9723   9811 171478  16092   6017    287  17209 

table(df_mainVars_hfpef_unircrd.pt1$ischemici, useNA = "ifany")
#      0      1   <NA> 
# 361261 269985 217492

table(df_mainVars_hfpef_unircrd.pt1$dmhx, useNA = "ifany")
#      0      1   <NA> 
# 341204 290042 217492

table(df_mainVars_hfpef_unircrd.pt1$dmhxdg, useNA = "ifany")
#      0      1   <NA> 
# 340988 291382 216368 

table(df_mainVars_hfpef_unircrd.pt1$dmhx,
      df_mainVars_hfpef_unircrd.pt1$dmhxdg,
      useNA = "ifany")
#             0      1   <NA>
#   0    339874   1330      0
#   1         0 290042      0
#   <NA>   1114     10 216368

table(df_mainVars_hfpef_unircrd.pt1$crt_p_or_d, useNA = "ifany")
#      0      1   <NA> 
# 621320   9926 217492

table(df_mainVars_hfpef_unircrd.pt1$icd_or_crt_d, useNA = "ifany")
#      0      1   <NA> 
# 614608  16638 217492

# SARS-COV-1 history
table(df_mainVars_hfpef_unircrd.pt1$medhist_38, useNA = "ifany")
#      0      1   <NA> 
# 630963    283 217492 

# SARS-COV-2 (COVID-19) history
table(df_mainVars_hfpef_unircrd.pt1$medhist_39, useNA = "ifany")
#      0      1   <NA> 
# 624098   7148 217492 


# activeinfec_05
# activeinfec_06

# SARS-COV-1 active at or during admission
table(df_mainVars_hfpef_unircrd.pt1$activeinfec_05, useNA = "ifany")
#      0      1   <NA> 
# 173380     15 675343

# SARS-COV-2 (COVID-19) active at or during admission
table(df_mainVars_hfpef_unircrd.pt1$activeinfec_06, useNA = "ifany")
#      0      1   <NA> 
# 171300   2095 675343 

save(df_mainVars_hfpef_unircrd.pt1,
     file = "df_mainVars_hfpef_unircrd.pt1.RData")

# START HERE - SUNDAY ========
load("df_mainVars_hfpef_unircrd.pt1.RData")

# look into values needed to score ARIC
# modified EFFECT risk scores

class(df_mainVars_hfpef_unircrd.pt1$agei)
head(df_mainVars_hfpef_unircrd.pt1$agei)
table(df_mainVars_hfpef_unircrd.pt1$agei, useNA = "ifany")
class(df_mainVars_hfpef_unircrd.pt1$agei)

class(df_mainVars_hfpef$agei)
table(df_mainVars_hfpef$agei, useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1$agei_cat.f, useNA = "ifany")

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$agei))

class(df_mainVars_hfpef_unircrd.pt1$sbpi)
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$sbpi))
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$sbp_admit))
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$sbp_disc))

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$buni))

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$sodiumi))

table(df_mainVars_hfpef_unircrd.pt1$medhist_11, useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1$medhist_03, useNA = "ifany")

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$hgb_admit))

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$hr_admit))
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$hr_disc))
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$hri))

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$bnpi))

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$nbnpi))

sum(is.na(as.numeric(df_mainVars_hfpef_unircrd.pt1$bnpi)))
sum(is.na(as.numeric(df_mainVars_hfpef_unircrd.pt1$nbnpi)))

na_bnpi <- is.na(as.numeric(df_mainVars_hfpef_unircrd.pt1$bnpi))
na_nbnpi <- is.na(as.numeric(df_mainVars_hfpef_unircrd.pt1$nbnpi))

table(na_bnpi, na_nbnpi)

table(df_mainVars_hfpef_unircrd.pt1$medhist_30, useNA = "ifany")
table(df_mainVars_hfpef_unircrd.pt1$hfprocedures_131, useNA = "ifany")
table(df_mainVars_hfpef_unircrd.pt1$hfprocedures_119, useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1$racei, useNA = "ifany")

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$bmii))
table(as.numeric(df_mainVars_hfpef_unircrd.pt1$bmii) < 18.5,
      useNA = "ifany")

# look at SDOH for IHME variables
summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$ihme_zip_income_median))
hist(as.numeric(df_mainVars_hfpef_unircrd.pt1$ihme_zip_income_median))

library(dplyr)
aa <- df_mainVars_hfpef_unircrd.pt1 %>%
  select(rcrdnum, patient_display_id, facility_display_id,
         ptfacid, admyr, admdti.date, zip, ihme_zip_income_median)

df_mainVars_hfpef_unircrd.pt1 %>%
  group_by(admyr) %>%
  summarise(incmed = median(as.numeric(ihme_zip_income_median), na.rm = TRUE))

zipincome <- df_mainVars_hfpef_unircrd.pt1 %>%
  group_by(zip) %>%
  summarise(incmed = median(as.numeric(ihme_zip_income_median), na.rm = TRUE))

# add scoring here for ARIC, modified-EFFECT =========
# SKIP for now


# try merging in adi_by_zipcode.csv
# focus on one year
library(readr)
adi_by_zipcode <- read_csv("adi_by_zipcode.csv")

head(df_mainVars_hfpef_unircrd.pt1$zip)
sum(is.na(df_mainVars_hfpef_unircrd.pt1$zip))
tzip <- table(df_mainVars_hfpef_unircrd.pt1$zip, useNA = "ifany")
class(df_mainVars_hfpef_unircrd.pt1$zip)
library(dplyr)
dd <- df_mainVars_hfpef_unircrd.pt1 %>%
  select(rcrdnum, zip) %>%
  filter(zip == "100")
ddt<- t(dd)

df_mainVars_hfpef_unircrd.pt1$zipnum <-
  as.numeric(df_mainVars_hfpef_unircrd.pt1$zip)
tzipnum <- 
  table(df_mainVars_hfpef_unircrd.pt1$zipnum, 
        useNA = "ifany")
View(tzipnum)

adi_by_zipcode$zipnum <-
  as.numeric(adi_by_zipcode$zipcode)

adi_by_zipcode %>%
  filter(zipnum >= 1000 & zipnum < 1200) %>%
  filter(year == 2020) %>%
  View()












# MKH testing a tvem model =====
# UPDATED 03/31/2025
# try adding packages
library(tidyverse)

# i installed tvem =====
library(tvem)

# SKIP START HERE ====================
# example code from tvem package =====
set.seed(123)
the_data <- simulate_tvem_example()
tvem_model <- tvem(data=the_data,
                   formula=y~x1,
                   invar_effects=~x2,
                   id=subject_id,
                   time=time)
print(tvem_model)
plot(tvem_model)

# look at cross-sectional example
cross_sectional_example <- simulate_cross_sectional_tvem_example(
  n_subjects = 500,  
  min_time = 20,
  max_time = 70,
  simulate_binary = TRUE)

#print(head(cross_sectional_example))

model1_cross_sectional <- tvem(data=cross_sectional_example,
                               num_knots=2,
                               spline_order=1,
                               formula=y~1,
                               id=subject_id,
                               time=time)
print(model1_cross_sectional)
plot(model1_cross_sectional)

# shouldnt the above example be run for binary data
# run a logistic regression??

model2_cross_sectional <- tvem(data=cross_sectional_example,
                               formula=y~x1+x2,
                               id=subject_id,
                               time=time)
print(model2_cross_sectional)
plot(model2_cross_sectional)

# SKIP END HERE ====================

# quick clean up of memory
rm(df_mainVars_hfpef,
   df_mainVars_hfpef_unircrd)
gc()
rm(glue_client)
gc()
rm(aa)
gc()

# TVEM USE THIS 03/31/2025 ========
# Model 
# outcome: death or discharge to hospice
# dschstati.DH - see below coded 0=no, 1=death(code 6) or hospice (code 2,3)
# varying cov: ihme median income by ZIP
# ihme_zipincmednum - make numeric see below
# unique IDs:
length(unique(df_mainVars_hfpef_unircrd.pt1$ptfacid))
length(unique(df_mainVars_hfpef_unircrd.pt1$rcrdnum))
class(df_mainVars_hfpef_unircrd.pt1$rcrdnum)
df_mainVars_hfpef_unircrd.pt1$rcrdnum.num <-
  as.numeric(df_mainVars_hfpef_unircrd.pt1$rcrdnum)
class(df_mainVars_hfpef_unircrd.pt1$rcrdnum.num)
length(unique(df_mainVars_hfpef_unircrd.pt1$rcrdnum.num))
# strata:
# df_mainVars_hfpef_unircrd.pt1$genderi.f


table(df_mainVars_hfpef_unircrd.pt1$dschstati, useNA = "ifany")
class(df_mainVars_hfpef_unircrd.pt1$dschstati)
df_mainVars_hfpef_unircrd.pt1$dschstati.DH <- ifelse(
  (as.numeric(df_mainVars_hfpef_unircrd.pt1$dschstati) == 2) |
    (as.numeric(df_mainVars_hfpef_unircrd.pt1$dschstati) == 3) |
    (as.numeric(df_mainVars_hfpef_unircrd.pt1$dschstati) == 6),
  1, 0
)
table(df_mainVars_hfpef_unircrd.pt1$dschstati.DH, useNA = "ifany")

# make numeric
df_mainVars_hfpef_unircrd.pt1$ihme_zipincmednum <- 
  as.numeric(df_mainVars_hfpef_unircrd.pt1$ihme_zip_income_median)
class(df_mainVars_hfpef_unircrd.pt1$ihme_zipincmednum)

table(df_mainVars_hfpef_unircrd.pt1$admyr, useNA = "ifany")

df_mainVars_hfpef_unircrd.pt1.2019 <-
  df_mainVars_hfpef_unircrd.pt1 %>%
  filter(as.numeric(admyr) == 2019)

# resave files
save(df_mainVars_hfpef_unircrd.pt1,
     file = "df_mainVars_hfpef_unircrd.pt1.RData")
save(df_mainVars_hfpef_unircrd.pt1.2019,
     file = "df_mainVars_hfpef_unircrd.pt1.2019.RData")

# death or hospice for 2019
# 3624 yes, 69060 no, 24 missing
table(df_mainVars_hfpef_unircrd.pt1.2019$dschstati.DH, 
      useNA = "ifany")

summary(df_mainVars_hfpef_unircrd.pt1.2019$ihme_zipincmednum)

df_mainVars_hfpef_unircrd.pt1.2019 <-
  df_mainVars_hfpef_unircrd.pt1.2019 %>%
  mutate(ihme_zipincmednum_cat = case_when(
    (ihme_zipincmednum < 58025) ~ 1,
    ((ihme_zipincmednum >= 58025) & (ihme_zipincmednum < 67212)) ~ 2,
    ((ihme_zipincmednum >= 67212) & (ihme_zipincmednum < 77077)) ~ 3,
    (ihme_zipincmednum > 77077) ~ 4,
  ))

table(df_mainVars_hfpef_unircrd.pt1.2019$ihme_zipincmednum_cat,
      useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1.2019$dschstati.DH,
      df_mainVars_hfpef_unircrd.pt1.2019$ihme_zipincmednum_cat,
      useNA = "ifany")

# TVEM 03/31/2025 ======
library(tvem)

# logistic regression
# get prevalence over median income
# for discharged to hospice or death
# with this large data - taking a long time to run
# let's limit this to only one year, 2019 has most data
model_tvem <-
  tvem(data = df_mainVars_hfpef_unircrd.pt1.2019,
       formula = dschstati.DH ~ 1,
       family = binomial(),
       id = rcrdnum.num,
       time = ihme_zipincmednum
       )
print(model_tvem)
# plot odds ratios - SKIP THIS
plot(model_tvem,
     exponentiate = TRUE)

# get plot data from model
# pull plotting data out of model
x <- 
  model_tvem[["time_grid"]]
tvem_intercept <-
  model_tvem[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem <-
  tvem_intercept
plotdata_tvem$x <- x
#names(plotdata_tvem)

library(ggplot2)
ggplot(plotdata_tvem, 
       aes(x = x)) +
  geom_line(aes(y = exp(estimate)),
            linetype = "solid") +
  geom_line(aes(y = exp(lower)),
            linetype = "dashed") +
  geom_line(aes(y = exp(upper)),
            linetype = "dashed") +
  labs(title = "TVEM - Odds of Death or Hospice by Median Income in Patient Zipcode)",
       subtitle = "Intercept only model",
       caption = "IHME Median Income Linked by Zipcode") +
  xlab("Median Income in Patient's Zipcode") +
  ylab("TVEM Odds Ratios")

# look at prevalence instead
# names(plotdata_tvem)
plotdata_tvem$prob_est <-
  exp(plotdata_tvem$estimate)/(1 + (exp(plotdata_tvem$estimate)))
plotdata_tvem$prob_upper <-
  exp(plotdata_tvem$upper)/(1 + (exp(plotdata_tvem$upper)))
plotdata_tvem$prob_lower <-
  exp(plotdata_tvem$lower)/(1 + (exp(plotdata_tvem$lower)))

# get as a 100%
plotdata_tvem$prob_est.pct <-
  (exp(plotdata_tvem$estimate)/(1 + (exp(plotdata_tvem$estimate)))) * 100
plotdata_tvem$prob_upper.pct <-
  (exp(plotdata_tvem$upper)/(1 + (exp(plotdata_tvem$upper)))) * 100
plotdata_tvem$prob_lower.pct <-
  (exp(plotdata_tvem$lower)/(1 + (exp(plotdata_tvem$lower)))) * 100

# plot of prevalence
library(ggplot2)
ggplot(plotdata_tvem, 
       aes(x = x)) +
  geom_line(aes(y = prob_est.pct),
            linetype = "solid") +
  geom_line(aes(y = prob_upper.pct),
            linetype = "dashed") +
  geom_line(aes(y = prob_lower.pct),
            linetype = "dashed") +
  scale_x_continuous(breaks=seq(0, 150000, 25000)) +
  labs(title = "TVEM - Prevalence of Death or Hospice at Discharge",
       subtitle = "Intercept only model",
       caption = "IHME Median Income Linked to Patient's Zipcode") +
  xlab("Median Income in Patient's Zipcode") +
  ylab("TVEM Prevalence (as a percent, 0-100)") +
  theme_classic()

# stratify by race
table(df_mainVars_hfpef_unircrd.pt1.2019$racei, useNA = "ifany")
# 1=hispanic
# 2=black
# 3=AI An
# 4=Asian
# 5=White
# 6=NH PI
# 7=other
# 8=utd
# or missing, unknown
df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw <- ifelse(
  as.numeric(df_mainVars_hfpef_unircrd.pt1.2019$racei) == 5,
  1, 0
)
df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw.f <-
  factor(df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw,
         levels = c(0, 1),
         labels = c("non-White", "White"))
table(df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw.f,
      useNA = "ifany")
save(df_mainVars_hfpef_unircrd.pt1.2019,
     file = "df_mainVars_hfpef_unircrd.pt1.2019.RData")

# look at death or hospice by race
table(df_mainVars_hfpef_unircrd.pt1.2019$dschstati.DH,
      df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw.f,
      useNA = "ifany")
#        non-White        White         <NA>
# 0          20504        45870         2686 - other discharge
# 1            614 (2.9%)  2838 (5.8%)   172 - death/hospice
# <NA>           9           15            0

# get data - no missing for race ======================
dat1 <- df_mainVars_hfpef_unircrd.pt1.2019 %>%
  select(rcrdnum.num,
         ihme_zipincmednum,
         dschstati.DH,
         racei.wnw) %>%
  filter(complete.cases(.))

# also look at model of race
# to predict death or hospice
# and look over income
# this is giving an error
# Error in basis_for_b0 %*% model1$coefficients[indices_for_this_b] : 
#   non-conformable arguments
model_tvem <-
  tvem(data = dat1,
       formula = dschstati.DH ~ racei.wnw,
       family = binomial(),
       id = rcrdnum.num,
       time = ihme_zipincmednum
  )

# separate out by White, non-White race
dat1_nonwhite <- dat1 %>%
  filter(racei.wnw == 0)

dat1_white <- dat1 %>%
  filter(racei.wnw == 1)

# death/hospice prevalence - split by race =====
model_tvem_nonwhite <-
  tvem(
    data = dat1_nonwhite,
    formula = dschstati.DH ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

model_tvem_white <-
  tvem(
    data = dat1_white,
    formula = dschstati.DH ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

# pull plotting data out of model
x <- 
  model_tvem_nonwhite[["time_grid"]]
tvem_intercept <-
  model_tvem_nonwhite[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_nonwhite <-
  tvem_intercept
plotdata_tvem_nonwhite$x <- x

# compute prevalence * 100%
plotdata_tvem_nonwhite$prob_est <-
  (exp(plotdata_tvem_nonwhite$estimate)/(1 + (exp(plotdata_tvem_nonwhite$estimate)))) * 100
plotdata_tvem_nonwhite$prob_upper <-
  (exp(plotdata_tvem_nonwhite$upper)/(1 + (exp(plotdata_tvem_nonwhite$upper)))) * 100
plotdata_tvem_nonwhite$prob_lower <-
  (exp(plotdata_tvem_nonwhite$lower)/(1 + (exp(plotdata_tvem_nonwhite$lower)))) * 100

# pull plotting data out of model
x <- 
  model_tvem_white[["time_grid"]]
tvem_intercept <-
  model_tvem_white[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_white <-
  tvem_intercept
plotdata_tvem_white$x <- x

# compute prevalence * 100%
plotdata_tvem_white$prob_est <-
  (exp(plotdata_tvem_white$estimate)/(1 + (exp(plotdata_tvem_white$estimate)))) * 100
plotdata_tvem_white$prob_upper <-
  (exp(plotdata_tvem_white$upper)/(1 + (exp(plotdata_tvem_white$upper)))) * 100
plotdata_tvem_white$prob_lower <-
  (exp(plotdata_tvem_white$lower)/(1 + (exp(plotdata_tvem_white$lower)))) * 100

plotdata_tvem_nonwhite$group <- "Non-White"
plotdata_tvem_white$group <- "White"

plotdata_tvem_merged <-
  rbind(plotdata_tvem_nonwhite,
        plotdata_tvem_white)

ggplot(plotdata_tvem_merged, 
       aes(x = x, color = group)) +
  geom_line(aes(y = prob_est),
            linetype = "solid",
            linewidth = 1) +
  geom_line(aes(y = prob_lower),
            linetype = "dotted",
            linewidth = 0.8) +
  geom_line(aes(y = prob_upper),
            linetype = "dotted",
            linewidth = 0.8) +
  scale_color_manual(
    values = c("black", "purple")
  ) + 
  scale_x_continuous(breaks=seq(0, 150000, 25000)) +
  labs(title = "TVEM - Prevalence % of Death/Hospice by Median Income",
       subtitle = "Colored by Race",
       color = "Race",
       caption = "") +
  xlab("IHME Median Income Linked to Patient Zipcode") +
  ylab("TVEM - Prevalence in % (0-100%)") +
  theme_classic()

# do the same thing again for differences in gender
# get data - no missing for gender ======================
# note 0=male, 1=female
df_mainVars_hfpef_unircrd.pt1.2019$genderi.num <-
  as.numeric(df_mainVars_hfpef_unircrd.pt1.2019$genderi)
save(df_mainVars_hfpef_unircrd.pt1.2019,
     file = "df_mainVars_hfpef_unircrd.pt1.2019.RData")

dat1 <- df_mainVars_hfpef_unircrd.pt1.2019 %>%
  select(rcrdnum.num,
         ihme_zipincmednum,
         dschstati.DH,
         genderi.num) %>%
  filter(complete.cases(.))

# also look at model of gender (0=male, 1=female)
# to predict death or hospice
# and look over income
# this is giving an error
# Error in basis_for_b0 %*% model1$coefficients[indices_for_this_b] : 
#   non-conformable arguments
model_tvem <-
  tvem(data = dat1,
       formula = dschstati.DH ~ genderi.num,
       family = binomial(),
       id = rcrdnum.num,
       time = ihme_zipincmednum
  )

# separate out by gender
dat1_male <- dat1 %>%
  filter(genderi.num == 0)

dat1_female <- dat1 %>%
  filter(genderi.num == 1)

# death/hospice prevalence - split by biological sex =====
model_tvem_male <-
  tvem(
    data = dat1_male,
    formula = dschstati.DH ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

model_tvem_female <-
  tvem(
    data = dat1_female,
    formula = dschstati.DH ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

# pull plotting data out of model
x <- 
  model_tvem_male[["time_grid"]]
tvem_intercept <-
  model_tvem_male[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_male <-
  tvem_intercept
plotdata_tvem_male$x <- x

# compute prevalence * 100%
plotdata_tvem_male$prob_est <-
  (exp(plotdata_tvem_male$estimate)/(1 + (exp(plotdata_tvem_male$estimate)))) * 100
plotdata_tvem_male$prob_upper <-
  (exp(plotdata_tvem_male$upper)/(1 + (exp(plotdata_tvem_male$upper)))) * 100
plotdata_tvem_male$prob_lower <-
  (exp(plotdata_tvem_male$lower)/(1 + (exp(plotdata_tvem_male$lower)))) * 100

# pull plotting data out of model
x <- 
  model_tvem_female[["time_grid"]]
tvem_intercept <-
  model_tvem_female[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_female <-
  tvem_intercept
plotdata_tvem_female$x <- x

# compute prevalence * 100%
plotdata_tvem_female$prob_est <-
  (exp(plotdata_tvem_female$estimate)/(1 + (exp(plotdata_tvem_female$estimate)))) * 100
plotdata_tvem_female$prob_upper <-
  (exp(plotdata_tvem_female$upper)/(1 + (exp(plotdata_tvem_female$upper)))) * 100
plotdata_tvem_female$prob_lower <-
  (exp(plotdata_tvem_female$lower)/(1 + (exp(plotdata_tvem_female$lower)))) * 100

plotdata_tvem_male$group <- "Male"
plotdata_tvem_female$group <- "Female"

plotdata_tvem_merged <-
  rbind(plotdata_tvem_male,
        plotdata_tvem_female)

ggplot(plotdata_tvem_merged, 
       aes(x = x, color = group)) +
  geom_line(aes(y = prob_est),
            linetype = "solid",
            linewidth = 1) +
  geom_line(aes(y = prob_lower),
            linetype = "dotted",
            linewidth = 0.8) +
  geom_line(aes(y = prob_upper),
            linetype = "dotted",
            linewidth = 0.8) +
  scale_color_manual(
    values = c("black", "purple")
  ) + 
  scale_x_continuous(limits = c(25000, 120000),
                     breaks=seq(25000, 120000, 25000)) +
  scale_y_continuous(limits = c(0, 15)) +
  #scale_x_continuous(breaks=seq(0, 120000, 25000)) +
  labs(title = "TVEM - Prevalence % of Death/Hospice by Median Income",
       subtitle = "Colored by Biological Sex",
       color = "Biological Sex",
       caption = "") +
  xlab("IHME Median Income Linked to Patient Zipcode") +
  ylab("TVEM - Prevalence in % (0-100%)") +
  theme_classic()

# look at prescriptions of SGLT2
class(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc)
# 1=yes, 2=no, 3=inelgible/contraindicated
table(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc,
      df_mainVars_hfpef_unircrd.pt1.2019$ihme_zipincmednum_cat,
      useNA = "ifany")
class(df_mainVars_hfpef_unircrd.pt1.2019$ahahf93)
table(df_mainVars_hfpef_unircrd.pt1.2019$ahahf93,
      useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1$sglt2i_disc, useNA = "ifany")
table(df_mainVars_hfpef_unircrd.pt1$ahahf93, useNA = "ifany")

# look at SGLT2 by admit year - only starts in 2019
table(df_mainVars_hfpef_unircrd.pt1$sglt2i_disc, 
      df_mainVars_hfpef_unircrd.pt1$admyr,
      useNA = "ifany")
#       2005  2006  2007  2008  2009  2010  2011  2012  2013  2014  2015  2016  2017  2018
# 1        0     0     0     0     0     0     0     0     0     0     0     0     0     0
# 2        0     0     0     0     0     0     0     0     5     2     2     4     9    15
# 3        0     0     0     0     0     0     0     0     0     0     0     0     0     4
# <NA>  9898 15998 20344 24611 31195 40214 45371 43731 45141 47597 52557 61344 67445 69002
# 
#       2019  2020  2021  2022
# 1      151   565  1764  6117
# 2       46   245 42740 50363
# 3      726  1201  3711  7267
# <NA> 71785 60124 21118  6326

df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc.num <-
  as.numeric(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc)
df_mainVars_hfpef_unircrd.pt1.2019 <-
  df_mainVars_hfpef_unircrd.pt1.2019 %>%
  mutate(sglt2i_disc.yes = case_when(
    sglt2i_disc.num == 1 ~ 1,
    sglt2i_disc.num == 2 ~ 0,
    sglt2i_disc.num == 3 ~ 0,
    is.na(sglt2i_disc.num) ~ 0,
  ))
  
table(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc.num, useNA = "ifany")
table(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc.yes, useNA = "ifany")

table(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc.yes, 
      df_mainVars_hfpef_unircrd.pt1.2019$ihme_zipincmednum_cat,
      useNA = "ifany")
#         1     2     3     4  <NA>
#   0  9232  9242  9759  8719 35605
#   1    24    26    32    25    44

save(df_mainVars_hfpef_unircrd.pt1.2019,
     file = "df_mainVars_hfpef_unircrd.pt1.2019.RData")

# look at SGLT2 for 2019 =======
dat1 <- df_mainVars_hfpef_unircrd.pt1.2019 %>%
  select(sglt2i_disc.yes,
         rcrdnum.num,
         ihme_zipincmednum)
  
model_tvem_sglt2 <-
  tvem(
    data = dat1,
    formula = sglt2i_disc.yes ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

print(model_tvem_sglt2)
# plot odds ratios - SKIP THIS
plot(model_tvem_sglt2,
     exponentiate = TRUE)

# get plot data from model
# pull plotting data out of model
x <- 
  model_tvem_sglt2[["time_grid"]]
tvem_intercept <-
  model_tvem_sglt2[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem <-
  tvem_intercept
plotdata_tvem$x <- x
#names(plotdata_tvem)

library(ggplot2)
# ggplot(plotdata_tvem, 
#        aes(x = x)) +
#   geom_line(aes(y = exp(estimate)),
#             linetype = "solid") +
#   geom_line(aes(y = exp(lower)),
#             linetype = "dashed") +
#   geom_line(aes(y = exp(upper)),
#             linetype = "dashed") +
#   labs(title = "TVEM - Odds of Death or Hospice by Median Income in Patient Zipcode)",
#        subtitle = "Intercept only model",
#        caption = "IHME Median Income Linked by Zipcode") +
#   xlab("Median Income in Patient's Zipcode") +
#   ylab("TVEM Odds Ratios")

# look at prevalence instead
# names(plotdata_tvem)
plotdata_tvem$prob_est <-
  exp(plotdata_tvem$estimate)/(1 + (exp(plotdata_tvem$estimate)))
plotdata_tvem$prob_upper <-
  exp(plotdata_tvem$upper)/(1 + (exp(plotdata_tvem$upper)))
plotdata_tvem$prob_lower <-
  exp(plotdata_tvem$lower)/(1 + (exp(plotdata_tvem$lower)))

# get as a 100%
plotdata_tvem$prob_est.pct <-
  (exp(plotdata_tvem$estimate)/(1 + (exp(plotdata_tvem$estimate)))) * 100
plotdata_tvem$prob_upper.pct <-
  (exp(plotdata_tvem$upper)/(1 + (exp(plotdata_tvem$upper)))) * 100
plotdata_tvem$prob_lower.pct <-
  (exp(plotdata_tvem$lower)/(1 + (exp(plotdata_tvem$lower)))) * 100

# plot of prevalence
library(ggplot2)
ggplot(plotdata_tvem, 
       aes(x = x)) +
  geom_line(aes(y = prob_est.pct),
            linetype = "solid") +
  geom_line(aes(y = prob_upper.pct),
            linetype = "dashed") +
  geom_line(aes(y = prob_lower.pct),
            linetype = "dashed") +
  scale_x_continuous(breaks=seq(0, 150000, 25000)) +
  labs(title = "TVEM - Prevalence of SGLT2 prescription",
       subtitle = "",
       caption = "IHME Median Income Linked to Patient's Zipcode") +
  xlab("Median Income in Patient's Zipcode") +
  ylab("TVEM Prevalence (as a percent, 0-100)") +
  theme_classic()

# show breakdown by race ========================
table(df_mainVars_hfpef_unircrd.pt1.2019$sglt2i_disc.yes, 
      df_mainVars_hfpef_unircrd.pt1.2019$racei.wnw.f,
      useNA = "ifany")

# get data - no missing for race ======================
dat1 <- df_mainVars_hfpef_unircrd.pt1.2019 %>%
  select(rcrdnum.num,
         ihme_zipincmednum,
         sglt2i_disc.yes,
         racei.wnw) %>%
  filter(complete.cases(.))

# also look at model of race
# to predict death or hospice
# and look over income
# this is giving an error
# Error in basis_for_b0 %*% model1$coefficients[indices_for_this_b] : 
#   non-conformable arguments
model_tvem <-
  tvem(data = dat1,
       formula = sglt2i_disc.yes ~ racei.wnw,
       family = binomial(),
       id = rcrdnum.num,
       time = ihme_zipincmednum
  )

# separate out by White, non-White race
dat1_nonwhite <- dat1 %>%
  filter(racei.wnw == 0)

dat1_white <- dat1 %>%
  filter(racei.wnw == 1)

# death/hospice prevalence - split by race =====
model_tvem_nonwhite <-
  tvem(
    data = dat1_nonwhite,
    formula = sglt2i_disc.yes ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

model_tvem_white <-
  tvem(
    data = dat1_white,
    formula = sglt2i_disc.yes ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

# pull plotting data out of model
x <- 
  model_tvem_nonwhite[["time_grid"]]
tvem_intercept <-
  model_tvem_nonwhite[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_nonwhite <-
  tvem_intercept
plotdata_tvem_nonwhite$x <- x

# compute prevalence * 100%
plotdata_tvem_nonwhite$prob_est <-
  (exp(plotdata_tvem_nonwhite$estimate)/(1 + (exp(plotdata_tvem_nonwhite$estimate)))) * 100
plotdata_tvem_nonwhite$prob_upper <-
  (exp(plotdata_tvem_nonwhite$upper)/(1 + (exp(plotdata_tvem_nonwhite$upper)))) * 100
plotdata_tvem_nonwhite$prob_lower <-
  (exp(plotdata_tvem_nonwhite$lower)/(1 + (exp(plotdata_tvem_nonwhite$lower)))) * 100

# pull plotting data out of model
x <- 
  model_tvem_white[["time_grid"]]
tvem_intercept <-
  model_tvem_white[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_white <-
  tvem_intercept
plotdata_tvem_white$x <- x

# compute prevalence * 100%
plotdata_tvem_white$prob_est <-
  (exp(plotdata_tvem_white$estimate)/(1 + (exp(plotdata_tvem_white$estimate)))) * 100
plotdata_tvem_white$prob_upper <-
  (exp(plotdata_tvem_white$upper)/(1 + (exp(plotdata_tvem_white$upper)))) * 100
plotdata_tvem_white$prob_lower <-
  (exp(plotdata_tvem_white$lower)/(1 + (exp(plotdata_tvem_white$lower)))) * 100

plotdata_tvem_nonwhite$group <- "Non-White"
plotdata_tvem_white$group <- "White"

plotdata_tvem_merged <-
  rbind(plotdata_tvem_nonwhite,
        plotdata_tvem_white)

ggplot(plotdata_tvem_merged, 
       aes(x = x, color = group)) +
  geom_line(aes(y = prob_est),
            linetype = "solid",
            linewidth = 1) +
  geom_line(aes(y = prob_lower),
            linetype = "dotted",
            linewidth = 0.8) +
  geom_line(aes(y = prob_upper),
            linetype = "dotted",
            linewidth = 0.8) +
  scale_color_manual(
    values = c("black", "purple")
  ) + 
  scale_x_continuous(breaks=seq(25000, 125000, 25000),
                     limits = c(25000, 125000)) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(title = "TVEM - Prevalence % of SGLT2 Prescribed by Median Income",
       subtitle = "Colored by Race",
       color = "Race",
       caption = "") +
  xlab("IHME Median Income Linked to Patient Zipcode") +
  ylab("TVEM - Prevalence in % (0-100%)") +
  theme_classic()

# sglts2 by gender =======
dat1 <- df_mainVars_hfpef_unircrd.pt1.2019 %>%
  select(rcrdnum.num,
         ihme_zipincmednum,
         sglt2i_disc.yes,
         genderi.num) %>%
  filter(complete.cases(.))

# also look at model of gender (0=male, 1=female)
# to predict SGLT2
# and look over income
# this is giving an error
# Error in basis_for_b0 %*% model1$coefficients[indices_for_this_b] : 
#   non-conformable arguments
model_tvem <-
  tvem(data = dat1,
       formula = sglt2i_disc.yes ~ genderi.num,
       family = binomial(),
       id = rcrdnum.num,
       time = ihme_zipincmednum
  )

# separate out by gender
dat1_male <- dat1 %>%
  filter(genderi.num == 0)

dat1_female <- dat1 %>%
  filter(genderi.num == 1)

# SGLT2 prevalence - split by biological sex =====
model_tvem_male <-
  tvem(
    data = dat1_male,
    formula = sglt2i_disc.yes ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

model_tvem_female <-
  tvem(
    data = dat1_female,
    formula = sglt2i_disc.yes ~ 1,
    family = binomial(),
    id = rcrdnum.num,
    time = ihme_zipincmednum
  )

# pull plotting data out of model
x <- 
  model_tvem_male[["time_grid"]]
tvem_intercept <-
  model_tvem_male[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_male <-
  tvem_intercept
plotdata_tvem_male$x <- x

# compute prevalence * 100%
plotdata_tvem_male$prob_est <-
  (exp(plotdata_tvem_male$estimate)/(1 + (exp(plotdata_tvem_male$estimate)))) * 100
plotdata_tvem_male$prob_upper <-
  (exp(plotdata_tvem_male$upper)/(1 + (exp(plotdata_tvem_male$upper)))) * 100
plotdata_tvem_male$prob_lower <-
  (exp(plotdata_tvem_male$lower)/(1 + (exp(plotdata_tvem_male$lower)))) * 100

# pull plotting data out of model
x <- 
  model_tvem_female[["time_grid"]]
tvem_intercept <-
  model_tvem_female[["grid_fitted_coefficients"]][["(Intercept)"]]

# make df
plotdata_tvem_female <-
  tvem_intercept
plotdata_tvem_female$x <- x

# compute prevalence * 100%
plotdata_tvem_female$prob_est <-
  (exp(plotdata_tvem_female$estimate)/(1 + (exp(plotdata_tvem_female$estimate)))) * 100
plotdata_tvem_female$prob_upper <-
  (exp(plotdata_tvem_female$upper)/(1 + (exp(plotdata_tvem_female$upper)))) * 100
plotdata_tvem_female$prob_lower <-
  (exp(plotdata_tvem_female$lower)/(1 + (exp(plotdata_tvem_female$lower)))) * 100

plotdata_tvem_male$group <- "Male"
plotdata_tvem_female$group <- "Female"

plotdata_tvem_merged <-
  rbind(plotdata_tvem_male,
        plotdata_tvem_female)

ggplot(plotdata_tvem_merged, 
       aes(x = x, color = group)) +
  geom_line(aes(y = prob_est),
            linetype = "solid",
            linewidth = 1) +
  geom_line(aes(y = prob_lower),
            linetype = "dotted",
            linewidth = 0.8) +
  geom_line(aes(y = prob_upper),
            linetype = "dotted",
            linewidth = 0.8) +
  scale_color_manual(
    values = c("black", "purple")
  ) + 
  scale_x_continuous(limits = c(25000, 120000),
                     breaks=seq(25000, 120000, 25000)) +
  scale_y_continuous(limits = c(0, 1)) +
  #scale_x_continuous(breaks=seq(0, 120000, 25000)) +
  labs(title = "TVEM - Prevalence % of SGLT2 Prescription by Median Income",
       subtitle = "Colored by Biological Sex",
       color = "Biological Sex",
       caption = "") +
  xlab("IHME Median Income Linked to Patient Zipcode") +
  ylab("TVEM - Prevalence in % (0-100%)") +
  theme_classic()

summary(as.numeric(df_mainVars_hfpef_unircrd.pt1$admyr))

*********
Get block-nhood-tract crosswalk file
*********.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\HCTI\pvdblock2010_forHCTI.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  block_fips_code A15
  block_population F3.0
  census_tract A11
  zcta A5
  census_block_group A12
  neighborhood A25.
CACHE.
EXECUTE.
DATASET NAME block_walk WINDOW=FRONT.


*********
Get geo records for later
*********.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Community Profiles\data_files\data_files\RI_geo_records_withnhood.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  geo_name A25
  geo_id A12
  level A21
  moe F1.0.
CACHE.
EXECUTE.
DATASET NAME nhood.

DATASET ACTIVATE nhood.
FILTER OFF.
USE ALL.
SELECT IF (level = 'neighborhood').
EXECUTE.

**********************
Get BLOCK data, join on nhood, then create a file aggregated on nhood
**********************.
*\Race & Ethnicity.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (P1 P5 H11 QT-P11)\DEC_10_SF1_P5_Race.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Id A24
  block_fips_code A15
  Geography A77
  Total F4.0
  NotHispanicorLatino F3.0
  NotHispanicorLatinoWhitealone F3.0
  NotHispanicorLatinoBlackorAfricanAmericanalone F3.0
  NotHispanicorLatinoAmericanIndianandAlaskaNativealon F2.0
  NotHispanicorLatinoAsianalone F2.0
  NotHispanicorLatinoNativeHawaiianandOtherPacificIsla F1.0
  NotHispanicorLatinoSomeOtherRacealone F2.0
  NotHispanicorLatinoTwoorMoreRaces F2.0
  HispanicorLatino F3.0
  HispanicorLatinoWhitealone F3.0
  HispanicorLatinoBlackorAfricanAmericanalone F2.0
  HispanicorLatinoAmericanIndianandAlaskaNativealone F1.0
  HispanicorLatinoAsianalone F1.0
  HispanicorLatinoNativeHawaiianandOtherPacificIslander F1.0
  HispanicorLatinoSomeOtherRacealone F3.0
  HispanicorLatinoTwoorMoreRaces F2.0.
CACHE.
EXECUTE.
DATASET NAME RaceEthn WINDOW=FRONT.

ADD FILES FILE=*
/KEEP block_fips_code Total NotHispanicorLatinoWhitealone NotHispanicorLatinoBlackorAfricanAmericanalone NotHispanicorLatinoAmericanIndianandAlaskaNativealon
NotHispanicorLatinoAsianalone NotHispanicorLatinoNativeHawaiianandOtherPacificIsla NotHispanicorLatinoSomeOtherRacealone NotHispanicorLatinoTwoorMoreRaces HispanicorLatino.
RENAME VARIABLES 
NotHispanicorLatinoWhitealone=NH_White
NotHispanicorLatinoBlackorAfricanAmericanalone = NH_Black
NotHispanicorLatinoAmericanIndianandAlaskaNativealon = NH_AIAN
NotHispanicorLatinoAsianalone=NH_Asian
NotHispanicorLatinoNativeHawaiianandOtherPacificIsla=NH_NHOPI
NotHispanicorLatinoSomeOtherRacealone=NH_Other
NotHispanicorLatinoTwoorMoreRaces=NH_TwoOrMore
HispanicorLatino=Hispanic.

DATASET ACTIVATE block_walk.
SORT CASES BY block_fips_code(A).
DATASET ACTIVATE RaceEthn.
SORT CASES BY block_fips_code(A).
MATCH FILES /TABLE=*
  /FILE='block_walk'
  /BY block_fips_code.
EXECUTE.


DATASET ACTIVATE RaceEthn.
DATASET DECLARE RaceEthn_nhood.
SORT CASES BY neighborhood.
AGGREGATE
  /OUTFILE='RaceEthn_nhood'
  /PRESORTED
  /BREAK=neighborhood
  /Total=SUM(Total) 
  /NH_White=SUM(NH_White) 
  /NH_Black=SUM(NH_Black) 
  /NH_AIAN=SUM(NH_AIAN) 
  /NH_Asian=SUM(NH_Asian) 
  /NH_NHOPI=SUM(NH_NHOPI) 
  /NH_Other=SUM(NH_Other) 
  /NH_TwoOrMore=SUM(NH_TwoOrMore) 
  /Hispanic=SUM(Hispanic).
EXECUTE.

DATASET ACTIVATE RaceEthn_nhood.
FORMATS Total to Hispanic (F5.0).
EXECUTE.

COMPUTE Pct_Tot=Total/Total*100.
COMPUTE Pct_NHWhite=NH_White/Total*100.
COMPUTE Pct_NHBlack=NH_Black/Total*100.
COMPUTE Pct_NHAIAN=NH_AIAN/Total*100.
COMPUTE Pct_NHAsian=NH_Asian/Total*100.
COMPUTE Pct_NHNHOPI=NH_NHOPI/Total*100.
COMPUTE Pct_NHOther=NH_Other/Total*100.
COMPUTE Pct_TwoorMore=NH_TwoOrMore/Total*100.
COMPUTE Pct_Hisp=Hispanic/Total*100.
EXECUTE.

DATASET ACTIVATE RaceEthn_nhood.
FORMATS Pct_Tot to Pct_Hisp (F5.3).
EXECUTE.


DATASET ACTIVATE nhood.
SORT CASES BY geo_name(A).
DATASET ACTIVATE RaceEthn_nhood.
SORT CASES BY neighborhood(A).
DATASET ACTIVATE nhood.
MATCH FILES /FILE=*
  /TABLE='RaceEthn_nhood'
  /RENAME neighborhood=geo_name
  /BY geo_name.
EXECUTE.

DATASET CLOSE RaceEthn_nhood.
DATASET CLOSE RaceEthn.

*/Population in Occupied Housing units.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (P1 P5 H11 "+
    "QT-P11)\DEC_10_SF1_H11_PopTenure.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Id A24
  block_fips_code A15
  Geography A77
  Totalpopulationinoccupiedhousingunits F3.0
  Ownedwithamortgageoraloan F3.0
  Ownedfreeandclear F2.0
  Renteroccupied F3.0.
CACHE.
EXECUTE.
DATASET NAME PopInHH WINDOW=FRONT.

ADD FILES FILE=*
/KEEP block_fips_code Totalpopulationinoccupiedhousingunits Ownedwithamortgageoraloan Ownedfreeandclear Renteroccupied.
RENAME VARIABLES 
Totalpopulationinoccupiedhousingunits=TotPopInHU
Ownedwithamortgageoraloan=OwnPopMortgage
Ownedfreeandclear=OwnPopFree
Renteroccupied=RentPop.

DATASET ACTIVATE block_walk.
SORT CASES BY block_fips_code(A).
DATASET ACTIVATE PopInHH.
SORT CASES BY block_fips_code(A).
MATCH FILES /TABLE=*
  /FILE='block_walk'
  /BY block_fips_code.
EXECUTE.


DATASET ACTIVATE PopInHH.
DATASET DECLARE PopInHH_nhood.
SORT CASES BY neighborhood.
AGGREGATE
  /OUTFILE='PopInHH_nhood'
  /PRESORTED
  /BREAK=neighborhood
  /TotPopInHU=SUM(TotPopInHU) 
  /OwnPopMort=SUM(OwnPopMortgage) 
  /OwnPopFree=SUM(OwnPopFree) 
  /RentPop=SUM(RentPop).
EXECUTE.

DATASET ACTIVATE PopInHH_nhood.
FORMATS TotPopInHU to RentPop (F5.0).
EXECUTE.

COMPUTE PopOwn=(OwnPopMort+OwnPopFree).
COMPUTE Pct_TotPopInHU=TotPopInHU/TotPopInHU*100.
COMPUTE Pct_PopOwn=PopOwn/TotPopInHU*100.
COMPUTE Pct_RentPop=RentPop/TotPopInHU*100.
EXECUTE.

DATASET ACTIVATE PopInHH_nhood.
FORMATS PopOwn (F5.0).
FORMATS Pct_TotPopInHU to Pct_RentPop (F5.3).
EXECUTE.


DATASET ACTIVATE nhood.
SORT CASES BY geo_name(A).
DATASET ACTIVATE PopInHH_nhood.
SORT CASES BY neighborhood(A).
DATASET ACTIVATE nhood.
MATCH FILES /FILE=*
  /TABLE='PopInHH_nhood'
  /RENAME neighborhood=geo_name
  /BY geo_name.
EXECUTE.

DATASET CLOSE PopInHH_nhood.
DATASET CLOSE PopInHH.



*/housing unit tenure.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (P1 P5 H11 QT-P11)\DEC_10_SF1_QTH2_HUtenure.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Id A24
  block_fips_code A15
  Geography A77
  NumberTENUREOccupiedhousingunits F3.0
  PercentTENUREOccupiedhousingunits A5
  NumberTENUREOccupiedhousingunitsOwnedwithamortgage F2.0
  PercentTENUREOccupiedhousingunitsOwnedwithamortgage A5
  NumberTENUREOccupiedhousingunitsOwnedfreeandclear F2.0
  PercentTENUREOccupiedhousingunitsOwnedfreeandclear A5
  NumberTENUREOccupiedhousingunitsRenteroccupied F3.0
  PercentTENUREOccupiedhousingunitsRenteroccupied A4
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_G F2.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_G A5
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_F F2.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_F A5
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_E F2.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_E A5
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_D F2.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_D A5
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_C F2.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_C A5
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_B F1.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_B A4
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_A F1.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits_A A4
  NumberTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits F1.0
  PercentTENUREBYHOUSEHOLDSIZEOwneroccupiedhousingunits A4
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_G F3.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_G A5
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_F F2.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_F A5
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_E F2.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_E A5
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_D F2.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_D A4
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_C F2.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_C A4
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_B F1.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_B A5
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits_A F1.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit_A A4
  NumberTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunits F1.0
  PercentTENUREBYHOUSEHOLDSIZERenteroccupiedhousingunit A4
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_I F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_I A5
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_H F1.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_H A4
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_G F1.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_G A5
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_F F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_F A5
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_E F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_E A5
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_D F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_D A5
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_C F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_C A4
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_B F2.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_B A4
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun_A F1.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu_A A4
  NumberTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingun F1.0
  PercentTENUREBYAGEOFHOUSEHOLDEROwneroccupiedhousingu A4
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_I F3.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_I A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_H F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_H A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_G F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_G A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_F F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_F A4
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_E F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_E A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_D F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_D A4
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_C F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_C A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_B F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_B A5
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu_A F2.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing_A A4
  NumberTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousingu F1.0
  PercentTENUREBYAGEOFHOUSEHOLDERRenteroccupiedhousing A4.
CACHE.
EXECUTE.
DATASET NAME HU_Tenure WINDOW=FRONT.

ADD FILES FILE=*
/KEEP block_fips_code NumberTENUREOccupiedhousingunits NumberTENUREOccupiedhousingunitsOwnedwithamortgage NumberTENUREOccupiedhousingunitsOwnedfreeandclear NumberTENUREOccupiedhousingunitsRenteroccupied.
RENAME VARIABLES 
NumberTENUREOccupiedhousingunits=TotOccHU
NumberTENUREOccupiedhousingunitsOwnedwithamortgage=OwnMortgage
NumberTENUREOccupiedhousingunitsOwnedfreeandclear=OwnFree
NumberTENUREOccupiedhousingunitsRenteroccupied=RentHU.

DATASET ACTIVATE block_walk.
SORT CASES BY block_fips_code(A).
DATASET ACTIVATE HU_Tenure.
SORT CASES BY block_fips_code(A).
MATCH FILES /TABLE=*
  /FILE='block_walk'
  /BY block_fips_code.
EXECUTE.


DATASET ACTIVATE HU_Tenure.
DATASET DECLARE HU_Tenure_nhood.
SORT CASES BY neighborhood.
AGGREGATE
  /OUTFILE='HU_Tenure_nhood'
  /PRESORTED
  /BREAK=neighborhood
  /TotOccHU=SUM(TotOccHU) 
  /OwnMortgage=SUM(OwnMortgage) 
  /OwnFree=SUM(OwnFree) 
  /RentHU=SUM(RentHU).
EXECUTE.

DATASET ACTIVATE HU_Tenure_nhood.
FORMATS TotOccHU to RentHU (F5.0).
EXECUTE.

COMPUTE HUOwn=(OwnMortgage+OwnFree).
COMPUTE Pct_OccHU=TotOccHU/TotOccHU*100.
COMPUTE Pct_HUOwn=HUOwn/TotOccHU*100.
COMPUTE Pct_HURent=RentHU/TotOccHU*100.
EXECUTE.

DATASET ACTIVATE HU_Tenure_nhood.
FORMATS HUOwn (F5.0).
FORMATS Pct_OccHU to Pct_HURent (F5.3).
EXECUTE.



DATASET ACTIVATE nhood.
SORT CASES BY geo_name(A).
DATASET ACTIVATE HU_Tenure_nhood.
SORT CASES BY neighborhood(A).
DATASET ACTIVATE nhood.
MATCH FILES /FILE=*
  /TABLE='HU_Tenure_nhood'
  /RENAME neighborhood=geo_name
  /BY geo_name.
EXECUTE.

DATASET CLOSE HU_Tenure_nhood.
DATASET CLOSE HU_Tenure.



*/HH characteristics and types.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (P1 P5 H11 QT-P11)\DEC_10_SF1_QTP11_HHType.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Id A24
  block_fips_code A15
  Geography A77
  Num_Totalhouseholds F3.0
  PercentTotalhouseholds A5
  Num_TotHH_FamHH_1 F3.0
  PercentTotalhouseholdsFamHH_1 A5
  Num_TotHH_FamHH_1Malehouseholder F2.0
  PercentTotalhouseholdsFamHH_1Malehouseholder A5
  Num_TotHH_FamHH_1Femalehouseholder F2.0
  PercentTotalhouseholdsFamHH_1Femalehouseholder A5
  Num_TotHH_NonFamHH_2 F2.0
  PercentTotalhouseholdsNonFamHH_2 A4
  Num_TotHH_NonFamHH_2Malehouseholder F2.0
  PercentTotalhouseholdsNonFamHH_2Malehouseholder A4
  Num_TotHH_NonFamHH_2MalehouseholderLivingalone F2.0
  PercentTotalhouseholdsNonFamHH_2MalehouseholderLi A4
  Num_TotHH_NonFamHH_2Femalehouseholder F2.0
  PercentTotalhouseholdsNonFamHH_2Femalehouseholder_A A4
  Num_TotHH_NonFamHH_2FemalehouseholderLivingalone F2.0
  PercentTotalhouseholdsNonFamHH_2Femalehouseholder A4
  Num_HOUSEHOLDSIZETotalhouseholds F3.0
  PercentHOUSEHOLDSIZETotalhouseholds A5
  Num_HOUSEHOLDSIZETotalhouseholds1personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds1personhousehold A4
  Num_HOUSEHOLDSIZETotalhouseholds2personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds2personhousehold A5
  Num_HOUSEHOLDSIZETotalhouseholds3personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds3personhousehold A5
  Num_HOUSEHOLDSIZETotalhouseholds4personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds4personhousehold A4
  Num_HOUSEHOLDSIZETotalhouseholds5personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds5personhousehold A4
  Num_HOUSEHOLDSIZETotalhouseholds6personhousehold F2.0
  PercentHOUSEHOLDSIZETotalhouseholds6personhousehold A4
  Num_HOUSEHOLDSIZETotalhouseholds7ormorepersonhouseho F2.0
  PercentHOUSEHOLDSIZETotalhouseholds7ormorepersonho A4
  Num_HOUSEHOLDSIZETotalhouseholdsAveragehouseholdsize F4.2
  PercentHOUSEHOLDSIZETotalhouseholdsAveragehouseholds A7
  Num_HOUSEHOLDSIZETotalhouseholdsAveragefamilysize F4.2
  PercentHOUSEHOLDSIZETotalhouseholdsAveragefamilysize A7
  Num_Families3 F3.0
  PercentFamilies3 A5
  Num_Families3w_rel_childU18 F2.0
  PercentFamilies3w_rel_childU18 A5
  Num_Families3w_rel_childU18w_own_childU18 F2.0
  PercentFamilies3w_rel_childU18w_own_childU18 A5
  Num_Families3w_rel_childU18w_own_childU18Under6yea F2.0
  PercentFamilies3w_rel_childU18w_own_childU18Under_A A5
  Num_Families3w_rel_childU18w_own_childU18Under6and F2.0
  PercentFamilies3w_rel_childU18w_own_childU18Under A4
  Num_Families3w_rel_childU18w_own_childU186to17yea F2.0
  PercentFamilies3w_rel_childU18w_own_childU186to1 A5
  Num_Husbandwifefamilies F2.0
  PercentHusbandwifefamilies A5
  Num_Husbandwifefamiliesw_rel_childU18 F2.0
  PercentHusbandwifefamiliesw_rel_childU18 A5
  Num_Husbandwifefamiliesw_rel_childU18w_own_childU18 F2.0
  PercentHusbandwifefamiliesw_rel_childU18w_own_childU18_C A5
  Num_Husbandwifefamiliesw_rel_childU18w_own_childU18Un_A F1.0
  PercentHusbandwifefamiliesw_rel_childU18w_own_childU18_B A5
  Num_Husbandwifefamiliesw_rel_childU18w_own_childU18Un F1.0
  PercentHusbandwifefamiliesw_rel_childU18w_own_childU18_A A5
  Num_Husbandwifefamiliesw_rel_childU18w_own_childU186 F2.0
  PercentHusbandwifefamiliesw_rel_childU18w_own_childU18 A5
  Num_Femalehouseholdernohusbandpresentfamilies F2.0
  PercentFemalehouseholdernohusbandpresentfamilies A5
  Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_D F2.0
  PercentFemalehouseholdernohusbandpresentfamiliesw_rel_D A5
  Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_C F2.0
  PercentFemalehouseholdernohusbandpresentfamiliesw_rel_C A5
  Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_B F1.0
  PercentFemalehouseholdernohusbandpresentfamiliesw_rel_B A5
  Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_A F1.0
  PercentFemalehouseholdernohusbandpresentfamiliesw_rel_A A4
  Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil F2.0
  PercentFemalehouseholdernohusbandpresentfamiliesw_rel A5.
CACHE.
EXECUTE.
DATASET NAME HH_Type WINDOW=FRONT.


ADD FILES FILE=*
/KEEP block_fips_code Num_Totalhouseholds Num_TotHH_FamHH_1 Num_TotHH_FamHH_1Malehouseholder Num_TotHH_FamHH_1Femalehouseholder Num_TotHH_NonFamHH_2
Num_TotHH_NonFamHH_2Malehouseholder Num_TotHH_NonFamHH_2Femalehouseholder Num_Families3 Num_Families3w_rel_childU18 Num_Families3w_rel_childU18w_own_childU18 
Num_Husbandwifefamilies Num_Husbandwifefamiliesw_rel_childU18 Num_Husbandwifefamiliesw_rel_childU18w_own_childU18 Num_Femalehouseholdernohusbandpresentfamilies
Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_D Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_C.
VARIABLE LABELS
Num_Totalhouseholds 'Total households'
Num_TotHH_FamHH_1 'Family households'
Num_TotHH_FamHH_1Malehouseholder 'Family HH - Male householder'
Num_TotHH_FamHH_1Femalehouseholder 'Family HH - Female householder'
Num_TotHH_NonFamHH_2 'Nonfamily households'
Num_TotHH_NonFamHH_2Malehouseholder 'Nonfamily households - Male householder'
Num_TotHH_NonFamHH_2Femalehouseholder 'Nonfamily households - Female householder' 
Num_Families3 'Families'
Num_Families3w_rel_childU18 'Families - With related children under 18 years'
Num_Families3w_rel_childU18w_own_childU18 'Families - With own children under 18 years'
Num_Husbandwifefamilies 'Husband-wife families'
Num_Husbandwifefamiliesw_rel_childU18 'Husband-wife families - With related children under 18 years'
Num_Husbandwifefamiliesw_rel_childU18w_own_childU18 'Husband=wife families - With own children under 18 years'
Num_Femalehouseholdernohusbandpresentfamilies 'Female householder, no husband present families'
Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_D 'Female householder, no husband present families	- With related children under 18 years'
Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_C 'Female householder, no husband present families	- With own children under 18 years'.
RENAME VARIABLES 
Num_Totalhouseholds=TotHH
Num_TotHH_FamHH_1=TotFamHH
Num_TotHH_FamHH_1Malehouseholder =TotFamHHMaleHH
Num_TotHH_FamHH_1Femalehouseholder =TotFamHHFemaleHH
Num_TotHH_NonFamHH_2=TotNonFamHH
Num_TotHH_NonFamHH_2Malehouseholder=TotNonFamHHMaleHH 
Num_TotHH_NonFamHH_2Femalehouseholder =TotNonFamHHFemaleHH
Num_Families3 =TotFamilies
Num_Families3w_rel_childU18=TotFam_w_rel_childU18
Num_Families3w_rel_childU18w_own_childU18 =TotFam_w_own_childU18
Num_Husbandwifefamilies =TotHusWifeFam
Num_Husbandwifefamiliesw_rel_childU18 =TotHusWifeFam_w_rel_childU18
Num_Husbandwifefamiliesw_rel_childU18w_own_childU18 =TotHusWifeFam_w_own_childU18
Num_Femalehouseholdernohusbandpresentfamilies=FemaleHH_NoHusb
Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_D =FemHH_NoHusb_w_rel_childU18
Num_Femalehouseholdernohusbandpresentfamiliesw_rel_chil_C=FemHH_NoHusb_w_own_childU18.
EXECUTE.

DATASET ACTIVATE block_walk.
SORT CASES BY block_fips_code(A).
DATASET ACTIVATE HH_Type.
SORT CASES BY block_fips_code(A).
MATCH FILES /TABLE=*
  /FILE='block_walk'
  /BY block_fips_code.
EXECUTE.


DATASET ACTIVATE HH_Type.
DATASET DECLARE HH_Type_nhood.
SORT CASES BY neighborhood.
AGGREGATE
  /OUTFILE='HH_Type_nhood'
  /PRESORTED
  /BREAK=neighborhood
  /TotHH=SUM(TotHH)
  /TotFamHH=SUM(TotFamHH)
  /TotFamHHMaleHH=SUM(TotFamHHMaleHH)
  /TotFamHHFemaleHH=SUM(TotFamHHFemaleHH)
  /TotNonFamHH=SUM(TotNonFamHH)
  /TotNonFamHHMaleHH=SUM(TotNonFamHHMaleHH)
  /TotNonFamHHFemaleHH=SUM(TotNonFamHHFemaleHH)
  /TotFamilies=SUM(TotFamilies)
  /TotFam_w_rel_childU18=SUM(TotFam_w_rel_childU18)
  /TotFam_w_own_childU18=SUM(TotFam_w_own_childU18)
  /TotHusWifeFam=SUM(TotHusWifeFam)
  /TotHusWifeFam_w_rel_childU18=SUM(TotHusWifeFam_w_rel_childU18)
  /TotHusWifeFam_w_own_childU18=SUM(TotHusWifeFam_w_own_childU18)
  /FemaleHH_NoHusb=SUM(FemaleHH_NoHusb)
  /FemHH_NoHusb_w_rel_childU18=SUM(FemHH_NoHusb_w_rel_childU18)
  /FemHH_NoHusb_w_own_childU18=SUM(FemHH_NoHusb_w_own_childU18).
EXECUTE.

DATASET ACTIVATE HH_Type_nhood.
FORMATS TotHH to FemHH_NoHusb_w_own_childU18 (F5.0).
EXECUTE.

COMPUTE Pct_TotHH=TotHH/TotHH*100.
COMPUTE Pct_TotFamHH=TotFamHH/TotHH*100.
COMPUTE Pct_TotFamHHMaleHH=TotFamHHMaleHH/TotHH*100.
COMPUTE Pct_TotFamHHFemaleHH=TotFamHHFemaleHH/TotHH*100.
COMPUTE Pct_TotNonFamHH=TotNonFamHH/TotHH*100.
COMPUTE Pct_TotNonFamHHMaleHH=TotNonFamHHMaleHH/TotHH*100.
COMPUTE Pct_TotNonFamHHFemaleHH=TotNonFamHHFemaleHH/TotHH*100.
COMPUTE Pct_TotFamilies=TotFamilies/TotFamilies*100.
COMPUTE Pct_TotFam_w_rel_childU18=TotFam_w_rel_childU18/TotFamilies*100.
COMPUTE Pct_TotFam_w_own_childU18=TotFam_w_own_childU18/TotFamilies*100.
COMPUTE Pct_TotHusWifeFam=TotHusWifeFam/TotFamilies*100.
COMPUTE Pct_TotHusWifeFam_w_rel_childU18=TotHusWifeFam_w_rel_childU18/TotFamilies*100.
COMPUTE Pct_TotHusWifeFam_w_own_childU18=TotHusWifeFam_w_own_childU18/TotFamilies*100.
COMPUTE Pct_FemaleHH_NoHusb=FemaleHH_NoHusb/TotFamilies*100.
COMPUTE Pct_FemHH_NoHusb_w_rel_childU18=FemHH_NoHusb_w_rel_childU18/TotFamilies*100.
COMPUTE Pct_FemHH_NoHusb_w_own_childU18=FemHH_NoHusb_w_own_childU18/TotFamilies*100.
EXECUTE.


DATASET ACTIVATE nhood.
SORT CASES BY geo_name(A).
DATASET ACTIVATE HH_Type_nhood.
SORT CASES BY neighborhood(A).
DATASET ACTIVATE nhood.
MATCH FILES /FILE=*
  /TABLE='HH_Type_nhood'
  /RENAME neighborhood=geo_name
  /BY geo_name.
EXECUTE.

DATASET CLOSE HH_Type_nhood.
DATASET CLOSE HH_Type.


*/Age.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (P1 P5 P12)\DEC_10_SF1_P12.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Id A24
  block_fips_code A15
  Geography A77
  Total F4.0
  Male F3.0
  M_Under5 F2.0
  M_5_9 F2.0
  M_10_14 F2.0
  M_15_17 F2.0
  M_18_19 F3.0
  M_20 F2.0
  M_21 F2.0
  M_22_24 F2.0
  M_25_29 F2.0
  M_30_34 F2.0
  M_35_39 F2.0
  M_40_44 F2.0
  M_45_49 F2.0
  M_50_54 F2.0
  M_55_59 F2.0
  M_60_61 F1.0
  M_62_64 F1.0
  M_65_66 F1.0
  M_67_69 F1.0
  M_70_74 F1.0
  M_75_79 F1.0
  M_80_84 F1.0
  M_85_over F1.0
  Female F3.0
  F_Under5 F2.0
  F_5_9 F2.0
  F_10_14 F2.0
  F_15_17 F2.0
  F_18_19 F3.0
  F_20 F3.0
  F_21 F3.0
  F_22_24 F2.0
  F_25_29 F2.0
  F_30_34 F2.0
  F_35_39 F2.0
  F_40_44 F2.0
  F_45_49 F2.0
  F_50_54 F2.0
  F_55_59 F2.0
  F_60_61 F1.0
  F_62_64 F1.0
  F_65_66 F1.0
  F_67_69 F1.0
  F_70_74 F1.0
  F_75_79 F1.0
  F_80_84 F1.0
  F_85_over F1.0.
CACHE.
EXECUTE.
DATASET NAME Age WINDOW=FRONT.

COMPUTE Under18=(M_Under5+M_5_9+M_10_14+M_15_17+F_Under5+F_5_9+F_10_14+F_15_17).
COMPUTE Age18plus=(M_18_19+M_20+M_21+M_22_24+M_25_29+M_30_34+M_35_39+M_40_44+M_45_49+M_50_54+M_55_59+M_60_61+M_62_64+M_65_66+M_67_69
+M_70_74+M_75_79+M_80_84+M_85_over
+F_18_19+F_20+F_21+F_22_24+F_25_29+F_30_34+F_35_39+F_40_44+F_45_49+F_50_54+F_55_59+F_60_61+F_62_64+F_65_66+F_67_69+F_70_74+F_75_79+F_80_84+F_85_over).
COMPUTE Age18_64=(M_18_19+M_20+M_21+M_22_24+M_25_29+M_30_34+M_35_39+M_40_44+M_45_49+M_50_54+M_55_59+M_60_61+M_62_64
+F_18_19+F_20+F_21+F_22_24+F_25_29+F_30_34+F_35_39+F_40_44+F_45_49+F_50_54+F_55_59+F_60_61+F_62_64).
COMPUTE Age65plus=(M_65_66+M_67_69+M_70_74+M_75_79+M_80_84+M_85_over
+F_65_66+F_67_69+F_70_74+F_75_79+F_80_84+F_85_over).
COMPUTE Age0_4=(M_Under5+F_Under5).
COMPUTE Age5_17=(M_5_9+M_10_14+M_15_17+F_5_9+F_10_14+F_15_17).
COMPUTE Age18_24=(M_18_19+M_20+M_21+M_22_24+F_18_19+F_20+F_21+F_22_24).
COMPUTE Age25_34=(M_25_29+M_30_34+F_25_29+F_30_34).
COMPUTE Age35_54=(M_35_39+M_40_44+M_45_49+M_50_54+F_35_39+F_40_44+F_45_49+F_50_54).
COMPUTE Age55_64=(M_55_59+M_60_61+M_62_64+F_55_59+F_60_61+F_62_64).
FORMATS Under18 to Age55_64(F4.0).
EXECUTE.

ADD FILES FILE=*
/KEEP block_fips_code Total Under18 Age18plus Age18_64 Age65plus Age0_4 Age5_17 Age18_24 Age25_34 Age35_54 Age55_64.

DATASET ACTIVATE block_walk.
SORT CASES BY block_fips_code(A).
DATASET ACTIVATE Age.
SORT CASES BY block_fips_code(A).
MATCH FILES /TABLE=*
  /FILE='block_walk'
  /BY block_fips_code.
EXECUTE.

DATASET ACTIVATE Age.
DATASET DECLARE Age_nhood.
SORT CASES BY neighborhood.
AGGREGATE
  /OUTFILE='Age_nhood'
  /PRESORTED
  /BREAK=neighborhood
  /Total=SUM(Total) 
  /Under18=SUM(Under18) 
  /Age18plus=SUM(Age18plus) 
  /Age18_64=SUM(Age18_64) 
  /Age65plus=SUM(Age65plus) 
  /Age0_4=SUM(Age0_4) 
  /Age5_17=SUM(Age5_17) 
  /Age18_24=SUM(Age18_24) 
  /Age25_34=SUM(Age25_34)
  /Age35_54=SUM(Age35_54) 
  /Age55_64=SUM(Age55_64).
EXECUTE.

DATASET ACTIVATE Age_nhood.
FORMATS Total to Age55_64 (F4.0).
EXECUTE.


DATASET ACTIVATE nhood.
SORT CASES BY geo_name(A).
DATASET ACTIVATE Age_nhood.
SORT CASES BY neighborhood(A).
DATASET ACTIVATE nhood.
MATCH FILES /FILE=*
  /TABLE='Age_nhood'
  /RENAME neighborhood=geo_name
  /BY geo_name.
EXECUTE.

DATASET CLOSE Age_nhood.
DATASET CLOSE Age.


SAVE TRANSLATE OUTFILE='P:\WORK\Kim\NNIP\Nhood_Block_working\nhoods_block.csv'
  /TYPE=CSV
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

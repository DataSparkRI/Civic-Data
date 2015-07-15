
GET TRANSLATE
  FILE='M:\FedGov\CensusDecennial\2010\pvdblock2010.dbf'
  /TYPE=DBF /MAP .
DATASET NAME PVD_blocks10 WINDOW=FRONT.


GET DATA /TYPE=XLSX
  /FILE='P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\aff_download (12)\DEC_10_SF1_QTH3_tenure.xlsx'
  /SHEET=name 'Sheet2'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME tenure WINDOW=FRONT.

RENAME VARIABLES Id2=geoid10.
ALTER TYPE geoid10(a15).
EXECUTE.

***merge together***.
DATASET ACTIVATE PVD_blocks10.
SORT CASES BY geoid10(A).
DATASET ACTIVATE tenure.
SORT CASES BY geoid10(A).

DATASET ACTIVATE PVD_blocks10.
MATCH FILES /TABLE=*
  /FILE='tenure'
  /BY geoid10.
EXECUTE.

DATASET CLOSE tenure.

DATASET ACTIVATE PVD_blocks10.
DELETE VARIABLES 
D_R
mtfcc10
ur10
uace10
funcstat10
intptlat10
intptlon10
shape_leng
shape_area
distance
ward
islandshor
rirep02
risen04
hisp18p
nhisp18p
nhoner18p
nhwht18p
nhblk18p
nhaian18p
nhasian18p
nhnhopi18p
nhothr18p
nh2mo18p
policedist
totpop
hisp
nhisp
nhonera
nhwht
nhblk
nhaian
nhasian
nhnhopi
nhothr
nh2mo.


DATASET ACTIVATE PVD_blocks10.
USE ALL.
COMPUTE filter_$=(lname ~= '').
VARIABLE LABELS filter_$ "lname ~= '' (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


DATASET DECLARE nhood_10_blks.
SORT CASES BY lname.
AGGREGATE
  /OUTFILE='nhood_10_blks'
  /PRESORTED
  /BREAK=lname
  /Occ_HU_sum=SUM(Occ_HU) 
  /OwnOcc_HU_sum=SUM(OwnOcc_HU) 
  /RentOcc_HU_sum=SUM(RentOcc_HU) 
  /Pop_OwnOcc_HU_sum=SUM(Pop_OwnOcc_HU) 
  /Pop_RentOcc_HU_sum=SUM(Pop_RentOcc_HU).


DATASET ACTIVATE nhood_10_blks.
SAVE TRANSLATE OUTFILE='P:\WORK\Kim\NNIP\Nhood_Block_working\Block data\tenure_data.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

DATASET ACTIVATE PVD_blocks10.
DATASET CLOSE nhood_10_blks.

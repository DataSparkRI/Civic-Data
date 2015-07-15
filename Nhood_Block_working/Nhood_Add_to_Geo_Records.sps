
*********
Create nhood geo records for profiles format
*********.
GET DATA
  /TYPE=TXT
  /FILE="P:\WORK\Community Profiles\data_files\data_files\RI_geo_records.csv"
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
DATASET NAME Geo_Records WINDOW=FRONT.


*********
format nhood file for profiles requirements
*********.
*/dropped bc it didn't have a nhood code.
*GET TRANSLATE
  FILE='M:\ProvPlan\InfoGroup\neighborhoods_2011.dbf'
  /TYPE=DBF /MAP .
*DATASET NAME nhood_2011 WINDOW=FRONT.

GET TRANSLATE
  FILE='M:\ProvPlan\InfoGroup\neighborhood_5k.dbf'
  /TYPE=DBF /MAP .
DATASET NAME nhood WINDOW=FRONT.

ADD FILES FILE=*
/KEEP nhcode sname lname.

ALTER TYPE nhcode(a12).
ALTER TYPE lname(a30).
RENAME VARIABLES nhcode=geo_id lname=geo_name.
EXECUTE.

STRING Level(a21).
COMPUTE Level='neighborhood'.
EXECUTE.
COMPUTE moe=0.
EXECUTE.
FORMATS moe(f1.0).
EXECUTE.
COMPUTE geo_id = LTRIM(geo_id).
EXECUTE.

ADD FILES FILE=*
/KEEP geo_name geo_id level moe.
ALTER TYPE geo_name(a25).

DATASET ACTIVATE Geo_Records.
ADD FILES /FILE=*
  /FILE='nhood'.
EXECUTE.

*/only need to do this once.
*SAVE TRANSLATE OUTFILE='P:\WORK\Community Profiles\data_files\data_files\RI_geo_records_withnhood.csv'
  /TYPE=CSV
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

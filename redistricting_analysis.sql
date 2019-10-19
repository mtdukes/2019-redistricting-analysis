/*REDISTRICTING ANALYSIS
The commands below import, clean and analyze data from the 2010 Census and the remedial NC House and Senate maps redrawn in September 2019 in response to a court order.

The queries use the following tables:
~ 2016_results_correx ~
Election results from 2016 sorted into precincts, requested from the NC State Board of Elections at the following URL: https://dl.ncsbe.gov/index.html?prefix=Requests/Dukes_Tyler/2016-11-08/ This version applies additional precinct sorting compared a previous file posted on the BOE site, for more accurate results. Files for individual counties were combined into one table. NOTE: Contains derived fields, described in detail below.

~ 2019_house_baf ~
Block assignment file for the 2019 remedial maps linking new NC House districts to their respective Census blocks. Sourced from the legislature at the following URL: https://www.ncleg.gov/documentsites/committees/house2019-182/09-13-2019/HB%201020%20H%20Red%20Comm%20PCS%20corrected%20v2_baf.zip

~ 2019_senate_baf ~
Block assignment file for the 2019 remedial maps linking new NC Senate districts to their respective Census blocks. Sourced from the legislature at the following URL: https://www.ncleg.gov/documentsites/committees/senate2019-154/Senate%20Consensus%20Nonpartisan%20Map/Senate%20Consensus%20Nonpartisan%20Map%20v3_BlockFile.zip

~ block_to_precinct ~
File created by the NC State Board of Elections linking each Census block to its respective precinct. Obtained from SBOE via email. NOTE: contains dervied fields described below.

~2019_redrawn_districts~
File created by WRAL to note the districts redrawn during the 2019 remedial processs. Includes the county clusters. Sourced from NC General Assembly.

~fips~
Table is a simple list of counties and fips codes, used for matching precincts with counties, since precinct names aren't unique

~meck_weights~
Table deriveded from the N.C. State Board of Elections data showing the precincts associated with each ballot style, along with their active voters. Used to weight the nearly 8,000 unsorted votes from Mecklenburg County into their estimated precincts. NOTE: This additional weighting did not change the overall findings.

~ geo_header ~
One of three Census redistricting files that describe the demographics gathered and caculated for the 2010 Census. This file contains the State/County/Tract/Block IDs link to the logical record number, which can then be linked to the other two tables. Sourced from the U.S. Census at the following URL: https://www2.census.gov/census_2010/01-Redistricting_File--PL_94-171/

~ nc000012010 ~
One of three Census redistricting files that describe the demographics gathered and caculated for the 2010 Census. This file contains race and ethnicity tables for the entire population Sourced from the U.S. Census at the following URL: https://www2.census.gov/census_2010/01-Redistricting_File--PL_94-171/

~ nc000022010 ~
One of three Census redistricting files that describe the demographics gathered and caculated for the 2010 Census. This file contains race and ethnicity data for the voting-age population, along with a seperate table on housing status. Sourced from the U.S. Census at the following URL: https://www2.census.gov/census_2010/01-Redistricting_File--PL_94-171/

By Tyler Dukes, WRAL
*/

/* STEP ONE: Create and load our Census table
Uses the file layout described in the data dictionary from Chapter 6 of the Census Redistricting Data Summary File's technical documentation located here: https://www2.census.gov/programs-surveys/decennial/rdo/about/2010-census-programs/2010Census_pl94-171_techdoc.pdf

These are the only files manually imported. The rest were imported through the import wizard
*/
#define the table
CREATE TABLE geo_header (
   fileid VARCHAR(255),
   stusab VARCHAR(255),
   sumlev VARCHAR(255),
   geocomp VARCHAR(255),
   chariter VARCHAR(255),
   cifsn VARCHAR(255),
   logrecno VARCHAR(255),
   region VARCHAR(255),
   division VARCHAR(255),
   state VARCHAR(255),
   county VARCHAR(255),
   countycc VARCHAR(255),
   countysc VARCHAR(255),
   cousub VARCHAR(255),
   cousubcc VARCHAR(255),
   cousubsc VARCHAR(255),
   place VARCHAR(255),
   placecc VARCHAR(255),
   placesc VARCHAR(255),
   tract VARCHAR(255),
   blkgrp VARCHAR(255),
   block VARCHAR(255),
   iuc VARCHAR(255),
   concit VARCHAR(255),
   concitcc VARCHAR(255),
   concitsc VARCHAR(255),
   aianhh VARCHAR(255),
   aianhhfp VARCHAR(255),
   aianhhcc VARCHAR(255),
   aihhtli VARCHAR(255),
   aitsce VARCHAR(255),
   aits VARCHAR(255),
   aitscc VARCHAR(255),
   ttract VARCHAR(255),
   tblkgrp VARCHAR(255),
   anrc VARCHAR(255),
   anrccc VARCHAR(255),
   cbsa VARCHAR(255),
   cbsasc VARCHAR(255),
   metdic VARCHAR(255),
   csa VARCHAR(255),
   necta VARCHAR(255),
   nectasc VARCHAR(255),
   nectadeiv VARCHAR(255),
   cnecta VARCHAR(255),
   cbsapci VARCHAR(255),
   nectapci VARCHAR(255),
   ua VARCHAR(255),
   uasc VARCHAR(255),
   uatype VARCHAR(255),
   ur VARCHAR(255),
   cd VARCHAR(255),
   sldu VARCHAR(255),
   sldl VARCHAR(255),
   vtd VARCHAR(255),
   vtdi VARCHAR(255),
   reserve2 VARCHAR(255),
   zcta5 VARCHAR(255),
   submcd VARCHAR(255),
   submcdcc VARCHAR(255),
   sdelm VARCHAR(255),
   sdsec VARCHAR(255),
   sduni VARCHAR(255),
   arealand VARCHAR(255),
   areawater VARCHAR(255),
   name VARCHAR(255),
   funcstat VARCHAR(255),
   gcuni VARCHAR(255),
   pop100 VARCHAR(255),
   hu100 VARCHAR(255),
   intptlat VARCHAR(255),
   intptlon VARCHAR(255),
   lsadc VARCHAR(255),
   partflag VARCHAR(255),
   reserve3 VARCHAR(255),
   uga VARCHAR(255),
   statens VARCHAR(255),
   countyns VARCHAR(255),
   cousubns VARCHAR(255),
   placens VARCHAR(255),
   concitns VARCHAR(255),
   aianhhns VARCHAR(255),
   aitsns VARCHAR(255),
   anrcns VARCHAR(255),
   submcdns VARCHAR(255),
   cd113 VARCHAR(255),
   cd114 VARCHAR(255),
   cd115 VARCHAR(255),
   sldu2 VARCHAR(255),
   sldu3 VARCHAR(255),
   sldu4 VARCHAR(255),
   sldl2 VARCHAR(255),
   sldl3 VARCHAR(255),
   sldl4 VARCHAR(255),
   aianhhsc VARCHAR(255),
   csasc VARCHAR(255),
   cnectasc VARCHAR(255),
   memi VARCHAR(255),
   nmemi VARCHAR(255),
   puma VARCHAR(255),
   reserved VARCHAR(255)
);

#load in the data as specified by the Census data dictionary
LOAD DATA LOCAL
INFILE '/Users/mtdukes/Dropbox/projects/wral/redistricting/legislative-redistricting-092019/census_data/ncgeo2010.pl' INTO TABLE geo_header
(@row)
SET
 fileid = TRIM( SUBSTR(@row,1,6) ),
 stusab = TRIM( SUBSTR(@row,7,2) ),
 sumlev = TRIM( SUBSTR(@row,9,3) ),
 geocomp = TRIM( SUBSTR(@row,12,2) ),
 chariter = TRIM( SUBSTR(@row,14,3) ),
 cifsn= TRIM( SUBSTR(@row,17,2) ),
 logrecno = TRIM( SUBSTR(@row,19,7) ),
 region = TRIM( SUBSTR(@row,26,1) ),
 division = TRIM( SUBSTR(@row,27,1) ),
 state = TRIM( SUBSTR(@row,28,2) ),
 county = TRIM( SUBSTR(@row,30,3) ),
 countycc = TRIM( SUBSTR(@row,33,2) ),
 countysc = TRIM( SUBSTR(@row,35,2) ),
 cousub = TRIM( SUBSTR(@row,37,5) ),
 cousubcc = TRIM( SUBSTR(@row,42,2) ),
 cousubsc = TRIM( SUBSTR(@row,44,2) ),
 place = TRIM( SUBSTR(@row,46,5) ),
 placecc = TRIM( SUBSTR(@row,51,2) ),
 placesc = TRIM( SUBSTR(@row,53,2) ),
 tract = TRIM( SUBSTR(@row,55,6) ),
 blkgrp = TRIM( SUBSTR(@row,61,1) ),
 block = TRIM( SUBSTR(@row,62,4) ),
 iuc = TRIM( SUBSTR(@row,66,2) ),
 concit = TRIM( SUBSTR(@row,68,5) ),
 concitcc = TRIM( SUBSTR(@row,73,2) ),
 concitsc = TRIM( SUBSTR(@row,75,2) ),
 aianhh = TRIM( SUBSTR(@row,77,4) ),
 aianhhfp = TRIM( SUBSTR(@row,81,5) ),
 aianhhcc = TRIM( SUBSTR(@row,86,2) ),
 aihhtli = TRIM( SUBSTR(@row,88,1) ),
 aitsce = TRIM( SUBSTR(@row,89,3) ),
 aits = TRIM( SUBSTR(@row,92,5) ),
 aitscc = TRIM( SUBSTR(@row,97,2) ),
 ttract = TRIM( SUBSTR(@row,99,6) ),
 tblkgrp = TRIM( SUBSTR(@row,105,1) ),
 anrc = TRIM( SUBSTR(@row,106,5) ),
 anrccc = TRIM( SUBSTR(@row,111,2) ),
 cbsa = TRIM( SUBSTR(@row,113,5) ),
 cbsasc = TRIM( SUBSTR(@row,118,2) ),
 metdic = TRIM( SUBSTR(@row,120,5) ),
 csa = TRIM( SUBSTR(@row,125,3) ),
 necta = TRIM( SUBSTR(@row,128,5) ),
 nectasc = TRIM( SUBSTR(@row,133,2) ),
 nectadeiv = TRIM( SUBSTR(@row,135,5) ),
 cnecta = TRIM( SUBSTR(@row,140,3) ),
 cbsapci = TRIM( SUBSTR(@row,143,1) ),
 nectapci = TRIM( SUBSTR(@row,144,1) ),
 ua = TRIM( SUBSTR(@row,145,5) ),
 uasc = TRIM( SUBSTR(@row,150,2) ),
 uatype = TRIM( SUBSTR(@row,152,1) ),
 ur = TRIM( SUBSTR(@row,153,1) ),
 cd = TRIM( SUBSTR(@row,154,2) ),
 sldu = TRIM( SUBSTR(@row,156,3) ),
 sldl = TRIM( SUBSTR(@row,159,3) ),
 vtd = TRIM( SUBSTR(@row,162,6) ),
 vtdi = TRIM( SUBSTR(@row,168,1) ),
 reserve2 = TRIM( SUBSTR(@row,169,3) ),
 zcta5 = TRIM( SUBSTR(@row,172,5) ),
 submcd = TRIM( SUBSTR(@row,177,5) ),
 submcdcc = TRIM( SUBSTR(@row,182,2) ),
 sdelm = TRIM( SUBSTR(@row,184,5) ),
 sdsec = TRIM( SUBSTR(@row,189,5) ),
 sduni = TRIM( SUBSTR(@row,194,5) ),
 arealand = TRIM( SUBSTR(@row,199,14) ),
 areawater = TRIM( SUBSTR(@row,213,14) ),
 name = TRIM( SUBSTR(@row,227,90) ),
 funcstat = TRIM( SUBSTR(@row,317,1) ),
 gcuni = TRIM( SUBSTR(@row,318,1) ),
 pop100 = TRIM( SUBSTR(@row,319,9) ),
 hu100 = TRIM( SUBSTR(@row,328,9) ),
 intptlat = TRIM( SUBSTR(@row,337,11) ),
 intptlon = TRIM( SUBSTR(@row,348,12) ),
 lsadc = TRIM( SUBSTR(@row,360,2) ),
 partflag = TRIM( SUBSTR(@row,362,1) ),
 reserve3 = TRIM( SUBSTR(@row,363,6) ),
 uga = TRIM( SUBSTR(@row,369,5) ),
 statens = TRIM( SUBSTR(@row,374,8) ),
 countyns = TRIM( SUBSTR(@row,382,8) ),
 cousubns = TRIM( SUBSTR(@row,390,8) ),
 placens = TRIM( SUBSTR(@row,398,8) ),
 concitns = TRIM( SUBSTR(@row,406,8) ),
 aianhhns = TRIM( SUBSTR(@row,414,8) ),
 aitsns = TRIM( SUBSTR(@row,422,8) ),
 anrcns = TRIM( SUBSTR(@row,430,8) ),
 submcdns = TRIM( SUBSTR(@row,438,8) ),
 cd113 = TRIM( SUBSTR(@row,446,2) ),
 cd114 = TRIM( SUBSTR(@row,448,2) ),
 cd115 = TRIM( SUBSTR(@row,450,2) ),
 sldu2 = TRIM( SUBSTR(@row,452,3) ),
 sldu3 = TRIM( SUBSTR(@row,455,3) ),
 sldu4 = TRIM( SUBSTR(@row,458,3) ),
 sldl2 = TRIM( SUBSTR(@row,461,3) ),
 sldl3 = TRIM( SUBSTR(@row,464,3) ),
 sldl4 = TRIM( SUBSTR(@row,467,3) ),
 aianhhsc = TRIM( SUBSTR(@row,470,2) ),
 csasc = TRIM( SUBSTR(@row,472,2) ),
 cnectasc = TRIM( SUBSTR(@row,474,2) ),
 memi = TRIM( SUBSTR(@row,476,1) ),
 nmemi = TRIM( SUBSTR(@row,477,1) ),
 puma = TRIM( SUBSTR(@row,478,5) ),
 reserved = TRIM( SUBSTR(@row,483,18) );

#create our table containing the first census file data on race/ethnicity for the population
 CREATE TABLE nc000012010 (
	fileid VARCHAR(255),
	stusab VARCHAR(255),
	chariter VARCHAR(255),
	cifsn VARCHAR(255),
	logrecno VARCHAR(255),
	P0010001 VARCHAR(255),
	P0010002 VARCHAR(255),
	P0010003 VARCHAR(255),
	P0010004 VARCHAR(255),
	P0010005 VARCHAR(255),
	P0010006 VARCHAR(255),
	P0010007 VARCHAR(255),
	P0010008 VARCHAR(255),
	P0010009 VARCHAR(255),
	P0010010 VARCHAR(255),
	P0010011 VARCHAR(255),
	P0010012 VARCHAR(255),
	P0010013 VARCHAR(255),
	P0010014 VARCHAR(255),
	P0010015 VARCHAR(255),
	P0010016 VARCHAR(255),
	P0010017 VARCHAR(255),
	P0010018 VARCHAR(255),
	P0010019 VARCHAR(255),
	P0010020 VARCHAR(255),
	P0010021 VARCHAR(255),
	P0010022 VARCHAR(255),
	P0010023 VARCHAR(255),
	P0010024 VARCHAR(255),
	P0010025 VARCHAR(255),
	P0010026 VARCHAR(255),
	P0010027 VARCHAR(255),
	P0010028 VARCHAR(255),
	P0010029 VARCHAR(255),
	P0010030 VARCHAR(255),
	P0010031 VARCHAR(255),
	P0010032 VARCHAR(255),
	P0010033 VARCHAR(255),
	P0010034 VARCHAR(255),
	P0010035 VARCHAR(255),
	P0010036 VARCHAR(255),
	P0010037 VARCHAR(255),
	P0010038 VARCHAR(255),
	P0010039 VARCHAR(255),
	P0010040 VARCHAR(255),
	P0010041 VARCHAR(255),
	P0010042 VARCHAR(255),
	P0010043 VARCHAR(255),
	P0010044 VARCHAR(255),
	P0010045 VARCHAR(255),
	P0010046 VARCHAR(255),
	P0010047 VARCHAR(255),
	P0010048 VARCHAR(255),
	P0010049 VARCHAR(255),
	P0010050 VARCHAR(255),
	P0010051 VARCHAR(255),
	P0010052 VARCHAR(255),
	P0010053 VARCHAR(255),
	P0010054 VARCHAR(255),
	P0010055 VARCHAR(255),
	P0010056 VARCHAR(255),
	P0010057 VARCHAR(255),
	P0010058 VARCHAR(255),
	P0010059 VARCHAR(255),
	P0010060 VARCHAR(255),
	P0010061 VARCHAR(255),
	P0010062 VARCHAR(255),
	P0010063 VARCHAR(255),
	P0010064 VARCHAR(255),
	P0010065 VARCHAR(255),
	P0010066 VARCHAR(255),
	P0010067 VARCHAR(255),
	P0010068 VARCHAR(255),
	P0010069 VARCHAR(255),
	P0010070 VARCHAR(255),
	P0010071 VARCHAR(255),
	P0020001 VARCHAR(255),
	P0020002 VARCHAR(255),
	P0020003 VARCHAR(255),
	P0020004 VARCHAR(255),
	P0020005 VARCHAR(255),
	P0020006 VARCHAR(255),
	P0020007 VARCHAR(255),
	P0020008 VARCHAR(255),
	P0020009 VARCHAR(255),
	P0020010 VARCHAR(255),
	P0020011 VARCHAR(255),
	P0020012 VARCHAR(255),
	P0020013 VARCHAR(255),
	P0020014 VARCHAR(255),
	P0020015 VARCHAR(255),
	P0020016 VARCHAR(255),
	P0020017 VARCHAR(255),
	P0020018 VARCHAR(255),
	P0020019 VARCHAR(255),
	P0020020 VARCHAR(255),
	P0020021 VARCHAR(255),
	P0020022 VARCHAR(255),
	P0020023 VARCHAR(255),
	P0020024 VARCHAR(255),
	P0020025 VARCHAR(255),
	P0020026 VARCHAR(255),
	P0020027 VARCHAR(255),
	P0020028 VARCHAR(255),
	P0020029 VARCHAR(255),
	P0020030 VARCHAR(255),
	P0020031 VARCHAR(255),
	P0020032 VARCHAR(255),
	P0020033 VARCHAR(255),
	P0020034 VARCHAR(255),
	P0020035 VARCHAR(255),
	P0020036 VARCHAR(255),
	P0020037 VARCHAR(255),
	P0020038 VARCHAR(255),
	P0020039 VARCHAR(255),
	P0020040 VARCHAR(255),
	P0020041 VARCHAR(255),
	P0020042 VARCHAR(255),
	P0020043 VARCHAR(255),
	P0020044 VARCHAR(255),
	P0020045 VARCHAR(255),
	P0020046 VARCHAR(255),
	P0020047 VARCHAR(255),
	P0020048 VARCHAR(255),
	P0020049 VARCHAR(255),
	P0020050 VARCHAR(255),
	P0020051 VARCHAR(255),
	P0020052 VARCHAR(255),
	P0020053 VARCHAR(255),
	P0020054 VARCHAR(255),
	P0020055 VARCHAR(255),
	P0020056 VARCHAR(255),
	P0020057 VARCHAR(255),
	P0020058 VARCHAR(255),
	P0020059 VARCHAR(255),
	P0020060 VARCHAR(255),
	P0020061 VARCHAR(255),
	P0020062 VARCHAR(255),
	P0020063 VARCHAR(255),
	P0020064 VARCHAR(255),
	P0020065 VARCHAR(255),
	P0020066 VARCHAR(255),
	P0020067 VARCHAR(255),
	P0020068 VARCHAR(255),
	P0020069 VARCHAR(255),
	P0020070 VARCHAR(255),
	P0020071 VARCHAR(255),
	P0020072 VARCHAR(255),
	P0020073 VARCHAR(255)
);

#load in our census data from the first file
LOAD DATA LOCAL
INFILE '/Users/mtdukes/Dropbox/projects/wral/redistricting/legislative-redistricting-092019/census_data/nc000012010.pl' 
INTO TABLE nc000012010 
    FIELDS TERMINATED BY ',' 
           OPTIONALLY ENCLOSED BY '"'
    LINES  TERMINATED BY '\n'
(
	fileid,
	stusab,
	chariter,
	cifsn,
	logrecno,
	P0010001,
	P0010002,
	P0010003,
	P0010004,
	P0010005,
	P0010006,
	P0010007,
	P0010008,
	P0010009,
	P0010010,
	P0010011,
	P0010012,
	P0010013,
	P0010014,
	P0010015,
	P0010016,
	P0010017,
	P0010018,
	P0010019,
	P0010020,
	P0010021,
	P0010022,
	P0010023,
	P0010024,
	P0010025,
	P0010026,
	P0010027,
	P0010028,
	P0010029,
	P0010030,
	P0010031,
	P0010032,
	P0010033,
	P0010034,
	P0010035,
	P0010036,
	P0010037,
	P0010038,
	P0010039,
	P0010040,
	P0010041,
	P0010042,
	P0010043,
	P0010044,
	P0010045,
	P0010046,
	P0010047,
	P0010048,
	P0010049,
	P0010050,
	P0010051,
	P0010052,
	P0010053,
	P0010054,
	P0010055,
	P0010056,
	P0010057,
	P0010058,
	P0010059,
	P0010060,
	P0010061,
	P0010062,
	P0010063,
	P0010064,
	P0010065,
	P0010066,
	P0010067,
	P0010068,
	P0010069,
	P0010070,
	P0010071,
	P0020001,
	P0020002,
	P0020003,
	P0020004,
	P0020005,
	P0020006,
	P0020007,
	P0020008,
	P0020009,
	P0020010,
	P0020011,
	P0020012,
	P0020013,
	P0020014,
	P0020015,
	P0020016,
	P0020017,
	P0020018,
	P0020019,
	P0020020,
	P0020021,
	P0020022,
	P0020023,
	P0020024,
	P0020025,
	P0020026,
	P0020027,
	P0020028,
	P0020029,
	P0020030,
	P0020031,
	P0020032,
	P0020033,
	P0020034,
	P0020035,
	P0020036,
	P0020037,
	P0020038,
	P0020039,
	P0020040,
	P0020041,
	P0020042,
	P0020043,
	P0020044,
	P0020045,
	P0020046,
	P0020047,
	P0020048,
	P0020049,
	P0020050,
	P0020051,
	P0020052,
	P0020053,
	P0020054,
	P0020055,
	P0020056,
	P0020057,
	P0020058,
	P0020059,
	P0020060,
	P0020061,
	P0020062,
	P0020063,
	P0020064,
	P0020065,
	P0020066,
	P0020067,
	P0020068,
	P0020069,
	P0020070,
	P0020071,
	P0020072,
	P0020073
);

#create our table containing the second census file data on race/ethnicity for the voting  population
CREATE TABLE nc000022010 (
	fileid VARCHAR(255),
	stusab VARCHAR(255),
	chariter VARCHAR(255),
	cifsn VARCHAR(255),
	logrecno VARCHAR(255),
	P0030001 VARCHAR(255),
	P0030002 VARCHAR(255),
	P0030003 VARCHAR(255),
	P0030004 VARCHAR(255),
	P0030005 VARCHAR(255),
	P0030006 VARCHAR(255),
	P0030007 VARCHAR(255),
	P0030008 VARCHAR(255),
	P0030009 VARCHAR(255),
	P0030010 VARCHAR(255),
	P0030011 VARCHAR(255),
	P0030012 VARCHAR(255),
	P0030013 VARCHAR(255),
	P0030014 VARCHAR(255),
	P0030015 VARCHAR(255),
	P0030016 VARCHAR(255),
	P0030017 VARCHAR(255),
	P0030018 VARCHAR(255),
	P0030019 VARCHAR(255),
	P0030020 VARCHAR(255),
	P0030021 VARCHAR(255),
	P0030022 VARCHAR(255),
	P0030023 VARCHAR(255),
	P0030024 VARCHAR(255),
	P0030025 VARCHAR(255),
	P0030026 VARCHAR(255),
	P0030027 VARCHAR(255),
	P0030028 VARCHAR(255),
	P0030029 VARCHAR(255),
	P0030030 VARCHAR(255),
	P0030031 VARCHAR(255),
	P0030032 VARCHAR(255),
	P0030033 VARCHAR(255),
	P0030034 VARCHAR(255),
	P0030035 VARCHAR(255),
	P0030036 VARCHAR(255),
	P0030037 VARCHAR(255),
	P0030038 VARCHAR(255),
	P0030039 VARCHAR(255),
	P0030040 VARCHAR(255),
	P0030041 VARCHAR(255),
	P0030042 VARCHAR(255),
	P0030043 VARCHAR(255),
	P0030044 VARCHAR(255),
	P0030045 VARCHAR(255),
	P0030046 VARCHAR(255),
	P0030047 VARCHAR(255),
	P0030048 VARCHAR(255),
	P0030049 VARCHAR(255),
	P0030050 VARCHAR(255),
	P0030051 VARCHAR(255),
	P0030052 VARCHAR(255),
	P0030053 VARCHAR(255),
	P0030054 VARCHAR(255),
	P0030055 VARCHAR(255),
	P0030056 VARCHAR(255),
	P0030057 VARCHAR(255),
	P0030058 VARCHAR(255),
	P0030059 VARCHAR(255),
	P0030060 VARCHAR(255),
	P0030061 VARCHAR(255),
	P0030062 VARCHAR(255),
	P0030063 VARCHAR(255),
	P0030064 VARCHAR(255),
	P0030065 VARCHAR(255),
	P0030066 VARCHAR(255),
	P0030067 VARCHAR(255),
	P0030068 VARCHAR(255),
	P0030069 VARCHAR(255),
	P0030070 VARCHAR(255),
	P0030071 VARCHAR(255),
	P0040001 VARCHAR(255),
	P0040002 VARCHAR(255),
	P0040003 VARCHAR(255),
	P0040004 VARCHAR(255),
	P0040005 VARCHAR(255),
	P0040006 VARCHAR(255),
	P0040007 VARCHAR(255),
	P0040008 VARCHAR(255),
	P0040009 VARCHAR(255),
	P0040010 VARCHAR(255),
	P0040011 VARCHAR(255),
	P0040012 VARCHAR(255),
	P0040013 VARCHAR(255),
	P0040014 VARCHAR(255),
	P0040015 VARCHAR(255),
	P0040016 VARCHAR(255),
	P0040017 VARCHAR(255),
	P0040018 VARCHAR(255),
	P0040019 VARCHAR(255),
	P0040020 VARCHAR(255),
	P0040021 VARCHAR(255),
	P0040022 VARCHAR(255),
	P0040023 VARCHAR(255),
	P0040024 VARCHAR(255),
	P0040025 VARCHAR(255),
	P0040026 VARCHAR(255),
	P0040027 VARCHAR(255),
	P0040028 VARCHAR(255),
	P0040029 VARCHAR(255),
	P0040030 VARCHAR(255),
	P0040031 VARCHAR(255),
	P0040032 VARCHAR(255),
	P0040033 VARCHAR(255),
	P0040034 VARCHAR(255),
	P0040035 VARCHAR(255),
	P0040036 VARCHAR(255),
	P0040037 VARCHAR(255),
	P0040038 VARCHAR(255),
	P0040039 VARCHAR(255),
	P0040040 VARCHAR(255),
	P0040041 VARCHAR(255),
	P0040042 VARCHAR(255),
	P0040043 VARCHAR(255),
	P0040044 VARCHAR(255),
	P0040045 VARCHAR(255),
	P0040046 VARCHAR(255),
	P0040047 VARCHAR(255),
	P0040048 VARCHAR(255),
	P0040049 VARCHAR(255),
	P0040050 VARCHAR(255),
	P0040051 VARCHAR(255),
	P0040052 VARCHAR(255),
	P0040053 VARCHAR(255),
	P0040054 VARCHAR(255),
	P0040055 VARCHAR(255),
	P0040056 VARCHAR(255),
	P0040057 VARCHAR(255),
	P0040058 VARCHAR(255),
	P0040059 VARCHAR(255),
	P0040060 VARCHAR(255),
	P0040061 VARCHAR(255),
	P0040062 VARCHAR(255),
	P0040063 VARCHAR(255),
	P0040064 VARCHAR(255),
	P0040065 VARCHAR(255),
	P0040066 VARCHAR(255),
	P0040067 VARCHAR(255),
	P0040068 VARCHAR(255),
	P0040069 VARCHAR(255),
	P0040070 VARCHAR(255),
	P0040071 VARCHAR(255),
	P0040072 VARCHAR(255),
	P0040073 VARCHAR(255),
	H0010001 VARCHAR(255),
	H0010002 VARCHAR(255),
	H0010003 VARCHAR(255)
);

#load in our census data from the second file on race/ethnicity/housing for the voting-age population
LOAD DATA LOCAL
INFILE '/Users/mtdukes/Dropbox/projects/wral/redistricting/legislative-redistricting-092019/census_data/nc000022010.pl' 
INTO TABLE nc000022010 
    FIELDS TERMINATED BY ',' 
           OPTIONALLY ENCLOSED BY '"'
    LINES  TERMINATED BY '\n'
(
	fileid,
	stusab,
	chariter,
	cifsn,
	logrecno,
	P0030001,
	P0030002,
	P0030003,
	P0030004,
	P0030005,
	P0030006,
	P0030007,
	P0030008,
	P0030009,
	P0030010,
	P0030011,
	P0030012,
	P0030013,
	P0030014,
	P0030015,
	P0030016,
	P0030017,
	P0030018,
	P0030019,
	P0030020,
	P0030021,
	P0030022,
	P0030023,
	P0030024,
	P0030025,
	P0030026,
	P0030027,
	P0030028,
	P0030029,
	P0030030,
	P0030031,
	P0030032,
	P0030033,
	P0030034,
	P0030035,
	P0030036,
	P0030037,
	P0030038,
	P0030039,
	P0030040,
	P0030041,
	P0030042,
	P0030043,
	P0030044,
	P0030045,
	P0030046,
	P0030047,
	P0030048,
	P0030049,
	P0030050,
	P0030051,
	P0030052,
	P0030053,
	P0030054,
	P0030055,
	P0030056,
	P0030057,
	P0030058,
	P0030059,
	P0030060,
	P0030061,
	P0030062,
	P0030063,
	P0030064,
	P0030065,
	P0030066,
	P0030067,
	P0030068,
	P0030069,
	P0030070,
	P0030071,
	P0040001,
	P0040002,
	P0040003,
	P0040004,
	P0040005,
	P0040006,
	P0040007,
	P0040008,
	P0040009,
	P0040010,
	P0040011,
	P0040012,
	P0040013,
	P0040014,
	P0040015,
	P0040016,
	P0040017,
	P0040018,
	P0040019,
	P0040020,
	P0040021,
	P0040022,
	P0040023,
	P0040024,
	P0040025,
	P0040026,
	P0040027,
	P0040028,
	P0040029,
	P0040030,
	P0040031,
	P0040032,
	P0040033,
	P0040034,
	P0040035,
	P0040036,
	P0040037,
	P0040038,
	P0040039,
	P0040040,
	P0040041,
	P0040042,
	P0040043,
	P0040044,
	P0040045,
	P0040046,
	P0040047,
	P0040048,
	P0040049,
	P0040050,
	P0040051,
	P0040052,
	P0040053,
	P0040054,
	P0040055,
	P0040056,
	P0040057,
	P0040058,
	P0040059,
	P0040060,
	P0040061,
	P0040062,
	P0040063,
	P0040064,
	P0040065,
	P0040066,
	P0040067,
	P0040068,
	P0040069,
	P0040070,
	P0040071,
	P0040072,
	P0040073,
	H0010001,
	H0010002,
	H0010003
);

/*
STEP TWO: Create indexes
Speeds up the process of querying data
*/

#create a few indexes to speed up our queries
create index geo_idx on
geo_header (logrecno);

create index file01_idx ON
nc000012010 (logrecno);

create index file02_idx ON
nc000022010 (logrecno);

create index 2019_house_baf_idx ON
2019_house_baf (block);

create index 2019_senate_baf_idx ON
2019_senate_baf (block);

create index 2018_house_baf_idx ON
2018_house_baf (block);

create index 2018_senate_baf_idx ON
2018_senate_baf (block);

/*
STEP THREE: General demographic analysis
Using our imported Census data, run a few different analyses on our new districts
*/
#to make sure our numbers match the reports run by the General Assembly, calculate population deviations
#for the new house districts
SELECT 2019_house_baf.district AS house_district, 
	SUM(nc000012010.P0010001) AS 2010_pop, 
	ROUND(9535483/120) AS ideal_pop, 
	(SUM(nc000012010.P0010001) - ROUND(9535483/120)) AS deviation,
	ROUND((((SUM(nc000012010.P0010001) - ROUND(9535483/120)) / ROUND(9535483/120)) * 100),2) AS deviation_pct
FROM geo_header
LEFT JOIN nc000012010
ON geo_header.logrecno = nc000012010.logrecno
LEFT JOIN 2019_house_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_house_baf.block
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2019_house_baf.district
ORDER BY CAST(house_district AS SIGNED);

SELECT 2019_senate_baf.district AS senate_district, 
	SUM(nc000012010.P0010001) as 2010_pop, 
	ROUND(9535483/50) as ideal_pop, 
	(SUM(nc000012010.P0010001) - ROUND(9535483/50)) as deviation,
	ROUND((((SUM(nc000012010.P0010001) - ROUND(9535483/50)) / ROUND(9535483/50)) * 100),2) as deviation_pct
FROM geo_header
LEFT JOIN nc000012010
ON geo_header.logrecno = nc000012010.logrecno
LEFT JOIN 2019_senate_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_senate_baf.block
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2019_senate_baf.district
ORDER BY CAST(senate_district AS SIGNED);

#get the bvap percentage of each house district
#just black/african american alone for now...
SELECT 2019_house_baf.district AS house_district,
	SUM(nc000022010.P0030001) AS 2010_vap,
	SUM(nc000022010.P0030004) AS 2010_bvap,
	ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) AS bvap_pct
FROM geo_header
LEFT JOIN nc000022010
ON geo_header.logrecno = nc000022010.logrecno
LEFT JOIN 2019_house_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_house_baf.block
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2019_house_baf.district
ORDER BY CAST(house_district AS SIGNED);

#get the bvap percentage of each senate district
#just black/african american alone for now...
SELECT 2019_senate_baf.district AS senate_district,
	SUM(nc000022010.P0030001) AS 2010_vap,
	SUM(nc000022010.P0030004) AS 2010_bvap,
	ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) AS bvap_pct
FROM geo_header
LEFT JOIN nc000022010
ON geo_header.logrecno = nc000022010.logrecno
LEFT JOIN 2019_senate_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_senate_baf.block
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2019_senate_baf.district
ORDER BY CAST(senate_district AS SIGNED);

#get the bvap percentage only for the 2018/2019 house maps for comparison
SELECT 2018_house_baf.district as house_district,
	ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) as 2018_bvap_pct,
	x.2019_bvap_pct
FROM geo_header
LEFT JOIN nc000022010
ON geo_header.logrecno = nc000022010.logrecno
LEFT JOIN 2018_house_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2018_house_baf.block
JOIN (
	SELECT 2019_house_baf.district,
		ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) as 2019_bvap_pct
	FROM geo_header
	LEFT JOIN nc000022010
	ON geo_header.logrecno = nc000022010.logrecno
	LEFT JOIN 2019_house_baf
	ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_house_baf.block
	WHERE geo_header.state <> ''
	AND geo_header.county <> ''
	AND geo_header.tract <> ''
	AND geo_header.block <> ''
	GROUP BY 2019_house_baf.district
	) as x
ON 2018_house_baf.district = x.district
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2018_house_baf.district
ORDER BY CAST(house_district AS SIGNED);

#get the bvap percentage only for the 2018/2019 SENATE maps
SELECT 2018_senate_baf.district as senate_district,
	ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) as 2018_bvap_pct,
	x.2019_bvap_pct
FROM geo_header
LEFT JOIN nc000022010
ON geo_header.logrecno = nc000022010.logrecno
LEFT JOIN 2018_senate_baf
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2018_senate_baf.block
JOIN (
	SELECT 2019_senate_baf.district,
		ROUND((SUM(nc000022010.P0030004) / SUM(nc000022010.P0030001)) * 100, 2) as 2019_bvap_pct
	FROM geo_header
	LEFT JOIN nc000022010
	ON geo_header.logrecno = nc000022010.logrecno
	LEFT JOIN 2019_senate_baf
	ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = 2019_senate_baf.block
	WHERE geo_header.state <> ''
	AND geo_header.county <> ''
	AND geo_header.tract <> ''
	AND geo_header.block <> ''
	GROUP BY 2019_senate_baf.district
	) as x
ON 2018_senate_baf.district = x.district
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
GROUP BY 2018_senate_baf.district
ORDER BY CAST(senate_district AS SIGNED);

#run the numbers on exactly how many people were impacted by these redrawn districts
SELECT SUM(nc000012010.P0010001) as 2010_pop
FROM geo_header
LEFT JOIN nc000012010
ON geo_header.logrecno = nc000012010.logrecno
LEFT JOIN (
	SELECT DISTINCT y.block
	FROM (
		SELECT 2019_house_baf.block, 2019_house_baf.district
		FROM 2019_house_baf
		INNER JOIN 2019_redrawn_districts
		ON 2019_house_baf.district = 2019_redrawn_districts.district
		WHERE 2019_redrawn_districts.chamber = 'HOUSE'
		UNION
		SELECT 2019_senate_baf.block, 2019_senate_baf.district
		FROM 2019_senate_baf
		INNER JOIN 2019_redrawn_districts
		ON 2019_senate_baf.district = 2019_redrawn_districts.district
		WHERE 2019_redrawn_districts.chamber = 'SENATE'
		) as y
	) as x
ON CONCAT(geo_header.state,geo_header.county,geo_header.tract,geo_header.block) = x.block
WHERE geo_header.state <> ''
AND geo_header.county <> ''
AND geo_header.tract <> ''
AND geo_header.block <> ''
AND x.block IS NOT NULL;

/*
STEP FOUR: Precinct analysis
Data cleaning and analysis to match 2016 results to our new districts
*/
#after importing data for 2016_results_correx
#change our column names to match our old resuls table
#county -> county_desc
#contest_title -> contest_name

#add fips code to our results file
ALTER TABLE 2016_results_correx
ADD COLUMN
county_fips VARCHAR(5)
AFTER county_desc;

#set the field to match the fips code
UPDATE 2016_results_correx, fips
SET 2016_results_correx.county_fips = fips.fips
WHERE 2016_results_correx.county_desc = fips.county;

#lets get rid of everything but the races we're interested in
#'1001_US PRESIDENT'
#'1001_PRESIDENT AND VICE PRESIDENT OF THE UNITED STATES'
#'1002_US SENATE'
#'1002_UNITED STATES SENATE'
#'1016_NC GOVERNOR'
#'1395_NC LIEUTENANT GOVERNOR'
#'1022_NC ATTORNEY GENERAL'
DELETE FROM 2016_results_correx
WHERE LEFT(contest_name,4) <> '1001' AND
LEFT(contest_name,4) <> '1002' AND
LEFT(contest_name,4) <> '1016' AND
LEFT(contest_name,4) <> '1395' AND
LEFT(contest_name,4) <> '1022';

#add a derived precinct_name to separate out precinct details
ALTER TABLE 2016_results_correx
ADD COLUMN
precinct_code VARCHAR(255)
AFTER precinct_name;

UPDATE 2016_results_correx
SET 2016_results_correx.precinct_code = LEFT(precinct_name,LOCATE('_',precinct_name) - 1);

#to simplify/speed up our queries, lets go ahead and construct a block id
#from the state/county fips code, tract and block
#crate the column in the block_to_precinct table
ALTER TABLE block_to_precinct
ADD COLUMN
block_id VARCHAR(15)
AFTER block;

#set the field to the corresponding code
UPDATE block_to_precinct
SET block_id = CONCAT(state_fips,county_fips,tract,block);

#make an index for the block_to_precinct file
CREATE INDEX block_to_precinct_idx ON
block_to_precinct (block_id);

#make an index for our 2016_results file
CREATE INDEX 2016_results_correx_idx ON
2016_results_correx (county_fips, precinct_code, contest_name, candidate_name);

#add precinct_id
#create a new column in our results file for quicker matching
#this will use the precinct_id constructed of the code and the county
ALTER TABLE 2016_results_correx
ADD COLUMN
precinct_id VARCHAR(255)
AFTER precinct_code;

UPDATE 2016_results_correx
SET 2016_results_correx.precinct_id = CONCAT(2016_results_correx.county_fips, 2016_results_correx.precinct_code);

#replace the spaces in the 2016 results file with underscores to better match our block_to_precinct file
#let's do this in precinct_id so we don't mess with our original data
UPDATE 2016_results_correx
SET precinct_id = replace(precinct_id, ' ', '_');

UPDATE 2016_results_correx
SET precinct_id = replace(precinct_id, '#', '');

#correct our btp_precincts by adding in rows that correspond with the split wake precincts
#to keep things straight, let's add a derived column to block_to_precinct
ALTER TABLE block_to_precinct
ADD COLUMN
derived VARCHAR(1);

UPDATE block_to_precinct
SET block_to_precinct.derived = '0';

#duplicate the new precincts and map them back to the old
INSERT INTO block_to_precinct (state_fips, county_fips, tract, block, block_id, precinct, derived)
SELECT state_fips, county_fips, tract, block, block_id, '16-08' AS precinct, 1 AS derived
FROM block_to_precinct
WHERE county_fips = '183' AND (precinct = '16-10' OR precinct = '16-11' );

INSERT INTO block_to_precinct (state_fips, county_fips, tract, block, block_id, precinct, derived)
SELECT state_fips, county_fips, tract, block, block_id, '17-08' AS precinct, 1 AS derived
FROM block_to_precinct
WHERE county_fips = '183' AND (precinct = '17-12' OR precinct = '17-13' );

INSERT INTO block_to_precinct (state_fips, county_fips, tract, block, block_id, precinct, derived)
SELECT state_fips, county_fips, tract, block, block_id, '19-10' AS precinct, 1 AS derived
FROM block_to_precinct
WHERE county_fips = '183' AND (precinct = '19-18' OR precinct = '19-19' );

INSERT INTO block_to_precinct (state_fips, county_fips, tract, block, block_id, precinct, derived)
SELECT state_fips, county_fips, tract, block, block_id, '19-04' AS precinct, 1 AS derived
FROM block_to_precinct
WHERE county_fips = '183' AND (precinct = '19-20' OR precinct = '19-21' );

#check to see how many unmatched rows we have
SELECT x.*, fips.county
FROM (
	SELECT LEFT(2016_results_correx.precinct_id, 5) AS results_precinct,
		2016_results_correx.precinct_name,
		SUM(2016_results_correx.votes) as total_votes
	FROM 2016_results_correx
	LEFT JOIN (
		SELECT CONCAT(state_fips, county_fips, precinct) AS precinct_id
		FROM block_to_precinct
		GROUP BY CONCAT(state_fips, county_fips, precinct)
		) as x
	ON 2016_results_correx.precinct_id = x.precinct_id
	WHERE x.precinct_id IS NULL
	AND (2016_results_correx.candidate_name = 'Roy Cooper' OR 2016_results_correx.candidate_name = 'Pat McCrory')
	#GROUP BY LEFT(2016_results_correx.precinct_id, 5) WITH ROLLUP
	GROUP BY LEFT(2016_results_correx.precinct_id, 5), 2016_results_correx.precinct_name WITH ROLLUP
	HAVING total_votes != 0
) as x
LEFT JOIN fips
ON x.results_precinct = fips.fips
ORDER BY county, total_votes DESC;

#Show the results in Mecklenburg
SELECT DISTINCT precinct_name, county_desc, precinct_id
FROM 2016_results_correx
WHERE county_desc = 'Mecklenburg'
GROUP BY precinct_name, county_desc, precinct_id;

#mecklenburg has a lot of unmatched precincts
#update our mecklenburg rows so we can parse out our problem
UPDATE 2016_results_correx
SET 2016_results_correx.precinct_id = CONCAT(precinct_id,RIGHT(precinct_name,5))
WHERE precinct_code = '' AND county_desc = 'Mecklenburg';

UPDATE 2016_results_correx
SET precinct_id = replace(precinct_id, ' ', '0')
WHERE precinct_code = '' AND county_desc = 'Mecklenburg'; 

#add a derived column to the 2016_results_correx table
ALTER TABLE 2016_results_correx
ADD COLUMN
derived VARCHAR(1);

UPDATE 2016_results_correx
SET 2016_results_correx.derived = '0';

#generate a results table that we can use
INSERT INTO 2016_results_correx
SELECT county_id,
	county_desc,
	county_fips,
	election_dt,
	result_type_lbl,
	result_type_desc,
	contest_id,
	contest_name,
	contest_party_lbl,
	contest_vote_for,
	precinct_cd,
	precinct_name,
	precinct_code,
	CONCAT(LEFT(precinct_id,5), meck_weights.precinct) AS precinct_id,
	candidate_id,
	candidate_name,
	candidate_party_lbl,
	group_num,
	group_name,
	voting_method_lbl,
	voting_method_rslt_desc,
	ROUND(votes * meck_weights.weight) AS votes,
	1 AS derived
FROM 2016_results_correx
LEFT JOIN meck_weights
ON meck_weights.unsorted_precinct = RIGHT(2016_results_correx.precinct_id,5)
WHERE county_desc = 'Mecklenburg' AND precinct_cd > 200 AND (candidate_party_lbl = 'DEM' OR candidate_party_lbl = 'REP')
HAVING votes > 0;

#our resulting query tallying up the votes from the 2016 election results and tying them
#back to each individual Census block and susequent new House district
#version below CORRECTS dem_win rounding error
#run the top two select statements first to set your candidates appropriately
SELECT @dem_candidate := 'Roy Cooper';
SELECT @gop_candidate := 'Pat McCrory';

SELECT @dem_candidate := 'Hillary Clinton';
SELECT @gop_candidate := 'Donald J. Trump';

SELECT @dem_candidate := 'Deborah K. Ross';
SELECT @gop_candidate := 'Richard Burr';

SELECT @dem_candidate := 'Josh Stein';
SELECT @gop_candidate := 'Buck Newton';

SELECT @dem_candidate := 'Linda Coleman';
SELECT @gop_candidate := 'Dan Forest';

SELECT dem_candidate.house_district,
	dem_candidate.dem_votes,
	gop_candidate.gop_votes,
	ROUND((dem_candidate.dem_votes / (dem_candidate.dem_votes + gop_candidate.gop_votes)) * 100,1) AS dem_pct,
	IF( dem_candidate.dem_votes > gop_candidate.gop_votes, 1, 0) AS dem_win
FROM (
	#query to combine our votes with our districts and roll up
	SELECT x.district as house_district,
		SUM(corrected_votes.adjusted_votes) AS dem_votes
	FROM (
		#query to match our precinct_id to our district through our block
		SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5), block_to_precinct.precinct) as precinct_id,
			2019_house_baf.district
		FROM 2019_house_baf
		LEFT JOIN block_to_precinct
		ON 2019_house_baf.block = block_to_precinct.block_id
		) as x
	LEFT JOIN (
		#query to combine our corrected vote totals for dem_candidate
		SELECT q1.precinct_id, 
			q1.district, 
			q1.dem_votes,
			q2.weight,
			ROUND(q1.dem_votes * ( IF(q2.weight IS NULL, 100, q2.weight) / 100) ) as adjusted_votes
		FROM (
			#initial query to join the number of candidates votes with precinct and district
			SELECT a.precinct_id,
				b.district, 
				a.dem_votes
			FROM (
				#query to link the precinct ID to the total vote count of the given candidate from results file
				SELECT x.precinct_id, 
					SUM(2016_results_correx.votes) AS dem_votes, 
					COUNT(x.precinct_id) AS precinct_count
				FROM (
					#query to link precinct_id with each district
					SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5),
						block_to_precinct.precinct) as precinct_id
					FROM 2019_house_baf
					LEFT JOIN block_to_precinct
					ON 2019_house_baf.block = block_to_precinct.block_id
					#end query
				) as x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @dem_candidate
				#AND 2016_results_correx.derived = 0
				GROUP BY x.precinct_id
				#end query
			) as a
			LEFT JOIN (
				#query to link precinct_id with district
				SELECT x.precinct_id,
					x.district
				FROM (
					#query to link precinct_id with each district (dupe of above)
					SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5),
						block_to_precinct.precinct) as precinct_id,
						2019_house_baf.district
					FROM 2019_house_baf
					LEFT JOIN block_to_precinct
					ON 2019_house_baf.block = block_to_precinct.block_id
					#end query
				) AS x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @dem_candidate
				#AND 2016_results_correx.derived = 0
				GROUP BY x.precinct_id, x.district
				#end query
			) AS b
			ON a.precinct_id = b.precinct_id
			#end query
		) AS q1 #end of our first query
		LEFT JOIN (
			#this is our query for getting the population for each census block
			#and calculating an appropriate weight
			SELECT c.precinct_id,
				c.district,
				c.2010_subgroup_pop,
				d.2010_total_pop,
				ROUND((c.2010_subgroup_pop / d.2010_total_pop) * 100,1) AS weight
			FROM (
				#query to join the census block files and total the population for each precinct
				SELECT district,
					CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_subgroup_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_house_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_house_baf.block
				LEFT JOIN block_to_precinct
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY district, precinct_id
				#end query
			) as c
			LEFT JOIN (
				#query to get the total population of each precinct, based on the block
				SELECT CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_total_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_house_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_house_baf.block
				LEFT JOIN block_to_precinct
					ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY precinct_id
				#end query
			) as d
			ON c.precinct_id = d.precinct_id
			#end query
		) AS q2
		ON q1.precinct_id = q2.precinct_id AND q1.district = q2.district
		#end query
	) AS corrected_votes
	ON corrected_votes.precinct_id = x.precinct_id AND corrected_votes.district = x.district
	GROUP BY x.district
	#end query
	) AS dem_candidate
#end dem_candidate query
LEFT JOIN (
	#query to combine our votes with our districts and roll up
	SELECT x.district as house_district,
		SUM(corrected_votes.adjusted_votes) AS gop_votes
	FROM (
		#query to match our precinct_id to our district through our block
		SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5), block_to_precinct.precinct) as precinct_id,
			2019_house_baf.district
		FROM 2019_house_baf
		LEFT JOIN block_to_precinct
		ON 2019_house_baf.block = block_to_precinct.block_id
		) as x
	LEFT JOIN (
		#query to combine our corrected vote totals for dem_candidate
		SELECT q1.precinct_id, 
			q1.district, 
			q1.gop_votes,
			q2.weight,
			ROUND(q1.gop_votes * ( IF(q2.weight IS NULL, 100, q2.weight) / 100) ) as adjusted_votes
		FROM (
			#initial query to join the number of candidates votes with precinct and district
			SELECT a.precinct_id,
				b.district, 
				a.gop_votes
			FROM (
				#query to link the precinct ID to the total vote count of the given candidate from results file
				SELECT x.precinct_id, 
					SUM(2016_results_correx.votes) AS gop_votes, 
					COUNT(x.precinct_id) AS precinct_count
				FROM (
					#query to link precinct_id with each district
					SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5),
						block_to_precinct.precinct) as precinct_id
					FROM 2019_house_baf
					LEFT JOIN block_to_precinct
					ON 2019_house_baf.block = block_to_precinct.block_id
					#end query
				) as x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @gop_candidate
				#AND 2016_results_correx.derived = 0
				GROUP BY x.precinct_id
				#end query
			) as a
			LEFT JOIN (
				#query to link precinct_id with district
				SELECT x.precinct_id,
					x.district
				FROM (
					#query to link precinct_id with each district (dupe of above)
					SELECT DISTINCT CONCAT(LEFT(2019_house_baf.block,5),
						block_to_precinct.precinct) as precinct_id,
						2019_house_baf.district
					FROM 2019_house_baf
					LEFT JOIN block_to_precinct
					ON 2019_house_baf.block = block_to_precinct.block_id
					#end query
				) AS x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @gop_candidate
				#AND 2016_results_correx.derived = 0
				GROUP BY x.precinct_id, x.district
				#end query
			) AS b
			ON a.precinct_id = b.precinct_id
			#end query
		) AS q1 #end of our first query
		LEFT JOIN (
			#this is our query for getting the population for each census block
			#and calculating an appropriate weight
			SELECT c.precinct_id,
				c.district,
				c.2010_subgroup_pop,
				d.2010_total_pop,
				ROUND((c.2010_subgroup_pop / d.2010_total_pop) * 100,1) AS weight
			FROM (
				#query to join the census block files and total the population for each precinct
				SELECT district,
					CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_subgroup_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_house_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_house_baf.block
				LEFT JOIN block_to_precinct
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY district, precinct_id
				#end query
			) as c
			LEFT JOIN (
				#query to get the total population of each precinct, based on the block
				SELECT CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_total_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_house_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_house_baf.block
				LEFT JOIN block_to_precinct
					ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY precinct_id
				#end query
			) as d
			ON c.precinct_id = d.precinct_id
			#end query
		) AS q2
		ON q1.precinct_id = q2.precinct_id AND q1.district = q2.district
		#end query
	) AS corrected_votes
	ON corrected_votes.precinct_id = x.precinct_id AND corrected_votes.district = x.district
	GROUP BY x.district
	#end query
	) as gop_candidate
#end gop_candidate query
ON dem_candidate.house_district = gop_candidate.house_district
ORDER BY CAST(gop_candidate.house_district AS SIGNED);

#our senate analysis doing the same, relying on the same variables as above
#version below CORRECTS dem_win rounding error
SELECT dem_candidate.senate_district,
	dem_candidate.dem_votes,
	gop_candidate.gop_votes,
	ROUND((dem_candidate.dem_votes / (dem_candidate.dem_votes + gop_candidate.gop_votes)) * 100,1) AS dem_pct,
	IF( dem_candidate.dem_votes > gop_candidate.gop_votes, 1, 0) AS dem_win
FROM (
	#query to combine our votes with our districts and roll up
	SELECT x.district as senate_district,
		SUM(corrected_votes.adjusted_votes) AS dem_votes
	FROM (
		#query to match our precinct_id to our district through our block
		SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5), block_to_precinct.precinct) as precinct_id,
			2019_senate_baf.district
		FROM 2019_senate_baf
		LEFT JOIN block_to_precinct
		ON 2019_senate_baf.block = block_to_precinct.block_id
		) as x
	LEFT JOIN (
		#query to combine our corrected vote totals for dem_candidate
		SELECT q1.precinct_id, 
			q1.district, 
			q1.dem_votes,
			q2.weight,
			ROUND(q1.dem_votes * ( IF(q2.weight IS NULL, 100, q2.weight) / 100) ) as adjusted_votes
		FROM (
			#initial query to join the number of candidates votes with precinct and district
			SELECT a.precinct_id,
				b.district, 
				a.dem_votes
			FROM (
				#query to link the precinct ID to the total vote count of the given candidate from results file
				SELECT x.precinct_id, 
					SUM(2016_results_correx.votes) AS dem_votes, 
					COUNT(x.precinct_id) AS precinct_count
				FROM (
					#query to link precinct_id with each district
					SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5),
						block_to_precinct.precinct) as precinct_id
					FROM 2019_senate_baf
					LEFT JOIN block_to_precinct
					ON 2019_senate_baf.block = block_to_precinct.block_id
					#end query
				) as x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @dem_candidate
				GROUP BY x.precinct_id
				#end query
			) as a
			LEFT JOIN (
				#query to link precinct_id with district
				SELECT x.precinct_id,
					x.district
				FROM (
					#query to link precinct_id with each district (dupe of above)
					SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5),
						block_to_precinct.precinct) as precinct_id,
						2019_senate_baf.district
					FROM 2019_senate_baf
					LEFT JOIN block_to_precinct
					ON 2019_senate_baf.block = block_to_precinct.block_id
					#end query
				) AS x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @dem_candidate
				GROUP BY x.precinct_id, x.district
				#end query
			) AS b
			ON a.precinct_id = b.precinct_id
			#end query
		) AS q1 #end of our first query
		LEFT JOIN (
			#this is our query for getting the population for each census block
			#and calculating an appropriate weight
			SELECT c.precinct_id,
				c.district,
				c.2010_subgroup_pop,
				d.2010_total_pop,
				ROUND((c.2010_subgroup_pop / d.2010_total_pop) * 100,1) AS weight
			FROM (
				#query to join the census block files and total the population for each precinct
				SELECT district,
					CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_subgroup_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_senate_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_senate_baf.block
				LEFT JOIN block_to_precinct
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY district, precinct_id
				#end query
			) as c
			LEFT JOIN (
				#query to get the total population of each precinct, based on the block
				SELECT CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_total_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_senate_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_senate_baf.block
				LEFT JOIN block_to_precinct
					ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY precinct_id
				#end query
			) as d
			ON c.precinct_id = d.precinct_id
			#end query
		) AS q2
		ON q1.precinct_id = q2.precinct_id AND q1.district = q2.district
		#end query
	) AS corrected_votes
	ON corrected_votes.precinct_id = x.precinct_id AND corrected_votes.district = x.district
	GROUP BY x.district
	#end query
	) AS dem_candidate
#end dem_candidate query
LEFT JOIN (
	#query to combine our votes with our districts and roll up
	SELECT x.district as senate_district,
		SUM(corrected_votes.adjusted_votes) AS gop_votes
	FROM (
		#query to match our precinct_id to our district through our block
		SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5), block_to_precinct.precinct) as precinct_id,
			2019_senate_baf.district
		FROM 2019_senate_baf
		LEFT JOIN block_to_precinct
		ON 2019_senate_baf.block = block_to_precinct.block_id
		) as x
	LEFT JOIN (
		#query to combine our corrected vote totals for dem_candidate
		SELECT q1.precinct_id, 
			q1.district, 
			q1.gop_votes,
			q2.weight,
			ROUND(q1.gop_votes * ( IF(q2.weight IS NULL, 100, q2.weight) / 100) ) as adjusted_votes
		FROM (
			#initial query to join the number of candidates votes with precinct and district
			SELECT a.precinct_id,
				b.district, 
				a.gop_votes
			FROM (
				#query to link the precinct ID to the total vote count of the given candidate from results file
				SELECT x.precinct_id, 
					SUM(2016_results_correx.votes) AS gop_votes, 
					COUNT(x.precinct_id) AS precinct_count
				FROM (
					#query to link precinct_id with each district
					SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5),
						block_to_precinct.precinct) as precinct_id
					FROM 2019_senate_baf
					LEFT JOIN block_to_precinct
					ON 2019_senate_baf.block = block_to_precinct.block_id
					#end query
				) as x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @gop_candidate
				GROUP BY x.precinct_id
				#end query
			) as a
			LEFT JOIN (
				#query to link precinct_id with district
				SELECT x.precinct_id,
					x.district
				FROM (
					#query to link precinct_id with each district (dupe of above)
					SELECT DISTINCT CONCAT(LEFT(2019_senate_baf.block,5),
						block_to_precinct.precinct) as precinct_id,
						2019_senate_baf.district
					FROM 2019_senate_baf
					LEFT JOIN block_to_precinct
					ON 2019_senate_baf.block = block_to_precinct.block_id
					#end query
				) AS x
				LEFT JOIN 2016_results_correx
				ON 2016_results_correx.precinct_id = x.precinct_id
				WHERE 2016_results_correx.candidate_name = @gop_candidate
				GROUP BY x.precinct_id, x.district
				#end query
			) AS b
			ON a.precinct_id = b.precinct_id
			#end query
		) AS q1 #end of our first query
		LEFT JOIN (
			#this is our query for getting the population for each census block
			#and calculating an appropriate weight
			SELECT c.precinct_id,
				c.district,
				c.2010_subgroup_pop,
				d.2010_total_pop,
				ROUND((c.2010_subgroup_pop / d.2010_total_pop) * 100,1) AS weight
			FROM (
				#query to join the census block files and total the population for each precinct
				SELECT district,
					CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_subgroup_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_senate_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_senate_baf.block
				LEFT JOIN block_to_precinct
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY district, precinct_id
				#end query
			) as c
			LEFT JOIN (
				#query to get the total population of each precinct, based on the block
				SELECT CONCAT(block_to_precinct.state_fips, block_to_precinct.county_fips, block_to_precinct.precinct) as precinct_id,
					SUM(nc000012010.P0010001) as 2010_total_pop
				FROM geo_header
				LEFT JOIN nc000012010
				ON geo_header.logrecno = nc000012010.logrecno
				LEFT JOIN 2019_senate_baf
				ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = 2019_senate_baf.block
				LEFT JOIN block_to_precinct
					ON CONCAT(geo_header.state, geo_header.county, geo_header.tract, geo_header.block) = block_to_precinct.block_id
				WHERE geo_header.state <> ''
				AND geo_header.county <> ''
				AND geo_header.tract <> ''
				AND geo_header.block <> ''
				GROUP BY precinct_id
				#end query
			) as d
			ON c.precinct_id = d.precinct_id
			#end query
		) AS q2
		ON q1.precinct_id = q2.precinct_id AND q1.district = q2.district
		#end query
	) AS corrected_votes
	ON corrected_votes.precinct_id = x.precinct_id AND corrected_votes.district = x.district
	GROUP BY x.district
	#end query
	) as gop_candidate
#end gop_candidate query
ON dem_candidate.senate_district = gop_candidate.senate_district
ORDER BY CAST(gop_candidate.senate_district AS SIGNED);
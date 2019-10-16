
# 2019 NC redistricting analysis

WRAL News used Census, 2016 election results and data published by a team of mathematicians at Duke University in the Common Cause v. Lewis case to analyze newly drawn districts approved by the N.C. General Assembly following a court order in September 2019.

## Findings

[See preliminary findings](https://github.com/mtdukes/2019-redistricting-analysis/blob/master/prelim-findings.md)

_PLEASE NOTE: These findings are preliminary and still subject to review and change._

## Data

 - **[2010 Census redistricting file for North Carolina](https://www2.census.gov/census_2010/01-Redistricting_File--PL_94-171/North_Carolina/nc2010.pl.zip)** Demographics gathered and calculated for the 2010 Census for the purposes of decennial redistricting in North Carolina.
 
 - **[Block assignment file for redrawn 2019 House maps](https://www.ncleg.gov/documentsites/committees/house2019-182/09-13-2019/HB%201020%20H%20Red%20Comm%20PCS%20corrected%20v2_baf.zip)** File mapping Census blocks to newly drawn House districts. Published by the N.C. House Committee on Redistricting.
 
- **[Block assignment file for redrawn 2019 Senate maps](https://www.ncleg.gov/documentsites/committees/senate2019-154/Senate%20Consensus%20Nonpartisan%20Map/Senate%20Consensus%20Nonpartisan%20Map%20v3_BlockFile.zip)** File mapping Census blocks to newly drawn Senate districts.  Published by the N.C. Senate Committee on Redistricting and Elections

- **N.C. State Board of Elections block-to-precinct file** File mapping Census blocks to precinct used in election results. Provided to WRAL News upon request on Sept. 17, 2019, by the State Board of Elections

- **[2016 election results "precinct sort" file](https://dl.ncsbe.gov/index.html?prefix=Requests/Dukes_Tyler/2016-11-08/)** Contains election results sorted into precincts by staff at the State Board of Elections. Provided to WRAL News upon request on Sept. 26, 2019

- **Ensemble election performance data for House/Senate maps** Data showing the distribution of elected Democrats for various races from 2008 to 2016, according to vote totals calculated for thousands of computer-generated district maps by a Duke University team of mathematicians and submitted as an expert report to the court in Common Cause v. Lewis. House ensemble scores are available in the [original expert report](https://sites.duke.edu/quantifyinggerrymandering/files/2019/09/Report.pdf) (Page 48). A corrected Senate version is available [in an addendum](https://sites.duke.edu/quantifyinggerrymandering/files/2019/09/Rebuttal.pdf) (Page 28).

- **Weights for Mecklenburg County** Data derived from a ballot style report produced by the State Board of Elections for ballot styles in Mecklenburg County. Used to predict and resort the unsorted votes from Mecklenburg County using the relative percentage of active voters in each precinct.

## Methodology

WRAL's analysis relied heavily on a previous methodology from Jonathan Mattingly, professor of mathematics at Duke University, submitted to both state and federal courts during multiple cases over partisan gerrymandering. His team used an algorithm to generate thousands of potential maps to form an ensemble, then calculated the vote totals of 17 different statewide races from 2008 to 2016 to find the number of Democrats elected for each election and each map.

The selection of "Democrats elected" vs. "Republicans elected"

The results gave a distribution of the "normal"  expected performance of potential North Carolina maps. And using that distribution, Mattingly's team compared the performance of the existing legislative maps for an expert report submitted to the court in Common Cause v. Lewis.

To generate comparable figures for the newly drawn legislative maps, WRAL used data from the Census, the N.C. General Assembly and the State Board of Elections to calculate the number of that would have been elected using voting patterns from the following 2016 statewide races:

- U.S. President
- U.S. Senate
- N.C. Governor
- N.C. Lt. Governor
- N.C. Attorney General

[Using database software](https://github.com/mtdukes/2019-redistricting-analysis/blob/master/redistricting_analysis.sql), we mapped each precinct to each Census block, then to each new district. That allowed us to calculate vote totals for the Republican and Democratic candidate for each newly drawn district and determine the winner.

For precincts that split across multiple districts, we used block-level 2010 Census population data to determine a weight measure. That weight measure was then applied to each split precinct to predict the breakdown in votes across multiple districts.

A small percentage of total votes for some counties in the 2016 election results file were not sorted into precincts, due to voting method or clerical issues. Among these counties, Mecklenburg had thousands of such votes in several unsorted categories - an order of magnitude more than any other counties. For these votes, WRAL used a report generated by the State Board of Elections listing precincts and active voters for each ballot style. We used the number of active voters in each unsorted category to create a weight measure, which we then used to predict the breakdown of unsorted votes across multiple precincts. We added those values to the vote totals (although they were too small to impact the outcome).

After generating vote totals for each race and chamber, we added up the total number of Democrats elected for each, producing 10 figures we could then use to compare to the performance of the previous enacted legislative maps and the rest of the ensemble generated by Mattingly's team.
# Replication Data for Clinton, Eubank, Fresh, and Shepherd's "Polling Place Changes and Political Participation: Evidence from North Carolina Presidential Elections, 2008-2016"

A few notes about working with this repository:

- Files called `.keep` are just placeholders for folders. They can be ignored.
- Use of this repository will require installation of [git lfs](https://git-lfs.github.com/) for managing large files. If you attempt to clone this repository and DON'T have git lfs installed, data files will just be small text files with a random appearing number. Moreover, `git lfs` will only integrate the actual data if you **clone** the repository (after installing git-lfs). This can be accomplished by openning a terminal, navigating to where you want the project folder to end up, and typing `git clone https://github.com/nickeubank/CEFS_PSRM_PPChangeAndParticipation.git`.
- To replicate:
    - Open `set_globals.do` and change the global `nc_electioneering` to the path to wherever you have saved this repository. Then choose whether to set the global `sample_size` to `10percent` or `full`. This code takes *forever* to run, so we recommend testing things against the 10percent sample before moving to running against the full sample. Paper results obviously are generated with the full sample.
    - Run `MASTER_RUN_ALL_FILES.do`.
    - All results (save some files prefixed `Map_` we made by hand for illustrative figures) will be re-created in `50_results_full`, and if you build the paper in `30_docs`, it will pull all those results into the paper and rebuild the PDF. 
- Note that this was most recently run in StataMP 16, and had helper functions detailed below installed.
- All files are meaning to be run in the ordinal sequence implied by their prefix number. However, these are far from ordinal (over time, we've added and removed files, so weird gaps exist. For more on this style of workflow management, [please see here](https://www.practicaldatascience.org/html/workflow.html).)
- Compiling `30_docs/polling_place_paper/CEFS_PSRM_PPChangeAndParticipation.tex` will automatically pull in all results generated while running.


## Stata Helper Apps: 


[1] package dm88_1 from http://www.stata-journal.com/software/sj5-4
      SJ5-4 dm88_1.  Update:  Renaming variables, multiply and...

[2] package zipsave from http://fmwww.bc.edu/RePEc/bocode/z
      'ZIPSAVE': module to save and use datasets compressed by zip

[3] package st0085_2 from http://www.stata-journal.com/software/sj14-2
      SJ14-2 st0085_2. Update: Making regression...

[4] package corrtex from http://fmwww.bc.edu/repec/bocode/c
      'CORRTEX': module to generate correlation tables formatted in LaTeX

[5] package blindschemes from http://fmwww.bc.edu/repec/bocode/b
      'BLINDSCHEMES': module to provide graph schemes sensitive to color vision deficiency

[6] package carryforward from http://fmwww.bc.edu/repec/bocode/c
      'CARRYFORWARD': module to carry forward previous observations

[7] package dm91 from http://www.stata.com/stb/stb61
      STB-61 dm91.  Patterns of missing values

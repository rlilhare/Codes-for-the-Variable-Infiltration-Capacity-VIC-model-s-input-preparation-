1. first I run the R code to resample the data as it is means simply putting the value from large grid to smaller grid.
for example, in present run 0.50 degree to 0.10 degree, without any interpolation , in R code methods=ngb means nothing to do with interpolation.
2. this give me regrid soil file for whole area Nelson
3. I use Matlab code to join the fid for LNRB
4. Note that we can't resample elevation in the soil file so we tood elevation data from SRTM dem for the current file prepration


Thanks
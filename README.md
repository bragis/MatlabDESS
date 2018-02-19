Matlab code for computing quantitative maps from DESS dicoms.

Instructions for use:
Go to the directory called “pt22”, and in that directory, there are a bunch of scripts. You would run one of these scripts to do your mapping, depending on how your acquisition was done:
 
exam_fitSliceRange.m: Assumes you did two separate scans (Hi and Lo, not “one-touch”) and computes T2 and ADC with two different methods.
exam_fitSliceRange_B1.m: Tries to do the same as the script above, but combines it with information from a B1 scan.
exam_fitSliceRangeOneScan.m: When you only have a “Lo” scan, you can use this to compute the T2 using the “simple analytical” approach. The function used at the bottom of this script can be either fitSliceOneScan.m or fitSliceOneScanLookup.m. They both compute a T2 map, but the former tries to do so analytically while the latter uses a lookup table.
exam_fitSliceRangeOneTouch2D.m: This should do the same as exam_fitSliceRange.m, but for scans acquired with the “one-touch” approach.
exam_fitSliceRangeOneTouch3D.m: This computes T1, T2, and ADC maps from a “one-touch” scan by creating a dictionary of signals over a range of T1, T2, and ADC values and picking the best fit with your measurements (a “3D lookup” approach).
exam_fitSliceRange2DparamsNotSame.m: Same as exam_fitSliceRange.m, but when your parameters (TR, TE, etc) are different between Hi and Lo.
 
In all of these, you have to type in information about the location of the dicoms, the series numbers, and the slices you want to fit. It should be pretty obvious how to do this from the comments in the code.

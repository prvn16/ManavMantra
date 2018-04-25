function [colnum,colname] = getColName(fptr,templt,casesen)
%getColName get table column name
%   [COLNUM,COLNAME] = getColNum(FPTR,TEMPLT,CASESEN) gets the table column 
%   numbers and names of the columns whose names matches an input template 
%   name.  If CASESEN is true, then the column name match will be 
%   case-sensitive.  CASESEN defaults to false.
%
%   The input column name template may be either the exact name of the 
%   column to be searched for, or it may contain wild card characters 
%   (*, ?, or #), or it may contain the integer number of the desired 
%   column (with the first column = 1). The `*' wild card character matches 
%   any sequence of characters (including zero characters) and the `?' 
%   character matches any single character. The # wildcard will match any 
%   consecutive string of decimal digits (0-9). 
%
%   Example:  Return all the columns starting with the letter 'C'.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       [nums,names] = fits.getColName(fptr,'C*');
%       fits.closeFile(fptr);
%
%   See also fits, getAColParms, getBColParms.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(templt,{'char'},{'nonempty'},'','TEMPLT');
if nargin > 2
	validateattributes(casesen,{'logical'},{'scalar'},'','CASESEN');
else
	casesen = false;
end
if casesen
	casesen = fitsiolib('get_constant_value','CASESEN');
else
	casesen = fitsiolib('get_constant_value','CASEINSEN');
end
[colnum,colname] = fitsiolib('get_col_name',fptr,casesen,templt);

function [coldata,nullval] = readCol(fptr,colnum,firstrow,numrows)
%readCol read rows of ASCII or binary table column
%   [COLDATA,NULLVAL] = readCol(FPTR,COLNUM) reads an entire column from an 
%   ASCII or binary table column.  NULLVAL is a logical array specifying if 
%   a particular element of COLDATA should be treated as undefined.  It is
%   the same size as COLDATA.
%
%   [COLDATA,NULLVAL] = readCol(FPTR,COLNUM,FIRSTROW,NUMROWS) reads a 
%   subsection of rows from an ASCII or binary table column.  
%
%   The MATLAB datatype returned by readCol corresponds to the datatype 
%   returned by getEqColType.
%
%   This function corresponds to the fits_read_col (ffgcv) function in 
%   the CFITSIO library C API.
%
%   Example:  Read an entire column.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       colnum = fits.getColName(fptr,'flux');
%       fluxdata = fits.readCol(fptr,colnum);
%       fits.closeFile(fptr);
%
%   Example:  Read the first five rows in a column.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       colnum = fits.getColName(fptr,'flux');
%       fluxdata = fits.readCol(fptr,colnum,1,5);
%       fits.closeFile(fptr);
%
%   See also fits, writeCol.

%   Copyright 2011-2017 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer'},'','COLNUM');

num_table_rows = matlab.io.fits.getNumRows(fptr);
switch(nargin)
	case 2
		firstrow = 1;
		numrows = num_table_rows;

	case 4
		validateattributes(firstrow,{'double'},{'scalar','positive','integer'},'','FIRSTROW');
		validateattributes(numrows,{'double'},{'scalar','positive','integer','<=',num_table_rows - firstrow + 1},'','NUMROWS');

	otherwise
		error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end

[~,repeat] = matlab.io.fits.getColType(fptr,colnum);

% Setting the number of rows that can be read at once in a column as 10000
% See g1613196 for more details
stepSize = 10000;
if numrows > stepSize
    % Get the datatype by reading first entry in the column
    [coldata, nullval] = fitsiolib('read_col',fptr,colnum,firstrow, 1);
    % Preallocate the arrays
    coldata = zeros(repeat, numrows, 'like', coldata);
    
    % If second output argument is not requested, we do not allocate
    % 'nullval' array. This ensures efficient memory management with large
    % FITS files.
    if nargout > 1
        nullval = zeros(repeat, numrows, 'like', nullval);
    end
    
    % Read all rows in a loop
    for k = 1:stepSize:numrows
        if (k+stepSize) > numrows
            index = numrows;
            rowsToBeRead = numrows - k + 1;
        else
            index = k + stepSize -1;
            rowsToBeRead = stepSize;
        end
        if nargout > 1
            [coldata(:,k:index), nullval(:,k:index)] =  fitsiolib('read_col',fptr,colnum,k,rowsToBeRead);
        else
            coldata(:,k:index) =  fitsiolib('read_col',fptr,colnum,k,rowsToBeRead);
        end
    end
else
    if nargout > 1
        [coldata,nullval] = fitsiolib('read_col',fptr,colnum,firstrow,numrows);
    else
        coldata = fitsiolib('read_col',fptr,colnum,firstrow,numrows);
    end
    
end

% Transpose column data if an ASCII column and from a binary table, not if
% from an ASCII table.
if ischar(coldata) && strcmp(matlab.io.fits.getHDUtype(fptr),'BINARY_TBL')
    coldata = coldata';
end

% Transpose the output into a column.
if size(coldata,1) <= repeat
    coldata = permute(coldata,[2 1]);
    if nargout > 1
        nullval = permute(nullval,[2 1]);
    end
end

if nargout > 1
    % Convert the NULLDATA to logical.
    if iscell(nullval)
        nullval = cellfun(@logical,nullval,'UniformOutput',false);
    else
        nullval = logical(nullval);
    end
end

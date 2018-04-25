%FWRITE Write binary data to file.
%   COUNT = FWRITE(FID,A) writes the elements of matrix A to the specified file. The
%   data are written in column order. COUNT is the number of elements successfully
%   written.
%
%   FID is an integer file identifier obtained from FOPEN, or 1 for standard output
%   or 2 for standard error.
%
%   COUNT = FWRITE(FID,A,PRECISION) writes the elements of matrix A to the specified
%   file, translating MATLAB values to the specified precision.
%
%   PRECISION controls the form and size of the result.  See the list of allowed
%   precisions under FREAD. If PRECISION is not specified, MATLAB uses the default,
%   which is 'uint8'. If either 'bitN' or 'ubitN' is used for the PRECISION then any
%   out of range value of A is written as a value with all bits turned on. If the
%   precision is 'char' or 'char*1', MATLAB writes characters using the encoding
%   scheme associated with the file. See FOPEN for more information.
%
%   COUNT = FWRITE(FID,A,PRECISION,SKIP) includes an optional SKIP argument that
%   specifies the number of bytes to skip before each PRECISION value is written.
%   With the SKIP argument present, FWRITE skips and writes a value, skips and writes
%   another value, etc. until all of A is written.  If PRECISION is a bit format like
%   'bitN' or 'ubitN' SKIP is specified in bits. This is useful for inserting data
%   into noncontiguous fields in fixed length records.
%
%   COUNT = FWRITE(FID,A,PRECISION,SKIP,MACHINEFORMAT) treats the data written as
%   having a format given by MACHINEFORMAT. You can obtain the MACHINEFORMAT argument
%   from the output of the FOPEN function. See FOPEN for possible values for
%   MACHINEFORMAT.
%   
%   For example,
%
%       fid = fopen('magic5.bin','wb')
%       fwrite(fid,magic(5),'integer*4')
%
%   creates a 100-byte binary file, containing the 25 elements of the 5-by-5 magic
%   square, stored as 4-byte integers.
%
%   See also FOPEN, FREAD, FPRINTF, SAVE, DIARY.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

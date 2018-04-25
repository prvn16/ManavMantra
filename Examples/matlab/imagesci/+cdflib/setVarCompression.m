function setVarCompression(cdfid,varnum,varargin)
%cdflib.setVarCompression Specify variable compression 
%   cdflib.setVarCompression(cdfId,varNum,compressionType,cparm) 
%   configures the compression setting for the variable specified by 
%   varNum in the file specified by cdfId.   Please consult the CDF User's 
%   Guide for a discussion of compression.
%
%   The compression type can be one of the five following strings or the 
%   numeric value corresponding to the string.
%
%       'NO_COMPRESSION'    - no compression
%       'RLE_COMPRESSION'   - run-length encoding compression
%       'HUFF_COMPRESSION'  - Huffman compression
%       'AHUFF_COMPRESSION' - Adaptive Huffman compression
%       'GZIP_COMPRESSION'  - GNU's zip compression.
%
%   cparm should only be provided if 'GZIP_COMPRESSION' is specified.  In
%   this case, params specifies the level of gzip compression and should be
%   a number between 1 and 9.  The parameter settings for
%   'RLE_COMPRESSION', 'HUFF_COMPRESSION', and 'AHUFF_COMPRESSION' are set
%   automatically.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarCompression.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       varnum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarCompression(cdfid,varnum,'GZIP_COMPRESSION',8);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setCompression, cdflib.getVarCompression.

%   Copyright 2009-2013 The MathWorks, Inc.


% If given a string, turn the compression type into the numeric equivalent.
if ischar(varargin{1})
	compression_scheme = cdflibmex('getConstantValue',varargin{1});
else
	compression_scheme = varargin{1};
end

if nargin == 3
	cdflibmex('setVarCompression',cdfid,varnum,compression_scheme);
else
	cdflibmex('setVarCompression',cdfid,varnum,compression_scheme,varargin{2});
end


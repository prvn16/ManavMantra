%SD Summary of MATLAB SD capabilities.
%   MATLAB provides low-level access to HDF files via package functions
%   that correspond to more than 50 functions in the HDF library SD
%   interface.   To use these MATLAB functions, you should be familiar with
%   the HDF SD C API.
% 
%   In most cases, the syntax of a MATLAB member function is similar to the 
%   syntax of the corresponding HDF library functions.  The functions 
%   are implemented as the package MATLAB.IO.HDF4.SD.  To use this package,
%   you need to prefix the function name with a package path, i.e. 
%
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','read');
%
%   The following table lists all the HDF library SD interface functions 
%   supported by this package.
%
%   -- Access --
%   close           - terminate access to file
%   endAccess       - terminate access to data set
%   getFileName     - return name of file 
%   select          - return identifier to data set
%   setExternalFile - stores data in external file
%   start           - initialize the SD interface
% 
%   -- Read/write --
%   create          - create new data set
%   readData        - read from a data set
%   setFillMode     - set fill mode of file
%   writedata       - write to data set
%   
%   -- Inquiry --
%   fileInfo        - return information about file contents
%   getCompInfo     - return compression information for data set
%   getFillValue    - return fill value of a data set
%   getInfo         - return information about data set
%   idToRef         - return reference number for data set
%   idType          - return type of object
%   isCoordVar      - determine if data set is a coordinate variable
%   isRecord        - determine if data set is appendable
%   nameToIndex     - return index of named data set
%   nameToIndices   - return list of data sets with same name
%   refToIndex      - return index of data set corresponding to reference
%   
%   -- Dimensions --
%   dimInfo         - get information about dimension
%   getDimID        - return identifier for a dimension
%   getDimScale     - return dimension scale data
%   setDimName      - associate name with dimension
%   setDimScale     - set dimension scale data
%   
%   -- User-defined Attributes --
%   attrInfo        - return information about attribute
%   findAttr        - return index of specified attribute
%   readAttr        - read attribute value
%   setAttr         - write attribute value
%
%   -- Predefined Attributes --
%   getCal          - return calibration information
%   getDataStrs     - return predefined attribute strings for data set
%   getDimStrs      - return predefined attribute strings for dimension
%   getFillValue    - read data set fill value
%   getRange        - return valid range
%   setCal          - set calibration information
%   setDataStrs     - set predefined attribute strings for data set
%   setDimStrs      - set predefined attribute strings for dimension
%   setFillValue    - set data set fill value
%   setRange        - set maximum and minimum range values
%
%   -- Chunking / Tiling Operations --
%   readChunk       - read data chunk from chunked data set
%   setChunk        - set chunk size and compression method
%   getChunkInfo    - return chunking information for data set
%   writeChunk      - write data chunk to chunked data set
%
%   -- Compression --
%   setCompress     - set data set compression method
%   setNBitDataSet  - specify non-standard bit length for data set
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also MATLAB.IO.HDFEOS.GD, MATLAB.IO.HDFEOS.SW.

%   Copyright 2013 The MathWorks, Inc.

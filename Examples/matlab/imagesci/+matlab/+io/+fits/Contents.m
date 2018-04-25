%FITS Summary of MATLAB CFITSIO capabilities.
%   MATLAB provides low-level access to FITS files via package functions
%   that correspond to more than 50 functions in the CFITSIO library.
%   To use these MATLAB functions, you should be familiar with the CFITSIO 
%   C API.
% 
%   In most cases, the syntax of a MATLAB member function is similar to the 
%   syntax of the corresponding CFITSIO library functions.  The functions 
%   are implemented as the package MATLAB.IO.FITS.  To use this package,
%   you need to prefix the function name with a package path, i.e. 
%
%       import matlab.io.*;
%       fptr = fits.openFile('tst0012.fits');
%
%   The following table lists all the CFITSIO library functions supported 
%   by this package.
%
%   -- File Access --
%       closeFile          - close FITS file
%       createFile         - create FITS file
%       deleteFile         - deletes FITS file
%       fileName           - return name of FITS file
%       fileMode           - return file I/O mode
%       openFile           - open FITS file
% 
%   -- Image Manipulation --
%       createImg          - create FITS image
%       getImgSize         - get image size
%       getImgType         - get image datatype
%       insertImg          - insert image just after current HDU
%       readImg            - read image data
%       setBscale          - reset scaling parameters
%       writeImg           - write to FITS image
%   
%   -- Keywords --
%       deleteKey          - delete key by name
%       deleteRecord       - delete key by record number
%       getHdrSpace        - return number of keywords in header
%       readCard           - return header record specified by keyword
%       readKey            - return specified keyword
%       readKeyCmplx       - return specified keyword as complex value
%       readKeyDbl         - return specified keyword as double precision
%       readKeyLongLong    - return specified keyword as int64
%       readKeyLongStr     - return the specified longstring value
%       readKeyUnit        - read physical units string 
%       readRecord         - return header record specified by number
%       writeComment       - write or append COMMENT keyword to current HDU
%       writeDate          - write DATE keyword to current HDU
%       writeKey           - update or add new keyword in current HDU
%       writeKeyUnit       - write physical units string 
%       writeHistory       - write or append HISTORY keyword to current HDU
%   
%   -- HDU Manipulation --
%       copyHDU            - copy current HDU from one file to another
%       deleteHDU          - delete current HDU
%       getHDUnum          - return number of current HDU
%       getHDUtype         - return type of current HDU
%       getNumHDUs         - get number of HDUs in file
%       movAbsHDU          - move to specified absolute HDU number
%       movNamHDU          - move to named HDU
%       movRelHDU          - move relative number of HDUs from current HDU
%       writeCheckSum      - compute DATASUM and CHECKSUM keyword values
%
%   -- Compression --
%       imgCompress        - compress image from one file into another
%       isCompressedImg    - determine if image is compressed 
%       setCompressionType - set algorithm to use when compressing image
%       setHCompScale      - set scale parameter for HCOMPRESS algorithm
%       setHCompSmooth     - set HCOMPRESS smoothing
%       setTileDim         - set tile dimensions
%
%   -- Table Information and Manipulation --
%       createTbl          - create new ASCII or bintable extension
%       deleteCol          - delete column from table
%       deleteRows         - delete rows from table
%       insertRows         - insert rows into table
%       getAColParms       - get ASCII table information
%       getBColParms       - get BINARY table information
%       getColName         - get table column name
%       getColType         - return column datatype, repeat value, and width
%       getEqColType       - return scaled column information
%       getNumCols         - get number of columns in table
%       getNumRows         - get number of rows in table
%       insertCol          - insert column into table
%       insertRows         - insert rows into table
%       insertATbl         - insert ASCII table after current HDU
%       insertBTbl         - insert binary table after current HDU
%       readATblHdr        - get ASCII table required keywords
%       readBTblHdr        - get binary table required keywords
%       readCol            - read rows of ASCII or binary table column
%       setTscale          - reset scaling parameters
%       writeCol           - write rows to ASCII or binary table column
%
%   -- Misc --
%       getConstantValue   - return numeric value of named constant
%       getVersion         - return CFITSIO library version
%       getOpenFiles       - return list of open FITS files
%
%   Please read the file cfitsiocopyright.txt for more information.
%
%   See also FITSREAD, FITSWRITE, FITSINFO, FITSDISP.

%   Copyright 2011-2013 The MathWorks, Inc.

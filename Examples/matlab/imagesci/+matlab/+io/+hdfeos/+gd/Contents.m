%GD Summary of MATLAB HDF-EOS Grid package.
%   MATLAB provides low-level access to HDF-EOS grid files via package
%   functions that correspond to more than 50 functions in the HDF-EOS
%   library grid interface. To use these MATLAB functions, you must be
%   familiar with the HDF-EOS library C interface.  Documentation about
%   HDF-EOS may be found at <http://hdfeos.org/>
% 
%   In most cases, the syntax of a MATLAB member function is similar to the
%   syntax of the corresponding HDF-EOS library functions.  The functions
%   are implemented as a package called MATLAB.IO.HDFEOS.GD.  To use this
%   package, you need to prefix the function name with a package path, i.e.
% 
%     import matlab.io.hdfeos.*
%     gfid = gd.open(filename,'read');
% 
%   The following table lists all the HDF-EOS library grid interface 
%   functions supported by this package.
% 
%   -- Access --
%   attach            - attach to existing grid dataset
%   close             - close file 
%   detach            - detach from grid
%   open              - create new file or open existing file
% 
%   -- Definition --
%   create            - create new grid structure
%   defComp           - define field compression scheme
%   defDim            - define grid dimensions
%   defField          - define data fields
%   defOrigin         - define origin of grid pixel
%   defPixReg         - define pixel registration
%   defProj           - define grid projection
%   writeBlkSOMoffset - write block SOM offset values
%
%   -- Basic I/O --
%   readField         - read data from grid field
%   writeField        - write data to grid field
%   writeAttr         - write attribute
%   readAttr          - read attribute
%   setFillValue      - set fill value for specified field
%   getFillValue      - return fill value for specified field
%   
%   -- Inquiry --
%   compInfo          - return compression information for specified field
%   dimInfo           - return length of dimension
%   fieldInfo         - return information for specified field
%   gridInfo          - return grid size and corner positions
%   inqAttrs          - return names of attributes
%   inqDims           - return information about grid dimensions
%   inqFields         - retrieve information about data fields
%   inqGrid           - return names of grids in file
%   nEntries          - return number of entities
%   originInfo        - return information about grid pixel origin
%   pixRegInfo        - return pixel registration information
%   projInfo          - return all GCTP projection information
%   readBlkSOMoffset  - read block SOM offset values
%   
%   -- Subsetting --
%   defBoxRegion      - define region of interest 
%   extractRegion     - read region of interest
%   regionInfo        - return information about defined region
%   defVrtRegion      - define a region of interest by vertical field
%   getPixels         - get row/columns for lon/lat pairs
%   getPixValues      - get field values for specified pixels
%   interpolate       - perform bilinear interpolation on a grid field 
%   
%   -- Tiling --
%   defTile           - define tiling scheme
%   readTile          - reads a single tile of data from a field
%   setTileComp       - set tiling, compression for field with fill value
%   tileInfo          - retrieve tiling information
%   writeTile         - writes a single tile of data to a field
%   
%   -- Utility --
%   ij2ll             - convert (i,j) coordinates to (lon,lat) for a grid
%   ll2ij             - convert (lon,lat) coordinates to (i,j) for a grid
%   sphereCodeToName  - return name of GCTP spheroid
%   sphereNameToCode  - return GCTP code of named GCTP spheroid 
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also MATLAB.IO.HDFEOS.SW, MATLAB.IO.HDF4.SD, HDFPT.

%   Copyright 2010-2015 The MathWorks, Inc.

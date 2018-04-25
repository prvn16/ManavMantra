%NETCDF Summary of MATLAB NETCDF capabilities.
%
%   MATLAB provides low-level access to NetCDF files via package functions
%   that correspond to more than 40 routines in the NetCDF library.  To
%   use these MATLAB functions, you must be familiar with the NetCDF C
%   interface.  The "NetCDF C Interface Guide" for version 4.1.3 may be
%   consulted at
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_4_1_3/>.
%
%   In most cases, the syntax of the MATLAB function is similar to the 
%   syntax of the NetCDF library function.  The functions are implemented 
%   as a package called "netcdf".  To use these functions, one needs to 
%   prefix the function name with package name "netcdf", i.e. 
%
%      ncid = netcdf.open ( ncfile, mode );
%
%   The following table lists all the NetCDF library functions supported by 
%   the netcdf package.
%
%      Library Functions
%      -----------------
%      getChunkCache    - Return default chunk cache settings.
%      inqLibVers       - Return NetCDF library version information.
%      setChunkCache    - Set the default chunk cache settings.
%      setDefaultFormat - Change default NetCDF file format.
%
%      File Functions
%      --------------
%      abort            - Revert recent NetCDF file definitions.
%      close            - Close NetCDF file.
%      create           - Create new NetCDF file.
%      endDef           - End NetCDF file define mode.
%      inq              - Return information about NetCDF file.
%      inqFormat        - Return NetCDF file format.
%      open             - Open NetCDF file.
%      reDef            - Set NetCDF file into define mode.
%      setFill          - Set NetCDF fill mode.
%      sync             - Synchronize NetCDF dataset to disk.  
%      
%      Dimension Functions
%      -------------------
%      defDim           - Create NetCDF dimension.
%      inqDim           - Return NetCDF dimension name and length.
%      inqDimID         - Return dimension ID.
%      inqUnlimDims     - Return unlimited dimensions visible in group.
%      renameDim        - Change name of NetCDF dimension.
%      
%      Group Functions
%      ---------------
%      defGrp           - Create group.
%      inqNcid          - Return ID of named group.
%      inqGrps          - Return IDs of child groups.
%      inqVarIDs        - Return all variable IDs for group.
%      inqDimIDs        - Return all dimension IDs visible from group.
%      inqGrpName       - Return relative name of group.
%      inqGrpNameFull   - Return complete name of group.
%      inqGrpParent     - Find ID of parent group.
%
%      Variable Functions
%      ------------------
%      defVar           - Create NetCDF variable.
%      defVarChunking   - Set chunking layout.
%      defVarDeflate    - Set variable compression.
%      defVarFill       - Set fill parameters for variable.
%      defVarFletcher32 - Set checksum mode.
%      getVar           - Return data from NetCDF variable.
%      inqVar           - Return information about variable.
%      inqVarChunking   - Return chunking layout for variable.
%      inqVarDeflate    - Return variable compression information.
%      inqVarFill       - Return fill value setting for variable.
%      inqVarFletcher32 - Return checksum settings.
%      inqVarID         - Return ID associated with variable name.
%      putVar           - Write data to NetCDF variable.
%      renameVar        - Change name of NetCDF variable.
%      
%      Attribute Functions
%      -------------------
%      copyAtt          - Copy attribute to new location.
%      delAtt           - Delete NetCDF attribute.
%      getAtt           - Return NetCDF attribute.
%      inqAtt           - Return information about NetCDF attribute.
%      inqAttID         - Return ID of NetCDF attribute.
%      inqAttName       - Return name of NetCDF attribute.
%      putAtt           - Write NetCDF attribute.
%      renameAtt        - Change name of attribute.
%
% 
%   The following functions have no equivalents in the NetCDF library.
%
%      getConstantNames - Return list of constants known to NetCDF library.
%      getConstant      - Return numeric value of named constant
%
%
%   MATLAB provides the following simple to use functions to read, write
%   and create NetCDF data files.
%
%   ncdisp        - Display contents of a NetCDF file in the command window.
%   ncread        - Read data from a variable in a NetCDF file.
%   ncreadatt     - Read an attribute value from a NetCDF file.
%   ncwrite       - Write data to a NetCDF file.
%   ncwriteatt    - Write an attribute to a NetCDF file.
%   ncinfo        - Return information about a NetCDF file.
%   nccreate      - Create a variable in a NetCDF file.  
%   ncwriteschema - Add NetCDF schema definitions to a NetCDF file.
%
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
 
%   Copyright 2008-2013 The MathWorks, Inc.

%CDFLIB Summary of MATLAB CDFLIB package.
%   MATLAB provides low-level access to CDF files via package functions
%   that correspond to more than 80 functions in the CDF library new 
%   standard interface.  To use these MATLAB functions, you must be 
%   familiar with the CDF C interface.  Documentation about CDF, version 
%   3.3.0, may be consulted at <http://cdf.gsfc.nasa.gov/>.
%
%   In most cases, the syntax of a MATLAB member function is similar to the 
%   syntax of the corresponding CDF library new standard interface 
%   function.  The functions are implemented as a package called "cdflib".  
%   To use these functions, you need to prefix the function name with 
%   package name "cdflib", i.e. 
%
%      cdfId = cdflib.open ( filename );
%
%   The following table lists all the member functions of the CDF package.
%
%  -- Library Information --
%      getConstantNames        - return list of CDF constant names
%      getConstantValue        - return numeric value corresponding to CDF constant
%      getLibraryCopyright     - return copyright notice
%      getLibraryVersion       - return version and release information
%      getFileBackward         - return backward compatibility mode
%      getValidate             - return data validation mode
%      setFileBackward         - set backward compatibility mode
%      setValidate             - set data validation mode
%
%  -- CDF Files --
%      close                   - close CDF
%      create                  - create CDF file
%      delete                  - delete CDF file
%      getCacheSize            - return number of cache buffers 
%      getChecksum             - return checksum mode
%      getCompression          - return CDF file compression settings
%      getCompressionCacheSize - get number of compression cache buffers
%      getCopyright            - return the copyright notice in CDF
%      getFormat               - return file format of CDF
%      getMajority             - return variable majority of CDF
%      getName                 - return file name of specified CDF
%      getReadOnlyMode         - return read-only mode of CDF
%      getStageCacheSize       - return number of staging cache buffers 
%      getVarsMaxWrittenRecNum - return maximum written record number
%      getVersion              - return release information for CDF
%      inquire                 - return basic characteristics of CDF
%      open                    - open existing CDF
%      setCacheSize            - specify number of dotCDF cache buffers
%      setChecksum             - specify checksum mode
%      setCompression          - specify CDF file compression settings
%      setCompressionCacheSize - specify compression cache buffers
%      setFormat               - specify the file format of CDF
%      setMajority             - specify variable majority of CDF
%      setReadOnlyMode         - specify read-only mode of CDF
%      setStageCacheSize       - specify staging cache buffers for CDF
%
%  -- CDF Variables --
%      closeVar                - close specified variable from multi-file format CDF
%      createVar               - create new CDF variable 
%      deleteVar               - delete CDF variable
%      deleteVarRecords        - delete range of records
%      getVarAllocRecords      - return number of records allocated
%      getVarBlockingFactor    - return CDF variable blocking factor
%      getVarCacheSize         - return number of multi-file cache buffers
%      getVarCompression       - return CDF variable compression information
%      getVarData              - return single value from specified index
%      getVarMaxAllocRecNum    - return number of records allocated for CDF variable
%      getVarMaxWrittenRecNum  - return maximum written record number
%      getVarName              - return name attached to CDF variable
%      getVarNum               - return variable identifier
%      getVarNumRecsWritten    - return number of records written
%      getVarPadValue          - return pad value
%      getVarRecordData        - return entire CDF variable record
%      getVarReservePercent    - return compression reserve percentage
%      getVarSparseRecords     - return sparse records type
%      inquireVar              - return information about CDF variable
%      hyperGetVarData         - read CDF variable hyperslab
%      hyperPutVarData         - write CDF variable hyperslab
%      putVarData              - write single datum to CDF variable
%      putVarRecordData        - write entire CDF variable record
%      renameVar               - rename existing CDF variable
%      setVarAllocBlockRecords - specify range of records to be allocated
%      setVarBlockingFactor    - specify CDF variable blocking factor 
%      setVarCacheSize         - specify multi-file cache buffers
%      setVarCompression       - specify CDF variable compression
%      setVarInitialRecs       - specify initial records
%      setVarPadValue          - specify pad value
%      setVarReservePercent    - specify compression reserve percentage
%      setVarsCacheSize        - specify cache buffers for all CDF variables
%      setVarSparseRecords     - specify sparse record type
%
%  -- CDF Attributes/Entries --
%      createAttr              - create attribute
%      deleteAttr              - delete attribute
%      deleteAttrEntry         - delete variable attribute entry
%      deleteAttrgEntry        - delete global attribute entry
%      getAttrEntry            - read variable attribute entry 
%      getAttrgEntry           - read global attribute entry 
%      getAttrMaxEntry         - return last entry number of variable attribute
%      getAttrMaxgEntry        - return last entry number of global attribute
%      getAttrName             - return attribute name
%      getAttrNum              - return attribute number
%      getAttrScope            - return attribute scope
%      getNumAttrEntries       - return number of entries for variable attribute
%      getNumAttrgEntries      - return number of entries for global attribute
%      getNumgAttributes       - return number of global attributes
%      getNumAttributes        - return number of variable attributes
%      inquireAttr             - return information about attribute
%      inquireAttrEntry        - return information about variable attribute entry
%      inquireAttrgEntry       - return information about global attribute entry
%      putAttrEntry            - write a variable attribute entry
%      putAttrgEntry           - write a global attribute entry
%      renameAttr              - rename attribute
%
%  -- EPOCH Utility Routines --
%      computeEpoch            - calculate EPOCH value
%      computeEpoch16          - calculate EPOCH16 value
%      epochBreakdown          - decompose EPOCH value
%      epoch16Breakdown        - decompose EPOCH16 value
% 
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFREAD, CDFWRITE, CDFINFO.
 
%   Copyright 2009-2013 The MathWorks, Inc.

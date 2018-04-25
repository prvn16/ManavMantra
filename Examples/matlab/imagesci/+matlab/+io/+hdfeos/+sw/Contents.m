%SW Summary of MATLAB HDF-EOS Swath package.
%   MATLAB provides low-level access to HDF-EOS swath files via package
%   functions that correspond to more than 30 routines in the HDF-EOS
%   library swath interface. To use these MATLAB functions, you should be
%   familiar with the HDF-EOS C interface.  Documentation about HDF-EOS may
%   be found at <http://hdfeos.org/>
%
%   In most cases, the syntax of a MATLAB member function is similar to the
%   syntax of the corresponding HDF-EOS library functions.  The functions
%   are implemented as a package called MATLAB.IO.HDFEOS.SW.  To use this
%   package, you need to prefix the function name with a package path, i.e.
%
%      import matlab.io.hdfeos.*
%      fileId = sw.open ( filename );
%
%   The following table lists all the HDF-EOS library swath interface 
%   functions supported by the sw package.
%
%  -- Access --
%      open            - create new file or open existing swath file
%      create          - create swath within file
%      attach          - attach to existing swath 
%      detach          - detach from swath interface
%      close           - close file
%
%  -- Definition --
%      defDim          - define new dimension within swath
%      defDimMap       - define mapping between dimensions dimension
%      defGeoField     - define new geolocation field within swath
%      defDataField    - define new data field within swath
%      defComp         - define field compression scheme
%
%  -- Basic I/O --
%      readAttr        - read attribute 
%      readField       - read data from a swath field
%      getFillValue    - get fill value for specified field
%      setFillValue    - set fill value for specified field
%      writeAttr       - write swath attribute
%      writeField      - write data to swath field
%
%  -- Inquiry --
%      compInfo       - return compression information
%      dimInfo        - return size of specified dimension
%      fieldInfo      - return geolocation or data field information
%      geoMapInfo     - return type of dimension mapping
%      idxMapInfo     - return offset and increment of indexed mapping
%      inqAttrs       - return attribute names
%      inqDataFields  - return information about data fields
%      inqDims        - return information about swath dimensions
%      inqGeoFields   - return information about geolocation field
%      inqIdxMaps     - return indexed geolocation relations
%      inqMaps        - return information about geolocation relations
%      inqSwath       - return names of swaths in file
%      mapInfo        - return offset and increment of mapping
%      nEntries       - return number of specific swath entities
%
%  -- Subsetting --
%      defBoxRegion   - define region of interest by location
%      regionInfo     - return information about defined region
%      extractRegion  - read region of interest
%      defTimePeriod  - define a time period of interest
%      periodInfo     - return information about a defined period
%      extractPeriod  - extract a defined period
%      defVrtRegion   - define a region of interest by vertical field
%      
%      
%   See also MATLAB.IO.HDFEOS.GD, MATLAB.IO.HDF4.SD, HDFPT.
 
%   Copyright 2010-2013 The MathWorks, Inc.


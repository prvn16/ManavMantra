function defDataField(swathID,name,idimlist,dtype,mergeCode)
%defDataField Define new data field within swath
%   defDataField(SWATHID,FIELDNAME,DIMLIST,DTYPE) defines a data field
%   to be stored in the swath identified by SWATHID.  DIMLIST may be a cell
%   array of dimension names, or a single char if there is only one
%   dimension.  DTYPE is the datatype of the field and may be one of the
%   following strings:
%
%       'double'
%       'single'
%       'int32'
%       'uint32'
%       'int16'
%       'uint16'
%       'int8'
%       'uint8'
%       'char'
%
%   DIMLIST should be ordered such that the fastest varying dimension is
%   listed first.  This is opposite from the order in which the dimensions
%   are listed in the C API.
%
%   sw.defDataField(SWATHID,FIELDNAME,DIMLIST,DTYPE,MERGECODE) defines a
%   data field that may be merged with other data fields according to the
%   value of MERGECODE. MERGECODE can be one of two strings, 'automerge'
%   and 'nomerge'.  If MERGECODE is 'automerge', then the HDF-EOS library
%   will attempt to merge swath fields into a single object.  This should
%   not be done if you wish to access the swath fields individually with
%   the another interface. By default, MERGECODE is 'nomerge'.
%
%   Note:  To assure that the fields defined by sw.defDataField are
%   properly extablished in the file, the swath should be detached and then
%   reattached before writing to any fields.
%
%   This function corresponds to the SWdefdatafield function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   DIMLIST parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'GeoTrack',2000);
%       sw.defDim(swathID,'GeoXtrack',1000);
%       sw.defDim(swathID,'DataTrack',4000);
%       sw.defDim(swathID,'DataXtrack',2000);
%       sw.defDim(swathID,'Bands',3);
%       sw.defDimMap(swathID,'GeoTrack','DataTrack',0,2);
%       sw.defDimMap(swathID,'GeoXtrack','DataXtrack',1,2);
%       dims = {'GeoXtrack','GeoTrack'};
%       sw.defGeoField(swathID,'Longitude',dims,'float');
%       sw.defGeoField(swathID,'Latitude',dims,'float');
%       dims = {'DataXtrack','DataTrack','Bands'};
%       sw.defDataField(swathID,'Spectra',dims,'float');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defGeoField, sw.inqDataFields.

%   Copyright 2010-2013 The MathWorks, Inc.



if nargin < 5
    mergeCode = 'nomerge';
end

% We can take a single name as the dimlist as well as a cell array.
if ischar(idimlist)
    if strfind(idimlist,',')
        error(message('MATLAB:imagesci:hdfeos:illegalDimensionName', idimlist));
    end
    dimlist = idimlist;
else
    % switch the ordering, row-vs-column majority issue.
    idimlist = fliplr(idimlist);
    % Construct the comma-delimited list for HDF-EOS2
    dimlist = idimlist{1} ;
    for j = 2:numel(idimlist);
        dimlist = [dimlist ',' idimlist{j}]; %#ok<AGROW>
    end
end

% Allow for matlab datatype names.
switch(dtype)
    case 'single'
        dtype = 'float';
    case 'double'
        dtype = 'float64';
end

status = hdf('SW','defdatafield',swathID,name,dimlist,dtype,mergeCode);
hdfeos_sw_error(status,'SWdefdatafield');

function data = hdfpointread(hinfo,params)
%HDFPOINTREAD:  HDF-EOS Point backend for HDFREAD.

%   Copyright 1984-2013 The MathWorks, Inc.

level = params.Level;
fieldname = params.Fields;


%Verify inputs are valid
parseInputs(hinfo,level,fieldname,params);

%Open interfaces
fileID = hdfpt('open',hinfo.Filename,'read');
if fileID==-1
    hdferrmsg(status,'PT','open');
end
pointID = hdfpt('attach',fileID,hinfo.Name);
if pointID==-1
    hdfpt('close',fileID);
    hdferrmsg(status,'PT','attach');
end

if isnumeric(level)
    %HDF-EOS defines level as zero based
    level = level-1;
else
    levelStr = level;
    level = hdfpt('levelindx',pointID,level);
    if level==-1
        closePTInterfaces(fileID,pointID);
        error(message('MATLAB:imagesci:hdfread:badPointName', levelStr));
    end
end

% Verify that the fields are present.
fields = parselist(fieldname);
for j = 1:numel(fields)
    if ~any(ismember(hinfo.Level(level+1).FieldNames,fields{j}))
        closePTInterfaces(fileID,pointID);
        error(message('MATLAB:imagesci:hdfread:badField', fields{j}));
    end
end

if ~isempty(params.Box)
    data = hdfpointread_box(fileID,pointID,level,fieldname,params.Box);
elseif ~isempty(params.Time)
    data = hdfpointread_time(fileID,pointID,level,fieldname,params.Time);
elseif ~isempty(params.RecordNumbers)
    data = hdfpointread_recordnumbers(hinfo,fileID,pointID,level,fieldname,params.RecordNumbers);
else
    recnums = 1:hinfo.Level(level+1).NumRecords;
    data = hdfpointread_recordnumbers(hinfo,fileID,pointID,level,fieldname,recnums);
end

closePTInterfaces(fileID,pointID);

return;

%==========================================================================
function closePTInterfaces(fileID,pointID)
%Close interfaces
try %#ok<TRYNC>
    hdfpt('detach',pointID);
end
try %#ok<TRYNC>
    hdfpt('close',fileID);
end
return;

%==========================================================================
function parseInputs(hinfo,level,fieldname,params)

if isempty(level) || isempty(fieldname)
    error(message('MATLAB:imagesci:hdfread:invalidPointInput'));
end


% 'Box' and 'Time' must both have just two elements.  When reading from
% swaths, both of these must have three elements.
if ~isempty(params.Box)
    validateattributes(params.Box,{'cell'},{'row','size',[1 2]},'','BOX');
end
if ~isempty(params.Time)
    validateattributes(params.Time,{'cell'},{'row','size',[1 2]},'','TIME');
end



%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','Level'};
numReqFields = length(reqFields);
if numFields >= numReqFields
    for i=1:numReqFields
        if ~isfield(hinfo,reqFields{i})
            error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Point'));
        end
    end
else
    error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Point'));
end


%Check to see if methods are exclusive.
if ~isempty(params.Box) || ~isempty(params.Time) || ~isempty(params.RecordNumbers) 
    % No other exclusive or optional method could have been given.
    fields = {'Box','Time','RecordNumbers'};
    s = 0;
    for j = 1:numel(fields)
        s = s + double(~isempty(params.(fields{j})));
    end
    if s > 1
        error(message('MATLAB:imagesci:hdfread:inconsistentParameters'));
    end
end

%--------------------------------------------------------------------------
function data = hdfpointread_box(fileID,pointID,level,fieldname,box)

[lon,lat] = deal(box{:});

regionID = hdfpt('defboxregion',pointID,lon,lat);
if regionID == -1
    closePTInterfaces(fileID,pointID);
    error (message('MATLAB:imagesci:hdfread:hdfEosApiFailure','DEFBOXREGION'));
end
try
    [data, status]  = hdfpt('extractregion',pointID,regionID,level,fieldname);
    if status == -1
        closePTInterfaces(fileID,pointID);
        error (message('MATLAB:imagesci:hdfread:hdfEosApiFailure','EXTRACTREGION'));
    end
catch myException
    closePTInterfaces(fileID,pointID);
    rethrow(myException);
end



%--------------------------------------------------------------------------
function data = hdfpointread_time(fileID,pointID,level,fieldname,time)

[start,stop] = deal(time{:});

regionID = hdfpt('deftimeperiod',pointID,start,stop);
if regionID == -1
    closePTInterfaces(fileID,pointID);
    error (message('MATLAB:imagesci:hdfread:hdfEosApiFailure','DEFTIMEPERIOD'));
end
try
    [data, status] = hdfpt('extractperiod',pointID,regionID,level,fieldname);
    if status == -1
        closePTInterfaces(fileID,pointID);
        error (message('MATLAB:imagesci:hdfread:hdfEosApiFailure','EXTRACTPERIOD'));
    end
catch myException
    closePTInterfaces(fileID,pointID);
    rethrow(myException);
end



%--------------------------------------------------------------------------
function data = hdfpointread_recordnumbers(hinfo,fileID,pointID,level,fieldname,recnums)

if any(recnums > hinfo.Level(level+1).NumRecords) || any(recnums < 0)
    closePTInterfaces(fileID,pointID);
    error(message('MATLAB:imagesci:hdfread:badRecordNumbers', level + 1, hinfo.Level( level + 1 ).NumRecords));
end


try
    [data, status] = hdfpt('readlevel',pointID,level,fieldname,recnums-1);
    if status == -1
        closePTInterfaces(fileID,pointID);
        error (message('MATLAB:imagesci:hdfread:readlevel'));
    end
catch myException
    closePTInterfaces(fileID,pointID);
    rethrow(myException);
end


function data = hdfvdataread(hinfo,params)
%HDFVDATAREAD read HDF Vdata
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data vdata set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(HINFO,FIELDS) reads all data from the comma separated
%   list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS) reads NUMRECORDS from the comma
%   separated list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS,FIRSTRECORD) reads NUMRECORDS
%   starting at record FIRSTRECORD from the comma separated list of FIELDS
%   in a Vdata set.

%   Copyright 1984-2013 The MathWorks, Inc.


[fields,numrecords,firstRecord] = parseVdataInputs(hinfo,params);

%Start interfaces
fileID = hdfh('open',hinfo.Filename,'read',0);
if fileID == -1
    hdferrmsg(fileID,'H','open');
end
status = hdfv('start',fileID);
if status == -1
    hdfh('close',fileID);
    hdferrmsg(status,'V','start');
end

%Attach to data set
vdID = hdfvs('attach',fileID,hinfo.Ref,'r');
if vdID == -1
    close_vh_interfaces(vdID,fileID);
    hdferrmsg(vdID,'VS','attach');
end

status = hdfvs('setfields',vdID,fields);
if status == -1
    close_vh_interfaces(vdID,fileID);
    hdferrmsg(status,'VS','setfields');
end

if firstRecord~=0
  pos = hdfvs('seek',vdID,firstRecord);
  if pos == -1
      close_vh_interfaces(vdID,fileID);
      hdferrmsg(pos,'VS','seek');
  end
end

try
    [data,count] = hdfvs('read',vdID,numrecords);
    if count == -1
        close_vh_interfaces(vdID,fileID);
        hdferrmsg(count,'VS','read');
    end
catch me
    close_vh_interfaces(vdID,fileID);
    rethrow(me)
end

close_vh_interfaces(vdID,fileID);


%==========================================================================
function [fields,numrecords,firstRecord] = parseVdataInputs(hinfo,params)

fields = params.Fields;
numrecords = params.NumRecords;
firstRecord = params.FirstRecord;
	  

fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Fields','Ref','NumRecords'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error(message('MATLAB:imagesci:hdfread:invalidVdataStruct'));
    end
  end
else 
  error(message('MATLAB:imagesci:hdfread:invalidVdataStruct'));
end
if ~isfield(hinfo.Fields,'Name')
  error(message('MATLAB:imagesci:hdfread:invalidVdataStruct'));
end

%Assign default values to parameters not defined in input
if isempty(fields)
  fields = sprintf('%s,',hinfo.Fields.Name);
  fields(end) = [];
end


% Verify that the requested fields are really there.
notThere = true; %#ok<NASGU>
req_fields = parselist(params.Fields);
for j = 1:numel(req_fields)
    notThere = true;
    for k = 1:numel(hinfo.Fields)
        if strcmp(req_fields{j},hinfo.Fields(k).Name)
            notThere = false;
        end
    end
    if notThere
        error(message('MATLAB:imagesci:hdfread:fieldNotPresent', ...
            req_fields{j}));
    end
end


if isempty(firstRecord)
  firstRecord = 0;
elseif firstRecord>=1
    firstRecord = firstRecord-1;
end

if isempty(numrecords)
    numrecords = hinfo.NumRecords - firstRecord;
end
if (firstRecord > hinfo.NumRecords) 
    error(message('MATLAB:imagesci:hdfread:badFirstRecord', ...
        hinfo.NumRecords));
elseif (numrecords > hinfo.NumRecords)
    error(message('MATLAB:imagesci:hdfread:badRecordSpecification', ...
        numrecords, hinfo.NumRecords));
end



%==========================================================================
function close_vh_interfaces(vdID,fileID)
%Close interfaces
try %#ok<TRYNC>
	hdfvs('detach',vdID);
end
try %#ok<TRYNC>
  hdfv('end',fileID);
end
try %#ok<TRYNC>
  hdfh('close',fileID);
end

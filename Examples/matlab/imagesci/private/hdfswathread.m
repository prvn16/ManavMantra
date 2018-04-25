function data = hdfswathread(hinfo,params)
%HDFSWATHREAD:  HDF-EOS swath backend for HDFREAD.

%   Copyright 1984-2013 The MathWorks, Inc.


%Verify inputs are valid
parseInputs(hinfo,params);
fieldname = params.Fields;

%Open interfaces
fileID = matlab.io.hdfeos.sw.open(hinfo.Filename);
try
    
    swathID = matlab.io.hdfeos.sw.attach(fileID,hinfo.Name);
    
    % verify that the field is there.
    try
        dims = matlab.io.hdfeos.sw.fieldInfo(swathID,fieldname);
    catch me
        error(message('MATLAB:imagesci:hdfread:fieldNotFound', fieldname, hinfo.Name));
    end
    
    % Check for consistency.  Do not allow both a geolocation restriction and
    % a dimension restriction if the dimension name is the same
    validate_vertical_restriction(params);
    
    
    if ~isempty(params.Index)
        
        [start,stride,edge] = deal(params.Index{:});
                        
        if isempty(start)
            start = ones(1,numel(dims));
        end
        start = start-1;
        
        if isempty(stride)
            stride = ones(1,numel(dims));
        end
        
        if isempty(edge)
            edge = floor((dims - start + stride - 1) ./ stride);
        end
        
		start = fliplr(start);
		stride = fliplr(stride);
		edge = fliplr(edge);
        
        data = matlab.io.hdfeos.sw.readField(swathID,fieldname,start,edge,stride);
        
    elseif ~isempty(params.Time)
        
        [start,stop,mode] = deal(params.Time{:});
        periodID = matlab.io.hdfeos.sw.defTimePeriod(swathID,start,stop,mode);
        data = matlab.io.hdfeos.sw.extractPeriod(swathID,periodID,fieldname);
        
    elseif ~isempty(params.Box)
        
        [lon,lat,mode] = deal(params.Box{:});     
        regionID = matlab.io.hdfeos.sw.defBoxRegion(swathID,lat,lon,mode);
        
        % 'Box' and 'Vertical' are not mutually exclusive.  
        if ~isempty(params.Vertical)
            for j = 1:numel(params.Vertical)
                [dimension, range] = deal(params.Vertical{j}{:});
                regionID = matlab.io.hdfeos.sw.defVrtRegion(swathID,regionID,dimension,range);
            end
        end
        data = matlab.io.hdfeos.sw.extractRegion(swathID,regionID,fieldname);
      
    elseif ~isempty(params.Vertical)
        
        regionID = 'NOPREVSUB';
        for j = 1:numel(params.Vertical)
            [dimension, range] = deal(params.Vertical{j}{:});
            regionID = matlab.io.hdfeos.sw.defVrtRegion(swathID,regionID,dimension,range);
        end
        
        data = matlab.io.hdfeos.sw.extractRegion(swathID,regionID,fieldname);

    else
        
		% Default case, read everything.
        data = matlab.io.hdfeos.sw.readField(swathID,fieldname);
        
    end
           
    %Permute data to be the expected dimensions
    data = permute(data,ndims(data):-1:1);
    
catch me
    if exist('swathID','var')
        matlab.io.hdfeos.sw.detach(swathID);
    end
    matlab.io.hdfeos.sw.close(fileID);
    rethrow(me);
end


matlab.io.hdfeos.sw.detach(swathID);
matlab.io.hdfeos.sw.close(fileID);




%==========================================================================
function parseInputs(hinfo,params)

% 'Box' and 'Time' must both have three elements.  When reading from
% HDF-EOS points, both of these must have just two elements.
if ~isempty(params.Box)
    validateattributes(params.Box,{'cell'},{'row','size',[1 3]},'hdfswathread','Box');
end
if ~isempty(params.Time)
    validateattributes(params.Time,{'cell'},{'row','size',[1 3]},'hdfswathread','Time');
end
validateattributes(params.Fields,{'cell','char'},{'nonempty'},'hdfswathread','Fields');
fields = parselist(params.Fields);


if length(fields)>1
    error(message('MATLAB:imagesci:hdfread:tooManyFields'));
end


%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields','GeolocationFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
    for i=1:numReqFields
        if ~isfield(hinfo,reqFields{i})
            error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Swath'));
        end
    end
else
    error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Swath'));
end


%Check to see if methods are exclusive.
if ~isempty(params.Index) || ~isempty(params.Time)
    % No other exclusive or optional method could have been given.
    fields = {'Index','Box','Time','Vertical'};
    s = 0;
    for j = 1:numel(fields)
        s = s + double(~isempty(params.(fields{j})));
    end
    if s > 1
        error(message('MATLAB:imagesci:hdfread:inconsistentParameters'));
    end
end





%===============================================================================
function validate_vertical_restriction(params)
% Check that we do not restrict on both a dimension and a geolocation variable
% of the same name.  Restricting on both does not really make sense, and the 
% HDF Swath interface will give inconsistent results in that case.

% If we have a dimension restriction and a geolocation restriction of the same 
% name, say 'DIM:Band_1KM_RefSB' and 'Band_1KM_RefSB', then we know we have
% a conflict.
geolocation_restriction_list = {};
dimension_restriction_list = {};

for j = 1:numel(params.Vertical)
    
    subset_obj = params.Vertical{j}{1};
    
    if strcmp(subset_obj(1:4),'DIM:') && (numel(subset_obj) > 4)
        % The subset object is a dimension.  Add it to the list.
        dimension_restriction_list{end+1} = subset_obj(5:end); %#ok<AGROW>
    else
        geolocation_restriction_list{end+1} = subset_obj; %#ok<AGROW>
    end
        
end


C = intersect(geolocation_restriction_list, dimension_restriction_list);
if ( numel(C) > 0 )
    error (message('MATLAB:imagesci:hdfread:incompatibleVerticalSubset', C{ 1 }, C{ 1 }));
        
end

function data = hdfgridread(hinfo,params)
%HDFGRIDREAD:  HDF-EOS grid backend for HDFREAD.

%   Copyright 1984-2015 The MathWorks, Inc.


%Verify inputs are valid
parseInputs(hinfo,params);
fieldname = params.Fields;

fileID = matlab.io.hdfeos.gd.open(hinfo.Filename);
try
    gridID = matlab.io.hdfeos.gd.attach(fileID,hinfo.Name);

    try
        dims = matlab.io.hdfeos.gd.fieldInfo(gridID,fieldname);
    catch me
        error(message('MATLAB:imagesci:hdfread:fieldNotFound', fieldname, hinfo.Name));
    end


    if ~isempty(params.Index)
    
        [start,stride,edge] = deal(params.Index{:});
        
        if isempty(start)
            start = ones(1,numel(dims));
        end
        if isempty(stride)
            stride = ones(1,numel(dims));
        end
        
        % The start is zero-based for expert interface.
        start = start - 1;
        
        % If specified to read until the end (edge not given), then must
        % compute how many elements to retrieve.
        if isempty(edge)
            edge = floor((dims - start + stride - 1) ./ stride);
        end
        
        % The indices must be in column-major order.           
        start = fliplr(start);
        stride = fliplr(stride);
        edge = fliplr(edge);
        
        data = matlab.io.hdfeos.gd.readField(gridID,fieldname,start,edge,stride);

    elseif ~isempty(params.Tile)
    
        tileCoords = fliplr(params.Tile-1);
        data = matlab.io.hdfeos.gd.readTile(gridID,fieldname,tileCoords);
    
    elseif ~isempty(params.Pixels)
    
        [lon,lat] = deal(params.Pixels{:});
        [rows,cols] = matlab.io.hdfeos.gd.getPixels(gridID,lat,lon);
        data = matlab.io.hdfeos.gd.getPixValues(gridID,rows,cols,fieldname);
    
    elseif ~isempty(params.Interpolate)
    
        [lon,lat] = deal(params.Interpolate{:});
        data = matlab.io.hdfeos.gd.interpolate(gridID,lat,lon,fieldname);
    
    elseif ~isempty(params.Box)
    
        [lon,lat] = deal(params.Box{:});
        regionID = matlab.io.hdfeos.gd.defBoxRegion(gridID,lat,lon);

        if ~isempty(params.Time)
            [start, stop] = deal(params.Time{:});

            % Is the Time field a variable or a dimension?
            vobj = determine_vertical_time_object(gridID);

            regionID = matlab.io.hdfeos.gd.defVrtRegion(gridID,regionID,vobj,[start stop]);
        end

        if ~isempty(params.Vertical)
            for j = 1:numel(params.Vertical)
                [dimension, range] = deal(params.Vertical{j}{:});
                regionID = matlab.io.hdfeos.gd.defVrtRegion(gridID,regionID,dimension,range);
            end
        end

        data = matlab.io.hdfeos.gd.extractRegion(gridID,regionID,fieldname);
    
    elseif ~isempty(params.Time)
        
        % There is no GDextractperiod function, so the gd package has no
        % defTimePeriod function.  But we can use defVrtRegion instead.    
        
        [start, stop] = deal(params.Time{:});

        % Is the Time field a variable or a dimension?
        vobj = determine_vertical_time_object(gridID);
        
           regionID = matlab.io.hdfeos.gd.defVrtRegion(gridID,'noprevsub',vobj,[start stop]);
        if ~isempty(params.Vertical)
            for j = 1:numel(params.Vertical)
                [dimension, range] = deal(params.Vertical{j}{:});
                regionID = matlab.io.hdfeos.gd.defVrtRegion(gridID,regionID,dimension,range);
            end
        end
        data = matlab.io.hdfeos.gd.extractRegion(gridID,regionID,fieldname);
    
    elseif ~isempty(params.Vertical)

        regionID = 'noprevsub';
        for j = 1:numel(params.Vertical)
            [dimension, range] = deal(params.Vertical{j}{:});
            regionID = matlab.io.hdfeos.gd.defVrtRegion(gridID,regionID,dimension,range);
        end
        data = matlab.io.hdfeos.gd.extractRegion(gridID,regionID,fieldname);
    
    else
    
        % Default action.
        data = matlab.io.hdfeos.gd.readField(gridID,fieldname);
    
    end
    
    

catch me
    if exist('gridID','var');
        matlab.io.hdfeos.gd.detach(gridID);
    end
    matlab.io.hdfeos.gd.close(fileID);
    rethrow(me);
end

matlab.io.hdfeos.gd.detach(gridID);
matlab.io.hdfeos.gd.close(fileID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);


%--------------------------------------------------------------------------
function parseInputs(hinfo,params)

if ~isempty(params.Box)
    validateattributes(params.Box,{'cell'},{'row','size',[1 2]},'','BOX');
end
if isempty(params.Fields)
    error(message('MATLAB:imagesci:hdfread:missingFieldsParam'));
else
    fields = parselist(params.Fields);
end

if length(fields)>1
    error(message('MATLAB:imagesci:hdfread:tooManyFields'));
end


%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
    for i=1:numReqFields
        if ~isfield(hinfo,reqFields{i})
            error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Grid'));
        end
    end
else
    error(message('MATLAB:imagesci:hdfread:invalidEosStruct','HDF-EOS Grid'));
end

%Check to see if methods are exclusive.
if ~isempty(params.Index) || ~isempty(params.Tile) || ~isempty(params.Pixels) || ~isempty(params.Interpolate)
    % No other exclusive or optional method could have been given.
    fields = {'Index','Tile','Pixels','Interpolate','Box','Time','Vertical'};
    s = 0;
    for j = 1:numel(fields)
        s = s + double(~isempty(params.(fields{j})));
    end
    if s > 1
        error(message('MATLAB:imagesci:hdfread:inconsistentParameters'));
    end
end

%--------------------------------------------------------------------------
function vobj = determine_vertical_time_object(gridID)

% Is the Time field a variable or a dimension?
try
    matlab.io.hdfeos.gd.fieldInfo(gridID,'Time');
    vobj = 'Time';
catch me %#ok<NASGU>
    % Assume it is then a dimension.
    matlab.io.hdfeos.gd.dimInfo(gridID,'Time');
    vobj = 'DIM:Time';
end

return

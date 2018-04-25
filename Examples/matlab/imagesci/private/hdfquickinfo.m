function hinfo = hdfquickinfo(filename,dataname,params)
%HDFQUICKINFO scan HDF file
%
%   HINFO = HDFQUICKINFO(FILENAME,DATANAME) scans the HDF file FILENAME for
%   the data set named DATANAME.  HINFO is a structure describing the data
%   set.  If no data set is found an empty structure is returned.

%   Copyright 1984-2015 The MathWorks, Inc.

found = 0;
hinfo = struct([]);

fileID = hdfh('open',filename,'read',0);
if (fileID < 0)
    error(message('MATLAB:imagesci:hdfinfo:invalidFile', filename));     
end
cleanUpHdfh = onCleanup(@() hdfh('close',fileID) );

%Search for EOS data sets first because they are wrappers around HDF data
%sets

%Grid data set
if ~found && ~isempty(params.Fields)
	[found, hinfo] = findInsideGrid ( filename, dataname );
end

%Swath data set
if ~found && ~isempty(params.Fields)
	[found, hinfo] = findInsideSwath ( filename, dataname );
end

%Point data set
if ~found && (~isempty(params.Level) && ~isempty(params.Fields))
	[found, hinfo] = findInsidePointDataSet ( filename, dataname );
end

% Read data (SD or Vdata set) inside a Vgroup
if ~found
	[found, hinfo] = findInsideVgroup(filename, fileID, dataname);
end


%Scientific Data Set
if ~found
	[found, hinfo] = findInsideSD(filename, fileID, dataname);
end


%Vdata set
if ~found
	[found, hinfo] = findInsideVdata(filename, fileID, dataname);
end

%8-bit Raster Image
if ~found
	[found, hinfo] = findInside8bitRasterImage(filename, fileID, dataname);
end

%24-bit Raster
if ~found
	[~, hinfo] = findInside24bitRasterImage(filename, fileID, dataname);
end



return;




%--------------------------------------------------------------------------
function [parentID, dataname] = findVgroupInPath(fileID,dataname,vgroupID)
% Find a parent vgroup in the supplied path.
parentID = -1;
if nargin==2
    % vgroup is empty.  Open the root vgroup and call ourselves again.
    if dataname(1)=='/' % The root directory
        dataname(1) = '';
    end
    [head, dataname] = splitPathname(dataname);
    if isempty(head)
        return
    end
    ref = hdfv('find', fileID, head);
    vgroupID = hdfv('attach',fileID, ref, 'r');
    % Return the parent ID.
    [parentID, dataname] = findVgroupInPath(fileID, dataname, vgroupID);
else
    [head, dataname] = splitPathname(dataname);
    if isempty(head)
        % If there are no subdirectories, we are done.            
        parentID = vgroupID;
        return
    end
    % Open the next vgroup
    vgroupID = findVgroupFromName(fileID, vgroupID, head);
    if vgroupID ~= -1
        % Attempt to open further Vgroups, if possible.
        [parentID, dataname] = findVgroupInPath(fileID, dataname, vgroupID);
    end
end

if parentID ~= vgroupID 
    % release all vgroup ID's except for the last one.
    hdfv('detach', vgroupID);
end



function [head, dataname] = splitPathname(dataname)
% Get the head of a pathname (vgroup name)
pathLoc = strfind(dataname, '/');
if ~isempty(pathLoc)
    head = dataname(1:pathLoc(1)-1);
    dataname = dataname(pathLoc(1)+1:end);
else
    head = [];
end

function [childID] = findVgroupFromName(fileID, vgroupID, dirName)
% Get a Vgroup with a given dirName (from inside a VGroup).
vgroupRef = -1;
while true
    % Get the next vgroup in the file
    vgroupRef = hdfv('getid', fileID, vgroupRef);
    if vgroupRef==-1
        break;
    end
    % If they are not a child of vgroupID, keep looking.
    if ~hdfv('isvg', vgroupID, vgroupRef)
        continue;
    end
    % Open the vgroup, and if the names match, we are done.
    childID = hdfv('attach', fileID, vgroupRef, 'r');
    [vgroup_name, status] = hdfv('getname', childID);
	if status ~= 0
		hdfv('end',fileID);
		error (message('MATLAB:imagesci:hdfinfo:getname', childID)); 
	end
    if strcmp(vgroup_name, dirName)
        return
    end
    hdfv('detach', childID);
end
childID = -1;






%--------------------------------------------------------------------------
function [found, hinfo] = findInsideVgroup(filename, fileID, dataname )

found = 0;
hinfo = [];

anID = hdfan('start',fileID);
cleanUpAnID = onCleanup(@() hdfan('end',anID) );


% Open the required interfaces and find the parent vgroup (if any).
hdfv('start',fileID);
cleanUpVint = onCleanup(@() hdfv('end',fileID) );

sdID = matlab.io.hdf4.sd.start(filename,'read');
cleanUpSD = onCleanup(@() matlab.io.hdf4.sd.close(sdID) );

[parentID, dataname] = findVgroupInPath(fileID, dataname);
cleanUpVg = onCleanup(@() hdfv('detach',parentID) );

count = hdfv('ntagrefs', parentID);
% Iterate over each child
for i=0:count-1
    if found
        break
    end
    % Find out the type of the child
    [tag,ref,status] = hdfv('gettagref', parentID,i);
	if status ~= 0
		matlab.io.hdf4.sd.close(sdID);
		error (message('MATLAB:imagesci:hdfinfo:gettagref', i)); 
	end

    bVG = hdfv('isvg', parentID, ref);
    bVS = hdfv('isvs', parentID, ref);
    bSDS = ~bVG && ~bVS;
    % handle the case where it is VDATA
    if( bVS ) 
        % Read the VDATA name.
        vdata_id = hdfvs('attach', fileID, ref, 'r');
        vdataName = hdfvs('getname', vdata_id);
        if strcmp(vdataName, dataname)
            found = 1;
            hinfo = hdfvdatainfo(filename, fileID, anID, ref);
        end
        hdfvs('detach',vdata_id);
        % Handle the case where it is Scientific Data
    elseif( bSDS ) 
        % Read the SDS name.
        if ((tag==hdfml('tagnum','DFTAG_NDG')) ...
                || (tag==hdfml('tagnum','DFTAG_SD')))
            index = matlab.io.hdf4.sd.refToIndex(sdID, ref);
            sdsID = matlab.io.hdf4.sd.select(sdID, index);
            sdsName = matlab.io.hdf4.sd.getInfo(sdsID);
            if strcmp(sdsName, dataname)
                found = 1;
                hinfo = hdfsdsinfo(filename, sdID, anID, index);
            end
            matlab.io.hdf4.sd.endAccess(sdsID);
        end
    end
end

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideGrid ( filename, dataname )

found = false;
hinfo = [];
grids = matlab.io.hdfeos.gd.inqGrid(filename);
if numel(grids) == 0
    return
end
fileID = matlab.io.hdfeos.gd.open(filename,'read');
cleanUpFile = onCleanup(@() matlab.io.hdfeos.gd.close(fileID));

try
    gridID = matlab.io.hdfeos.gd.attach(fileID,dataname);
    found = true;
catch me
    if ~strcmp(me.identifier,'MATLAB:imagesci:hdfeos:hdfEosLibraryError')
        rethrow(me);
    end
    return
end

hinfo = hdfgridinfo(filename,fileID,dataname);

matlab.io.hdfeos.gd.detach(gridID);

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideSwath ( filename, dataname )
found = false;
hinfo = [];
swaths = matlab.io.hdfeos.sw.inqSwath(filename);
if numel(swaths) == 0
    return
end

fileID = matlab.io.hdfeos.sw.open(filename,'read');
cleanUpFile = onCleanup(@() matlab.io.hdfeos.sw.close(fileID));

try
    swathID = matlab.io.hdfeos.sw.attach(fileID,dataname);
    found = true;
catch me
    if ~strcmp(me.identifier,'MATLAB:imagesci:hdfeos:hdfEosLibraryError')
        rethrow(me);
    end
    return
end


found = 1;
hinfo = hdfswathinfo(filename,fileID,dataname);
matlab.io.hdfeos.sw.detach(swathID);

return



%--------------------------------------------------------------------------
function [found, hinfo] = findInsidePointDataSet ( filename, dataname )
found = false;
hinfo = [];
numpoint = hdfpt('inqpoint',filename);
if numpoint == 0
    return
end
fileID = hdfpt('open',filename,'read');
if (fileID < 0)
    error(message('MATLAB:imagesci:hdfinfo:invalidFile', filename));     
end
pointID = hdfpt('attach',fileID,dataname);
if pointID~=-1
        found = 1;
        hinfo = hdfpointinfo(filename,fileID,dataname);
        hdfpt('detach',pointID);
end
hdfpt('close',fileID);
return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideSD ( filename, fileID, dataname )

%
% If given something like "/varname", then the slash just means
% that varname is part of the root group.  We need to remove
% the slash.
if ( dataname(1) == '/' )
    dataname(1) = '';
end

found = false;
hinfo = [];
sdID = matlab.io.hdf4.sd.start(filename,'read');

anID = hdfan('start',fileID);
try
    matlab.io.hdf4.sd.nameToIndex(sdID,dataname);
catch me %#ok<NASGU>
    matlab.io.hdf4.sd.close(sdID);
    return
end

found = 1;
hinfo = hdfsdsinfo(filename,sdID,anID,dataname);

matlab.io.hdf4.sd.close(sdID);
hdfan('end',anID);
return



%--------------------------------------------------------------------------
function [found, hinfo] = findInsideVdata ( filename, fileID, dataname )

%
% If given something like "/varname", then the slash just means
% that varname is part of the root group.  We need to remove
% the slash.
if ( dataname(1) == '/' )
    dataname(1) = '';
end

found = false;
hinfo = [];
anID = hdfan('start',fileID);
hdfv('start',fileID);
ref = hdfvs('find',fileID,dataname);
if ref~=0
    found = 1;
    hinfo = hdfvdatainfo(filename,fileID,anID,ref);
end
hdfv('end',fileID);
hdfan('end',anID);

return





%--------------------------------------------------------------------------
function [found, hinfo] = findInside8bitRasterImage ( filename, fileID, dataname )
found = false;
hinfo = [];

anID = hdfan('start',fileID);

[name,ref] = strtok(dataname,'#');
if strcmp('8-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster8info(filename,ref,anID);
    if ~isempty(hinfo)
       found = 1;
    end
end

hdfan('end',anID);

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInside24bitRasterImage(filename, fileID, dataname)
found = false;
hinfo = [];

anID = hdfan('start',fileID);

[name,ref] = strtok(dataname,'#');
if strcmp('24-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster24info(filename,ref,anID);
    if ~isempty(hinfo)
       found = 1;
    end
end

hdfan('end',anID);

return




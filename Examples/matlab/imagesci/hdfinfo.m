function fileinfo = hdfinfo(varargin)
%HDFINFO Information about HDF 4 or HDF-EOS 2 file
%
%   FILEINFO = HDFINFO(FILENAME) returns a structure whose fields contain
%   information about the contents an HDF or HDF-EOS file.  FILENAME is a
%   string that specifies the name of the HDF file. HDF-EOS files are
%   described as HDF files.
%
%   FILEINFO = HDFINFO(FILENAME,MODE) reads the file as an HDF file if MODE
%   is 'hdf', or as an HDF-EOS file if MODE is 'eos'.  If MODE is 'eos',
%   only HDF-EOS data objects are queried.  To retrieve information on the
%   entire contents of a hybrid HDF-EOS file, MODE must be 'hdf' (default).
%   
%   The set of fields in FILEINFO depends on the individual file.  Fields
%   that may be present in the FILEINFO structure are:
%
%   HDF objects:
%   
%   Filename   A string containing the name of the file
%   
%   Vgroup     An array of structures describing the Vgroups
%   
%   SDS        An array of structures describing the Scientific Data Sets
%   
%   Vdata      An array of structures describing the Vdata sets
%   
%   Raster8    An array of structures describing the 8-bit Raster Images
%   
%   Raster24   An array of structures describing the 24-bit Raster Images
%   
%   HDF-EOS objects:
%
%   Point      An array of structures describing HDF-EOS Point data
%   
%   Grid       An array of structures describing HDF-EOS Grid data
%   
%   Swath      An array of structures describing HDF-EOS Swath data
%   
%   The data set structures above share some common fields.  They are (note,
%   not all structures will have all these fields):
%   
%   Filename          A string containing the name of the file
%                     
%   Type              A string describing the type of HDF object 
%   	              
%   Name              A string containing the name of the data set
%                     
%   Attributes        An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     data set
%                     
%   Rank              A number specifying the number of dimensions of the
%                     data set
%
%   Ref               The reference number of the data set
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%
%   Fields specific to each structure are:
%   
%   Vgroup:
%   
%      Class      A string containing the class name of the data set
%
%      Vgroup     An array of structures describing Vgroups
%                 
%      SDS        An array of structures describing Scientific Data sets
%                 
%      Vdata      An array of structures describing Vdata sets
%                 
%      Raster24   An array of structures describing 24-bit raster images  
%                 
%      Raster8    An array of structures describing 8-bit raster images
%                 
%      Tag        The tag of this Vgroup
%                 
%   SDS:
%              
%      Dims       An array of structures with fields 'Name', 'DataType',
%                 'Size', 'Scale', and 'Attributes'.  Describing the
%                 dimensions of the data set.  'Scale' is an array of numbers
%                 to place along the dimension and demarcate intervals in
%                 the data set.
%              
%      DataType   A string specifying the precision of the data
%              
%
%      Index      Number indicating the index of the SDS
%   
%   Vdata:
%   
%      DataAttributes    An array of structures with fields 'Name' and 'Value'
%                        describing the name and value of the attributes of the
%                        entire data set
%   
%      Class             A string containing the class name of the data set
%		      
%      Fields            An array of structures with fields 'Name' and
%                        'Attributes' describing the fields of the Vdata
%                        
%      NumRecords        A number specifying the number of records of the data
%                        set   
%                        
%      IsAttribute       1 if the Vdata is an attribute, 0 otherwise
%      
%   Raster8 and Raster24:
%
%      Name           A string containing the name of the image
%   
%      Width          An integer indicating the width of the image
%                     in pixels
%      
%      Height         An integer indicating the height of the image
%                     in pixels
%      
%      HasPalette     1 if the image has an associated palette, 0 otherwise
%                     (8-bit only)
%      
%      Interlace      A string describing the interlace mode of the image
%                     (24-bit only)
%
%   Point:
%
%      Level          A structure with fields 'Name', 'NumRecords',
%                     'FieldNames', 'DataType' and 'Index'.  This structure
%                     describes each level of the Point
%      
%   Grid:
%     
%      UpperLeft      A number specifying the upper left corner location
%                     in meters
%      
%      LowerRight     A number specifying the lower right corner location
%                     in meters
%      
%      Rows           An integer specifying the number of rows in the Grid
%      
%      Columns        An integer specifying the number of columns in the Grid
%      
%      DataFields     An array of structures with fields 'Name', 'Rank', 'Dims',
%                     'NumberType', 'FillValue', and 'TileDims'. Each structure
%                     describes a data field in the Grid fields in the Grid
%      
%      Projection     A structure with fields 'ProjCode', 'ZoneCode',
%                     'SphereCode', and 'ProjParam' describing the Projection
%                     Code, Zone Code, Sphere Code and projection parameters of
%                     the Grid
%      
%      Origin Code    A number specifying the origin code for the Grid
%      
%      PixRegCode     A number specifying the pixel registration code
%      
%   Swath:
%		       
%      DataFields         An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Data field in the Swath 
%
%      GeolocationFields  An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Geolocation field in the Swath 
%   
%      MapInfo            A structure with fields 'Map', 'Offset', and
%                         'Increment' describing the relationship between the
%                         data and geolocation fields. 
%   
%      IdxMapInfo         A structure with 'Map' and 'Size' describing the
%                         relationship between the indexed elements of the
%                         geolocation mapping
%   
% 
%   Example:  
%             % Retrieve info about example.hdf
%             fileinfo = hdfinfo('example.hdf');
%             % Retrieve info about Scientific Data Set in example
%             data_set_info = fileinfo.SDS;
%	     
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDFTOOL, HDFREAD, HDF.  
  
%   Copyright 1984-2015 The MathWorks, Inc.

[filename, mode] = parseInputs(varargin{:});

%  Open the interfaces. The private functions will expect the interfaces to be
%  open and closed by this function.   This is done for performance; opening
%  and closing these interfaces is expensive.
if strcmpi(mode,'hdf')
    fileID = hdfh('open',filename,'read',0);
    if fileID==-1
        error(message('MATLAB:imagesci:validate:fileOpen',filename));
    end
    
    sdID=-1;
    try
        sdID = matlab.io.hdf4.sd.start(filename,'read');
    catch
        warning(message('MATLAB:imagesci:sd:hdfLibraryError','SD'));
    end
    
    vstatus = hdfv('start',fileID);
    if vstatus==-1
        warning(message('MATLAB:imagesci:hdfinfo:interfaceStart','V'));
    end
    
    anID = hdfan('start',fileID);
    if anID == -1
        warning(message('MATLAB:imagesci:hdfinfo:interfaceStart','AN'));
    end
elseif strcmpi(mode,'eos')
    gdID = -1;
    try
        gdID = matlab.io.hdfeos.gd.open(filename,'read');
    catch
        warning(message('MATLAB:imagesci:hdfeos:hdfEosLibraryError','GD'));
    end
    
    swID = -1;
    try
        swID = matlab.io.hdfeos.sw.open(filename,'read');
    catch
        warning(message('MATLAB:imagesci:hdfeos:hdfEosLibraryError','SW'));
    end
    
    ptID = hdfpt('open',filename,'read');
    if ptID==-1
        warning(message('MATLAB:imagesci:hdfinfo:interfaceStart','PT'));
    end
end

%Get attributes that apply to entire file
fileAttribute = '';
if ~strcmpi(mode,'eos')
    if sdID ~= -1
        [~,nGlobalAttrs] = matlab.io.hdf4.sd.fileInfo(sdID);
        if nGlobalAttrs>0
            for i=1:nGlobalAttrs
                [fileAttribute(i).Name,~,~] = matlab.io.hdf4.sd.attrInfo(sdID,i-1);
                [fileAttribute(i).Value] = matlab.io.hdf4.sd.readAttr(sdID,i-1);
            end
        end
    end
end

% HDF-EOS files are typically "hybrid", meaning they contain HDF-EOS and
% HDF data objects.  It is impossible to distinguish the additional HDF
% objects that may be in an HDF-EOS file from HDF-EOS object.  The only way
% to read these is to look at the entire file as an HDF file.
if strcmp(mode,'eos')
    if gdID ~= -1
        grid = GridInfo(filename,gdID);
    else
        grid = [];
    end
    
    if swID ~= -1
        swath = SwathInfo(filename,swID);
    else
        swath = [];
    end
    
    if ptID ~= -1
        point = PointInfo(filename,ptID);
    else
        point = [];
    end
else
    %Get Vgroup structures
    if vstatus ~= -1
        [Vgroup,children] = VgroupInfo(filename,fileID,sdID,anID);
    else
        Vgroup = [];
        children = [];
    end
    
    %Get SDS structures
    if sdID ~= -1
        Sds = SdsInfo(filename,sdID,anID,children);
    else
        Sds = [];
    end
    
    %Get Vdata structures
    if vstatus ~= -1
        vdinfo = VdataInfo(filename,fileID,anID);
    else
        vdinfo = [];
    end
    
    %Get 8-bit image structures
    raster8 = Raster8Info(filename,children,anID);
    
    %Get 24-bit image structures
    raster24 = Raster24Info(filename,children,anID);
    
    %Get file annotations
    if anID ~= -1
        [label, desc] = annotationInfo(anID);
    else
        label = {};
        desc = {};
    end
end

%Populate output structure
hinfo.Filename = filename;
if strcmp(mode,'eos')
    if ~isempty(point)
        hinfo.Point = point;
    end
    if ~isempty(grid)
        hinfo.Grid = grid;
    end
    if ~isempty(swath)
        hinfo.Swath = swath;
    end
else
    if ~isempty(fileAttribute)
        hinfo.Attributes = fileAttribute;
    end
    if ~isempty(Vgroup)
        hinfo.Vgroup = Vgroup;
    end
    if ~isempty(Sds)
        hinfo.SDS = Sds;
    end
    if ~isempty(vdinfo)
        hinfo.Vdata = vdinfo;
    end
    if ~isempty(raster8)
        hinfo.Raster8 = raster8;
    end
    if ~isempty(raster24)
        hinfo.Raster24 = raster24;
    end
    if ~isempty(label)
        hinfo.Label = label;
    end
    if ~isempty(desc)
        hinfo.Description = desc;
    end
end

%Close interfaces
if strcmp(mode,'hdf')
    if sdID ~= -1
        matlab.io.hdf4.sd.close(sdID);
    end
    if vstatus ~= -1
        status = hdfv('end',fileID);
        hdfwarn(status)
    end
    if anID ~= -1
        status = hdfan('end',anID);
        hdfwarn(status)
    end
    if fileID ~= -1
        status = hdfh('close',fileID);
        hdfwarn(status)
    end
elseif strcmp(mode,'eos')
    if gdID ~= -1
        matlab.io.hdfeos.gd.close(gdID);
    end
    
    if swID ~= -1
        matlab.io.hdfeos.sw.close(swID);
    end
    if ptID ~= -1
        hdfpt('close',ptID);
    end
end

fileinfo = hinfo;


%===============================================================
function [filename_out, mode_out] = parseInputs(filename,varargin)

p = inputParser;
p.addRequired('filename', ...
    @(x)validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));
p.addOptional('mode','hdf', ...
    @(x)validateattributes(x,{'char'},{'nonempty'},'','MODE'));
p.parse(filename,varargin{:});

mode_out = validatestring(p.Results.mode,{'hdf','eos'});

%Get full path of the file
fid = fopen(filename);
if fid~=-1
    filename_out = fopen(fid);
    fclose(fid);
else
    error(message('MATLAB:imagesci:hdfinfo:fileNotFound'));
end

if ~hdfh('ishdf',filename_out)
  error(message('MATLAB:imagesci:hdfinfo:invalidFile', filename));
end


%================================================================
function [Vgroup, children] = VgroupInfo(filename,fileID,sdID,anID)
Vgroup = [];

%Find top level (lone) Vgroups
[~,maxsize] = hdfv('lone',fileID,0);
[refArray,maxsize] = hdfv('lone',fileID,maxsize);
hdfwarn(maxsize)

children.Tag = [];
children.Ref = [];
%Get Vgroup structures (including children)
for i=1:maxsize
    [Vgrouptemp, child] = hdfvgroupinfo(filename,refArray(i),fileID, sdID, anID);
    if ~isempty(Vgrouptemp.Filename)
        Vgroup = [Vgroup Vgrouptemp]; %#ok<AGROW>
    end
    if ~isempty(child.Tag)
        children.Tag = [children.Tag, child.Tag];
        children.Ref = [children.Ref, child.Ref];
    end
end
return;
%================================================================
function vdinfo = VdataInfo(filename,fileID,anID)
vdinfo = [];

[~, maxsize] = hdfvs('lone',fileID,0);
[refArray, maxsize] = hdfvs('lone',fileID,maxsize);
hdfwarn(maxsize)
for i=1:length(refArray)
    vdtemp = hdfvdatainfo(filename,fileID,anID,refArray(i));
    %Ignore Vdata's that are attributes
    %Ignore Vdata's that are Attr0.0 class, this is consistent with the
    %NCSA's Java HDF Viewer
	%
	% DimVal0.0 and DimVal0.1 signify SDS dimensions that are internally
	% represented as Vdatas.  They are more properly addressed through the
	% SD interface.
	%
	% SDSVar signifies that an SDS really is "the" SDS and not a coordinate
	% variable (which is also technically an SDS, confusingly enough).
    if ~(vdtemp.IsAttribute || strcmp(vdtemp.Class,'Attr0.0') ...
		|| strcmp(vdtemp.Class,'DimVal0.0') || strcmp(vdtemp.Class,'DimVal0.1') ...
		|| strcmp(vdtemp.Class,'SDSVar') )
        vdinfo = [vdinfo vdtemp]; %#ok<AGROW>
    end
end
return;

%================================================================
function Sds = SdsInfo(filename,sdID,anID,children)
%Initialize output to empty
Sds = [];

%Get number of data sets in file. SDS index is zero based
[ndatasets,~] = matlab.io.hdf4.sd.fileInfo(sdID);
for i=1:ndatasets
    sdsID = matlab.io.hdf4.sd.select(sdID,i-1);
    if sdID == -1
        warning(message('MATLAB:imagesci:hdfinfo:sdRetrieve'));
        return;
    end
    ref = matlab.io.hdf4.sd.idToRef(sdsID);
    matlab.io.hdf4.sd.endAccess(sdsID);
    %Don't add to hinfo structure if it is already part of a Vgroup
    %Assuming that the tag used for SDS is consistent for each file
    if ~(isused(hdfml('tagnum','DFTAG_NDG'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_SD'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_SDG'),ref,children) )
        [sds, IsScale] = hdfsdsinfo(filename,sdID,anID,i-1);
        %Ignore dimension scales
        if ~IsScale
            Sds =[Sds sds];     %#ok<AGROW>
        end
    end
end
return;
%================================================================
function raster8 = Raster8Info(filename,children,anID)
raster8 = [];

%Get number of 8-bit raster images
nimages = hdfdfr8('nimages',filename);

for i=1:nimages
    % It wouldn't seem like this call does anything, but it really does.
    [~, ~, ~] = hdfdfr8('getdims',filename);
    ref = hdfdfr8('lastref');
    rinfotemp = hdfraster8info(filename,ref,anID);
    if ~(isused(hdfml('tagnum','DFTAG_RIG'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_RI'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_CI'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_CI8'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_RI8'),ref,children))
        raster8 = [raster8 rinfotemp]; %#ok<AGROW>
    end
end

%Restart the DFR8 interface
status = hdfdfr8('restart');
hdfwarn(status)
return;

%================================================================
function raster24 = Raster24Info(filename,children,anID)
raster24 = [];
%Get number of 24-bit raster images
nimages = hdfdf24('nimages',filename);

for i=1:nimages
    % It wouldn't seem like this call does anything, but it really does.
    [~, ~, ~] = hdfdf24('getdims',filename);
    ref = hdfdf24('lastref');
    rinfotemp = hdfraster24info(filename,ref,anID);
    if ~(isused(hdfml('tagnum','DFTAG_RIG'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_RI'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_CI'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_CI8'),ref,children) || ...
            isused(hdfml('tagnum','DFTAG_RI8'),ref,children))
        raster24 = [raster24 rinfotemp]; %#ok<AGROW>
    end
end

%Restart the DF24 interface
status = hdfdf24('restart');
hdfwarn(status)
return;
%================================================================x
function pinfo = PointInfo(filename,fileID)
pinfo = [];

if ~has_eos_vgroup(filename,'POINT')
    return
end

[numPoints, pointListLong] = hdfpt('inqpoint',filename);
if numPoints>0
    pointList = parselist(pointListLong);
    pinfo = hdfpointinfo(filename,fileID,pointList{1});
    pinfo = repmat(pinfo,1,numPoints);
    for i = 2:numPoints
        pinfo(i) = hdfpointinfo(filename,fileID,pointList{i});
    end
end
return;


%================================================================x
function swinfo = SwathInfo(filename,fileID)
swinfo = [];

if ~has_eos_vgroup(filename,'SWATH')
    return
end

swaths = matlab.io.hdfeos.sw.inqSwath(filename);
numSwaths = length(swaths);
if numSwaths>0
    swinfo = hdfswathinfo(filename,fileID,swaths{1});
    swinfo = repmat(swinfo,1,numSwaths);
    for i=2:numSwaths
        swinfo(i) = hdfswathinfo(filename,fileID,swaths{i});
    end
end
return;

%================================================================x
function gdinfo = GridInfo(filename,fileID)
gdinfo = [];

if ~has_eos_vgroup(filename,'GRID')
    return
end

grids = matlab.io.hdfeos.gd.inqGrid(filename);
numGrids = length(grids);
if numGrids>0
    gdinfo = hdfgridinfo(filename,fileID,grids{1});
    gdinfo = repmat(gdinfo,1,numGrids);
    for i=2:numGrids
        gdinfo(i) = hdfgridinfo(filename,fileID,grids{i});
    end
end
return;

%================================================================
function [label,desc] = annotationInfo(anID)
% Retrieves annotations for the file.
label ={};
desc = {};

[numFileLabel,numFileDesc,~,~,status] = hdfan('fileinfo',anID);
hdfwarn(status)
if status==0
    if numFileLabel>0
        label = cell(1,numFileLabel);
        for i=1:numFileLabel
            FileLabelID = hdfan('select',anID,i-1,'file_label');
            hdfwarn(FileLabelID)
            if FileLabelID~=-1
                [label{i},status] = hdfan('readann',FileLabelID);
                hdfwarn(status)
                status = hdfan('endaccess',FileLabelID);
                hdfwarn(status)
            end
        end
    end
    if numFileDesc>0
        desc = cell(1,numFileDesc);
        for i=1:numFileDesc
            FileDescID = hdfan('select',anID,i-1,'file_desc');
            hdfwarn(FileDescID)
            if FileDescID~=-1
                [desc{i},status] = hdfan('readann',FileDescID);
                hdfwarn(status)
                status = hdfan('endaccess',FileDescID);
                hdfwarn(status)
            end
        end
    end
end
return;

%================================================================
function used = isused(tag,ref,used)
if isempty(used.Tag) && isempty(used.Ref)
    used = 0;
else
    tagIdx = find(used.Tag == tag, 1 );
    if isempty(tagIdx)
        used = 0;
    else
        refIdx = find(used.Ref == ref, 1);
        if isempty(refIdx)
            used = 0;
        else
            used = 1;
        end
    end
end




%--------------------------------------------------------------------------
function tf = has_eos_vgroup(filename, eos_class)
% This function uses the plain HDF interface to check supposed EOS files
% for the existance of EOS vgroup structures.  We do this because some
% tweaked HDF files can cause the HDF-EOS library to segfault.

tf = false;

fileID = hdfh('open',filename,'read',0);
hdfv('start',fileID);

% Just look at the top-level vgroups.
[~,maxsize] = hdfv('lone',fileID,0);
[refArray,maxsize] = hdfv('lone',fileID,maxsize);

for i=1:maxsize
    vgID = hdfv('attach',fileID, refArray(i), 'r');
    class = hdfv('getclass',vgID);
    if strcmp(class, eos_class)
        tf = true;
    end
    hdfv('detach',vgID);
end

hdfv('end',fileID);
hdfh('close',fileID);

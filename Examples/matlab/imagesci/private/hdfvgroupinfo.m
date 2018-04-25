function [vginfo, children] = hdfvgroupinfo(filename,dataset,fileID,sdID,anID)
%HDFVGROUPINFO Information about HDF Vgroup
%
%   VGINFO = HDFVGROUPINFO(FILENAME,DATASET) returns a structure whose
%   fields contain information about an HDF Vgroup.  FILENAME is a string
%   that specifies the name of the HDF file.   DATASET is a string
%   specifying the name of the Vgroup (?) or a number specifying the zero based
%   index of the data set.  FILEID is the file identifier returned by
%   hdfh('open',... and SDID is the sds identifier returned by
%   matlab.io.hdf4.sd.start(FILENAME,...
%
%   Assumptions: 
%               1.  The file has been open.  FILEID is a valid file
%                   identifier.
%               2.  The V, AN and SD interfaces have been started.
%               3.  anID may be -1.
%               4.  The V, AN and SD interface and file will be closed elsewhere.
% 
%   The fields of VGINFO depend on the contents of the file.
%
%   Possible fields of VGINFO are:
%
%   Filename  A string containing the name of the file
%		   
%   Name      A string containing the name of the data set
%
%   Class     A string containing the name of the class of the data set
%
%   Vgroup    An array of structures describing Vgroups
%
%   SDS       An array of structures describing Scientific Data sets
%
%   Vdata     An array of structures describing Vdata sets
%
%   Raster24  An array of structures describing 24-bit raster images  
%
%   Raster8   An array of structures describing 8-bit raster images
%
%   Type      A string describing the type of HDF object 
%
%   Tag       The tag number of this Vgroup
%
%   Ref       The reference number of this vgroup
%

%   Copyright 1984-2015 The MathWorks, Inc.


validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(dataset,{'double'},{'row'},'','DATASET');
validateattributes(fileID,{'numeric'},{'scalar'},'','FILEID');
validateattributes(sdID,{'numeric'},{'row'},'','SDID');
validateattributes(anID,{'numeric'},{'row'},'','ANID');

%Initialization
vginfo = struct('Filename',[],'Name',[],'Class',[],'Vgroup',[],'SDS',[],...
    'Vdata',[],'Raster24',[],'Raster8',[],'Tag',[],'Ref',[]);
vgroup = [];
sds = [];
raster8 = [];
raster24 = [];
vdata = [];
children.Tag = [];
children.Ref = [];

vgID = hdfv('attach',fileID,dataset,'r');
if vgID == -1
    warning(message('MATLAB:imagesci:hdfinfo:attachFailure',filename,dataset));
    return;
end

%Get the class of Vgroup.  Return early if it is a class that we ignore.
% There are two such classes, cdf0.0, rig0.0
[class, status] = hdfv('getclass',vgID);
hdfwarn(status)
if strcmpi(class,'cdf0.0') || strcmpi(class,'rig0.0')
    status = hdfv('detach',vgID);
    hdfwarn(status)
    return
end

%Get name of Vgroup
[~, name, status] = hdfv('inquire',vgID);
hdfwarn(status)

%Get child/tag reference pairs
childTags = [];
childRefs = [];
numChildren = hdfv('ntagrefs',vgID);
hdfwarn(numChildren)
if numChildren>0
    [childTags, childRefs, status] = hdfv('gettagrefs',vgID,numChildren);
    hdfwarn(status)
    children.Tag = childTags;
    children.Ref = childRefs;
end

%Close interfaces
status = hdfv('detach',vgID);
hdfwarn(status)

%Get children information.  Use same tag mapping as NCSA
for i=1:length(childTags)
    switch childTags(i)
        case {hdfml('tagnum','DFTAG_SD'),hdfml('tagnum','DFTAG_NDG'),hdfml('tagnum','DFTAG_SDG')}
            %Change reference number to index
            index = matlab.io.hdf4.sd.refToIndex(sdID,childRefs(i));
            hdfwarn(index)
            if index~=-1
                sds = [sds hdfsdsinfo(filename,sdID,anID,index)];  %#ok<AGROW>
            end
        case hdfml('tagnum','DFTAG_RI8')
            raster8 = [raster8 hdfraster8info(filename,childRefs(i),anID)]; %#ok<AGROW>
        case hdfml('tagnum','DFTAG_RI')
            raster24 = [raster24 hdfraster24info(filename,childRefs(i),anID)]; %#ok<AGROW>
        case hdfml('tagnum','DFTAG_RIG')
            raster24 = [raster24 hdfraster24info(filename,childRefs(i),anID)]; %#ok<AGROW>
        case {hdfml('tagnum','DFTAG_VS'),hdfml('tagnum','DFTAG_VH')}
            vtemp = hdfvdatainfo(filename,fileID,anID,childRefs(i));
            
            if ~(strcmp(vtemp.Class,'DimVal0.0') || strcmp(vtemp.Class,'DimVal0.1') ...
                    || strcmp(vtemp.Class,'SDSVar') )
                vdata = [vdata vtemp]; %#ok<AGROW>
            end

        case hdfml('tagnum','DFTAG_VG')
            [vgrouptemp, child] = hdfvgroupinfo(filename,childRefs(i),fileID,sdID,anID);
            vgroup = [vgroup vgrouptemp]; %#ok<AGROW>
            if ~isempty(child.Tag)
                children.Tag = [children.Tag child.Tag];
                children.Ref = [children.Ref child.Ref];
            end
        otherwise
            warning(message('MATLAB:imagesci:hdfinfo:unknownVgroup', childTags( i )));
    end
end

%Populate output structure
vginfo.Filename = filename;
vginfo.Name = name;
vginfo.Class = class;
if ~isempty(vgroup)
    vginfo.Vgroup = vgroup;
end
if ~isempty(sds)
    vginfo.SDS = sds;
end
if ~isempty(vdata)
    vginfo.Vdata = vdata;
end
if ~isempty(raster24)
    vginfo.Raster24 = raster24;
end
if ~isempty(raster8)
    vginfo.Raster8 = raster8;
end
vginfo.Tag = hdfml('tagnum','DFTAG_VG');
vginfo.Ref = dataset;
vginfo.Type = 'Vgroup';
return;






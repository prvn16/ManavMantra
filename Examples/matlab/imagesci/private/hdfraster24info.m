function raster = hdfraster24info(filename, imid, anID)
%HDFRASTER8INFO Information about HDF 24-bit Raster image
%
%   RINFO=RASTER8INFO(FILENAME,IMID) returns a structure whose fields contain
%   information about an 24-bit raster image in an HDF file.  FILENAME
%   is a string that specifies the name of the HDF file.  IMID is a string
%   specifying the name of the raster image or a number specifying the
%   image's reference number.  
%
%   The fields of RINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the image
%
%   Width          An integer indicating the width of the image
%                  in pixels
%
%   Height         An integer indicating the height of the image
%                  in pixels
%
%   Interlace      A string describing the interlace mode of the image
%
%   Ref            Reference number of the raster image
%  
%   Label          A cell array containing an Annotation label
%	       
%   Description    A cell array containing an Annotation description

%   Type           A string describing the type of HDF object 
%

%   Copyright 1984-2013 The MathWorks, Inc.

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(imid,{'numeric'},{'scalar'},'','imID');
validateattributes(anID,{'numeric'},{'row'},'','anID');

assert ( hdfh('ishdf',filename), ...
    message('MATLAB:imagesci:hdfinfo:invalidFile',filename));


%Get image information
tag =hdfml('tagnum','DFTAG_RI');
status = hdfdf24('readref',filename,imid);
if status == -1
    warning(message('MATLAB:imagesci:hdfinfo:readref'));
    raster = [];
else
    [width, height, interlace, status] = hdfdf24('getdims',filename);
    hdfwarn(status);
    
    [label, desc] = hdfannotationinfo(anID,tag,imid);
    
    % Use reference number to name the image: "24-bit Raster Image #refnum".
    % Other browsers use the first data label as the name if it exists.
    name = getString(message('MATLAB:imagesci:hdfinfo:refNum',24,imid));
    
    %Populate output structure
    raster.Filename = filename;
    raster.Name = name;
    raster.Tag = tag;
    raster.Ref = imid;
    raster.Width = width;
    raster.Height = height;
    raster.Interlace = interlace;
    raster.Label = label;
    raster.Description = desc;
    raster.Type = '24-Bit Raster Image';
end

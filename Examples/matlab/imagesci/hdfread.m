function varargout = hdfread(varargin)
%HDFREAD extract data from HDF file
%   
%   HDFREAD reads data from a data set in an HDF or HDF-EOS file.  If the
%   name of the data set is known, then HDFREAD searches the file for the
%   data.  Otherwise, use HDFINFO to obtain a structure describing the
%   contents of the file. The fields of the structure returned by HDFINFO are
%   structures describing the data sets contained in the file.  A structure
%   describing a data set may be extracted and passed directly to HDFREAD.
%   These options are described in detail below.
%   
%   DATA = HDFREAD(FILENAME,DATASETNAME) returns in the variable DATA all 
%   data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   [DATA,MAP] = HDFREAD(...) returns the image data and the colormap for an
%   8-bit raster image.
%   
%   DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2,VALUE2...) subsets the
%   data according to the string PARAMETER which specifies the type of
%   subsetting, and the values VALUE.  The table below outlines the valid
%   subsetting parameters for each type of data set.  Parameters marked as
%   "required" must be used to read data stored in that type of data set.
%   Parameters marked "exclusive" may not be used with any other subsetting
%   parameter, except any required parameters.  When a parameter requires
%   multiple values, the values must be stored in a cell array.  Note that
%   the number of values for a parameter may vary for the type of data set.
%   These differences are mentioned in the description of the parameter.
%
%   DATA = HDFREAD(FILENAME,EOSNAME,PARAMETER,VALUE,PARAMETER2,VALUE2...) 
%   subsets the data field from the HDF-EOS point, grid, or swath specified 
%   by EOSNAME.  
%
%   Table of available subsetting parameters
%
%
%           Data Set          |   Subsetting Parameters
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'  (exclusive)
%                             |   'Box'            (exclusive)
%                             |   'Time'           (exclusive)
%
%    There are no subsetting parameters for Raster Images
%
%
%   Valid parameters and their values are:
%
%   'Index' 
%
%     Three-element cell array {START,STRIDE,EDGE}, specifying the location
%     of the data to be read from the data set.  START, STRIDE and EDGE
%     must be arrays the same size as the number of dimensions.  START
%     specifies the location in the data set to begin reading.  Each number
%     in START must be smaller than its corresponding dimension.  STRIDE is
%     an array specifying the interval between the values to read.  EDGE is
%     an array specifying the length of each dimension to read.  The region
%     specified by START, STRIDE and EDGE must be within the dimensions of
%     the data set.  If either START, STRIDE, or EDGE is empty, then
%     default values are calculated assuming: starting at the first element
%     of each dimension, a stride of one, and EDGE to read the from the
%     starting point to the end of the dimension.  The defaults are all
%     ones for START and STRIDE, and EDGE is an array containing the
%     lengths of the corresponding dimensions.  START,STRIDE and EDGE are
%     one based.
%
%   'Fields'
%
%      Text string or cell array specifying the names of the fields to be
%      read.  For Grid and Swath data sets, only one field may be
%      specified.
%
%   'Box'
%
%     For Grid or Point data sets, Box is a two-element cell array, 
%     {LON, LAT}, specifying the longitude and latitude coordinates that
%     define a region.  LON and LAT are each two-element vectors specifying
%     the opposite corners of the box.  For Swath data sets, Box is a
%     three-element cell array {LON,LAT,MODE}, where MODE defines the
%     criterion for the inclusion of a cross track in a region. The cross
%     track in within a region if its midpoint is within the box, either
%     endpoint is within the box or any point is within the box. Therefore
%     MODE can have values of 'midpoint', 'endpoint', or 'anypoint'.
%
%   'Time'
%
%     For Grid or Point data sets, Time is a two-element cell array,
%     {STARTTIME,STOPTIME} where STARTTIME and STOPTIME specify a period of
%     time.  For Swath data sets, Time is a three-element cell array,
%     {STARTTIME,STOPTIME,MODE}, where  MODE defines the criterion for the
%     inclusion of a cross track in a region. The cross track in within a
%     region if its midpoint is within the box, or if either endpoint is
%     within the box.  Therefore MODE can have values of 'midpoint' or
%     'endpoint'.
%
%   'Vertical'
%
%     Two-element cell array, {DIMENSION, RANGE}, where RANGE is a vector
%     specifying the min and max range for the subset, and DIMENSION is the
%     name of the field or dimension to subset by.  If DIMENSION is a
%     dimension, then the RANGE specifies the range of elements to extract
%     (1 based).  If DIMENSION is the field, then RANGE specifies the range
%     of values to extract. Vertical subsetting may be used in conjunction
%     with 'Box' and/or 'Time'.  To subset a region along multiple
%     dimensions, vertical subsetting may be used up to 8 times in one call
%     to HDFREAD.
%
%   'Pixels'
%
%     Two-element cell array {LON, LAT}, where LON and LAT are numbers
%     that specify opposite corners of a latitude/longitude region.  The
%     longitude/latitude region will be converted into pixel rows and
%     columns with the origin in the upper left-hand corner of the grid.
%     This is the pixel equivalent of reading a 'Box' region.
%
%   'RecordNumbers'
%
%     A one-based vector specifying the record numbers to read. 
%
%   'Level'
%   
%     A string representing the name of the level to read or a one
%     based number specifying the index of the level to read from an
%     HDF-EOS Point data set.
%
%   'NumRecords'
%
%     A number specifying the total number of records to read.
%
%   'FirstRecord'
%
%     A one-based number specifying the first record from which to begin
%     reading.
%
%   'Tile'
%
%     A vector specifying the tile coordinates to read.  The elements are
%     one-based numbers.
%
%   'Interpolate'
%
%     Two-element cell array {LON, LAT}, where LON and LAT are vectors
%     specifying points for bilinear interpolation.
%
%    Example:  Read data set named 'Example SDS'.
%        data1 = hdfread('example.hdf','Example SDS');
%
%    Example:  Read data from HDF-EOS global grid field 'TbOceanRain'.
%        data = hdfread('example.hdf','MonthlyRain','Fields','TbOceanRain');
%      
%    Example:  Read data for the northern hemisphere for the same field.
%        data = hdfread('example.hdf','MonthlyRain', ...
%                       'Fields','TbOceanRain', ...
%                       'Box', {[0 360], [0 90]});
%
%    Example:  Retrieve info about example.hdf.
%        fileinfo = hdfinfo('example.hdf');
%        %  Retrieve info about Scientific Data Set in example.hdf
%        data_set_info = fileinfo.SDS;
%        %  Check the size
%        data_set_info.Dims.Size
%        % Read a subset of the data using info structure
%        data2 = hdfread(data_set_info, 'Index',{[3 3],[],[10 2 ]});
%
%    Example:  Access data in Fields of Vdata.
%        s = hdfinfo('example.hdf') 
%        data3 = hdfread(s.Vdata, 'Fields', {'Idx', 'Temp', 'Dewpt'}) 
%        data3{1} 
%        data3{2} 
%        data3{3}
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDFTOOL, HDFINFO, HDF.  
  
%   Copyright 1984-2013 The MathWorks, Inc.

varargout{1} = [];

[hinfo,params] = dataSetInfo(varargin{:});

if isempty(hinfo)
  error(message('MATLAB:imagesci:hdfread:noDataSets'));
end

if strcmp(hinfo.Type,'Obsolete')
    [varargout{1},varargout{2},varargout{3}] = obsoletehdfread(hinfo.Filename,hinfo.TagRef);
    return
end

switch hinfo.Type
    case 'Scientific Data Set'
        varargout{1} = hdfsdsread(hinfo,params);
    case 'Vdata set'
        varargout{1} = hdfvdataread(hinfo,params);
    case '8-Bit Raster Image'
        [varargout{1},varargout{2}] = hdfraster8read(hinfo);
    case '24-Bit Raster Image'
        varargout{1} = hdfraster24read(hinfo);
        %From here on, all read functions will parse the subsetting parameters
    case  'HDF-EOS Grid'
        varargout{1} = hdfgridread(hinfo,params);
    case  'HDF-EOS Swath'
        varargout{1} = hdfswathread(hinfo,params);
    case  'HDF-EOS Point'
        varargout{1} = hdfpointread(hinfo,params);
    case 'Vgroup'
        error(message('MATLAB:imagesci:hdfread:specificDataset'));
    otherwise
        error(message('MATLAB:imagesci:hdfread:datatype',hinfo.Type));
end
return;

%--------------------------------------------------------------------------
function parms = parseInput(subsets)
%PARSESUBSETS 
%  Parse some of the subsetting param/value pairs. Values for parameters
%  that are required for data sets are extracted from the variable list of
%  subsetting parameters. This routine will error if the input parameters
%  are not consistent with the param/value syntax described in the help for
%  HDFREAD.

%Return empty structures if not assigned on the command line

p = inputParser;

% {[START],[STRIDE],[EDGE]} where START is one-based.  COUNT should not
% have any zeros.
p.addParamValue('Index',[],...
    @(x)iscell(x) && (numel(x) ==3) && all(x{1} > 0) && all(x{2} > 0) && all(x{3} > 0));
p.addParamValue('Fields','',...
    @(x)ischar(x) || iscellstr(x));
p.addParamValue('NumRecords',[], ...
    @(x)(isscalar(x) && ((iscell(x) && isscalar(x{1})) || isa(x,'double'))));
p.addParamValue('FirstRecord',[],...
    @(x)isnumeric(x) && isscalar(x) && (x>0));
p.addParamValue('Level',[], ...
    @(x)(ischar(x) && ~isempty(x)) || (isnumeric(x) && isscalar(x) && (x>0)));
p.addParamValue('Tile',[],...
    @(x)isnumeric(x) && ~any(x<1));
p.addParamValue('Pixels',[],...
    @(x)iscell(x) && (numel(x) == 2));
p.addParamValue('Interpolate',[],...
    @(x)iscell(x) && (numel(x) == 2));
p.addParamValue('Box',[],...
    @(x)iscell(x) && ((numel(x) == 2) || (numel(x) == 3)));
p.addParamValue('Time',[],...
    @(x)iscell(x) && ((numel(x) == 2) || (numel(x) == 3)));
p.addParamValue('RecordNumbers',[],...
    @(x)(iscell(x) && (numel(x) == 1)) || (isnumeric(x)));
p.addParamValue('Vertical',[],...
    @(x)iscell(x));
p.addParamValue('Extmode','internal',...
    @(x)ischar(x));
p.parse(subsets{:});

parms = p.Results;


if ~isempty(parms.Fields)
    if iscellstr(parms.Fields)
        fields = parms.Fields;
        fields = sprintf('%s,',fields{:});
        parms.Fields = fields(1:end-1);
    end
end
if ~isempty(parms.NumRecords) 
    if iscell(parms.NumRecords)
        parms.NumRecords = parms.NumRecords{1};
    end
end

% Restrict to first record number.
if ~isempty(parms.RecordNumbers) && iscell(parms.RecordNumbers)
    parms.RecordNumbers = parms.RecordNumbers{:};
end

% The input parser actually cannot handle multiple cases of 'vertical',
% which are legal.  They have been validated, however, so loop back thru
% and pick them up.
idx = [];
for j = 1:2:numel(subsets)
    if strcmpi(subsets{j},'vertical')
        idx(end+1) = j+1; %#ok<AGROW>
    end
end
vertical = cell(numel(idx),1);
for j = 1:numel(idx)
    vertical{j} = subsets{idx(j)};
end
parms.Vertical = vertical;
return;
    
%=================================================================
function [hinfo,params] = dataSetInfo(varargin)
%DATASETINFO Return info structure for data set and subset param/value pairs
%
%  Distinguish between DATA = HDFREAD(FILENAME,DATASETNAME) and 
%  DATA = HDFREAD(HINFO)

if nargin<1
    error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end

validateattributes(varargin{1},{'char','struct'},{'nonempty'});

if ischar(varargin{1}) %HDFREAD(FILENAME,DATASETNAME...)

  narginchk(2,inf);

    
  filename = varargin{1};
  %Get full filename
  fid = fopen(filename);
  if fid ~= -1
    filename = fopen(fid);
    fclose(fid);
  else
    error(message('MATLAB:imagesci:validate:fileOpen',filename));
  end

  %Use HX interface in case data is in external files
  hdf('HX', 'setdir', fileparts(filename));
  if ischar(varargin{2})
    dataname = varargin{2};
    params = parseInput(varargin(3:end));
    hinfo = hdfquickinfo(filename,dataname,params);
  elseif isnumeric(varargin{2}) %Obsolete syntax
    params = [];
    hinfo.Filename = filename;
    hinfo.TagRef = varargin{2};
    hinfo.Type = 'Obsolete';
    warning(message('MATLAB:imagesci:hdfread:obsoleteUsage'));
  else
    error(message('MATLAB:imagesci:hdfread:invalidDatasetName')); %Invalid input
  end

elseif isstruct(varargin{1}) %HDFREAD(HINFO,...)

  hinfo = varargin{1};
  if (numel(hinfo) > 1) || ~isfield(hinfo,'Type')
      error(message('MATLAB:imagesci:hdfread:badStruct'));
  end

  params = parseInput(varargin(2:end));

end
return;

%=================================================================
function [first, second, third]=obsoletehdfread( filename, tagref )
%HDFREAD Read data from HDF file.
%   Note: HDFREAD has been grandfathered; use IMREAD instead.
%
%   I=HDFREAD('filename', [GROUPTAG GROUPREF]) reads a binary
%   or intensity image from an HDF file.  
%
%   [X,MAP]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   indexed image and its colormap (if available) from an HDF file.
%
%   [R,G,B]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   RGB image from an HDF file.
%
%   Use the HDFPEEK function to inspect the file for group tags,
%      reference numbers, and image types.  Example:
%      [tagref,name,info] = hdfpeek('brain.hdf');
%      for i=1:size(tagref,1), 
%        if info(i)==8,
%          [X,map] = hdfread('brain.hdf',tagref(i,:)); imshow(X,map)
%        end
%      end
%
%   See also IMFINFO, IMREAD, IMWRITE.


validateattributes(filename,{'char'},{'row'},'hdfread','filename');
validateattributes(tagref,{'numeric'},{'row'},'hdfread','tagref');

first = [];
second = [];
third = [];

[X,map] = imread(filename,'hdf',tagref(2));

if isempty(map) 
    sizeX = size(X);
    if ndims(X)==3 && sizeX(3)==3   % RGB Image
        first = double(X(:,:,1))/255;
        second = double(X(:,:,2))/255;
        third = double(X(:,:,3))/255;
    elseif ismatrix(X)              % Grayscale Intensity image
        first = double(X)/255;
    end
else                                % Indexed Image
    first = double(X)+1;
    second = map;
end













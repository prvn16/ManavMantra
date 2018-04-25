function writej2c(data, map, filename, varargin)
%WRITEJ2C Write a JPEG 2000 file to disk.
%   WRITEJ2C(I,[],FILENAME) writes the grayscale image I
%   to the file specified by the string FILENAME.
%
%   WRITEJ2C(...,'CompressionRatio', VAL) uses VAL as the compression ratio.
%
%   WRITEJ2C(...,'Mode',VAL) uses VAL as the compression mode.
%   MODE must be either 'lossy' or 'lossless'. The default value of MODE is
%   'lossy'. 
%
%   WRITEJ2C(...,'ProgressionOrder',PO) uses PO as the progression order.
%   Progression order must be a string that is one of 'LRCP', 'RLCP',
%   'RPCL', 'PCRL' or 'CPRL'. The default is 'LRCP'. 
%
%   WRITEJ2C(...,'QualityLayers',VAL) uses VAL as the number of quality
%   layers. Default value is 1.
%
%   WRITEJ2C(...,'ReductionLevels',VAL) uses VAL as the number of reduction
%   levels. Default is determined automatically.
%
%   WRITEJ2C(...,'TileSize', TS) uses TS as the tile size. Tile size is a
%   2-element vector specifying tile height and tile width. Default value
%   is [512 512]. 
%
%   See also IMWRITE.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(filename,{'char'},{'nonempty'},'','FILENAME');
validateattributes(data,{'logical','int8','uint8','int16','uint16','double','single'},{'nonempty'},'','DATA');
writejp2k(data, map, filename, 'j2c', varargin{:});

return



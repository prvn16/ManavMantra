function writejp2(data, map, filename, varargin)
%WRITEJP2 Write a JPEG 2000 file to disk.
%   WRITEJP2(I,[],FILENAME) writes the grayscale image I
%   to the file specified by the string FILENAME.
%
%   WRITEJP2(...,'CompressionRatio', VAL) uses VAL as the compression ratio.
%
%   WRITEJP2(...,'Mode',VAL) uses VAL as the compression mode.
%   MODE must be either 'lossy' or 'lossless'. The default value of MODE is
%   'lossy'. 
%
%   WRITEJP2(...,'ProgressionOrder',PO) uses PO as the progression order.
%   Progression order must be a string that is one of 'LRCP', 'RLCP',
%   'RPCL', 'PCRL' or 'CPRL'. The default is 'LRCP'. 
%
%   WRITEJP2(...,'QualityLayers',VAL) uses VAL as the number of quality
%   layers. Default value is 1.
%
%   WRITEJP2(...,'ReductionLevels',VAL) uses VAL as the number of reduction
%   levels. Default is determined automatically.
%
%   WRITEJP2(...,'TileSize', TS) uses TS as the tile size. Tile size is a
%   2-element vector specifying tile height and tile width. Default value
%   is [128 128]. 
%
%   See also IMWRITE.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(filename,{'char'},{'nonempty'},'','FILENAME');
validateattributes(data,{'logical','int8','uint8','int16','uint16','double','single'},{'nonempty'},'','DATA');
writejp2k(data, map, filename, 'jp2', varargin{:});

return

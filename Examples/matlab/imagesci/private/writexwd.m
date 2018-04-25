function writexwd(X,map,fname)
%WRITEXWD  Write a XWD (X window dump) file to disk.
%   WRITEXWD(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.

%   Drea Thomas, 7-20-93.
%   Revised Steven L. Eddins, June 1996.
%   Copyright 1984-2013 The MathWorks, Inc.

validateattributes(X,{'numeric'},{'2d'},'','X');
validateattributes(map,{'numeric'},{'nonempty'},'','map');

%open the file with big endian format
fid = fopen(fname,'W','b');
assert(fid~=-1, message('MATLAB:imagesci:imwrite:fileOpen',fname));

[a,b] = size(X);
c = size(map, 1);
header = [ 101+length(fname)  % Length of header
          7                   % file_version
          2                   % Image format 2 == ZPixmap
          8                   % Image depth
          b                   % Image width
          a                   % Image height
          0                   % Image x ofset
          1                   % MSB first (byte order)
          8                   % Bitmap unit
          1                   % MSB first (bit order)
          8                   % Bitmap scanline pad
          8                   % Bits per pixel
          b                   % Bytes per scanline
          3                   % Visual class (pseudocolor)
          0                   % Z red mask (not used)
          0                   % Z green mask (not used)
          0                   % Z blue mask (not used)
          8                   % Bits per logical pixel
          c                   % Length of colormap
          c                   % Number of colors
          b                   % Window width
          a                   % Window height
          0                   % Window upper left X coordinate
          0                   % Window upper left Y coordinate
          0 ];                % Window border width

fwrite(fid,header,'int32');
fwrite(fid,fname);
fwrite(fid,0);
fwrite(fid,[zeros(c,1) (0:(c-1))',map*65535,zeros(c,1)]','uint16');
if (isa(X, 'uint8'))
  fwrite(fid,X','uint8');
  fclose(fid);
else
  fwrite(fid,X'-1);
  fclose(fid);
end

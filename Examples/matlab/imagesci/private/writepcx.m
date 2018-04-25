function writepcx(X,map,fname)
%WRITEPCX Write a PCX file to disk.
%   WRITEPCX(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.

%   Drea Thomas, 7-20-93.
%   Revised Steven L. Eddins, June 1996.
%   Copyright 1984-2013 The MathWorks, Inc.

validateattributes(X,{'logical', 'uint8', 'double', 'single'},{'2d'},'','X');
validateattributes(map,{'numeric'},{'nonempty'},'','MAP');

m = size(map, 1);
if (m<256)
    map=[map;zeros(256-m,3)];
elseif (m>256)
    error(message('MATLAB:imagesci:writepcx:tooManyColormapEntries'));
end;

fid=fopen(fname,'W','l');
assert(fid~=-1, message('MATLAB:imagesci:imwrite:fileOpen',fname));

fwrite(fid,10,'uint8'); % PCX ID
fwrite(fid,5,'uint8');  % PCX Version #

nEncoding=1;
fwrite(fid,nEncoding,'uint8');
nBits=8;
fwrite(fid,nBits,'uint8');
nXmin=0;
fwrite(fid,nXmin,'int16');
nYmin=0;
fwrite(fid,nYmin,'int16');
[nVres,nHres]=size(X);
nXmax=nHres-1;
fwrite(fid,nXmax,'int16');
nYmax=nVres-1;
fwrite(fid,nYmax,'int16');
fwrite(fid,nHres,'int16');
fwrite(fid,nVres,'int16');
nHPalette=zeros(1,48);
fwrite(fid,nHPalette,'uint8');
nReserved=0;
fwrite(fid,nReserved,'uint8');
nPlanes=1;
fwrite(fid,nPlanes,'uint8');
nBytesPerLine=nHres;
fwrite(fid,nBytesPerLine,'int16');
nHPaletteInf=1;
fwrite(fid,nHPaletteInf,'int16');
nVidX=0;
fwrite(fid,nVidX,'int16');
nVidY=0;
fwrite(fid,nVidY,'int16');
nBlanks=zeros(1,54);
fwrite(fid,nBlanks,'uint8');
fclose(fid);

if isa(X,'logical')
    X = uint8(X);
elseif ~isa(X,'uint8')
    X = uint8(X-1);
end
pcxrle(fname, X');

fid = fopen(fname, 'A', 'l');

fwrite(fid,12,'uint8');
map=(map').*255;
map=round(map(:));
fwrite(fid,map,'uint8');
fclose(fid);

function writeras(data, map, filename, varargin)
%WRITERAS Write a RAS (Sun raster) file to disk.
%
%   WRITERAS(BM, [], FILENAME) writes the bitmap image BM to the file
%   specified by the string FILENAME.
%
%   WRITERAS(I, [], FILENAME) writes the grayscale image I to the file.
%
%   WRITERAS(RGB, [], FILENAME) writes the truecolor image represented by
%   the M-by-N-by-3 array RGB.
%
%   WRITERAS(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   WRITERAS(...,'Type',TYPE) writes an image file of the type indicated by
%   the string TYPE.  TYPE can be 'standard' (uncompressed, uses b-g-r color
%   order with RGB images), 'rgb' (like 'standard', but uses r-g-b color
%   order for RGB images) or 'rle' (run-length compression of 1 and 8 bit
%   images).
%
%   WRITERAS(...,'Alpha',ALPHA) adds the alpha (transparency) channel to
%   the image.  ALPHA must be a 2D matrix with the same number or rows
%   and columns as the image matrix.  Only allowed with RGB images.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   A complete official specification for the RAS (Sun Raster) image format
%   does not seem to have been made publicly available.  As sources for the
%   RAS image format I have used
%
%     * /usr/include/rasterfile.h of the Sun OS
%     * The rasterfile(4) man page of the Sun OS
%     * The files libpnm4.c, rasttopnm.c, and pnmtorast.c in the NetPBM 8.3
%       distribution
%     * "Inside SUN Rasterfile", a note by Jamie Zawinski
%      <jwz@teak.berkeley.edu> containing an excerpt from "Sun-Spots
%      Digest", Volume 6, Issue 84.

% Author:      Peter J. Acklam
% E-mail:      pjacklam@online.no

%  Copyright 2001-2013 The MathWorks, Inc.

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Some argument checking
   %

   validateattributes(data,{'double','single','logical','uint8','uint16'},{'real'},'','DATA');
   nd = ndims(data);
   if nd > 3
      error(message('MATLAB:imagesci:writeras:tooManyDims', nd));
   end

   validateattributes(map,{'double','single'},{'real'},'','MAP');


   [height, width, ncomp] = size(data);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Process param/value pairs
   %

   type  = 'standard';
   alpha = [];

   if rem(length(varargin), 2)
      error(message('MATLAB:imagesci:validate:badParamPair'));
   end

   for k = 1:2:length(varargin)

      param = lower(varargin{k});
      validateattributes(param,{'char'},{'nonempty'},'','PARAMETER NAME');
	  param = validatestring(param,{'type','alpha'});

      switch param

         case 'type'
            type = varargin{k+1};
      		validateattributes(type,{'char'},{'nonempty'},'','TYPE');
         	type = validatestring(type,{'standard','rgb','rle'});

         case 'alpha'
            alpha = varargin{k+1};
      		validateattributes(alpha,{'double','single','uint8','uint16'},{'2d'},'','ALPHA');

      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Figure out the bitdepth.
   %

   if islogical(data)
      bitdepth = 1;
   elseif ncomp == 3
      if isempty(alpha)
         bitdepth = 24;
      else
         bitdepth = 32;
      end
   else
      bitdepth = 8;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Bitmap RAS file.
   %

   if islogical(data)

      % First do some checking.
      if ~isempty(map) || ~isempty(alpha)
         error(message('MATLAB:imagesci:writeras:bitmapWithColormapAlpha'));
      elseif ncomp ~= 1
         error(message('MATLAB:imagesci:writeras:bitmapWith3dData'));
      end

      % Bitmaps have no color maps.
      maptype = 0;
      maplength = 0;

      % Add padding if necessary.
      paddedWidth = 16*ceil(width/16);
      if paddedWidth > width
         data(:,width+1:paddedWidth) = 0;
      end

      % Convert from ones and zeros to uint8 without converting to double.
      % Make sure data is uint8 and contains only zeros and ones.
      byteWidth = paddedWidth/8;
      bytedata = repmat(uint8(0), [height byteWidth]);
      for i = 1:8
         bytedata = bitor(bytedata, bitshift(uint8(data(:,i:8:end) == 0), 8-i));
      end
      bytedata = bytedata.';
      data = bytedata(:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Indexed RAS file.
   %

   elseif ~isempty(map)

      % First do some checking.
      if ~isempty(alpha)
         error(message('MATLAB:imagesci:writeras:indexedWithAlpha'));
      elseif ncomp ~= 1
         error(message('MATLAB:imagesci:writeras:indexedWith3dData'));
      end
      if size(map, 1) > 256
         error(message('MATLAB:imagesci:writeras:tooManyColormapEntries'));
      end

      % Clip colormap, round and convert to uint8.
      map = map(:);
      k = map > 1;
      if any(k)
         warning(message('MATLAB:imagesci:writeras:colormapClippedgt1'));
         map(k) = 1;
      end
      k = map < 0;
      if any(k)
         warning(message('MATLAB:imagesci:writeras:colormapClippedlt0'));
         map(k) = 0;
      end
      map = uint8(255*map);

      maptype = 1;
      maplength = length(map);

      % Check index matrix and make sure it is uint8.
      switch class(data)
         case {'double', 'single'}
            if any(data(:) < 1)
               error(message('MATLAB:imagesci:writeras:badIndexValues'));
            end
            if any(data(:) > maplength)
               error(message('MATLAB:imagesci:writeras:indexTooLarge'));
            end
            data = uint8(data-1);
         case 'uint8'
            % Nothing to do.
      end

      % Add padding if necessary.
      paddedWidth = 2*ceil(width/2);
      if width < paddedWidth
         data(:,width+1:paddedWidth) = 0;
      end

      data = data.';
      data = data(:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Grayscale (intensity) or RGB RAS file.
   %

   else

      % First do some checking.
      if (ncomp ~= 1) && (ncomp ~= 3)
         error(message('MATLAB:imagesci:writeras:wrongDims', ncomp));
      end

      % Grayscale and RGB images have no color maps.
      maptype = 0;
      maplength = 0;

      % Check image array and convert to uint8.
      switch class(data)
         case {'double', 'single'}
            % Clip values, round and convert to uint8.
            data = min(max(data, 0), 1);
            data = uint8(255*data);
         case 'uint8'
            % Nothing to do.
         case 'uint16'
            warning(message('MATLAB:imagesci:writeras:reducedTo8Bits'));
            %data = uint8(round(double(data)/257)); % 257 = (2^16-1)/(2^8-1)
            data = bitshift(data, -8);
      end

      % Check alpha channel and convert to uint8.
      if ~isempty(alpha)
         if ncomp == 1
            error(message('MATLAB:imagesci:writeras:grayscaleWithAlpha'));
         end
         if size(alpha,1) ~= size(data,1) || size(alpha,2) ~= size(data,2)
            error(message('MATLAB:imagesci:writeras:sizeOfAlpha'));
         end

         % Convert to uint8.
         switch class(alpha)
            case {'double', 'single'}
               % Clip values, round and convert to uint8.
               alpha = min(max(alpha, 0), 1);
               alpha = uint8(255*alpha);
               %alpha = alpha(:);
            case 'uint8'
               % Nothing to do.
            case 'uint16'
               warning(message('MATLAB:imagesci:writeras:reducedTo8Bits'));
               %alpha = uint8(round(double(A)/257)); % 257 = (2^16-1)/(2^8-1)
               alpha = bitshift(alpha, -8);
         end
      end

      % Default is blue-green-red color order.
      if (ncomp == 3) && ~strcmp(type, 'rgb')
         data = flip(data, 3);
      end

      % The alpha channel is the first channel.
      if ~isempty(alpha)
         data = cat(3, alpha, data);
      end

      byteWidth = size(data, 3)*width;
      paddedByteWidth = 2*ceil(byteWidth/2);

      data = permute(data, [3 2 1]);
      data = reshape(data, [byteWidth height]);
      if byteWidth < paddedByteWidth
         data(byteWidth+1:paddedByteWidth,:) = 0;
      end

      data = data(:);

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % RLE is only supported when bitdepth <= 8.
   %

   if strcmp(type, 'rle')
      if bitdepth <= 8
         data = raserle(data);
      else
         warning(message('MATLAB:imagesci:writeras:writingStandardNotRle', bitdepth));
         type = 'standard';
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Figure out some other values that are needed for the image header.
   %

   datalength = length(data);           % DATA should be a vector now
   switch type
      case 'standard', typeval = 1;
      case 'rle',      typeval = 2;
      case 'rgb',      typeval = 3;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Open image file and write image header.
   %

   fid = fopen(filename, 'W', 'ieee-be');
   assert(fid~=-1, message('MATLAB:imagesci:imwrite:fileOpen',filename));

   fwrite(fid, 1504078485, 'uint32');   % magic number: hex2dec('59A66A95')
   fwrite(fid, width,      'uint32');   % width (pixels) of image
   fwrite(fid, height,     'uint32');   % height (pixels) of image
   fwrite(fid, bitdepth,   'uint32');   % depth (1, 8, 24, or 32 bits) pr pixel
   fwrite(fid, datalength, 'uint32');   % length (bytes) of image
   fwrite(fid, typeval,    'uint32');   % type of file; see READRAS for details
   fwrite(fid, maptype,    'uint32');   % type of colormap; see READRAS for details
   fwrite(fid, maplength,  'uint32');   % length (bytes) of following map

   if sscanf(version, '%g', 1) < 6
      data = double(data);
      map = double(map);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the colormap.
   %

   if ~isempty(map)
      fwrite(fid, map, 'uint8');
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image data.
   %

   fwrite(fid, data, 'uint8');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Close the file.
   %

   fclose(fid);

%%%
%%% raserle --- RLE encode RAS data.
%%%
function Xrle = raserle(X)
%RASERLE Perform RAS RLE encoding.
%   XRLE = RASERLE(X) performs RLE-compression on X and returns the RLE
%   data.

   decoded_length = length(X);

   % Initialize output vector.  Add one since a single value of 128 is
   % encoded as [ 128 0 ] (only case when encoded data is longer than
   % decoded data).
   Xrle = repmat(uint8(0), decoded_length+1, 1);

   % RAS RLE Encoding:
   %
   % verbatim:  VAL                  (if VAL not 128)
   %            128   0              (if VAL is 128)
   % rle:       128 COUNT VAL

   i = 1;         % Index into X vector.
   j = 1;         % Index into XRLE vector.

   while i <= decoded_length

      if   ( i+1 <= decoded_length ) && ( X(i) == X(i+1) ) ...
         && (   ( i+2 <= decoded_length ) && ( X(i+1) == X(i+2) ) ...
             || ( X(i) == 128 ) )
         len = 1;
         while   ( len <= 255 ) && ( i+len <= decoded_length ) ...
               && ( X(i) == X(i+len) )
            len = len + 1;
         end
         Xrle(j)   = 128;
         Xrle(j+1) = len - 1;
         Xrle(j+2) = X(i);
         j = j + 3;
         i = i + len;
      else
         while 1
            Xrle(j) = X(i);
            i = i + 1;
            if Xrle(j) == 128
               Xrle(j+1) = 0;
               j = j + 2;
            else
               j = j + 1;
            end
            if ( i+1 > decoded_length ) || ( X(i) == X(i+1) )
               break
            end
         end
      end

   end

   Xrle = Xrle(1:j-1);

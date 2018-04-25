function writepnm(data, map, filename, varargin)
%WRITEPNM Write a PPM/PGM/PBM file to disk.
%
%   WRITEPNM(BM, [], FILENAME) writes the bitmap image BM to the file
%   specified by the string FILENAME.
%
%   WRITEPNM(I, [], FILENAME) writes the grayscale image I to the file.
%
%   WRITEPNM(RGB, [], FILENAME) writes the truecolor image represented by
%   the M-by-N-by-3 array RGB.
%
%   WRITEPNM(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   If the filename suffix is .PPM, .PGM, or .PBM, then it is the suffix,
%   not the image data, that determines what kind of image that will be
%   written.  For instance, if the suffix is .PGM, then a portable graymap
%   will be written regardless of the image data given and the input image
%   will be converted to grayscale if necessary.
%
%   If the filename suffix is .PNM, then file format and suffix will be
%   chosen automatically depending on the image data.
%
%   WRITEPNM(..., 'MaxValue', VALUE) may be used to write an image with a
%   different maximum pixel value than what is the default.  VALUE must be a
%   positive integer.  The default value is 255 except for uint16 images,
%   for which the default is 65535.  PBM images don't have a maximum pixel
%   value, so VALUE will be ignored for PBM images.
%
%   WRITEPNM(..., 'Encoding', ENCODING) may be used to specify the output
%   encoding.  ENCODING must be 'ASCII' for ASCII (plain) encoded
%   images and 'rawbits' for binary encoded images.  The default
%   encoding 'rawbits.'

% Author:      Peter J. Acklam
% E-mail:      pjacklam@online.no

%  Copyright 2001-2013 The MathWorks, Inc.

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Some argument checking

   validateattributes(data,{'logical', 'uint8', 'uint16', 'single', 'double'},{'nonempty'},'','DATA');
   if ndims(data) > 3
       error(message('MATLAB:imagesci:writepnm:tooManyDims', ndims(data)));
   end
   if (size(data,3) == 2) || (size(data,3) > 3)
       error(message('MATLAB:imagesci:writepnm:badNumberOfChannels', size(data,3)));
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Get format (PPM/PGM/PBM) from file name.

   [~, ~, suffix] = fileparts(filename);
   switch lower(suffix)
      case '.ppm', format = 'ppm';
      case '.pgm', format = 'pgm';
      case '.pbm', format = 'pbm';
      case '.pnm', format = 'pnm';
      otherwise
         error(message('MATLAB:imagesci:writepnm:badFileExtension', filename, suffix));
   end


   maxval = 255;
   if isa(data, 'uint16') 
      maxval = 65535;
   end

   p = inputParser;
   p.addParamValue('maxvalue',maxval, ...
       @(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',1},'','MAXVALUE'));
   p.addParamValue('encoding','raw', ...
       @(x) validateattributes(x,{'char'},{'nonempty'},'','ENCODING'));
   p.parse(varargin{:});

   maxval = double(p.Results.maxvalue);
   encoding = validatestring(p.Results.encoding,{'ascii','rawbits'});
   if strcmp(encoding,'ascii')
      encoding = 'plain';
   else
      encoding = 'raw';
   end

   if strcmp(encoding, 'raw') && maxval > 65535
      warning(message('MATLAB:imagesci:writepnm:usingPlainEncoding'));
      encoding = 'plain';
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Determine format automatically if necessary.
   %

   if strcmp(format, 'pnm')
      format = auto_determine_format(data, map, maxval);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Now call the appropriate subfunction depending on the format.
   %

   switch format
      case 'pbm'
         writepbm(data, map, filename, encoding);
      case 'pgm'
         writepgm(data, map, filename, encoding, maxval);
      case 'ppm'
         writeppm(data, map, filename, encoding, maxval);
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write PBM (portable bitmap) file.
%

function writepbm(data, map, filename, encoding)

   [height, width, channels] = size(data);

   rgbw = [ 0.298936 ; 0.587043 ; 0.114021 ];   % RGB weights

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert any image to a bitmap image.  Afterwards, `data' should be a
   % uint8 array of zeros (black) and ones (white).
   %

   if isempty(map)
      % no colormap, so it is not an indexed image

      if channels > 1
         % it is an rgb image

         % adjust rgb weights (to save work we convert from rgb image to
         % grayscale _and_ map pixel values to the set {0,1} all in one go)
         switch class(data)
            case 'uint8'  
               rgbw = rgbw / 255;
            case 'uint16' 
               rgbw = rgbw / 65535;
         end

         % convert to uint8 array of zeros and ones
         data = uint8(rgbw(1) * double(data(:,:,1)) + ...
                      rgbw(2) * double(data(:,:,2)) + ...
                      rgbw(3) * double(data(:,:,3)));

      else
         % It is a grayscale image or a bitmap image.  (Bitmaps don't need
         % any conversion.)

         if ~islogical(data)
            % it is a grayscale image

            % convert to zeros and ones by bitshifting or thresholding
            switch class(data)
               case 'uint8'  
                  data = bitshift(data, -7);
               case 'uint16' 
                  data = uint8(bitshift(data, -15));
               case {'double', 'single'} 
                  data = uint8(data >= 0.5);
            end

         end
      end
   else
      % it is an indexed image

      % convert colormap to a vector of ones and zeros by thresholding
      bwmap = uint8(map * rgbw >= 0.5);

      % get image data
      switch class(data)
      case {'double', 'single'}
          data = bwmap(data);
      case {'uint8', 'uint16'}
          data = bwmap(double(data)+1);
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert the bitmap image into a vector containing the integer values
   % that will be written to the image file.
   %

   % adjust values since PBM uses zeros for white and ones for black
   data = bitxor(data, 1);

   if strcmp(encoding, 'raw')

      % add padding if necessary
      byteWidth = ceil(width/8);        % number or bytes for one scanline
      paddedWidth = 8*byteWidth;        % padded width of image
      if paddedWidth > width
         data(:,width+1:paddedWidth) = 0;
      end

      % convert from bits (zeros and ones) to bytes {0,1,...,255} without
      % temporary conversion to double
      bytedata = repmat(uint8(0), [height byteWidth]);
      for i = 1:8
         bytedata = bitor(bytedata, bitshift(uint8(data(:,i:8:end)), 8-i));
      end
      data = bytedata;

   end

   % transpose (PPM/PGM/PBM images are written row major order) and reshape
   data = data.';
   data = data(:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image data to a file.
   %

   switch encoding
      case 'raw'
         write_raw_data(filename, 'pbm', data, height, width);
      case 'plain'
         write_plain_data(filename, 'pbm', data, height, width);
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write PGM (portable bitmap) file.
%
function writepgm(data, map, filename, encoding, maxval)

   [height, width, channels] = size(data);
   cls = class(data);

   rgbw = [ 0.298936 ; 0.587043 ; 0.114021 ];   % RGB weights

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert any image into a vector containing the integer values that will
   % be written to the image file.
   %

   if isempty(map)
      % no colormap, so it is not an indexed image

      if channels > 1
         % it is an rgb image

         % adjust rgb weights (to save work we convert from rgb image to
         % grayscale _and_ map pixel values to the set {0,1,...,maxval} all
         % in one go)
         switch cls
            case 'uint8',  rgbw = (maxval /   255) * rgbw;
            case 'uint16', rgbw = (maxval / 65535) * rgbw;
            case {'double', 'single'}, rgbw =  maxval          * rgbw;
         end

         % convert to grayscale and compute the output values
         data = round(   rgbw(1) * double(data(:,:,1)) ...
                       + rgbw(2) * double(data(:,:,2)) ...
                       + rgbw(3) * double(data(:,:,3)) );

      else
         % it is a grayscale image or a bitmap image

         if islogical(data)
            % It is a bitmap image.  Use the logical image as a mask, changing
            % true values to maxval.
            mask = data;

            if maxval <= 255
               data = uint8(data);
               data(mask) = maxval;
            elseif maxval <= 65535
               data = uint16(data);
               data(mask) = maxval;
            else
               data = double(data);
               data(mask) = maxval;
            end

         else
            % it is a grayscale image

            data = remap_pixel_values(data, maxval);

         end

      end
   else
      % it is an indexed image

      % convert the map to grayscale and at the same time adjust the map so
      % it contains the final pixel values (integers in the set
      % {0,1,...,maxval})

      graymap = round(map * (maxval * rgbw));
      if maxval <= 255
         graymap = uint8(graymap);
      elseif maxval <= 65535
         graymap = uint16(graymap);
      end
      switch cls
      case {'double', 'single'}
          data = graymap(data);
      case {'uint8', 'uint16'}
          data = graymap(double(data)+1);
      end

   end

   % transpose (PPM/PGM/PBM images are written row major order) and reshape
   data = data.';
   data = data(:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image data to a file.
   %

   switch encoding
      case 'raw'
         write_raw_data(filename, 'pgm', data, height, width, maxval);
      case 'plain'
         write_plain_data(filename, 'pgm', data, height, width, maxval);
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write PPM (portable pixelmap) file.
%
function writeppm(data, map, filename, encoding, maxval)

   [height, width, channels] = size(data);
   cls = class(data);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert any image into a vector containing the integer values that will
   % be written to the image file.
   %

   if isempty(map)
      % no colormap, so it is not an indexed image

      if channels > 1
         % it is an rgb image

         data = remap_pixel_values(data, maxval);

         % convert to vector
         data = permute(data, [3 2 1]);
         data = data(:);

      else
         % it is a grayscale image or a bitmap image

         if islogical(data)
            % it is a bitmap image
            mask = data;

            % let all non-zero values be maxval
            if maxval <= 255
               data = uint8(data);
               data(mask) = maxval;
            elseif maxval <= 65535
               data = uint16(data);
               data(mask) = maxval;
            else
               data = double(data);
               data(mask) = maxval;
            end

            % convert to vector (here is what the 5 lines are for: 1) remove
            % the logicalness 2) transpose since PPM/PGM/PBM are written row
            % major order 3) make a row with of the data for one color
            % component 4) duplicate since there are three color components
            % 5) convert to vector
            data = +data;
            data = data.';
            data = reshape(data, [1 height*width]);
            data = data(ones(1,3), :);
            data = data(:);

         else
            % it is a grayscale image

            switch cls
               case 'uint8'
                  % map from set {0,1,...,255} to set {0,1,...,maxval}
                  if maxval ~= 255
                     data = round((maxval / 255) * double(data));
                  end
               case 'uint16'
                  % map from set {0,1,...,65535} to set {0,1,...,maxval}
                  if maxval ~= 65535
                     data = round((maxval / 65535) * double(data));
                  end
               case {'double', 'single'}
                  % map from interval [0,1] to set {0,1,...,maxval}
                  if maxval ~= 1
                     data = maxval * data;
                  end
                  data = round(data);
            end

            % convert to vector (here is what the 4 lines are for: 1)
            % transpose since PPM/PGM/PBM are written row major order 2)
            % make a row with of the data for one color component 3)
            % duplicate since there are three color components 4) convert to
            % vector
            data = data.';
            data = reshape(data, [1 height*width]);
            data = data(ones(1,3), :);
            data = data(:);

         end

      end
   else
      % it is an indexed image

      % adjust the map so it contains the final pixel values (integers in
      % the set {0,1,...,maxval})

      map = round(map * maxval);
      if maxval <= 255
         map = uint8(map);
      elseif maxval <= 65535
         map = uint16(map);
      end

      % transpose (PPM/PGM/PBM images are written row major order)
      data = data.';

      switch cls
         case {'double', 'single'}
            data = map(data,:);
         case {'uint8', 'uint16'}
            data = map(double(data)+1,:);
      end

      % convert to vector (first transpose the height*width-by-3 data array
      % since all color components for one pixel is written before all the
      % color components for the next pixel)
      data = data.';
      data = data(:);

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image data to a file.
   %
   if strcmp(encoding,'raw')
      write_raw_data(filename, 'ppm', data, height, width, maxval);
   else
      write_plain_data(filename, 'ppm', data, height, width, maxval);
   end


%--------------------------------------------------------------------------
function write_raw_data(filename, format, data, height, width, maxval)

   validateattributes(data,{'numeric'},{'column'},'','DATA');

   % Open file for writing.  The PBM/PGM/PPM format doesn't allow multi-byte
   % values, but some extensions do allow this, and they use big-endian.
   fid = fopen(filename, 'W', 'ieee-be');
   assert(fid~=-1, message('MATLAB:imagesci:imwrite:fileOpen',filename));

   % Write the file header.
   switch format
      case 'pbm'
         fprintf(fid, 'P4 %d %d\n', width, height);
      case 'pgm'
         fprintf(fid, 'P5 %d %d %d\n', width, height, maxval);
      case 'ppm'
         fprintf(fid, 'P6 %d %d %d\n', width, height, maxval);
   end

   prec = 'uint8';
   if ~strcmp(format, 'pbm')
      if maxval > 255
         prec = 'uint16';
      end
      assert((maxval <= 65535), 'MAXVAL > 65535 requires ASCII encoding.');
   end

   % Write the image data to the file.
   count = fwrite(fid, data, prec);

   % Close the file.
   fclose(fid);

   % See if we succeeded in writing all data to the file.
   if count < length(data)
       error(message('MATLAB:imagesci:writepnm:writeFailed'));
   end

%--------------------------------------------------------------------------
function write_plain_data(filename, format, data, height, width, maxval)

   validateattributes(data,{'numeric','logical'},{'column'},'','DATA');

   % Open the file for writing.
   fid = fopen(filename, 'W');
   if (fid < 0)
       error(message('MATLAB:imagesci:imwrite:fileOpen', filename));
   end

   data = double(data);

   % Write the file header.
   switch format
      case 'pbm'
         fprintf(fid, 'P1 %d %d\n', width, height);
      case 'pgm'
         fprintf(fid, 'P2 %d %d %d\n', width, height, maxval);
      case 'ppm'
         fprintf(fid, 'P3 %d %d %d\n', width, height, maxval);
   end

   % Ascii encoded PPM/PGM/PBM files should not have more than 70 characters
   % on each line.  PBM uses 1 character for each pixel, but for PPM/PGM
   % compute the number of values `n' that will fit on a line (the longest
   % line will have `n' maxval values and `n-1' blanks separating them, so
   % if `w' is the width of a maxval, then the longest line will have `n*w +
   % (n-1)' characters (not including the newline), and `n*w + (n-1) <= 70'
   % is equivalent to `n <= 71/(w+1)')

   if strcmp(format, 'pbm')
      w = 1;
   else
      w = length(sprintf('%1.f', maxval));      % width of a maxval
   end

   n = floor(71/(w+1));                 % max number of values on a line
   fmt = [repmat('%1.f ', [1 n-1]), '%1.f\n'];  % build format string

   % Write the image data to the file.
   fprintf(fid, fmt, data(1:end-1));

   % The reason for writing the last value separately is not so much for
   % avoiding a trailing whitespace character in the file as it is to see if
   % we succeeded in writing the data to the file.
   count = fprintf(fid, '%1.f', data(end));

   % Close the file.
   fclose(fid);

   % See if we succeeded in writing all data to the file.
   if count == 0
        error(message('MATLAB:imagesci:writepnm:writeFailed'));
   end

%--------------------------------------------------------------------------
function format = auto_determine_format(data, map, maxval)
%AUTO_DETERMINE_FORMAT Automatically determine image format (PPM/PGM/PBM)

   [height, ~, channels] = size(data);

   % initialize image type variables (assume image is grayscale/bitmap until
   % proven otherwise)
   isgray = 1;
   isbm   = 1;

   % we don't want to compare the pixel values as they are in the array, but
   % as they will be in the file, so we need to scale them
   switch class(data)
      case {'double', 'single'}, scalefactor = maxval;
      case 'uint8',  scalefactor = maxval / 255;
      case 'uint16', scalefactor = maxval / 65535;
   end

   if isempty(map)
      % no colormap, so it is not an indexed image

      if channels > 1
         % it is an rgb image (but it might be a grayscale or black/white
         % image which happens to be stored as an rgb image)

         % to save memory, check one row at a time -- not the whole image
         for row = 1:height
            rowdata = round(scalefactor * double(data(row,:,:)));
            if (any(rowdata(1,:,1) ~= rowdata(1,:,2)) || ...
                any(rowdata(1,:,1) ~= rowdata(1,:,3)))
               % found differing pixel values, so image is neither graymap
               % nor bitmap
               isgray = 0;
               isbm   = 0;
               break
            end
            if isbm
               if any(rowdata(1,:,1) ~= 0 & rowdata(1,:,1) ~= maxval)
                  % found gray values (values that represent neither black
                  % nor white), so image is not a bitmap
                  isbm = 0;
               end
            end
         end

      else
         % it is a grayscale image or a bitmap image

         % no need to check the case when `data' is logical, since a bitmap
         % image matches the initial assumption
         if ~islogical(data)
            % it is a grayscale image (but it might be a black/white image
            % which happens to be stored as a grayscale image)

            % to save memory, check one row at a time -- not the whole image
            for row = 1:height
               rowdata = round(scalefactor * double(data(row,:)));
               if any(rowdata ~= 0 & rowdata ~= maxval)
                  isbm = 0;
                  break
               end
            end
         end
      end
   else
      % it is an indexed image (which might be a grayscale or black/white
      % image which happens to be stored as an indexed image)

      % certain index matrices use zero-based indexing which requires
      % adjustment of the index values
      switch class(data)
         case {'double', 'single'}
            adjustidx = 0;
         case {'uint8', 'uint16'}
            adjustidx = 1;
      end

      % to save memory, check one row at a time -- not the whole image
      for row = 1:height
         rowidx = double(data(row,:));  % indices for current row
         if adjustidx
            rowidx = rowidx + 1;
         end
         rowdata = round(maxval * map(rowidx,:));
         if (any(rowdata(:,1) ~= rowdata(:,2)) || ...
             any(rowdata(:,1) ~= rowdata(:,3)))
            % found differing pixel values, so image is neither graymap not
            % bitmap
            isgray = 0;
            isbm = 0;
            break
         end
         if isbm
            if any(rowdata(:,1) ~= 0 & rowdata(:,1) ~= maxval)
               % found gray values (values that represent neither black nor
               % white), so image is not a bitmap
               isbm = 0;
            end
         end
      end
   end

   if isgray
      if isbm
         format = 'pbm';
      else
         format = 'pgm';
      end
   else
      format = 'ppm';
   end

%--------------------------------------------------------------------------
function newdata = remap_pixel_values(data, maxval)
%REMAP_PIXEL_VALUES Remap pixel values in array of pixel values.
%
%   NEWDATA = REMAP_PIXEL_VALUES(DATA, MAXVAL) remaps the pixel values in
%   DATA as follows
%
%   Class of DATA   Input                    Output
%   -------------   -----                    ------
%   uint8           The set {0,1,...,255}    The set {0,1,...,maxval}
%   uint16          The set {0,1,...,65535}  The set {0,1,...,maxval}
%   double          The interval [0,1]       The set {0,1,...,maxval}
%
%   The remapping is done by bit manipulation if possible, otherwise the
%   remapping is done by scaling and rounding.

   cls = class(data);

   switch cls

       case 'uint8'
           % map from set {0,1,...,255} to set {0,1,...,maxval}
           switch maxval
               case {1, 3, 7, 15, 31, 63, 127}
                   % maxval = 2^n - 1
                   n = log2(maxval+1);
                   newdata = bitshift(data,-8+n);
                   
               case 255            % = 2^8 - 1
                   % do nothing
                   newdata = data;
                   
               case {511, 1023, 2047, 4095, 8191, 16383, 32767}
                   n = log2(maxval+1);
                   newdata = uint16(data);
                   newdata = bitor(bitshift(newdata, n-8), bitshift(newdata, -16+n));
                   
               case 65535          % = 2^16 - 1
                   newdata = uint16(data);
                   newdata = bitor(bitshift(newdata, 8), newdata);
               otherwise
                   newdata = round((maxval / 255) * double(data));
           end

       case 'uint16'
           % map from set {0,1,...,65535} to set {0,1,...,maxval}
           switch maxval
               case {1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, ...
                       4095, 8191, 16383, 32767}
                   % maxval = 2^n - 1
                   n = log2(maxval+1);
                   newdata = bitshift(data,-16+n);
                   
               case 65535          % = 2^16 - 1
                   % do nothing
                   newdata = data;
               otherwise
                   newdata = round((maxval / 65535) * double(data));
           end

      case {'double', 'single'}
         % map from interval [0,1] to set {0,1,...,maxval}
         if maxval == 1
            newdata = data;
         else
            newdata = maxval * data;
         end
         newdata = round(newdata);

   end

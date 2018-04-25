function info = imgifinfo(filename)
%IMGIFINFO Information about a GIF file.
%   INFO = IMGIFINFO(FILENAME) returns a structure containing
%   information about the GIF file specified by the string
%   FILENAME. 
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2015 The MathWorks, Inc.


% Open File Pointer
fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
cfid = onCleanup(@()fclose(fid));

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('gif', fid);

% Initialize other tags
info.FormatSignature = '';
info.BackgroundColor = [];
info.AspectRatio = [];
info.ColorTable = [];
info.Interlaced = [];

% Verify if GIF Image
sig = fread(fid, 3)';
assert(isequal(sig,[71 73 70]), ...
    message('MATLAB:imagesci:imfinfo:badFormat', filename, 'GIF'));
fseek(fid,0,'bof');

% Read in the Header and Logical Screen Descriptor.
% bytes 1-6:  the GIF header signature
% 2 uint16, bytes 7-10:  Screen size
% bytes 11-13:  logical screen descriptor
[buffer,count] = fread(fid,13,'uint8=>uint8');
if ( count ~= 13 ) 
    error(message('MATLAB:imagesci:imgifinfo:fileCorrupt', ...
        ferror(fid)));
end
GIFheader = buffer(1:6)';
LogicalScreenDescriptor = buffer(11:13);
PackedByte = LogicalScreenDescriptor(1);

% Read in the Global Color Table if required
GCTbool = bitget(PackedByte,8)==1;
if GCTbool
   sizeGCT = double(bitget(PackedByte,1:3));
   bitdepth = sum(sizeGCT.*[1 2 4]) + 1;
   n = 3*bitshift(1,bitdepth);
   [table,count] = fread(fid,n,'uint8');
   if ( count ~= n )
       error(message('MATLAB:imagesci:imgifinfo:fileCorrupt', ...
           ferror(fid)));
   end
   GlobalColorTable = reshape(table,3,length(table)/3)'./255;
end

% Since those extension blocks can be anywhere (including before the Local
% Image Descriptor), we have to fread and sort until we hit a Separator
k = 0; CommentExtension = '';

% Keep going past blocks till we hit Image Descriptor or Extension Block
separator = fread(fid,1,'uint8');
while (separator ~= 59)
    
   % Image Descriptor
   if (separator == 33)
      [blockLabel,count] = fread(fid,1,'uint8');
      if ( count ~= 1 )
          error(message('MATLAB:imagesci:imgifinfo:fileCorrupt', ...
              ferror(fid)));
      end
      
      switch blockLabel
          
          % Graphics Control Extension
          case 249 
             fseek(fid, 1, 'cof');
             packed = fread(fid, 1, 'uint8');
             info(k+1).DelayTime = fread(fid, 1, 'uint16');

             if (bitget(packed, 1))
                 info(k+1).TransparentColor = fread(fid,1,'uint8')+1;
             else
                 fseek(fid, 1, 'cof');
             end
             info(k+1).DisposalMethod = getDisposalMethod(packed);
             fseek(fid, 1, 'cof');  % Block terminator.
      
          % Plain Text Extension
          case 1 
             fseek(fid,13,'cof');
             countByte = fread(fid,1,'uint8');
             while (countByte ~=0)
                fseek(fid,countByte+1,'cof');
                countByte = fread(fid,1,'uint8');
             end
         
          % Application Extension.
          % 1 byte :  blocksize (0x0b == 11)
          % 8 bytes:  application identifier
          % 3 bytes:  application authentication
          % 1 byte :  pointer to application data
          % 1 byte :  block terminator, should be zero
          case 255
              % Read in the blocksize byte to verify that it is 11. If it
              % isn't, issue a warning to the user.
              blocksize = fread(fid,1,'uint8');
              identifier = fread(fid,8,'uint8=>char')';
              if ( blocksize ~= 11 )
                  wid = 'MATLAB:imagesci:imgifinfo:invalidApplicationExtensionBlockLength';
                  warning(message(wid,blocksize,identifier));
              end  

              % Skip past the application authentication bytes.
              fseek(fid,3,'cof');
              
              % Read through all the application data sub-blocks until we
              % reach the block termination byte (0).  Since we don't know
              % how long the application data field will be, we have to
              % read it all.
              countByte = fread(fid,1,'uint8');
              while (countByte ~= 0)
                 fseek(fid,countByte,'cof');
                 countByte = fread(fid,1,'uint8');
              end
         
          % Comment Extension   
          case 254 
             fread(fid,1); % pointer
             letter = fread(fid,1);
             while (letter ~= 0)
                CommentExtension = [CommentExtension char(letter)]; %#ok<AGROW>
                letter = fread(fid,1);              
             end
             
          % Corrupted File Error
          otherwise
             error(message('MATLAB:imagesci:imgifinfo:unrecognizedExtensionID',...
                 blockLabel));
      end
      
   % Image descriptor
   elseif (separator == 44)
      % Create new structure for new frame
      k = k+1;
      
      % Fill in fields that are independent of Local Color Table 
      info(k).Filename =  info(1).Filename;
      info(k).FileModDate = info(1).FileModDate;
      info(k).FileSize = info(1).FileSize;
      info(k).Format = char(GIFheader(1:3));
      info(k).FormatVersion = char(GIFheader(4:6));
      info(k).ColorType = 'indexed';
      info(k).FormatSignature = [info(k).Format info(k).FormatVersion];
      
      % If GlobalColorTable Flag is set to 0, then Background Color is null.
      if bitget(PackedByte,8) == 0
         info(k).BackgroundColor = [];
      else
         info(k).BackgroundColor = LogicalScreenDescriptor(2)+1;
      end
      info(k).AspectRatio = LogicalScreenDescriptor(3);
         
      % Fill in the fields to be check for a Local Image Descriptor 
      [buffer,count] = fread(fid,9,'uint8=>uint8');
      if count ~= 9
          error(message('MATLAB:imagesci:imgifinfo:fileCorrupt', ...
              ferror(fid)));
      end
      LocalID = typecast(buffer(1:8),'uint16');
      LocalPacked = buffer(9);
      
      % Location of subsequent images relative to base image
      % Convert to one based indexing for images
      info(k).Left = LocalID(1)+1;
      info(k).Top = LocalID(2)+1;
      info(k).Width = LocalID(3);
      info(k).Height = LocalID(4);
      
      % Check whether Interlaced
      if (bitget(LocalPacked,7) == 1)
         info(k).Interlaced = 'yes';
      else
         info(k).Interlaced = 'no';
      end
      
      % Check and see if we have a Local Color Table
      LCTbool = bitget(LocalPacked,8)==1;
      if LCTbool
         % Use the Local Color Table 
         Localbitdepth = double(bitget(LocalPacked,1:3));
         Localbitdepth = sum(Localbitdepth.*[1 2 4]) + 1; 
         info(k).BitDepth = Localbitdepth;
         n = 3*bitshift(1,Localbitdepth);
         [ltable,count] = fread(fid,n,'uint8');
         if ( count ~= n )
             error(message('MATLAB:imagesci:imgifinfo:fileCorrupt', ...
                 ferror(fid)));
         end
         info(k).ColorTable = reshape(ltable,3,length(ltable)/3)'./255;
      
      elseif GCTbool
         % Use the Global Color Table
         info(k).BitDepth = bitdepth;
         info(k).ColorTable = GlobalColorTable;   
      
      else
         % Use a default color table
         info(k).ColorTable = [0 0 0;1 1 1];
         info(k).BitDepth = 1;
      end
      
      % fseek past the Image data 
      % "A block with a zero byte count terminates the Raster Data 
      %  stream for a given image."
      fread(fid,1,'uint8'); % minumum code size
      countByte = fread(fid,1,'uint8');
      while countByte~=0
          fseek(fid,countByte,'cof');
          countByte = fread(fid,1,'uint8');
      end
   end
   separator = fread(fid,1,'uint8');   
end

% Number of frames
numImages = k;
if ~isempty(CommentExtension)
  for i = 1:numImages
    info(i).CommentExtension = native2unicode(double(CommentExtension));
  end
end
if (numImages == 0)
  error(message('MATLAB:imagesci:imgifinfo:noImages'));
end

% Sort order of structure fields to be returned
info = reorder_fields(info);




%--------------------------------------------------------------------------
function disposalMethod = getDisposalMethod(packedBits)
%getDisposalMethod   Get animation redraw method from packed byte

% The disposal method occupies bits 3-5 in the packed byte (1-based)
disposalNum = bitget(packedBits, 3) + ...
              2 * bitget(packedBits, 4) + ...
              4 * bitget(packedBits, 5);

switch (disposalNum)
case 0
    disposalMethod = 'DoNotspecify';
case 1
    disposalMethod = 'LeaveInPlace';
case 2
    disposalMethod = 'RestoreBG';
case 3
    disposalMethod = 'RestorePrevious';
otherwise
    disposalMethod = 'UnknownMethod';
end



function image_info = reorder_fields(image_info)
% Orders Top and Left before Height and Width

field_names = fieldnames(image_info);
num_fields = length(field_names);
for ctr = 1:num_fields
     if strcmp(field_names{ctr},'Width')
         width_index = ctr;
     elseif strcmp(field_names{ctr},'Left')
         left_index = ctr;
     end
end
perm_index = [1:width_index-1          ...
              left_index:left_index+1  ... 
              width_index:left_index-1 ...      
              left_index+2:num_fields];
image_info = orderfields(image_info,perm_index);


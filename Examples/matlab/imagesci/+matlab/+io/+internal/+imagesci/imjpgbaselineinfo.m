function [info, exif_offset, ifd_idx] = imjpgbaselineinfo(fid)
%IMJPGBASELINEINFO Information about a JPEG file.
%   [INFO, EXIF_OFFSET, IFD_IDX] = IMJPGBASELINEINFO(FID) returns a 
%   structure containing information about the JPEG file specified by the 
%   file identifier FID.  
%
%   EXIF_OFFSET is the byte position of the Exif IFD.  
%
%   Copyright 2012-2017 The MathWorks, Inc.

% This will point to the start of Exif metadata if it exists.

% The calling function imjpginfo.m is responsible for closing the file id.

exif_offset = 0;
ifd_idx = [];

info = struct('Filename','','FileModDate','','FileSize',0,...
    'Format','jpg', 'FormatVersion','', ...
    'Width',0,'Height',0,'BitDepth',0, ...
    'ColorType','', 'FormatSignature','', 'NumberOfSamples',0, ...
    'CodingMethod','','CodingProcess','','Comment',[]);

% Have already positioned past FFD8, Start-Of-Image marker

has_start_of_frame = false;
marker_count = 0;
com_marker_count = 0;

[marker, marker_length] = recover_valid_marker(fid);
start_of_segment = ftell(fid)-4;

while 1
    
    switch (marker)
              
        case {65472, 65473, 65474, 65475, 65477, 65478, 65479, 65480, ...
              65481, 65482, 65483, 65485, 65486, 65487}
            % FFC0:FFC3 FFC5:FFCB FFCD:FFCF
            % Start of frame.  FFC8 is listed as reserved.
            has_start_of_frame = true;
            
            P = fread(fid,1,'uint8');
            Y = fread(fid,1,'uint16');
            X = fread(fid,1,'uint16');
            Nf = fread(fid,1,'uint8');
            switch(Nf)
                case 1
                    info.ColorType = 'grayscale';
                case 3
                    info.ColorType = 'truecolor';
                case 4
                    info.ColorType = 'CMYK';
                otherwise
                    error(message('MATLAB:imagesci:imjpginfo:unsupportedNumberOfComponents', Nf));
            end

            
            info.Width = X;
            info.Height = Y;
            info.BitDepth = Nf * P;
            info.NumberOfSamples = Nf;
            
            switch(marker)
                case {65474, 65478, 65482, 65486}
                    % FFC2 FFC6 FFCA FFCE
                    info.CodingProcess = 'Progressive';
                case {65475, 65479, 65483, 65487}
                    % FFC3 FFC7 FFCB FFCF
                    info.CodingProcess = 'Lossless';
                otherwise
                    info.CodingProcess = 'Sequential';
            end
            
            switch(marker)
                case {65485, 65486, 65487}
                    % FFCD FFCE FFCF
                    info.CodingMethod = 'Arithmetic';
                otherwise
                    info.CodingMethod = 'Huffman';
            end
            
            marker_count = marker_count + 1;

        case 65476
            % FFC4:  Huffman table    
            
        case 65484
            % FFCC - arithmetic coding conditioning
            % Underdocumented segment.
            
        case { 65488, 65489, 65490, 65491, 65492, 65493, 65494, 65495}
            % FFD0:FFD7
            % restart interval termination
            % FFD8 is the Start-Of-Image (SOI) marker
            
        case 65497
            % FFD9:  EndOfImage marker.  We are done.
            break;
        
        case {65499, 65500, 65501, 65502, 65503}
            % FFDB:  quantization tables
            % FFDC:  number of lines (DNL)
            % FFDD:  restart interval
            % FFDE: heirarchical progression
            % FFDF: expand reference components
            
        case 65498
            % FFDA:  start of scan
            % We are done. See g1670919 for more details         
            break;
            
        case 65504
            % FFE0:  APP0 Application segment.  Currently unused.
            
            
        case 65505
            % FFE1:  APP1 Application segment (maybe Exif)
            [raw_identifier,count] = fread(fid,6,'uint8');
            if count ~= 6
                msg = ferror(fid);
                error(message('MATLAB:imagesci:imjpginfo:readError',msg));
            end
            identifier = char(raw_identifier');
            if strcmp(deblank(identifier),'Exif')
                % Ignore an APP1 segment if it is not Exif.  
                [exif_offset, ifd_idx] = parse_app1_exif_segment(fid);
            end
                            
            % Don't do anything more, let TIFFTAGSREAD retrieve the Exif
            % data.


            
        case { 65506, 65507, 65508, 65509, 65510, 65511, 65512, 65513, ...
            65514, 65515, 65516, 65517, 65518, 65519 }
            % FFE2:FFEF
            % APPn where n = 2 through 15;
          
        case { 65520,65521,65522,65523,65524,65525,65526,65527,65528, ...
               65529,65530,65531,65532,65533 }
            % FFF0:FFFD
            % JPGn:  reserved for JPEG extentions
            
        case 65534
            % FFFE:  COM marker
            com_marker_count = com_marker_count + 1;
            comment = fread(fid,marker_length-2);
            
            % Chop off any nul chars.
            idx = find(comment==0);
            if ~isempty(idx)
                comment = comment(1:idx(1)-1);
            end
            info.Comment{com_marker_count,1} = native2unicode(comment');                  
            
    end
    
   
    % Seek to the start of the next marker.  Add two for the length of the
    % marker itself.
    status = fseek(fid, start_of_segment+marker_length+2, 'bof' );
    if status ~= 0
        msg = ferror(fid);
        error(message('MATLAB:imagesci:imjpginfo:readError',msg));
    end
    
    [marker, marker_length] = recover_valid_marker(fid);
    start_of_segment = ftell(fid)-4;
    
    marker_count = marker_count + 1;
    
end


if com_marker_count == 0
    info.Comment = {};
end

if marker_count == 0
    filename = fopen(fid);
    error(message('MATLAB:imagesci:imjpginfo:corruptJFIF',filename));
end
if ~has_start_of_frame
    filename = fopen(fid);
    error(message('MATLAB:imagesci:imjpginfo:missingMarker',filename,'SOF'));
end


%--------------------------------------------------------------------------
function [marker, marker_length] = recover_valid_marker(fid)

persistent recognized_markers;
if isempty(recognized_markers)
    % 65472:65487:  FFC0 through FFCF
    % 65488:65503:  FFD0 through FFDF
    % 65504:65519:  FFE0 through FFEF
    % 65520:65534:  FFF0 through FFFE
    recognized_markers = uint16(65472:65534);
end

start_of_segment = ftell(fid);
marker = fread(fid,1,'uint16');
marker_length = fread(fid,1,'uint16');

invalid_marker_or_length = false;

while ~(isempty(ferror(fid))  ...   % marker and marker length were read
        && any(recognized_markers == marker) ... % marker is valid
        && (marker_length ~= 0))    % valid marker length
    
    if feof(fid)
        error(message('MATLAB:imagesci:imjpginfo:readError', ...
            'End of file encountered before SOF marker.'));
    end
    
    % Is the marker FFFF?  The JPEG standard allows for a sequence of FF bytes
    % leading up to a non-FF byte.  See Section B.1.1.2 of CCITT T.81
    if marker == 65535
        fseek(fid,ftell(fid)-2,'bof');
        x = uint8(255);
        while x == 255
            % Swallow the padded bytes.
            x = fread(fid,1,'uint8');
        end
        if isempty(x)
            msg = ferror(fid);
            error(message('MATLAB:imagesci:imjpginfo:readError',msg))
        end
        
        marker = typecast(uint8([x 255]),'uint16');
        marker_length = fread(fid,1,'uint16');
        
        % Try the loop condition again.
        continue
    end
    
    
    % OK, we have an invalid marker or marker length.  Try to find the next
    % valid marker by seeking ahead byte-by-byte.
    invalid_marker_or_length = true;
    fseek(fid,ftell(fid)-2,'bof');
    x = fread(fid,1,'uint8');
    while x ~= 255
        x = fread(fid,1,'uint8');
    end
    if isempty(x)
        msg = ferror(fid);
        error(message('MATLAB:imagesci:imjpginfo:readError',msg));
    end
    y = fread(fid,1,'uint8');
    if isempty(y);
        msg = ferror(fid);
        error(message('MATLAB:imagesci:imjpginfo:readError',msg));
    end
    marker = typecast(uint8([y x]),'uint16');
    marker_length = fread(fid,1,'uint16');
    
end



if invalid_marker_or_length
    num_bad_bytes = ftell(fid) - 4 - start_of_segment;
    warning(message('MATLAB:imagesci:imjpginfo:corruptJPEGsegment', ...
            num_bad_bytes, dec2hex(marker)));
end



%--------------------------------------------------------------------------
function [exif_offset, idx] = parse_app1_exif_segment(fid)
% Parse the APP1 segment and return the indices of any IFDs.  Later on we 
% pass these indices into TIFFTAGSREAD to retrieve the metadata.  We also
% return the offset of the TIFF header as exif_offset.
%
% For JPEG, IDX will have at least one value, 0, which means to get
% metadata about the main IFD.  If IDX is [0 1], though, that second value
% means that there is an Exif thumbnail.

exif_offset = ftell(fid);

% Byte order might be different than big endian.
byteorder = fread(fid,2,'uint8');
if isequal(byteorder', uint8([73 73]))
    machine_format = 'ieee-le';
else
    machine_format = 'ieee-be';
end

% Determine the location of the first IFD.
fseek(fid,2,'cof');
idx = 0;
first_ifd_offset = fread(fid,1,'uint32',0,machine_format);

% Seek to the offset of the first IFD.
fseek(fid,exif_offset + first_ifd_offset,'bof');

% How many tags in the first IFD?
num_tags = fread(fid,1,'uint16',0,machine_format);

% Seek to the end of the IFD and read the offset to the 2nd
% IFD.
fseek(fid, exif_offset + first_ifd_offset + 2 + num_tags * 12, 'bof');
second_ifd_offset = fread(fid,1,'uint32',0,machine_format);

% If the offset is not zero and is less than 2^16 - 1 (max length of an
% APP1 segment), then we have an Exif thumbnail.
if second_ifd_offset ~= 0 && second_ifd_offset <= 65535
    % Make note of the 2nd IFD, it's index is 1.
    idx(2) = 1;
end


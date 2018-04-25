function info = tifftagsprocess ( info )
% TIFFTAGSPROCESS Processes raw TIFF tags into human-readable form
%
%   INFO = TIFFTAGSPROCESS(TAGS) processes the cell array TAGS into a 
%   structure with name/value pairs.  There will be one structure for
%   each image in the image file.  If one of the tag elements
%   indicates a sub IFD, then the resulting name/value pair will consist
%   of another structure of name/value pairs.
%
%   Unrecognized tags are placed into a field called 'UnknownTags'.
%
%   See also TIFFTAGSREAD, IMFINFO

%   Copyright 2008-2015 The MathWorks, Inc.


num_ifds = numel(info);
if num_ifds > 0 
    if isfield ( info(1), 'DigitalCamera' )
        info(1).DigitalCamera = exiftagsprocess ( info(1).DigitalCamera );
    end
end



return




function info = exiftagsprocess ( info )
% EXIFTAGSPROCESS Processes raw exif tags into human-readable form
%
%   INFO = EXIFTAGSPROCESS(TAGS) processes the cell array TAGS into a
%   structure with name/value pairs.  There will be one structure for
%   each image in the image file.  If one of the tag elements
%   indicates a sub IFD, then the resulting name/value pair will consist
%   of another structure of name/value pairs.
%
%   Unrecognized tags are placed into a field called 'UnknownTags'.
%


num_ifds = numel(info);
for j = 1:num_ifds
    
    tagnames = fieldnames(info(j));
    
    
    for k = 1:numel(tagnames)
        
        switch ( tagnames{k} )
            
            case 'OECF'
                info(j).OECF = char(info(j).OECF);
                
            case 'ComponentsConfiguration'
                info(j).ComponentsConfiguration = handleComponentsConfiguration(info(j).ComponentsConfiguration);
                
            case 'Flash'
                info(j).Flash = handleFlash(info(j).Flash);
                
            case 'FlashpixVersion'
                info(j).FlashpixVersion = handleFlashpixVersion(info(j).FlashpixVersion);
                
            case 'DeviceSettingDescription'
                info(j).DeviceSettingDescription = ...
                    handleDeviceSettingDescription(info(j).DeviceSettingDescription);
                
                
        end % switch
        
    end % loop through current ifd
    
    
end % loop through IFD list

return










%===============================================================================
function y = handleFlash(x)

% did the flash fire
if bitand(x,1)
    y = 'Flash fired, ';
else
    y = 'Flash did not fire, ';
end

% status of return light
switch bitshift ( bitand(x,6), -1 )
    case 0
        y = [y 'no strobe return detection function, ']; %#ok<I18N_Concatenated_Msg>
    case 1
        y = [y 'reserved, '];
    case 2
        y = [y 'strobe return light not detected, ']; %#ok<I18N_Concatenated_Msg>
    case 3
        y = [y 'strobe return light detected, ']; %#ok<I18N_Concatenated_Msg>
end

% camera flash mode
switch bitshift ( bitand(x,24), -3 )
    case 0
        y = [y 'unknown flash mode, ']; %#ok<I18N_Concatenated_Msg>
    case 1
        y = [y 'compulsory flash firing, ']; %#ok<I18N_Concatenated_Msg>
    case 2
        y = [y 'compulsory flash suppression, ']; %#ok<I18N_Concatenated_Msg>
    case 3
        y = [y 'auto flash mode, ']; %#ok<I18N_Concatenated_Msg>
end

% presence of flash function
if bitshift ( bitand(x,32), -4 )
    y = [y 'no flash function, ']; %#ok<I18N_Concatenated_Msg>
else
    y = [y 'flash function present, ']; %#ok<I18N_Concatenated_Msg>
end

% red-eye mode
switch bitshift ( bitand(x,64), -5 )
    case 0
        y = [y 'no red-eye reduction mode or unknown.']; %#ok<I18N_Concatenated_Msg>
    case 1
        y = [y 'red-eye reduction mode supported.']; %#ok<I18N_Concatenated_Msg>
end

%===============================================================================
function y = handleComponentsConfiguration(x)

% x is a series of integers, such as [4 5 6 0], which means RGB.

if (any(x<0) || any(x>6))
    warning (message('MATLAB:imagesci:tifftagsprocess:invalidComponentsConfiguration'));
    y = x;
    return;
end

% remove any zeros
x(x==0) = [];

components(1,1:2) = 'Y ';
components(2,1:2) = 'Cb';
components(3,1:2) = 'Cr';
components(4,1:2) = 'R ';
components(5,1:2) = 'G ';
components(6,1:2) = 'B ';

y = components(x,1:2)';
y(y==' ') = [];



%===============================================================================
function y = handleFlashpixVersion(x)

if strcmp(char(x'),'0100')
    y = 'Flashpix Format Version 1.0';
else
    y = x;
end

%===============================================================================
function y = handleDeviceSettingDescription(x)

switch ( class(x) )
    case 'uint16'
        y = x';
    otherwise
        y = unicode2native(char(x));
end

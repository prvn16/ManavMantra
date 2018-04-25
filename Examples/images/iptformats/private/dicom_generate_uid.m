function uid = dicom_generate_uid(uid_type)
%DICOM_GENERATE_UID  Create a globally unique ID.
%   UID = DICOM_GENERATE_UID(TYPE) creates a unique identifier (UID) of
%   the specified type.  TYPE must be one of the following:
%
%      'instance'      - A UID for any arbitrary DICOM object
%      'ipt_root'      - The root of the Image Processing Toolbox's UID
%      'series'        - A UID for an arbitrary series of DICOM images
%      'study'         - A UID for an arbitrary study of DICOM series
%
%   See also MWGUIDGEN.

%   Copyright 1993-2012 The MathWorks, Inc.

% This is the UID root assigned to us.  It prevents collisions with UID
% generation schemes from other vendors.
ipt_root = '1.3.6.1.4.1.9590.100.1';

switch (uid_type)
case {'ipt_root'}
    
    uid = ipt_root;
    
case {'instance', 'series', 'study'}

    switch (lower(computer()))
    case {'pcwin', 'pcwin64'}
        
        guid_32bit = create_guid_windows();
        uid = guid_to_uid(ipt_root, guid_32bit);
        
    case {'glnxa64', 'glnx86'}
        
        guid_32bit = create_guid_linux();
        uid = guid_to_uid(ipt_root, guid_32bit);

    case {'maci', 'maci64'}
        
        guid_32bit = create_guid_mac();
        uid = guid_to_uid(ipt_root, guid_32bit);
    
    otherwise
    
        error(message('images:dicom_generate_uid:unsupportedPlatform'))
        
    end
    
otherwise
    
    error(message('images:dicom_generate_uid:inputValue', uid_type));
    
end



function guid_32bit = create_guid_linux

[status, raw_guid] = system('uuidgen');
if (status ~= 0)
    
    for ii = 1:5
        % Five attempts to get valid uuid
        [status, raw_guid] = system('cat /proc/sys/kernel/random/uuid');
        tmp_guid = strip_unix_messages(raw_guid);
        guid_32bit = sscanf(strrep(tmp_guid, '-', ''), '%08x');
        
        if ~isempty(guid_32bit)
            break;
        end
    
    end
    
    if (status ~= 0 || isempty(guid_32bit))
        
        error(message('images:dicom_generate_uid:linuxSystemProblem'))
    
    end
else
    tmp_guid = strip_unix_messages(raw_guid);
    guid_32bit = sscanf(strrep(tmp_guid, '-', ''), '%08x');
end




function guid_32bit = create_guid_mac

[status, raw_guid] = system('uuidgen');
if (status ~= 0)
    
    error(message('images:dicom_generate_uid:macSystemProblem'))
    
end

tmp_guid = strip_unix_messages(raw_guid);
guid_32bit = sscanf(strrep(tmp_guid, '-', ''), '%08x');



function guid_32bit = create_guid_windows

% Generate a GUID as a series of 16 UINT8 values.
guid_8bit = mwguidgen;

% Convert the bytes to four UINT32 values.
guid_32bit = images.internal.dicom.typecast(guid_8bit, 'uint32');



function uid = guid_to_uid(ipt_root, guid_32bit)

% Convert a group of numeric values into a concatenated string.
guid = '';
for p = 1:length(guid_32bit)
    
    guid = [guid sprintf('%010.0f', double(guid_32bit(p)))];  %#ok<AGROW>
    
end

% The maximum decimal representation of four concatenated 32-bit values
% is 40 digits long, which is one digit too many for the UID container in
% DICOM (after you add in the UID root).  Shorten it to fit in DICOM's
% length requirements by removing a value from the middle.  (As a result,
% 1 in every 10^39 values will be a duplicate.)
guid(13) = '';

% The DICOM standard requires the digit that follows a dot to be
% nonzero.  Removing the leading zeros does not cause duplication.
guid = remove_leading_zeros(guid);

% Append the GUID to the UID root. The intervening digit is the version
% number of the UID generation scheme.  Increment the version number if
% the rule/mechanism for generating "guid" changes. (The next scheme version
% number should be 4; skip 3, which is being used for implementation UIDs.)
uid = [ipt_root '.2.' guid];



function out = remove_leading_zeros(in)

out = in;
while (out(1) == '0')
    out(1) = '';
end



function out = strip_unix_messages(in)

% It's possible that sourcing a shell configuration file (or
% another part of the shell launch) causes a message to appear in
% the system() output. Strip out everything but the GUID value,
% which we must assume to be the last full line.

out = in;

newLine = sprintf('\n');
idx = find(in == newLine);

if (numel(idx) > 1)
  out(1:idx(end-1)) = '';
end

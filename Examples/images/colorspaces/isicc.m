function tf = isicc(pf)
%ISICC True for complete profile structure
%   ISICC(PF) returns TRUE if the structure PF
%   contains the required fields to represent an
%   ICC profile, as returned by ICCREAD and used
%   by ICCWRITE or MAKECFORM.  It must also contain
%   the tags required by the ICC specification.
%
%   In particular, PF must contain a "Header" field,
%   which in turn must contain a "Version" field and
%   a "DeviceClass" field.  These fields are used to
%   determine the set of required tags according to
%   the ICC Profile Specification, either Version 2
%   (ICC.1:2001-04) or Version 4 (ICC.1:2001-12),
%   which are available at www.color.org. The set of
%   required tags is given in Section 6.3 in either
%   version.
%
%   Examples
%   --------
%   Read in a profile and test its validity. 
%
%       P = iccread('sRGB.icm');
%       TF = isicc(P)    % valid profile
%
%   Create a MATLAB structure and test its validity. 
%
%       S.name = 'Any Student';
%       S.score = 83;
%       S.grade = 'B+';
%       TF = isicc(S)    % invalid profile
%
%   See also ICCREAD, ICCWRITE, MAKECFORM, APPLYCFORM.

%   Copyright 2004-2006 The MathWorks, Inc.
%   Original authors: Scott Gregory, Toshia McCabe, Robert Poe 01/28/04

% Check for required top-level fields
tf = isa(pf, 'struct');

% File name
if ~tf
    return;
elseif ~isfield(pf, 'Filename')
    tf = false;
elseif isempty(pf.Filename) | ~isstr(pf.Filename)
    tf = false;
end

% Header
if ~tf
    return;
elseif ~isfield(pf, 'Header')
    tf = false;
elseif isempty(pf.Header) | ~isstruct(pf.Header)
    tf = false;
else
    header = pf.Header;
end

% Tag table
if ~tf
    return;
elseif ~isfield(pf, 'TagTable')
    tf = false;
elseif isempty(pf.TagTable) | ~iscell(pf.TagTable)
    tf = false;
end
    
% Private tags
if ~tf
    return;
elseif ~isfield(pf, 'PrivateTags')
    tf = false;
elseif ~iscell(pf.PrivateTags)
    tf = false;
end

% Some required header fields (Note:  not all fields checked)
if ~tf
    return;
elseif ~isfield(header, 'Version') || ~isfield(header, 'DeviceClass')
    tf = false;
else % determine device-class signature
    version = sscanf(header.Version(1), '%d%');
    devclass = header.DeviceClass;
    device_classes = get_device_classes(version);
    idx = strmatch(devclass, device_classes(:, 2), 'exact');
    if isempty(idx)
       tf = false;
    else
       signature = device_classes{idx, 1};
    end
end

% Tags required for all classes
if ~tf
    return;
elseif (~isfield(pf, 'ProfileDescription') ...
        && ~isfield(pf, 'Description')) ...
       || ~isfield(pf, 'Copyright')
    tf = false;

% Tag required for all classes except device link
elseif ~strcmp(signature, 'link') && ~isfield(pf, 'MediaWhitePoint')
    tf = false;
end

if ~tf
    return;
end

% If still here, tf is true.

% Tags required for specific classes
switch signature
    case 'scnr'
        tf = isfield(pf, 'MatTRC') || ...
             isfield(pf, 'GrayTRC') || ...
             isfield(pf, 'AToB0');
        if strcmp(header.ConnectionSpace, 'Lab')
            tf = tf && isfield(pf, 'AToB0');
        end
        
    case 'mntr'
        tf = isfield(pf, 'MatTRC') || ...
             isfield(pf, 'GrayTRC') || ...
             (isfield(pf, 'AToB0') && isfield(pf, 'BToA0') && version > 2);
        if strcmp(header.ConnectionSpace, 'Lab')
            tf = tf && isfield(pf, 'AToB0');
        end
        
    case 'prtr'
        tf = isfield(pf, 'GrayTRC') || ...
             (isfield(pf, 'AToB0') && ...
              isfield(pf, 'BToA0') && ...
              isfield(pf, 'AToB1') && ...
              isfield(pf, 'BToA1') && ...
              isfield(pf, 'AToB2') && ...
              isfield(pf, 'BToA2') && ...
              isfield(pf, 'Gamut'));
        
    case 'link'
        tf = isfield(pf, 'AToB0') && ...
             isfield(pf, 'ProfileSequence');
         
    case 'spac'
        tf = isfield(pf, 'AToB0') && ...
             isfield(pf, 'BToA0');
         
    case 'abst'
        tf = isfield(pf, 'AToB0');
        
    case 'nmcl'
        tf = isfield(pf, 'NamedColor2');
        
    otherwise
        tf = false;
end

% Verify completeness of MatTRC tags
if ~tf
    return;
elseif isfield(pf, 'MatTRC')
    mattrc = pf.MatTRC;
    mattrc_tagnames = get_mattrc_tagnames(version);
    for k = 1:6
        tf = tf && any(strcmp(mattrc_tagnames(k, 2), fieldnames(mattrc)));
    end
end

% Additional requirement for non-D50 adaptation
if tf && isfield(pf, 'ViewingConditions') && version > 2
    if ~strcmp(pf.ViewingConditions.IlluminantType, 'D50')
        tf = isfield(pf, 'ChromaticAdaptation');
    end
end


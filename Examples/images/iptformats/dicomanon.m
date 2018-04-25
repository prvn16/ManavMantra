function dicomanon(filename_in, filename_out, varargin)
%DICOMANON  Anonymize DICOM file.
%
%    DICOMANON(FILE_IN, FILE_OUT) removes confidential medical
%    information from the DICOM file FILE_IN and creates a new file
%    FILE_OUT with the modified values.  Image data and other
%    attributes are unmodified.
%
%    DICOMANON(..., 'keep', FIELDS) modifies all of the confidential
%    data except for those listed in FIELDS, which is a cell array of
%    field names.  This syntax is useful for keeping metadata that does
%    not uniquely identify the patient but is useful for diagnostic
%    purposes (e.g., PatientAge, PatientSex, etc.).
%
%      Note: Keeping certain fields may compromise patient
%      confidentiality.
%
%    DICOMANON(..., 'update', ATTRS) modifies the confidential data and
%    updates particular confidential data.  ATTRS is a structure.  The
%    field names of ATTRS are the attributes to preserve, and the
%    structure values are the attribute values.  Use this syntax to
%    preserve the Study/Series/Image hierarchy or to replace one a
%    specific value with a more generic property (e.g., remove
%    PatientBirthDate but keep a computed PatientAge). 
%
%    DICOMANON(..., 'WritePrivate', TF) specifies whether nonstandard
%    attributes should be written to the anonymized file.  If TF is
%    true, private extensions will be included in the file, which
%    could compromise patient confidentiality.  The default value is
%    false.
%
%    DICOMANON(..., 'UseVRHeuristic', TF) instructs the parser to use a
%    heuristic to help read certain noncompliant files which switch value
%    representation (VR) modes incorrectly. A warning will be displayed if
%    the heuristic is employed. When TF is true (the default), a small
%    number of compliant files will not be read correctly. Set TF to false
%    to read these compliant files. Compliant files are always written.
%
%    For information about the fields that will be modified or removed,
%    see DICOM Supplement 55 from <http://medical.nema.org/>.
%
%    Examples:
%
%      % (1) Remove all confidential metadata from a file.
%      dicomanon('patient.dcm', 'anonymized.dcm')
%
%      % (2) Create a training file.
%      dicomanon('tumor.dcm', 'tumor_anon.dcm', ...
%         'keep', {'PatientAge', 'PatientSex', 'StudyDescription'})
%
%      % (3) Anonymize a series of images, keeping the hierarchy.
%      values.StudyInstanceUID = dicomuid;
%      values.SeriesInstanceUID = dicomuid;
%
%      d = dir('*.dcm');
%      for p = 1:numel(d)
%          dicomanon(d(p).name, sprintf('anon%d.dcm', p), ...
%             'update', values)
%      end
%
%    See also DICOMINFO, DICOMWRITE.

% Copyright 2005-2017 The MathWorks, Inc.

% NOTE: When updating this function, be sure to increment the
% version number which is part of the "De-identification Method"
% text value.

filename_in = matlab.images.internal.stringToChar(filename_in);
filename_out = matlab.images.internal.stringToChar(filename_out);

dictionary = dicomdict('get_current');

% Process input arguments
validateFilenames(filename_in, filename_out)
args = parseInputs(varargin{:});
preserveAttr('', args, 'reset');

% Get the original data.
metadata = dicominfo(filename_in, 'UseVRHeuristic', args.usevrheuristic);
[X, map] = dicomread(metadata, 'UseVRHeuristic', args.usevrheuristic);

% Update fields to preserve.
metadata = updateAttrs(metadata, args.update); 

% Make new UIDs for attributes that must be different than the input.
SOPInstanceUID = dicomuid;
StudyUID = dicomuid;
SeriesUID = dicomuid;
FrameUID = dicomuid;
SyncUID = dicomuid;
SrUID = dicomuid;

% Anonymize the data.
%
% For type 1 attributes - Use changeAttr with a new value.
% For type 2 attributes - Use changeAttr with an empty value.
% For type 3 attributes - Use removeAttr().

metadata = removeAttr(metadata, '0008', '0014', args, dictionary);
metadata = changeAttr(metadata, '0008', '0018', SOPInstanceUID, args, dictionary);
metadata = changeAttr(metadata, '0008', '0050', '', args, dictionary);
metadata = changeAttr(metadata, '0008', '0080', '', args, dictionary);
metadata = removeAttr(metadata, '0008', '0081', args, dictionary);
metadata = changeAttr(metadata, '0008', '0090', '', args, dictionary);
metadata = removeAttr(metadata, '0008', '0092', args, dictionary);
metadata = removeAttr(metadata, '0008', '0094', args, dictionary);
metadata = removeAttr(metadata, '0008', '1010', args, dictionary);
metadata = removeAttr(metadata, '0008', '1030', args, dictionary);
metadata = removeAttr(metadata, '0008', '103E', args, dictionary);
metadata = removeAttr(metadata, '0008', '1040', args, dictionary);
metadata = removeAttr(metadata, '0008', '1048', args, dictionary);
metadata = changeAttr(metadata, '0008', '1050', '', args, dictionary);
metadata = removeAttr(metadata, '0008', '1060', args, dictionary);
metadata = removeAttr(metadata, '0008', '1070', args, dictionary);
metadata = removeAttr(metadata, '0008', '1080', args, dictionary);
metadata = changeAttr(metadata, '0008', '1155', SOPInstanceUID, args, dictionary);
metadata = removeAttr(metadata, '0008', '2111', args, dictionary);
metadata = changeAttr(metadata, '0010', '0010', '', args, dictionary);
metadata = changeAttr(metadata, '0010', '0020', '', args, dictionary);
metadata = changeAttr(metadata, '0010', '0030', '', args, dictionary);
metadata = removeAttr(metadata, '0010', '0032', args, dictionary);
metadata = changeAttr(metadata, '0010', '0040', '', args, dictionary);
metadata = removeAttr(metadata, '0010', '1000', args, dictionary);
metadata = removeAttr(metadata, '0010', '1001', args, dictionary);
metadata = removeAttr(metadata, '0010', '1010', args, dictionary);
metadata = removeAttr(metadata, '0010', '1020', args, dictionary);
metadata = removeAttr(metadata, '0010', '1030', args, dictionary);
metadata = removeAttr(metadata, '0010', '1040', args, dictionary);
metadata = removeAttr(metadata, '0010', '1090', args, dictionary);
metadata = removeAttr(metadata, '0010', '2160', args, dictionary);
metadata = removeAttr(metadata, '0010', '2180', args, dictionary);
metadata = removeAttr(metadata, '0010', '21B0', args, dictionary);
metadata = removeAttr(metadata, '0010', '4000', args, dictionary);
metadata = update_0018_1000(metadata, args, dictionary);  % See tech ref.
metadata = removeAttr(metadata, '0018', '1030', args, dictionary);
metadata = changeAttr(metadata, '0020', '000D', StudyUID, args, dictionary);
metadata = changeAttr(metadata, '0020', '000E', SeriesUID, args, dictionary);
metadata = changeAttr(metadata, '0020', '0010', '', args, dictionary);  % See tech ref.
metadata = changeAttr(metadata, '0020', '0052', FrameUID, args, dictionary);
metadata = changeAttr(metadata, '0020', '0200', SyncUID, args, dictionary);
metadata = removeAttr(metadata, '0020', '4000', args, dictionary);
metadata = removeAttr(metadata, '0040', '0275', args, dictionary);
metadata = changeAttr(metadata, '0040', 'A124', SrUID, args, dictionary);
metadata = removeAttr(metadata, '0040', 'A730', args, dictionary);  
metadata = removeAttr(metadata, '0088', '0140', args, dictionary);  % See tech ref.
metadata = changeAttr(metadata, '3006', '0024', FrameUID, args, dictionary);
metadata = changeAttr(metadata, '3006', '00C2', FrameUID, args, dictionary);

% Add details about the anonymization (See PS 3.15 E.1.1)
metadata = insertAttr(metadata, '0012', '0062', 'YES', args, dictionary); 
metadata = insertAttr(metadata, '0012', '0063', getDeidentificationString(args), args, dictionary);

% Write the new data file.
if (~isempty(map))
    dicomwrite(X, map, filename_out, metadata, ...
               'createmode', 'copy', ...
               'dictionary', dictionary, ...
               'WritePrivate', args.writeprivate, ...
               'UseMetadataBitDepths', true);
else
    dicomwrite(X, filename_out, metadata, ...
               'createmode', 'copy', ...
               'dictionary', dictionary, ...
               'WritePrivate', args.writeprivate, ...
               'UseMetadataBitDepths', true);
end



function metadata = update_0018_1000(metadata, args, dictionary)
% Update (0018,1000) which can be either type 2 or 3 depending on SOP Class.

thisGroup        = '0018';
thisElement      = '1000';
mediaStorageName = dicom_name_lookup('0002', '0002', dictionary);

% Assume that if the transfer syntax isn't present, it's safe to remove.
if (~isfield(metadata, mediaStorageName))
    metadata = removeAttr(metadata, thisGroup, thisElement, args, dictionary);
else
    switch (metadata.(mediaStorageName))
    case '1.2.840.10008.5.1.4.1.1.481.7'
        % Only type 2 in RT Treatment Summary Record Storage.
        metadata = changeAttr(metadata, thisGroup, thisElement, '', args, dictionary);
    otherwise
        metadata = removeAttr(metadata, thisGroup, thisElement, args, dictionary);
    end
end


        
function metadata = changeAttr(metadata, group, element, newValue, args, dictionary)
%CHANGEATTR  Update an attribute's value.

name = dicom_name_lookup(group, element, dictionary);

if (preserveAttr(name, args))
    return
end

if ((~isempty(name)) && (isfield(metadata, name)))
    metadata.(name) = newValue;
end



function metadata = removeAttr(metadata, group, element, args, dictionary)
%REMOVEATTR  Remove an attribute.

name = dicom_name_lookup(group, element, dictionary);

if (preserveAttr(name, args))
    return
end

if ((~isempty(name)) && (isfield(metadata, name)))
    metadata = rmfield(metadata, name);
end



function metadata = updateAttrs(metadata, values)
%UPDATEATTRS  Update metadata with user-specified values.

if (~isstruct(values))
    return
end

fields = fieldnames(values);

for p = 1:numel(fields)
    metadata.(fields{p}) = values.(fields{p});
end



function metadata = insertAttr(metadata, group, element, newValue, args, dictionary)
%INSERTATTR  Insert (or update) an attribute's value.

name = dicom_name_lookup(group, element, dictionary);

if (preserveAttr(name, args))
    return
end

metadata.(name) = newValue;



function validateFilenames(filename_in, filename_out)

validateattributes(filename_in, {'char'}, {'nonempty', 'row'}, 'dicomanon', 'FILE_IN');
validateattributes(filename_out, {'char'}, {'nonempty', 'row'}, 'dicomanon', 'FILE_OUT');


function args = parseInputs(varargin)
%PARSEINPUTS  Parse input arguments to DICOMANON.

args.update = struct([]);
args.keep = {};
args.writeprivate = false;
args.usevrheuristic = true;

params = fieldnames(args);

p = 1;
while (p <= nargin)
    
    paramName = matlab.images.internal.stringToChar(varargin{p});
    if (~ischar(paramName) && ~(isstring(paramName) && isscalar(paramName)))
        error(message('images:dicomanon:badParam'));
    end
    
    idx = strmatch(lower(paramName), params);
    
    if (isempty(idx))
        error(message('images:dicomanon:unknownParam', paramName));
    elseif (numel(idx) > 1)
        error(message('images:dicomanon:ambiguousParam', paramName));
    else
        args.(params{idx}) = varargin{p + 1};
    end
    
    p = p + 2;
    
end

% Retrofit input parsing to allow keep to be an array of strings. Convert
% it to a cellstr to allow rest of code working as originally designed.
if isstring(args.keep)
   args.keep = args.keep.cellstr;
end

% Retrofit input parsing to allow update struct field values to be strings.
% Convert each field that is a string to a char vector to allow code to
% continue working as originally designed.
if ~isempty(args.update)
    args.update = structfun(@(field) matlab.images.internal.stringToChar(field),args.update,'UniformOutput',false);
end




function tf = preserveAttr(name, args, varargin)

persistent preserveFields;

% If there are three arguments, set up for future inquiries.
if (nargin == 3)
   
    % Keep track of the fields to preserve.
    if (isempty(args.keep))
        
        preserveFields = fieldnames(args.update);
        
    elseif (isempty(args.update))
        
        preserveFields = args.keep;
        
    else
        
        preserveFields = cat(2, args.keep(:)', fieldnames(args.update)');
        
    end

    if (isempty(name))
        return
    end
    
end

% Look for the field in the fields to preserve.
tf = ~isempty(strmatch(name, preserveFields, 'exact'));



function str = getDeidentificationString(args)
% Get a string for the De-identification Method attribute (0012,0063)
% See PS 3.3 C.7.1.1 (Table C.7-1) and/or Change Proposal 892.

verStr = 'DICOMANON (rev R2010a)';

methodStr = 'PS 3.15-2008 Table E.1-1';

if (~isempty(args.keep) || ~isempty(args.update))
    overrideStr = ' - nondefault';
else
    overrideStr = '';
end

str = sprintf('%s - %s%s', verStr, methodStr, overrideStr);

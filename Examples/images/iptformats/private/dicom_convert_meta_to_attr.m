function attr = dicom_convert_meta_to_attr(attr_name, metadata, dictionary, txfr, specificCharacterSet)
%DICOM_CONVERT_META_TO_ATTR  Convert a metadata field to an attr struct.

%   Copyright 1993-2015 The MathWorks, Inc.

% Look up the attribute tag.
tag = images.internal.dicom.tagLookup(attr_name, dictionary);

if (isempty(tag))

    attr = [];
    return

end

% Get the VR.
VR = determine_VR(tag, metadata, dictionary, txfr);

% Process struct data - Person Names (PN) and sequences (SQ).
if (isequal(VR, 'PN') || isPersonName(metadata.(attr_name)))
    
    data = dicom_encode_pn(metadata.(attr_name), specificCharacterSet);

elseif (isequal(VR, 'SQ') || isstruct(metadata.(attr_name)))
    
    data = encode_SQ(metadata.(attr_name), dictionary, txfr, specificCharacterSet);
    
else
    
    data = metadata.(attr_name);
    
end
    

% Add the attribute.
if (isempty(VR))
    attr = dicom_add_attr([], tag(1), tag(2), dictionary, specificCharacterSet, data);
else
    attr = dicom_add_attr([], tag(1), tag(2), dictionary, specificCharacterSet, data, VR);
end



function VR = determine_VR(tag, metadata, dictionary, txfr)
%DETERMINE_VR  Find an attribute's value representation (VR).

attr_details = dicom_dict_lookup(tag(1), tag(2), dictionary);

if (isempty(attr_details))

    if (tag(2) == 0)
        VR = 'UL';
    else
        VR = [];
    end
    
else
    
    VR = attr_details.VR;
    
    if (iscell(VR))
      
        % If it's US/SS, look at Pixel Representation (0028,0103).
        % If it's OB/OW, look at whether it's compressed.
        
        
        if (~isempty(strfind([VR{:}], 'US')))
          
            PixRep = dicomlookup('0028','0103');
            if (isfield(metadata, PixRep) && (metadata.(PixRep) == 1))
                VR = 'SS';
            else
                VR = 'US';
            end

        elseif (isequal(tag, uint16([sscanf('7fe0', '%x'), ...
                                     sscanf('0010', '%x')])))
            
            uidDetails = dicom_uid_decode(txfr);
            bitDepth = metadata.(dicomlookup('0028', '0100'));
            
            if (uidDetails.Compressed)

                VR = 'OB';
                
            elseif (isequal(uidDetails.VR, 'IMPLICIT'))
              
                VR = 'OW';
                
            elseif (bitDepth > 8)
              
                VR = 'OW';
                
            else
              
                VR = 'OB';
                
            end
            
        else
            VR = VR{1};
        end
        
    end
    
end



function attrs = encode_SQ(SQ_struct, dictionary, txfr, specificCharacterSet)
%ENCODE_SQ  Turn a structure of sequence data into attributes.

attrs = [];

if (isempty(SQ_struct))
    return
end

% Don't worry about encoding rules yet.  Just convert the MATLAB struct
% containing item and data fields into an array of attribute structs.

items = fieldnames(SQ_struct);
for p = 1:numel(items)
    
    data = encode_item(SQ_struct.(items{p}), dictionary, txfr, specificCharacterSet);
    attrs = dicom_add_attr(attrs, 'fffe', 'e000', dictionary, specificCharacterSet, data);
    
end



function attrs = encode_item(item_struct, dictionary, txfr, specificCharacterSet)
%ENCODE_ITEM  Turn one item of a sequence into attributes.

attrs = [];

if (isempty(item_struct))
    return
end

% Each item can have its own Specific Character Set attribute. Look for and
% use it locally.
SCSFromItem = dicom_get_SpecificCharacterSet(item_struct, dictionary);
if ~isempty(SCSFromItem)
    specificCharacterSet = SCSFromItem;
end

attr_names = fieldnames(item_struct);
for p = 1:numel(attr_names)
    
    new_attr = dicom_convert_meta_to_attr(attr_names{p}, item_struct, dictionary, txfr, specificCharacterSet);
    attrs = cat(2, attrs, new_attr);
    
end



function tf = isPersonName(attr)

if (isstruct(attr))
    
    tf = isfield(attr, 'FamilyName') || ...
         isfield(attr, 'GivenName') || ...
         isfield(attr, 'MiddleName') || ...
         isfield(attr, 'NamePrefix') || ...
         isfield(attr, 'NameSuffix');
    
else
    
    tf = false;
    
end

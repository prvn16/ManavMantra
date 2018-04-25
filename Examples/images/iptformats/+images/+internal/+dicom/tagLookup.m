function tag = tagLookup(attr_name, dictionary)
%DICOM_TAG_LOOKUP  Look up the data dictionary tag from a attribute name.

%   Copyright 1993-2016 The MathWorks, Inc.

persistent all_names all_tags prev_dictionary tag_cache;
mlock

if ((isempty(all_names)) || (~isequal(prev_dictionary, dictionary)))

    [all_names, all_tags] = get_dictionary_info(dictionary);
    prev_dictionary = dictionary;
    tag_cache = struct([]);
    
end

% As an optimization, attributes are cached the first time they're found.
% Query the cache.
if (isfield(tag_cache, attr_name))
    tag = tag_cache.(attr_name);
    return
end

% Look for the name among the attributes.
idx = find(strcmp(attr_name, all_names));

if (isempty(idx))
    
    if contains(lower(attr_name), 'private_')
        
        % It's private.  Parse out the group and element values.
        tag = parse_private_name(attr_name);

    else
        
        % It's not a DICOM attribute.
        tag = [];
        
    end
    
else
    
    if (numel(idx) > 1)
        
	warning(message('images:dicom_tag_lookup:multipleAttrib', attr_name));        
	
        idx = idx(1);
        
    end
    
    % Look for the index in the sparse array.
    % (row, column) values are (group + 1, element + 1)
    [group, element] = find(all_tags == idx);
    tag = [group element] - 1;

end

tag_cache(1).(attr_name) = tag;



function [all_names, all_tags] = get_dictionary_info(dictionary)
%GET_DICTIONARY_INFO  Get necessary details from the data dictionary

if (findstr('.mat', dictionary))
    
    dict = load(dictionary);
    
    all_names = {dict.values(:).Name};
    all_tags = dict.tags;
    
else
    
    [all_tags, values] = images.internal.dicom.loadDictionary(dictionary);
    
    all_names = {values(:).Name};
    
end



function tag = parse_private_name(attr_name)
%PARSE_PRIVATE_NAME  Get the group and element from a private attribute.

attr_name = lower(attr_name);
idx = find(attr_name == '_');

if contains(lower(attr_name), 'creator')
    
    % (gggg,0010-00ff) are Private Creator Data attributes:
    % "Private_gggg_eexx_Creator"  -->  (gggg,00ee).
    
    if (isempty(idx))
        tag = [];
        return;
    end
    
    group = sscanf(attr_name((idx(1) + 1):(idx(1) + 4)), '%x');
    element = sscanf(attr_name((idx(2) + 1):(idx(2) + 4)), '%x');
    
    tag = [group element];
    
elseif contains(lower(attr_name), 'grouplength')

    % Skip Private Group Length attributes.
    group = sscanf(attr_name(9:12), '%x');
    tag = [group 0];
    
else
    
    % Normal private data attributes: "Private_gggg_eeee".
    group = sscanf(attr_name((idx(1) + 1):(idx(1) + 4)), '%x');
    element = sscanf(attr_name((idx(2) + 1):(idx(2) + 4)), '%x');
    
    tag = [group element];
    
end

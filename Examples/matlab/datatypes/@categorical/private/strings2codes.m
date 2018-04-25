function [is,us] = strings2codes(s)
%STRINGS2CODES Handle strings that will become undefined elements.

%   Copyright 2013-2016 The MathWorks, Inc.

if ischar(s)
    us = strtrim(s);
    
    % Set '<undefined>' or '' as undefined elements
    if ~isempty(us) && us(1) ~= '<' % first char of categorical.undefLabel or categorical.missingLabel
        % Avoid more expensive checks in the most common cases where the
        % RHS is not '<undefined>', '<missing>' or '' or another empty string.
        is = 1;
    elseif strcmp(us,'') || strcmp(us,char(zeros(1,0))) || strcmp(us,categorical.undefLabel)
        is = 0;
        us = {};
    elseif strcmp(us,categorical.missingLabel)
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidUndefinedChar', us, categorical.undefLabel, categorical.missingLabel));
    else
        is = 1;
    end
    is = uint8(is); % cast to int because callers may rely on an integer class
elseif isstring(s) % scalar strings - have checked that it is scalar already
    us = strip(s);
    
    % Set '' and the missing string as undefined elements.  Don't allow
    % "<undefined>" or "<missing>" for strings.
    if ismissing(us) || us == ''
        is = 0;
        us = {};
    elseif us == categorical.undefLabel || us == categorical.missingLabel % don't allow "<undefined>" or "<missing>"
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidUndefinedString', char(us), categorical.undefLabel, categorical.missingLabel));
    else % create a category
        is = 1;
        us = char(us);
    end
    is = uint8(is); % cast to int because callers may rely on an integer class
else % iscellstr(s)
    [us,~,is] = unique(strtrim(s));

    us = us(:); % force cellstr to a column
    hasMissingLabel = strcmp(us,categorical.missingLabel);
    if any(hasMissingLabel)
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidMissingChar', categorical.missingLabel));
    end

    % Set '<undefined>' or '' as undefined elements
    locs = strcmp(us,'') | strcmp(us,char(zeros(1,0))) | strcmp(us,categorical.undefLabel);

    if any(locs)
        convert = (1:length(us))' - cumsum(locs);
        convert(locs) = 0;
        is = convert(is);
        us(locs) = [];
    end

    is = reshape(is,size(s));

    % Error if exceeded maximum allowed number of categories
    numCats = numel(us);
    if numCats > categorical.maxNumCategories
        error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
    end

    % Set code class based on number of strings (i.e. categories)
    is = categorical.castCodes(is, numCats);
end

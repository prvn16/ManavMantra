function res = fieldParser(value, field, parseElement, ...
                           allowsArray, useStringMatrix, varargin)
% fieldParser implements the behavior of matlab.net.http.HeaderField.parseField to
%   parse a comma-separated list of strings comprising a header field value and
%   return a MATLAB type.  It is factored out here so it can be used to parse an
%   input value for a HeaderField value, for the purpose of verifying that it is
%   semantically correct.  This throws exceptions if the value could not be
%   parsed.
%      
%      value            the value to be parsed
%      field            the HeaderField object for which it is being parsed
%      parseElement     handle to field.parseElement()
%      allowsArray      value returned by field.allowsArray()
%      useStringMatrix  value returned by field.useStringMatrix()
%      varargin can be empty or
%            arrayDelims, structDelims, structFields[, custom]
%            arrayDelims, parser[, custom]
%                       parameters, as per parseField
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

%   Copyright 2015-2017 The MathWorks, Inc.

    args = varargin;
    if ~isempty(args) && islogical(args{end})
        % strip off the custom arg for the purposes of looking at the other varargs
        custom = args{end};
        args(end) = [];
    else
        custom = false;
    end
    nargs = length(args);
    if nargs == 0
        arrayDelims = ',';
    else 
        arrayDelims = args{1};
        if nargs == 2 && isa(args{2},'function_handle')
            parser = args{2};
            nargs = 1; % don't count parser as argument
        end
    end
    % set the parser to the field's parseElement function
    if ~exist('parser','var')
        % don't pass in arrayDelims, but pass in the custom parameter, if any
        parser = @(elem)parseElement(field, elem, varargin{2:end});
    end
    
    if isempty(value)
        res = parser([]);
    elseif allowsArray && (~isempty(arrayDelims) || ischar(arrayDelims))
        % Split the field into array elements
        elements = matlab.net.http.internal.delimSplit(...
                                        strtrim(value), arrayDelims);
        res = arrayfun(@(elem)parser(strtrim(elem)), elements, ...
                        'UniformOutput', false);
        if isscalar(res)
            % if result is a single element, extract from its cell
            res = res{1};
        end
    else
        res = parser(strtrim(value));
    end
    
    if ~isempty(res) && ~isscalar(res)
        % create optional arguments to parseElement based on varargin argument
        if nargs < 2 
            % arg was arrayDelims
            sd = '';  % no structDelims
            sf = [];  % no structFields
        elseif nargs < 3
            % arg was arrayDelims, structDelims
            sd = args{2};  % save structDelims
            sf = [];       % no structFields
        else
            % arg was arrayDelims, structDelims, structFields
            sd = args{2};  % save structDelims
            sf = args{3};  % save structFields
        end
        stringParser = @(v)parseElement(field, v, sd, sf);
        if ~custom || allowsArray
            % if arrays allowed or we're not doing custom, combine cells of res in to an
            % array of structs or MxNx2 string matrix
            if useStringMatrix
                res = matlab.net.http.internal.concatMatrices(res, stringParser);
            else
                res = matlab.net.http.internal.concatStructs(res, stringParser);
            end
        end
    end

end
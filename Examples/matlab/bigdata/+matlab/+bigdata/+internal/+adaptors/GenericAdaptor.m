%GenericAdaptor Adaptor for generic data.

% Copyright 2016-2017 The MathWorks, Inc.
classdef GenericAdaptor < ...
        matlab.bigdata.internal.adaptors.AbstractAdaptor & ...
        matlab.bigdata.internal.adaptors.GeneralArrayParenIndexingMixin & ...
        matlab.bigdata.internal.adaptors.GeneralArrayDisplayMixin

    methods (Access = protected)
        function m = buildMetadataImpl(obj)
            m = matlab.bigdata.internal.adaptors.NumericishMetadata(obj.TallSize);
        end
    end
    methods
        function obj = GenericAdaptor(clz)
            if nargin < 1
                clz = '';
            else
                if ~isempty(clz)
                    if ~ismember(clz, matlab.bigdata.internal.adaptors.getAllowedTypes())
                        error(message('MATLAB:bigdata:array:TypeNotAllowed', clz));
                    end
                    % Check we're not trying to make a generic adaptor for
                    % a strong type.
                    assert(~ismember(clz, matlab.bigdata.internal.adaptors.getStrongTypes()), ...
                        'MATLAB:bigdata:array:AssertStrongType', ...
                        'GenericAdaptor being constructed with strong type.');
                end
            end
            obj@matlab.bigdata.internal.adaptors.AbstractAdaptor(clz);
        end

        function varargout = subsrefBraces(~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:SubsrefBracesNotSupported'));
        end
        function obj = subsasgnBraces(~, ~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:SubsasgnBracesNotSupported'));
        end
        
        function names = getProperties(~)
            names = cell(0,1);
        end

        function [nanFlagCell, precisionFlagCell] = interpretReductionFlags(~, FCN_NAME, flags)

            baseNanFlags = {'includenan', 'omitnan'};
            basePrecisionFlags = {'double', 'native', 'default'};

            switch lower(FCN_NAME)
                case {'sum', 'prod', 'mean'}
                    defaultNan = {'includenan'};
                    defaultPrecision = {'default'};
                    allowedNanFlags = baseNanFlags;
                    allowedPrecisionFlags = basePrecisionFlags;
                case {'min', 'max'}
                    defaultNan = {'omitnan'};
                    defaultPrecision = {};
                    allowedNanFlags = baseNanFlags;
                    allowedPrecisionFlags = {};
                case 'var'
                    defaultNan = {'includenan'};
                    defaultPrecision = {};
                    allowedNanFlags = baseNanFlags;
                    allowedPrecisionFlags = {};
                case {'any', 'all'}
                    defaultNan = {};
                    defaultPrecision = {};
                    allowedNanFlags = {};
                    allowedPrecisionFlags = {};
                case {'median'}
                    defaultNan = {'includenan'};
                    defaultPrecision = {};
                    allowedNanFlags = baseNanFlags;
                    allowedPrecisionFlags = {};
                otherwise
                    assert(false, 'Unrecognised reduction: %s', FCN_NAME);
            end
            
            allowedFlags = [allowedNanFlags, allowedPrecisionFlags];

            parsedFlags = iParseFlags(FCN_NAME, flags, allowedFlags);

            categories = {allowedNanFlags, allowedPrecisionFlags};
            flags = cell(1, numel(categories));
            defaults = {defaultNan, defaultPrecision};
            for catIdx = 1:numel(categories)
                thisFlagCell = intersect(parsedFlags, categories{catIdx});
                if isempty(thisFlagCell)
                    flags{catIdx} = defaults{catIdx};
                else
                    % Need to error if multiple flags specified, or single flag specified multiple
                    % times.
                    if numel(thisFlagCell) > 1 || ...
                            sum(strcmp(thisFlagCell{1}, parsedFlags)) > 1
                        error(message('MATLAB:bigdata:array:MultipleOptionsSpecified', ...
                            FCN_NAME, strjoin(categories{catIdx})));
                    end
                    flags{catIdx} = thisFlagCell(1);
                end
            end
            [nanFlagCell, precisionFlagCell] = deal(flags{:});
        end
        
        function tf = isTypeKnown(obj)
            % isTypeKnown Return TRUE if and only if this adaptor has known
            % type.
            tf = ~isempty(obj.Class);
        end
        
        function obj = resetNestedGenericType(obj)
            %resetNestedGenericType Reset the type of any GenericAdaptor
            % found among this adaptor or any children of this adaptor.
            
            obj = copySizeInformation(matlab.bigdata.internal.adaptors.GenericAdaptor(), obj);
        end
    end

    methods (Access=protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(obj, defaultType, sz)
            clz = obj.Class;
            if isempty(clz)
                clz = defaultType;
            end
            if clz == "cell"
                sample = repmat({'1'}, sz);
            elseif clz == "logical"
                sample = true(sz);
            elseif clz == "char"
                sample = repmat('1', sz);
            else
                % Value 49 is ASCII for '1'. We pick this value to ensure
                % all samples have the same value as each other regardless
                % of class.
                sample = 49 * ones(sz, clz);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iParseFlags - given a cell of flags, and a cell of options, pick out the
% unambiguous case-insensitive matches. Error on invalid or ambiguous flag.
function parsedFlags = iParseFlags(FCN_NAME, flags, options)
validFlagsStr = strjoin(options);
parsedFlags = cell(1, numel(flags));
for idx = 1:length(flags)
    thisFlag = flags{idx};
    match = strncmpi(thisFlag, options, strlength(thisFlag));
    switch sum(match)
        case 0
            % no match
            if isempty(options)
                % No options are valid
                error(message('MATLAB:bigdata:array:NoOptionsAllowed', FCN_NAME));
            else
                error(message('MATLAB:bigdata:array:InvalidOption', thisFlag, FCN_NAME, validFlagsStr));
            end
        case 1
            parsedFlags{idx} = options{match};
        otherwise
            error(message('MATLAB:bigdata:array:AmbiguousOption',thisFlag, FCN_NAME, validFlagsStr));
    end
end
end


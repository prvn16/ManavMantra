
%   Copyright 2016-2017 The MathWorks, Inc.

classdef DatetimeFamilyAdaptor < ...
        matlab.bigdata.internal.adaptors.AbstractAdaptor & ...
        matlab.bigdata.internal.adaptors.GeneralArrayParenIndexingMixin & ...
        matlab.bigdata.internal.adaptors.GeneralArrayDisplayMixin & ...
        matlab.bigdata.internal.adaptors.NoCellIndexingMixin

    properties (Access = private)
        % Local scalar of the right type. Used to check and store global
        % array properties (FORMAT, TIMEZONE).
        Proto;
    end

    properties (Dependent)
        Format
        TimeZone
    end
    
    methods (Access = private)
        function names = getDataProperties(obj)
            % Return a list of properties that extract part of the data
            if strcmp(obj.Class, 'datetime')
                names = {'Year';'Month';'Day';'Hour';'Minute';'Second'};
            else
                names = {};
            end
        end
        
        function names = getGlobalProperties(obj)
            % Return a list of properties that are global to the array
            if strcmp(obj.Class, 'datetime')
                names = {'Format';'TimeZone'};
            else
                names = {'Format'};
            end
        end
        
        function names = getStaticProperties(obj)
            % Return a list of properties that are global to all arrays
            if strcmp(obj.Class, 'datetime')
                names = {'SystemTimeZone'};
            else
                names = {};
            end
        end
        
        function unsupportedDotIndexing(obj, msgId, property)
            if ismember(property, getProperties(obj))
                % It is a property that we don't yet support
                error(message(msgId, obj.Class));
            else
                % Completely bogus property - throw MATLAB's error.
                msgId = sprintf('MATLAB:%s:UnrecognizedProperty', obj.Class);
                error(message(msgId, property));
            end
        end
    end

    methods (Access = protected)
        function m = buildMetadataImpl(obj)
            if ismember(obj.Class, {'datetime', 'duration'})
                % both have MIN/MAX, so attempt to compute.
                m = matlab.bigdata.internal.adaptors.NumericishMetadata(obj.TallSize);
            else
                % calendarDuration has no MIN/MAX, so don't even bother trying to compute them.
                m = matlab.bigdata.internal.adaptors.GenericArrayMetadata(obj.TallSize);
            end
        end
    end
    methods
        function obj = DatetimeFamilyAdaptor(varargin)
            % DatetimeFamilyAdaptor constructor.
            % a = DatetimeFamilyAdaptor(previewData) - build from preview data
            % a = DatetimeFamilyAdaptor(classNames, format) - build from classname and format
            % a = DatetimeFamilyAdaptor(classNames, format, timezone) - datetime only
            
            allowedTypes = {'datetime', 'duration', 'calendarDuration'};
            
            if ischar(varargin{1}) || isstring(varargin{1})
                % Create from classname. 
                narginchk(1,3);
                className = varargin{1};
                assert(ismember(className, allowedTypes));
                proto = feval(className);
                if nargin>=2
                    proto.Format = varargin{2};
                end
                if nargin>=3
                    proto.TimeZone = varargin{3};
                end
            else
                % Create from a local object.
                narginchk(1,1);
                className = class(varargin{1});
                assert(ismember(className, allowedTypes));
                proto = varargin{1}([]);
            end
            obj@matlab.bigdata.internal.adaptors.AbstractAdaptor(className);

            % Create a local prototype of the right class for storing the
            % global properties
            obj.Proto = proto;
        end

        function [nanFlagCell, precisionFlagCell] = interpretReductionFlags(obj, FCN_NAME, flags)

            % Datetime family types don't have any precision flags
            precisionFlagCell = {};
            
            % Only 'datetime' allows 'omitnat' as a synonym for 'omitnan'
            allowOmitNat = strcmp(obj.Class, 'datetime');
       
            omitFlags = {'omitnan'};
            includeFlags = {'includenan'};
            if allowOmitNat
                omitFlags{end+1} = 'omitnat';
                includeFlags{end+1} = 'includenat';
            end
            
            if ismember(lower(FCN_NAME), {'sum', 'mean'})
                % For SUM and MEAN, only 'native' and 'default' is supported. 
                flags = iCheckAndRemovePrecisionFlag(flags,FCN_NAME); 
            end
            
            % For datetime family operations, the only valid flag is 'omitnan' /
            % 'includenan', so we can use relatively simple parsing here.
            nanFlagCell = cell(1, numel(flags));
            for idx = 1:numel(flags)
                nanFlagCell{idx} = iExtractNanFlag(FCN_NAME, flags{idx}, omitFlags, includeFlags);
            end
            
            if ismember(lower(FCN_NAME), {'sum', 'mean','median'}) && isempty(nanFlagCell)
                % For SUM, MEAN and MEDIAN we always need to provide a default NaN flag
                nanFlagCell = {'includenan'};
            elseif numel(nanFlagCell) > 1
                error(message('MATLAB:bigdata:array:InvalidRepeatedFlag', FCN_NAME, ...
                              strjoin([omitFlags, includeFlags])));
            end
        end

        function varargout = subsrefDot(obj, pa, ~, S)
            % DOT indexing for property access. Properties come in three
            % varieties:
            % * data properties return a tall double containing part of the
            %   datetime (e.g. 'Year', 'Seconds')
            % * global properties contain a client-side value that applies
            %   to the whole array (e.g. 'Format', 'TimeZone')
            % * static properties apply to all instances of all arrays
            %   (e.g. 'SystemTimeZone')
            property = S(1).subs;
            if ~isValidPropertyName(property)
                error(message(['MATLAB:',obj.Class,':InvalidPropertyName']));
            end
            
            if ismember(property, getDataProperties(obj))
                % Data properties act element-wise, returning a double
                % array the same size as the input.
                outPa = elementfun( @(x) subsref(x, S(1)), pa );
                outAdap = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
                outAdap = copySizeInformation(outAdap, obj);
                out = tall(outPa, outAdap);
                
            elseif ismember(property, getGlobalProperties(obj))
                % Properties that are global to the whole array are stored
                % locally in the prototype.
                out = obj.Proto.(property);
                
            elseif strcmp(property,'SystemTimeZone') && strcmp(obj.Class,'datetime')
                % Datetime has a special hidden static property
                % SystemTimeZone. 
                
                % A bug on Mac (g1618935) means we must call this static
                % method using an instance to get the right answer.
                d = datetime;
                out = d.SystemTimeZone;
                
            else
                unsupportedDotIndexing(obj, 'MATLAB:bigdata:array:GetDatetimePropertiesUnsupported', property);
            end
            [varargout{1:nargout}] = iRecurseSubsref(out, S(2:end));
       end
        
        function obj = subsasgnDotDeleting(obj, ~, ~, S)
            unsupportedDotIndexing(obj, 'MATLAB:bigdata:array:SetDatetimePropertiesUnsupported', S(1).subs);
        end
        
        function out = subsasgnDot(obj, pa, szPa, S, b)
            % DOT indexing for assignment. Properties come in three
            % varieties:
            % * data properties return a tall double containing part of the
            %   datetime (e.g. 'Year', 'Seconds')
            % * global properties contain a client-side value that applies
            %   to the whole array (e.g. 'Format', 'TimeZone')
            % * static properties that are global to all values on the
            %   client (e.g. 'SystemTimeZone')
            property = S(1).subs;
            if ~isValidPropertyName(property)
                error(message(['MATLAB:',obj.Class,':InvalidPropertyName']));
            end
            if ismember(property, getDataProperties(obj))
                if numel(S)==1
                    % Data properties are set element-wise, returning a new
                    % tall array with the same adaptor as the input.
                    if istall(b)
                        b = hGetValueImpl(b);
                    end
                    outPa = elementfun( @subsasgn, pa, S(1), b );
                    outAdap = obj;
                    out = tall(outPa, outAdap);
                else
                    % Replacing part of variable - extract, update, replace.
                    tallVar = obj.subsrefDot(pa, szPa, S(1));
                    tallVar = subsasgn(tallVar, S(2:end), b);
                    out     = obj.subsasgnDot(pa, szPa, substruct('.', property), tallVar);
                end
                
            elseif ismember(property, getGlobalProperties(obj))
                % Properties that are global to the whole array are stored
                % locally in the prototype, but must also be applied to all
                % partitions.
                outAdap = obj;
                outAdap.Proto.(property) = b; % This will error-check the value
                outPa = elementfun( @(x) iAssignProperty(x,property,b), pa );
                out = tall(outPa, outAdap);
                
            elseif ismember(property, getStaticProperties(obj))
                % Assigning to static properties is not allowed
                error(message('MATLAB:datetime:ReadOnlyProperty', property));
                
            else
                unsupportedDotIndexing(obj, 'MATLAB:bigdata:array:SetDatetimePropertiesUnsupported', S(1).subs);
                
            end
        end
        
        function names = getProperties(obj)
            % Return a list of public properties for this class
            names = [
                getGlobalProperties(obj)
                getDataProperties(obj)
                ];
        end
        
        function val = get.Format(obj)
            val = obj.Proto.Format;
        end
        
        function val = get.TimeZone(obj)
            val = obj.Proto.TimeZone;
        end
        
    end

    methods (Access=protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(obj, ~, sz)
            clz = obj.Class;
            if clz == "datetime"
                sample = repmat(datetime(1,1,1), sz);
            elseif clz == "duration"
                sample = repmat(milliseconds(1), sz);
            else
                sample = repmat(caldays(1), sz);
            end
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract a single omit/include flag.
function nf = iExtractNanFlag(FCN_NAME, flag, omitFlags, includeFlags)
    n = numel(flag);
    if n > 0 && any(strncmpi(flag, omitFlags, n))
        nf = 'omitnan';
    elseif n > 0 && any(strncmpi(flag, includeFlags, n))
        nf = 'includenan';
    else
        validFlagsStr = strjoin([omitFlags, includeFlags]);
        error(message('MATLAB:bigdata:array:InvalidOption', flag, FCN_NAME, validFlagsStr));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check and remove precision flag for sum and mean.
function flags = iCheckAndRemovePrecisionFlag(flags, FCN_NAME)
nflags = numel(flags);
removeflags = false(1, nflags);
for idx = 1:nflags
    flag = flags{idx};
    n = numel(flag);
    if n > 0 && strncmpi(flag, 'double', n)
        error(message('MATLAB:duration:InvalidNumericConversion',flag));
    elseif n > 0 && (strncmpi(flag, 'default', n) ||  strncmpi(flag, 'native', n))
        removeflags(idx) = true;
    end
end
if sum(removeflags) > 1
    if strcmpi(FCN_NAME, 'sum')
        error(message('MATLAB:sum:repeatedFlagOutType'));
    else
        assert(strcmpi(FCN_NAME,'mean'), 'Precision flags are only valid for SUM and MEAN.');
        error(message('MATLAB:mean:invalidFlags'));
    end
end
flags(removeflags) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check that an input is a plausible property name
function tf = isValidPropertyName(arg)
tf = ischar(arg) || (isstring(arg) && isscalar(arg));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply remaining indexing expressions
function varargout = iRecurseSubsref(data, S)
    if isempty(S)
        varargout = {data};
    else
        [varargout{1:nargout}] = subsref(data, S);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper to do property assignment
function x = iAssignProperty(x,prop,b)
x.(prop) = b;
end
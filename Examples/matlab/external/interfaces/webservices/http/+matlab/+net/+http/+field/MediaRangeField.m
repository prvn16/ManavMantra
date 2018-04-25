classdef (Abstract, AllowedSubclasses={?matlab.net.http.field.AcceptField,...
                                       ?matlab.net.http.field.ContentTypeField}) ...
          MediaRangeField < matlab.net.http.HeaderField
%MediaRangeField Abstract base class for HeaderFields that have media types.
%  This is a common base class of ContentTypeField and AcceptField. This class
%  allows the field to contain a comma-separated list of strings as interpreted by
%  the MediaType class. Subclasses may place additional constraints on the field's
%  value.
%
%  See also AcceptField, ContentTypeField, matlab.net.http.MediaType

% Copyright 2015-2017 The MathWorks, Inc.
    methods
        function value = convert(obj)
        % convert returns a vector of MediaType objects
        %   TYPES = convert(FIELD) parses the FIELD as a comma-separated list of
        %   values and converts each value to a MediaType object. Each value is a
        %   media-type expression as defined in RFC 7231, <a href="http://tools.ietf.org/html/rfc7231#section-3.1.1.1">section 3.1.1.1</a>.
        %   This syntax is used in both the Content-Type and Accept header fields.
        %
        % See also matlab.net.http.MediaType, ContentTypeField, AcceptField
        
            % This parser returns a MxNx2 array of strings, where M is the number of
            % media types and N is the maximum number of parameters in any of those
            % types:
            %   v(i,:,:) is the i'th media type
            %   v(i,n,1) is the name of the nth parameter for the ith media type
            %   v(i,n,2) is the value of that parameter
            % Special case: the first "parameter" for each media type is the
            % type/subtype which has no parameter name:
            %   v(i,1,1) is an empty string 
            %   v(i,1,2) is the "type/subtype" string
            
            % Because we pass "true" into the last parameter to callParseField, 
            % if allowsArray() is false then the first dimension of v is dropped, so we just
            % get an Nx2 array
            if isscalar(obj)
                v = obj.callParseField(obj.Value, true);
                if ~isempty(v) && ~isempty(obj.Value) && strlength(obj.Value) ~= 0
                    if obj.allowsArray()
                        num = size(v,1);
                    else
                        num = 1;
                    end
                    % Convert the MxNx2 or Nx2 array, to a vector of M MediaType objects
                    for i = num : -1 : 1
                        if obj.allowsArray()
                            % v(i,:,:) is the ith MediaType
                            % shiftdim to make v(i,2:end,:) into an Nx2 matrix
                            % params(n,1) is name, params(n,2) is value
                            params = shiftdim(v(i,2:end,:),1);
                            mtype = v(i,1,2);
                        else
                            params = v(2:end,:);
                            mtype = v(1,2);
                        end
                        % eliminate rows containing empty names and values: these were
                        % filled in, in the case where some MediaTypes had more
                        % parameters than others
                        firstEmpty = find(strlength(params(1:end,1)) == 0 & ...
                                          strlength(params(1:end,2)) == 0, 1);
                        params(firstEmpty:end,:) = [];
                        value(i) = matlab.net.http.MediaType(mtype, params);  
                    end
                else
                    value = [];
                end
            elseif isempty(obj)
                value = matlab.net.http.MediaType.empty;
            else
                value = arrayfun(@convert, obj, 'UniformOutput', false);
                value = [value{:}];
            end
        end
    end 
    
    methods (Access=protected, Hidden)
        function obj = MediaRangeField(varargin)
        % The value is allowed to be a vector of strings or MediaTypes depending on
        % the value of allowsArray(). The MediaType may have a quality ('q')
        % parameter depending on the value of alllowsQuality().
            narginchk(0,2);
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
        
        function exc = getStringException(~, ~)
            % force scalarToString to convert and validate value
            exc = false;
        end

        function str = scalarToString(obj, value, varargin)
        % called for string because getStringException returned false
            import matlab.net.http.internal.*
            if isa(value, 'matlab.net.http.MediaType')
                mt = value;
            elseif isstring(value) || ischar(value)
                % Validate by trying to convert to MediaType.
                mt = matlab.net.http.MediaType(value);
            else
                % This path always fails
                validateattributes(value, ...
                   {'MediaType','string','char'}, {}, mfilename, 'MediaType');
            end
            str = validateType(obj, mt);
        end
        
        function tf = allowsQuality(~)
        % Returns true to indicate that the quality ('q') field has special
        % processing.
            tf = true;
        end
        
        function tf = isValidQuality(~,~)
            tf = true;
        end
    end
    
    methods (Access=private)
        function str = validateType(obj, mediaType)
        % Check that the MediaType object is valid for this field and return the
        % stringified value. If allowsQuality is not set, it must not have a "q"
        % parameter (Weight property). Also the string must not be empty.
            if ~obj.allowsQuality() && ~isempty(mediaType.Weight)
                error(message('MATLAB:http:QualityNotAllowed', obj.Name));
            end        
            str = string(mediaType);
            if strlength(str) == 0
               error(message('MATLAB:http:BadMediaType',''));
            end
        end
    end
    
    methods (Static, Access=protected, Hidden)
        function tf = useStringMatrix()
            tf = true;
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden not to do any escape or quote processing, because strings we get
        % are always the stringified result of MediaType which has already done this,
        % or have been validated by MediaType.
            tokens = [];
        end
            
    end
end




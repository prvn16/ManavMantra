classdef FormProvider < matlab.net.http.io.StringProvider
% FormProvider ContentProvider that sends form data
%   This provider creates data suitable for a request message whose Content-Type
%   is application/x-www-form-urlencoded, as required by many servers that
%   expect users to fill in HTML forms.
%
%   Using this provider in the Body of a RequestMessage is generally optional,
%   because you can insert a QueryParameter vector directly into the Body of a
%   RequestMessage to get the same conversion done automatically. 
%
%   Subclass authors may desire to create a FormProvider subclass to create the
%   data dynamically only when the message is ready to be transmitted, or during
%   transmission.
%
%   FormProvider methods:
%     FormProvider     - constructor
%     string           - return contents as a string
%   
%   FormProvider properties:
%     Parameters       - array of QueryParameters
%
% See also MultipartFormProvider

% Copyright 2017 The MathWorks, Inc.

    properties (Dependent)
        % Parameters - Array of QueryParameters
        %   This is a vector of QueryParameters as passed into or derived from the
        %   arguments to the constructor. You may set this to a QueryParameter vector
        %   or a cell array of arguments suitable for the QueryParameter constructor.
        %
        %   To see what the body of the message will look like that contains these
        %   parameters, use the string method.
        %
        % See also matlab.net.QueryParameter, string
        Parameters matlab.net.QueryParameter % dependent because set.Parameters accesses Data
    end
    
    properties (Access=private)
        RealParameters matlab.net.QueryParameter
    end
    
    methods
        function obj = FormProvider(varargin)
        % FormProvider Create a ContentProvider that sends form data
        %   PROVIDER = FormProvider(QUERYPARAMS) returns a provider that sends a vector
        %   of QueryParameter specified as QUERYPARAMS.
        %
        %   PROVIDER = FormProvider(ARGS,...) send an arbitrary list of arguments ARGS
        %   to the QueryParameter constructor to obtain a QueryParameter vector. This
        %   is simply a shortcut for:
        %         FormProvider(QueryParameter(ARGS,...))
        %   Note that, as allowed for QueryParameter, you can append a 'literal'
        %   argument to the end of the list if your arguments are already encoded.
        %
        % See also matlab.net.QueryParameter
            
            % specify us-ascii as the charset because QueryParameter.string() guarantees it.
            obj@matlab.net.http.io.StringProvider([],'US-ASCII');
            if nargin > 0
                if nargin == 1 && isa(varargin{1}, 'matlab.net.QueryParameter')
                    obj.Parameters = varargin{1};
                else
                    obj.Parameters = matlab.net.QueryParameter(varargin{:});
                end
            end
        end
        
        function set.Parameters(obj, arg)
            validateattributes(arg, {'matlab.net.QueryParameter'}, {'vector'}, mfilename, 'Parameters');
            obj.RealParameters = arg;
            obj.Data = string.empty;
        end
        
        function value = get.Parameters(obj)
            value = obj.RealParameters;
        end
        
        function str = string(obj)
        % STRING Get contents as a string
        %   STR = STRING(PROVIDER) returns the contents as a string. This information
        %   is also displayed by SHOW.
        %
        % See also show
            obj.setData();
            str = obj.string@matlab.net.http.io.StringProvider();
        end
    end
    
    methods (Access=protected)
        function complete(obj, varargin)
            ctf = obj.Header.getValidField('Content-Type');
            if isempty(ctf)
                % If there is no Content-Type field, add one
                obj.Header = obj.Header.addFields(matlab.net.http.field.ContentTypeField(...
                    'application/x-www-form-urlencoded'));
            end
            % The StringProvider will encode the characters according to the explicit or
            % default charset for the Content-Type
            obj.complete@matlab.net.http.io.StringProvider(varargin{:});
        end
        
        function start(obj)
            if isempty(obj.Data) && ~isempty(obj.RealParameters)
                % Convert QueryParameter array to string on start and store in data
                obj.setData();
            end
            obj.start@matlab.net.http.io.StringProvider();
        end
        
        function len = expectedContentLength(obj, varargin)
            if ~isempty(varargin) && varargin{1}
                obj.setData();
            end
            len = obj.expectedContentLength@matlab.net.http.io.StringProvider(varargin{:});
        end
    end

    methods (Access=private)
        function setData(obj)
        % Sets the Data property to the stringified parameters
            if isempty(obj.Data)
                obj.Data = string(obj.RealParameters);
            end
        end
    end

end
        
        
            
                
                
        
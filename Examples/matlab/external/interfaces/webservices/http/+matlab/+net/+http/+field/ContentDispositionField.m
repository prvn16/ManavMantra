classdef (Sealed) ContentDispositionField < matlab.net.http.field.GenericParameterizedField
% ContentDispositionField Content-Disposition HTTP header field    
%   This is a subclass of GenericParameterizedField that specifies the
%   Content-Disposition field, most commonly used in multipart form requests and
%   in response messages that contain files for downloading.
%
%   In a RequestMessage, FileProvider automatically creates this field to
%   specify the name of the file being uploaded, and in a ResponseMessage,
%   FileConsumer uses this field to determine the name of the file to create.
%
%   ContentTypeField properties:
%     Name      - Always "Content-Disposition"
%     Value     - Value of the field
%
%   ContentDispositionField methods:
%     ContentDispositionField  - constructor
%     convert                  - return matrix of parameter names and values
%     setParameter             - set a parameter
%     getParameter             - get a parameter
%
% See also GenericParameterizedField, matlab.net.http.RequestMessage,
% matlab.net.http.ResponseMessage, matlab.net.http.io.MultipartFormProvider,
% matlab.net.http.io.FileProvider, matlab.net.http.io.FileConsumer

% Copyright 2015-2017, The MathWorks, Inc.

    methods (Static, Hidden)
        function names = getSupportedNames
            names = 'Content-Disposition'; 
        end
    end
    
    methods
        function obj = ContentDispositionField(varargin)
        % ContentDispositionField An HTTP Content-Disposition header field
        %   FIELD = ContentDispositionField(TYPE,PARAM1,NAME1,...) creates a
        %   Content-Disposition field containing the specified parameters. See the
        %   GenericParameterizedField constructor for a description of the arguments.
        %
        % See also GenericParameterizedField.GenericParameterizedField
            obj = obj@matlab.net.http.field.GenericParameterizedField('Content-Disposition', varargin{:});
        end
    end
    
end
classdef MultipartFormProvider < matlab.net.http.io.MultipartProvider
% MultipartFormProvider ContentProvider for multipart/form-data messages
%   Use this provider to send a multipart form to the server. A multipart form
%   is a message containing a series of parts, where each part has a "control
%   name" and its data. The data can be any of the types allowed for
%   RequestMessage.Body.Data or another ContentProvider.
%
% MultipartFormProvider methods:
%
%   MultipartFormProvider - constructor

% Copyright 2017 The MathWorks, Inc.

    properties 
        Names string
    end
    
    methods
        function obj = MultipartFormProvider(varargin)
        % MultipartFormProvider Constructor for ContentProvider of multipart forms
        %   PROVIDER = MultipartFormProvider(NAME1, PART1, NAME2, PART2, ...) creates
        %   multipart/form-data content where each PART is form-data containing a NAME
        %   and its contents. The PART arguments can be any of the types supported by
        %   MultipartProvider, including other ContentProviders.
        %
        %   If a PART is an array of ContentProviders, it is equivalent to repeating the
        %   NAME,PART for each element of the array. For example, FileProvider returns
        %   an array of FileProviders if the argument is an array of strings, so you can
        %   write:
        %      MultipartFormProvider("name",FileProvider(["file1" "file2"]));
        %   as a shortcut for:
        %      MultipartFormProvider("name",FileProvider("file1"),"name",FileProvider("file2"));
        %
        %   Some servers require multiple parts under the same name to be in a nested
        %   multipart/mixed part. To send this, wrap the parts in a Multipart Provider.
        %   For example to send a message as described at the very end of <a href="https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2">chapter 17</a> 
        %   of the HTML 4.01 specification for form data:
        %
        %   fps = FileProvider(["file1.txt", "file2.gif"]); 
        %   mp = MultipartProvider(fps);
        %   formProvider = MultipartFormProvider("submit-name","Larry","files",mp);
        %   req = RequestMessage('put',[],formProvider);
        %   req.send(uri);
        
            obj@matlab.net.http.io.MultipartProvider();
            if mod(nargin,2) ~= 0
                error(message('MATLAB:http:OddNumberOfArguments'));
            end
            obj.Parts = varargin(2:2:end);
            for i = 1 : length(obj.Parts)
                % For these types, make sure the part is a scalar
                part = obj.Parts{i};
                classes = ["matlab.net.http.io.ContentProvider" 
                           "matlab.net.http.RequestMessage"
                           "matlab.net.http.MessageBody"];
                if any(class(part) == classes)
                    validateattributes(part, classes, {'scalar'}, mfilename, 'PART');
                end
            end
            obj.Names = strings(1,nargin/2);
            for i = 1 : 2 : nargin
                name = matlab.net.internal.getString(varargin{i}, mfilename, "NAME(" + (i+1)/2 + ")");
                obj.Names(i) = name;
            end
            obj.Names = varargin(1:2:end);
            badNames = ismissing(obj.Names) | strlength(obj.Names) == 0;
            if any(badNames)
                error(message('MATLAB:http:ArgMustBeString', find(badNames,1)));
            end
            obj.Subtype = 'form-data';
        end
        
    end
    
    methods (Access=?matlab.net.http.io.MultipartFormProvider)
        function headers = completePart(obj, index, ~, headers)
        % completePart complete the next part; overridden method of MultipartProvider 
        %   HEADERS = completePart(PROVIDER, INDEX, SUBINDEX, HEADERS) augments the
        %   header of this part as required for multipart form data by setting or adding
        %   the Content-Disposition field appropriately. The SUBINDEX argument is
        %   ignored because, if the part is an array, this provider uses the same header
        %   for each element of the array. 
        %
        %   However, if the part is an array of ContentProviders, each provider may
        %   have already initialized the header with its own information. Note this
        %   method is called after delegateTo in the provider.
            cdname = 'Content-Disposition';
            oldField = headers.getFields(cdname);
            if isempty(oldField)
                field = matlab.net.http.field.ContentDispositionField();
            elseif ~isscalar(oldField)
                error(message('MATLAB:http:MoreThanOneField', cdname));
            else
                field = oldField;
            end
            
            function errorOut()
                desired = char('form-data; name=' + obj.Names(index));
                error(message('MATLAB:http:ConflictingValue', char(field), desired));
            end
        
            if ~isempty(field.Type) && ~strcmpi(field.Type, 'form-data')
                errorOut()
            end
            name = field.getParameter('name');
            if ~isempty(name) && ~strcmp(name, obj.Names(index))
                errorOut()
            end
            field.Type = 'form-data';
            field = field.setParameter('name', obj.Names(index));
            if isempty(oldField)
                headers = headers.addFields(field);
            else
                headers = headers.changeFields(field);
            end
        end
    end
end

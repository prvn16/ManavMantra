classdef (AllowedSubclasses={...
         ?matlab.net.http.field.AuthenticateField, ...
         ?matlab.net.http.field.AuthenticationInfoField, ...
         ?matlab.net.http.field.AuthorizationField, ...
         ?matlab.net.http.field.CaseInsensitiveStringField, ...
         ?matlab.net.http.field.CookieField, ...
         ?matlab.net.http.field.GenericField, ...
         ?matlab.net.http.field.GenericParamValueField, ...
         ?matlab.net.http.field.IntegerField, ...
         ?matlab.net.http.field.LocationField, ...
         ?matlab.net.http.field.MediaRangeField, ...
         ?matlab.net.http.field.ScalarDateField, ...
         ?matlab.net.http.field.SetCookieField, ...
         ?matlab.net.http.field.URIReferenceField, ...
        }) HeaderField < matlab.mixin.Heterogeneous 
% HeaderField Field of an HTTP header
%   This class implements a header field of an HTTP message, providing conversions
%   between strings in the header and MATLAB arrays and structs. This field has two
%   properties, Name and Value, both strings, and in the simplest case these
%   properties may be set to arbitrary values, subject to constraints on the
%   characters allowed in HTTP header fields.
%
%   The Name field defines the "type" of this field, and for some commonly used
%   fields there are subclasses in the matlab.net.http.field package that support
%   those field types. For example matlab.net.http.field.DateField implements 'Date'
%   header field, so if you are creating one of those it is better to use that
%   subclass, which accepts a value in the form of a date-time string or a datetime
%   object. If, instead, you use HeaderField to create a 'Date' field, any Value you
%   specify for the field will be interpreted and enforced by the DateField class,
%   even though this object is not an instance of that class. Likewise, if you use
%   the convert method to convert the field value to a MATLAB datetime, the
%   DateField's convert method will be used.
%
%   To see a list of all supported subclasses, use HeaderField.displaySubclasses.
%
%   HeaderField properties:
%      Name      - name of the field (string)
%      Value     - value of the field (string)
%
%   HeaderField methods:
%      HeaderField       - constructor
%      convert           - return Value as MATLAB type
%      parse             - parse Value generically and return strings
%      addFields         - add fields to array
%      removeFields      - remove fields from array
%      changeFields      - change existing fields in array
%      replaceFields     - replace or add fields
%      getFields         - return matching fields
%      eq, ==            - compare for functional equivalence
%      isequal           - compare for functional equivalence
%      char, string      - return HeaderField as character vector or string
%      displaySubclasses - (static) display list of supported subclasses
%
% See also HeaderField, displaySubclasses, matlab.net.http.field.DateField

%   The following documentation is for internal use only. Its behavior is likely to
%   change in a future release.
%
%   Subclass authors: All subclasses must be defined in the matlab.net.http.field
%   package. Every subclass must implement getSupportedNames() to return the field
%   name, or cell array of names, that it implements.
%
%   All subclasses should override convert() and one or more of the protected methods
%   in this class to customize the subclass behavior. For example
%   getStringException() and scalarToString() should be overridden to check or
%   convert supplied field values that the caller supplies, to strings that are
%   stored in the header, and parseField() and/or parseElement() should be
%   implemented to convert a string in the header to MATLAB data types.
%
%   If a subclass's getSupportedNames() function returns vector of strings, the
%   subclass must provide a 2-argument constructor taking NAME and VALUE parameters.
%   If it returns a scalar string it must provide a 1-argument constructor that takes
%   just a VALUE. 
%   
%   A subclass constructor should invoke its superclass constructor
%   with the NAME and VALUE parameters. The subclass need not validate these
%   parameters in its constructor: the infrastructure will insure that the NAME is
%   one of those allowed by getSupportedNames(), and will invoke the subclass's
%   scalarToString() and getStringException() to insure that the VALUE is valid.

%   Copyright 2015-2017 The MathWorks, Inc. 

    properties
        % Name - name of the field (a string)
        %    When you set this property you effectively change the field's type, that
        %    may determine what values of the Value property are legal.
        %    
        %    If this is an instance of a subclass implementing a specific header
        %    field type, it will likely enforce constraints on the name you can set.
        %    If you set this to [] or an empty string, the value will become [].
        Name
    end
    
    properties (Dependent)
        % Value - value of the field (a string)
        %    When you read this property you always get a string representing the value
        %    in the field. When you set this property the value may be any type
        %    acceptable to this field based on the Name property and/or the class of
        %    this object, and the result will always be converted to a string. For
        %    field types that have a default value, specifying an empty string such as
        %    '' or "" will insert that default. Specifying an empty double, [], causes
        %    this field not to be added by RequestMessage.send or
        %    RequestMessage.complete when completing the message. Fields with [] values
        %    are not included in the completed message.
        %
        %    See also Name, parse, convert, RequestMessage
        Value
        %    For internal use only: Subclass authors may control how values are
        %    validated and converted by overriding various protected methods in this
        %    class. Default behavior, if this is not a subclass, is described in the
        %    valueToString method.
    end
    
    properties (Access=private)
        RealValue
    end
    
    
    properties (Constant, Hidden)
        % TokenChars - characters allowed in a token
        %    This is a regular expression that matches all characters allowed in a
        %    token of a header, as defined in RFC 7320, <a href="http://tools.ietf.org/html/rfc7230#section-3.2.6">section 3.2.6</a>.
        %    You can use this to assist in your own parsing of header fields.
        TokenChars = "-!#$%&'*+.^`|~a-zA-Z_0-9"
    end
    
    methods 
        function obj = set.Value(obj, value)
        % If input is an empty string, either '' or "", gets the default value from
        % getDefaultValue(). Invokes validateValue to check and/or convert the
        % value.
            if (isempty(value) && ischar(value)) || ...
                    (isstring(value) && isscalar(value) && strlength(value) == 0)
                value = obj.getDefaultValue();
            end
            % validate and/or convert value to a string
            convertedValue = validateValue(obj, obj.Name, value);  
            obj.RealValue = convertedValue;
        end
        
        function res = get.Value(obj)
            res = obj.RealValue;
        end
        
        function obj = set.Name(obj, name)
        % Verifies that name is in getSupportedNames of this object, and invokes
        % validateValue to check that the value, if already set, is permitted for
        % this name.
            import matlab.net.internal.getString
            supportedNames = obj.getSupportedNames();
            name = strtrim(getString(name, class(obj), 'Name', true)); 
            if strlength(name) == 0
                name = [];
            elseif ~isempty(name)
                if ~isempty(supportedNames) 
                    if ~any(strcmpi(name,supportedNames))
                        if ischar(supportedNames)
                            supportedNames = {supportedNames};
                        else
                        end
                        error(message('MATLAB:http:BadName', name, class(obj), ...
                                      strjoin(supportedNames)));
                    end
                elseif ~obj.isBaseClass() && ...
                       ~isa(obj, 'matlab.net.http.field.GenericField')  
                    % Class of obj allows any name and it's not this base class or
                    % instance of GenericField. Make sure user doesn't choose a name
                    % implemented by some other class, as that could result in
                    % unintentional bypass of value validation.
                    otherclass = matlab.net.http.internal.PackageMonitor.getClassForName(name);
                    match = @(x) x{1}{1};
                    nameOf = @(c) match(regexp(c, '\.([^.]+)$','tokens'));
                    if ~isempty(otherclass) && ~(metaclass(obj) >= otherclass)
                        error(message('MATLAB:http:NameUsedByOtherClass', ...
                            nameOf(class(obj)), name, nameOf(otherclass.Name)));
                    end
                else
                end
                % get any chars illegal in a name
                bad = regexp(name, '[^' + obj.TokenChars + ']', 'match', 'once');
                if ~isempty(bad) && ~ismissing(bad) && strlength(bad) ~= 0
                    error(message('MATLAB:http:BadCharInProp', ...
                                  bad, name, 'HeaderField.Name'));
                end
                validateValue(obj, name, obj.Value);   %#ok<MCSUP> because we don't change anything here
            else
            end
            obj.Name = name;
        end
        
        function obj = HeaderField(varargin)
        % HeaderField - Constructor for header field array
        %   FIELDS = HeaderField(NAME1,VALUE1,...,NAMEn,VALUEn) creates HeaderFields
        %   with the specified names and values,
        %
        %     NAME - name of the field (a string)
        %     VALUE - value of the field (a string or type appropriate for the NAME)
        %
        %   Either argument may be []. If the last VALUE is missing it is treated 
        %   as empty.
        %
        %   This constructor creates fields whose class is HeaderField. If you are
        %   creating a field of a class defined in the matlab.net.http.field package,
        %   you should use that class constructor instead. For a list of these
        %   classes, use displaySubclasses.
        %
        %   For example these two both create a 'Content-Type' field with the same
        %   Name and Value:
        %
        %     ctf = matlab.net.http.HeaderField('Content-Type','text/plain');
        %     ctf = matlab.net.http.field.ContentTypeField('text/plain');
        %  
        %   The second form is preferred because you cannot misspell the field name
        %   (as it is derived from the class name), while the first will accept any
        %   field name and you may not find out about the error until the server
        %   rejects the message. In fact, most servers silently ignore unknown field
        %   names.
        %
        %   However, assuming the field name in the first case is correct, the same
        %   validation of the VALUE takes place (in this case, that it is a valid
        %   media-type) regardless of which constructor you use.
        %
        %   If you want to create a particular HeaderField with a Name and Value that
        %   this constructor rejects, use GenericField.
        %
        % See also Name, Value, displaySubclasses,
        % matlab.net.http.field.ContentTypeField, matlab.net.http.field.GenericField
            if nargin ~= 0
                if nargin == 1 && isempty(varargin{1})
                    % This to support coercion of [] to empty array
                    obj = matlab.net.http.HeaderField.empty;
                else
                    if mod(nargin,2) > 0
                        varargin{nargin+1} = [];
                    else
                    end
                    max = length(varargin)/2;
                    obj = repmat(obj,1,max);
                    for i = max : -1 : 1
                        i2 = i*2;
                        obj(i).Name = varargin{i2-1};
                        obj(i).Value = varargin{i2};
                    end
                end
            else
            end
        end
        
        function value = convert(obj, varargin) 
        % CONVERT Return the value of a header field converted to a MATLAB type
        %   VALUES = CONVERT(FIELDS) returns an array or cell array that is the result
        %   of calling CONVERT on each header field in FIELDs. If there is a custom
        %   class for the field in the matlab.net.http.field package based on the
        %   field's Name, invokes it to convert the Value to a MATLAB value or object.
        %   Throws an exception if the conversion fails or there is no custom class
        %   that supports this Name. This method does not work on heterogeneous
        %   arrays: all members of FIELDS must be the same class.
        %
        %   VALUES is normally an array of values containing all the results of
        %   converting FIELDS. It is not necessarily the same length as FIELDS
        %   because the CONVERT method for some individual fields may return an array
        %   of values. If all converted values are not of the same type, VALUES is a
        %   cell array of the values.
        %
        %   See displaySubclasses for the list of fields supporting CONVERT. Use the
        %   parse method to process header fields for which there is no CONVERT
        %   method.
        %
        % See also Name, Value, parse, convertLike, displaySubclasses

        %   Subclass authors: you must override this to implement custom parsing of
        %   the header fields you support to return a value of the desired type, or to
        %   convert the value using array or struct delimiters other than the default
        %   (comma and semicolon). Your CONVERT method must not call this CONVERT
        %   method.
            assert(strcmp(class(obj), 'matlab.net.http.HeaderField')); %#ok<STISA> need to check exact class, not subclass
            value = convertInternal(obj, [], varargin{:});
        end
    end
    
    methods (Sealed)
        % Methods sealed so that they work on heterogeneous arrays
        
        function [fields, indices] = getFields(obj, varargin)
        % getFields Return fields from an array of HeaderField
        %   [FIELDS, INDICES] = getFields(HEADERS, IDS) returns FIELDS, a vector of
        %     HeaderField in the vector of HEADERS that match the IDS, and a vector
        %     of their INDICES. The IDS can be:
        %       - a character vector, vector of strings, comma-separated list of
        %         strings or character vectors, or cell array of character vectors
        %         naming the fields to be returned. Names are not case-sensitive.
        %       - a vector of HeaderField or comma separated list of them, whose names 
        %         are used to determine which fields to return. Names are not
        %         case-sensitive and Values of the HeaderFields are ignored.
        %       - a vector of meta.class that are subclasses of HeaderField, or 
        %         comma-separated list of them. For each class, this matches any
        %         fields that are instances of that class (including its subclasses)
        %         plus any fields whose names match the names explicitly supported by
        %         the class or its subclasses.
        %
        %         For example MediaRangeField has two subclasses, AcceptField and
        %         ContentTypeField. If you specify an ID of
        %         ?matlab.net.http.field.MediaRangeField it will match all fields of
        %         of class MediaRangeField, AcceptField and ContentTypeField, plus any
        %         fields with the Name 'Accept' or 'Content-Type' (such as
        %         matlab.net.http.HeaderField or matlab.net.http.field.GenericField).
        %
        %     If there is no match, Fields is HeaderField.empty.
        %
        %     Header field name matching is case-insensitive.
        %
        %     If there is more than one match, FIELDS is a vector containing all the
        %     matches. If they are all the same type, it is generally possible to
        %     call convert(FIELDS) to obtain a vector of their converted values.
        %     Except for the Set-Cookie field, multiple fields of the same type are
        %     allowed in a message only if the field syntax supports a comma-separated
        %     list of values.
        %
        % See also meta.class, HeaderField.convert, SetCookieField,
        % matlab.net.http.field.MediaRangeField, matlab.net.http.field.AcceptField,
        % matlab.net.http.field.ContentTypeField
            fields = matlab.net.http.HeaderField.empty;
            if isempty(varargin)
                error(message('MATLAB:minrhs'));
            end
            % look for HeaderField instances in args
            ids = matlab.net.http.HeaderField.getFieldsVector(varargin);
            if isempty(ids)
                % no HeaderFields; it should be names or meta.class objects; see if meta.class
                ids = matlab.net.http.HeaderField.getFieldsVector(varargin,'meta.class');
                if isempty(ids)
                    % not meta.class, or all invalid meta.classes, or (assumed) strings
                    if isa(ids, 'meta.class')
                        % they are nonexistent classes
                        error(message('MATLAB:http:NotClasses'));
                    else
                        % not HeaderField or meta.class, so assume strings
                        ids = matlab.net.http.HeaderField.getNameVector(varargin);
                    end
                else
                    % at least one argument is a valid meta.class; see if all are HeaderField
                    validClasses = ids < ?matlab.net.http.HeaderField;
                    if ~all(validClasses)
                        badClass = ids(find(~validClasses,1));
                        error(message('MATLAB:http:NotHeaderField', badClass.Name));
                    end
                end
            else
            end
            % get the names and classes of all fields matching ids, a vector of strings or
            % meta.classes
            names = matlab.net.http.HeaderField.getMatchingNames(ids);
            if isa(ids, 'meta.class')
                classes = ids;
            else
                classes = [];
            end
            indices = [];
            if ~isempty(obj)
                hdrNames = [obj.Name];
                matches = zeros(1,length(hdrNames));
                % first match the names
                for j = 1 : length(names)
                    matches = matches | strcmpi(names(j), hdrNames);
                end
                if ~isempty(classes)
                    % next match the classes, if any
                    matches = matches | ...
                        arrayfun(@(hdr) any(metaclass(hdr) <= classes), obj); 
                else
                end
                fields = obj(matches);
                if nargout > 1
                    indices = find(matches);
                else
                end
            else
            end 
        end
                
        function tf = eq(obj,other)
        % == Compare two HeaderField arrays 
        %   A == B does an element by element comparison of two HeaderField arrays,
        %   returning an array of logicals indicating matching elements. The arrays
        %   must have the same dimensions, unless one is a scalar.
        %
        %   Two HeaderFields are considered equal if they are functionally
        %   equivalent, even if not identical. This means their Names match using a
        %   case-insensitive compare, and their Values match based on using isequal
        %   on the result of convert(), if convert() is supported for the HeaderField
        %   type. If convert() is not supported, comparisons are based on a
        %   case-sensitive match of the Value strings.
        %
        %   This comparison only uses the Name and Value properties and ignores the
        %   actual classes of A and B, as long as both are instances of HeaderField.
        %   For example, the last line below evaluates to true, even though one is
        %   a HeaderField and the other is a DateField, because their values are the
        %   same and DateField.Name is always 'Date'.
        %
        %      import matlab.net.http.HeaderField
        %      dt = datetime('now');
        %      HeaderField('date', dt) == matlab.net.http.field.DateField(dt)
        %
        % See also Name, Value, matlab.net.http.field.DateField, convert
        
            tf = isa(obj, 'matlab.net.http.HeaderField') && ...
                 isa(other, 'matlab.net.http.HeaderField');
            if tf
                % compare two strings, where [] == [] is true
                cmpi = @(a,b) (isempty(a) && isempty(b)) || ...
                             (~isempty(a) && ~isempty(b) && strcmpi(a,b));
                % return logical array comparing scalar x to each element of array y
                fun = @(x,y) arrayfun(@(y) cmpi(x.Name, y.Name) && ...
                                           cmpv(x, y), y);
                % do scalar expansion if one is a scalar and the other not 
                if isscalar(other) 
                    tf = fun(other, obj);
                elseif isscalar(obj) 
                    tf = fun(obj, other);
                elseif ndims(obj) == ndims(other) && all(size(obj) == size(other))
                    tf = arrayfun(@(x,y) x == y, obj, other);
                    if isempty(tf)
                        % this can occur if obj and other are both HeaderField.empty
                        tf = true;
                    else
                    end
                else
                    error(message('MATLAB:dimagree'));
                end
            else
            end
            
            function tf = cmpv(a,b)
            % Compare the values of two HeaderField objects with the same name for
            % equality. If the Value fields are not equal, use the convert() method
            % to get the values and compare the result. 
                tf = isempty(a.Value) && isempty(b.Value);
                if tf
                    return   % both empty
                end
                tf = isempty(a.Value) == isempty(b.Value);
                if ~tf
                    return   % only one empty
                end  
                % both not empty
                tf = strtrim(a.Value) == strtrim(b.Value);
                if tf
                    return   % strings equal
                end  
                % strings not equal, call convert
                try
                    c1 = a.convert();
                    c2 = b.convert();
                    % do isequal comparison first because it works on any object
                    % type; do == in case object implements scalar expansion
                    tf = isequal(c1,c2) || all(c1 == c2);
                catch 
                    % convert() not supported or couldn't compare using isequal or eq
                    tf = false;
                end
            end
        end
        
        function tf = isequal(obj,other)
        % isequal True if two HeaderField arrays are equal
        %   The arrays must be the same size and corresponding elements must compare
        %   equal according to eq.
        %
        % See also eq.
            tf = isequal(size(obj), size(other)) && all(obj == other);
        end
        
        function value = convertLike(obj, other, varargin) 
        % convertLike Convert the value of a header field like another header field
        %   VALUES = convertLike(FIELDS, OTHER) returns the value of the field
        %   converted to a MATLAB type, using conversion rules of the field OTHER.
        %   OTHER is a string, character vector, HeaderField or meta.class identifying
        %   a custom HeaderField subclass. This performs the same action as convert
        %   but allows you to process the value of any header field as if it were
        %   another header field.
        %
        %   Use this when you have a header field of a type for which MATLAB does not
        %   have a custom type, but which has content that can be parsed by one of the
        %   custom types. For example, suppose you receive a message that has a
        %   header field with the name 'Created-Date' whose contents is formatted like
        %   the HTTPDateField. Since MATLAB does not recognize 'Created-Date' as a
        %   custom header field, you can write the following to retrieve a datetime
        %   from the value.
        %
        %     myField = response.getFields("Created-Date");
        %     date = myField.convertLike(?matlab.net.http.field.HTTPDateField);
        %
        %   See displaySubclasses for the list of fields supporting convertLike.
        %
        % See also convert, displaySubclasses
            if ~ischar(other)
                validateattributes(other, {'string','matlab.net.http.HeaderField','meta.class'}, {'scalar'}, 'convertLike', 'OTHER');
            end
            if isa(other, 'matlab.net.http.HeaderField')
                otherClass = metaclass(other);
                otherField = other;
            elseif isa(other, 'meta.class')
                otherClass = other;
                if ~(otherClass < ?matlab.net.http.HeaderField)
                    error(message('MATLAB:http:NotHeaderFieldSubclass', otherClass.Name));
                end
                otherField = [];
            else 
                otherArg = matlab.net.internal.getString(other, 'convertLike', ...
                                    'OTHER', false, {'meta.class','HeaderField'}); 
                validateattributes(char(otherArg), {'char'}, {'nonempty'}, 'convertLike', 'OTHER');
                otherField = [];
                otherClass = matlab.net.http.internal.PackageMonitor.getClassForName(otherArg);
                if isempty(otherClass)
                    error(message('MATLAB:http:NoCustomConversion', otherArg));
                end
            end
            if isempty(otherField)
                % if we don't have a name for the other class, need to pick a supported one
                otherName = matlab.net.http.internal.PackageMonitor.getNamesForClass(otherClass);
                if isempty(otherName)
                    otherName = 'dummy';
                else
                    otherName = otherName(1);
                end
                otherField = createField(otherName);
                assert(~isempty(otherField)); % can't happen because we used supported name
            end
            value = convertInternal(obj, otherField, varargin{:});
        end
        
        function obj = changeFields(obj, varargin)
        % changeFields changes values in an array of HeaderFields
        %   FIELDS = changeFields(FIELDS,NAME1,VALUE1,...,NAMEn,VALUEn) returns a copy of
        %     the FIELDS array with changes to the values of existing fields.
        %     NAME is the name of the field and VALUE is the new value.
        %     The last VALUE, if missing, is assumed to be [].
        %
        %     NAME matching is case-insensitive; however if the NAME you specify
        %     differs in case from the existing name, then the field's name will be
        %     changed to NAME. This usage will never change the class of an existing
        %     field in FIELDS.
        %     
        %   FIELDS = changeFields(FIELDS,NEWFIELDS) changes existing FIELDS to the names,
        %     values and types in NEWFIELDS, a vector of HeaderFields or comma-separated
        %     list of them. Matching is by case-insensitive Name. This may change the
        %     class of an existing field if its Name is a case-insensitive match to the
        %     Name in NEWFIELDS.
        %
        %  This method is designed to modify existing fields. It throws an error if all
        %  the specified fields are not already in the header of each message, or if
        %  there is more than one match to a specified field.
        %
        % See also addFields, removeFields, getFields, replaceFields
        
            % get the argument list in the form of a HeaderField array
            % useClasses is true if the argument list was a HeaderField array
            [fields, useClasses] = obj.getInputsAsFields(true, false, varargin{:});
            obj = obj.changeFieldsInternal(fields, useClasses, false);
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'changeFields');
        end
        
        function obj = replaceFields(obj, varargin)
        % replaceFields changes values in or adds fields to an array of HeaderFields
        %   FIELDS = replaceFields(FIELDS,NAME1,VALUE1,...,NAMEn,VALUEn)
        %   FIELDS = replaceFields(FIELDS,NEWFIELDS)
        %   This method is the same as changeFields, but if a field does not already
        %   exist, adds a new one to the end of FIELDS instead of throwing an error.
        %
        % See also addFields, removeFields, getFields, changeFields
            [fields, useClasses] = obj.getInputsAsFields(true, false, varargin{:});
            obj = obj.changeFieldsInternal(fields, useClasses, true);
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'replaceFields');
        end    
        
        function obj = addFields(obj, varargin)
        % addFields Add fields to an HTTP HeaderField array
        %   FIELDS = addFields(FIELDS,NEWFIELDS) returns a copy of the HeaderField array
        %     FIELDS with NEWFIELDS added to the end of the array. NEWFIELDS is a vector
        %     of HeaderField objects or comma separated list of them. There is no check
        %     for duplicate fields.
        %
        %   FIELDS = addFields(FIELDS,NAME1,VALUE1,...,NAMEn,VALUEn) adds fields with NAME 
        %     and VALUE to end of FIELDS. A VALUE may be '' to use the default value
        %     for the field (usually, but not necessarily, []). If the last VALUE
        %     is missing, it is the same as specifying []. The type of
        %     HeaderField object created depends on its NAME, and any VALUEs are
        %     validated for that type.
        %
        %   FIELDS = addFields(FIELDS,INDEX,___) inserts fields at the specified INDEX in 
        %     FIELDS. Can be used in combination with any of above. Adds to end if
        %     INDEX is greater than length of FIELDS. If INDEX is negative, counts
        %     from end of header, where 0 adds fields to the end and -1 inserts
        %     fields before the last field.
        %
        % See also getFields, changeFields, removeFields, replaceFields
        
        % Undocumented behavior for internal use only -- this may change in a future
        % release:
        %   addFields(STRUCTS) - array of structures containing Name and Value
        %     fields.
            [fields, where] = obj.getInputsAsFields(false, true, varargin{:});
            obj = obj.addFieldsInternal(where, fields);
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'addFields');
        end
        
        function obj = removeFields(obj, varargin)
        % removeFields Remove fields from an HTTP HeaderField array
        %   FIELDS = removeFields(FIELDS, IDS) returns a copy of the HeaderField array 
        %   FIELDS all fields matching IDS removed. The IDS can be:
        %     - a character vector, vector of strings, comma-separated list of
        %       strings or character vectors, or cell array of character vectors
        %       naming the fields to be removed. Names are not case-sensitive.
        %     - a vector of HeaderField or comma-separated list of them, whose names 
        %       are used to determine which fields to remove. Names are not
        %       case-sensitive and Values of the HeaderFields are ignored.
        %     - a vector of meta.class that are subclasses of HeaderField, or
        %       comma-separated list of them. For each class, this matches any fields
        %       that are instances of that class (including its subclasses) plus any
        %       fields whose names match the names explicitly supported by the class
        %       or its subclasses.
        %
        %   For example MediaRangeField has two subclasses, AcceptField and
        %   ContentTypeField. If you specify an ID of
        %   ?matlab.net.http.field.MediaRangeField it will match all fields of
        %   class MediaRangeField, AcceptField and ContentTypeField, plus any fields
        %   with the Name 'Accept' or 'Content-Type' (such as
        %   matlab.net.http.HeaderField or matlab.net.http.field.GenericField).
        %
        % See also addFields, changeFields, getFields, replaceFields
        
            [names, classes] = obj.getNamesAndClasses(varargin);
            obj = obj.removeFieldsInternal(names, classes);
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'removeFields');
        end
                
    end
    
    methods (Static, Hidden)
        function names = getSupportedNames()
        % getSupportedNames return field names that this class supports
        %   This is intended to be implemented by subclasses to declare the names of
        %   header fields the subclass supports. Return value is a string vector.
        %
        %   Each time you set the Name or Value field of a HeaderField object
        %   (not a subclass), the set.Name and set.Value methods query this method in
        %   all the subclasses in the matlab.net.http.field package to see which ones
        %   implement the Name. Most specific subclass implementing the Name is
        %   invoked (via a constructor call) to validate the provided Name and Value.
        %
        %   If getSupportedNames returns just a single string, indicating that the
        %   subclass supports only one Name, the set.Value and set.Name methods of
        %   HeaderField invoke the subclass constructor with just the Value. If it
        %   returns a vector, indicating that the subclass implements multiple names,
        %   the constructor is invoked with both Name and Value arguments.
        %   
        %   This method is also queried when the infrastructure forms a
        %   ReponseMessage received from a server, to populate the Header array in
        %   the ResponseMessage with appropriate subclasses of HeaderField.
        %
        %   If this method returns [] (the default) it indicates this is a support
        %   class or base class that will not be considered by the infrastructure to
        %   be an implementation of any particular field type. Even though this base
        %   class returns [], you must still override this to return [] if your class
        %   supports any name, or a warning will be thrown.
        %
        %   Subclasses that extend other subclasses that implement this method should
        %   override this method if they don't implement all the supported names of
        %   their immediate superclass. If they implement the same name as one or
        %   more of their superclasses, the subclass will be used for that name
        %   instead of the superclass.
        %
        %   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
        %   and is intended for use only within the scope of functions and classes
        %   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
        %   may change, or the function itself may be removed in a future release.
        names = [];
        end
    end
    
    methods (Sealed, Static, Hidden)
        
        function [field, isBase] = createHeaderField(varargin)
        % createHeaderField Create the appropriate HeaderField subclass
        %  FIELD = createHeaderField(NAME,VALUE) create field with NAME and VALUE
        %   This is a factory method to create a new header field. If NAME is not
        %   empty, it looks in the matlab.net.http.field package for a subclass of
        %   matlab.net.http.HeaderField whose getSupportedNames() method returns
        %   NAME. If so, it invokes that subclass's constructor, possibly throwing an
        %   error if VALUE is invalid for that sublcass. If there is no subclass it
        %   invokes the base class HeaderField constructor. NAME must be empty or a
        %   string. The type of VALUE may be any type that the constructor accepts.
        %
        %  [NEWFIELD, ISBASE] = createHeaderField(FIELD) create a possibly new field
        %   from FIELD. In this usage an existing FIELD is provided. If class(FIELD) is
        %   matlab.net.http.HeaderField, then the Name and Value of FIELD are used as
        %   above to possibly construct a new object of the appropriate subclass.
        %   Otherwise FIELD is simply returned. ISBASE is true if class(NEWFIELD) is 
        %   matlab.net.http.HeaderField.
        %
        %   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
        %   and is intended for use only within the scope of functions and classes
        %   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
        %   may change, or the function itself may be removed in a future release.
            if nargin == 1
                field = varargin{1};
                validateattributes(field, {'matlab.net.http.HeaderField'}, ...
                                   {'scalar'}, 'createHeaderField');
                if ~field.isBaseClass()
                    isBase = false;
                    return;
                else
                    name = field.Name;
                    value = field.Value;
                end
            else
                narginchk(2, 2);
                name = varargin{1};
                if ~isempty(name)
                    name = matlab.net.internal.getString(name, ...
                                      mfilename,'Name');
                else
                end
                value = varargin{2};
            end
            field = createField(name, value); % may throw exception
            if isempty(field)
                isBase = true;
                field = matlab.net.http.HeaderField(name, value);
            else
                isBase = false;
            end
        end
    end
    
    methods (Access = private)
        function rval = validateValue(obj, name, value)
        %   name  string object or []
        %   value whatever the user specified
        %   rval  string or []
        % Called whenever the Name or Value property in this object is set, to
        % validate and/or convert the value to an appropriate string for Value of the
        % header field with this name. If the name and value are both nonempty and
        % this object is not a subclass, look for a subclass that implements the Name
        % and use it to validate or convert the value, and return that value.
        % Otherwise if no appropriate subclass is found use a generic converter in
        % this base class. If this is a subclass already, we trust that the subclass
        % has overridden valueToString or scalarToString to convert the value to a
        % string, so we'll just call those functions.
            if isempty(value) && ~ischar(value) 
                % If [] nothing to validate
                rval = [];
            elseif isempty(name)
                % no name; call converter. It will be the
                % generic converter in the base class, or a possibly custom
                % converter in the subclass.
                rval = obj.callValueToString(value);
            elseif ~obj.isBaseClass()
                % Name specified and we're a subclass
                % Make sure name is legal for this subclass
                names = obj.getSupportedNames();
                if ~isempty(names) && ~any(strcmpi(name, names))
                    error(message('MATLAB:http:IllegalNameForField', name, ...
                        strjoin(cellstr(names)), class(obj)));
                end
                % Name OK; call converter. It will be the
                % generic converter in the base class, or a possibly custom
                % converter in the subclass.
                rval = obj.callValueToString(value);
            else
                % Name specified and we're the base class: see if there's a subclass
                % for this name. If so, fetch its value (which does necessary
                % validation and conversion).
                field = createField(name, value);
                if isempty(field)
                    % no subclass, so use generic converter
                    rval = obj.callValueToString(value);
                else
                    rval = field.Value;
                end
            end
        end
        
        function errorCheck(obj, str, value)
        % Throw an appropriate error if str is []. Intended to be called after
        % obj.scalarToString(value) to determine whether conversion succeeded.
            if ~ischar(str) && isempty(str) 
                obj.throwValueError('MATLAB:http:BadFieldValue', value);
            end
        end
        
        function tf = isBaseClass(obj)
        % True if this is the base class
            tf = strcmp(class(obj),'matlab.net.http.HeaderField'); %#ok<STISA>
        end
        
        function rval = callValueToString(obj, value)
        % Call valueToString(value) with zero, one or two additional arguments.
        % Behavior of this is subclass-specific, as it uses allowsStruct() and
        % allowsArray(), so it may change when a subclass is added in the future, but
        % such a change should only be to allow new types of values to be specified or
        % to more strictly enforce constraints on the syntax of the value.
            if obj.allowsStruct()
                rval = obj.valueToString(value, ', ', '; ');
            elseif obj.allowsArray()
                rval = obj.valueToString(value, ', ');
            else
                rval = obj.valueToString(value);
            end
            % Disallow non-visible characters other than space and tab, and all must
            % be ASCII. This is defined as field-content in
            % http://tools.ietf.org/html/rfc7230#section-3.2, which is sequence of
            % VCHAR (%21-7E), SP (%20), HTAB (%09) or obs-text (%80-FF).
            badChar = regexp(rval, '[^\x09\x20-\x7e\x80-\xff]', 'match', 'once');
            if ~isempty(badChar) && ~ismissing(badChar) && strlength(badChar) ~= 0
                % print illegal char in hex, as it's not likely visible
                error(message('MATLAB:http:IllegalCharInValue', ...
                              dec2hex(char(badChar),2)));
            end
        end
        
        function rval = quoteTokens(obj, value, index, fieldName, delims)
        % Quote any tokens in value, if needed. See quoteValue() for detailed
        % description of quoting. 
        %    value - the string, converted from user input
        %    index (optional) - the index of this value in array of input values, 
        %                       always at least 1 if present.
        %    fieldName (optional) - the name of the field, if this value came from a 
        %                           struct; else [].
        %    delims (optional) - delimiters
        % This function calls out to getTokenExtents() to determine where the tokens
        % lie in the value.
            if isempty(value)
                rval = value;
                return;
            end
            if nargin < 4
                fieldName = [];
                if nargin < 3
                    index = 1;
                else
                end
            else
            end
            extents = obj.getTokenExtents(value, index, fieldName);
            if ~isempty(extents)
                value = char(value); 
                rval = "";
                eEnd = 0;
                for i = 1 : size(extents, 1)
                    % first insert any non-token chars before token
                    eStart = extents(i,1);
                    if eStart > eEnd + 1
                        pad = value(eEnd+1:eStart-1);
                        rval = rval + pad;
                    else
                    end
                    eEnd = extents(i,2);
                    % inserted quoted token
                    if nargin > 4
                        val = obj.quoteValue(value(eStart:eEnd), delims);
                    else
                        val = obj.quoteValue(value(eStart:eEnd));
                    end
                    rval = rval + val;
                end
                % add remaining chars after token
                rval = rval + value(eEnd+1:end);
            else
                rval = string(value);
            end
        end
        
        function tf = isStringMatrix(obj, value)
        % Return true if useStringMatrix() and value is an Nx2 string matrix
            tf = obj.useStringMatrix() && isstring(value) && ismatrix(value) && ...
                 size(value,2) == 2;
        end
        
        function str = defaultConvert(obj, value)
        % defaultConvert Convert the value to a string using default conversion rules.
        %   This converts a single scalar value taken from an array or struct member
        %   provided by the user. Caller has verified that value is a scalar or char
        %   vector. Does not determine whether value needs to be quoted.
        %
        %   If numeric, error out if not real
        %   Convert using string (which converts numbers like num2str)
        %   If that errors, convert using char
        %   If that errors, throw error
        %   If result is not a scalar string, throw error
            if isnumeric(value)
                validateattributes(value, {'numeric'}, {'real'}, class(obj), 'Value');
                str = string(value);
            else
                e = [];
                try
                    str = string(value); % handles string, char, numbers
                catch
                    try 
                        str = string(char(value));
                    catch e
                    end
                end
                % Handle cases where value might override char or string to return something
                % unexpected, like a matrix or non-string. Use disp to display value in
                % message.
                if ~isempty(e) || ~isscalar(str) || ~isstring(str)
                    error(message('MATLAB:http:CannotConvertToString', ...
                                  strtrim(evalc('disp(value)'))));
                end
            end
        end
        
        function value = convertInternal(obj, field, varargin)
        % convertInternal Convert obj.Value like field. If field is [], use the rules
        % of the custom class that implements obj.Name. obj may be an array; returns
        % vector or cell vector.
            if isscalar(obj)
                % if field specified, copy our value into it and request convert
                % otherwise create a new field using current field's name
                if ~isempty(field)
                    % This may throw an exception if the value is illegal for the field
                    field.Value = obj.Value;
                else
                    if isempty(obj.Name) || strlength(obj.Name) == 0
                        error(message('MATLAB:http:NameEmpty'));
                    end
                    field = createField(obj.Name, obj.Value);
                    if isempty(field)
                        error(message('MATLAB:http:NoCustomConversion', obj.Name));
                    end
                    % The call to convert below will recurse forever if field is the same class as
                    % this object. This can only happen if a subclass of HeaderField calls
                    % HeaderField.convert, which isn't allowed.
                    assert(~strcmp(class(field),class(obj)));
                end
                value = field.convert(varargin{:});
            elseif isempty(obj)
                value = [];
            else
                convertit = @(o) convertInternal(o, field, varargin{:});
                value = arrayfun(convertit, obj, 'UniformOutput', false);
                try
                    % try putting all values into array; if fails, keep cell array
                    value = [value{:}];
                catch
                end
            end
        end
    end
    
    methods (Sealed)
        function value = parse(obj,varargin)
        % PARSE  Parse the Value of the header field and return strings
        %   This function parses the Value according to a generic set of rules, where
        %   all the values are returned as string objects. Use this method to
        %   process header fields for which there is no custom convert method.
        %
        %   VALUE = PARSE(obj)
        %     The Value of the header field is parsed according to a generic set of
        %     rules, where all the values are returned as string objects. The Value
        %     is first parsed as a list of comma-separated strings, each of which
        %     become elements of the result vector. Each element will be treated
        %     either a simple string, struct of semicolon-separated values, or struct
        %     of NAME=VALUE pairs. The NAME of each struct field will be converted to
        %     a valid MATLAB identifier using matlab.lang.makeValidName and
        %     matlab.lang.makeUniqueStrings to resolve duplicates. If a struct field
        %     is a simple token (i.e., just a VALUE and not a NAME=VALUE), the name
        %     'Arg_N' will be used for the field, where N is the ordinal position of
        %     the field in the struct.
        %
        %     This function uses parsing rules based in part on sections 3.2.4-3.2.6
        %     of <a href="http://tools.ietf.org/html/rfc7230">RFC 7230</a>, and augmented to interpret multiple values, and it assumes
        %     that the field may contain multiple values (vectors) or name-value
        %     pairs (structs). Therefore, for example, if the value contains a quoted
        %     string, it is processed as a single token, where delimiters in the
        %     string become part of the string and the result is the string with
        %     quotes and backslashes of quoted pairs removed. Comments (text
        %     surrounded by open-closed parentheses) are retained (including the
        %     parentheses), but are treated as single tokens with possible escapes,
        %     similar to quoted strings.
        %
        %     If the field contains one or more comma-separated elements, none of
        %     which look like structs (i.e., have no semicolons or = signs) the VALUE
        %     returned is a vector of strings. If any of the values look like
        %     structs, VALUE is an array of structs.
        %
        %     If the input is a vector of HeaderFields, this method concatentates the
        %     results of parsing each of the fields into a single array. This could
        %     result in a cell array if the values are not of the same type.
        %
        %   VALUE = PARSE(obj, FIELDS)
        %     This lets you specify the names of struct fields to be created that are
        %     not named. FIELDS is a string vector, char vector or cell array of char
        %     vectors. If the Nth field of a struct has no name, and corresponding
        %     Nth name in FIELDS exists and is nonempty, it will be used instead of
        %     Arg_N. Using this syntax forces the returned value to be a struct (or
        %     vector of them) with at least as many fields as the length of FIELDS.
        %     Typically this pattern occurs in header fields that begin with a token
        %     followed by name=value pairs. For example, consider a field with the
        %     syntax:
        %
        %         media-type; name1=value1; name2=value2; ... 
        %
        %     where "media-type" consists of just a value, rather than a name=value
        %     pair. Its struct field name would therefore be Arg_1. If you want that
        %     first field to be called "MediaType", you can specify:
        %
        %           headerField.PARSE('MediaType');
        %
        %   VALUE = PARSE(___, PARAM1, VALUE1, ... , PARAMn, VALUEn)
        %     Specifies the delimiters to use for arrays and structs, instead of
        %     comma and semicolon. Valid parameter names are:
        %        'ArrayDelimiters'   specifies delimiters separating array elements
        %        'MemberDelimiters'  specifies delimiters separating struct fields
        %     The parameter name is case-insensitive, but the full word must be
        %     specified. The VALUE of a PARAM is a string vector, char vector or cell
        %     vector of regular expressions specifying the possible delimiters,
        %     interpreted in the order they appear in the vector. Specify '' if you do
        %     not want this field to be parsed as an array or struct, but you still want
        %     quoted string and escape processing. Specify [] if you do not want the
        %     field to be parsed as an array or struct and also do not want quoted
        %     string or escape processing within that array element or struct value. 
        %
        %     If one of the MemberDelimiters is, '\s' or ' ' (i.e., whitespace or a
        %     single space character) then whitespace will be considered a delimiter
        %     except where it appears to be surrounding the "=" of a name=value pair.
        %     This allows parsing of "bad whitespace" as defined in RFC 7230, 
        %     <a href="https://tools.ietf.org/html/rfc7230#section-3.2.3">section 3.2.3</a>.
        %
        %   As an example, with no optional parameters, the following field value:
        %
        %      text/plain;q=0.5;format=flowed, text/*;level=1, image/jpeg
        %
        %   will be interpreted as an returned as an array of 3 structs:
        %
        %      Arg_1:   'text/plain'  'text/*'   'image/jpeg'
        %          q:   '0.5'         []         []
        %     format:   'flowed'      []         []
        %      level:   []            '1'        []
        %
        %   The empty fields were added because a struct array must have the same
        %   fields in all elements.
        %
        %   As another example, consider the header field:
        %
        %     Server: CERN/3.0  libmww/2.17   foo
        %
        %   The following:
        %
        %     VALUE = PARSE(obj, {'product','comment'}, 'ArrayDelimiters', '\s', 
        %                                               'MemberDelimiters', '/')
        %   returns an array of 3 structs:
        %
        %     product:   'CERN'    'libmww'   'foo'
        %     comment:   '3.0'     '2.17'     []
        %  
        %   To obtain the value as a cell array of strings without interpreting the
        %   strings as possible structs:
        %
        %    VALUE = PARSE(obj, 'ArrayDelimiters', '\s', 'MemberDelimiters', [])
        %
        %   returns:
        %
        %    ["CERN/3.0", "libmww/2.17", "foo"]
        %
        % See also Name, Value, matlab.lang.makeValidName, convert
        % matlab.lang.makeUniqueStrings
        
        % Internal behavior, for subclass designers:
        %   An additional PARAM,VALUE pair is supported:
        %      '_custom'  true if we should invoke subclass-specific behavior to parse
        %                 this field, by invoking functions such as allowsArray() or
        %                 allowsStruct() that subclasses may override. Subclasses
        %                 should set this property to invoke that behavior. Default
        %                 is false.
            import matlab.net.internal.*
            skip = false;
            custom = false;
            % This argument parser actually allows the FIELDS parameter to be in any
            % position
            persistent publicParams params paramsStr
            if isempty(params)
                publicParams = {'arraydelimiters','memberdelimiters'};
                params = [publicParams '_custom'];
                paramsStr = string(params);
            end           
            for i = 1 : length(varargin)
                if skip
                    skip = false;
                    continue;
                end
                arg = varargin{i};
                if iscell(arg) || (isstring(arg) && ~isscalar(arg)) 
                    % If array of strings, it's structFields
                    if exist('structFields','var')
                        error(message('MATLAB:http:DuplicateStructFields'));
                    end
                    structFields = getStringVector(arg, mfilename, 'FIELDS', true);
                else
                    % Not array of strings; must be single string. Need to disambiguate between a
                    % named parameter or a 1-element FIELDS array that happens to have the name of
                    % a named parameter.
                    strarg = getString(arg, class(obj), 'FIELDS');
                    % If we already have FIELDS, assume named parameter if it's not the last
                    % argument. 
                    lastarg = length(varargin) == i;
                    if ~lastarg
                        nextarg = varargin{i+1};
                    end
                    isnamed = exist('structFields','var') && ~lastarg;
                    %  ~isnamed at this point says it might be FIELDS.
                    if ~isnamed && ~lastarg
                        % Might be FIELDS and there is another argument. Assume it's FIELDS if the
                        % next argument is a named parameter. otherwise assume (for now) this is a
                        % named parameter. Arbitrarily assume that the next argument is a named
                        % parameter only if has at least 5 chars. If wrong, we'll still use that as a
                        % named parameter if the current argument isn't one.
                        nextarg = varargin{i+1};
                        isnamed = ~((isstring(nextarg) || ischar(nextarg)) && ...
                                    strlength(string(nextarg)) > 5 && ...
                                    any(paramsStr.startsWith(lower(nextarg))));
                    end
                    if isnamed
                        % come here if named parameter is the only valid option or if
                        % next argument isn't a named parameter
                        assert(~lastarg); % impossible due to above
                        e = [];
                        try
                            % check for named parameter but don't error out if it's not in this list
                            strarg = validatestring(strarg, params);
                        catch e
                        end
                        if isempty(e)
                            % named parameter found
                            switch strarg
                                case 'arraydelimiters'
                                    if ~isempty(nextarg)
                                        nextarg = getStringVector(nextarg, class(obj), arg);
                                    end
                                    arrayDelims = nextarg;
                                    skip = true;
                                case 'memberdelimiters'
                                    if ~isempty(nextarg)
                                        nextarg = getStringVector(nextarg, class(obj), arg);
                                    end
                                    structDelims = nextarg;
                                    skip = true;
                                case '_custom'
                                    validateattributes(nextarg, {'logical'}, {'scalar'}, 'HeaderField.parse', arg);
                                    custom = nextarg;
                                    skip = true;
                            end
                        else
                            % If not a named parameter, it's an error if we already have a FIELDS
                            % argument. If not, assume it's FIELDS and not a named parameter.
                            if exist('structFields','var')
                                % for purposes of the message, only list the publicParams
                                validatestring(strarg, publicParams, mfilename);
                            else
                                structFields = strarg;
                            end
                        end
                    else
                        % If not a named parameter, assume FIELDS
                        if exist('structFields','var')
                            validatestring(strarg, publicParams, mfilename);
                            error(message('MATLAB:http:MissingValueForParam', arg));
                        end
                        structFields = strarg;
                    end
                end
            end
            if ~exist('arrayDelims','var')
                arrayDelims = ',';
            end
            if exist('structFields','var')
                % After removing empty placeholders, check for illegal or duplicate names. 
                sf = structFields(strlength(structFields) ~= 0); 
                invalid = find(arrayfun(@(s) ~isvarname(char(s)), sf), 1); % get first invalid name
                if ~isempty(invalid)
                    error(message('MATLAB:http:InvalidFieldName', sf(invalid)));
                end
                if length(unique(sf)) ~= length(sf)
                    error(message('MATLAB:http:NamesNotUnique', strjoin('"' + sf + '"')));
                end
            end
            if exist('structDelims','var')
                % these always return struct
                if exist('structFields','var')
                    value = parseField(obj, arrayDelims, structDelims, structFields, custom);
                else
                    value = parseField(obj, arrayDelims, structDelims, custom);
                end
            else
                if exist('structFields','var')
                    % this forces return of struct
                    value = parseField(obj, arrayDelims, ';', structFields, custom);
                else
                    % this possibly returns plain string(s) if no semicolons or equals
                    value = parseField(obj, arrayDelims, custom);
                end
            end
        end
        
        function str = string(obj)
        % STRING Return header field as a string
        %   STR = STRING(fields) returns the array of HeaderField objects as a string,
        %     as it would appear in a message, with newlines inserted between the
        %     fields but not at the end of all the fields.
        %
        % See also char
            if ~isscalar(obj)
                if isempty(obj)
                    str = '';
                else
                    strs = arrayfun(@string, obj, 'UniformOutput', false);
                    str = strjoin([strs{:}], newline);
                end
            else
                % a single obj gets no newline
                if isempty(obj.Value)
                    v = '';
                else
                    v = obj.Value;
                end
                if isempty(obj.Name)
                    n = "";
                else
                    n = obj.Name;
                end
                str = n + ': ' + v;
            end
        end
        
        function str = char(obj)
        % CHAR returns the header field array as a character vector.
        %   For more information see STRING.
        %
        % See also string
            str = char(string(obj));
        end
        
    end
    
    methods (Sealed, Access=protected, Hidden)
        function value = parseField(obj, varargin)
        % Parse and return the value of this header field
        % VALUE = parseField(HEADERFIELD, arrayDelims, structDelims, structFields, custom)
        %    This function is called by parse() to parse the Value property in the
        %    header as an array of strings, where each string may be interpreted as a 
        %    struct, as described in parse. HEADERFIELD is a scalar or vector of
        %    HeaderFields.
        %
        %    arrayDelims   - string or cell array of regular expressions specifying 
        %                    delimiters between array elements. If missing, ',' is
        %                    used. If '' or allowsArray is overridden to return
        %                    false, the value is processed as a single array element.
        %                    Quoted string and escape processing is applied to array
        %                    elements. If an empty array ([]), the Value is not
        %                    processed as an array (i.e., no quoted string or escape
        %                    processing is done, and this function returns either a
        %                    scalar struct or a string). Optional whitespace on
        %                    either side of an arrayDelim is allowed and ignored.
        %    structDelims  - optional; passed to parseElement for each array element.
        %    structFields  - optional; passed to parseElement for each array element.
        %    custom        - optional: true to use subclass-specific behavior to parse
        %                    the field; false otherwise. Default is true, which is
        %                    what most subclasses will want if they call this method.
        %                    If false the default values of all overridden functions
        %                    such as allowsArray() will be used. If present this
        %                    parameter must be last.
        %
        %    This function parses the Value in this header field, breaking it up into
        %    array elements (strings) as specified by arrayDelims, and passes each
        %    element to parseElement (along with the structDelims and structFields
        %    parameters) for further processing. The return values from parseElement
        %    are assembled into either a cell array of strings, array of structs, or
        %    array of objects, depending on the types of values returned, or 3-D array
        %    of strings if useStringMatrix() is set.
        %
        %    This function treats strings surrounded by quotes or open-closed
        %    parentheses as tokens, so will ignore arrayDelims or structDelims within
        %    them.
        %
        %    If parseElement returns only strings, this function returns a cellstr
        %    (same as if structDelims was specified as []).
        %
        %    If custom is false or useStringMatrix() is not set, and parseElement
        %    returns structs or structs and strings, this function returns a vector
        %    of structs with fields that are the union of all struct fields returned
        %    by parseElement, where unset fields have empty values and strings become
        %    structs with a single field whose name is 'Arg_1' or (if specified)
        %    structFields{1}. The combination of structs and strings results only if
        %    structDelims is missing.
        %    
        %    If custom is true and useStringMatrix is set, and parseElement returns
        %    Nx2 string matrices:
        %      Pad each Nx2 matrix with rows so their first dimensions are all the
        %      same. Padding uses empty strings.
        %      Return an MxNx2 array, where M is number of elements.
        %
        %    If the input is a vector, this method behaves as if all the values were
        %    in one field separated by an ArrayDelims. In other words, it
        %    concatenates the result of parsing each of the HeaderFields into single
        %    vector or cell vector if the results are heterogeneous.
        %
        %    Subclasses that override convert may use this as a utility to parse the
        %    header field with specific array or struct delimiters.
        %
        % VALUE = parseField(HEADERFIELD, arrayDelims, PARSER)
        %    Splits the Value of the header into elements at the delimiters specified
        %    in arrayDelims and pass each element to PARSER for processing. PARSER
        %    is a handle to a function that takes a string and returns either a
        %    struct, string or scalar value or object. This usage is for the benefit
        %    of subclasses that override convert, which want generic escape and array
        %    processing for the field but with a custom parser for the element
        %    values. This usage always invokes subclass-specific behavior.
        %
        %    This function assembles the values received from PARSER into an array or
        %    cell array, depending on the types of values received:
        %
        %       If all values are strings or structs, returned value is as described
        %       for the non-PARSER usage above.
        %
        %       If all values are of exactly the same type or have a common
        %       matlab.mixin.heterogeneous type, the returned value is an array of
        %       those types.
        %
        %       If values are of different non-heterogeneous types, the returned
        %       value is a cell array of those values.
            if isempty(obj)
                value = obj.callParseField([]);
            else
                for i = 1 : length(obj)
                    fValue = obj(i).callParseField(obj(i).Value, varargin{:});
                    if i == 1
                        value = fValue;
                    else
                        % append the individual results to the end of the value array
                        if iscell(value)
                            value = [value num2cell(fValue)]; %#ok<AGROW>
                        else
                            try
                                value = [value fValue]; %#ok<AGROW>
                            catch
                                % above can fail if previous value and fValue are not
                                % matlab.mixin.Heterogeneous. In that case, convert
                                % value into cell array.
                                c1 = num2cell(value);
                                c2 = num2cell(fValue);
                                value = [c1(:)' c2(:)'];
                           end
                        end
                    end
                end
            end
        end
        
        function value = callParseField(obj, str, varargin)
        % VALUE = callParseField(HEADERFIELD, STR, arrayDelims, structDelims, structFields, custom)
        %    All arguments after STR are optional; placeholders required
        %   Same as parseField but parses str instead of this field's value.
        %   Placeholder not required for custom argument.
        %
        %   obj must be a scalar.
            if isempty(obj) || isempty(obj.Value)
                value = [];
            else
                parser = @(obj, varargin) parseElement(obj, varargin{:});
                % If last argument is a logical, it's the custom parameter.
                if ~isempty(varargin) && islogical(varargin{end}) && ~varargin{end}
                    % custom = false, so pass in defaults for allowsArray and useStringMatrix
                    value = matlab.net.http.internal.fieldParser(...
                      str, obj, parser, true, false, varargin{:});
                else
                    value = matlab.net.http.internal.fieldParser(...
                      str, obj, parser, obj.allowsArray(), obj.useStringMatrix(), varargin{:});
                end
            end
        end
        
        function value = parseElement(obj, str, varargin)
        % Return the value of one array element of a header field
        %   parseElement(obj, str, structDelims, structFields, custom)
        %    This function is called by parseField to process each array element (a
        %    string) extracted from the Value of the header.
        %
        %    str          - the string to be processed
        %
        %    structDelims - optional string or cell array of regular expressions 
        %                   specifying delimiters between struct elements. If missing,
        %                   semicolon is used. If an empty array, or if missing and the
        %                   string contains no semicolons, or allowsStruct is overridden
        %                   to return false, this function returns str; otherwise it
        %                   always returns a struct with at least one field even if the
        %                   string contains no structDelims. Optional whitespace is
        %                   assumed on either side of a delimiter, which will be
        %                   ignored. 
        %
        %                   If one of these delimiters is ' ' (space), the actual
        %                   delimiter will be \s (any whitespace), and it will only be
        %                   considered a delimiter if it is not preceded by an = or
        %                   followed by an = (but not both). So in "a = b" or "a= b"
        %                   or "a =b" the spaces are not delimiters, but in "a b" or
        %                   "a= =b" the space is a delimiter.
        %
        %    structFields - optional names to use for unnamed fields (those without 
        %                   name=value syntax), as described in parse. Ignored
        %                   if structDelims is empty. The returned struct will
        %                   always contain at least these fields, even if the string
        %                   has fewer fields. Unset fields will have empty values.
        %
        %    custom       - optional true or false to implement subclass-specific
        %                   parsing based on overloaded methods such as allowsArray()
        %                   and allowsStruct(). Default is true, which is what most
        %                   subclasses will want to do. Specifying this argument does
        %                   not require filling in placeholder for structDelims or
        %                   structFields.
        %
        %    Subclasses that override convert may use this function as a utility to
        %    parse the value as a struct, perhaps with custom delimiters or field
        %    names. 
            if isempty(obj)
                value = string.empty;
            else
                if ~isempty(varargin) && islogical(varargin{end})
                    % If last arg is a boolean, it's the custom flag. 
                    % Save it and remove the arg.
                    custom = varargin{end};
                    varargin(end) = [];
                else
                    custom = true;
                end
                if custom
                    value = matlab.net.http.internal.elementParser(...
                        str, obj.allowsStruct(), obj.useStringMatrix(), varargin{:});
                else
                    % in the non-custom case, use all the defaults
                    value = matlab.net.http.internal.elementParser(...
                        str, true, false, varargin{:});    
                end
            end
        end
        
        function exc = getValueError(obj, id, value, varargin)
        % exc = getValueError(id, value) returns an MException with the specified id
        %   Creates a message using the specified id providing these arguments:
        %      {0} Name of the field (or class if Name is empty)
        %      {1} Class of value
        %      {2} Stringified value
        %      {3...} any additional arguments from varargin
            if isstring(value) || iscellstr(value)
                v = value;
            else
                try
                    v = num2str(value);
                catch
                    try
                        v = char(value);
                    catch
                        % if it has no char or num2str method, disp it, using cellstr to
                        % remove trailing empty lines and bracketing with newlines
                        c = cellstr(evalc('disp(value)'));
                        v = sprintf('\n%s\n', c{1});
                    end
                end
            end
            % v now a string array, char array or cellstr
            name = obj.Name;
            if isempty(name)
                name = class(obj);
            else
            end
            % if v has more than one row, concatentate with space separators
            % otherwise leave alone because cellstr strips trailing spaces
            if (iscellstr(v) && isrow(v)) || isstring(v)
                v = strjoin(v, '  ');
            else
            end
            if ~isrow(v)
                v = strjoin(cellstr(v),'  ');
            else
            end
            exc = MException(message(id, name, class(value), v, varargin{:}));
        end
                
        function throwValueError(obj, id, value, varargin)
        % throwValueError(id, value) throws an MException with the specified id
        %   Creates a message using the specified id providing these arguments:
        %      {0} Name of the field (or class if Name is empty)
        %      {1} Class of value
        %      {2} Stringified value
        %      {3...} any additional arguments from varargin
            throw(getValueError(obj, id, value, varargin{:}));
        end
    end
    
    methods (Static, Access=protected, Hidden)
        function converted = convertObject(~, value)
        % Converter whose sole purpose is to convert [] to an empty HeaderField array
            if isempty(value)
                converted = matlab.net.http.HeaderField.empty;
            else
                converted = []; % generates MATLAB error
            end
        end
    end        
       
    methods (Access=protected, Hidden)
        % These methods would be overidden only by classes that don't want the
        % default field constructing behavior, where the methods such as allowsArray,
        % allowsStruct and getStringException aren't sufficient to specify behavior.
        % This could be because the array or struct delimiters are something other
        % than comma and semicolon, or the default conversions from MATLAB types to
        % string aren't appropriate (or don't work).
        
        function str = valueToString(obj, value, arrayDelim, structDelim)
        % Convert the value to a string to be stored in the header. 
        %   This function is used to construct a header field value, and it accepts
        %   values that are either strings or objects that can be converted to
        %   strings.
        %
        %   It called by set.Value to convert the provided value to a string. This
        %   base class method accepts a char matrix, cell array of strings, struct
        %   array, or array of any type whose elements can be converted by
        %   defaultConvert(). It produces a list of tokens (strings) for each
        %   element of the value array or row of a char matrix, using arrayDelim as
        %   separator between tokens and structDelim for separator between struct
        %   fields. If an element of the value is a string and getStringException
        %   returns [] to indicate the string is valid, the element becomes the token
        %   unchanged; otherwise the token is obtained by calling scalarToString to
        %   convert the element, passing in structDelim as a separator in case the
        %   value is a struct. In summary:
        %   
        %   Input: string
        %   Returns: the same string (unchanged)
        %
        %   Input: v1 or [v1 v2 v3] or {v1 v2 v3} 
        %   Returns: [scalarToString(v1) arrayDelim scalarToString(v2) arrayDelim ...] 
        %
        %   Input: s, an MxNx2 string array
        %   Returns: [scalarToString(s(1,:,:)) arrayDelim scalarToString(s(2,:,:)) ...]
        %
        %   Both arrayDelim and structDelim are optional; the default values are
        %   comma and semicolon, respectively.
        %
        %   In this base class, if the value is a single string (not cell array), it
        %   (or the result of scalarToString) is returned unchanged. In all other
        %   cases of string or scalar elements (but not structs) each token is
        %   further processed by quoteValue to add double-quotes and escapes in
        %   strings that have characters not allowed in tokens. Thus, if you have a
        %   value and don't want this quote processing, convert the value to a single
        %   string before storing it in the Value. If you do want quote processing,
        %   and have just a single string, place it in a cell array of length 1. If
        %   the input is a struct array, quote processing is not done.
        %
        %   Subclasses may override this if they want to convert array values
        %   differently or to specify array delimiters other than the default, but
        %   they must obey the contract of this method that if the input is a single
        %   string that is valid, the result is the same string. If the need is to
        %   use default array processing but only to control processing of individual
        %   array elements, subclasses should override scalarToString and/or
        %   getStringException instead. If the need is only to disallow values that
        %   are arrays or structs, but not implement special processing, override
        %   allowsArray or allowsStruct. If you do override this, it is up to you to
        %   check that the value is not an array or struct, if not allowed.
        %
        %   Subclasses can expect that this function is called exactly once each time 
        %   the value is set. Implementations that override this function must not
        %   assume that the header's Name field is set -- processing should depend
        %   only on arguments passed into this function.
        %
        %   Subclasses overriding this method will not be passed a structDelim
        %   parameter if allowsStruct returns false, or an arrayDelim parameter if
        %   allowsArray and allowsStruct return false. But if allowsStruct is true,
        %   both parameters (possibly empty) will be present, so in that case
        %   subclasses must declare them.
        %
        %   If your class does not allow array values (allowsArray is false), you
        %   should call throwValueError('MATLAB:http:ArraysNotAllowed') if the input
        %   parameter is not a scalar, unless your intent is to create a
        %   single-valued string out of the array.
        %
        %   Typical pattern:
        %
        %     function str = scalarToString(obj, value, varargin)
        %         if isa(value, 'matlab.net.URI')
        %             str = string(value);
        %         elseif isstring(value)
        %             str = scalarToString@matlab.net.http.HeaderField(obj, value, varargin{:});
        %         else
        %             % not a string or URI: this produces guaranteed error
        %             validateattributes(value, {'matlab.net.URI', 'string'}, {}, ...
        %                 class(obj), 'URI');
        %         end
        %     end
        
            if nargin < 4 && obj.allowsStruct()
                structDelim = "; ";
            elseif nargin >= 4 && ischar(structDelim)
                structDelim = string(structDelim); 
            end
            if nargin < 3 
                if obj.allowsArray()
                    arrayDelim = ", ";
                elseif obj.allowsStruct()
                    arrayDelim = [];
                end
            elseif ischar(arrayDelim)
                arrayDelim = string(arrayDelim);
            end
            isStringMatrix = isstring(value) && ismatrix(value) && size(value,2) == 2 && obj.useStringMatrix();
            isStringArray = isstring(value) && ndims(value) == 3 && size(value,3) == 2 && obj.useStringMatrix() && obj.allowsArray();
            if (isscalar(value) && ~ischar(value) && ~isstring(value)) || isStringMatrix
                % a scalar, or a string matrix when useStringMatrix is set, represents one element
                if isstruct(value) || isStringMatrix
                    % If a struct or string matrix, convert it to string. Any quoting must be done
                    % within scalarToString
                    if obj.allowsStruct()
                        str = obj.scalarToString(value, [], 1, [], structDelim);
                    elseif obj.allowsArray()
                        str = obj.scalarToString(value, [], 1);
                    else
                        str = obj.scalarToString(value, []);
                    end
                else
                    % Non-structs get their value quoted only if the value allows
                    % structs and the value contains an arrayDelim or structDelim,
                    % or it allows array and the value contains arrayDelim.
                    if obj.allowsStruct()
                        % if struct alloweds, quote both array and struct delims
                        str = obj.quoteTokens(obj.scalarToString(value, [], 1, [], ...
                                             [arrayDelim structDelim]));
                    elseif obj.allowsArray()
                        % of arrays allowed, quote array delims
                        str = obj.quoteValue(obj.scalarToString(value, [], 1, ...
                                             arrayDelim));
                    else
                        % If no arrays or structs allowed, don't quote anything
                        str = obj.scalarToString(value, []);
                    end
                end
                obj.errorCheck(str, value);
            elseif (ischar(value) && isrow(value)) || ...
                    isstring(value) && isscalar(value)
                % A scalar string is treated as a raw header field value that might
                % contain an arrayDelim-separated list of values beyond what
                % scalarToString can process. Our job here is just to validate that
                % the string is OK, not to change it.
                value = string(value);
                e = obj.getStringException(value);
                if ~isempty(e)
                    % String wasn't acceptable; maybe input was an array of
                    % acceptable strings
                    if obj.allowsArray()
                        % If arrays allowed, split into elements at arrayDelim and
                        % process each through scalarToString, and then
                        % reconcatenate. This gives scalarToString a chance to
                        % validate and possibly convert the strings. When splitting
                        % at arrayDelim, replace spaces with zero or more whitespace
                        % chars.
                        delim = regexprep(arrayDelim, ' +', '\\s*');
                        splitValue = matlab.net.http.internal.delimSplit(...
                                                       value, delim);
                        % validate each element                           
                        empties = arrayfun(@(v) ...
                                  isempty(obj.scalarToString(v, e, 1)), splitValue);
                        if any(empties) 
                            err = [];
                        else
                            err = '';
                        end
                    else
                        % validate the whole string
                        err = obj.scalarToString(value, e);
                    end
                    obj.errorCheck(err, value);
                end
                str = value; % string OK; return it
            elseif ~obj.allowsArray()
                obj.throwValueError('MATLAB:http:ArraysNotAllowed',value);
            % Everything past here is an array of more than one element
            elseif ischar(value) && ismatrix(value)
                % a char matrix with 2 or more rows; each row is a value
                numrows = size(value);
                str = "";
                idx = 1;
                charDelim = char(arrayDelim);
                for i = 1 : numrows
                    if i ~= 1
                        str{1}(idx:idx+length(charDelim)-1) = charDelim; 
                        idx = idx+2;
                    end
                    row = value(i,:);
                    e = obj.getStringException(row);
                    if isempty(e)
                        val = row;
                    else
                        val = obj.scalarToString(row, e, i);
                        obj.errorCheck(val, row);
                    end
                    % quote processing on each row
                    if obj.allowsArray()
                        val = obj.quoteTokens(val, i, [], arrayDelim);
                    else
                        val = obj.quoteTokens(val, i, []);
                    end
                    len = strlength(val);
                    str{1}(idx:idx+len-1) = char(val);
                    idx = idx+len;
                end
                str{1}(idx:end) = [];
            elseif isvector(value) || isStringArray
                % it's a vector; accept either cell vector, regular vector (of structs or
                % values) or an MxNx2 string array
                if isStringArray 
                    len = size(value,1);
                else
                    len = length(value);
                end
                values(len) = "";
                for i = 1 : len
                    if iscell(value)
                        valin = value{i};
                    elseif isStringArray
                        valin = shiftdim(value(i,:,:),1);
                    else
                        valin = value(i);
                    end
                    if ((ischar(valin) && isrow(valin)) || ...
                        (isstring(valin) && isscalar(valin))) ...
                        && isempty(obj.getStringException(valin))
                        % element is a string
                        val = string(valin);
                    else
                        % element is not a string: convert it to string, using
                        % structDelim if struct is allowed
                        if obj.allowsStruct()
                            val = obj.scalarToString(valin, [], i, arrayDelim, structDelim);
                        else
                            val = obj.scalarToString(valin, [], i);
                        end
                        obj.errorCheck(val, valin);
                    end
                    if ~isstruct(valin) && ~isStringMatrix && ~isStringArray
                        % quote processing on non-structs
                        if obj.allowsArray()
                            values(i) = obj.quoteTokens(val, i, [], arrayDelim);
                        else
                            values(i) = obj.quoteTokens(val, i, []);
                        end
                    else
                        values(i) = val;
                    end
                end
                str = strjoin(values, arrayDelim);
            else
                obj.throwValueError('MATLAB:http:ValueNotVector',value);
            end
            if isempty(str) && ~isstring(str)
                obj.throwValueError('MATLAB:http:BadFieldValue',value);
            end
        end
        
        function str = scalarToString(obj, value, exc, index, arrayDelim, structDelim)
        % Convert the scalar value or string to a header field value
        %   This function is called by valueToString() to convert a single element of an
        %   array used to set the Value in the field. It is invoked only for scalars or
        %   strings, or (if useStringMatrix() is set) for Nx2 string matrices. For
        %   strings or string arrays, it is invoked only if getStringException() returns
        %   nonempty (indicating the string as provided needs to be converted or is
        %   invalid). Implementations of this method can assume that if value is a
        %   string, it is invalid or needs conversion.
        %
        %   value                  - The scalar value to convert
        %   exc                    - The MException returned from getStringException
        %                            Set only if value is a string or char vector.
        %                            May be false if the string needs processing.
        %   index (optional)       - the position of the scalar in the array, if 
        %                            arrays are allowed. Not present if
        %                            allowsArray() is false.
        %   arrayDelim (optional)  - Not present if allowsArray() is false.
        %   structDelim (optional) - Not present if allowsStruct() is false.
        %
        %   By default, throws exc if the value is a scalar string (since this
        %   means getStringException has already rejected it). Overriding this method
        %   to process a scalar string makes sense if you want to convert the input
        %   string to a different string, rather than allowing the literal string to
        %   be used.
        %
        %   If the value is not a struct, converts value using defaultConvert().
        %
        %   If the value is a struct (or, if useStringMatrix() is set, an Nx2 string
        %   matrix), returns a structDelim-separated list of name=value pairs in the
        %   order they appear in the structure (or matrix). Each field of the struct,
        %   or row of the string matrix, creates either a "name=value" string in the
        %   result, or just a "value" or "name" string.
        %
        %   In the case of a struct, fields with names of the form 'Arg_N' are inserted
        %   as simply "value" at the position indicated by the number N (or at the end
        %   if the name is Arg_End), and fields with empth values are skipped. Nonempty
        %   fields of the struct must be strings or scalars. Each value is processed by
        %   quoteTokens() to quote strings with array or struct delimiters.
        %
        %   In the case of an Nx2 string matrix, if the name in a row is "" or missing
        %   the value is inserted without a name. Conversely, if the value is "" but
        %   the name appears, the name is inserted. However, values are subject to
        %   quoting, while names must be valid tokens and are never quoted. If both
        %   name and value are "" or missing, nothing is inserted for that row.
        %
        %   If the value is not a struct or string matrix, the caller (valueToString, in
        %   the default case) is responsible for deciding whether to quote delimiters.
        %
        %   For example, given ';' as structDelim, the struct or string matrix:
        %
        %     Arg_2:   'value2'              ["Foo" "value1";
        %     Foo:     'value1'               ""    "value2";
        %     Any:     []                     ""    "";
        %     Arg_End: '(com\)ment)'          "Bar" "value;""e3";
        %     Bar:     'value;"e3'            ""    "(com\)ment)"]
        %
        %   return:
        %
        %     Foo=value1; value2; Bar="valu;\"e3"; (com\)ment)
        %
        %   If the input value is invalid, this function either throws an error or
        %   returns []. If this returns [], and the caller is valueToString, a
        %   generic error will be produced that refers to the class and name of the
        %   field. Note that an empty string, '', is a valid return value which does
        %   not signal an error.
        %
        %   Subclasses should override this to provide custom conversions for scalar
        %   or struct values, or to control the value of structDelim. Since, if the
        %   value is a string, this is called only after getStringException() has
        %   returned false or an MException, subclasses that don't want to convert
        %   the string should throw an appropriate error (explicitly or by calling
        %   this superclass method to return the exception received from
        %   getStringException()) or return [] on any string to return a generic
        %   error. For other types, if conversion fails, subclasses should throw an
        %   error or return []. Subclasses overriding this method will not be passed
        %   a structDelim argument if allowsStruct is false.
        %
        %   If you override this method, it is safest to declare it this way:
        %
        %     function str = scalarToString(obj, value, varargin)
        %
        %   and pick off the additional arguments from varargin, if they are present.
        %
        %   The result returned by this function will be escaped and quoted, if
        %   necessary. If you have already quoted and escaped your string, override
        %   getTokenExtents() to return [].
        
            if nargin < 5
                structDelim = [];
                if nargin < 4
                   index = 1;
                end
            end
            if (ischar(value) || isstring(value)) && ~obj.useStringMatrix()  % it has to be a simple string
                % The simple string case is always an error
                if isempty(exc) || (islogical(exc) && ~exc)
                    % We get here if caller invoked us on a string without setting exception, or
                    % they set exception to false. In that case throw a generic exception.
                    throwValueError(obj, 'MATLAB:http:BadFieldValue', value);
                else
                    throw(exc);
                end
            elseif isstruct(value) || obj.isStringMatrix(value)
                if obj.allowsStruct()
                    % fields is either a cellstr or string array, depending whether input is a
                    % string matrix and useStringMatrix allows it
                    if obj.useStringMatrix() 
                        if isstring(value)
                            % string matrix allowed and value is string
                            fields = value(:,1);
                            obj.throwOnInvalidToken(fields);
                        else
                            throwValueError(obj, 'MATLAB:http:StructNotAllowed', value);
                        end
                    else
                        % string matrix not allowed and value isn't string; we hope it's a struct
                        fields = fieldnames(value);
                    end
                    
                    lf = length(fields);
                    strs = strings(1,lf);   % the fields with name=value syntax (not named Arg_*)
                    argStrs = strings(1,lf);% the fields with value syntax (named Arg_N)
                    argEnd = [];            % the field with value syntax (named Arg_End)
                    for i = 1 : lf
                        % for each field of the struct or row of string matrix, insert an element in strs
                        % that's either the value as a string or name=value
                        if iscell(fields)
                            ns = fields{i};
                            v = value.(ns);
                        else
                            ns = fields(i);
                            v = value(i,2);
                            if ismissing(v) 
                                v = "";
                            end
                            if v == ""
                                if ismissing(ns) || ns == ""
                                    % both name and value empty; ignore row
                                    continue;
                                else
                                    % if value empty but not name, put name in value and make name empty, so it looks
                                    % like "",value
                                    v = ns;
                                    ns = "";
                                end
                            end
                        end
                        % convert the value and add quotes if it needs it
                        v = obj.defaultConvert(v);
                        if strlength(ns) ~= 0
                            % quote the value only if ns specified
                            v = obj.quoteTokens(v, index, ns, [arrayDelim structDelim]);
                        end
                        if nargin < 4
                            structDelim = ";";
                        end
                        % checkValueForDelim(v, {arrayDelim structDelim});
                        if obj.useStringMatrix()
                            idx = 0;
                        else
                            idx = strfind(ns, 'Arg_'); 
                        end
                        if isempty(ns) || (isstring(ns) && ns == "") || ...
                           (~isempty(idx) && idx == 1 && (...
                                ~isempty(regexp(ns(5:end),'^[1-9]\d*$', 'once'))) || ...
                                (ischar(ns) && ns(5:end) == "End"))
                            % If a field name begins with Arg_ and followed by a
                            % number N or "End", or is empty, put just the value (not the
                            % name) in the N'th (or last) position of argStrs. Don't have to
                            % worry about N being used twice because field names
                            % can't repeat. 
                            if idx ~= 0
                                argno = str2double(ns(5:end));
                            else
                                argno = i;
                            end
                            if isnan(argno) % this corresponds to Arg_End
                                argEnd = v;
                            else
                                argStrs(argno) = v;
                            end
                        elseif ~isempty(v) 
                            if strlength(v) ~= 0
                                strs(i) = string(ns) + '=' + v; 
                            elseif strlength(ns) ~= 0
                                strs(i) = string(ns);
                            end
                        end
                    end
                    strs(strlength(strs) == 0) = []; % remove empty elements of strs
                    % for each nonempty string in argstrs, insert it into its proper
                    % place in strs
                    for i = 1 : length(argStrs)
                        arg = argStrs(i);
                        if i > length(strs)
                            strs(i) = arg;
                        elseif strlength(arg) ~= 0
                            strs = [strs(1:i-1) arg strs(i:end)];
                        end
                    end
                    if ~isempty(argEnd)
                        strs(end+1) = argEnd;
                    end
                    strs(strlength(strs) == 0) = []; % remove empty elements again
                    str = strjoin(strs, structDelim); 
                else
                    obj.throwValueError('MATLAB:http:NoStructs', value);
                end
            else
                str = obj.defaultConvert(value);
            end
        end
        
        function exc = getStringException(~, ~)
        % Determine validity of input string for the field
        %   exc = getStringException(obj, str) returns empty if the string is valid
        %     for use in the field as is. Returns an MException (not thrown) if the
        %     string is invalid. Returns false if the string needs to be further
        %     processed by scalarToString to convert to a field value or throw an
        %     error. Note the MException is returned, not thrown.
        %
        %   This function, intended to be overridden by subclasses, is invoked by
        %   valueToString on each string, string in a cell array, or row of a char
        %   matrix to set the Value field. Return values:
        %     []         causes valueToString to use the string as is
        %     MException causes valueToString to invoke scalarToString to try to 
        %                convert the value to an acceptable. The default scalarToString
        %                will throw this MException if it is passed a string, so if you
        %                override this, return an MException only if you don't intend to
        %                override scalarToString to further process the string.
        %     false      same as MException, except causes scalarToString to throw a
        %                generic error message is instead of your custom one.
        %   If you want to throw a custom error for an invalid string, return an
        %   MException. If you override scalarToString, check if a string is passed
        %   in. If so, either throw a custom error or return [] to throw a generic
        %   error.
        %
        %   Default behavior of this function returns [], which says any string is
        %   acceptable. Subclasses that want to validate strings should implement
        %   a pattern something like this:
        %    
        %    try
        %       convert str to expected object type that would be returned by
        %       convert() or parse it, for e.g. 
        %       v = matlab.net.http.internal.elementParser(str, true, true); 
        %       if v is valid exc = [] 
        %       if invalid 
        %            exc = obj.getvalueError('id', str) false
        %       end
        %    catch exc
        %    end
            exc = [];
        end
        
    end
    
    methods (Access={?matlab.net.http.io.ContentProvider,?matlab.net.http.RequestMessage}, Hidden)
        function value = convertNonempty(obj)
        % converNonempty Call convert on nonempty, nongeneric fields
        %   value = convertNonempty(FIELDS) calls convert on the nonempty-valued,
        %   non-GenericField fields in FIELDS and returns an array of the results. FIELDS
        %   must be an array of HeaderFields whose convert method returns objects that
        %   are all the same type and can form an array.
        %
        % FOR INTERNAL USE ONLY: This method is intentionally undocumented and for use
        % only by classes in the matlab.net.http packages. This method may be removed
        % or changed in a future release.
            value = [];
            for i = 1 : numel(obj)
                field = obj(i);
                if ~isempty(field.Value) && (~isstring(field.Value) || strlength(field.Value) ~= 0) ...
                        && ~isa(field, 'matlab.net.http.field.GenericField')
                    res = field.convert();
                    if (isempty(value))
                        value = res;
                    else
                        value(end) = res;
                    end
                else
                end
            end
        end
        
        function num = getNumber(obj)
        % num = getNumber() returns the value of the field as a number. Calls convert()
        % and, if the result is a string, tries to convert it to a double. If it is
        % anything else, returns []. Does not throw an error.
        %
        % FOR INTERNAL USE ONLY: This method is intentionally undocumented and for use
        % only by classes in the matlab.net.http packages. This method may be removed
        % or changed in a future release.
            num = obj.convert();
            if ~isnumeric(num)
                if isstring(num)
                    num = double(num);
                else
                    num = -1;
                end
            else
            end
        end
    end
    
    methods (Static, Access=protected, Hidden)
        % These methods should be overridden by most subclasses to customize value
        % conversions.
        
        function tf = allowsArray()
        % Return true if this header field allows or contains lists or arrays
        %   This function, intended to be possibly overridden by subclasses, is
        %   invoked by methods in this class that store the Value field to determine
        %   whether array processing should be done. The default is true.
        %
        %   If false, attempt to set the Value property of this field to a non-scalar
        %   results in an error, and the parse function will not attempt to
        %   parse the Value as a list.
            tf = true;
        end
        
        function tf = allowsStruct() 
        % Return true if this header field allows or contains structs
        %   This function, intended to be possibly overridden by subclasses, is
        %   invoked by methods in this class that store or return the Value field to
        %   determine whether struct processing should be done. The default is true.
        %
        %   If false, attempt to set the Value property of this field to a struct
        %   results in an error, and the parse function will not attempt to
        %   parse the value as a struct.
            tf = true;
        end
        
        function tf = useStringMatrix()
        % If true and allowsStruct is set, the name=value parameters in an element of
        %   this field should be returned in an Nx2 string matrix instead of a
        %   struct, and likewise an Nx2 string matrix is accepted to set the value
        %   instead of a struct. By default this is false. It is overridden by
        %   subclasses that return and accept field values in specialized objects.
        %   If true, struct input is not accepted when setting Value.
            tf = false;
        end
        
        function tf = allowsTrailingComment() 
        % Return true if this header field allows a comment at the end of the header
        %   Default is true. If set and the header contains a comment, it may be 
        %   obtained from the Comment property.
        %   
        %   This setting applies only to comments at the ends of fields. Subclasses
        %   that want to allow comments in particular positions inside elements of
        %   the header need to override TBD
            tf = true;
        end
        
        function value = getDefaultValue()
        % Return the default value for this field. This is the value that will be
        %   stored in the field if it is set to [] or not specified in the
        %   constructor. Default returns []. Subclasses need override this only if
        %   they want to specify a different default. The value returned must be a
        %   legal value acceptable to the set.Value function.
            value = [];
        end
        
        function tokens = getTokenExtents(value, index, field) %#ok<INUSD>
        % Given a string that represents the converted-to-string value of a
        % particular element of an array or struct that was passed in as a header
        % field value, return the an n-by-2 array of starting and ending token
        % positions. These are the tokens that need to be processed for possible
        % escapes and quotes. If this returns empty, no escape/quote processing is
        % done on the value. This is appropriate if the tokens have already been
        % checked to be valid tokens.
        %
        % This function is needed because field values provided by the user are not
        % necessarily simple tokens, but may contain delimiters. For example the
        % MediaType field of the AcceptField has the syntax "type/subtype" which is
        % actually 2 tokens separated by a slash.
        %   field - If not empty, the name of the struct field being processed. 
        %   index - The index of the element; always at least 1
        % Default returns [1 length(value)] indicating the entire value is a token.
        %
        % Subclasses who have already escaped and quoted their tokens in
        % scalarToString() should override this to return [] to indicate no quote
        % processing should be performed.
            tokens = [1 strlength(string(value))];
        end
        
        function str = quoteValue(token, delims)
        % Quote the token (string) if it contains a sequences that need quoting.
        %   delims - optional vector of strings to check for in addition to standard
        % This function is called by valueToString and scalarToString, before storing
        % a token, to quote (with double quotes) a token that contains unquoted
        % special characters or whitespace. Within quotes, backslash and
        % double-quote characters are escaped with backslash. The special characters
        % are those not allowed in tokens according to RFC 7230:
        %         (),/:;<=>?@[\]{}"  
        % plus all whitespace characters plus anything that matches one of the
        % delims. If the string is already quoted (i.e., begins and ends with paired
        % double-quotes or open-closed parentheses), the token is assumed to be
        % already formatted as a quoted string or comment and is returned unchanged.
        %
        % If token is '' or "", returns "". Otherwise, if token is empty, returns
        % token.
        %
        % This method is only needed for fields that allow quoted values.
        %
        % Subclasses that have different quoting rules may wish to override this.
        % Subclasses whose scalarToString() method has already quoted the returned
        % value, or which don't want any additional quoting of the value, should
        % override getTokenExtents() to return [].
            if isempty(token) && ~ischar(token)
                str = token;
                return
            end
            token = string(token); 
            if token == ""
                str = """""";
                return
            end
            % See if starts with a quote character: " or (
            if strlength(token) > 1 && (token.startsWith('"') || token.startsWith('(')) 
                % It starts with a " or ( 
                % See if it ends with the paired " or )
                if token.startsWith('(')
                    match = ')';
                else
                    match = '"';
                end
                if token.endsWith(match)
                    % ends with a " or ), but we need to see if it's properly paired
                    i = 2;
                    while i < strlength(token)
                        ch = extractBetween(token,i,i);
                        if ch == '\'
                            i = i + 2;
                        elseif ch == match
                            % unescaped " or ) means it's not a quoted string or
                            % comment after all
                            break;
                        else
                            i = i + 1;
                        end
                    end
                    % If the first unescaped matching quote is the last character of
                    % the token, then it's a quoted string and we just return as is.
                    % If we fall off the end of string (e.g., the last " is escaped)
                    % or we didn't get to the end, it's not a quoted string or
                    % comment.
                    if i == strlength(token)
                        % return as is
                        str = token;
                        return;
                    end
                else
                end
            else
            end
            
            % It's not already a quoted string, so quote if necessary
            if nargin > 1
                str = matlab.net.http.internal.quoteToken(token, delims);
            else
                str = matlab.net.http.internal.quoteToken(token);
            end
        end
        
    end
    
    methods (Static, Sealed, Hidden)
        function str = createQuotedString(value)
        % Given a string value, place double-quotes around it and add escapes
        %   Creates quoted-pair (using backslash) for double-quote and backslash. No
        %   reason to escape other chars.
            str = ['"' regexprep(value, '(\|")', '\$1') '"'];
        end
        
        function tf = isValidToken(value, allowQuotes, allowComments)
        % Return true if string is a valid HTTP token. This is a utility useful for
        % subclasses to validate strings to be inserted in HTTP field values.
        % Returns true if the string contains at least one character and only the
        % characters allowed in tokens as per section 3.2.6 of RFC 7230. White space
        % is not permitted anywhere in the value (except within comments and quotes)
        %
        % The optional allowQuotes and allowComments parameters, if true, specify
        % whether quoted strings and/or comments are allowed. In this case the token
        % is considered valid if it is completely surrounded by paired double-quotes
        % or parentheses and internal quotes or parentheses are aqpropriately
        % escaped, with no constraints on the characters within the string.
        %
        % Accepts scalartext
            if (ischar(value) && ~isrow(value)) || (isstring(value) && ...
                  (~isscalar(value) || ismissing(value) || strlength(value) == 0))
                tf = false;
                return;
            end
            value = char(value);
            if (nargin > 1 && allowQuotes && value(1) == '"') || ...
               (nargin > 2 && allowComments && value(1) == '(') 
                % allowQuotes and it begins with a quote, or allowComments and it
                % begins with a left paren
                if length(value) > 1
                    if allowQuotes
                        closer = '"';
                    else
                        closer = ')';
                    end
                    % the string must end with the closer and there must be no
                    % non-escaped closers in the string
                    % remove escaped pairs
                    unescapedChars = regexprep(value(2:end), '\\.', '');
                    % the only closer left should be at the end
                    tf = strfind(unescapedChars, closer) == length(value) - 1;
                    tf = isscalar(tf) && tf;
                else
                    tf = false;
                end
            else
                % Caller doesn't allow comments or quotes, or allowed but isn't a
                % comment or quoted string, so check for any illegal characters.
                % It's worth noting that org.apache.http is much more liberal with
                % regard to what characters can occur in a token, compared to RFC
                % 7230. It's not clear what rules POCO uses.
                tf = isempty(matlab.net.http.HeaderField.getInvalidCharInToken(value));
            end
        end
        
        function ch = getInvalidCharInToken(token)
        % Return the first invalid character in the token. Returns [] if the token is
        % valid. This simply insures all characters are in TokenChars.
        % Accepts char or string; returns char or []
            ch = regexp(char(token), '[^' + matlab.net.http.HeaderField.TokenChars + ']', 'once', 'match');
        end
        
        function throwOnInvalidToken(tokens)
        % Throw an error if any element in the string array or cellstr tokens is not a
        % valid token
            tokens = string(tokens);
            for i = 1 : length(tokens)
                ch = matlab.net.http.HeaderField.getInvalidCharInToken(tokens(i));
                if ~isempty(ch)
                    error(message('MATLAB:http:IllegalCharInToken', ch, char(tokens(i))));
                end   
            end
        end
        function str = qualityToString(value)
        % Parse value and return a string representing the quality value, suitable
        % for use in a q=weight parameter of a header field. If the value is empty,
        % return []. If the value is a string and it is valid, just return it.
        % Otherwise if the value is a number convert it to a quality string. A valid
        % quality must be between 0 and 1 inclusive. This method does not enforce
        % the syntax of the string, as long as it has a valid numeric value.
            isvalid = @(x)isreal(x) && isscalar(x) && x >= 0 && x <= 1;
            if isempty(value)
                str = [];
            elseif isnumeric(value)
                if isvalid(value)
                    % stringify numbers < 1 by printing '0.' and up to 3 digits with
                    % no trailing zeros
                    str = sprintf('%1.3g',round(value,3));
                else
                    error(message('MATLAB:http:BadQuality', num2str(value)));
                end
            else
                num = matlab.net.internal.getString(value, mfilename, 'quality');
                num = str2double(num);
                if isvalid(num)
                    str = value;
                else
                    error(message('MATLAB:http:BadQuality', value));
                end
            end
        end
    end
    
    methods (Static, Sealed)
        function [fields, names] = displaySubclasses()
        % displaySubclasses Display supported HeaderField subclasses
        %   HeaderField.displaySubclasses displays all subclasses of HeaderField in
        %   the matlab.net.http.field package that you can construct, along with the
        %   names of header fields they support.
        %
        %   [FIELDS, NAMES] = HeaderField.displaySubclasses returns FIELDS, an array
        %   of strings naming the subclasses, and NAMES, a cell array containing
        %   vectors of strings containing the header field names that the subclasses
        %   support: NAMES{i} contains the names supported by FIELDS(i). NAMES{i} is
        %   empty if FIELDS(i) has no constraints on supported names.
        
            % Basically we just list all non-abstract classes in matlab.net.http.field
            % with public constructors.
            list = meta.package.fromName('matlab.net.http.field').ClassList;
            
            classes = arrayfun(@dispClass, list, 'UniformOutput', false);
            classes(cellfun(@isempty, classes)) = []; % remove empty cells
            classes = sort(classes);
            
            % this returns string vector or string.empty
            if nargout ~= 1
                getNames = @(c) string(feval(['matlab.net.http.field.' char(c) '.getSupportedNames']));
            else
            end
            
            if nargout > 0
                fields = string(classes);
                if nargout > 1
                    names = arrayfun(getNames, fields, 'UniformOutput', false);
                else
                end
            else
                fprintf('%s\n',getString(message('MATLAB:http:DisplaySubclasses')));
                if desktop('-inuse')
                    cellfun(@(x) fprintf('%-*s %s\n', 72+length(x), ...
                              sprintf('<a href="matlab:doc matlab.net.http.field.%s">%s</a>',x, x), ...
                              strjoin(getNames(x), ', ')), classes);
                else
                    % no links in nodesktop case
                    cellfun(@(x) fprintf('%-24s %s\n', x, ...
                                         strjoin(getNames(x), ', ')), classes);
                end
            end
            
            function clsName = dispClass(clazz)
                % get name of the class after the last '.'
                clsName = clazz.Name(regexp(clazz.Name, '\.[^.]+$')+1 : end);
                assert(~isempty(clsName));
                % find the constructor; the method with the same name
                methods = clazz.MethodList;
                constructor = methods(cellfun(@(x)strcmp(x,clsName), {methods.Name}));
                assert(isscalar(constructor));
                if ~strcmp(constructor.Access,'public') || clazz.Abstract
                    % can't create if constructor not public or class is abstract
                    clsName = [];
                else
                end
            end
        end
    end
    
    methods (Hidden, Sealed, Access={?matlab.net.http.io.ContentConsumer,...
                                     ?matlab.net.http.io.ContentProvider,...
                                     ?matlab.net.http.internal.HTTPConnector,...
                                     ?matlab.net.http.Message})
        function field = getValidField(obj, varargin)
        % getValidField Return valid fields from array of HeaderField
        %   This methid is the same as getFields except it only returns the last
        %   matching field that has a valid value for the field type and isn't empty.
        %   If the field has a subclass, return a new instance of that subclass.
        %
        % FOR INTERNAL USE ONLY: This method is intentionally undocumented and for use
        % only by classes in the matlab.net.http packages. This method may be removed
        % or changed in a future release.
            fields = obj.getFields(varargin{:});
            field = matlab.net.http.HeaderField.empty;
            for i = length(fields) : -1 : 1
                testfield = fields(i);
                if ~isempty(testfield.Value) && strlength(testfield.Value) ~= 0
                    if ~field.isBaseClass() 
                        % if not base class HeaderField, then its value must be valid
                        % for the subclass
                        field = testfield;
                        break;
                    else
                        % otherwise try to convert it to a subclass
                        [testfield, isBase] = obj.createHeaderField(testfield);
                        if ~isBase
                            % converted OK, so use it
                            field = testfield;
                            break;
                        end
                    end
                end
            end
        end
    end
    
    methods (Hidden, Sealed, Access=?matlab.net.http.Message)
        function obj = changeFieldsInternal(obj, newfields, useClasses, add)
        % Change the values of all the fields in obj that match names in the HeaderField
        % array fields. If useClasses is true, also change the classes to match. If
        % add is true, add the field if it doesn't exist. Same as changeFields except
        % that argument must be HeaderField array. Errors out if there is no match of
        % one of the fields.
            for i = 1 : length(newfields)
                name = newfields(i).Name;
                % match is vector of matching fields
                if isempty(obj)
                    match = [];
                else
                    match = find(strcmpi(name, [obj.Name]));
                end
                if isempty(match)
                    if add
                        obj(end+1) = newfields(i); %#ok<AGROW>
                        continue;
                    else
                        error(message('MATLAB:http:NoMatchingField', name));
                    end
                elseif length(match) > 1
                    error(message('MATLAB:http:MoreThanOneField', name));
                end
                % Copy name and value properties into existing field. In the NAME,VALUE usage
                % of this function, don't just store the whole fields(i) because we don't want
                % to change its class.
                if useClasses
                    obj(match) = newfields(i);
                else
                    obj(match).Name = newfields(i).Name;
                    obj(match).Value = newfields(i).Value;
                end
            end
        end
        
        function obj = addFieldsInternal(obj, where, fields)
        % Add fields to the header
        %   obj    - a HeaderField array
        %   where  - index where fields should be inserted; <0 means count from end; 
        %            [] means at end
        %   fields - HeaderField array to add
            if isempty(where)
                where = length(obj) + 1;
            else
                % set start to value in range 1:length(obj)+1
                if where <= 0
                    % count from end where 0 is end+1
                    where = max(length(obj) + where + 1, 1);
                else
                    % count from front
                    where = min(length(obj) + 1, where);
                end
            end
            obj = [obj(1:where-1) fields obj(where:end)];
        end
       
        function obj = removeFieldsInternal(obj, names, classes)
        % Remove fields whose Name matches any of those in the HeaderField array names,
        % and whose class matches any of those in the met.class array classes (and
        % subclasses).
            % first remove matching names
            for i = 1 : length(names)
                obj(strcmpi(names(i), [obj.Name])) = [];
            end
            % next remove matching classes and their subclasses
            if ~isempty(classes)
                obj(arrayfun(@(h) any(metaclass(h) <= classes), obj)) = [];
            end
        end
    end
       
    methods (Static, Hidden, Access=?matlab.net.http.Message)
        function fields = getFieldsVector(args, type)
        % Utility to convert varargs list to an array of HeaderFields. 'args' is a cell
        % array, the varargin from a call to a function. If it contains only
        % HeaderField arrays, just return them all in a single vector. If it contains
        % some HeaderField arrays and some not, error out. If no HeaderField objects,
        % return matlab.net.http.HeaderField.empty.
        %
        % if 'type' specified, it's the name of a class other than HeaderField to do
        % the above processing, but still return HeaderField.empty if not.
            if nargin == 1
                type = 'matlab.net.http.HeaderField';
            end
            if any(cellfun(@(a) isa(a, type), args))
                % If any arg is type, try to collapse all args into single type vector.
                % This allows the arg list to be a mixture of scalars and arrays, as long as
                % they are all of 'type'.
                try
                    fields = reshape([args{:}], 1, []);
                catch e
                    % didn't work, so error out
                    error(message('MATLAB:http:ExpectedAllSameType', type));
                end
            else 
                fields = matlab.net.http.HeaderField.empty;
            end
        end
        
        function [fields, index, useClasses] = getInputsAsFields(check, allowIndex, varargin)
        % Parse the varargin argument list, one of:
        %   NAME,VALUE pairs
        %   HeaderField arrays (comma-separated)
        %   struct array with Name and Value members (one argument)
        % Any of above may be preceded by a numeric INDEX argument.
        % Returns a single HeaderField array created from the arguments. For NAME,VALUE
        % and struct arguments, returns the appropriate subclass. For HeaderField
        % arguments, concatenates all the arrays into one vector.
        %
        % useClasses is true if all the inputs are HeaderField objects.
        % index is the value of the optional INDEX argument or []
        %
        % Struct input is assumed to be internal use only and will assert if there is
        % more than one input array.
        %
        % CHECK is true to validate the values of the fields in the case of NAME,VALUE
        % or struct input; false to silently allow any value.
            % set where to the INDEX argument or empty
            if ~isempty(varargin) && allowIndex && isnumeric(varargin{1})
                index = varargin{1};
                validateattributes(index, {'numeric'}, {'scalar','integer'}, ...
                    mfilename, 'INDEX');
                varargin(1) = []; % shift varargs left to get rid of INDEX arg
            else
                index = [];
            end
            if isempty(varargin)
                fields = matlab.net.http.HeaderField.empty;
                useClasses = false;
                return
            end
            fields = matlab.net.http.HeaderField.getFieldsVector(varargin);
            if ~isempty(fields)
                % all args were HeaderField
                useClasses = true;
            else
                useClasses = false;
                if isstruct(varargin{1})
                    % if first vararg is a struct, create HeaderField objects from
                    % Name/Value members. Allow only a single struct array.
                    structs = varargin{1};
                    assert(length(varargin) == 1 && (isempty(structs) || isvector(structs)));
                    if check
                        fields = arrayfun(@(s) ...
                               HeaderField.createHeaderField(s.Name, s.Value), structs, ...
                               'UniformOutput', false);
                    else
                        fields = arrayfun(@(s) createFieldSafe(s.Name,s.Value), ...
                                                    structs, 'UniformOutput', false);
                    end
                    fields = [fields{:}];
                else
                    names = varargin(1:2:end);
                    values = varargin(2:2:end);
                    if length(values) < length(names) 
                        values{end+1} = []; % append empty to end if not enough values
                    end
                    % Call the HeaderField constructors on each. This will validate that the values
                    % are valid for those names. 
                    if check
                        fields = cellfun(@(n,v)matlab.net.http.HeaderField.createHeaderField(n,v), ...
                                     names, values, 'UniformOutput', false);
                    else
                        fields = cellfun(@(n,v) createFieldSafe(n,v), ...
                                     names, values, 'UniformOutput', false);
                    end
                    fields = [fields{:}];  % take HeaderFields out of their cells
                end
            end
        end
            
        function args = getNameVector(args)
        % args is the varargin from a call to a function, which must not be empty. If
        % args{1} is a nonscalar array other than char or cell array, it must be the
        % only argument, and we return args{1}, or we error out with "too many input
        % arguments". Otherwise we return args.
            if ~isempty(args)
                firstArg = args{1};
                if iscell(firstArg) || (~ischar(firstArg) && ~isscalar(firstArg))
                    if length(args) > 1
                        error(message('MATLAB:maxrhs'));
                    end
                    args = firstArg;
                end
            end
        end
        
        function names = getMatchingNames(ids)
        % Return vector of names in vector of ids:
        %   strings or cell array of strings (names)
        %   meta.class (use PackageMonitor.getNamesForClass)
        %   HeaderField (use their names; if name empty, use getNamesForClass)
        % Error out if ids is not one of above.
            import matlab.net.http.internal.PackageMonitor
            if ischar(ids) || isstring(ids) || iscell(ids)
                names = matlab.net.internal.getStringVector(ids, mfilename, 'IDS');
            else
                % We want to error out if user specifies HeaderField.empty or a meta.class
                % that doesn't exist (which creates meta.class.empty) with a message that the
                % input was empty, so need to mention 'nonempty' first, before 'vector'.
                validateattributes(ids, {'cell', 'meta.class', 'matlab.net.http.HeaderField', 'string array'}, ...
                    {'nonempty','vector'}, mfilename, 'IDS');
                if isa(ids, 'meta.class')
                    names = arrayfun(@(c)PackageMonitor.getNamesForClass(c), ...
                                     ids, 'UniformOutput', false);
                    names = [names{:}];
                else
                    names = string.empty;
                    % input was HeaderField array
                    for i = 1 : length(ids)
                        if isempty(ids(i).Name)
                            names = [names PackageMonitor.getNamesForClass(metaclass(ids(i)))]; %#ok<AGROW>
                        else
                            names = [names ids(i).Name]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        function [names, classes] = getNamesAndClasses(args)
        % Parse the cell array args and return:
        %   names   string array of names of HeaderFields and strings in args
        %   classes meta.class array of meta.class objects in args
            ids = matlab.net.http.HeaderField.getFieldsVector(args);
            if isempty(ids)
                ids = matlab.net.http.HeaderField.getFieldsVector(args,'meta.class');
                if isempty(ids)
                    ids = matlab.net.http.HeaderField.getNameVector(args);
                end
            end
            names = matlab.net.http.HeaderField.getMatchingNames(ids);
            if isa(ids, 'meta.class')
                classes = ids;
            else
                classes = [];
            end
        end
    end
end

function obj = instantiate(metaclass, varargin)
% Instantiate the specifed class by calling its constructor with varargin parameters.
% If "too many arguments" error occurs, and varargin has 2 arguments, try calling it
% with just the 2nd argument (which is the value).
    try
        obj = feval(metaclass.Name, varargin{:});
    catch e
        if strcmp(e.identifier, 'MATLAB:maxrhs') && length(varargin) == 2
            obj = feval(metaclass.Name, varargin{2});
        else
            rethrow(e);
        end
    end
end

function field = createField(name, varargin)
% If a subclass of matlab.net.http.HeaderField in the matlab.net.http.field package
% is found that implements the field name return the field object. Otherwise returns
% [].
    metaclass = matlab.net.http.internal.PackageMonitor.getClassForName(name);
    if isempty(metaclass)
        field = [];
    else
        % Subclass found; instantiate it. This has the side-effect of validating the
        % name and value.
        if isscalar(string(feval([metaclass.Name '.getSupportedNames'])))
            % supports just one name, so constructor has no name argument
            field = instantiate(metaclass, varargin{:});
            field.Name = name; % insure the name has the same case as what was given
        else
            field = instantiate(metaclass, name, varargin{:});
        end
    end
end

function field = createFieldSafe(name, varargin)
% createFieldSafe  Create a HeaderField of the appropriate subclass from the name and
% value. If the subclass complains, create one of type matlab.net.http.field.Generic.
    try
        field = matlab.net.http.HeaderField.createHeaderField(name, varargin{:});
    catch
        field = matlab.net.http.field.GenericField(name, varargin{:});
    end
end




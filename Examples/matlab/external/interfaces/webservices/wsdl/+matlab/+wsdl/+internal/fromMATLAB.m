function res = fromMATLAB(name, value, type, boxit, isArray, origType)
%fromMATLAB - Convert the MATLAB value to a value that is suitable as an
%  argument a Java method that takes a parameter of a type corresponding to the XML
%  type specified.  The correspondence assumed is that in the table of CXF
%  conversions of XML to Java in
%  http://docs.oracle.com/cd/E13222_01/wls/docs103/webserv/data_types.html#wp221277
%  and implemented in getJavaType() in createWsdlClient().  For example the Java
%  parameter type for an XML int is int, and for an XML dateTime it's
%  javax.xml.datatype.XMLGregorianCalendar.
%
% We try to accept a value of any reasonable type that can be converted to the 
% desired type, so any numeric input type will be accepted for any XML numeric type.
% For numeric types except long, this means that we'll return a double, since MATLAB
% allows a double to be a valid argument for all the Java numeric types.  For 
% long that doesn't fit accuratey into a double, we'll return an int64.  For other
% XML types represented as Java objects, we'll construct a Java object.
%
%   name    -- cell array of two strings, the first naming the object or method
%              and the second naming the parameter.
%   value   -- the value.  If ~isArray, it must be convertible to a Java scalar;
%              otherwise it can be a vector or cell array of strings.  If Java, it
%              must be the Java type that the XML type maps to.  It may be empty
%              if the Java class it maps to is an object and not a primitive.
%   type    -- a string that is an XML schema builtin type, like 'string' or 'dateTime'
%   boxit   -- (optional) if true, box primitives in Java objects, e.g. 'int' to 'java.lang.Integer'
%   isArray -- (optional) value may be a vector that we wrap in java.util.List
%   origType-- used only on recursive calls, the original type specified, when the
%              recursive call specifies a different type
%   res     -- a value that can be used as an argument to the Java method.  If value
%              is empty, the result is empty only if null is an acceptable value for
%              the return type (i.e. boxit is specified or it's not a primitive).
%
% This function is for internal use only and may change in a future release.

% Copyright 2014 The MathWorks, Inc.

% In this function we explicitly check for bad input types in order to avoid the user
% seeing Java exceptions here or later when this return value is input to a Java
% method.

    import matlab.wsdl.internal.fromMATLAB
    persistent dtf undef
    % If any code below doesn't set res, we detect it at the bottom and issue an
    % "illegal type" message. 
    res = NaN;
    if nargin < 4
        boxit = false;
    end
    if nargin > 4 && isArray 
        if isempty(value)
            res = value;
            return;
        end;
        % If array required, make a java.util.List of converted elements by calling
        % this function recursively on each element, boxing primitives.
        if regexp(type,'^(g|date|time)','once')
            % Since date and time parameters may already be vectors, we need to 
            % handle them by row, each row being a value.  This won't handle
            % multi-dimensional arrays.
            s = size(value);
            res = java.util.ArrayList(s(1));
            for i = 1 : s(1)
                res.add(fromMATLAB(name, value(i,:), type, true, false));
            end
        else
            % The *Binary types are already vectors, and we're not supporting arrays
            % of them, so rule them out
            if isempty(regexp(type,'Binary$','once'))
                % For scalar values, allow them to be row, column or even arbitrary
                % dimensions (which are flattened).  This works on numeric or cell arrays.
                if strcmp(type,'string') && ~iscell(value)
                    % if type is string and value is not a cell array of them, we
                    % have just one element.
                    res = java.util.ArrayList(1);
                    res.add(fromMATLAB(name, value, type, true, false));
                else
                    % in other cases, compute total number of elements
                    num = prod(size(value)); %#ok<PSIZE> because numel is overridden for datetime
                    res = java.util.ArrayList(num);
                    % We can't just use arrayfun because order isn't guaranteed, and
                    % we need to preserve order.  In case it's multidimensional, convert
                    % to a column vector, ordered by column.
                    value = reshape(value,num,1); 
                    for i = 1 : num;
                        if iscell(value)
                           res.add(fromMATLAB(name, value{i}, type, true, false)); 
                        else
                           res.add(fromMATLAB(name, value(i), type, true, false));
                        end
                    end
                end
            end
        end
    else
        % Argument is expected to convertible to an XML scalar type (which includes
        % XML *Binary types even though they are arrays in MATLAB and Java).
        try
            % NOTE: for all types that map to Java classes, must check isempty(value)
            % and just return value, which will be converted to Java null. For
            % primitive types where boxit is false, isempty(value) is an error, which
            % will be thrown if res is not set.
            if type(1) == 'g'
                % Handle gMonth, gYear, etc. all the same as date
                type = 'g';
            end
            switch type
                case 'string'  % Convert to String; accept char or String
                    if isa(value,'char') && isrow(value) 
                        % Since MATLAB converts char to java.lang.String automatically,
                        % we don't need to convert unless boxing
                        if boxit
                            res = java.lang.String(value);
                        else
                            res = value;
                        end
                    elseif isempty(value)
                        res = value;
                    end
                case 'g'
                    % convert a calendarDuration into an XMLGregorianCalendar with no time
                    if isempty(value)
                        res = value;
                        return;
                    end
                    if ~isa(value, 'calendarDuration')
                        value = calendarDuration(value);
                    end
                    if isscalar(value)
                        getdtf
                        [y,m,d] = split(value,'ymd');
                        if y == 0, y = undef; end;
                        if m == 0 
                            m = undef; 
                        end;
                        if d == 0, d = undef; end;
                        res = dtf.newXMLGregorianCalendarDate(y,m,d,undef);
                    end
                case 'time'
                    % For time we'll accept a duration or datetime
                    if isempty(value)
                        res = value;
                        return;
                    end
                    if ~isa(value, 'duration') && ~isa(value, 'datetime')
                        value = duration(value);
                    end
                    if isscalar(value)
                        [h,m,s] = hms(value);
                        getdtf
                        % the only way to get a time zone into the time field is to
                        % specify it as a datetime, not a duration
                        if isa(value, 'datetime') && ~isempty(value.TimeZone)
                            tz = minutes(tzoffset(value));
                        else
                            tz = undef;
                        end
                        secs = floor(s);
                        res = dtf.newXMLGregorianCalendar(h, m, secs, ...
                            java.math.BigDecimal(s - secs), tz);
                    end
                case {'dateTime','date'} % Convert to XMLGregorianCalendar
                    % We'll accept Java XMLGregorianCalendar, Date, or various MATLAB date objects.
                    if isempty(value)
                        res = value;
                        return;
                    end
                    if ~isa(value, 'datetime')
                        value = datetime(value);
                    end
                    if isscalar(value)
                        getdtf
                        yr = year(value);
                        mo = month(value);%convertMonthToJava(month(value));
                        dy = day(value);
                        if isempty(value.TimeZone)
                            tz = undef;
                        else
                            tz = minutes(tzoffset(value));
                        end
                        switch type
                            case 'dateTime'
                                secs = second(value);
                                ss = floor(secs);
                                fs = round((secs - ss)*1000);
                                res = dtf.newXMLGregorianCalendar(yr, mo, dy, ...
                                    hour(value), minute(value), ss, fs, tz);
                            case 'date'
                                res = dtf.newXMLGregorianCalendar(yr, mo, dy, tz);
                        end
                    end
                    
                 case {'boolean','byte','double','float','int','short'}
                    % All calls to double() in the numeric conversions below serve
                    % two purposes:
                    %  1. Convert every number to a type acceptable as parameter of a
                    %     any Java number (or boolean) type, which is double.
                    %  2. Throw error if it's not a number type, before it gets to Java.
                    %     This avoids having to make isnumeric() tests.
                    if boxit
                        if isempty(value)
                            res = value;
                            return;
                        end
                        if strcmp(type,'int')
                            jclass = 'java.lang.Integer';
                        else
                            type(1) = upper(type(1));
                            jclass = ['java.lang.' type];
                        end
                        if isscalar(value)
                            try
                                % An exception means it was not one of the expected
                                % primitive types convertible by double() or a call
                                % to the Java constructor for the type.  Don't
                                % set res so that code below will issue proper
                                % message.
                                res = eval([jclass '(double(value))']);
                            catch
                            end
                        end
                    else
                        % plain number with no conversion or logical
                        if isscalar(value) && (isnumeric(value) || islogical(value))
                            res = double(value);
                        end
                    end
                case 'long'
                    % Long could lose precision as double, so leave it unchanged
                    % if caller specified int64 or uint64.  For other numeric input,
                    % double still works.
                    if isnumeric(value) && isscalar(value)
                        if boxit
                            res = java.lang.Long(value);
                        else
                            if isa(value,'int64') || isa(value,'uint64')
                                res = value;
                            else
                                res = double(value);
                            end
                        end
                    elseif isempty(value)
                        res = value;
                    end
                case 'unsignedByte'
                   if isscalar(value) && isnumeric(value)
                        res = double(value);
                        if boxit
                            res = java.lang.Short(res);
                        end
                    elseif isempty(value)
                        res = value;
                    end
                case 'unsignedInt'
                    if isscalar(value) && isnumeric(value)
                        res = double(value);
                        if boxit
                            res = java.lang.Long(res);
                        end
                    elseif isempty(value)
                        res = value;
                    end
                case 'unsignedShort'
                    if isscalar(value) && isnumeric(value)
                        res = double(value);
                        if boxit
                            res = java.lang.Integer(res);
                        end
                    elseif isempty(value)
                        res = value;
                    end
                case 'unsignedLong'
                    if isscalar(value) && isnumeric(value)
                        % this handles all numbers accurately
                        res = java.math.BigInteger(int2str(value));
                    elseif isempty(value)
                        res = value;
                    end
                case {'hexBinary','base64Binary'}
                    % These represented as Java byte[].  Any MATLAB numeric
                    % array converts to byte[] if the method signature
                    % requires it, so nothing to do except flatten.
                    res = value(:)';
                case 'duration'
                    % For duration, accept a MATLAB duration or calendarDuration
                    if isempty(value)
                        res = value;
                        return;
                    end
                    if ~isa(value,'duration') && ~isa(value,'calendarDuration')
                        try 
                            value = duration(value);
                        catch
                            value = calendarDuration(value);
                        end
                    end
                    positive = true;
                    if isa(value,'duration') 
                        if value < 0
                            positive = false;
                            value = abs(value);
                        end
                        time = value;
                        d(1:3) = 0;
                    else
                        % For calendarDuration, all numbers must have the same sign
                        % (or be 0)
                        [d(1),d(2),d(3),t] = split(value,'ymdt');
                        if all(sign(d) >= 0) && t >= 0
                            time = t;
                        elseif all(sign(d) <= 0) && t <= 0
                            d = -d;
                            time = -t;
                            positive = false;
                        else
                            error(message('MATLAB:webservices:CalDurationSigns',char(value)))
                        end
                    end
                    yy = java.math.BigInteger.valueOf(d(1));
                    mm = java.math.BigInteger.valueOf(d(2));
                    dd = java.math.BigInteger.valueOf(d(3));
                    [h,m,s] = hms(time);
                    h = java.math.BigInteger.valueOf(h);
                    m = java.math.BigInteger.valueOf(m);
                    s = java.math.BigDecimal.valueOf(s);
                    getdtf
                    res = dtf.newDuration(positive,yy,mm,dd,h,m,s);
                case {'NOTATION','QName'}
                    % Qname or NOTATION assumed to be formatted QName string
                    if (isa(value,'char') && isrow(value)) || isa(value,'java.lang.String')
                        res = javax.xml.namespace.QName.valueOf(value);
                    elseif isempty(value)
                        res = value;
                    end
                case {'anyType','anySimpleType'}
                    if isa(value,'matlab.wsdl.internal.WsdlObject')
                        res = value.getObj;
                    elseif isnumeric(value) || ischar(value) || islogical(value)
                        % These types converted properly by MATLAB once we flatten
                        res = value(:)';
                    elseif isa(value,'duration') || isa(value,'calendarDuration')
                        res = fromMATLAB(name,value,'duration',boxit,isArray,type);
                    elseif isa(value,'datetime')
                        % TODO: determine whether datetime should be a dateTime, time
                        % or date depending on what fields are visible in its format.
                        % For now, always convert to dateTime.
                        res = fromMATLAB(name,value,'dateTime',boxit,isArray,type);
                    end
                case 'decimal'
                    % CXF wants a BigDecimal for this type
                    if isscalar(value) && isnumeric(value)
                        if isa(value,'uint64') && value > intmax('int64')
                            % uint64's larger than intmax(int64) require use of the
                            % string constructor to preserve the full value.
                            res = java.math.BigDecimal(int2str(value));
                        else
                            % all others use one of the numeric constructors that
                            % take an int, double or long
                            res = java.math.BigDecimal(value);
                        end
                    elseif isempty(value)
                        res = value;
                    end
                otherwise
                    if ~isempty(regexp(type, '(nteger|Int|Short|Byte)$', 'ONCE')) % sic
                        % CXF wants a BigInteger for these arbitrary-precision
                        % integer types
                        if isinteger(value) 
                            if isa(value,'uint64') && value > intmax('int64')
                                % uint64's larger than intmax(int64) require use of the
                                % string constructor to preserve the full value.
                                res = java.math.BigInteger(int2str(value));
                            else
                                % all other integers can use valueOf that takes long
                                res = java.math.BigInteger.valueOf(value);
                            end
                        else
                            % If value is floating point, convert to (possibly very
                            % long) string and use string constructor, to be sure we
                            % get full magnitude, as there is no double constructor.
                            if rem(value,1) == 0
                                obj.value = java.math.BigInteger(num2str(value,310));
                                res = obj.value;
                            else
                                % Not a whole number; round and truncate
                                res = java.math.BigInteger(num2str(fix(value+.5),310));
                            end
                        end
                    elseif (ischar(value) && isrow(value)) || isa(value,'java.lang.String')
                        % all other types assumed string
                        if boxit && ischar(value)
                            res = java.lang.String(value);
                        else
                            res = value;
                        end
                    elseif isempty(value)
                        res = value;
                    end                    
            end
        catch ex
            % if Java exception occurred in above conversions, throw plain
            % MException with the Java message
            if isa(ex, 'matlab.exception.JavaException')
                if ~exist('origType','var')
                    origType = type;
                end
                valtype = getValueType(value);
                error(message('MATLAB:webservices:IllegalArgType', ...
                        valtype, origType, char(ex.ExceptionObject.getLocalizedMessage)));
            else
                ex.rethrow
            end
        end
    end
    if ~isempty(res) && isnumeric(res) && isscalar(res) && isnan(res)
        % if res is still NaN, this is an error
        if isempty(value)
            error(message('MATLAB:webservices:EmptyParameter', name{1}, name{2}, type));
        else
            if ~exist('origType','var')
                origType = type;
            end
            valtype = getValueType(value);
            error(message('MATLAB:webservices:IllegalArgTypeNoMsg',...
                name{1}, valtype, name{2}, origType));
        end
    end
    
    function getdtf
        if isempty(dtf)
            dtf = javax.xml.datatype.DatatypeFactory.newInstance;
            undef = javax.xml.datatype.DatatypeConstants.FIELD_UNDEFINED;
        end
    end

    function res = getValueType(value)
        % return class(value) if scalar, else with its dimentions in form
        % '1x2x6 int8'
        if ~isscalar(value)
            res = [strjoin(strsplit(num2str(size(value))),'x') ' ' class(value)];
        else 
            res = class(value);
        end
    end

end

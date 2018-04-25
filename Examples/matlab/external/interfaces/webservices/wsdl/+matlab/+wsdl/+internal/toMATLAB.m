function res = toMATLAB(value, type, isArray, pkgName)
    % Convert value, a primitive or Java class returned from a previous call to a
    % Java method in the service or a get method in a derived class, to a MATLAB
    % value based on the XML builtin 'type' as per our XML-to-MATLAB conversion
    % rules.  If isArray, value is expected to be a java.util.List of them, which
    % we'll convert to a vector or cell array.  This is the reverse of the
    % conversions in fromMATLAB, but more strict in that we only accept
    % exactly the expected Java type as input as documented in
    % http://docs.oracle.com/cd/E13222_01/wls/docs103/webserv/data_types.html#wp221277
    % with the addition (missing from that table) that unsignedLong is converted to
    % BigInteger.
    %
    %   value   the Java value, which may already be converted to a MATLAB primitive
    %           for certain types
    %   type    the XML type from the schema
    %   isArray true if the schema said it was an array
    %   pkgName MATLAB package name, required if type is anyType, and used only if
    %           value is a derived type
    %
    % Return values are one of:
    %
    % if type is a cell array, this means 'anyType' which refers to a complex type
    % or simple type:  
    %     If value is a Java object of a type that is one of the types we convert
    %        from below, process as below, process as if 'anySimpleType' below.    
    %        If another type, get an instance of the MATLAB derived class constructed
    %        from that object, found in the package name in type{1}.
    %     If value is not a Java object, just return it.
    %   
    % if value is [] return [].  This would correspond to a return value that is
    %                            nillable, though we can't verify that.
    % if ~isArray:
    %   scalar single, double, int8, int16, int32, int64, uint8, uint16, uint32, uint64
    %          for type = float, double, byte, short, int, long, unsignedByte, etc.
    %   scalar logical for type = boolean
    %   string for type = string, QName, NOTATION
    %   calendarDuration for type = gYear, gMonth, gDay, gYearMonth, gMonthDay
    %   datetime for type = dateTime, time
    %   duration or calendarDuration for type = duration, depending on existence of
    %      month, day or year fields
    %   double for type = decimal, integer, and all *Integer types
    %   for 'anySimpleType', convert to one of above depending on the type of value:
    %      MATLAB type: double, logical or string
    %      javax.xml.datatype.XMLGregorianCalendar: datetime year/month/day complete; 
    %         calendarDuration otherwise
    %      javax.xml.datatype.Duration: duration if no month, day or year; 
    %         calendarDuration otehrwise
    %      javax.xml.namespace.QName: string
    % if isArray:
    %   column vector for all above scalar types
    %   cell array of strings for type = string 
    %   nx3 array of double for type = gYear, gMonth, gDay, gYearMonth, gMonthDay
    %
    % This function is for internal use only and may change in a future release.
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    import matlab.wsdl.internal.toMATLAB;
    persistent doubleConversions
    if isempty(doubleConversions)
        % These are the XML numeric types that CXF converts to corresponding Java
        % primitive types, which MATLAB then converts to double, which we then need to
        % convert to the MATLAB type we really want.
        xmlTypes = ...
          {'byte','short','int','unsignedByte','unsignedShort','unsignedInt','float','double','anyType'};
        mTypes = ...
          {@int8, @int16,@int32,@uint8,        @uint16,        @uint32,      @single,@double, @(x)x};
        doubleConversions = containers.Map(xmlTypes, mTypes);
    end
    if isempty(value)
        res = value;
        return;
    end
    if ~exist('pkgName','var') 
        pkgName = '';
    end
    if (~isjava(value))
        % Non-Java values result when the Java function returns a primitive number or
        % boolean, which MATLAB always converts to a double or logical, or a char. If
        % a number, we have to convert to the type we want.  For example, we want an
        % XML short to result in an int8.  Based on above noted XML-to-Java
        % conversions, CXF generates code to return a Java short, but MATLAB has
        % converted that short return value to double, so we then have to convert the
        % double to int8.  If the XML type was unsignedShort, CXF would return int,
        % which MATLAB converts to double, which we convert to uint8, etc.

        % An anyType is returned from Java as Object, which our call to callJava
        % will return as either an appropriate MATLAB primitive or leave as a
        % Java object.  We'll allow certain primitives to be returned for anyType.
        isany = strcmp(type,'anyType');
        if (isany || strcmp(type,'boolean')) && islogical(value)
            res = value;
            return;
        elseif isa(value,'double')
            func = doubleConversions(type);
            res = func(value);
            return;
        elseif (isany || strcmp(type,'long') || strcmp(type,'unsignedInt')) && isa(value,'int64')
            % If the XML type is long or unsignedInt we expect Java call to return an
            % int64 which doesn't need conversion (because we have wrapped the call
            % in callJava).  Note that XML unsignedLong is converted by CXF to a
            % java.math.BigInteger, not a primitive, so we handle that below.
            res = value;
            return;
        elseif (isany || ~isempty(regexp(type,'Binary$','once'))) && isa(value,'int8')
            % for the *Binary XML types, which are essentially unsigned byte arrays,
            % CXF returns a Java byte[] array (signed 8-bit numbers) which MATLAB has
            % already converted to an int8 array, so just typecast to uint8 to get
            % them back to unsigned
            res = typecast(value,'uint8');
            return;
        elseif isa(value,'char') && (isany || strcmp(type,'string'))
            % If the Java result came from a field or method declared Object, and
            % that object is a String, MATLAB auto-converts it to char, so nothing to
            % do.  This is the case, for example, for javax.ws.Holder.value fields.
            res = value;
            return;
        end
        % no other non-Java values expected
        throwTypeError(value, type);
    end
    if nargin < 3 
        isArray = false;
    end
    if isArray
        % Array (List) types should be returned as MATLAB array of converted values
        n = value.size; % we expect value to be java.util.List
        if n == 0
            res = [];
            return;
        end
        % Convert the last value and use it, plus the XML type, to determine size and
        % type of array. We can't just call List.get() to fetch the last element,
        % because that method is declared to return Object, which causes Number
        % objects to be converted to double, which could lose precision if it is a
        % Long, so fetch element through a helper method declared to return a Number
        % object.
        val = com.mathworks.jmi.Matlab.getAsNumber(value, n-1);
        if isempty(val);
            % not a Number object, so safe to get value directly as Object because
            % MATLAB won'd automatically convert the result.  Exception is if the
            % value is a String, which MATLAB will convert to char.
            val = value.get(n-1);
        end
        % Now recursively convert the Object with ~isArray; this returns one of the
        % ~isArray types as noted above.  char doesn't need conversion
        if ~ischar(val)
            val = toMATLAB(val, type, false, pkgName);
        end
        % Store last element, converted, in order to efficiently size the array.
        % Note this method forces the result to be a column vector.
        if ischar(val)
            res{n,1} = val;
        else
            % While this code doesn't care, we don't expect to get any non-char
            % vectors from toMATLAB when ~isArray 
            % TODO: BUG in datetime indexing requires this line first
            if isa(val,'datetime'), res = val; end
            res(n,1:length(val)) = val;
        end       
        % Convert remaining elements of List just as we did the last element, blindly
        % trusting they are all of the same type as determined above.
        for i = 1 : n-1
            obj = com.mathworks.jmi.Matlab.getAsNumber(value, i-1);
            if isempty(obj) 
                obj = value.get(i-1);
            end
            if ischar(obj)
                val = obj;
            else
                val = toMATLAB(obj, type, false, pkgName);
            end
            if iscell(res)
                % if we're building a cell array, just add the value
                res{i} = val;
            else
                % In case toMATLAB returns a vector object for a given type,
                % expand the width (number of columns) of the array if necessary to
                % accommodate the longest vector.
                res(i,1:length(val)) = val;
            end
        end
    else
        % We have a Java Object, not a primitive.  
        if strcmp(type,'anyType') || strcmp(type,'anySimpleType')
            % for these, we expect CXF would always return us a java.lang.Object
            if isa(value,'java.lang.Object')
                if strcmp(type,'anyType')
                    res = convertAny(value,type,pkgName);
                else
                    res = convertAny(value,type);
                end
            else
                throwTypeError(value,type);
            end
        elseif isa(value, 'java.lang.Number')
            % If CXF gave us a Number, we need to unbox it to the appropriate
            % primitive.  First check for special cases involving XML long and the
            % non-primitive integer and decimal types which CXF returns as BigInteger
            % and BigDecimal.
            if isa(value, 'java.lang.Long') && strcmp(type,'long')
                % CXF returns Long for both XML unsignedInt and long.  In the case of
                % long, need to preserve all 64 bits, so get as MATLAB int64.
                res = matlab.internal.callJava('longValue',value); % returns int64
                return;
            elseif isa(value, 'java.math.BigInteger') 
                % CXF returns BigInteger for the XML *nteger types and unsignedLong.
                % The former becomes double while the latter must be uint64.  This
                % leads to the unfortunate situation that an unsignedLong has more
                % precision than Integer.  Alas this is allowed by the XML spec,
                % which requires only 18 digits of precision.
                if strcmp(type,'unsignedLong')
                    value = matlab.internal.callJava('longValue',value);
                    res = typecast(value,'uint64');
                    return;
                end
                if regexp(type,'nteger$')
                    res = double(value);
                    return;
                end
                throwTypeError(value,type);
            elseif isa(value, 'java.math.BigDecimal')
                % CXF returns BigDecimal for XML decimal type
                if strcmp(type,'decimal')
                    res = double(value);
                    return;
                end
                throwTypeError(value,type);
            end
            % For all Number types not converted above, call us recursively with the
            % unboxed doubleValue, which can hold the value accurately.  This is what
            % we would have gotten if CXF had returned a primitive type.  The
            % recursive call will convert to the destination MATLAB type.
            res = toMATLAB(value.doubleValue, type, false, pkgName);
        else
            % Now we are left with a non-Number Java object to convert
            switch type
                case 'boolean'
                    if isa(value, 'java.lang.Boolean') 
                        res = value.booleanValue; % becomes logical
                    else
                        throwTypeError(value,type);
                    end
                case 'string'
                    if isa(value, 'java.lang.String')
                        res = char(value);
                    else
                        throwTypeError(value, type);
                    end
                case {'gMonth','gYear','gDay','gMonthDay','gYearMonth'}
                    % These become calendarDurations.  Caller can extract
                    % year,month,day fields using:
                    %  [y,m,d] = split(res,'ymd')
                    if ~isa(value,'javax.xml.datatype.XMLGregorianCalendar')
                        throwTypeError(value,type);
                    end
                    undef = javax.xml.datatype.DatatypeConstants.FIELD_UNDEFINED;
                    res = years(0);
                    if value.getYear ~= undef
                        res = res + calyears(value.getYear);
                    end
                    if value.getMonth ~= undef
                        res = res + calmonths(value.getMonth);
                    end
                    if value.getDay ~= undef
                        res = res + caldays(value.getDay);
                    end
                case {'dateTime','date','time'}
                    % These become datetime objects.  Caller can get individual
                    % components by accessing
                    % Year/Month/Day/Hour/Minute/Second/TimeZone fields.  Values of
                    % fields not relevant for the type (e.g., Hour for 'date' or
                    % Month for 'time') are undefined. TimeZone is always relevant
                    % but may be '' if unspecified.
                    if ~isa(value,'javax.xml.datatype.XMLGregorianCalendar')
                        throwTypeError(value,type);
                    end
                    undef = javax.xml.datatype.DatatypeConstants.FIELD_UNDEFINED;
                    % create, effectively a 3-element date vector for date, or
                    % a 6-element for dateTime and time
                    if ~strcmp(type,'date')
                        res(6) = value.getSecond;
                        if res(6) ~= undef 
                            fs = value.getFractionalSecond; % expect BigDecimal
                            if ~isempty(fs)     
                                res(6) = res(6) + fs.doubleValue;
                            end
                        end    
                        res(5) = value.getMinute;
                        res(4) = value.getHour;
                        % if all time fields are undefined, convert to date only
                        if res(4:end) == undef
                            res(4:end) = [];
                        end
                    end
                    res(3) = value.getDay;
                    res(2) = value.getMonth;
                    res(1) = value.getYear;
                    res(res == undef) = 0; % set any remaining undef fields to 0
                    tz = value.getTimezone; % time zone in minutes of offset from UTC
                    if tz ~= undef
                        % convert to GMT+HH:MM or GMT-HH:MM
                        tz = sprintf('GMT%+03d:%02d', fix(tz/60), rem(abs(tz),60));
                        res = datetime(res,'TimeZone',tz);
                    else
                        res = datetime(res);
                    end
                case 'duration'
                    % This creates a duration or calendarDuration depending on
                    % whether years, months or days are specified.
                    if ~isa(value,'javax.xml.datatype.Duration')
                        throwTypeError(value,type);
                    end
                    % undefined values here are zero
                    y = value.getYears;
                    m = value.getMonths;
                    d = value.getDays;
                    % This is a MATLAB duration
                    res = hours(value.getHours) + minutes(value.getMinutes) + ...
                          seconds(value.getSeconds);
                    if value.getSign < 0
                        res = -res;
                        y = -y; 
                        m = -m; 
                        d = -d;
                    end
                    if y ~= 0 || m ~= 0 || d ~= 0
                        % This creates a calendarDuration
                        res = calyears(y) + calmonths(m) + caldays(d) + res;
                    end
                case {'NOTATION','QName'}
                    if isa(value,'javax.xml.namespace.QName')
                        res = value.toString;
                    else
                        throwTypeError(value,type);
                    end
                otherwise
                    % All other types are strings
                    if isa(value,'java.lang.String')
                        res = char(value);
                    elseif ischar(value)
                        res = value;
                    else
                        throwTypeError(value,type);
                    end
            end
        end
    end
end

function throwTypeError(value,type)
% Throw an error if the value is not allowed for the specified type.  This indicates
% a bug in our code, where we got a type from CXF that we didn't expect for the XML
% type.
    throwAsCaller(MException('MATLAB:webservices:InternalErrorType', '%s', ...
          message('MATLAB:webservices:InternalErrorType', class(value), type).getString));
end    

function res = convertAny(value,type,pkgName)
    % Convert the java.lang.Object value to a corresponding MATLAB type.
    %  value   a java.lang.Object or null
    %  type    'anyType' or 'anySimpleType'
    %  pkgName MATLAB package name, used for anyType if value is a derived type
    
    % When the XML schema returns an anyType or anySimpleType, CXF represents it as
    % java.lang.Object and returns a Java object of a class corresponding the actual
    % XML type of the data.  So if the XML type of the data is long the Java type is
    % java.lang.Long.  In these cases we want to convert the Java object into the
    % same MATLAB type that we would convert it to if the schema type actually said
    % long (which in this case, would be 'int64'). In this way, if the return value
    % from this function is passed back into another method that takes anyType (and
    % is thus declared to take Object), fromMATLAB will turn it back into
    % java.lang.Long which CXF will pass back as XML long as the service might
    % expect.
    
    % This attempt to preserve type isn't perfect, as not all schema types convert to
    % unique Java types, so the reverse conversion may not be an exact inverse (e.g.,
    % XML unsignedByte and short both convert to java.lang.Short, which we get as
    % 'int16', which on input we'll convert back to java.lang.Short, which CXF will
    % always convert to XML short, not unsignedByte). But even though the type is not
    % reversed, the value is perserved.
    
    import matlab.wsdl.internal.toMATLAB;
    persistent anyConversions;
    if isempty(anyConversions)
        javaTypes = ...
            {'java.lang.Byte',      'java.lang.Short',        'java.lang.Integer', ...
             'java.lang.Long',      'java.lang.Boolean',      'java.lang.String', ...
             'java.lang.Float',     'java.lang.Double',       'java.lang.BigInteger', ...
             'java.lang.BigDecimal','javax.xml.namespace.QName'};
        methods = ...
            {{'byteValue',@int8},   {'shortValue',@int16},    {'intValue',@int32}, ...
             {'longValue',@int64},  {'booleanValue',@logical},{'toString',@char}, ...
             {'floatValue',@double},{'doubleValue',@double},  {'doubleValue',@double}, ...
             {'doubleValue',@double},{'toString',@char}};
        anyConversions = containers.Map(javaTypes, methods);
    end
    
    cls = char(value.getClass.getName);
    try
        % Do the simple conversions
        methods = anyConversions(cls);
    catch 
        % An exception means it's not in the list.  Need to use isa instead of
        % switch on getClass(value) because these are interfaces.
        if isa(value,'javax.xml.datatype.XMLGregorianCalendar')
            res = toMATLAB(value,'dateTime',false,pkgName);
        elseif isa(value,'javax.xml.datatype.Duration')
            res = toMATLAB(value,'duration',false,pkgName);
        else
            switch(cls)
                case '[B'
                    % This is a Java primitive byte array which we want to convert to
                    % uint8 array that represents one of the *Binary types. Use
                    % Vector.get() as a quick and dirty way to get back the object we
                    % put in, but this time with MATLAB conversion applied.
                    v = java.util.Vector(1);
                    v.add(value);
                    % MATLAB converts return value of byte[] to int8 array, so cast.
                    res = typecast(v.get(0),'uint8');
                otherwise
                    % if it's some other Java type, this should only be returned for
                    % anyType, because we handled all the anySimpleTypes above.
                    if strcmp(type,'anyType')
                        res = matlab.wsdl.internal.WsdlObject.getMATLABObject(value,pkgName);
                    else
                        throwTypeError(value,type);
                    end
            end
        end
        return;
    end
    jmethod = methods{1};
    mfunc = methods{2};
    res = mfunc(matlab.internal.callJava(jmethod, value));
end

          
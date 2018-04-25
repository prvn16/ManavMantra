classdef (Sealed, InferiorClasses = {?matlab.graphics.axis.Axes}) duration < matlab.mixin.internal.MatrixDisplay
    %DURATION Arrays to represent lengths of time in fixed-length time units.
    %   duration arrays store values to represent lengths of time measured in
    %   fixed-length units of hours, minutes, and seconds.  Duration arrays
    %   help simplify calculations on datetime arrays involving time units such
    %   as hours and minutes.
    %
    %   Use the YEARS, DAYS, HOURS, MINUTES, and SECONDS functions to create
    %   durations from numeric values. Use the DURATION constructor to create an
    %   array of durations from numeric arrays as a combination of individual units.
    %
    %   You can subscript and manipulate duration arrays just like ordinary
    %   numeric arrays. Duration arrays also support sorting and comparison and
    %   mathematical calculations.
    %
    %   Each element of a duration array represents a length of time in
    %   fixed-length time units. Use a calendarDuration array to represent
    %   lengths of time in terms of flexible-length calendar units. Use a
    %   datetime array to represent points in time.
    %
    %   DURATION properties:
    %       Format - A character vector describing the format in which the array's values display.
    %
    %   DURATION methods and functions:
    %     Creating arrays of durations:
    %       duration    - Create an array of durations.
    %       seconds     - Create durations from numeric values in units of seconds.
    %       minutes     - Create durations from numeric values in units of minutes.
    %       hours       - Create durations from numeric values in units of hours.
    %       days        - Create durations from numeric values in units of standard-length days.
    %       years       - Create durations from numeric values in units of standard-length years.
    %       isduration  - True for an array of durations.
    %     Conversion to numeric values:
    %       hms         - Convert durations to equivalent numbers of hours, minutes, and seconds.
    %       seconds     - Convert durations to equivalent numeric values in units of seconds.
    %       minutes     - Convert durations to equivalent numeric values in units of minutes.
    %       hours       - Convert durations to equivalent numeric values in units of hours.
    %       days        - Convert durations to equivalent numeric values in units of standard-length days.
    %       years       - Convert durations to equivalent numeric values in units of standard-length years.
    %     Mathematical calculations with durations:
    %       abs         - Absolute value for durations.
    %       uminus      - Negation for durations.
    %       plus        - Addition for durations.
    %       minus       - Subtraction for durations.
    %       times       - Multiplication for durations.
    %       mtimes      - Matrix multiplication for durations.
    %       ldivide     - Left division for durations.
    %       rdivide     - Right division for durations.
    %       colon       - Create equally-spaced sequence of durations.
    %       linspace    - Create equally-spaced sequence of durations.
    %       sum         - Sum of durations.
    %       diff        - Duration differences.
    %       mean        - Mean of durations.
    %       median      - Median of durations.
    %       mode        - Most frequent duration value.
    %       floor       - Round durations towards minus infinity.
    %       ceil        - Round durations towards infinity.
    %       round       - Round durations.
    %       isnan       - True for durations that are Not-a-Number.
    %       isinf       - True for durations that are +Inf or -Inf.
    %       isfinite    - True for durations that are finite.
    %     Comparisons between durations:
    %       eq          - Equality comparison between durations.
    %       ne          - Not-equality comparison between durations.
    %       lt          - Less than comparison between durations.
    %       le          - Less than or equal comparison between durations.
    %       ge          - Greater than or equal comparison between durations.
    %       gt          - Greater than comparison between durations.
    %       min         - Find minimum of durations.
    %       max         - Find maximum of durations.
    %       sort        - Sort durations.
    %       sortrows    - Sort rows of a matrix of durations.
    %       issorted    - True for sorted duration vectors and matrices.
    %     Set membership:
    %       intersect   - Find durations common to two arrays.
    %       ismember    - Find durations in one array that occur in another array.
    %       setdiff     - Find durations that occur in one array but not in another.
    %       setxor      - Find durations that occur in one or the other of two arrays, but not both.
    %       unique      - Find unique durations in an array.
    %       union       - Find durations that occur in either of two arrays.
    %     Plotting:
    %       plot        - Plot durations.
    %     Conversion to other numeric representations:
    %       datenum     - Convert durations to datenum values.
    %       datevec     - Convert durations to date vectors.
    %     Conversion to strings:
    %       cellstr     - Convert durations to cell array of character vectors.
    %       char        - Convert durations to character matrix.
    %       string      - Convert durations to strings.
    %
    %   Examples:
    %
    %      % Create an array of durations by specifying the number of hours.
    %      % Then add a random number of minutes.
    %      d = hours(1:5)
    %      d = d + minutes(randi([0 59],1,5))
    %
    %      % Set the format to display in timer notation.
    %      d.Format = 'hh:mm:ss'
    %
    %      % Add durations to a datetime.
    %      t0 = datetime('today')
    %      d = hours(1:5) + minutes(randi([0 59],1,5))
    %      t1 = t0 + d
    %
    %      % Find the time difference between two sets of datetimes as durations.
    %      % Then convert those to numeric values, in units of hours.
    %      t0 = [datetime('yesterday') datetime('today') datetime('tomorrow')]
    %      t1 = datetime('now')
    %      d = t1 - t0
    %      s = hours(d)
    %
    %   See also HOURS, MINUTES, SECONDS, DURATION, CALENDARDURATION, DATETIME
    
    %   Copyright 2014-2017 The MathWorks, Inc.
    
    
    properties(GetAccess='public', Dependent=true)
        %FORMAT Display format property for duration arrays.
        %   The Format property of a duration array determines the format in which
        %   the array displays its values. This property is a character vector
        %   constructed using the characters y,d,h,m,s,S to represent time units of
        %   the durations. You can display durations as simple numbers (including a
        %   fractional part), such as 1.234 hrs, using one of the following
        %   formats:
        %
        %      'y' - the number of exact fixed-length (i.e. 365.2425 day) years
        %      'd' - the number of exact fixed-length (i.e. 24 hour) days
        %      'h' - the number of hours
        %      'm' - the number of minutes
        %      's' - the number of seconds
        %
        %   Control the number of significant digits displayed for these formats using
        %   the FORMAT command.
        %
        %   You can display durations in the form of a digital timer using one of the
        %   following formats, where 'dd' indicates exact fixed-length (i.e. 24 hour)
        %   days, 'hh' indicated hours,' mm' indicates minutes, and 'ss' indicates
        %   seconds:
        %
        %      'dd:hh:mm:ss'
        %      'hh:mm:ss' (default)
        %      'mm:ss'
        %      'hh:mm'
        %
        %   These formats only display whole units. However, with 'dd:hh:mm:ss',
        %   'hh:mm:ss', and 'mm:ss', you can also display up to nine fractional second
        %   digits, using 'S'. For example, 'hh:mm:ss.SSS' displays durations out to
        %   milliseconds.
        %
        %   Changing the display format does not change the duration values in the
        %   array, only their display.
        %
        %   See also DURATION.
        Format
    end
    properties(GetAccess='public', Hidden, Constant)
        % This property is for internal use only and will change in a
        % future release.  Do not use this property.
        DefaultDisplayFormat = 'hh:mm:ss';
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        % The duration data, stored as milliseconds
        millis = 0;
        
        % Format in which to display
        fmt = duration.DefaultDisplayFormat;
    end
    properties(GetAccess='private', Constant)
        noConstructorParamsSupplied = struct('Format',false,'InputFormat',false);
    end
    
    % Backward compatibility layer
    properties(GetAccess='private', SetAccess='private', Dependent=true)
        data
    end
    methods
        function d = set.data(d,data)
            d.millis = data * 1000;
        end
    end
    
    methods(Access = 'public')
        function this = duration(inData,varargin)
            %DURATION Create an array of durations.
            %   D = DURATION(H,MI,S) creates an array of durations from numeric arrays
            %   containing the number of hours, minutes, and seconds. H, MI, and S must
            %   be numeric arrays with the same size, or any of them can be a scalar.
            %
            %   D = DURATION(H,MI,S,MS) creates an array of durations from numeric
            %   arrays containing the number of hours, minutes, seconds, and
            %   milliseconds. H, MI, S, and MS must be numeric arrays with the same
            %   size, or any of them can be a scalar.
            %
            %   D = DURATION(DV) creates a column vector of durations from a numeric
            %   matrix DV in the form [H MI S].
            %
            %   D = DURATION(T) where T is a string array, character vector, or
            %   cell array of character vectors, converts the text in T to duration.
            %   Text data is assumed to be of the form 'hh:mm:ss' or 'dd:hh:mm:ss' with
            %   the possible inclusion of fractional digits.
            %
            %   D = DURATION(T,'InputFormat',FMT) converts the text in T to duration
            %   using the format FMT.
            %
            %   D = DURATION(...,'Format',FMT) specifies the format in which D
            %   displays. FMT is a character vector containing the characters y,d,h,m,s
            %   to represent time units of the durations. For the complete
            %   specification, type "help duration.Format".
            %
            %   Examples:
            %
            %      % Two ways to create arrays of random durations between 0 and 1 hour long.
            %      d1 = duration(rand(1,5),0,0)
            %      d2 = hours(rand(1,5))
            %
            %      % Two ways to create equivalent arrays of durations from a specified
            %      % number of minutes and seconds.
            %      d1 = duration(0,1:3,4:6)
            %      d2 = minutes(1:3) + seconds(4:6)
            %
            %      % Two ways to create a duration with hours, minutes and seconds
            %      d1 = duration(10,20,30)
            %      d2 = duration('10:20:30');
            %
            %   See also SECONDS, MINUTES, HOURS, DAYS, YEARS, DURATION, CALENDARDURATION
            
            import matlab.internal.datatypes.parseArgs
            
            if nargin == 0 % same as duration(0,0,0)
                return;
            end
            
            inputFormat = '';
            if isnumeric(inData)
                % Find how many numeric inputs args: count up until the first non-numeric.
                numNumericArgs = 1; % include inData
                for i = 1:numel(varargin)
                    if ~isnumeric(varargin{i}), break, end
                    numNumericArgs = numNumericArgs + 1;
                end
                if numNumericArgs == 1 % duration([h,m,s],...)
                    if ~ismatrix(inData) || ~(size(inData,2) == 3)
                        error(message('MATLAB:duration:InvalidNumericData'));
                    end
                    % Split numeric matrix into separate vectors. Manual
                    % conversion to cell for performance
                    inData = double(inData);
                    inData = {inData(:,1),inData(:,2),inData(:,3)};
                elseif numNumericArgs == 3 % duration(h,m,s,...)
                    inData = [{inData} varargin(1:2)];
                    varargin = varargin(3:end);
                elseif numNumericArgs == 4 % duration(h,m,s,ms,...)
                    inData = [{inData} varargin(1:3)];
                    varargin = varargin(4:end);
                else
                    error(message('MATLAB:duration:InvalidNumericData'));
                end
                convertFromText = false;
            elseif isstring(inData) || matlab.internal.datatypes.isCharStrings(inData)
                % strips whitespace and converts to always be cell.
                inData = strtrim(convertStringsToChars(inData));
                convertFromText = true;
            elseif ~isa(inData,'duration') && ~isa(inData, 'missing')
                error(message('MATLAB:duration:InvalidData'));
            end
            
            if isempty(varargin)
                % Default format.
                outputFmt = duration.DefaultDisplayFormat;
                supplied = this.noConstructorParamsSupplied;
            else
                % Accept explicit parameter name/value pairs.
                pnames = {'Format'                      ,'InputFormat'};
                dflts =  { duration.DefaultDisplayFormat,inputFormat};
                
                [outputFmt,inputFormat,supplied] = parseArgs(pnames, dflts, varargin{:});
                
                if supplied.Format, verifyFormat(outputFmt); end
                if supplied.InputFormat 
                    if ~convertFromText
                        warning(message('MATLAB:duration:IgnoredInputFormat'));
                    else
                        inputFormat = convertStringsToChars(inputFormat);
                    	verifyInputFormat(inputFormat); 
                    end
                end
               
            end
                                  
            try
                if iscell(inData) && ~convertFromText % numeric input, now cells
                    % Construct from separate h,m,s arrays.
                    thisMillis = duration.createFromFields(inData);
                elseif isa(inData,'duration')
                    % Modify a duration array.
                    thisMillis = inData.millis;
                    if ~supplied.Format, outputFmt = inData.fmt; end
                elseif isa(inData, 'missing')
                    % Create a NaN from a missing.
                    thisMillis = double(inData);
                elseif convertFromText
                    thisMillis = createFromText(inData,inputFormat,outputFmt,supplied);
                end
            catch ME
                throw(ME)
            end
            
            this.millis = thisMillis;
            this.fmt = outputFmt;
        end
        
        %% Conversions to numeric types
        function s = milliseconds(d)
            %MILLISECONDS Convert durations to equivalent numeric values in units of milliseconds.
            %   MS = MILLISECONDS(T) converts the durations in the array T to the equivalent
            %   number of milliseconds. D is a double array.
            %
            %   See also SECONDS, MINUTES, HOURS, DAYS, YEARS, DURATION.
            s = d.millis;
        end
        
        function s = seconds(d)
            %SECONDS Convert durations to equivalent numeric values in units of seconds.
            %   S = SECONDS(T) converts the durations in the array T to the equivalent
            %   number of seconds. D is a double array.
            %
            %   See also MINUTES, HOURS, DAYS, YEARS, DURATION.
            s = d.millis / 1000; % ms -> s
        end
        
        function m = minutes(d)
            %MINUTES Convert durations to equivalent numeric values in units of minutes.
            %   M = MINUTES(T) converts the durations in the array T to the equivalent
            %   number of minutes. D is a double array.
            %
            %   See also SECONDS, HOURS, DAYS, YEARS, DURATION.
            m = d.millis / (60*1000); % ms -> m
        end
        
        function h = hours(d)
            %HOURS Convert durations to equivalent numeric values in units of hours.
            %   H = HOURS(T) converts the durations in the array T to the equivalent
            %   number of hours. H is a double array.
            %
            %   See also SECONDS, MINUTES, DAYS, YEARS, DURATION.
            h = d.millis / (3600*1000); % ms -> h
        end
        
        function d = days(d)
            %DAYS Convert durations to equivalent numeric values in units of standard-length days.
            %   D = DAYS(T) converts the durations in the array T to the equivalent
            %   number of exact fixed-length (24 hour) days. D is a double array.
            %
            %   See also SECONDS, MINUTES, HOURS, YEARS, DURATION.
            d = d.millis / (86400*1000); % ms -> days
        end
        
        function y = years(d)
            %YEARS Convert durations to equivalent numeric values in units of standard-length years.
            %   S = YEARS(D) converts the durations in the array D to the equivalent
            %   number of exact fixed-length (365.2425 day) years. D is a double array.
            %
            %   See also SECONDS, MINUTES, HOURS, DAYS, DURATION.
            y = d.millis / (86400*365.2425*1000); % ms -> years
        end
        
        %% Conversions to string types
        function s = char(this,format,locale)
            %CHAR Convert durations to character matrix.
            %   C = CHAR(T) returns a character matrix representing the durations in T.
            %
            %   C = CHAR(T,FMT) uses the specified duration format. FMT is a character vector
            %   containing the characters y,d,h,m,s to represent time units of the
            %   durations. For the complete specification, type "help duration.Format".
            %
            %   C = CHAR(T,FMT,LOCALE) specifies the locale (in particular, the language)
            %   used to create the character vectors. LOCALE must be a character vector in the form
            %   xx_YY, where xx is a lowercase ISO 639-1 two-letter language code and YY is
            %   an uppercase ISO 3166-1 alpha-2 country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = hours(23:25) + minutes(8) + seconds(1.2345)
            %      c = char(dt)
            %
            %   See also CELLSTR, STRING, DURATION.
            import matlab.internal.duration.formatAsString
            
            isLong = strncmp(matlab.internal.display.format,'long',4);
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            end
            if nargin < 3 || isequal(locale,[])
                s = strjust(char(formatAsString(this.millis,format,isLong,false)),'right');
            else
                s = strjust(char(formatAsString(this.millis,format,isLong,false,matlab.internal.datetime.verifyLocale(locale))),'right');
            end
        end
        
        function c = cellstr(this,format,locale)
            %CELLSTR Convert durations to character vectors.
            %   C = CELLSTR(T) returns a cell array of character vectors representing
            %   the durations in T.
            %
            %   C = CELLSTR(T,FMT) uses the specified duration format. FMT is a
            %   character vector containing the characters y,d,h,m,s to represent time
            %   units of the durations. For the complete specification, type "help
            %   duration.Format".
            %
            %   C = CELLSTR(T,FMT,LOCALE) specifies the locale (in particular, the
            %   language) used to create the character vectors. LOCALE must be a
            %   character vector in the form xx_YY, where xx is a lowercase ISO 639-1
            %   two-letter language code and YY is an uppercase ISO 3166-1 alpha-2
            %   country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = hours(23:25) + minutes(8) + seconds(1.2345)
            %      c = cellstr(dt)
            %
            %   See also CHAR, STRING, DURATION.
            import matlab.internal.duration.formatAsString
            
            isLong = strncmp(matlab.internal.display.format,'long',4);
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            end
            if nargin < 3 || isequal(locale,[])
                c = formatAsString(this.millis,format,isLong,false);
            else
                c = formatAsString(this.millis,format,isLong,false,matlab.internal.datetime.verifyLocale(locale));
            end
        end
        
        function s = string(this,format,locale)
            %STRING Convert durations to strings.
            %   (T) returns a string array representing the durations in T.
            %
            %   S = STRING(T,FMT) uses the specified duration format. FMT is a char string
            %   containing the characters y,d,h,m,s to represent time units of the durations,
            %   for example 'hh:mm'. For the complete specification, type "help duration.Format".
            %
            %   S = STRING(T,FMT,LOCALE) specifies the locale (in particular, the language)
            %   used to create the strings. LOCALE must be a char string in the form xx_YY,
            %   where xx is a lowercase ISO 639-1 two-letter language code and YY is an
            %   uppercase ISO 3166-1 alpha-2 country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = hours(23:25) + minutes(8) + seconds(1.2345)
            %      c = cellstr(dt)
            %
            %   See also CHAR, CELLSTR, DURATION.
            import matlab.internal.duration.formatAsString
            
            isLong = strncmp(matlab.internal.display.format,'long',4);
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            end
            if nargin < 3 || isequal(locale,[])
                s = formatAsString(this.millis,format,isLong,true);
            else
                s = formatAsString(this.millis,format,isLong,true,matlab.internal.datetime.verifyLocale(locale));
            end
            
            % Convert 'NaN' to missing string. String method is a
            % conversion, not a text representation, and thus NaT should be
            % converted to its equivalent in string, which is the missing
            % string.
            s(isnan(this)) = string(missing);
        end
        
        %% Conversions to the legacy types
        function n = datenum(this)
            %DATEVEC Convert durations to date vectors.
            %   DN = DATENUM(T) converts the durations in the array T to the equivalent
            %   number of standard-length (86400 seconds) days. D is a double array.
            %
            %   Examples:
            %      dt = hours(23:25) + minutes(8) + seconds(1.2345)
            %      dn = datenum(dt)
            %
            %   See also HMS, HOURS, MINUTES, SECONDS, DATENUM, DURATION.
            n = this.millis / (86400*1000); % ms -> days
        end
        
        function [y,mo,d,h,m,s] = datevec(this,varargin)
            %DATEVEC Convert durations to date vectors.
            %   DV = DATEVEC(T) splits the duration array T into separate column vectors for
            %   years, months, days, hours, minutes, and seconds, and returns one numeric
            %   matrix.
            %
            %   [Y,MO,D,H,MI,S] = DATEVEC(T) returns the components of T as individual
            %   variables.
            %
            %   Examples:
            %      dt = hours(23:25) + minutes(8) + seconds(1.2345)
            %      dv = datevec(dt)
            %
            %   See also HMS, HOURS, MINUTES, SECONDS, DATEVEC, DURATION.
            s = this.millis / 1000; % ms -> s
            y = fix(s / (86400*365.2425)); % possibly negative, possibly nonfinite
            mo = zeros(size(s));
            mo(~isfinite(s)) = NaN;
            s = s - (86400*365.2425)*y; % NaN if s was infinite
            d = fix(s / 86400);
            s = s - 86400*d;
            h = fix(s / 3600);
            s = s - 3600*h;
            m = fix(s / 60);
            s = s - 60*m;
            
            % Return the same non-finite in all fields.
            nonfiniteElems = ~isfinite(y);
            nonfiniteVals = y(nonfiniteElems);
            if ~isempty(nonfiniteVals)
                mo(nonfiniteElems) = nonfiniteVals;
                d(nonfiniteElems) = nonfiniteVals;
                h(nonfiniteElems) = nonfiniteVals;
                m(nonfiniteElems) = nonfiniteVals;
                s(nonfiniteElems) = nonfiniteVals;
            end
            
            if nargout <= 1
                y = [y(:),mo(:),d(:),h(:),m(:),s(:)];
            end
        end
        
        %% Array methods
        function [varargout] = size(this,varargin)
            [varargout{1:nargout}] = size(this.millis,varargin{:});
        end
        function l = length(this)
            l = length(this.millis);
        end
        function n = ndims(this)
            n = ndims(this.millis);
        end
        
        function n = numel(this,varargin)
            if nargin == 1
                n = numel(this.millis);
            else
                n = numel(this.millis,varargin{:});
            end
        end
        
        function t = isempty(a),  t = isempty(a.millis);  end
        function t = isscalar(a), t = isscalar(a.millis); end
        function t = isvector(a), t = isvector(a.millis); end
        function t = isrow(a),    t = isrow(a.millis);    end
        function t = iscolumn(a), t = iscolumn(a.millis); end
        function t = ismatrix(a), t = ismatrix(a.millis); end
        
        function result = cat(dim,varargin)
            import matlab.internal.datatypes.isCharStrings;
            for i = 1:numel(varargin)
                arg = varargin{i};
                if (isstring(arg) && ~isscalar(arg)) || ischar(arg) && ~isCharStrings(arg)
                    error(message('MATLAB:duration:cat:InvalidConcatenation'));
                end
            end
            try
                [argsMillis,result] = duration.isequalUtil(varargin);
            catch ME
                if strcmp(ME.identifier,'MATLAB:duration:InvalidComparison')
                    error(message('MATLAB:duration:cat:InvalidConcatenation'));
                else
                    throw(ME);
                end
            end
            result.millis = cat(dim,argsMillis{:}); % use fmt from the first array
        end
        function result = horzcat(varargin)
            try
                result = cat(2,varargin{:});
            catch ME
                throw(ME);
            end
        end
        function result = vertcat(varargin)
            try
                result = cat(1,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function that = ctranspose(this)
            try
                that = this; that.millis = ctranspose(this.millis);
            catch ME
                throwAsCaller(ME);
            end
        end
        function that = transpose(this)
            try
                that = this; that.millis = transpose(this.millis);
            catch ME
                throwAsCaller(ME);
            end
        end
        function that = reshape(this,varargin)
            that = this; that.millis = reshape(this.millis,varargin{:});
        end
        function that = permute(this,order)
            that = this; that.millis = permute(this.millis,order);
        end
        
        %% Relational operators
        function t = eq(a,b)
            %EQ Equality comparison for durations.
            %   A == B returns a logical matrix the same size as the duration arrays A
            %   and B with logical 1 (true) where the elements are equal, logical 0
            %   (false) otherwise.  A and B must be the same size, or either can be a
            %   scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = EQ(A,B) is called for the syntax 'A == B'.
            %
            %   See also NE, LT, LE, GE, GT.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis == bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = ne(a,b)
            %NE Not-equality comparison for durations.
            %   A ~= B returns a logical matrix the same size as the duration arrays A and B
            %   with logical 1 (true) where the elements are not equal, and logical 0
            %   (false) otherwise.  A and B must be the same size, or either can be a
            %   scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = NE(A,B) is called for the syntax 'A ~= B'.
            %
            %   See also EQ, LT, LE, GE, GT.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis ~= bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = lt(a,b)
            %LT Less than comparison for durations.
            %   A < B returns a logical matrix the same size as the duration arrays A and B
            %   with logical 1 (true) where A(I) < B(I), and logical 0 (false) otherwise.
            %   A and B must be the same size, or either can be a scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = LT(A,B) is called for the syntax 'A < B'.
            %
            %   See also EQ, NE, LE, GE, GT.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis < bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = le(a,b)
            %LE Less than or equal comparison for durations.
            %   A <= B returns a logical matrix the same size as the duration arrays A and B
            %   with logical 1 (true) where A(I) <= B(I), and logical 0 (false) otherwise.
            %   A and B must be the same size, or either can be a scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = LE(A,B) is called for the syntax 'A <= B'.
            %
            %   See also EQ, NE, LT, GE, GT.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis <= bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = ge(a,b)
            %GE Greater than or equal comparison for durations.
            %   A >= B returns a logical matrix the same size as the duration arrays A and B
            %   with logical 1 (true) where A(I) >= B(I), and logical 0 (false) otherwise.
            %   A and B must be the same size, or either can be a scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = GE(A,B) is called for the syntax 'A >= B'.
            %
            %   See also EQ, NE, LT, LE, GT.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis >= bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = gt(a,b)
            %GT Greater than comparison for durations.
            %   A > B returns a logical matrix the same size as the duration arrays A and B
            %   with logical 1 (true) where A(I) > B(I), and logical 0 (false) otherwise.  A
            %   and B must be the same size, or either can be a scalar.
            %
            %   You can also compare a duration array with a numeric array, where a
            %   numeric value is treated as a number of standard (86400s) days, or with
            %   a text array where the text matches the format of the duration, or has
            %   the format 'hh:mm:ss' or 'dd:hh:mm:ss' with possible fractional
            %   seconds.
            %
            %   C = GT(A,B) is called for the syntax 'A > B'.
            %
            %   See also EQ, NE, LT, LE, GE.
            try
                [amillis,bmillis] = duration.compareUtil(a,b);
                t = (amillis > bmillis);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function t = isequal(varargin)
            %ISEQUAL True if duration arrays are equal.
            %   TF = ISEQUAL(A,B) returns logical 1 (true) if the duration arrays A and B
            %   are the same size and contain the same values, and logical 0 (false)
            %   otherwise.
            %
            %   TF = ISEQUAL(A,B,C,...) returns logical 1 (true) if all the input arguments
            %   are equal.
            %
            %   NaN elements are not considered equal to each other.  Use ISEQUALN to treat
            %   NaN elements as equal.
            %
            %   See also ISEQUALN, EQ.
            narginchk(2,Inf);
            try
                argsMillis = duration.isequalUtil(varargin);
            catch ME
                if strcmp(ME.identifier,'MATLAB:duration:InvalidComparison')
                    t = false;
                    return
                else
                    throw(ME);
                end
            end
            t = isequal(argsMillis{:});
        end
        
        function t = isequaln(varargin)
            %ISEQUALN True if duration arrays are equal, treating NaN elements as equal.
            %   TF = ISEQUALN(A,B) returns logical 1 (true) if the duration arrays A and B
            %   are the same size and contain the same values or corresponding NaN elements,
            %   and logical 0 (false) otherwise.
            %
            %   TF = ISEQUALN(A,B,C,...) returns logical 1 (true) if all the input arguments
            %   are equal.
            %
            %   Use ISEQUAL to treat NaN elements as unequal.
            %
            %   See also ISEQUAL, EQ.
            narginchk(2,Inf);
            try
                argsMillis = duration.isequalUtil(varargin);
            catch ME
                if strcmp(ME.identifier,'MATLAB:duration:InvalidComparison')
                    t = false;
                    return
                else
                    throw(ME);
                end
            end
            t = isequaln(argsMillis{:});
        end
        
        %% Math
        function y = eps(x)
            %EPS Spacing of durations.
            %   D = EPS(X) is the positive distance from ABS(X) to the next larger duration
            %   in magnitude from X.
            y = x;
            y.millis = eps(x.millis);
            % Output eps in a simple format (not a digital timer format; e.g. hh:mm:ss)
            if any(y.fmt == ':')
                y.fmt = 's';
            end
        end
        
        function y = cumsum(x,varargin)
            %CUMSUM Cumulative sum of elements.
            %   Y = CUMSUM(X) computes the cumulative sum along the first non-singleton
            %   dimension of the duration array X. Y is the same size as X.
            %
            %   Y = CUMSUM(X,DIM) cumulates along the dimension specified by DIM.
            %
            %   Y = CUMSUM(___,DIRECTION) cumulates in the direction specified by
            %   the character vector DIRECTION using any of the above syntaxes:
            %       'forward' - (default) uses the forward direction, from beginning to end.
            %       'reverse' -           uses the reverse direction, from end to beginning.
            %
            %   Example:
            %
            %      % Find the cumulative sums of a vector of durations.
            %      dur = hours([4 3 2 1 -1 -2 -3 -4])
            %      cumsum(dur)
            %
            %   See also CUMMIN, CUMMAX, SUM.
            y = x;
            y.millis = cumsum(x.millis,varargin{:});
        end
        function y = cummin(x,varargin)
            %CUMMIN Cumulative smallest element.
            %   Y = CUMMIN(X) computes the cumulative smallest value along the first
            %   non-singleton dimension of the duration array X. Y is the same size as X.
            %
            %   Y = CUMMIN(X,DIM) cumulates along the dimension specified by DIM.
            %
            %   Y = CUMMIN(___,DIRECTION) cumulates in the direction specified by
            %   the character vector DIRECTION using any of the above syntaxes:
            %       'forward' - (default) uses the forward direction, from beginning to end.
            %       'reverse' -           uses the reverse direction, from end to beginning.
            %
            %   Example:
            %
            %      % Find the cumulative minima of a vector of durations.
            %      dur = hours([3 5 6 4 2 1 8 7])
            %      cummin(dur)
            %
            %   See also CUMSUM, CUMMAX, MIN.
            y = x;
            y.millis = cummin(x.millis,varargin{:});
        end
        function y = cummax(x,varargin)
            %CUMMAX Cumulative largest element.
            %   Y = CUMMAX(X) computes the cumulative largest value along the first
            %   non-singleton dimension of the duration array X. Y is the same size as X.
            %
            %   Y = CUMMAX(X,DIM) cumulates along the dimension specified by DIM.
            %
            %   Y = CUMMAX(___,DIRECTION) cumulates in the direction specified by
            %   the character vector DIRECTION using any of the above syntaxes:
            %       'forward' - (default) uses the forward direction, from beginning to end.
            %       'reverse' -           uses the reverse direction, from end to beginning.
            %
            %   Example:
            %
            %      % Find the cumulative maxima of a vector of durations.
            %      dur = hours([3 5 6 4 2 1 8 7])
            %      cummax(dur)
            %
            %   See also CUMSUM, CUMMIN, MAX.
            y = x;
            y.millis = cummax(x.millis,varargin{:});
        end
        
        function z = mod(x,y)
            %MOD Modulus after division for durations.
            %   MOD(X,Y) is X - N.*Y where N = FLOOR(X./Y) if Y ~= 0. X and Y are duration
            %   arrays of the same size, or scalars.
            %
            %   Example:
            %
            %      % Create an array of random durations and find the modulus and
            %      % remainder, modulo 1 hour.
            %      dur = minutes(randi([-180 180],6,1))
            %      mod(dur,hours(1))
            %      rem(dur,hours(1))
            %
            %   See also REM.
            [xmillis,ymillis,z] = duration.compareUtil(x,y);
            z.millis = mod(xmillis,ymillis);
        end
        function z = rem(x,y)
            %REM Remainder after division for durations.
            %   REM(X,Y) is X - N.*Y where N = FIX(X./Y) if Y ~= 0. X and Y are duration
            %   arrays of the same size, or scalars.
            %
            %   Example:
            %
            %      % Create an array of random durations and find the remainder and
            %      % modulus, modulo 1 hour.
            %      dur = minutes(randi([-180 180],6,1))
            %      rem(dur,hours(1))
            %      mod(dur,hours(1)))
            %
            %   See also MOD.
            [xmillis,ymillis,z] = duration.compareUtil(x,y);
            z.millis = rem(xmillis,ymillis);
        end
    end % public methods block
    
    methods(Hidden = true)
        %% Display and strings
        function disp(this,name)
            if (nargin < 2)
                name = '';
            end
            
            try
                displayFun(this,name);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        %% Arrayness
        function n = end(this,k,n)
            try
                n = builtin('end',this.millis,k,n);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        %% Subscripting
        this = subsasgn(this,s,rhs)
        that = subsref(this,s)
        
        function sz = numArgumentsFromSubscript(~,~,~)
            % This function is for internal use only and will change in a
            % future release.  Do not use this function.
            sz = 1;
        end
        
        %% Variable Editor methods
        % These functions are for internal use only and will change in a
        % future release.  Do not use this function.
        [out,warnmsg] = variableEditorClearDataCode(this, varname, rowIntervals, colIntervals)
        [out,warnmsg] = variableEditorColumnDeleteCode(this, varName, colIntervals)
        out = variableEditorInsert(this, orientation, row, col, data)
        out = variableEditorPaste(this, rows, columns, data)
        [out,warnmsg] = variableEditorRowDeleteCode(this, varName, rowIntervals)
        [out,warnmsg] = variableEditorSortCode(~, varName, columnIndexStrings, direction)
        
        %% Error stubs
        % Methods to override functions and throw helpful errors
        function d = double(d), error(message('MATLAB:duration:InvalidNumericConversion','double')); end %#ok<MANU>
        function d = single(d), error(message('MATLAB:duration:InvalidNumericConversion','single')); end %#ok<MANU>
        function d = month(d), error(message('MATLAB:duration:MonthsNotSupported','month')); end %#ok<MANU>
        function d = months(d), error(message('MATLAB:duration:MonthsNotSupported','months')); end %#ok<MANU>
    end % hidden public methods block
    
    methods(Hidden = true, Static = true)
        function d = empty(varargin)
            %EMPTY Create an empty duration array.
            %   D = DURATION.EMPTY() creates a 0x0 duration array.
            %
            %   D = DURATION.EMPTY(M,N,...) or D = DURATION.EMPTY([N M ...]) creates
            %   an N-by-M-by-... duration array.  At least one of N,M,... must be zero.
            %
            %   See also DURATION.
            if nargin == 0
                d = duration([],[],[]);
            else
                dMillis = zeros(varargin{:});
                if numel(dMillis) ~= 0
                    error(message('MATLAB:duration:empty:InvalidSize'));
                end
                d = duration([],[],[]);
                d.millis = dMillis;
            end
        end
        
        function d = fromMillis(millis,fmt,addFractional)
            % This function is for internal use only and will change in a
            % future release. Do not use this function.
            d = duration;
            d.millis = millis;
            if nargin > 1
                if nargin > 2 && addFractional
                    fmt = duration.getFractionalSecondsFormat(millis,fmt);
                end
                d.fmt = fmt;
            end

        end

        function fmt = getFractionalSecondsFormat(data,fmt)
            % Find the longest fractional part by checking the modulus of the
            % milliseconds. Note: if mod(data,1000) == 0 so does mod(data,1)
            % etc. First, get the remainder, implicitly expanding in MOD into
            % Nx3 and look only at the non-zero values. Next, sum each row to
            % get the number of digit increments. Finally, find the row with the
            % most increments. Multiplying by three gets the number of digits
            % needed.
            % i.e. see: mod([1000;1001;1000.1;1000.00001],[1e3,1e0,1e-3]) > 0
            fractional = 3 * max(sum(mod(data(:),[1e3,1e0,1e-3]) > 0,2));
            if fractional  > 0
                fmt = [fmt '.' repmat('S',1,fractional)];
            end
        end
    end % static hidden public methods block
    
    methods(Access='protected')
        displayFun(this,objectname)
        this = subsasgnDot(this,s,rhs)
        this = subsasgnParens(this,s,rhs)
        value = subsrefDot(this,s)
        value = subsrefParens(this,s)
    end
    
    methods(Static, Access='protected')
        [amillis,bmillis,template] = compareUtil(a,b)
        [argsMillis,template] = isequalUtil(args)
        millis = createFromFields(fields)
    end % protected static methods block
end
               
function millis = createFromText(data,inputFormat,displayFormat,supplied)
import matlab.internal.datatypes.throwInstead;
% Convert the data from text
if ischar(data), data = {data};end
if isempty(data)
    millis = zeros(size(data));
    return; 
end

if ~supplied.InputFormat
    [formats, numColons] = getDetectionFormats(data);
    if supplied.Format && contains(displayFormat,':')
        formats = unique([replace(displayFormat,{'.','S'},''); formats(:)],'stable');
    end
    try
        millis = tryTextFormats(data,formats);
    catch ME 
        if numColons == 1
            error(message('MATLAB:duration:DetectedTwoPart','hh:mm','mm:ss'));
        end
        throwInstead(ME,{'MATLAB:duration:AutoConvertString'},'MATLAB:duration:UndetectableFormat',getFirstNonLiteralNaN(data),'hh:mm:ss', 'dd:hh:mm:ss');
    end
else % inputFormat passed in.
    [inputFormatEff, allowFractionalSeconds] = getBaseFormat(inputFormat);
    try
        millis = tryTextFormats(data,{inputFormatEff},allowFractionalSeconds);
    catch ME
        throwInstead(ME,{'MATLAB:duration:AutoConvertString'},'MATLAB:duration:DataMismatchedFormat',getFirstNonLiteralNaN(data),inputFormat)
    end
end
end

function d = getFirstNonLiteralNaN(data)
literalNaNs = strcmpi(data,'nan')...
    | strcmpi(data,'+nan')...
    | strcmpi(data,'-nan')...
    | (strlength(data) == 0)...
    | ismissing(data);
d =  data{find(~literalNaNs,1)};
d = ['''' d ''''];
end
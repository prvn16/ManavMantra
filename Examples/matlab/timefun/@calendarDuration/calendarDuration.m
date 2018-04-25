classdef (Sealed, InferiorClasses = {?duration}) calendarDuration < matlab.mixin.internal.MatrixDisplay
%CALENDARDURATION Arrays to represent lengths of time in flexible-length calendar date/time units.
%   calendarDuration arrays store values to represent lengths of time measured
%   in flexible-length calendar date/time units. A calendar duration consists of
%   a number of months, a number of days, and a duration (hours, minutes, and
%   seconds), but you can also work with them in units of years, quarters, and
%   weeks. Calendar duration arrays help simplify calculations on datetime
%   arrays involving calendar units such as days and months.
%
%   Use the CALDAYS, CALWEEKS, CALMONTHS, CALQUARTERS, or CALYEARS functions to
%   create calendar durations in terms of a single unit. Use the CALENDARDURATION
%   constructor to create an array of calendar durations from numeric arrays as
%   a combination of individual units.
%
%   You can subscript and manipulate calendar duration arrays just like
%   ordinary numeric arrays.
%
%   Each element of a calendar duration array represents a length of time
%   in flexible-length calendar units. Use a DURATION array to represent
%   lengths of time in terms of fixed-length time units. Use a DATETIME
%   array to represent points in time.
%
%   CALENDARDURATION properties:
%       Format - A character vector describing the format in which the array's values
%                display.
%                       
%   CALENDARDURATION methods and functions:
%     Creating arrays of calendar durations:
%       calendarDuration   - Create an array of calendar durations
%       iscalendarduration - True for an array of calendar durations.
%       caldays            - Create calendar durations from numeric values in units of calendar days.
%       calweeks           - Create calendar durations from numeric values in units of calendar weeks.
%       calmonths          - Create calendar durations from numeric values in units of calendar months.
%       calquarters        - Create calendar durations from numeric values in units of calendar quarters.
%       calyears           - Create calendar durations from numeric values in units of calendar years.
%     Conversion to numeric values:
%       caldays            - Convert calendar durations to equivalent numbers of whole calendar days.
%       calweeks           - Convert calendar durations to equivalent numbers of whole calendar weeks.
%       calmonths          - Convert calendar durations to equivalent numbers of whole calendar months.
%       calquarters        - Convert calendar durations to equivalent numbers of whole calendar quarters.
%       calyears           - Convert calendar durations to equivalent numbers of whole calendar years.
%       split              - Split calendar durations into equivalent numeric date/time units.
%       time               - Extract the time portion of calendar durations.
%     Calendar calculations with calendar durations:
%       uminus             - Negation for calendar durations.
%       plus               - Addition for calendar durations.
%       minus              - Subtraction for calendar durations.
%       times              - Multiplication for calendar durations.
%       mtimes             - Matrix multiplication for calendar durations.
%       isnan              - True for calendar durations that are Not-a-Number.
%       isinf              - True for calendar durations that are +Inf or -Inf.
%       isfinite           - True for calendar durations that are finite.
%     Conversion to other numeric representations:
%       datevec            - Convert calendar durations to date vectors.
%     Conversion to strings:
%       char               - Convert calendar durations to character matrix.
%       cellstr            - Convert calendar durations to cell array of character vectors.
%       string             - Convert calendar durations to strings.
%   Examples:
%
%      % Create an array of calendar durations by specifying the number of months.
%      % Then add a random number of calendar days.
%      d = calmonths(10:14)
%      d = d + caldays(randi([0 15],1,5))
%
%      % Set the format to display as months, calendar days, and time.
%      d.Format = 'mdt'
%
%      % Add calendar durations to a datetime.
%      t0 = datetime('today')
%      d = calmonths(10:14) + caldays(randi([0 15],1,5))
%      t1 = t0 + d
%
%      % Find the calendar difference between two sets of datetimes. Then convert
%      % those to a numeric value, in units of months and calendar days. Years
%      % are included in the values for months.
%      t0 = datetime('today')
%      t1 = t0 + calyears(1:5) + calmonths(6:10) + caldays(11:15)
%      d = between(t0,t1)
%      [m,d] = split(d,'md')
%
%   See also CALYEARS, CALQUARTERS, CALMONTHS, CALWEEKS, CALDAYS, DURATION, DATETIME.

%   Copyright 2014-2017 The MathWorks, Inc.

    properties(GetAccess='public', Dependent=true)
        %FORMAT Display format property for calendarDuration arrays.
        %   The Format property of a calendarDuration array determines the format
        %   in which the array displays its values. This property is a character
        %   vector constructed using the characters y,q,m,w,d,t (in that order) to
        %   represent the date and time components of the calendar durations.
        %
        %   The format must contain the characters 'm', to display the number of
        %   months, 'd', to display the number of days, and 't', to display the number
        %   of hours, minutes, and seconds. The format character vector may also contain the
        %   characters 'y' and/or 'q' to display the number of years and/or quarters. In
        %   this case, multiples of 12 months display as years (if 'y' is present), and
        %   multiples of 3 months display as quarters (if 'q' is present). The format
        %   character vector may also contain the character 'w' to display the number of weeks. In
        %   this case, multiples of 7 days display as weeks.
        %
        %   CALENDARDURATION displays only whole numbers for years, quarters, months,
        %   weeks, days, hours, and minutes. Control the number of fractional digits
        %   displayed for seconds using the FORMAT command. Components whose value is
        %   zero are not displayed even if the corresponding character appears in the
        %   format.
        %
        %   Changing the display format does not change the calendar duration values
        %   in the array, only their display.
        %
        %   The default value when you create an array using calendarDuration is 'ymdt'.
        %
        %   See also CALENDARDURATION.
        Format
    end
    properties(GetAccess='public', Hidden, Constant)
        % This property is for internal use only and will change in a
        % future release.  Do not use this property.
        DefaultDisplayFormat = 'ymdt';
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        % number of months, days, milliseconds, stored as separate arrays
        components = struct('months',[],'days',[],'millis',[]);
        
        % Format in which to display
        fmt = 'ymdt';
    end
    
    % Forward compatibility layer
    properties(GetAccess='private', SetAccess='private', Dependent=true)
        data
    end
    methods
        function d = set.data(d,data)
            d.components = struct('months',data.months, ...
                                  'days',data.days, ...
                                  'millis',data.seconds*1000);
        end
    end
    
    methods(Access = 'public')
        function this = calendarDuration(inData,varargin)
            %CALENDARDURATION Create an array of calendar durations.
            %   D = CALENDARDURATION(Y,MO,D) creates an array of calendar durations from
            %   numeric arrays containing the number of years, months, and days. Y, MO, and
            %   D must be the same size, or any of them can be a scalar.
            %
            %   D = CALENDARDURATION(Y,MO,D,H,MI,S) creates an array of calendar durations
            %   from numeric arrays containing the number of years, months, days, hours,
            %   minutes, and seconds. Y, MO, D, H, MI, and S must be the same size, or any
            %   of them can be a scalar.
            %
            %   D = CALENDARDURATION(Y,MO,D,T) creates an array of calendar durations from
            %   numeric arrays Y, MO, D containing the number of years, months, days, and a
            %   duration array T containing elapsed times. Y, MO, D, and T must be the same
            %   size, or any of them can be a scalar.
            %
            %   D = CALENDARDURATION([Y,MO,D]), and CALENDARDURATION([Y,MO,D,H,MI,S])
            %   create arrays of calendar durations from one numeric matrix with three
            %   or six columns.
            %
            %   D = CALENDARDURATION(..., 'FORMAT',FMT) specifies the format in which D
            %   displays. FMT is a character vector containing the characters y,q,m,w,d,t to
            %   represent date and time units of the calendar durations. For the complete
            %   specification, type "help calendarDuration.Format".
            %
            %   Examples:
            %
            %      % Two ways to create arrays of random calendar durations between 0 and
            %      % 10 calendar days long.
            %      d1 = calendarDuration(0,0,randi([0 10],1,5))
            %      d2 = caldays(randi([0 10],1,5))
            %
            %      % Two ways to create equivalent arrays of calendar durations from a
            %      % specified number of months and calendar days.
            %      d1 = calendarDuration(0,1:3,4:6)
            %      d2 = calmonths(1:3) + caldays(4:6)
            %
            %   See also CALDAYS, CALWEEKS, CALMONTHS, CALQUARTERS, CALYEARS,
            %            CALENDARDURATION.
            
            import matlab.internal.datatypes.parseArgs
            
            if nargin == 0 % same as calendarDuration(0,0,0)
                theComponents = struct('months',0,'days',0,'millis',0);
                inFmt = calendarDuration.DefaultDisplayFormat;
            else
                if isnumeric(inData)
                    % Find how many numeric inputs args: count up until the first non-numeric.
                    numNumericArgs = 1 + sum(cumprod(cellfun(@isnumeric,varargin)));
                    if numNumericArgs == 1 % calendarDuration([y,mo,d,h,mi,s],...), or calendarDuration([y,mo,d],...)
                        m = size(inData,2);
                        if ~ismatrix(inData) || ~((m == 6) || (m == 3))
                            error(message('MATLAB:calendarDuration:InvalidNumericMatrix'));
                        end
                        % Split numeric matrix into separate vectors.
                        inData = num2cell(double(inData),1);
                    elseif numNumericArgs == 3 % calendarDuration(y,mo,d,t,...) or calendarDuration(y,mo,d,...)
                        if (nargin >= 4) && isa(varargin{3},'duration')
                            inData = {inData varargin{1:2} milliseconds(varargin{3})};
                            varargin = varargin(4:end);
                        else
                            inData = {inData varargin{1:2}};
                            varargin = varargin(3:end);
                        end
                    elseif numNumericArgs == 4 % calendarDuration(y,mo,d,ms,...)
                        inData = {inData varargin{1:3}};
                        varargin = varargin(4:end);
                    elseif numNumericArgs == 6 % calendarDuration(y,mo,d,h,mi,s,...)
                        inData = {inData varargin{1:5}};
                        varargin = varargin(6:end);
                    else
                        error(message('MATLAB:calendarDuration:InvalidNumericData'));
                    end
                elseif isa(inData,'duration')
                    error(message('MATLAB:calendarDuration:InvalidDurationData'));
                elseif ~isa(inData,'calendarDuration') && ~isa(inData, 'missing')
                    error(message('MATLAB:calendarDuration:InvalidData'));
                end
                
                if isempty(varargin)
                    % Default format.
                    inFmt = calendarDuration.DefaultDisplayFormat;
                    supplied = struct('Format',false);
                else
                    % Accept explicit parameter name/value pairs.
                    pnames = {'Format'                              };
                    dflts =  { calendarDuration.DefaultDisplayFormat};
                    [inFmt,supplied] = parseArgs(pnames, dflts, varargin{:});
                    if supplied.Format, inFmt = verifyFormat(inFmt); end
                end
                
                if isa(inData,'calendarDuration') % construct from an array of calendarDurations
                    if ~supplied.Format, inFmt = inData.fmt; end
                    theComponents = inData.components;
                elseif isa(inData, 'missing')
                    theComponents = struct('months',0,'days',0,'millis',double(inData));
                else
                    % Construct from numeric data.
                    theComponents = calendarDuration.createFromFields(inData);
                end
            end
            
            this.components = theComponents;
            this.fmt = inFmt;
        end
        
        %% Extract date/time fields
        function y = calyears(this)
            %CALYEARS Convert calendar durations to equivalent numbers of whole calendar years.
            %   Y = CALYEARS(T) returns the equivalent number of whole calendar years for
            %   each calendar duration in T. Y is equal to FIX(MONTHS(T)/12).
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      y = calyears(dt)
            %
            %   See also CALQUARTERS, CALMONTHS, CALWEEKS, CALDAYS, TIME.
            comps = this.components;
            y = calendarDuration.expandFieldForOutput(comps,floor(comps.months/12));
        end
        
        function q = calquarters(this)
            %CALQUARTERS Convert calendar durations to equivalent numbers of whole calendar quarters.
            %   Q = CALQUARTERS(T) returns the equivalent number of whole calendar quarters
            %   for each calendar duration in T. Q is equal to FIX(CALMONTHS(T)/3).
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      q = calquarters(dt)
            %
            %   See also CALYEARS, CALMONTHS, CALWEEKS, CALDAYS, TIME.
            comps = this.components;
            q = calendarDuration.expandFieldForOutput(comps,floor(comps.months/3));
        end
        
        function mo = calmonths(this)
            %CALMONTHS Convert calendar durations to equivalent numbers of whole calendar months.
            %   M = CALMONTHS(T) returns the equivalent number of whole calendar months for
            %   each calendar duration in T.
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      q = calmonths(dt)
            %
            %   See also CALYEARS, CALQUARTERS, CALWEEKS, CALDAYS, TIME.
            comps = this.components;
            mo = calendarDuration.expandFieldForOutput(comps,comps.months);
        end
        
        function w = calweeks(this)
            %CALWEEKS Convert calendar durations to equivalent numbers of whole calendar weeks.
            %   W = CALWEEKS(T) returns the equivalent number of whole calendar weeks for
            %   each calendar duration in T. W is equal to FIX(CALDAYS(T)/7).
            %
            %   Examples:
            %      dt = caldays(15:17) + hours(1.2345)
            %      w = calweeks(dt)
            %
            %   See also CALYEARS, CALQUARTERS, CALMONTHS, CALDAYS, TIME.
            comps = this.components;
            if ~all((comps.months(:) == 0))
                error(message('MATLAB:calendarDuration:NonZeroMonths'));
            end
            w = calendarDuration.expandFieldForOutput(comps,floor(comps.days/7));
        end
        
        function d = caldays(this)
            %CALDAYS Convert calendar durations to equivalent numbers of whole calendar days.
            %   D = CALDAYS(T) returns the equivalent number of whole calendar days for each
            %   calendar duration in T.
            %
            %   Examples:
            %      dt = caldays(15:17) + hours(1.2345)
            %      q = caldays(dt)
            %
            %   See also CALYEARS, CALQUARTERS, CALMONTHS, CALWEEKS, TIME.
            comps = this.components;
            if ~all((comps.months(:) == 0))
                error(message('MATLAB:calendarDuration:NonZeroMonths'));
            end
            d = calendarDuration.expandFieldForOutput(comps,comps.days);
        end
        
        function t = time(this)
            %TIME Extract the time portion of calendar durations.
            %   T = TIME(D) returns the time portions of the calendar duration in D as
            %   durations.
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      t = time(dt)
            %
            %   See also CALYEARS, CALQUARTERS, CALMONTHS, CALWEEKS, CALDAYS, DURATION.
            comps = this.components;
            t = duration.fromMillis(calendarDuration.expandFieldForOutput(comps,comps.millis));
        end
        
        %% Conversions to string types
        function s = char(this,format,locale)
            %CHAR Convert calendar durations to character array.
            %   C = CHAR(T) returns a character matrix representing the calendar durations in T.
            %
            %   C = CHAR(T,FMT) uses the specified calendar duration format. FMT is a character vector
            %   containing the characters y,q,m,w,d,t to represent time units of the calendar
            %   durations. For the complete specification, type "help calendarDuration.Format".
            %
            %   C = CHAR(T,FMT,LOCALE) specifies the locale (in particular, the
            %   language) used to create C. LOCALE must be a
            %   character vector in the form xx_YY, where xx is a lowercase ISO 639-1
            %   two-letter language code and YY is an uppercase ISO 3166-1 alpha-2
            %   country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      c = char(dt)
            %
            %   See also CELLSTR, STRING, CALENDARDURATION.
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            else
                format = verifyFormat(format);
            end
            
            if nargin < 3 || isequal(locale,[])
                s = calendarDuration.formatAsString(this.components,format,true);
            else
                s = calendarDuration.formatAsString(this.components,format,true,locale);
            end
                s = strjust(char(s(:)),'right');
        end
        
        function c = cellstr(this,format,locale)
            %CELLSTR Convert calendar durations to cell array of character vectors.
            %   C = CELLSTR(T) returns a cell array of character vectors representing
            %   the calendar durations in T.
            %
            %   C = CELLSTR(T,FMT) uses the specified calendar duration format. FMT is
            %   a character vector containing the characters y,q,m,w,d,t to represent
            %   time units of the calendar durations. For the complete specification,
            %   type "help calendarDuration.Format".
            %
            %   C = CELLSTR(T,FMT,LOCALE) specifies the locale (in particular, the
            %   language) used to create the character vectors. LOCALE must be a
            %   character vector in the form xx_YY, where xx is a lowercase ISO 639-1
            %   two-letter language code and YY is an uppercase ISO 3166-1 alpha-2
            %   country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      c = cellstr(dt)
            %
            %   See also CHAR, STRING, CALENDARDURATION.
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            else
                format = verifyFormat(format);
            end

            if nargin < 3 || isequal(locale,[])
                c = cellstr(calendarDuration.formatAsString(this.components,format,true));
            else
                c = cellstr(calendarDuration.formatAsString(this.components,format,true,locale));
            end
        end
        
        function s = string(this,format,locale)
            %STRING Convert calendar durations to strings.
            %   S = STRING(T) returns a string array representing the calendar durations in T.
            %
            %   S = STRING(T,FMT) uses the specified calendar duration format. FMT is a char
            %   string containing the characters y,q,m,w,d,t to represent time units of the
            %   calendar durations, for example 'ymd'. For the complete specification, type
            %   "help calendarDuration.Format".
            %
            %   S = STRING(T,FMT,LOCALE) specifies the locale (in particular, the language)
            %   used to create the strings. LOCALE must be a char string in the form xx_YY,
            %   where xx is a lowercase ISO 639-1 two-letter language code and YY is an
            %   uppercase ISO 3166-1 alpha-2 country code, for example 'ja_JP'.
            %
            %   Examples:
            %      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
            %      c = cellstr(dt)
            %
            %   See also CHAR, CELLSTR, CALENDARDURATION.
            if nargin < 2 || isequal(format,[])
                format = this.fmt;
            else
                format = verifyFormat(format);
            end

            if nargin < 3 || isequal(locale,[])
                s = calendarDuration.formatAsString(this.components,format,false);
            else
                s = calendarDuration.formatAsString(this.components,format,false,locale);
            end
        end
        
        %% Conversions to the legacy types
        function [y,mo,d,h,m,s] = datevec(this,varargin)
            %DATEVEC Convert calendar durations to date vectors.
            %   DV = DATEVEC(T) splits the calendar duration array T into separate
            %   column vectors for years, months, days, hours, minutes, and seconds,
            %   and returns one numeric matrix.
            %
            %   [Y,MO,D,H,MI,S] = DATEVEC(T) returns the components of T as individual
            %   variables.
            %
            %   Examples:
            %      dt = calmonths(16) + caldays(8) + hours(1.2345)
            %      dv = datevec(dt)
            %
            %   See also CALYEARS, CALQUARTERS, CALMONTHS, CALWEEKS, CALDAYS, TIME, CALENDARDURATION.
            theComponents = this.components;
            outSz = calendarDuration.getFieldSize(theComponents);
            
            mo = theComponents.months;
            d = theComponents.days;
            s = theComponents.millis / 1000; % ms -> s
            
            % Find nonfinite elements
            check = mo + d + s;
            nonfiniteElems = ~isfinite(check);
            nonfiniteVals = check(nonfiniteElems);
            
            if isscalar(mo), mo = repmat(mo,outSz); end
            y = fix(mo / 12);
            mo = rem(mo,12);
            if isscalar(d), d = repmat(d,outSz); end
            if isscalar(s), s = repmat(s,outSz); end
            h = fix(s / 3600);
            s = rem(s,3600);
            m = fix(s / 60);
            s = rem(s,60);
            
            % Return the same non-finite in all fields.
            if ~isempty(nonfiniteVals)
                y(nonfiniteElems) = nonfiniteVals;
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
        function [varargout] = size(this,dim)
            [~,field] = calendarDuration.getFieldSize(this.components);
            if nargin < 2
                [varargout{1:nargout}] = size(field);
            else
                [varargout{1:nargout}] = size(field,dim);
            end
        end
        function l = length(this)
            [~,field] = calendarDuration.getFieldSize(this.components);
            l = length(field);
        end
        function n = ndims(this)
            [~,field] = calendarDuration.getFieldSize(this.components);
            n = ndims(field);
        end
        
        function n = numel(this,varargin)
             [~,field] = calendarDuration.getFieldSize(this.components);
             if nargin == 1
                 n = numel(field);
             else
                 n = numel(field,varargin{:});
             end
        end
        
        function t = isempty(a),  [~,f] = calendarDuration.getFieldSize(a.components); t = isempty(f);  end
        function t = isscalar(a), [~,f] = calendarDuration.getFieldSize(a.components); t = isscalar(f); end
        function t = isvector(a), [~,f] = calendarDuration.getFieldSize(a.components); t = isvector(f); end
        function t = isrow(a),    [~,f] = calendarDuration.getFieldSize(a.components); t = isrow(f);    end
        function t = iscolumn(a), [~,f] = calendarDuration.getFieldSize(a.components); t = iscolumn(f); end
        function t = ismatrix(a), [~,f] = calendarDuration.getFieldSize(a.components); t = ismatrix(f); end
        
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

        function this = ctranspose(this)
            try
                this.components = applyArraynessFun(this.components,@transpose); % NOT ctranspose
            catch ME
                throwAsCaller(ME);
            end
        end
        function this = transpose(this)
            try
                this.components = applyArraynessFun(this.components,@transpose);
            catch ME
                throwAsCaller(ME);
            end
        end
        function this = reshape(this,varargin)
            this.components = applyArraynessFun(this.components,@reshape,varargin{:});
        end
        function this = permute(this,order)
            this.components = applyArraynessFun(this.components,@permute,order);
        end
        function t = isequal(varargin)
            %ISEQUAL True if calendar duration arrays are equal.
            %   TF = ISEQUAL(A,B) returns logical 1 (true) if the calendar duration arrays A
            %   and B are the same size and contain the same values, and logical 0 (false)
            %   otherwise.
            %
            %   TF = ISEQUAL(A,B,C,...) returns logical 1 (true) if all the input arguments
            %   are equal.
            %
            %   NaN elements are not considered equal to each other.  Use ISEQUALN to treat
            %   NaN elements as equal.
            %
            %   See also ISEQUALN.
            narginchk(2,Inf);
            try
                argsComponents = calendarDuration.isequalUtil(varargin);
            catch ME
                if strcmp(ME.identifier,'MATLAB:calendarDuration:InvalidComparison')
                    t = false;
                    return
                else
                    throw(ME);
                end
            end
            t = isequal(argsComponents{:});
        end
        
        function t = isequaln(varargin)
            %ISEQUALN True if calendar duration arrays are equal, treating NaN elements as equal.
            %   TF = ISEQUALN(A,B) returns logical 1 (true) if the calendar duration arrays
            %   A and B are the same size and contain the same values or corresponding NaN
            %   elements, and logical 0 (false) otherwise.
            %
            %   TF = ISEQUALN(A,B,C,...) returns logical 1 (true) if all the input arguments
            %   are equal.
            %
            %   Use ISEQUAL to treat NaN elements as unequal.
            %
            %   See also ISEQUAL.
            narginchk(2,Inf);
            try
                argsComponents = calendarDuration.isequalUtil(varargin);
            catch ME
                if strcmp(ME.identifier,'MATLAB:calendarDuration:InvalidComparison')
                    t = false;
                    return
                else
                    throw(ME);
                end
            end
            t = isequaln(argsComponents{:});
        end
    end % public methods block
    
    methods(Hidden = true)
        %% Display and strings
        function disp(this, name)
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
                [~,field] = calendarDuration.getFieldSize(this.components);
                n = builtin('end',field,k,n);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        %% Subscripting
        this = subsasgn(this,s,rhs)
        that = subsref(this,s)
        
        function sz = numArgumentsFromSubscript(~,~,~)
            sz = 1;
        end
        
        %% Variable Editor methods
        % These functions are for internal use only and will change in a
        % future release.  Do not use this function.
        [out, warnmsg] = variableEditorColumnDeleteCode(this, varName, colIntervals)
        out = variableEditorInsert(this, orientation, row, col, data)
        out = variableEditorPaste(this, rows, columns, data)
        [out, warnmsg] = variableEditorRowDeleteCode(this, varName, rowIntervals)
        
        %% Error stubs
        % Methods to override functions and throw helpful errors
        function n = datenum(this), error(message('MATLAB:calendarDuration:DatenumNotDefined')); end %#ok<MANU,STOUT>
        function n = datestr(this), error(message('MATLAB:calendarDuration:DatestrNotDefined')); end %#ok<MANU,STOUT>
        function c = linspace(a,b,n), error(message('MATLAB:calendarDuration:LinspaceNotDefined')); end %#ok<INUSD,STOUT>
        function c = colon(a,d,b), error(message('MATLAB:calendarDuration:ColonNotDefined')); end %#ok<INUSD,STOUT>
        function d = double(d), error(message('MATLAB:calendarDuration:InvalidNumericConversion','double')); end %#ok<MANU>
        function d = single(d), error(message('MATLAB:calendarDuration:InvalidNumericConversion','single')); end %#ok<MANU>
        function d = month(d), error(message('MATLAB:calendarDuration:NoMonthsMethod','month')); end %#ok<MANU>
        function d = months(d), error(message('MATLAB:calendarDuration:NoMonthsMethod','months')); end %#ok<MANU>
    end % hidden public methods block
    
    methods(Hidden = true, Static = true)
        function d = empty(varargin)
            %EMPTY Create an empty calendarDuration array.
            %   D = CALENDARDURATION.EMPTY() creates a 0x0 calendarDuration array.
            %
            %   D = CALENDARDURATION.EMPTY(M,N,...) or D = CALENDARDURATION.EMPTY([N M ...])
            %   creates an N-by-M-by-... calendarDuration array.  At least one of N,M,...
            %   must be zero.
            %
            %   See also CALENDARDURATION.
            if nargin == 0
                d = calendarDuration([],[],[]);
            else
                dComponents = zeros(varargin{:});
                if numel(dComponents) ~= 0
                    error(message('MATLAB:calendarDuration:empty:InvalidSize'));
                end
                d = calendarDuration([],[],[]);
                d.components = struct('months',dComponents,'days',dComponents,'millis',dComponents);
            end
        end
        
        function fmt = combineFormats(varargin)
            % This function is for internal use only and will change in a
            % future release.  Do not use this function.
            
            %COMBINEFORMATS Combine the formats of two calendarDuration arrays.
            %   FMT = CALENDARDURATION.COMBINEFORMATS(FMT1,FMT2,...) returns a
            %   calendarDuration format character vector that is a combination of the formats FMT1,
            %   FMT2, ... .
            %
            %   See also CALENDARDURATION.
            tokens = 'yqmwdt';
            [~,i] = ismember(unique(strjoin(varargin,'')),tokens);
            fmt = tokens(sort(i));
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
        args = isequalUtil(args)
        components = createFromFields(fields)
        s = formatAsString(components,fmt,missingAsNaN,locale)
        
        function [sz,f] = getFieldSize(components)
            % Get the size of the array, and a representative field
            if ~isscalar(components.months)
                f = components.months;
            elseif ~isscalar(components.days)
                f = components.days;
            else
                % If millis is a not a scalar, then it determines the array
                % size. If it is a scalar too, then the array is a scalar, and
                % millis is still the array size.
                f = components.millis;
            end
            sz = size(f);
        end
        
        function components = expandScalarFields(components)
            % Expand any scalar fields in an in-progress array out to the full array size.
            % Any field that is not all zeros must be stored as a full-sized array, even if
            % it contains the same value everywhere. But leave scalar zeros alone, as
            % space-saving placeholders.
            
            [sz,f] = calendarDuration.getFieldSize(components);
            if ~isscalar(f)
                if isscalar(components.months) && (components.months ~= 0)
                    components.months = repmat(components.months,sz);
                end
                if isscalar(components.days) && (components.days ~= 0)
                    components.days = repmat(components.days,sz);
                end
                if isscalar(components.millis) && (components.millis ~= 0)
                    components.millis = repmat(components.millis,sz);
                end
            end
        end
        
        function components = expandScalarZeroPlaceholders(components)
            % Expand any scalar zero placeholders out to the full array size.
            sz = calendarDuration.getFieldSize(components);
            if isequal(components.months,0)
                components.months = zeros(sz);
            end
            if isequal(components.days,0)
                components.days = zeros(sz);
            end
            if isequal(components.millis,0)
                components.millis = zeros(sz);
            end
        end
        
        function [components,nonfiniteElems,nonfiniteVals] = reconcileNonfinites(components)
            % Find and reconcile any nonfinite elements across all components of
            % the array, and put the same nonfinite in all three fields. This is
            % needed, for example, when constructing from components or adding
            % two calendarDurations together, and different components contain
            % nonfinites in the same elements.
            
            % In extreme cases, this sum could overflow, but for all practical
            % purposes, that's not an issue.
            check = components.months + components.days + components.millis;
            nonfiniteElems = ~isfinite(check);
            if any(nonfiniteElems(:))
                nonfiniteVals = check(nonfiniteElems);
                if isscalar(check)
                    % Ordinarily, reconcileNonfinites leaves scalar zero placeholders
                    % alone, they have no effect. However, a placeholder in a scalar
                    % calendarDuration can't be distinguished from a real value, so
                    % treat it like one.
                    components.months = check;
                    components.days = check;
                    components.millis = check;
                else
                    if ~isequal(components.months,0)
                        components.months(nonfiniteElems) = nonfiniteVals;
                    end
                    if ~isequal(components.days,0)
                        components.days(nonfiniteElems) = nonfiniteVals;
                    end
                    if ~isequal(components.millis,0)
                        components.millis(nonfiniteElems) = nonfiniteVals;
                    end
                end
            else
                nonfiniteVals = [];
            end
        end
        
        function field = expandFieldForOutput(components,field)
            % Expand the field out to the array size if it's a scalar zero placeholder.
            if isequal(field,0)
                field = zeros(calendarDuration.getFieldSize(components));
            end
            
            % Find any nonfinite values in other fields.
            check = components.months + components.days + components.millis;
            nonfiniteElems = ~isfinite(check);
            nonfiniteVals = check(nonfiniteElems);
            % Replicate nonfinites where necessary in this field.
            if ~isempty(nonfiniteVals)
                field(nonfiniteElems) = nonfiniteVals;
            end
        end
    end % protected static methods block
end


%%%%%%%%%%%%%%%%% Local functions %%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
function components = applyArraynessFun(components,fun,varargin)
% If the field is a scalar 0, it's just a placeholder, leave it alone
if ~isequal(components.months,0)
    components.months = fun(components.months,varargin{:});
end
if ~isequal(components.days,0)
    components.days = fun(components.days,varargin{:});
end
if ~isequal(components.millis,0)
    components.millis = fun(components.millis,varargin{:});
end
end
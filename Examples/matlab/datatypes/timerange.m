classdef (Sealed) timerange < matlab.internal.tabular.private.subscripter
%TIMERANGE Timetable row subscripting by time range.
%   S = TIMERANGE(STARTTIME,ENDTIME) creates a subscript to select rows of a
%   timetable within a range of times. S selects all rows whose times are in the
%   time interval specified by STARTTIME and ENDTIME, including STARTTIME but
%   not ENDTIME. The time interval is a half-open interval. STARTTIME and
%   ENDTIME are either datetime or duration scalars, depending on the timetable
%   that S will be used to subscript into. STARTTIME and ENDTIME may also be
%   date/time character vectors as accepted by DATETIME.
%
%   S = TIMERANGE(STARTTIME,ENDTIME,INTERVALTYPE) creates a subscript over the
%   type of interval specified by INTERVALTYPE. INTERVALTYPE is one of the
%   following:
% 
%      'open'        - select rows where STARTTIME <  ROWTIMES and ROWTIMES <  ENDTIME
%      'closed'      - select rows where STARTTIME <= ROWTIMES and ROWTIMES <= ENDTIME
%      'openleft'    - select rows where STARTTIME <  ROWTIMES and ROWTIMES <= ENDTIME
%      'openright'   - select rows where STARTTIME <= ROWTIMES and ROWTIMES <  ENDTIME
%      'closedright' - same as 'openleft'
%      'closedleft'  - same as 'openright'
%
%   Examples:
%
%   % Select rows of a timetable by date, from April 3rd to 12th, inclusive.
%   tt = array2timetable(randn(10,3),'RowTimes',datetime(2016,4,randi(15,10,1)))
%   tr = timerange(datetime(2016,4,3),datetime(2016,4,12),'closed')
%   tt4to12 = tt(tr,:)
%
%   % Select rows from April 20th to the end of the month. There are no rows in
%   % the timetable that fall in that range.
%   tr = timerange(datetime(2016,4,20),datetime(2016,5,1))
%   tt20to30 = tt(tr,:)
%
%   % Select rows of a timetable whose times are between 15 and 30 minutes, not
%   % including the right endpoint.
%   tt = array2timetable(randn(10,3),'RowTimes',hours(rand(10,1)))
%   tr = timerange(minutes(15),minutes(30))
%   tt0to1 = tt(tr,:)
%
%   See also WITHTOL, VARTYPE.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties(Transient, Access='protected')
        % left & right edge of range: default to NAT to not match anything
        first = NaT;
        last  = NaT;
        
        % Range type: 
        %   'openright' (same as 'closedleft') {default}
        %   'openleft' (same as 'closedright')
        %   'open'
        %   'closed'
        type = 'openright';
    end
    
    properties(Transient, Access='private')
        first_matchTimeZone = false;
        last_matchTimeZone = false;
    end
        
    methods
        % Constructor adds an extra, unused input so error handling catches
        % the common mistake of passing in a timetable as a leading input.
        % Otherwise, front-end would throw "Too many input arguments".
        function obj = timerange(first,last,type,~)   
            import matlab.internal.datatypes.isCharString
            import matlab.internal.datatypes.istabular
            import matlab.internal.datetime.text2timetype
            % No inputs: return default constructed timerange
            if nargin == 0
                return
            end
            
            % common error: timerange(tt,startTime,endTime,...)
            if istabular(first)
                error(message('MATLAB:timerange:TabularInput'));
            end                        
            
            % Distinguish among other possible syntaxes.
            narginchk(2,3);
            switch nargin
                case 2 % timerange(startTime,endTime) - default range type
                    % Further error checking is done in parsing code below
                case 3 % timerange(startTime,endTime,intervalType)                    
                    if ~isCharString(type) || ~isValidIntervalType(type)
                        error(message('MATLAB:timerange:InvalidIntervalType'));
                    end
                    obj.type = lower(type);
%                otherwise
%                    assert(false);
            end            
            
            % Verify input size + class
            [firstTraits, lastTraits] = verifyTypes(first, last);

            % For character vector, assume datetime and try constructing
            if firstTraits.isText
                first = text2timetype(first,'MATLAB:datetime:InvalidTextInput',last);
                [first, obj.first_matchTimeZone] = handleTimeZone(first, last, lastTraits);
            end
            
            if lastTraits.isText
                last = text2timetype(last,'MATLAB:datetime:InvalidTextInput',first);
                [last, obj.last_matchTimeZone] = handleTimeZone(last, first, firstTraits);
            end
            
            if firstTraits.isNonFiniteNum && isnumeric(first)
                first = convertNonFinite(first,last);
            elseif lastTraits.isNonFiniteNum && isnumeric(last)
                last = convertNonFinite(last,first);
            end                        
            
            % Make sure edges are scalar
            verifyScalar(first);
            verifyScalar(last);           
            % make sure after text conversion that the types are the same
            verifyConvertedTypes(first,last);
            % Type is already been assigned above
            obj.first = first;
            obj.last = last;

        end
    end   
    
    methods(Access={?withtol, ?timerange, ?vartype, ?matlab.internal.tabular.private.tabularDimension})
        % The getSubscripts method is called by table subscripting to find the indices
        % of the times (if any) along that dimension that fall between the specified
        % left and right time.
        function subs = getSubscripts(obj,subscripter)
            % Only timetable subscripting is supported. TIMERANGE is used in a
            % non-timetable context if subscripter is not a rowTimesDim
            if ~isa(subscripter,'matlab.internal.tabular.private.rowTimesDim')
                error(message('MATLAB:timerange:InvalidSubscripter'));
            end

            try
                rowTimes = subscripter.labels;
                
                if obj.first_matchTimeZone || obj.last_matchTimeZone
                    rowTimesTZ = rowTimes.TimeZone;
                    
                    if obj.first_matchTimeZone && ~isempty(rowTimesTZ)
                        obj.first.TimeZone = rowTimesTZ;
                    end
                    
                    if obj.last_matchTimeZone && ~isempty(rowTimesTZ)
                        obj.last.TimeZone = rowTimesTZ;
                    end                    
                end                   
                
                switch obj.type
                    case {'openright' 'closedleft'}
                        subs = obj.first <= rowTimes & rowTimes < obj.last;
                    case {'openleft' 'closedright'}
                        subs = obj.first < rowTimes & rowTimes <= obj.last;
                    case 'open'
                        subs = obj.first < rowTimes & rowTimes < obj.last;
                    case 'closed'
                        subs = obj.first <= rowTimes & rowTimes <= obj.last;
                    otherwise
                        error(message('MATLAB:timerange:InvalidIntervalType'));
                end
            catch ME
                if ~isequal(class(rowTimes),class(obj.first))
                    % Timetable RowTimes has different time type from that in TIMERANGE
                    error(message('MATLAB:timerange:MismatchRowTimesType',class(rowTimes),class(obj.first)));
                else
                    rethrow(ME);
                end
            end
        end
    end
    methods(Hidden = true)
        function disp(obj)      
            % Take care of formatSpacing
            tab = sprintf('\t');
            if strcmp(matlab.internal.display.formatSpacing,'loose')
                lineSpacer = newline;
            else
                lineSpacer = '';
            end
            
            % Determine what string to display depending on the interval type
            if any(strcmp(char(obj.type),{'openright' 'closedleft'})) % char is needed around obj.type to support disp of empty timerange
                msgid = 'MATLAB:timerange:UIStringDispRightOpen'; 
            elseif any(strcmp(char(obj.type),{'openleft' 'closedright'}))
                msgid = 'MATLAB:timerange:UIStringDispLeftOpen';
            elseif any(strcmp(char(obj.type),'open'))
                msgid = 'MATLAB:timerange:UIStringDispOpen';
            else %closed
                msgid = 'MATLAB:timerange:UIStringDispClosed';
            end
            
            % Plug in the time range end points
            if isa(obj.first,'datetime')
                % Use the default date and time format for datetime. The time portion must be included to make the range
                % as explicit as possible.
                s = settings;
                datetimeSettings = s.matlab.datetime;
                datetimeformat = datetimeSettings.DefaultFormat.ActiveValue;
                dispMsg = getString(message(msgid, char(obj.first, datetimeformat), char(obj.last, datetimeformat)));
            else % duration timerange, don't need a format specified
                dispMsg = getString(message(msgid, char(obj.first), char(obj.last)));
            end
            
            disp([tab getString(message('MATLAB:timerange:UIStringDispHeader')) lineSpacer]);
            disp([tab tab dispMsg lineSpacer]);
            disp([tab getString(message('MATLAB:timerange:UIStringDispFooter')) lineSpacer]);
        end
    end

    %%%% PERSISTENCE BLOCK ensures correct save/load across releases %%%%%%
    %%%% Properties and methods in this block maintain the exact class %%%%
    %%%% schema required for TIMERANGE to persist through MATLAB releases %
    properties(Constant, Access='protected')
        % current running version. This is used only for managing forward
        % compatibility. Value is not saved when an instance is serialized
        %
        %   1.0 : 16b. first shipping version
        %   1.1 : 18a. added 'first_matchTimeZone' & 'last_matchTimeZone'
        %              properties to support timezone inference on match
        %   1.2 : 18a. added serialized field 'incompatibilityMsg' to support
        %              customizable 'kill-switch' warning message. The field
        %              is only consumed in loadobj() and does not translate
        %              into any table property
        version = 1.2;
    end
    
    methods(Hidden)
        function s = saveobj(obj)
            s = struct;
            s = obj.setCompatibleVersionLimit(s, 1.0); % limit minimum version compatible with a serialized instance
            
            s.first                = obj.first; % scalar datetime or duration. left limit of the range.
            s.first_matchTimeZone  = obj.first_matchTimeZone;
            s.last                 = obj.last;  % scalar datetime or duration. right limit of the range.
            s.last_matchTimeZone   = obj.last_matchTimeZone;            
            s.type                 = obj.type;  % a single character vector. One of the allowed range types: {'openright' 'closedleft' 'openleft' 'closedright' 'open' 'closed'}
        end
    end
    
    methods(Hidden, Static)
        function obj = loadobj(s)
            % Always default construct an empty instance, and recreate a
            % proper timerange in the current schema using attributes
            % loaded from the serialized struct
            obj = timerange();
            
            % Pre-18a (i.e. v1.0) saveobj did not save the versionSavedFrom
            % field. A missing field would indiciate it is serialized in
            % version 1.0 format. Append the field if it is not present.
            if ~isfield(s,'versionSavedFrom')
                s.versionSavedFrom = 1.0;
            end            
            
            % Return the empty instance if current version is below the
            % minimum compatible version of the serialized object
            if obj.isIncompatible(s, 'MATLAB:timerange:IncompatibleLoad')
                return;
            end
            
            % Restore serialized data
            % ASSUMPTION: 1. type and semantics of the serialized struct
            %                fields are consistent as stated in saveobj above.
            %             2. as a result of #1, the values stored in the
            %                serialized struct fields are valid in this
            %                version of timerange, and can be assigned into
            %                the reconstructed object without any check
            obj.first               = s.first;
            obj.last                = s.last;
            obj.first_matchTimeZone = s.versionSavedFrom>1.0 && s.first_matchTimeZone;
            obj.last_matchTimeZone  = s.versionSavedFrom>1.0 && s.last_matchTimeZone;            
            obj.type                = s.type;
        end
    end
end

function b = isValidIntervalType(intervalType)
	% Do not allow partial matches, these are too similar.
    b = any(strcmpi(intervalType,{'openright' 'closedleft' 'openleft' 'closedright' 'open' 'closed'}));
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Input Parsing helpers %%%%%%%%%%%%%%%%%%%%%%%%%%
function verifyScalar(in)
    if ~isscalar(in)
        throwAsCaller(MException(message('MATLAB:timerange:NonScalarInput')));
    end
end

function [firstTraits, lastTraits] = verifyTypes(first, last)
    function [traits, isInvalidType] = typeTraits(in)
        import matlab.internal.datatypes.isCharString
                
        traits.isText     = isCharString(in);
        traits.isDatetime = isa(in,'datetime');
        traits.isDuration = isa(in,'duration');
        traits.isNonFiniteNum = (isnumeric(in) && isscalar(in) && ~isfinite(in))...
            || traits.isText && ismember(lower(in),["inf","+inf","-inf"]); % +/- Inf or NaN
        
        isInvalidType = ~traits.isText && ~traits.isDatetime && ~traits.isDuration && ~traits.isNonFiniteNum;
    end
    
    [firstTraits, isFirstInvalid]  = typeTraits(first);
    [lastTraits,  isLastInvalid] = typeTraits(last);
    
    % Error if either type is invalid, or both are non-finite numerics
    if isFirstInvalid || isLastInvalid || (firstTraits.isNonFiniteNum && lastTraits.isNonFiniteNum)
        throwAsCaller(MException(message('MATLAB:timetable:InvalidTimes')));
    end
    
    % Duration cannot mix with non-duration
    if (firstTraits.isDuration && lastTraits.isDatetime) || ...
       (lastTraits.isDuration && firstTraits.isDatetime)        
        throwAsCaller(MException(message('MATLAB:timerange:InputTypesMismatch')));
    end
    
    % If both are datetimes, they must be zoned or unzoned at the same time
    if firstTraits.isDatetime && lastTraits.isDatetime && xor(strcmp(first.TimeZone,''),strcmp(last.TimeZone,''))
        throwAsCaller(MException(message('MATLAB:timerange:TimeZonesMismatch')));
    end
end

function [this, matchTimeZoneOnSubscript] = handleTimeZone(this, other, otherTraits)
    % If the other edge is a datetime, match its TimeZone;
    % If both are text, match TimeZone of the subscripting context
    matchTimeZoneOnSubscript = false;
    if isa(this,'datetime')
        if otherTraits.isDatetime
            this.TimeZone = other.TimeZone;
        elseif otherTraits.isText
            matchTimeZoneOnSubscript = true;
        end
    end
end

function verifyConvertedTypes(first,last)
if ~strcmp(class(first),class(last))
    error(message('MATLAB:timerange:InputTypesMismatch'));
end
end

function a = convertNonFinite(a,b)
% For non-finite numeric, the other input determines its type.
% The case where both are simultaneously non-finite numeric is
% already ruled out in verifyTypes() above
if isdatetime(b)
    a = datetime(a,0,0);
elseif isduration(b)
    a = duration(a,0,0);
end
end
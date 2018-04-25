classdef (Sealed) withtol < matlab.internal.tabular.private.subscripter
%WITHTOL Timetable row subscripting by time with tolerance.
%   S = WITHTOL(ROWTIMES,TOL) creates a subscript to select rows of a timetable.
%   S selects all rows whose times match a time in ROWTIMES within the tolerance
%   specified by TOL. ROWTIMES is a datetime or duration vector, depending on
%   the timetable that S will be used to subscript into. ROWTIMES may also be a
%   cell array of date/time character vectors as accepted by DATETIME. TOL is a
%   non-negative tolerance specified as a duration.
%
%   Examples:
%
%   % Select the numeric variables in a timetable.
%   time = hours(1:10)' + seconds(randn(10,1));
%   tt = array2timetable(randn(10,3),'RowTimes',time)
%   wt = withtol(hours(3:8),seconds(5))
%   ttNumeric = tt(wt,:)
%
%   See also TIMERANGE, VARTYPE.

%   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Transient, Access='protected')
        subscriptTimes = NaT; % sorted datetime/duration vector used for matching
        tol = duration(NaN,0,0); % scalar duration for matching tolerance
    end
    
    properties(Transient, Access='private')
        matchTimeZone  = false;
    end
    
    methods
        % Constructor adds an extra, unused input so error handling catches
        % the common mistake of passing in a timetable as a leading input.
        % Otherwise, front-end would throw "Too many input arguments".        
        function obj = withtol(subscriptTimes,tol,~)
            import matlab.internal.datatypes.istabular
            import matlab.internal.datatypes.isCharStrings
            import matlab.internal.datatypes.isCharString
            import matlab.internal.datetime.text2timetype
            
            % No input arguments, withtol will not match to any time
            if nargin==0
                return;
            end
            
            % common error: withtol(tt,subscriptTimes,tol)
            if istabular(subscriptTimes) 
                error(message('MATLAB:withtol:TabularInput'));
            end
            
            % Enforce 2-input in other cases
            narginchk(2,2);
                        
            % Make sure that subscriptTimes are datetime/duration, and tol is duration
            % subscriptTimes can also be character vector or a cell array of character vectors
            if isCharStrings(subscriptTimes)
                subscriptTimes = text2timetype(subscriptTimes,'MATLAB:datetime:InvalidTextInput');
                obj.matchTimeZone = isdatetime(subscriptTimes);
            elseif ~isa(subscriptTimes, 'datetime') && ~isa(subscriptTimes, 'duration') % not enforcing shape - will be indiscriminantly columnize below
                error(message('MATLAB:timetable:InvalidTimes'));
            end
            
            if isCharString(tol)
                try
                    tol = duration(tol); 
                catch
                    error(message('MATLAB:withtol:InvalidTolerance'));
                end
            end
            if ~isscalar(tol) || ~isa(tol, 'duration') || (tol < 0)
                error(message('MATLAB:withtol:InvalidTolerance'));
            end
            % Forbid the case when tolerance exceeds the smallest half-interval in 
            % subscript times (which might result in duplicated data)
            maxTol = min(diff(unique(subscriptTimes))/2);
            if tol >= maxTol
                error(message('MATLAB:withtol:LargeTolerance',char(maxTol,tol.Format)));
            end
            
            obj.subscriptTimes = subscriptTimes(:); % columnize the times
            obj.tol = tol; % scalar duration
        end
    end
    
    methods(Access={?withtol, ?timerange, ?vartype, ?matlab.internal.tabular.private.tabularDimension})
        % The getSubscripts method is called by timetable subscripting to find the
        % indices of the times (if any) along that dimension that match the given
        % times within the given tolerance
        function subs = getSubscripts(obj,subscripter)
            % Only timetable subscripting is supported. WITHTOL is used in a
            % non-timetable context if subscripter is not a rowTimesDim
            if ~isa(subscripter,'matlab.internal.tabular.private.rowTimesDim')
                error(message('MATLAB:withtol:InvalidSubscripter'));
            end
            
            try                
                % Cache property values outside of loop to minimize dot access overhead
                rowTimes  = subscripter.labels;
                subsTimes = obj.subscriptTimes;
                matchTol  = obj.tol;
                
                if obj.matchTimeZone
                    subsTimes.TimeZone = rowTimes.TimeZone;
                end                
                
                % Make a list of rowTimes that match each of subscriptTimes, then vertcat
                % the list. An implicit assertion here is that timetable rowTimes is always
                % a column vector, and subscriptTimes is columnized at construction. Thus
                % subscripts return should also always be a column vector.
                subs = cell(length(subsTimes), 1);
                for i = 1:length(subsTimes)
                    subs{i} = find( (rowTimes>=subsTimes(i)-matchTol) & (rowTimes<=subsTimes(i)+matchTol) );
                end
                subs = vertcat(subs{:});
            catch ME
                rowTimesCls  = class(rowTimes);
                subsTimesCls = class(subsTimes);
                if ~isequal(rowTimesCls,subsTimesCls)
                    % Timetable RowTimes has different time type from that in WITHTOL
                    error(message('MATLAB:withtol:MismatchRowTimesType',rowTimesCls,subsTimesCls));
                else
                    rethrow(ME);
                end
            end
        end
    end
    
    methods(Hidden)
        function disp(obj)
            % Take care of formatSpacing
            tab = sprintf('\t');
            if strcmp(matlab.internal.display.formatSpacing,'loose')
                lineSpacer = newline;
            else
                lineSpacer = '';
            end
            
            numSubscripts = length(obj.subscriptTimes);
            dispSnipThres = numSubscripts;
            displaySubs = char(obj.subscriptTimes(1:min(dispSnipThres,numSubscripts)));
            displaySubsFooter = [tab tab getString(message('MATLAB:withtol:UIStringDispSnipFooter', numSubscripts-dispSnipThres)) lineSpacer];                        
            
            disp([tab getString(message('MATLAB:withtol:UIStringDispHeader')) lineSpacer]);
            disp([tab tab getString(message('MATLAB:withtol:UIStringDispTimes')) lineSpacer]);                        
            disp([repmat([tab tab], size(displaySubs,1), 1) displaySubs]);
            disp(displaySubsFooter(numSubscripts>dispSnipThres,:));
            disp([tab tab getString(message('MATLAB:withtol:UIStringDispTolerance', char(obj.tol))) lineSpacer]);
            disp([tab getString(message('MATLAB:withtol:UIStringDispFooter')) lineSpacer]);
        end
    end
    
    %%%% PERSISTENCE BLOCK ensures correct save/load across releases %%%%%%
    %%%% Properties and methods in this block maintain the exact class %%%%
    %%%% schema required for WITHTOL to persist through MATLAB releases %%%
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
            
            s.subscriptTimes = obj.subscriptTimes; % a sorted datetime or duration vector. Used in timetable subscripting to match rowTimes
            s.matchTimeZone  = obj.matchTimeZone;  % scalar logical. Used to decide if subscripting matches TimeZone in the timetable
            s.tol = obj.tol;                       % a scalar duration. Tolerance
        end
    end
    
    methods(Hidden, Static)
        function obj = loadobj(s)
            % Always default construct an empty instance, and recreate a
            % proper WITHTOL in the current schema using attributes
            % loaded from the serialized struct                
            obj = withtol();
            
            % Pre-18a (i.e. v1.0) saveobj did not save the versionSavedFrom
            % field. A missing field would indiciate it is serialized in
            % version 1.0 format. Append the field if it is not present.
            if ~isfield(s,'versionSavedFrom')
                s.versionSavedFrom = 1.0;
            end
            
            % Return the empty instance if current version is below the
            % minimum compatible version of the serialized object
            if obj.isIncompatible(s, 'MATLAB:withtol:IncompatibleLoad')
                return;
            end
            
            % Restore serialized data
            % ASSUMPTION: 1. type and semantics of the serialized struct
            %                fields are consistent as stated in saveobj above.
            %             2. as a result of #1, the values stored in the
            %                serialized struct fields are valid in this
            %                version of withtol, and can be assigned into
            %                the reconstructed object without any check
            obj.subscriptTimes = s.subscriptTimes;
            obj.matchTimeZone  = s.versionSavedFrom>1.0 && s.matchTimeZone;
            obj.tol = s.tol;
        end
    end
end

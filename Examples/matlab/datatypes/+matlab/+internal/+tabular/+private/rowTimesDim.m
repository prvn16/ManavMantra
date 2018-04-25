classdef (Sealed) rowTimesDim < matlab.internal.tabular.private.tabularDimension
%ROWTIMESDIM Internal class to represent a timetable's rows dimension.

% This class is for internal use only and will change in a
% future release.  Do not use this class.

    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Constant, GetAccess=public)
        propertyNames = {'RowTimes'};
        requireLabels = true;
        requireUniqueLabels = false;
    end
    
    %===========================================================================
    methods
        function obj = rowTimesDim(length,labels)
            assert(nargin == 2);
            
            % This is the relevant parts of validateAndAssignLabels
            if ~(isdatetime(labels) || isduration(labels))
                error(message('MATLAB:timetable:InvalidRowTimes'));
            end
            labels = labels(:); % a col vector, conveniently forces any empty to 0x1
            obj = obj.init(length,labels);
        end
        
        %-----------------------------------------------------------------------
        function labels = emptyLabels(obj,num)
            % EMPTYLABELS Return a vector of empty labels of the right kind.
            oldLabels = obj.labels;
            if isa(oldLabels,'datetime')
                labels = datetime.fromMillis(NaN(num,1),oldLabels.Format,oldLabels.TimeZone);
            else
                labels = duration.fromMillis(NaN(num,1),oldLabels.Format);
            end
        end
        
        %-----------------------------------------------------------------------
        function labels = textLabels(obj,indices)
            % TEXTLABELS Return the labels converted to text.
            if nargin < 2
                labels = cellstr(obj.labels);
            else
                labels = cellstr(obj.labels(indices));
            end
        end
                
        %-----------------------------------------------------------------------
        function labels = defaultLabels(obj,indices)
            % DEFAULTLABELS Return a vector of default labels of the right kind.
            if nargin < 2
                len = obj.length;
            else
                len = length(indices);
            end
            oldLabels = obj.labels;
            if isa(oldLabels,'datetime')
                labels = NaT(len,1,'Format',oldLabels.Format,'TimeZone',oldLabels.TimeZone);
            else
                labels = NaN(len,1);
            end
        end
                
        %-----------------------------------------------------------------------
        function obj = lengthenTo(obj,maxIndex,newLabels)
            newIndices = (obj.length+1):maxIndex;
            if nargin < 3
                if isa(obj.labels,'datetime')
                    obj.labels(newIndices,1) = NaT;
                else
                    obj.labels(newIndices,1) = NaN;
                end
            else
                % newLabels is assumed already checked by validateNativeSubscripts.
                obj.labels(newIndices,1) = newLabels(:);
            end
            obj.length = maxIndex;
        end
        
        %-----------------------------------------------------------------------
        function s = getProperties(obj)
            % Same order as rowNamesDim.propertyNames
            s.RowTimes = obj.labels;
        end
                    
        %-----------------------------------------------------------------------
        function [tf,dt] = isregular(obj, unit)
            rowTimes = obj.labels;
            
            % Test if datetime or duration row times are regularly-spaced in with
            % respect to time or a calendar unit.
            if nargin == 1
                [tf,dt] = matlab.internal.datetime.isRegularTimeVector(rowTimes);
            else
                [tf,dt] = matlab.internal.datetime.isRegularTimeVector(rowTimes,unit);
            end
        end
    end
    
    %===========================================================================
    methods (Access=protected)
        function obj = validateAndAssignLabels(obj,newLabels,rowIndices,fullAssignment,~,~,~)
            % Only accept datetime or duration, strings are not somehow auto-converted.
            % Labels are required for a time dimension, so do not allow a full assignment of
            % a 0x0 to clear them out. Allow a full assignment to change the type, but not a
            % partial assignment.
            if isdatetime(newLabels) || isduration(newLabels)
                if fullAssignment
                    % OK to replace datetime with duration or vice versa.
                elseif ~isa(newLabels,class(obj.labels))
                    error(message('MATLAB:timetable:MixedRowTimesAssignment',class(obj.labels)));
                end
            else
                error(message('MATLAB:timetable:InvalidRowTimes'));
            end
            newLabels = newLabels(:); % a col vector, conveniently forces any empty to 0x1
            
            % Missing and duplicate row times are always allowed, no need to check.
            
            obj = obj.assignLabels(newLabels,fullAssignment,rowIndices);
        end
        
        %-----------------------------------------------------------------------
        function [subscripts,indices] = validateNativeSubscripts(obj,subscripts)
            import matlab.internal.datatypes.isCharStrings
            import matlab.internal.datetime.text2timetype
            
            labels = obj.labels;
            if isa(labels,'datetime')
                if isa(subscripts,'datetime')
                    % OK
                elseif isCharStrings(subscripts)
                    subscripts = text2timetype(subscripts,'MATLAB:datetime:AutoConvertString',labels);
                    if isduration(subscripts)
                        error(message('MATLAB:timetable:InvalidRowSubscriptsDatetime'));
                    end
                else
                    error(message('MATLAB:timetable:InvalidRowSubscriptsDatetime'));
                end
                haveDatetimes = true;
            elseif isa(labels,'duration')
                if isa(subscripts,'duration') 
                    % OK
                elseif isCharStrings(subscripts)
                    subscripts = text2timetype(subscripts,'MATLAB:duration:AutoConvertString',labels);
                    if isdatetime(subscripts)
                        error(message('MATLAB:timetable:InvalidRowSubscriptsDuration'));
                    end
                else
                    error(message('MATLAB:timetable:InvalidRowSubscriptsDuration'));
                end
                haveDatetimes = false;
                denom = max(abs(labels),seconds(1e-9)); % elementwise denominator
            end
            % Create a list of rows that match for each subscript, then combine the lists.
            % Because subscripts may match multiple or no labels, can't preserve the shape
            % of the original subscripts.
            indices = cell(size(subscripts));
            
            for i = 1:numel(subscripts)
                if haveDatetimes
                    % Absolute tolerance for datetime subscripting
                    inds = find(abs(subscripts(i) - labels) < 1e-15);
                else
                    % Relative tolerance for duration subscripting,
                    % transitioning to absolute tolerance near zero.
                    inds = find(abs((subscripts(i) - labels)./denom) < 1000*eps);
                end
                
                if isempty(inds)
                    if isfinite(subscripts(i))
                        inds = 0;
                    else
                        % +Inf/-Inf won't match within tolerance because the
                        % difference will be NaN. Find exact matches here,
                        % avoiding the isfinite test unless necessary.
                        inds = find(subscripts(i) == labels);
                    end
                end
                indices{i} = inds(:)';
            end
            indices = [indices{:}];
        end
        
        %-----------------------------------------------------------------------
        function obj = makeUniqueForRepeatedIndices(obj,indices) %#ok<INUSD>
            % Row times do not need to be unique
        end
        
        %-----------------------------------------------------------------------
        function throwRequiresLabels(obj) %#ok<MANU>
            msg = message('MATLAB:timetable:CannotRemoveRowTimes');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidPartialLabelsAssignment(obj) %#ok<MANU>
            assert(false);
        end
        function throwIncorrectNumberOfLabels(obj) %#ok<MANU>
            msg = message('MATLAB:timetable:IncorrectNumberOfRowTimes');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIncorrectNumberOfLabelsPartial(obj) %#ok<MANU>
            msg = message('MATLAB:timetable:IncorrectNumberOfRowTimesPartial');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIndexOutOfRange(obj) %#ok<MANU>
            msg = message('MATLAB:table:RowIndexOutOfRange');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwUnrecognizedLabel(obj,label) %#ok<INUSD>
            assert(false); % rowTimesDim returns an empty result instead
        end
        function throwInvalidLabel(obj) %#ok<MANU>
            assert(false); % rowTimesDim throws InvalidRowSubscriptsDatetime/Duration instead
        end
        function throwInvalidSubscripts(obj) %#ok<MANU>
            assert(false); % rowTimesDim throws InvalidRowSubscriptsDatetime/Duration instead
        end
    end
    
    %===========================================================================
    methods(Static)
        function rowtimes = regularRowTimesFromTimeStep(startTime,timeStep,len)
            % This is correct for both duration and calendarDuration, as long as
            % the calendarDuration is "pure", i.e. only one unit.
            rowtimes = startTime + (0:len-1)'*timeStep;
        end
        function rowtimes = regularRowTimesFromCalDurTimeStep(startTime,timeStep,stopTime)
            % colon gets the (possibly ambiguous) arithmetic right even for
            % "non-pure" calendarDurations, without needing the length. It is
            % exact for calendarDuration steps, no round-off.
            rowtimes = (startTime:timeStep:stopTime)';
        end
        function rowtimes = regularRowTimesFromSamplingRate(startTime,samplingRate,len)
            rowtimes = startTime + milliseconds((0:len-1)')*1000/samplingRate;
        end
    end
    
    %===========================================================================
    methods(Static, Access=protected)
        function x = orientAs(x)
            % orient as column
            if ~iscolumn(x)
                x = x(:);
            end
        end
    end
end


classdef AxesLimitUtils
    % This is an undocumented class and may be removed in future.
    
    %   Copyright 2016 The MathWorks, Inc.
    
    methods (Static)
        
        function setDateTimeAxesLimits(ax, propName, dateTimeInterval)            
            % Sets the axes limits to datetimes or durations based on a java DateTimeInterval
            if strcmp('datetime',char(dateTimeInterval.getLeft.getMATLABType))
                leftDate = datetime(char(dateTimeInterval.getLeft.getDateString),...
                    'InputFormat',char(dateTimeInterval.getLeft.getFormat),...
                    'Format',char(dateTimeInterval.getLeft.getFormat));
                rightDate = datetime(char(dateTimeInterval.getRight.getDateString),...
                    'InputFormat',char(dateTimeInterval.getLeft.getFormat),...
                    'Format',char(dateTimeInterval.getLeft.getFormat));
            elseif strcmp('duration',char(dateTimeInterval.getLeft.getMATLABType))
                leftDateVec = dateTimeInterval.getLeft.getDatevec;
                rightDateVec = dateTimeInterval.getRight.getDatevec;
                leftDate = duration(leftDateVec(4),leftDateVec(5),leftDateVec(6),...
                    'Format',char(dateTimeInterval.getLeft.getFormat));
                rightDate = duration(rightDateVec(4),rightDateVec(5),rightDateVec(6),...
                    'Format',char(dateTimeInterval.getLeft.getFormat));
            elseif strcmp('categorical',char(dateTimeInterval.getLeft.getMATLABType))
                if ~strcmp(char(ax.(propName)(1)) , char(toString(dateTimeInterval.getLeft)))
                    ax.(propName)(1) = char(toString(dateTimeInterval.getLeft));
                end
                if ~strcmp(char(ax.(propName)(2)) , char(toString(dateTimeInterval.getRight)))
                    ax.(propName)(2) = char(toString(dateTimeInterval.getRight));
                    
                end
                return
            end
            try
                ax.(propName) = [leftDate, rightDate];
            catch e
                leftDateVec = dateTimeInterval.getLeft.getDatevec;
                rightDateVec = dateTimeInterval.getRight.getDatevec;
                if strcmp('datetime',char(dateTimeInterval.getLeft.getMATLABType))
                    ax.(propName) = [datetime(leftDateVec(:)'), datetime(rightDateVec(:)')];
                elseif strcmp('duration',char(dateTimeInterval.getLeft.getMATLABType))
                    ax.(propName) = [duration(leftDateVec(4),leftDateVec(5),leftDateVec(6)),...
                        duration(rightDateVec(4),rightDateVec(5),rightDateVec(6))];
                end
            end
        end
        %toJavaDateTimeInterval
        function dateTimeInterval = toAxesLimitInterval(datetimePair) 
            % Converts the pair of datetime or duration objects from MATLAB to a java DateTimeInterval
            import com.mathworks.page.plottool.propertyeditor.controls.DateTime;
            import com.mathworks.page.plottool.propertyeditor.controls.Duration;
            import com.mathworks.page.plottool.propertyeditor.controls.CategoricalType;
            import com.mathworks.page.plottool.propertyeditor.AxesLimitInterval;
            if isdatetime(datetimePair)
                dateTimeInterval = AxesLimitInterval(DateTime(char(datetimePair(1)),datetimePair(1).Format,datevec(datetimePair(1))),...
                    DateTime(char(datetimePair(2)),datetimePair(2).Format,datevec(datetimePair(2))));
            elseif isduration(datetimePair)
                dateTimeInterval = AxesLimitInterval(Duration(char(datetimePair(1)),datetimePair(1).Format,datevec(datetimePair(1))),...
                    Duration(char(datetimePair(2)),datetimePair(2).Format,datevec(datetimePair(2))));
            elseif iscategorical(datetimePair)
                dateTimeInterval = AxesLimitInterval(CategoricalType(char(datetimePair(1)),categories(datetimePair(1))),...
                    CategoricalType(char(datetimePair(2)),categories(datetimePair(2))));
            end

        end
        

        function dateTime = parseDateTimeOrDurationString(datetimeStr, existingFormat, type)
            import matlab.graphics.internal.plottools.AxesLimitUtils;
            if strcmp(type,'datetime')
                dateTime = AxesLimitUtils.parseDateTimeString(datetimeStr, existingFormat);
            elseif strcmp(type,'duration')
                dateTime = AxesLimitUtils.parseDurationString(datetimeStr, existingFormat);
            end
        end
        
        function dateTime = parseDateTimeString(datetimeStr, existingFormat)
            import com.mathworks.page.plottool.propertyeditor.controls.DateTime;
            import matlab.graphics.internal.plottools.AxesLimitUtils;
            try
                dateTimeObject = datetime(char(datetimeStr),'Format',char(existingFormat),'InputFormat',char(existingFormat));
            catch e
                dateTimeObject = datetime(char(datetimeStr));
            end
            if  isnat(dateTimeObject)
                error(message('MATLAB:rulerFunctions:InvalidDatetimeFormat'))
            end
            dateTime =  AxesLimitUtils.createJavaDateTime(dateTimeObject);
        end      
    
        function jDuration = parseDurationString(datetimeStr, existingFormat)
            import com.mathworks.page.plottool.propertyeditor.controls.Duration;
            import matlab.graphics.internal.plottools.AxesLimitUtils;
            
            hms = parseDuration(char(existingFormat),char(datetimeStr));
            try
                durationObject = duration(hms(1),hms(2),hms(3),'Format',char(existingFormat));
            catch
                durationObject = duration(hms(1),hms(2),hms(3));
            end
            jDuration = AxesLimitUtils.createJavaDuration(durationObject);
        end
        
        function dateTime = createJavaDateTime(dateTimeObject)
            % Convert the MATLAB datetime object to a java DataTime
            import com.mathworks.page.plottool.propertyeditor.controls.DateTime;
            dateTime = DateTime(char(dateTimeObject),dateTimeObject.Format,datevec(dateTimeObject));
        end
        
        function jDuration = createJavaDuration(durationObject)
            % Convert the MATLAB duration objects to a java Duration
            import com.mathworks.page.plottool.propertyeditor.controls.Duration;
            jDuration = Duration(char(durationObject),durationObject.Format,datevec(durationObject));
        end
    end
end

function hms = parseDuration(curFmt,durationString)

% variableEditorRowNameCode

% Handle duration editing.  The value needs to match the current format
% (or at least must be close enough that textscan can pick out the
% numbers entered).  This works because there is a small, finite number
% of formats allowed for durations.

if length(curFmt) == 1
    % special 1 character formats
    num = textscan(durationString, '%f');
    num = num{:};
    
    if isempty(num)
        error(['invalid value for format: ' curFmt]);
    end
    
    if strcmp(curFmt, 'y')
        % Take user input as number of years - convert to hours
        % for duration constructor
        hms = [num*365.2425*24, 0, 0];
    elseif strcmp(curFmt, 'd')
        % Take user input as number of days - convert to hours
        % for duration constructor
        hms = [num*24, 0, 0];
    elseif strcmp(curFmt, 'h')
        % Take user input as number of hours
        hms = [num, 0, 0];
    elseif strcmp(curFmt, 'm')
        hms = [0, num, 0];
    elseif strcmp(curFmt, 's')
        hms = [0, 0, num];
    end
elseif strcmp(curFmt, 'dd:hh:mm:ss')
    % User input must include dd:hh:mm:ss
    ddhhmmss = textscan(durationString, '%f:%f:%f:%f');
    if isempty(ddhhmmss{1}) || isempty(ddhhmmss{2}) || ...
            isempty(ddhhmmss{3}) || isempty(ddhhmmss{4})
        error(['invalid value for format: ' curFmt]);
    end
    hms = [ddhhmmss{1}*24 + ddhhmmss{2}, ddhhmmss{3}, ddhhmmss{4}];
elseif strcmp(curFmt, 'hh:mm:ss')
    % User input must include hh:mm:ss
    hhmmss = textscan(durationString, '%f:%f:%f');
    if isempty(hhmmss{1}) || isempty(hhmmss{2}) || isempty(hhmmss{3})
        error(['invalid value for format: ' curFmt]);
    end
    hms = [hhmmss{1:3}];
elseif strcmp(curFmt, 'mm:ss')
    % User input must include mm:ss
    mmss = textscan(durationString, '%f:%f');
    if isempty(mmss{1}) || isempty(mmss{2})
        error(['invalid value for format: ' curFmt]);
    end
    hms = [0, mmss{1}, mmss{2}];
elseif strcmp(curFmt, 'hh:mm')
    % User input must include hh:mm
    hhmm = textscan(durationString, '%f:%f');
    if isempty(hhmm{1}) || isempty(hhmm{2})
        error(['invalid value for format: ' curFmt]);
    end
    hms = [hhmm{1}, hhmm{2}, 0];
end
end
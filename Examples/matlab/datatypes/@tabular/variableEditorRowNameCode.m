function [metadataCode,warnmsg] = variableEditorRowNameCode(this,varName,index,rowLabel)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to modify row names in the row positions
% defined by the index input.

%   Copyright 2011-2016 The MathWorks, Inc.

warnmsg = '';

% Validation
if isempty(rowLabel)
    if istimetable(this)
        error(message('MATLAB:timetable:IncorrectNumberOfRowTimes'));
    else
        error(message('MATLAB:table:InvalidRowNames'));
    end
end
if this.rowDim.hasLabels && any(strcmp(this.rowDim.labels,rowLabel))
    error(message('MATLAB:table:DuplicateRowNames',rowLabel));
end

if istimetable(this)
    rowLabelsPropertyName = '.Properties.RowTimes';
else % otherwise, it's a table
    rowLabelsPropertyName = '.Properties.RowNames';
end

metadataCode = [varName rowLabelsPropertyName];
if iscellstr(this.rowDim.labels)
    metadataCode = [metadataCode '{' num2str(index) '} = ''' rowLabel ''';'];
elseif isdatetime(this.rowDim.labels)
    % Handle datetime row labels
    try
        % Try to validate datetime, so errors can be displayed to the user
        % before the code is generated.
        eval(['datetime(''' rowLabel ''', ''Format'', ''' strrep(this.rowDim.labels.Format, '''', '''''') ''');']);
        metadataCode = [metadataCode '(' num2str(index) ') = ''' rowLabel ''';'];
    catch
        error(message('MATLAB:datetime:InvalidFromVE'));
    end
elseif isduration(this.rowDim.labels)
    % Handle duration editing.  The value needs to match the current format
    % (or at least must be close enough that textscan can pick out the
    % numbers entered).  This works because there is a small, finite number
    % of formats allowed for durations.
    curFmt = this.rowDim.labels.Format;
    try
        if length(curFmt) == 1
            % special 1 character formats
            num = textscan(rowLabel, '%f');
            num = num{:};
            
            if isempty(num)
                error(['invalid value for format: ' curFmt]);
            end
            
            if strcmp(curFmt, 'y')
                % Take user input as number of years - convert to hours
                % for duration constructor
                eval(['duration(' num2str(num*365.2425*24) ...
                    ', 0, 0, ''Format'', curFmt);']);
                durStr = ['duration(' num2str(num*365.2425*24) ...
                    ', 0, 0, ''Format'', ''' curFmt ''')'];
            elseif strcmp(curFmt, 'd')
                % Take user input as number of days - convert to hours
                % for duration constructor
                eval(['duration(' num2str(num*24) ...
                    ', 0, 0, ''Format'', curFmt);']);
                durStr = ['duration(' num2str(num*24) ...
                    ', 0, 0, ''Format'', ''' curFmt ''')'];
            elseif strcmp(curFmt, 'h')
                % Take user input as number of hours
                eval(['duration(' num2str(num) ...
                    ', 0, 0, ''Format'', curFmt);']);
                durStr = ['duration(' num2str(num) ...
                    ', 0, 0, ''Format'', ''' curFmt ''')'];
            elseif strcmp(curFmt, 'm')
                % Take user input as number of minutes
                eval(['duration(0, ' num2str(num) ...
                    ', 0, ''Format'', curFmt);']);
                durStr = ['duration(0, ' num2str(num) ...
                    ', 0, ''Format'', ''' curFmt ''')'];
            elseif strcmp(curFmt, 's')
                % Take user input as number of seconds
                eval(['duration(0, 0, ' num2str(num) ...
                    ', ''Format'', curFmt);']);
                durStr = ['duration(0, 0, ' num2str(num) ...
                    ', ''Format'', ''' curFmt ''')'];
            end
        elseif strcmp(curFmt, 'dd:hh:mm:ss')
            % User input must include dd:hh:mm:ss
            ddhhmmss = textscan(rowLabel, '%f:%f:%f:%f');
            if isempty(ddhhmmss{1}) || isempty(ddhhmmss{2}) || ...
                    isempty(ddhhmmss{3}) || isempty(ddhhmmss{4})
                error(['invalid value for format: ' curFmt]);
            end
            eval(['duration('  num2str(ddhhmmss{1}*24 + ddhhmmss{2}) ...
                ', ' num2str(ddhhmmss{3}) ', ' num2str(ddhhmmss{4}) ...
                ', ''Format'', curFmt);']);
            durStr = ['duration(' num2str(ddhhmmss{1}*24 + ddhhmmss{2}) ...
                ', ' num2str(ddhhmmss{3}) ', ' num2str(ddhhmmss{4}) ...
                ', ''Format'', ''' curFmt ''')'];
            
        elseif strcmp(curFmt, 'hh:mm:ss')
            % User input must include hh:mm:ss
            hhmmss = textscan(rowLabel, '%f:%f:%f');
            if isempty(hhmmss{1}) || isempty(hhmmss{2}) || isempty(hhmmss{3})
                error(['invalid value for format: ' curFmt]);
            end
            eval(['duration('  num2str(hhmmss{1}) ...
                ', ' num2str(hhmmss{2}) ', ' num2str(hhmmss{3}) ...
                ', ''Format'', curFmt);']);
            durStr = ['duration(' num2str(hhmmss{1}) ...
                ', ' num2str(hhmmss{2}) ', ' num2str(hhmmss{3}) ...
                ', ''Format'', ''' curFmt ''')'];
        elseif strcmp(curFmt, 'mm:ss')
            % User input must include mm:ss
            mmss = textscan(rowLabel, '%f:%f');
            if isempty(mmss{1}) || isempty(mmss{2})
                error(['invalid value for format: ' curFmt]);
            end
            eval(['duration(0, '  ...
                num2str(mmss{1}) ', ' num2str(mmss{2}) ...
                ', ''Format'', curFmt);']);
            durStr = ['duration(0, ' num2str(mmss{1}) ...
                ', ' num2str(mmss{2}) ...
                ', ''Format'', ''' curFmt ''')'];
            
        elseif strcmp(curFmt, 'hh:mm')
            % User input must include hh:mm
            hhmm = textscan(rowLabel, '%f:%f');
            if isempty(hhmm{1}) || isempty(hhmm{2})
                error(['invalid value for format: ' curFmt]);
            end
            eval(['duration('  num2str(hhmm{1}) ...
                ', ' num2str(hhmm{2}) ', 0' ...
                ', ''Format'', curFmt);']);
            durStr = ['duration(' num2str(hhmm{1}) ...
                ', ' num2str(hhmm{2}) ', 0' ...
                ', ''Format'', ''' curFmt ''')'];
        end
        
        metadataCode = [varName rowLabelsPropertyName ...
            '(' num2str(index) ') = ' durStr ';'];
    catch
        error(message('MATLAB:duration:InvalidFromVE'));
    end
end





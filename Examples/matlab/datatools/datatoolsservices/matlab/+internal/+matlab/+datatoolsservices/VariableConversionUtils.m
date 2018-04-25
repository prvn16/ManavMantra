classdef VariableConversionUtils
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Internal class use for variable conversion tools for the Data Tools
    % UIs.
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods(Static)
        function d = getDurationFromText(text, varargin)
            % Returns a duration from the given text.  This is needed
            % because duration objects do not have a constructor which
            % accepts text.
            %
            % If no additional arguments are given, the text is assumed to
            % be in the default duration display format.
            %
            % The second argument can optionally be the display format to
            % use (as text), or a duration object, which will provide the
            % format to use.
            if nargin == 1
                % Use the default duration display format
                curFmt = duration.DefaultDisplayFormat;
            else
                if isduration(varargin{1})
                    % Use the format of the given duration
                    curFmt = varargin{1}.Format;
                else
                    % Use the format which was passed in as an argument
                    curFmt = varargin{1};
                end
            end
            
            try
                if length(curFmt) == 1
                    % special 1 character formats
                    num = textscan(text, '%f');
                    num = num{:};
                    
                    if isempty(num)
                        error(['invalid value for format: ' curFmt]);
                    end
                    
                    if strcmp(curFmt, 'y')
                        % Take user input as number of years - convert to hours
                        % for duration constructor
                        d = duration(num*365.2425*24, 0, 0, 'Format', curFmt);
                    elseif strcmp(curFmt, 'd')
                        % Take user input as number of days - convert to hours
                        % for duration constructor
                        d = duration(num*24, 0, 0, 'Format', curFmt);
                    elseif strcmp(curFmt, 'h')
                        % Take user input as number of hours
                        d = duration(num, 0, 0, 'Format', curFmt);
                    elseif strcmp(curFmt, 'm')
                        % Take user input as number of minutes
                        d = duration(0, num, 0, 'Format', curFmt);
                    elseif strcmp(curFmt, 's')
                        % Take user input as number of seconds
                        d = duration(0, 0, num, 'Format', curFmt);
                    end
                elseif strcmp(curFmt, 'dd:hh:mm:ss')
                    % User input must include dd:hh:mm:ss
                    ddhhmmss = textscan(text, '%f:%f:%f:%f');
                    if isempty(ddhhmmss{1}) || isempty(ddhhmmss{2}) || ...
                            isempty(ddhhmmss{3}) || isempty(ddhhmmss{4})
                        error(['invalid value for format: ' curFmt]);
                    end
                    d = duration(ddhhmmss{1}*24 + ddhhmmss{2}, ddhhmmss{3}, ddhhmmss{4}, 'Format', curFmt);
                    
                elseif strcmp(curFmt, 'hh:mm:ss')
                    % User input must include hh:mm:ss
                    hhmmss = textscan(text, '%f:%f:%f');
                    if isempty(hhmmss{1}) || isempty(hhmmss{2}) || isempty(hhmmss{3})
                        error(['invalid value for format: ' curFmt]);
                    end
                    d = duration(hhmmss{1}, hhmmss{2}, hhmmss{3}, 'Format', curFmt);
                elseif strcmp(curFmt, 'mm:ss')
                    % User input must include mm:ss
                    mmss = textscan(text, '%f:%f');
                    if isempty(mmss{1}) || isempty(mmss{2})
                        error(['invalid value for format: ' curFmt]);
                    end
                    d = duration(0, mmss{1}, mmss{2}, 'Format', curFmt);
                    
                elseif strcmp(curFmt, 'hh:mm')
                    % User input must include hh:mm
                    hhmm = textscan(text, '%f:%f');
                    if isempty(hhmm{1}) || isempty(hhmm{2})
                        error(['invalid value for format: ' curFmt]);
                    end
                    
                    d = duration(hhmm{1}, hhmm{2}, 0, 'Format', curFmt);
                end
            catch
                d = [];
            end
        end
    end
end
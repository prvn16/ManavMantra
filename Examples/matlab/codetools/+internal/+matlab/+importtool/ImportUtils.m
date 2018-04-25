% Copyright 2012-2017 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version. 

classdef ImportUtils
    methods (Static)
        function columnNames = getDefaultColumnNames(wsVarNames, data, ncols, avoidShadow)
            if nargin<=2 || ncols==-1
                ncols = size(data,2);
            end
            
            if ~isstring(data)
                data = string(data);
            end
            
            % initialize columnNames to be a row vector - that's what
            % callers expect us to return
            columnNames = string([]);
            
            % reshape wsVarNames to be a row vector to line up with
            % columnNames being a row vector
            wsVarNames = reshape(wsVarNames, 1, numel(wsVarNames));
            
            for col=1:ncols
                if col <= size(data, 2) && ~ismissing(data(1,col)) && ~(data(1,col) == '')
                    % Try to extract a valid variable name from the column
                    % header.  This is done by replacing any beginning
                    % characters which are not alphabetic with '', and any
                    % non-alphanumeric or underscore characters in the rest
                    % of the name with ''.  For example, a header name like
                    % '1_BadVar#1_Name' will become BadVar1_Name.
                    cellData = regexprep(data(1,col), ...
                        '^[^a-zA-Z]*|[^a-zA-Z0-9_]', '');
                else 
                    cellData = [];
                end
                if ~(cellData == '') 
                   colName = cellData;
                else
                   colName = "VarName" + col;
                end
                if strlength(colName) > namelengthmax
                    varName = colName.extractBefore(namelengthmax+1);
                else
                    varName  = colName;
                end
                if needsNewName(varName, wsVarNames, columnNames, avoidShadow) 
                   varName = getNewVarName(varName, wsVarNames, columnNames, avoidShadow);
                end
                
                % add the new var name to the end of the row
                columnNames(1, end+1) = varName; %#ok<AGROW>
            end 
        end
        
        function val = variableExists(varName)
        % variableExists is used to ensure that default variable names do
        % not conflict with MATLAB functions, classes, builtins etc. Note,
        % that we do not care about exist(varName)==1 because conflicts
        % with variables in this function's workspace are not important.

            %TODO: convert to char for exist and which functions
            if isstring(varName)
                varName = char(varName);
            end
            
            val = 0;
            if exist(varName, 'var') % Check for variables
                val = 1;
            else
                whichVarName = which(varName);
                
                if ~isempty(whichVarName)
                    if ~isempty(regexp(whichVarName, ...
                            ['(.*[\\/]' varName '\.m)'], 'match'))
                        val = 2;
                    elseif ~isempty(regexp(whichVarName, ...
                            ['(.*[\\/]' varName '\))'], 'match'))
                        val = 3;
                    end
                    
                    if (val > 0) && ...
                            contains(whichVarName, '@') && ...
                            (exist(varName, 'builtin') == 0)
                        % The varName only exists as a function within a
                        % Matlab class folder.  Don't consider this as an
                        % existing variable, since it can't be called
                        % directly on the command line.
                        val = 0;
                    end
                end
            end
        end
        
        function [dateFormat,formatIndex] = getDateFormat(str)
            formatstr = internal.matlab.importtool.ImportUtils.getAllDateFormats;
            currentLocale = char(java.util.Locale.getDefault.toString);
            englishLocale = any(strfind(currentLocale, 'en') == 1);

            [dateFormat, formatIndex] = internal.matlab.importtool.ImportUtils.getDateFormatWithLocale(str, formatstr, englishLocale);
        end
        
        function [dateFormat, formatIndex] = getDateFormatWithLocale(str, formatstr, englishLocale)
            
            dateFormat = '';
            formatIndex = -1;
            
            % disable any warnings coming from the datetime constructor.
            % It will try to warn for ambiguous formats which we may not
            % care about, and capture lasterror to reset it afterwards, so
            % format errors won't show up in lasterror after Import.
            s = warning('off', 'all');
            L = lasterror; %#ok<*LERR>
            
            for k=1:length(formatstr)
                try %#ok<TRYNC>
                    % Attempt to guess the best matching format for the
                    % given date/time string.  The datetime constructor
                    % will guess many formats, but it sets the Format
                    % property of the resulting datetime array to the
                    % format passed in, so its best if we can guess what
                    % the best matching format is.
                    format_slashdates = false;
                    format_dashdates = false;
                    
                    if str.contains('-')
                        format_dashdates = ~isempty(regexp(str,'^\w{1,2}\-{1}\w{3}\-{1}\w{2,4}.*','once')); %ww-www-ww(ww)*
                        if ~format_dashdates
                            % try with year first
                            format_dashdates = ~isempty(regexp(str,'^\w{2,4}\-{1}\w{2}\-{1}\w{1,2}.*','once')); %ww(ww)-w(w)-w(2)*
                        end
                    end
                    if ~format_dashdates && str.contains('/')
                        format_slashdates = ~isempty(regexp(str,'^\w{1,2}\/{1}\w{1,2}\/{0,1}\w{0,4}.*','once'));
                    end
                    format_times = str.contains(':') && ~isempty(regexp(str,'\w{1,2}\:{1}\w{2}\:{0,1}\w{0,2}.*','once'));
                    
                    if format_dashdates || format_slashdates || format_times
                        
                        if format_slashdates && ...
                                isempty(regexp(formatstr{k},'^\w{1,2}\/{1}\w{1,2}\/{0,1}\w{0,4}.*','once'))
                            % date string has slashes but format doesn't,
                            % so skip it
                            continue;
                        end
                        
                        if format_dashdates && ...
                                isempty(regexp(formatstr{k},'^\w{1,2}\-{1}\w{3}\-{1}\w{2,4}.*','once')) && ...
                                isempty(regexp(formatstr{k},'^\w{2,4}\-{1}\w{2}\-{1}\w{1,2}.*','once'))
                            % date string has slashes but format doesn't,
                            % so skip it
                            continue;
                        end
                        
                        if ~format_times && ...
                                ~isempty(regexp(formatstr{k},'\w{2}\:{1}\w{2}\:{0,1}\w{0,2}.*','once'))
                            % date string doesn't have times but format
                            % does, so skip it
                            continue
                        end
                        
                        % Attempt to create a datetime object with the
                        % specified format.  
                        dt = [];
                        try
                            dt = datetime(str, 'InputFormat', formatstr{k});
                        catch
                            if ~englishLocale
                                % Try using English locale as well
                                try
                                    dt = datetime(str, 'InputFormat', ...
                                        formatstr{k}, 'Locale', 'en_US');
                                catch
                                end
                            end
                        end
                        
                        % If the format doesn't work, the datetime
                        % properties will be NaN.  Check an arbitrary one
                        % (hour) to see whether it worked.  Also avoid
                        % years less than 100 (so we don't choose a year
                        % format of yyyy for 2 digit years)
                        if ~isempty(dt) && ~isnan(dt.Hour) && dt.Year > 100
                            dateFormat = formatstr{k};
                            formatIndex = k;
                            warning(s);
                            return
                        end
                    end
                end
            end
            
            % Reset warning and lasterror state
            warning(s);
            lasterror(L);
        end

        % Returns the list of all date formats which the import tool will
        % attempt to match.
        function dateFormats = getAllDateFormats
            dateFormats = strings(16, 1);
            dateFormats(1) = "dd-MMM-yyyy HH:mm:ss";
            dateFormats(2) = "dd-MMM-yyyy";
            
            currentLocale = char(java.util.Locale.getDefault.toString);
            englishLocale = strcmpi(currentLocale,'en_US');

            if englishLocale
                dateFormats(3) = "MM/dd/yy HH:mm:ss";
                dateFormats(4) = "MM/dd/yyyy HH:mm:ss";
                dateFormats(5) = "MM/dd/yyyy hh:mm:ss a";
                dateFormats(6) = "MM/dd/yyyy";
                dateFormats(7) = "MM/dd/yy";
                dateFormats(8) = "MM/dd";
            else
                dateFormats(3) = "dd/MM/yy HH:mm:ss";
                dateFormats(4) = "dd/MM/yyyy HH:mm:ss";
                dateFormats(5) = "dd/MM/yyyy hh:mm:ss a";
                dateFormats(6) = "dd/MM/yyyy";
                dateFormats(7) = "dd/MM/yy";
                dateFormats(8) = "dd/MM";
            end
            
            dateFormats(9) = "HH:mm:ss";
            dateFormats(10) = "hh:mm:ss a";
            dateFormats(11) = "HH:mm";
            dateFormats(12) = "hh:mm a";
            dateFormats(13) = "dd-MMM-yyyy HH:mm";  %used by finance
            dateFormats(14) = "dd-MMM-yy";  %used by finance
            dateFormats(15) = "MM/dd/yyyy HH:mm";
            dateFormats(16) = "yyyy-MM-dd"; % ISO 8601 standard
        end
        
        function b = isStringTextType()
            b = strcmp(internal.matlab.importtool.ImportUtils.getSetTextType, 'string');
        end
        
        function b = getSetTextType(varargin)
            s = settings;
            st = s.matlab.importtool.ImportToolTextType;
            if nargin == 1
                newTextType = varargin{1};
                if strcmp(newTextType, 'char') || ...
                        strcmp(newTextType, 'string')
                    st.PersonalValue = newTextType;
                end
            else
                b = st.ActiveValue;
            end
        end
    end 
    
    properties (Constant)
        DEFAULT_TEXT_TYPE = 'string';
    end
end

function TF = needsNewName(varName, wsVarNames, derivedColumnNames, avoidShadow)  
% needsNewName returns true if a new name is needed. New names
% are never needed if avoidShadow is ALLOW_SHADOW.
% if avoidShadow is AVOID_SOME_SHADOWS, names must be
% "isvarname" and not be duplicated.
% if avoidShadow is AVOID_SOME_SHADOWS, names must be
% "isvarname", not be duplicated, must not be an existing
% variable, and must not be a function or builtin.

%TODO: convert to char for isvarname
    TF = false;
    if avoidShadow.isAvoidSomeShadows() && ... % tables
            (any(strcmp(varName,derivedColumnNames)) || ~isvarname(char(varName)))
        TF = true;
    elseif avoidShadow.isAvoidAllShadows() && ... % column vectors
            (internal.matlab.importtool.ImportUtils.variableExists(varName)>1 ...
            || any(strcmp(varName,[wsVarNames(:); derivedColumnNames(:)])))
        TF = true;
        % else -  numeric Matrix or cell array - always false;
    end
end

function varName = getNewVarName(varName, wsVarNames, columnNames, avoidShadow)
% getNewVarName returns a valid name that can be used as a column header
    numericSuffixStart = regexp(varName,'\d*$','once');
    if ~isempty(numericSuffixStart)
        varNameRoot = varName.extractBefore(numericSuffixStart);
    else
        varNameRoot = varName;
    end
    suffixDigit = 1;
    
    if strlength(varNameRoot) >= namelengthmax
        varName = varNameRoot.extractBefore(min(namelengthmax-length(num2str(suffixDigit))+1, ...
            strlength(varNameRoot)+length(num2str(suffixDigit))));
    else
        varName = varNameRoot;
    end
    
    if avoidShadow.isAvoidSomeShadows() % Tables - just don't used matlab 
                                        % keywords or duplicated column 
                                        % names. 
        while iskeyword(varName+suffixDigit) || ...
                any(strcmp(varName+suffixDigit,columnNames(:)))
            suffixDigit=suffixDigit+1;
            if strlength(varName+suffixDigit) >= namelengthmax
                varName = varNameRoot.extractBefore(namelengthmax-length(num2str(suffixDigit))+1);
            end
        end
    elseif avoidShadow.isAvoidAllShadows() % Column vectors
        while internal.matlab.importtool.ImportUtils.variableExists(varName+suffixDigit)>1 || ...
                any(strcmp(varName+suffixDigit, [wsVarNames(:); columnNames(:)]))
            suffixDigit=suffixDigit+1;
            if strlength(varName+suffixDigit) >= namelengthmax
                varName = varNameRoot.extractBefore(namelengthmax-length(num2str(suffixDigit))+1);
            end
        end
    end
    varName = varName+suffixDigit;
end

       
        

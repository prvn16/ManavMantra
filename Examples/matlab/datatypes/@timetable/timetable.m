classdef (Sealed) timetable < tabular
%TIMETABLE Timetable.
%   Timetables are used to collect heterogeneous data and metadata into a single
%   container, where each row has a timestamp.  Timetables are suitable for
%   storing column-oriented or tabular timestamped data that are often stored as
%   columns in a text file or in a spreadsheet.  Timetables can accommodate
%   variables of different types, sizes, units, etc.  They are often used to
%   store experimental data, with rows representing different observations and
%   columns representing different measured variables.
%
%   Use the TIMETABLE constructor to create a timetable from variables in the
%   MATLAB workspace.  Use TABLE2TIMETABLE or ARRAY2TIMETABLE to create a
%   timetable from a table or array, respectively. Use the readtable function to
%   create a table by reading data from a text or spreadsheet file, and then use
%   TABLE2TIMETABLE to convert that to a timetable.
%
%   The TIMETABLE constructor can also be used to create timetables without
%   providing workspace variables, by providing the rowtimes, timetable
%   size and variable types.
%
%   Timetables can be subscripted using parentheses much like ordinary numeric
%   arrays, but in addition to numeric and logical indices, you can use a
%   timetable's variable and row names as indices.  You can access individual
%   variables in a timetable much like fields in a structure, using dot
%   subscripting.  You can access the contents of one or more variables using
%   brace subscripting.
%
%   Timetables can contain different kinds of variables, including numeric,
%   logical, character, categorical, and cell.  However, a timetable is a
%   different class than the variables that it contains.  For example, even a
%   timetable that contains only variables that are double arrays cannot be
%   operated on as if it were itself a double array.  However, using dot
%   subscripting, you can operate on a variable in a timetable as if it were a
%   workspace variable.  Using brace subscripting, you can operate on one or
%   more variables in a timetable as if they were in a homogeneous array.
%
%   A timetable TT has properties that store metadata such as its variable names
%   and row times.  Access or assign to a property using P = TT.Properties.PropName
%   or TT.Properties.PropName = P, where PropName is one of the following:
%
%   TIMETABLE metadata properties:
%       Description          - A character vector describing the timetable
%       DimensionNames       - A two-element cell array of character vectors containing names of
%                              the dimensions of the timetable
%       VariableNames        - A cell array containing names of the variables in the timetable
%       VariableDescriptions - A cell array of character vectors containing descriptions of the
%                              variables in the timetable
%       VariableUnits        - A cell array of character vectors containing units for the variables
%                              in the timetable
%       VariableContinuity   - An array containing a matlab.tabular.Continuity value for each timetable 
%                              variable, specifying whether a variable represents continuous or discrete 
%                              data values. You can assign 'unset', 'continuous', 'step', or 'event' to
%                              elements of VariableContinuity.
%       RowTimes             - A datetime or duration vector containing the times associated 
%                              with each row in the timetable. The time are not required to be
%                              uniformly-spaced, unique, or sorted, and RowTimes may contain
%                              missing values.
%       UserData             - A variable containing any additional information associated
%                              with the timetable.  You can assign any value to this property.
%
%   TIMETABLE methods and functions:
%     Construction and conversion:
%       timetable        - Create a timetable from workspace variables.
%       array2timetable  - Convert homogeneous array to timetable.
%       table2timetable  - Convert table to timetable.
%       timetable2table  - Convert timetable to table.
%     Size and shape:
%       istimetable      - True for timetables.
%       size             - Size of a timetable.
%       width            - Number of variables in a timetable.
%       height           - Number of rows in a timetable.
%       ndims            - Number of dimensions of a timetable.
%       numel            - Number of elements in a timetable.
%       horzcat          - Horizontal concatenation for timetables.
%       vertcat          - Vertical concatenation for timetables.
%     Set membership:
%       intersect        - Find rows common to two timetables.
%       ismember         - Find rows in one timetable that occur in another timetable.
%       setdiff          - Find rows that occur in one timetable but not in another.
%       setxor           - Find rows that occur in one or the other of two timetables, but not both.
%       unique           - Find unique rows in a timetable.
%       union            - Find rows that occur in either of two timetables.
%       join             - Merge two timetables by matching up rows using key variables.
%       innerjoin        - Inner join between two timetables.
%       outerjoin        - Outer join between two timetables.
%     Data manipulation and reorganization
%       retime           - Adjust a timetable and its data to a new time vector.
%       synchronize      - Synchronize timetables.
%       addvars          - Insert new variables at a specified location in a table.
%       movevars         - Move table variables to a specified location.
%       removevars       - Delete the specified table variables.
%       splitvars        - Splits multi-column variables into separate variables.
%       mergevars        - Merges multiple variables into one multi-column variable or a nested table.
%       sortrows         - Sort rows of a timetable.
%       lag              - Lag or lead data in a timetable.
%       issorted         - TRUE for a sorted timetable.
%       isregular        - TRUE for a regular timetable.
%       summary          - Print summary of a timetable.
%       sortrows         - Sort rows of a timetable.
%       stack            - Stack up data from multiple variables into a single variable.
%       unstack          - Unstack data from a single variable into multiple variables.
%       rows2vars        - Reorient rows to be variables of output table.
%       inner2outer      - Invert a nested table-in-table hierarchy.
%       ismissing        - Find elements in a timetable that contain missing values.
%       standardizeMissing - Insert missing data indicators into a timetable.
%     Computations on timetables:
%       varfun           - Apply a function to variables in a timetable.
%       rowfun           - Apply a function to rows of a timetable.
%     Subscripting into timetables:
%       timerange        - Timetable row subscripting by time range.
%       withtol          - Timetable row subscripting by time with tolerance.
%       vartype          - Timetable variable subscripting by variable type.
%
%   Examples:
%
%      % Create a timetable from individual workspace variables. Notice that the
%      % name of the timetable's row times vector is the same as the workspace variable.
%      MeasurementTime = datetime({'2015-12-18 08:03:05';'2015-12-18 10:03:17';'2015-12-18 12:03:13'});
%      Temp = [37.3;39.1;42.3];
%      Pressure = [30.1;30.03;29.9];
%      WindSpeed = [13.4;6.5;7.3];
%      WindDirection = categorical({'NW';'N';'NW'});
%      TT = timetable(MeasurementTime,Temp,Pressure,WindSpeed,WindDirection)
%      
%      % Create a timetable using duration row times instead of datetimes.
%      ElapsedTime = seconds([7385;14597;21793]);
%      TT = timetable(ElapsedTime,Temp,Pressure,WindSpeed,WindDirection)
%      
%      % Create a timetable using the RowTimes parameter. Notice that the name
%      % of the timetable's row times vector is the default, 'Time'.
%      TT = timetable(Temp,Pressure,WindSpeed,WindDirection,'RowTimes',MeasurementTime)
%
%      % Create a timetable from columns of one numeric matrix.
%      data = cumsum(randn(25,4),1);
%      TT = array2timetable(data,'VariableNames',{'X' 'Y' 'Z1' 'Z2'},'RowTimes',datetime(2016,11,1:25))
%      
%      % Select the rows where X is large, and select a subset of the variables.
%      TTpositive = TT(TT.X>0, {'X' 'Y'})
%
%      % Convert the two Z variables into a single variable.
%      TT.Z = [TT.Z1 TT.Z2];
%      TT(:,{'Z1' 'Z2'}) = []
%
%      % Select rows at two specific times.
%      TT(datetime(2016,11,[3 4]), :)
%
%      % Select rows within a range of times.
%      TT(timerange(datetime(2016,11,5),datetime(2016,11,10),'closed'),:)
%
%      % Add metadata to the timetable.
%      TT.Properties.Description = 'Simulated measurement data';
%      TT.Properties.VariableUnits =  {'m' 'm' 'Pa'};
%      TT.Properties.VariableDescriptions{3} = 'Upper/Lower Pressure';
%      summary(TT)
%
%      % Create a new variable in the timetable from existing variables.
%      TT.ZRatio = TT.Z(:,2)./TT.Z(:,1)
%
%      % Sort the timetable based on the new variable.
%      sortrows(TT,'ZRatio')
%
%      % Make a scatter plot of one of the timetable's variables against time.
%      plot(TT.Time,TT.X,'x')
%
%      % Make a scatter plot of two of the timetable's variables.
%      plot(TT.X,TT.Y,'o')
%
%      % Make a scatter plot of two of the timetable's variables against time.
%      plot(TT.Time,TT{:,{'X' 'Y'}},'-o')
%
%   See also TIMETABLE, TABLE2TIMETABLE, ARRAY2TIMETABLE

%   Copyright 2016-2017 The MathWorks, Inc.
        
    properties(Constant, GetAccess='protected')
        propertyNames = [fieldnames(tabular.arrayPropsDflts); ...
                                    matlab.internal.tabular.private.metaDim.propertyNames; ...
                                    matlab.internal.tabular.private.varNamesDim.propertyNames; ...
                                    matlab.internal.tabular.private.rowTimesDim.propertyNames];
        defaultDimNames = dfltTimetableDimNames();
        dispRowLabelsHeader = true;
    end
        
    properties(Transient, Access='protected')
        data = cell(1,0);
        
        metaDim = matlab.internal.tabular.private.metaDim(2,timetable.defaultDimNames);
        rowDim  = matlab.internal.tabular.private.rowTimesDim(0,datetime.empty(0,1));
        varDim  = matlab.internal.tabular.private.varNamesDim(0);
        
        % 'Properties' will appear to contain this, as well as the per-row, per-var,
        % and per-dimension properties contained in rowDim, varDim. and metaDim,
        arrayProps = timetable.arrayPropsDflts;
    end
            
    methods
        function t = timetable(varargin)
        %TIMETABLE Create a timetable from workspace variables.
        %   Use TIMETABLE to create a timetable from variables in the MATLAB workspace.
        %   Use TABLE2TIMETABLE or ARRAY2TIMETABLE to create a timetable from a table or
        %   array, respectively. To create a timetable from data from a text or
        %   spreadsheet file, use READTABLE and then use TABLE2TIMETABLE to convert the
        %   result from a table to a timetable.
        %
        %   TT = TIMETABLE(ROWTIMES, VAR1, VAR2, ...) creates a timetable TT from the
        %   workspace variables VAR1, VAR2, ..., using the datetime or duration vector
        %   ROWTIMES as the time vector.  All variables must have the same number of
        %   rows.
        %
        %   TT = TIMETABLE(VAR1, VAR2, ..., 'RowTimes',ROWTIMES) creates a timetable
        %   using the specified datetime or duration vector, ROWTIMES, as the time
        %   vector. Other datetime or duration inputs become variables in TT.
        %
        %   TT = TIMETABLE(VAR1, VAR2, ..., 'SamplingRate',FS,'StartTime',T0)
        %   creates a timetable using the specified sampling rate FS and start time
        %   T0 to implicitly define TT's time vector. FS is a positive numeric
        %   scalar specifying the number of samples per second (Hz). T0 is a scalar
        %   datetime or duration, and determines whether TT's row times are absolute
        %   (T0 is a datetime) or relative (T0 is a duration). The default is
        %   SECONDS(0).
        %
        %   TT = TIMETABLE(VAR1, VAR2, ..., 'TimeStep',DT,'StartTime',T0) creates a
        %   timetable using the specified time step DT and start time T0 to
        %   implicitly define TT's time vector. DT is a scalar duration or
        %   calendarDuration specifying the inter-sample time step. T0 is a scalar
        %   datetime or duration, and determines whether TT's row times are absolute
        %   (T0 is a datetime) or relative (T0 is a duration). T0 must be a datetime
        %   if DT is a calendarDuration. The default is SECONDS(0).
        %
        %   TT = TIMETABLE(..., 'VariableNames', {'name1', ..., 'name_M'}) creates a
        %   timetable using the specified variable names. The names must be valid MATLAB
        %   identifiers, and unique.
        %
        %   TT = TIMETABLE('Size', [n m], 'VariableTypes', {'type1', ...,
        %   'typeM'}, 'RowTimes', ROWTIMES, ...) creates a timetable with
        %   the given rowtimes, timetable size and variable types. When
        %   given a non-zero number of rows, the variables will be filled
        %   with default values. For variable types whose default value
        %   does not exist, it will be filled with empty instances of the
        %   given type.
        %
        %   Timetables can contain variables that are built-in types, or objects that
        %   are arrays and support standard MATLAB parenthesis indexing of the form
        %   var(i,...), where i is a numeric or logical vector that corresponds to rows
        %   of the variable. In addition, the array must implement a SIZE method with a
        %   DIM argument, and a VERTCAT method.
        %
        %   Examples:
        %   
        %      % Create a timetable from individual workspace variables. Notice that the
        %      % name of the timetable's row times vector is the same as the workspace variable.
        %      MeasurementTime = datetime({'2015-12-18 08:03:05';'2015-12-18 10:03:17';'2015-12-18 12:03:13'});
        %      Temp = [37.3;39.1;42.3];
        %      Pressure = [30.1;30.03;29.9];
        %      WindSpeed = [13.4;6.5;7.3];
        %      WindDirection = categorical({'NW';'N';'NW'});
        %      TT = timetable(MeasurementTime,Temp,Pressure,WindSpeed,WindDirection)
        %      
        %      % Create a timetable using duration row time instead of datetimes.
        %      ElapsedTime = seconds([7385;14597;21793]);
        %      TT = timetable(ElapsedTime,Temp,Pressure,WindSpeed,WindDirection)
        %      
        %      % Create a timetable using the RowTimes parameter. Notice that the name
        %      % of the timetable's row times vector is the default, 'Time'.
        %      TT = timetable(Temp,Pressure,WindSpeed,WindDirection,'RowTimes',MeasurementTime)
        %
        %      % Create a timetable from a table.
        %      T = table(Temp,Pressure,WindSpeed,WindDirection)
        %      TT = table2timetable(T,'RowTimes',MeasurementTime)
        %
        %      % Create a timetable from columns of one numeric matrix.
        %      data = cumsum(randn(25,4),1);
        %      TT = array2timetable(data,'VariableNames',{'X' 'Y' 'Z1' 'Z2'},'RowTimes',datetime(2016,11,1:25))
        %
        % See also TABLE2TIMETABLE, ARRAY2TIMETABLE.
            import matlab.internal.datatypes.isCharStrings
            import matlab.internal.datatypes.isIntegerVals
            import matlab.internal.tabular.validateTimeVectorParams
        
            if nargin == 0
                % Nothing to do
            else
                % Parse the optional params from the right end. The number of
                % data inputs is what's left on the left end. A char row vector
                % or a scalar string that is intended to be a data input may
                % be interpreted as a parameter name in unlucky cases.
                pnames = {'Size' 'VariableTypes' 'VariableNames'  'RowTimes' 'SamplingRate'  'TimeStep'   'StartTime'};
                dflts =  {    []              {}              {}          []            []           []    seconds(0)};
                partialMatchPriority = [0 0 1 0 0 0 0]; % prioritize VariableNames when partial matching for backwards compatibility
                [numVars,sz,vartypes,varnames,rowtimes,samplingRate,timeStep,startTime,supplied] ...
                    = matlab.internal.datatypes.reverseParseArgs(pnames,dflts,partialMatchPriority,varargin{:}); 

                [rowtimesDefined,rowtimes,startTime,timeStep,samplingRate] = validateTimeVectorParams(supplied,rowtimes,startTime,timeStep,samplingRate);

                if supplied.Size % preallocate from specified size and var types
                    if numVars > 0
                        % If using 'Size' parameter, cannot have data variables as inputs
                        error(message('MATLAB:table:InvalidSizeSyntax'));                    
                    elseif ~isIntegerVals(sz,0) || ~isequal(numel(sz),2)
                        error(message('MATLAB:table:InvalidSize'));
                    end
                    sz = double(sz);
                    
                    if sz(2) == 0
                        % If numVars is 0, vartypes can be empty
                        if ~isequal(numel(vartypes),0)
                            error(message('MATLAB:table:SizeMismatch'))
                        end
                    elseif ~supplied.VariableTypes && (sz(2) > 0)
                        error(message('MATLAB:table:MissingVariableTypes'));
                    elseif ~isCharStrings(vartypes,true) % require cellstr
                        error(message('MATLAB:table:InvalidVariableTypes'));
                    elseif ~isequal(sz(2), numel(vartypes))
                        error(message('MATLAB:table:SizeMismatch'))
                    elseif ~rowtimesDefined
                        % RowTimes, TimeStep, or SamplingRate must be provided
                        % in the preallocation syntax.
                        error(message('MATLAB:timetable:NoTimeVectorPreallocation'));
                    end
                    
                    numRows = sz(1); numVars = sz(2);
                    vars = tabular.createVariables(vartypes,sz);
                    
                    if supplied.TimeStep
                        rowtimes = t.rowDim.regularRowTimesFromTimeStep(startTime,timeStep,numRows);
                    elseif supplied.SamplingRate
                        rowtimes = t.rowDim.regularRowTimesFromSamplingRate(startTime,samplingRate,numRows);
                    end
                    
                    if ~supplied.VariableNames
                        % Create default var names, which never conflict with
                        % the default row times name.
                        varnames = t.varDim.dfltLabels(1:numVars);
                    end
                    
                else % create from data variables
                    if supplied.VariableTypes
                        % VariableTypes may not be supplied with data variables
                        error(message('MATLAB:table:IncorrectVariableTypesSyntax'));
                    end
                    
                    % Count number of rows and check each data variable
                    vars = varargin(1:numVars);
                    numRows = tabular.verifyCountVars(vars);

                    % Throw a warning if data contains scalar text that
                    % exactly matches a name-value pair name.
                    tabular.warnIfAmbiguousText(vars,numRows,pnames);
                    
                    if ~supplied.VariableNames
                        % Get the workspace names of the input arguments from inputname if
                        % variable names were not provided. Need these names before looking
                        % through vars for the time vector.
                        varnames = repmat({''},1,numVars);
                        for i = 1:numVars, varnames{i} = inputname(i); end
                    end
                
                    if rowtimesDefined 
                        rowtimesName = {}; % use the default name
                        if supplied.RowTimes
                            if numVars == 0
                                % Create an Nx0 timetable as tall as the specified row times
                                numRows = length(rowtimes);
                            end
                        elseif supplied.TimeStep
                            rowtimes = t.rowDim.regularRowTimesFromTimeStep(startTime,timeStep,numRows);
                        else % supplied.SamplingRate
                            rowtimes = t.rowDim.regularRowTimesFromSamplingRate(startTime,samplingRate,numRows);
                        end
                    else
                        % Neither RowTimes, TimeStep, nor SamplingRate was specified, get the row times from first data arg
                        rowtimes = vars{1};
                        if ~isdatetime(rowtimes) && ~isduration(rowtimes) || ~isvector(rowtimes)
                            if numVars == 1 && matlab.internal.datatypes.istabular(vars{1})
                                error(message('MATLAB:timetable:NoTimeVectorTableInput'));
                            else
                                error(message('MATLAB:timetable:NoTimeVector'));
                            end
                        end
                        vars(1) = [];
                        numVars = numVars - 1; % don't count time index in vars

                        if ~supplied.VariableNames
                            rowtimesName = varnames{1};
                            varnames(1) = [];
                        else % if supplied.VariableNames && ~supplied.RowTimes
                            % get the row times name from the first input
                            rowtimesName = inputname(1);
                        end

                        if ~isempty(rowtimesName)
                            % If the rows times came from a data input (not from the
                            % RowTimes param), and var names were not provided, get the
                            % row dim name from the inputs. Otherwise, leave the default
                            % row dim name alone.
                            t.metaDim = t.metaDim.setLabels(rowtimesName,1);
                        end
                    end
                    
                    if ~supplied.VariableNames
                        % Fill in default names for data args where inputname couldn't. Do
                        % this after removing the time vector from the other vars, to get the
                        % default names numbered correctly.
                        empties = cellfun('isempty',varnames);
                        if any(empties)
                            varnames(empties) = t.varDim.dfltLabels(find(empties)); %#ok<FNDSB>
                        end
                        % Make sure default names or names from inputname don't conflict.
                        % In this case, both the var names and the row times name are being
                        % detected from the input variable names. Uniqueify duplicates by
                        % appending to the duplicate names
                        varnames = matlab.lang.makeUniqueStrings(varnames,rowtimesName,namelengthmax);
                    end
                end
                t = t.initInternals(vars, numRows, rowtimes, numVars, varnames);
                
                % Detect conflicts between the var names and the default dim names.
                t.metaDim = t.metaDim.checkAgainstVarLabels(varnames);
            end
        end
    end

    
    methods(Hidden, Static)
        function t = empty(varargin)
        %EMPTY Create an empty table.
        %   T = TIMETABLE.EMPTY() creates a 0x0 timetable.
        %
        %   T = TIMETABLE.EMPTY(NROWS,NVARS) or T = TIMETABLE.EMPTY([NROWS NVARS]) creates
        %   an NROWSxNVARS timetable.  At least one of NROWS or NVARS must be zero. If
        %   NROWS is positive, T's time vector contains NaTs.
        %
        %   See also TIMETABLE, ISEMPTY.
            if nargin == 0
                t = timetable();
            else
                sizeOut = size(zeros(varargin{:}));
                if prod(sizeOut) ~= 0
                    error(message('MATLAB:timetable:empty:EmptyMustBeZero'));
                elseif length(sizeOut) > 2
                    error(message('MATLAB:timetable:empty:EmptyMustBeTwoDims'));
                else
                    % Create a 0x0 timetable, and then resize to the correct number
                    % of rows or variables.
                    t = timetable();
                    if sizeOut(1) > 0
                        t.rowDim = t.rowDim.lengthenTo(sizeOut(1));
                    end
                    if sizeOut(2) > 0
                        t.varDim = t.varDim.lengthenTo(sizeOut(2));
                        t.data = cell(1,sizeOut(2)); % assume double
                    end
                end
            end
        end
        
        % Called by cell2timetable, struct2timetable
        function t = fromScalarStruct(s)
            % This function is for internal use only and will change in a
            % future release.  Do not use this function.
            
            % Construct a timetable from a scalar struct
            vnames = fieldnames(s);
            p = length(vnames);
            if p > 0
                n = unique(structfun(@(f)size(f,1),s));
                if ~isscalar(n)
                    error(message('MATLAB:table:UnequalFieldLengths'));
                end
            else
                n = 0;
            end
            t = timetable.init(struct2cell(s)',n,{},p,vnames);
        end
        
        function t = init(vars, numRows, rowLabels, numVars, varnames, varDimName)
            % INIT creates a timetable from data and metadata.  It bypasses the input parsing
            % done by the constructor, but still checks the metadata.
            % This function is for internal use only and will change in a future release.  Do not
            % use this function.
            t = timetable();
            t = t.initInternals(vars, numRows, rowLabels, numVars, varnames);
            if nargin == 6
                t.metaDim = t.metaDim.setLabels(varDimName,2);
            end
        end
    end % hidden static methods block
    
    methods(Access = 'protected')  
        function b = cloneAsEmpty(a)            
        %CLONEASEMPTY Create a new empty table from an existing one.
%             if strcmp(class(a),'timetable') %#ok<STISA>
                b = timetable();
                b.rowDim = a.rowDim.selectFrom([]);
%             else % b is a subclass of timetable
%                 b = a; % respect the subclass
%                 % leave b.metaDim alone;
%                 b.rowDim = b.rowDim.createLike(0);
%                 b.varDim = b.varDim.createLike(0);
%                 b.data = cell(1,0);
%                 leave b.arrayProps alone
%             end
        end
        
        function errID = throwSubclassSpecificError(obj,msgid,varargin)
            % Throw the timetable version of the msgid error, using varargin as the
            % variables to fill the holes in the message.
            errID = throwSubclassSpecificError@tabular(obj,['timetable:' msgid],varargin{:});
            if nargout == 0
                throwAsCaller(errID);
            end
        end
        
        function rowLabelsStruct = summarizeRowLabels(t)
            % SUMMARIZEROWLABELS is called by summary method to get a struct containing
            % a summary of the row labels. For timetable, this includes size, type,
            % min, median, max, NumMissing, time step.
            rowTimes = t.rowDim.labels;

            rowLabelsStruct.Size = size(rowTimes);
            rowLabelsStruct.Type = class(rowTimes);

            % We always want to work by column, and also ignore NaN/NaT.
            rowLabelsStruct.Min = min(rowTimes,[],1,'omitnan'); 
            rowLabelsStruct.Median = median(rowTimes,1,'omitnan'); 
            rowLabelsStruct.Max = max(rowTimes,[],1,'omitnan');

            % Missing values count
            nummissing = sum(ismissing(rowTimes),1);
            rowLabelsStruct.NumMissing = nummissing;
            
            % Time Step
            [~, tstep] = isregular(t);
            rowLabelsStruct.TimeStep = tstep;
        end
        
        function printRowLabelsSummary(t,rowLabelsStruct)
            % PRINTROWLABELSSUMMARY is called by summary method to print the row labels
            % summary.            
            fprintf('RowTimes:\n');
            if (strcmp(matlab.internal.display.formatSpacing,'loose')), fprintf('\n'); end
            
            if matlab.internal.display.isHot
                varnameFmt = '<strong>%s</strong>';
            else
                varnameFmt = '%s';
            end

            % Print size and type, and remove from struct
            szStr = [sprintf('%d',rowLabelsStruct.Size(1)) sprintf([matlab.internal.display.getDimensionSpecifier,'%d'],rowLabelsStruct.Size(2:end))];

            fprintf(['    ' varnameFmt ': %s %s\n'], t.metaDim.labels{1}, szStr, rowLabelsStruct.Type);
            rowLabelsStruct = rmfield(rowLabelsStruct,{'Size','Type'});

            % Remove unwanted fields for display
            if ~rowLabelsStruct.NumMissing
                rowLabelsStruct = rmfield(rowLabelsStruct,'NumMissing');
            end
            if isnan(rowLabelsStruct.TimeStep)
                rowLabelsStruct = rmfield(rowLabelsStruct,'TimeStep');
            end

            % Create and print table from remaining struct
            labels = fieldnames(rowLabelsStruct);
            values = struct2cell(rowLabelsStruct);

            if ~isempty(rowLabelsStruct.Min)
                % Standardize the cell array to be of character vectors
                values = cellfun(@toText,values,'UniformOutput',false);

                vt = cell2table(values,'RowNames',labels,'VariableNames',t.metaDim.labels(1)); %#ok<NASGU>
                c = evalc('disp(vt,false,12)');
                c = strrep(c, '''', ' '); % Remove the single quotes from cell display

                lf = newline;
                firstTwoLineFeeds = find(c==lf,2,'first');
                c(1:firstTwoLineFeeds(end)) = [];

                fprintf('        Values:\n');
                fprintf('%s',c);
            end
            
        end
    end % protected methods block

    %%%% PERSISTENCE BLOCK ensures correct save/load across releases %%%%%%
    %%%% Properties and methods in this block maintain the exact class %%%%
    %%%% schema required for TIMETABLE to persist through MATLAB releases %    
    properties(Constant, Access='protected')
        % Version of this timetable serialization and deserialization
        % format. This is used for managing forward compatibility. Value is
        % saved in 'versionSavedFrom' when an instance is serialized.
        %
        %   2.0 : 16b. first shipping version
        %   3.0 : 17a. added varDescriptions and varUnits fields to preserve
        %              VariableDescriptions and VariableUnits Properties.
        %   3.1 : 17b. added varContinuity to preserve VariableContinuity property.
        %   3.2 : 18a. added serialized field 'incompatibilityMsg' to support 
        %              customizable 'kill-switch' warning message. The field
        %              is only consumed in loadobj() and does not translate
        %              into any timetable property.
        version = 3.2;
    end
    
    methods(Hidden)
        function tt_serialized = saveobj(tt)
            % SAVEOBJ must maintain that all ingredients required to recreate
            % a valid TIMETABLE in this and previous version of MATLAB are 
            % present and valid in TT_SERIALIZED; any new ingredients needed
            % by future version are created in that version's LOADOBJ.
            % New ingredients MUST ONLY be saved as new fields in TT_SERIALIZED,
            % rather than as modifications to existing fields
            tt_serialized = struct;
            tt_serialized = tt.setCompatibleVersionLimit(tt_serialized, 2.0);
            
            tt_serialized.arrayProps = tt.arrayProps;     % scalar struct. Two fields holding timetable Description & UserData Properties
            tt_serialized.data       = tt.data;           % 1-by-numVars cell vector. Each cell corresponds to data from one variable
            tt_serialized.numDims    = tt.metaDim.length; % scalar double. Number of dimensions
            tt_serialized.dimNames   = tt.metaDim.labels; % 1-by-numDims cell of char vector. Names of each dimension
            tt_serialized.numRows    = tt.rowDim.length;  % scalar double. Number of rows
            tt_serialized.rowTimes   = tt.rowDim.labels;  % numRows-by-1 datetime or duration (must exist). Time of each row of data
            tt_serialized.numVars    = tt.varDim.length;  % scalar double. Number of variables
            tt_serialized.varNames   = tt.varDim.labels;  % 1-by-numVars cell of char vector. Names, if any, of each variable
            tt_serialized.varDescriptions = tt.varDim.descrs; % 1-by-numVars cell of char vector. User specified description, if any, of each variable
            tt_serialized.varUnits   = tt.varDim.units;   % 1-by-numVars cell of char vector. User specified unit, if any, of each variable
            
            if isenum(tt.varDim.continuity)
                tt_serialized.varContinuity = cellstr(tt.varDim.continuity);
            else
                tt_serialized.varContinuity = {};  % [] saved as {}
            end
        end
    end
    
    methods(Hidden, Static)
        function tt = loadobj(tt_serialized)
            % LOADOBJ has knowledge of the ingredients needed to create a
            % TIMETABLE in the current version of MATLAB from a MAT file
            % saved in either the current or previous version; a MAT file 
            % created in a future version of MATLAB will have any new
            % ingredients unknown to the current version as fields of the 
            % TT_SERIALIZED struct, but those are never accessed here

            % Always default construct an empty timetable, and recreate a
            % proper timetable in the current schema using attributes
            % loaded from the serialized struct            
            tt = timetable();
            
            % Handle cases where variables data fail to load correctly
            tt_serialized = tabular.handleFailedToLoadVars(tt_serialized, tt_serialized.numRows, tt_serialized.numVars, tt_serialized.varNames);
            
            % Return an empty instance if current version is below the
            % minimum compatible version of the serialized object
            if tt.isIncompatible(tt_serialized, 'MATLAB:timetable:IncompatibleLoad')
                return;
            end
            
            % Restore core data
            tt.data = tt_serialized.data;

            % Avoid calling setDescription and setUserData for performance, as their values
            % are ASSUMED to be valid coming from a MAT file
            tt.arrayProps.Description = tt_serialized.arrayProps.Description;
            tt.arrayProps.UserData    = tt_serialized.arrayProps.UserData;
            
            % Restore meta-dimension & metaData
            tt.metaDim = tt.metaDim.init(tt_serialized.numDims, tt_serialized.dimNames);
           
            % Restore row-dimension & metaData
            if isstruct(tt_serialized.rowTimes) % Optimized rowTimes is saved, expand into a full time vector in this version
                % An optimized rowTimes struct should have these fields:
                %     origin  : scalar datetime or duration. Start of the regularly spaced time vector
                %     stepSize: scalar duration. Time step of the regularly spaced time vector
                rowTimes = tt_serialized.rowTimes.origin + ( 0:tt_serialized.rowTimes.stepSize:tt_serialized.rowTimes.stepSize*(tt_serialized.numRows-1) );
            else
                rowTimes = tt_serialized.rowTimes;
            end
            tt.rowDim = tt.rowDim.init(tt_serialized.numRows, rowTimes);

            % Restore variable-dimension & metaData
            if tt_serialized.versionSavedFrom >= 3.1
                %Continuity was added at 3.1
                tt.varDim = tt.varDim.init(tt_serialized.numVars, ...
                                           tt_serialized.varNames, ...
                                           tt_serialized.varDescriptions, ...
                                           tt_serialized.varUnits, ...
                                           tt_serialized.varContinuity);
            elseif tt_serialized.versionSavedFrom == 3.0
                tt.varDim = tt.varDim.init(tt_serialized.numVars, ...
                                           tt_serialized.varNames, ...
                                           tt_serialized.varDescriptions, ...
                                           tt_serialized.varUnits);
            else
                % varDescriptions & varUnits are not present in MAT file 
                % saved from timetable below version 3.0
                tt.varDim = tt.varDim.init(tt_serialized.numVars, ...
                                           tt_serialized.varNames);
            end                
        end
    end
end

%-------------------------------------------------------------------------------
function names = dfltTimetableDimNames()
names = { getString(message('MATLAB:timetable:uistrings:DfltRowDimName')) ...
          getString(message('MATLAB:timetable:uistrings:DfltVarDimName')) };
end

%-------------------------------------------------------------------------------
function c = toText(x)
if isnumeric(x)
	c = num2str(x);
else % datetime/duration
    c = char(x);
end
end

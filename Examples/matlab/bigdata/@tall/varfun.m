function b = varfun(fun, a, varargin)
%VARFUN Apply a function to each variable of a table or a timetable.
%   B = VARFUN(FUN,A)
%   B = VARFUN(FUN,A,'PARAM1',val1,'PARAM2',val2,...)
%
%   Supported parameters:
%   'InputVariables' - numeric, char, cellstr, or logical vector only.
%   'OutputFormat' - 'uniform', 'table', 'timetable', or 'cell' only.
%
%   Limitations:
%   1) FUN must always return a tall array.
%   2) 'InputVariables' cannot be specified as a function_handle.
%   3) When A is a tall timetable, and 'OutputFormat' is 'timetable', FUN must
%   return an array with the same size in the first dimension as the
%   input. Specify 'OutputFormat' as 'table' when FUN is a reduction function
%   such as MEAN.
%
%   See also table/varfun.

% Copyright 2016-2017 The MathWorks, Inc.

% Input checking - 'a' must be tall, others not.
thisFcn = upper(mfilename);
tall.checkIsTall(thisFcn, 1, a);
tall.checkNotTall(thisFcn, 1, varargin{:});
tall.checkNotTall(thisFcn, 0, fun);

if ~isa(fun,'function_handle')
    error(message('MATLAB:table:varfun:InvalidFunction'));
end
funName = func2str(fun);

% 'a' must be a tall table
a = tall.validateType(a, mfilename, {'table', 'timetable'}, 1);
aVarNames = subsref(a, substruct('.', 'Properties', '.', 'VariableNames'));

if strcmp(tall.getClass(a), 'table')
    defaultFmt = 'table';
else
    defaultFmt = 'timetable';
end
pnames = {'GroupingVariables' 'InputVariables' 'OutputFormat'   'ErrorHandler'};
dflts =  {                []               []     defaultFmt               [] };
[~,dataVars,outputFormat,~,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

if supplied.GroupingVariables
    error(message('MATLAB:bigdata:array:VarfunUnsupportedParameter', 'GroupingVariables'));
end
if supplied.ErrorHandler
    error(message('MATLAB:bigdata:array:VarfunUnsupportedParameter', 'ErrorHandler'));
end

if supplied.InputVariables
    % tall/varfun doesn't support function handles for 'InputVariables'
    if isa(dataVars, 'function_handle')
        error(message('MATLAB:bigdata:array:VarfunUnsupportedInputVarsFcn'));
    end
    try
        dataVars = matlab.bigdata.internal.util.resolveTableVarSubscript(...
            aVarNames, dataVars);
    catch E
        throw(E);
    end
else
    dataVars = aVarNames;
end

outputFormat = iResolveOutputFormat(supplied.OutputFormat, outputFormat, defaultFmt);

% Apply the function to each variable in turn creating cell array b_data.
ndataVars = numel(dataVars);
b_data = cell(1, ndataVars);
for jvar = 1:ndataVars
    varname_j = dataVars{jvar};
    varData   = subsref(a, substruct('.', varname_j));
    try
        b_data{jvar} = fun(varData);
    catch E
        % Note of course that this 'catch' block is only hit for client-side
        % errors. Execution-time errors will not be wrapped, and will result in
        % just the underlying error. There's not much we can do about that since
        % we don't know what type of operation 'fun' represents.
        error(message('MATLAB:table:varfun:FunFailed', funName, varname_j, E.message));
    end
    if ~istall(b_data{jvar})
        error(message('MATLAB:bigdata:array:VarfunFunReturnedNonTall', funName));
    end
end

% Set up the output in the specified format.
switch outputFormat
  case 'uniform'
    if ndataVars > 0
        for idx = 1:ndataVars
            b_data{idx} = lazyValidate(b_data{idx}, {@isscalar, ...
                                'MATLAB:table:varfun:NotAScalarOutput', funName, dataVars{idx}});
        end
        [b_data{1:ndataVars}] = elementfun(@(varargin) iCheckOutputTypes(funName, dataVars, varargin{:}), ...
                                           b_data{1:ndataVars});
        b = [b_data{:}];
    else
        b = tall.createGathered(zeros(1,0));
    end
  case {'table', 'timetable'}
    for idx = 1:ndataVars
        b_data{idx} = lazyValidate(b_data{idx}, {@(x) ~ischar(x) || ~isrow(x), ...
                            'MATLAB:table:varfun:CharRowFunOutput'});
    end
    if ~isvarname(funName), funName = 'Fun'; end
    b_varnames = matlab.internal.tabular.makeValidVariableNames(...
        strcat(funName,{'_'},dataVars),'warn');
    if strcmp(outputFormat,'table')
        if ndataVars > 0
            b = table(b_data{:}, 'VariableNames', b_varnames);
        else
            b = tall.createGathered(table.empty(0, 0));
        end
    else
        if ndataVars > 0
            dimNames = subsref(a, substruct('.', 'Properties', '.', 'DimensionNames'));
            rt = subsref(a, substruct('.', 'Properties', '.', 'RowTimes'));
            szMismatchException = MException(message(...
                'MATLAB:bigdata:array:VarfunTimetableSizeMismatch', funName));
            b = makeTallTimetableWithDimensionNames(dimNames, rt, b_varnames, ...
                                                    szMismatchException, b_data{:});
        else
            b = tall.createGathered(timetable.empty(0, 0));
        end
    end
  case 'cell'
    if ndataVars > 0
        % Note that using 'OutputFormat' == 'cell' on unreduced data is probably a
        % mistake since we are required to make a single cell for each tall
        % array.
        b = clientfun(@(varargin) varargin, b_data{:});
        % The cell array output is always 1-by-ndataVars, so we can fully specify the
        % output adaptor.
        b.Adaptor = setKnownSize(matlab.bigdata.internal.adaptors.getAdaptorForType('cell'), ...
                                 [1, ndataVars]);
    else
        b = tall.createGathered(cell(1,0));
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Type check derived from tabular/varfun>horzcatWithUniformScalarCheck
function varargout = iCheckOutputTypes(funName, dataVars, varargin)

varargout = varargin;
for idx = 1:numel(varargin)
    if idx == 1
        uniformClass = class(varargin{idx});
    else
        if ~isa(varargin{idx}, uniformClass)
            c = class(varargin{idx});
            error(message('MATLAB:table:varfun:MismatchInOutputTypes',...
                          funName, c, uniformClass, dataVars{idx}));
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outputFormat = iResolveOutputFormat(outputFormatSupplied, outputFormat, defaultOutputFormat)
allowedOutputFormats = {'uniform', 'table', 'cell', 'timetable'};
if outputFormatSupplied
    if isempty(outputFormat)
        error(message('MATLAB:table:varfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
    outputFormat = find(strncmpi(outputFormat,allowedOutputFormats,length(outputFormat)));
    
    if isempty(outputFormat) || ~isscalar(outputFormat)
        error(message('MATLAB:table:varfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
    outputFormat = allowedOutputFormats{outputFormat};
else
    outputFormat = defaultOutputFormat;
end
end

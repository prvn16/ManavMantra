function varargout = makeimportcode(varargin)
% This undocumented function may change in a future release.

%MAKEIMPORTCODE Generates readable code based on input argument
%
%  MAKEIMPORTCODE(PARAMS) Generates code for importing data from a file 
%               (or the clipboard) using the specified parameters, and
%               displays the code in the desktop editor.
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-editor')  Display code in the
%               desktop editor
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-string') Output code as a 
%                string variable
%
%  MAKEIMPORTCODE(PARAMS,'Output', FILENAME) Output code as a file
%
%   Copyright 2006-2015 The MathWorks, Inc.

% Fields for PARAMS
% --------
% REQUIRED:
% hasInputArg - logical
% hasOutputArg - logical
% needsStructurePatch - logical
% loadFunc - double.  One of...
%     0 = IMPORTDATA
%     1 = LOAD -MAT
%     2 = LOAD -ASCII
%     3 = LOAD -XL
% outputBreakup - double.  One of...
%     0 = "normal"
%     1 = "by Column"
%     2 = "by Row"
% unpackXLSdata - logical
% unpackXLStextdata - logical
% unpackXLScolheaders - logical
% unpackXLSrowheaders - logical

%
% OPTIONAL:
% delimiter - char (ignored if loadFunc ~= 0)
% headerLines - double (ignored if loadFunc ~= 0)
% worksheetName - char (ignored if loadFunc ~= 3)
 
% Check arguments.
checkArguments(varargin)
% Strip away unnecessary arguments, and add some new, calculated 
% parameters for later use.
params = adjustParams(varargin{1});
% Generate the basic function code.
hFunc = localGenCode(params);
% Add it to a codeprogram.
hProgram = codegen.codeprogram;
hProgram.addSubFunction(hFunc);
% Configure the output options, and use them to generate the code.
options = configureOptions(varargin);
strCells = hProgram.toMCode(options);
% Output the generated code in the requested style, possibly returning it.
out = handleGeneratedCode(options, generateCodeString(strCells));
if ~isempty(out)
    varargout{1} = out;
end

%-------------------------------
function checkArguments(args)
if isempty(args)
    error(message('MATLAB:codetools:makeimportcode:InsufficientArguments'));
end
if rem(length(args), 2) ~= 1
    error(message('MATLAB:codetools:makeimportcode:ArgumentsMustBeOdd'));
end
if ~isstruct(args{1})
    error(message('MATLAB:codetools:makeimportcode:FirstArgMustBeStruct'));
end
for i = 2:length(args)
    if ~ischar(args{i})
        error(message('MATLAB:codetools:makeimportcode:ArgsMustBeChars'));
    end
end

%-------------------------------
function params = adjustParams(params)
params.LOADMAT = params.loadFunc == 1;
params.LOADASCII = params.loadFunc == 2;
params.LOADXL = params.loadFunc == 3;
params.IMPORTDATA = ~params.LOADMAT && ~params.LOADASCII && ~params.LOADXL;
if (~params.IMPORTDATA)
    if isfield(params, 'delimiter')
        params = rmfield(params, 'delimiter');
    end
    if isfield(params, 'headerLines')
        params = rmfield(params, 'headerLines');
    end
end

%-------------------------------
function options = configureOptions(args)
options.Output = '-editor';
options.OutputTopNode = false;
options.ReverseTraverse = false;
options.ShowStatusBar = false;
options.MFileName = '';
if length(args) > 2
    for i = 2:(length(args)-1)
        if strcmpi(args{i}, 'Output')
            options.Output = args{i+1};
        end
    end
    if ( ~strcmp(options.Output,'-editor') && ...
            ~strcmp(options.Output,'-string') && ...
            ~strcmp(options.Output,'-cmdwindow') )
        [~, file] = fileparts(options.Output);
        options.MFileName = file;
    end
end

%-------------------------------
function str = generateCodeString(strCells)
str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')]; %#ok<AGROW>
end

%-------------------------------
function hFunc = localGenCode(params)

hFunc = codegen.coderoutine;

hFunc.Name = 'importfile';
if params.hasInputArg
    hFunc.Comment = getString(message('MATLAB:codetools:private:makeimportcode:ImportsDataFromSpecifiedFile'));
else
    hFunc.Comment = getString(message('MATLAB:codetools:private:makeimportcode:ImportsDataFromSystemClipboard'));
end

hInputArg = generateInputArg(params.hasInputArg);
if (params.hasInputArg)
    hFunc.addArgin(hInputArg);
end
    
hOutputArg = generateOutputArgForImport;
importTheData(hFunc, params, hInputArg, hOutputArg);

if params.needsStructurePatch
    hOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg);
end

if (params.LOADXL)
    createXLNewVariables(hFunc, hOutputArg, params.unpackXLScolheaders, params.unpackXLSrowheaders, params.outputBreakup);
    if params.outputBreakup ~= 0
        hNewOutput=changeOutputBreakup(hFunc, hOutputArg, params);
    else
        hNewOutput=hOutputArg;
    end
    if params.hasOutputArg == 0
        createWorkspace(hFunc, hOutputArg, params.outputBreakup);
    else
        createXLOutput(hFunc, hNewOutput, hOutputArg, params.outputBreakup);
    end
    generateXLOutputHandling(hFunc, params.hasOutputArg, hNewOutput);
else
    if params.outputBreakup ~= 0
        hNewOutput=changeOutputBreakup(hFunc, hOutputArg, params);
    else
        hNewOutput=hOutputArg;
    end
    if params.hasOutputArg == 0
        createWorkspace(hFunc, hOutputArg, params.outputBreakup);
    end    
    generateOutputHandling(hFunc, params.hasOutputArg, hNewOutput);
end

function createXLOutput (hFunc, hNewOutput, hOutputArg, outputBreakup)
switch (outputBreakup)
    case 2
        strCreateOutputVariables = getString(message('MATLAB:codetools:private:makeimportcode:CreateOutputVariables'));
        hFunc.addText();
        hFunc.addText(sprintf('%% %s',strCreateOutputVariables));
        hFunc.addText('for i = 1:size(', hOutputArg, '.rowheaders, 1)');
        hFunc.addText('    ', hNewOutput, '.(matlab.lang.makeValidName(', hOutputArg, '.rowheaders{i})) = ', hOutputArg, '.data(i, :);');
        hFunc.addText('end');

    case 1
        strCreateOutputVariables = getString(message('MATLAB:codetools:private:makeimportcode:CreateOutputVariables'));
        hFunc.addText();
        hFunc.addText(sprintf('%% %s',strCreateOutputVariables));        
        hFunc.addText('for i = 1:size(', hOutputArg, '.colheaders, 2)');
        hFunc.addText('    ', hNewOutput, '.(matlab.lang.makeValidName(', hOutputArg, '.colheaders{i})) = ', hOutputArg, '.data(:, i);');
        hFunc.addText('end');
    
    otherwise
        % Do nothing
end

%-------------------------------
function hInputArg = generateInputArg(hasInputArg)
hInputArg = codegen.codeargument;
hInputArg.IsParameter = hasInputArg;
if hasInputArg
    hInputArg.Name = 'fileToRead';
    hInputArg.Comment = getString(message('MATLAB:codetools:private:makeimportcode:FileToRead'));
else
    hInputArg.Name = '''-pastespecial''';
    hInputArg.Comment = getString(message('MATLAB:codetools:private:makeimportcode:ReadDataFromSystemClipboard'));
    hInputArg.Value = '-pastespecial';
end

%-------------------------------
function hOut = generateOutputArgForImport
hOut = codegen.codeargument;
hOut.IsParameter = true;
hOut.IsOutputArgument = true;
hOut.Name = 'newData';

%-------------------------------
function createXLNewVariables(hFunc, hOutputArg, unpackXLScolheaders, unpackXLSrowheaders, outputBreakup)

XL_NUM = 'numbers';
XL_STR = 'strings';

hFunc.addText('if ~isempty(', XL_NUM, ')');
hFunc.addText('    ', hOutputArg, '.data = ', ' ', XL_NUM, ';');
hFunc.addText('end');

if outputBreakup == 0
    hFunc.addText('if ~isempty(', XL_STR, ')');
    hFunc.addText('    ', hOutputArg, '.textdata = ', ' ', XL_STR, ';');   
    hFunc.addText('end');
end

if unpackXLSrowheaders
    strBreakDataUpIntoOneFieldPerRow = getString(message('MATLAB:codetools:private:makeimportcode:BreakDataUpIntoOneFieldPerRow'));
    hFunc.addText('');
    hFunc.addText('if ~isempty(strings) && ~isempty(numbers)');
    hFunc.addText('    [strRows, strCols] = size(strings);');
    hFunc.addText('    [numRows, ~] = size(numbers);');    
    hFunc.addText(sprintf('    % %s',strBreakDataUpIntoOneFieldPerRow));
    hFunc.addText('    if  strCols == 1 && strRows == numRows');
    hFunc.addText('        ', hOutputArg, '.rowheaders = strings(:,end);');
    hFunc.addText('    end');
    hFunc.addText('end');
end
if unpackXLScolheaders
    strBreakDataUpIntoOneFieldPerColumn = getString(message('MATLAB:codetools:private:makeimportcode:BreakDataUpIntoOneFieldPerColumn'));
    hFunc.addText('');
    hFunc.addText('if ~isempty(strings) && ~isempty(numbers)');
    hFunc.addText('    [strRows, strCols] = size(strings);');
    hFunc.addText('    [numRows, numCols] = size(numbers);');    
    hFunc.addText('    likelyRow = size(raw,1) - numRows;'); 
    hFunc.addText(sprintf('    %% %s',strBreakDataUpIntoOneFieldPerColumn));
    hFunc.addText('    if strCols == numCols && likelyRow > 0 && strRows >= likelyRow');
    hFunc.addText('        ', hOutputArg, '.colheaders = strings(likelyRow, :);');
    hFunc.addText('    end');
    hFunc.addText('end');
end



%-------------------------------
function createWorkspace(hFunc, hOutputArg, outputBreakup)
switch (outputBreakup) 
    case 1        
        strCreateNewVariablesInBaseWorkspace = getString(message('MATLAB:codetools:private:makeimportcode:CreateNewVariablesInBaseWorkspace'));
        hFunc.addText();
        hFunc.addText(sprintf('%% %s',strCreateNewVariablesInBaseWorkspace));
        hFunc.addText('for i = 1:size(', hOutputArg, '.colheaders, 2)');
        hFunc.addText('    assignin(''base'', matlab.lang.makeValidName(', hOutputArg, '.colheaders{i}), ', hOutputArg, '.data(:,i));');
        hFunc.addText('end');
        
    case 2
        strCreateNewVariablesInBaseWorkspace = getString(message('MATLAB:codetools:private:makeimportcode:CreateNewVariablesInBaseWorkspace'));
        hFunc.addText();
        hFunc.addText(sprintf('%% %s',strCreateNewVariablesInBaseWorkspace));
        hFunc.addText('for i = 1:size(', hOutputArg, '.rowheaders, 1)');
        hFunc.addText('    assignin(''base'', matlab.lang.makeValidName(', hOutputArg, '.rowheaders{i}), ', hOutputArg, '.data(i,:));');
        hFunc.addText('end');        
        
    otherwise
        strCreateNewVariablesInBaseWorkspace = getString(message('MATLAB:codetools:private:makeimportcode:CreateNewVariablesInBaseWorkspace'));
        hFunc.addText();
        hFunc.addText(sprintf('%% %s',strCreateNewVariablesInBaseWorkspace));
        hFunc.addText('vars = fieldnames(', hOutputArg, ');');
        hFunc.addText('for i = 1:length(vars)');
        hFunc.addText('    assignin(''base'', vars{i}, ', hOutputArg, '.(vars{i}));');
        hFunc.addText('end');
end

%-------------------------------
function returnValuesAsStructure(hFunc, hOut)
hFunc.addArgout(hOut);

%-------------------------------
function importTheData(hFunc, params, hInputArg, hOutputArg)
delimiterArgument = '';
headerLinesArgument = '';
if isfield(params, 'delimiter') && (~isempty(params.delimiter))
    hFunc.addText('DELIMITER = ''', params.delimiter, ''';');
    delimiterArgument = ', DELIMITER';
    if isfield(params, 'headerLines') && (params.headerLines ~= -1)
        hFunc.addText('HEADERLINES = ', num2str(params.headerLines), ';');
        headerLinesArgument = ', HEADERLINES';
    end
    hFunc.addText('');
end

strImportTheFile = getString(message('MATLAB:codetools:private:makeimportcode:ImportTheFile'));
hFunc.addText ( sprintf ( '%% %s', strImportTheFile ) ) ;

if params.LOADXL && (isfield(params, 'worksheetName')) && ~strcmp(params.worksheetName,'')
    closing = strcat(', sheetName);') ;
else
    closing = ');' ;
end

if params.LOADMAT
    fun = 'load(''-mat'', ';
elseif params.LOADASCII
    fun = 'load(''-ascii'', ';
elseif params.LOADXL
    fun = 'xlsread(';
else
    fun = 'importdata(';
end

if params.LOADXL
    hFunc.addText('sheetName=''', params.worksheetName, ''';');
    if params.unpackXLScolheaders
        hFunc.addText('[numbers, strings, raw]', ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
    else
        hFunc.addText('[numbers, strings]', ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
    end
else
    hFunc.addText(hOutputArg, ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
end

%-------------------------------
function hNewOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg)
hOutputArg.Name = 'rawData';

hNewOutputArg = codegen.codeargument;
hNewOutputArg.IsParameter = true;
hNewOutputArg.IsOutputArgument = true;
hNewOutputArg.Name = 'newData';

strForSomeSimpleFilessuchAsACSV = getString(message('MATLAB:codetools:private:makeimportcode:ForSomeSimpleFilessuchAsACSV'));
hFunc.addText('');
hFunc.addText(sprintf(strForSomeSimpleFilessuchAsACSV));
hFunc.addText('[~,name] = fileparts(', hInputArg, ');');
hFunc.addText(hNewOutputArg, '.(matlab.lang.makeValidName(name)) = ', hOutputArg, ';');

%-------------------------------
function hOutputArg = changeOutputBreakup(hFunc, hOutputArg, params)
switch (params.outputBreakup) 
    case 1
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByColumn';
        
        if ~params.LOADXL && params.hasOutputArg ~= 0
            strBreakDataUpIntoOneFieldPerColumn = getString(message('MATLAB:codetools:private:makeimportcode:BreakDataUpIntoOneFieldPerColumn'));
            hFunc.addText('');
            hFunc.addText(sprintf('%% %s',strBreakDataUpIntoOneFieldPerColumn));
            hFunc.addText('colheaders = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(', hOutputArg ,'.colheaders), {}, namelengthmax);');
            hFunc.addText('len = size(colheaders,2);');
            hFunc.addText('for i = 1:len');
            hFunc.addText('    ', hNewOutputArg, '.(colheaders{1,i}) = ', ...
                hOutputArg, '.data(:, i);');
            hFunc.addText('end');
        end
        
		hOutputArg = hNewOutputArg;
        
    case 2
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByRow';
        
        if ~params.LOADXL && params.hasOutputArg ~= 0
            strBreakDataUpIntoOneFieldPerRow = getString(message('MATLAB:codetools:private:makeimportcode:BreakDataUpIntoOneFieldPerRow'));
            hFunc.addText('');
            hFunc.addText(sprintf('%% %s',strBreakDataUpIntoOneFieldPerRow));
            hFunc.addText('rowheaders =  matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(', hOutputArg ,'.rowheaders), {}, namelengthmax);');
            hFunc.addText('for i = 1:length(rowheaders)');
            hFunc.addText('    ', hNewOutputArg, '.(rowheaders{i}) = ', ...
                hOutputArg, '.data(i, :);');
            hFunc.addText('end');
        end
        
		hOutputArg = hNewOutputArg;
        
    otherwise
        % Do nothing
end 

%-------------------------------
function generateOutputHandling(hFunc, hasOutputArg, hOutputArg)
if hasOutputArg
    returnValuesAsStructure(hFunc, hOutputArg);
end

%-------------------------------
function generateXLOutputHandling(hFunc, hasOutputArg, hOutputArg)
if hasOutputArg
    returnValuesAsStructure(hFunc, hOutputArg);
end

%-------------------------------
function res = handleGeneratedCode(options, str)
res = '';
if strcmp(options.Output,'-cmdwindow')
    disp(str);
elseif strcmp(options.Output,'-editor')
    % Throw to command window if java is not available
    err = javachk('mwt',getString(message('MATLAB:codetools:private:makeimportcode:TheMATLABEditor')));
    if ~isempty(err)
        local_display_mcode(str,'cmdwindow');
    end
    editorDoc = matlab.desktop.editor.newDocument(str);
    editorDoc.smartIndentContents;
elseif strcmp(options.Output,'-string')
    res = str;
else
    fid = fopen(options.Output,'w');
    if(fid<0)
        error(message('MATLAB:codetools:makeimportcode:CannotSave',options.Output));
    end
    fprintf(fid,'%s',str);
    fclose(fid);
end

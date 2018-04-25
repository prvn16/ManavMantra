function varargout = uiimport(varargin)
%UIIMPORT Open Import Wizard to import data
%
%   UIIMPORT Starts the Import Wizard in the current directory.  Options to
%   load data from a file are presented.
%
%   UIIMPORT(FILENAME) Starts the Import Wizard, opening the file specified
%   in FILENAME.  The Import Wizard displays a preview of the data in the
%   file.
%
%   UIIMPORT('-file') works as above but the file selection dialog is
%   presented first.
%
%   S = UIIMPORT(...) works as above with resulting variables stored as
%   fields in the struct S.
%
%   For ASCII data, you must verify that the Import Wizard recognized the
%   column delimiter.
%
%   See also LOAD, IMPORTDATA.

%   Copyright 1984-2015 The MathWorks, Inc.

%   N.B.: This function uses undocumented java objects whose behavior will
%       change in future releases.  When using this function as an example,
%       use Java objects from the java.awt or javax.swing packages to
%       ensure forward compatibility.

import com.mathworks.mlwidgets.workspace.*;
import internal.matlab.importtool.*;

% Check for required level of Java support
if ~usejava('MWT')
    exception = MException('MATLAB:codetools:uiimport:TheImportWizardNotSupported', '%s', getString(message('MATLAB:codetools:uiimport:TheImportWizardNotSupported')));
    exception.throw ;
end

% Lock the file into memory, since it has persistent variables
% which must last for an entire (non-blocking) invocation.
mlock;

% A handle to an asynchronously-invoked instance (if any), which we can
% bring to the foreground on subsequent calls.
persistent asynchronousInstance;

isSynchronous = (nargout == 1);

% If we already have an asynchronous instance available, either use it or
% error out appropriately.

% First, call DRAWNOW to flush the Java event dispatch thread.  This is
% to ensure that any pending Cancel events are processed before we try to
% reuse an old instance.
drawnow;
if ~isempty(asynchronousInstance)
    if ~isSynchronous
        % Warning: the AWTINVOKE function may not be available in the next
        % release, or its syntax may change without warning.  Do not use the
        % AWTINVOKE function in other contexts.
        awtinvoke(asynchronousInstance, 'setVisible', true);
        asynchronousInstance.toFront;
        if nargin ~= 0
            if ~strcmp(varargin{1}, '-pastespecial')
                exception = MException('MATLAB:codetools:uiimport:alreadyOpenFile', '%s',...
                    getString(message('MATLAB:codetools:uiimport:alreadyOpenFile')));
                exception.throw ;
            else
                exception = MException('MATLAB:codetools:uiimport:alreadyOpenClipboard', '%s',...
                    getString(message('MATLAB:codetools:uiimport:alreadyOpenClipboard')));
                exception.throw ;
            end
        else
            return;
        end
    else
        % An asynchronous instance is already up, and the user is trying to
        % start a synchronous instance.  This is going to cause a lot of
        % problems.  We don't want to attach to the existing one, since the
        % synchronous version is most likely being invoked on behalf of
        % some other code.  We don't want to ignore the new request, but we
        % can't honor it intelligently, either.  Error.
        exception = MException('MATLAB:codetools:uiimport:incompatibleInstances', '%s',...
            getString(message('MATLAB:codetools:uiimport:incompatibleInstances')));
        exception.throw ;
    end
end

% ad is the primary piece of data that is shared between the primary
% function and the nested functions of this file.
ad = '';

% If the user didn't specify any input arguments, just initialize the
% Wizard contents normally.  Otherwise, figure out exactly what the user is
% requesting and act accordingly.
% this is the modified version for motw since there is no clipboard option 
% on the web
useFileDialog = false;
useClipboard = false;
if nargin == 0
    useFileDialog = true;
    if nargout > 0
        varargout = {[]};
    end
else
    if strcmp(varargin{1}, '-file')
        useFileDialog = true;
    end
end


% At this point, useFileDialog is TRUE, OR useClipboard is true, OR
% both are still false (user listed an actual file name).
fileAbsolutePath = '';
waitFrame = [];
ctorFile = [];
if useFileDialog
    fileSelected = '';    

    [fileExtDesc, fileExtList] = ImportableFileExtension.getImportToolFileChooserDropDownInfo;
    com.mathworks.mlwidgets.workspace.ImportFileChooser.setupExtensionsForDropDown(...
        getString(message('MATLAB:codetools:uiimport:RecognizedDataFilesStr')),...
        fileExtDesc,fileExtList);
    
    javaMethodEDT('showImportFileDialog', ...
        'com.mathworks.mlwidgets.workspace.ImportFileChooser', []);
    if ImportFileChooser.getState() == javax.swing.JFileChooser.APPROVE_OPTION
        fileSelected = ImportFileChooser.getSelectedFile;
    end
    if (isempty(fileSelected))
        if nargout > 0
            varargout{1} = [];
        end
        return;
    else
        fileAbsolutePath = char(fileSelected.getAbsolutePath);
    end
    type = finfo(fileAbsolutePath);
    if ishdf(fileAbsolutePath)
        hdfCleanup = filterHdfToolWarning(); %#ok<NASGU>
        hdftool(fileAbsolutePath);
        if nargout > 0
            varargout{1} = [];
        end
        return;
    end
    ctorFile = java.io.File(fileAbsolutePath);
    if ctorFile.length>1e6 && ~isSynchronous && isTextFile(fileAbsolutePath)
        waitFrame = showLargeFileWindow;
    end
elseif ~useClipboard
    fileAbsolutePath = localGetAbsolutePath(varargin{1});
    ctorFile = java.io.File(fileAbsolutePath);
    if ctorFile.length>1e6 && ~isSynchronous && isTextFile(fileAbsolutePath)
        waitFrame = showLargeFileWindow;
    end
    type = finfo(fileAbsolutePath);
    if ishdf(fileAbsolutePath)
        hdfCleanup = filterHdfToolWarning(); %#ok<NASGU>
        hdftool(fileAbsolutePath);
        if nargout > 0
            varargout{1} = [];
        end
        hideLargeFileWindow(waitFrame);
        return;
    end
    % We need to pass a lot of data to the ImportWizardContents object
    % now.  This will allow us to skip the asynchronous initialization
    % which "should" be performed by the panels that we may be skipping.

    % Gather the data, using the same function calls that the callbacks
    % would have used.

    % User specified a file.  Check to see if it exists.  If not,
    % throw an error here, rather than letting it happen later.
    if ~exist(fileAbsolutePath, 'file')
        [~, fileName, fileExt] = fileparts(fileAbsolutePath);
        if ~isempty(fileExt)
            fileName = [fileName fileExt];
        end
        exception = MException('MATLAB:codetools:uiimport:fileNotFound', '%s',...
            getString(message('MATLAB:codetools:uiimport:FileNotFound',fileName)));
        hideLargeFileWindow(waitFrame);
        exception.throw ;
    end
end


% Detect and report empty input files - display an error dialog
if (~useClipboard && ctorFile.length == 0)
    javaMethodEDT('showMessageDialog', ...
        'com.mathworks.mwswing.MJOptionPane', [], getString(message('MATLAB:codetools:uiimport:CannotImportFromEmptyFile')), getString(message('MATLAB:codetools:uiimport:ImportWizard')), 0);
    return;
end

[ctorPreviewText, ctorHeaderLines, ctorDelim] = ...
    gatherFilePreviewData(fileAbsolutePath);

% Spreadsheets are handled by the Spreadsheet Import Tool which is
% fundamentally asynchronous. Allow the synchronous operation to go ahead
% with the Import Wizard but issue a deprecation warning.
if isSynchronous && ad.isSpreadsheet
    warning(message('MATLAB:xlsread:spreadsheetSynchronous'));
end

if ( strcmp(ctorPreviewText, 'FileInterpretError')  )
    javaMethodEDT('showMessageDialog', ...
        'com.mathworks.mwswing.MJOptionPane', [], getString(message('MATLAB:codetools:uiimport:FileContainsUninterpretableData')), getString(message('MATLAB:codetools:uiimport:ImportWizard')), 0);
    hideLargeFileWindow(waitFrame);
    return;
end

if ( ~isempty(ad.datastruct) && ad.isSpreadsheet )
    sn_htable = java.util.Properties;
    sheetNameCells=textscan(ctorPreviewText,'%s','delimiter', '\n', 'whitespace','');
    internalSheetNames=iGenerateVariableName(sheetNameCells{1});
    for ij = 1:size(internalSheetNames,1)
        sn_htable.put(sheetNameCells{1}{ij},internalSheetNames{ij});
    end
    sheetName=internalSheetNames{1};
else
    ad.isSpreadsheet=false;
    sheetName='';
    internalSheetNames={};
end
[ctorVariables, ctorSizes, ctorBytes, ctorClasses, ctorColHeaders, ctorRowHeaders] = ...
    getVariableListData(sheetName);

% Create the Wizard contents, supplying all of that data.
iwc = com.mathworks.mde.dataimport.ImportWizardContents(useClipboard, ctorFile,  ...
    ctorDelim, ctorHeaderLines, ctorPreviewText, ...
    ctorVariables, ctorSizes, ctorBytes, ctorClasses, ...
    genvarnameLocal(ctorColHeaders), ...
    genvarnameLocal(ctorRowHeaders), isSynchronous, ad.isSpreadsheet);

% Create the Wizard proper.  Store a handle to it if it was launched
% asynchronously, position it nicely, etc.
wiz = javaObjectEDT('com.mathworks.widgets.wizard.WizardFrame', iwc);
if ~isSynchronous
    asynchronousInstance = wiz;
end
javaMethodEDT('setName', wiz, 'ImportWizard');
javaMethodEDT('setSize', wiz, 702, 435);
javaMethodEDT('setLocation', wiz, 200, 200);
javaMethodEDT('setVisible', wiz, true);
wizardCallbackProxy = iwc.getImportProxy;
remainPaused = true;

% Register function handles as callbacks to various events in the GUI.
hhwizardCallbackProxy = handle(wizardCallbackProxy,'callbackProperties');
set(hhwizardCallbackProxy, 'filePreviewEventCallback', @filePreview);
set(hhwizardCallbackProxy, 'multimediaEventCallback', @multimediaDisplay);
set(hhwizardCallbackProxy, 'variableListEventCallback', @variableList);
set(hhwizardCallbackProxy, 'variableListDelimiterEventCallback', @variableListDelimiter);
set(hhwizardCallbackProxy, 'variablePreviewEventCallback', @variablePreview);
set(hhwizardCallbackProxy, 'finishEventCallback', @finish);
set(hhwizardCallbackProxy, 'cancelEventCallback', @cancel);

% Notify the proxy that all registrations have been completed, so that
% it can fire any queued events.
wizardCallbackProxy.registrationCompleted;

% If the Wizard was launched asynchronously, wait for notification that it
% has been either completed or dismissed.  Once that happens, return the
% appropriate values.
newData = [];
if isSynchronous
    while getRemainPaused
        drawnow;
        pause(0.1);
    end
    varargout{1} = newData;
    releaseReferences;
end
hideLargeFileWindow(waitFrame);

% If instead the Wizard was launched asynchronously, finish execution of
% the primary function and allow control to return to the caller.  The
% @finish callback will take care of assigning the variables correctly in
% the caller's workspace.

    function filePreview(~, b)
        fileObject = b.getFile;
        fileAbsolutePath = '';
        if ~isempty(fileObject)
            fileAbsolutePath = char(fileObject.getAbsolutePath);
        end
        [description, headerLines, textDelimiter, handledElsewhere] = ...
            gatherFilePreviewData(fileAbsolutePath);

        labels = cell(1, 10);
        if ~ad.isSpreadsheet
            labels{1}=' ';
        end
        if (isstruct(ad.datastruct))
            variables=fieldnames(ad.datastruct);
        else
            variables=[];
        end

        notFound=true;
        if ad.isSpreadsheet
            numberOfSheets=size(internalSheetNames,1);
            label=sheetNameCells{1}{1};
            if (numberOfSheets == 1)
                notFound = strcmp(ctorSizes{1}, '0x0');
                if(notFound)
                    strBlank = getString(message('MATLAB:codetools:uiimport:Blank'));
                    labels{1} = strcat ( label, sprintf(' (%s)',strBlank) ) ;
                else
                    labels{1} = label ;
                end
            else
                for j = 1:numberOfSheets
                    token=internalSheetNames{j};
                    label=sheetNameCells{1}{j};
                    for i = 1:length ( variables )
                        if (isfield(ad.datastruct.(variables{i}), token)) || isfield(ad.datastruct, token)
                            notFound=false;
                            break ;
                        end
                    end

                    if(notFound)
                        strBlank = getString(message('MATLAB:codetools:uiimport:Blank'));
                        labels{j} = strcat ( label, sprintf(' (%s)',strBlank) ) ;
                    else
                        labels{j} = label ;
                    end
                    notFound=true;
                end
            end
        end
        if ~handledElsewhere
            reportFilePreview(getSource(b), description, headerLines, textDelimiter, labels);
        else
            cancel;
            drawnow;
        end
    end

    function [description, headerLines, textDelimiter, handledElsewhere] = gatherFilePreviewData(fileAbsolutePath)
        import internal.matlab.importtool.*;
        type = '';
        loadcmd = '';
        handledElsewhere = false;

        if isempty(fileAbsolutePath)
            description = clipboard('paste');
        else
            handledElsewhere = ~isempty (fileAbsolutePath) && ishdf(fileAbsolutePath);
            if handledElsewhere
                description = '';
                headerLines = '';
                textDelimiter = '';
                hdfWarnCleanup = filterHdfToolWarning(); %#ok<NASGU>
                hdftool(fileAbsolutePath);
                return;
            end
            [type, ~, loadcmd, description] = ...
                finfo(fileAbsolutePath);
        end

         description = convertToString(description);
         limit = 20000;
         limitString = getString(message('MATLAB:codetools:uiimport:TwentyThousand'));
         if (length(description) > limit)
                description = [description(1:limit) 10 10 ...
                 getString(message('MATLAB:codetools:uiimport:PreviewTruncatedAtTwentyThousandCharacters',limitString))];

         end

        % Stash the type away for use in the previewType function, so that
        % we don't have to call finfo again.  finfo is a little too
        % expensive to call repeatedly for no good reason.
        ad.type = type;
        ad.absolutePath = fileAbsolutePath;
        ad.loadcmd = loadcmd;
        ad.isSpreadsheet = any(strcmpi(type, ImportableFileExtension.getSpreadsheetFileExtensions(false)));
        [datastruct, textDelimiter, headerLines]= runImportdata(fileAbsolutePath, type);
        ad.datastruct = datastruct;

        if ( isempty(ad.datastruct) )
            ad.isSpreadsheet=false;
        end
    end

    function [datastruct, OTextDelimiter, OHeaderLines] = runImportdata(fileAbsolutePath, type, delim, hLines)
        datastruct = [];
        OTextDelimiter = ',';
        OHeaderLines = -1;
        ismat = 0;
        ad.codegen.hasInputArg = ~isempty(fileAbsolutePath);
        if isempty(fileAbsolutePath)
            fileAbsolutePath = '-pastespecial';
        end
        ad.codegen.loadFunc = 0;
        if strcmp(type, 'mat')
            try
                % check if this is a binary mat file
                datastruct = load('-mat', fileAbsolutePath);
                ismat = 1;
                if isempty(fieldnames(datastruct))
                    datastruct = [];
                end
                ad.codegen.loadFunc = 1;
            catch matLoadError %#ok<NASGU>
                % not a binary mat file - try using -ascii, this will
                % nearly always work because importdata should be called.
                % Use try/catch just in case
                try
                    datastruct = load('-ascii', fileAbsolutePath);
                    ad.codegen.loadFunc = 2;
                catch asciiLoadError
                    rethrow ( asciiLoadError ) ;
                end
            end
        end
        if (strcmpi('WK1', type))
            ad.codegen.loadFunc = 4;
        elseif (ad.isSpreadsheet)
            ad.codegen.loadFunc = 3;
        end
        if ~ismat && isempty(datastruct)
            xlWarningID = 'MATLAB:xlsread:Mode';
            xlWarningStatus = warning('query', xlWarningID);
            warning('off', xlWarningID);
            [lastmsg, lastID] = lastwarn;
            try
                if nargin == 2
                    % try importdata and get text delimiter if there
                    if (ad.isSpreadsheet)
                        options.Flatten = false;
                        [datastruct, OTextDelimiter, OHeaderLines] = ...
                            importdata(fileAbsolutePath,'',0,options);
                    else
                        [datastruct, OTextDelimiter, OHeaderLines] = ...
                            importdata(fileAbsolutePath);
                    end
                elseif nargin == 3
                    [datastruct, OTextDelimiter, OHeaderLines] = ...
                        importdata(fileAbsolutePath, delim);
                    ad.codegen.delimiter = delim;
                elseif nargin == 4
                    [datastruct, OTextDelimiter, OHeaderLines] = ...
                        importdata(fileAbsolutePath, delim, hLines);
                    ad.codegen.delimiter = delim;
                    ad.codegen.headerLines = hLines;
                end
                restoreWarnings(xlWarningStatus, lastmsg, lastID);
            catch unrecognizedFormatError
                % unrecognized file format
                restoreWarnings(xlWarningStatus, lastmsg, lastID);
                rethrow(unrecognizedFormatError);
            end
        end

        % Error handling code below will be rewritten at a future date.
        ad.codegen.needsStructurePatch = false;
        if ismat && isempty(datastruct)
            % empty mat file
            % Set preview to
            % 'Nothing to load. MAT-file is empty.'
        elseif isempty(datastruct)
            % can't load file
            if isempty(ad.loadcmd)
                % set preview to
                % 'Don''t know how to import this file.\n\n\tSee HELP
                % FILEFORMATS.'  and a diagnostic describing the actual
                % error.
            else
                % set preview to
                % 'File contains:' and a description of the problem.
            end
        else
            if ~isstruct(datastruct) || length(datastruct) > 1
                [~,name] = fileparts(fileAbsolutePath);
                s.(genvarnameLocal(name)) = datastruct;
                datastruct = s;
                if (~ad.isSpreadsheet)
                    ad.codegen.needsStructurePatch = true;
                end
            end
        end

        ad.codegen.unpackXLSdata = false;
        ad.codegen.unpackXLStextdata = false;
        ad.codegen.unpackXLScolheaders = false;
        ad.codegen.unpackXLSrowheaders = false;

        if isnan(OTextDelimiter)
            % If OTextdelimiter is NaN, then we've resorted to IMPORTDATA,
            % but have found that we're NOT trying to import raw text.
            % Therefore, re-initialize the variables so that the rest of
            % the Wizard knows to act properly.
            OTextDelimiter = '';
            OHeaderLines = -1;
        end
        [~, ~, x] = fileparts(fileAbsolutePath);
        if strcmpi(x, '.xls' ) || strcmpi(x, '.xlsx' ) || strcmpi(type, 'xlsm') || strcmpi(type, 'xlsb')
            if isfield(datastruct, 'data') && ...
                  isstruct(datastruct.data)
                ad.codegen.unpackXLSdata = true;
            end
            if isfield(datastruct, 'textdata') && ...
                    isstruct(datastruct.textdata)
                ad.codegen.unpackXLStextdata = true;
            end
            if isfield(datastruct, 'colheaders') && ...
                    isstruct(datastruct.colheaders)
                ad.codegen.unpackXLScolheaders = true;
            end
            if isfield(datastruct, 'rowheaders') && ...
                    isstruct(datastruct.rowheaders)
                ad.codegen.unpackXLSrowheaders = true;
            end
        end
    end

    function [variables, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData(sheetName)


        variables = [];
        if isstruct(ad.datastruct)
            variables = fieldnames(ad.datastruct);
        end

        sizes = [];
        if ~isempty(variables)
            sizes = cell(size(variables));
            for i = 1:length(variables)
                if (isfield(ad.datastruct.(variables{i}),sheetName))
                    sizes{i} = getSizeString(ad.datastruct.(variables{i}).(sheetName));
                elseif (isfield(ad.datastruct,(variables{i})))
                    sizes{i} = getSizeString(ad.datastruct.(variables{i}));
                elseif ~isempty(sheetName)
                    sizes{i} = '0x0';
                end
            end
        end

        classes = [];
        if ~isempty(variables)
            classes = cell(size(variables));
            for i = 1:length(variables)
                if (isfield(ad.datastruct.(variables{i}),sheetName))
                    classes{i} = class(ad.datastruct.(variables{i}).(sheetName));
                else
                    classes{i} = class(ad.datastruct.(variables{i}));
                end
            end
        end

        byteses = zeros(1, length(variables));
        if ~isempty(variables)
            for i = 1:length(variables)
                if (isfield(ad.datastruct.(variables{i}),sheetName))
                    myTemp = ad.datastruct.(variables{i}).(sheetName);  %#ok<NASGU>
                    whosData = whos('myTemp');
                    byteses(i) = whosData.bytes;
                elseif ~isempty(sheetName) && isstruct(ad.datastruct.(variables{i}))
                    byteses(i) = 0;
                else
                    myTemp = ad.datastruct.(variables{i}); %#ok<NASGU>
                    whosData = whos('myTemp');
                    byteses(i) = whosData.bytes;
                end
            end
        end

        colHeaders = [];
        if isfield(ad.datastruct, 'colheaders') && ...
                isfield(ad.datastruct.colheaders,sheetName)
            colHeaders = ad.datastruct.colheaders.(sheetName);
        elseif isfield(ad.datastruct, 'colheaders') && ...
              ~isstruct(ad.datastruct.colheaders)
            colHeaders = ad.datastruct.colheaders;
        end

        rowHeaders = [];
        if isfield(ad.datastruct, 'rowheaders') && ...
                isfield(ad.datastruct.rowheaders,sheetName)
            rowHeaders = ad.datastruct.rowheaders.(sheetName);
        elseif isfield(ad.datastruct, 'rowheaders') && ...
              ~isstruct(ad.datastruct.rowheaders)
            rowHeaders = ad.datastruct.rowheaders;
        end
    end

    function variableList(~, b)
        if (ad.isSpreadsheet)
            sheetName=sn_htable.get(char(getWorksheetName(b)));
        else
            sheetName='';
        end
        [variables, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData(sheetName);
        reportVariableList(getSource(b), previewType, variables, ...
            sizes, byteses, classes, colHeaders, rowHeaders, ...
            genvarnameLocal(colHeaders), ...
            genvarnameLocal(rowHeaders),char(getWorksheetName(b)));
    end

    function variableListDelimiter(~, b)
        ad.datastruct = runImportdata(ad.absolutePath, ad.type, ...
            char(getDelimiter(b)), getHeaderLines(b));
        [vars, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData('');
        reportVariableListDelimiter(getSource(b), vars, sizes, ...
            byteses, classes, colHeaders, rowHeaders, ...
            genvarnameLocal(colHeaders), genvarnameLocal(rowHeaders));
    end

    function variablePreview(~, b)
        javaVariableName = getVariableName(b);
        previewLimit = b.getSource.NUMERIC_PREVIEW_LIMIT;
        varName = char(javaVariableName);
        row = getRow(b);
        column = getColumn(b);
        if (ad.isSpreadsheet)
            sheetName=sn_htable.get(char(getSheetName(b)));
        else
            sheetName='';
        end
        COLON = com.mathworks.mde.dataimport.ImportProxy.COLON;
        if row ~= COLON
            rowInd = row;
            rowString = num2str(row);
        else
            rowInd = ':';
            rowString = ':';
        end
        if column ~= COLON
            columnInd = column;
            columnString = num2str(column);
        else
            columnInd = ':';
            columnString = ':';
        end
        fullRefName = '';
        value = [];
        if (strcmp(varName, 'colheaders') || ...
                strcmp(varName, 'rowheaders') || ...
                strcmp(varName, 'data') || ...
                strcmp(varName, 'textdata'))

            if isfield(ad.datastruct.(varName), sheetName)
                fullRefName = strcat (['ad.datastruct.' varName], '.', sheetName);
                value = ad.datastruct.(varName).(sheetName);
                if ~(row == COLON && column == COLON)
                    s.type = '()';
                    s.subs = {rowInd, columnInd};
                    value = subsref(ad.datastruct.(varName).(sheetName), s);
                end
            elseif ~isstruct(ad.datastruct.(varName))
                fullRefName = ['ad.datastruct.' varName];
                value = ad.datastruct.(varName);
                if ~(row == COLON && column == COLON)
                    s.type = '()';
                    s.subs = {rowInd, columnInd};
                    value = subsref(ad.datastruct.(varName), s);
                end
            end

        end
        if isempty(fullRefName)
            if (ad.isSpreadsheet && ~isstruct(ad.datastruct.(varName)) && isfield(ad.datastruct, varName)) || ...
                isfield(ad.datastruct, varName)
                fullRefName = ['ad.datastruct.' varName];
                value = ad.datastruct.(varName);
                if ~(row == COLON && column == COLON)
                    fullRefName = [fullRefName '(' rowString ',' ...
                                   columnString ')'];
                    s.type = '()';
                    s.subs = {rowInd, columnInd};
                    value = subsref(value, s);
                end
            end
        end
        realValue = '';
        if isnumeric(value) && isempty(value)
            realValue = '[ ]';
        end
        imagValue = '';
        if isempty(realValue)
            if numel(size(value)) == 2 && isnumeric(value)
                rowLimit = min(previewLimit, size(value,1));
                colLimit = min(previewLimit, size(value,2));
                value = value(1:rowLimit, 1:colLimit);
                realValue = real(value);
                if ~isreal(value)
                    imagValue = imag(value);
                else
                    imagValue = [];
                end
            else
                limit = 20000;
                limitString = getString(message('MATLAB:codetools:uiimport:TwentyThousand'));
                realValue = '';
                if numel(value) > limit/10
                      realValue = getString(message('MATLAB:codetools:uiimport:PreviewTooLargeToBeDisplayed'));
                end
                if isempty(realValue)
                    realValue = evalc(['disp(' fullRefName ')']);
                    if ~isempty(realValue) && length(realValue) > limit
                        realValue = [realValue(1:limit) 10 10 ...
                            getString(message('MATLAB:codetools:uiimport:PreviewTruncatedAtTwentyThousandCharacters',limitString))];
                    end
                end
            end
        end
        if (isa(realValue, 'char'))
            imagValue = '';
        end
        reportVariablePreview(getSource(b), getOwner(b), javaVariableName, ...
                              row, column, char(getSheetName(b)), realValue, imagValue);
    end

    function out = getRemainPaused
        out = remainPaused;
    end

    function setRemainPaused(in)
        remainPaused = in;
    end

    function finish(unused, b)
        origVars = stringA2charC(getOriginalNames(b));
        newVars = stringA2charC(getNewNames(b));
        newData = [];
        if (ad.isSpreadsheet)
            sheetName=sn_htable.get(char(getWorksheetName(b)));
        else
            sheetName='';
        end
        switch(getStyle(b))
            case 2
                if (isfield(ad.datastruct.colheaders, sheetName))
                    colheaders = genvarnameLocal(ad.datastruct.colheaders.(sheetName));
                else
                    colheaders = genvarnameLocal(ad.datastruct.colheaders);
                end
                for i = 1:length(newVars)
                    origName = origVars{i};
                    newName = newVars{i};
                    for j = 1:length(colheaders)
                        if strcmp(origName, colheaders{j})
                            if (isfield(ad.datastruct.colheaders, sheetName))
                                newData.(genvarnameLocal(newName)) = ...
                                    ad.datastruct.data.(sheetName)(:, j);
                            else
                                newData.(genvarnameLocal(newName)) = ...
                                    ad.datastruct.data(:, j);
                            end
                            break;
                        end
                    end
                end
            case 1
                if (isfield(ad.datastruct.rowheaders, sheetName))
                    rowheaders = genvarnameLocal(ad.datastruct.rowheaders.(sheetName));
                else
                    rowheaders = genvarnameLocal(ad.datastruct.rowheaders);
                end
                for i = 1:length(newVars)
                    origName = origVars{i};
                    newName = newVars{i};
                    for j = 1:length(rowheaders)
                        if strcmp(origName, rowheaders{j})
                            if (isfield(ad.datastruct.rowheaders, sheetName))
                                newData.(genvarnameLocal(newName)) = ...
                                    ad.datastruct.data.(sheetName)(j, :);
                            else
                                newData.(genvarnameLocal(newName)) = ...
                                    ad.datastruct.data(j, :);
                            end
                            break;
                        end
                    end
                end
            otherwise
                for i = 1:length(newVars)
                    if (ad.isSpreadsheet && isfield(ad.datastruct.(origVars{i}), sheetName))
                        newData.(genvarnameLocal(newVars{i})) = ad.datastruct.(origVars{i}).(sheetName);
                    else
                        newData.(genvarnameLocal(newVars{i})) = ad.datastruct.(origVars{i});
                    end
                end
        end

        if isSynchronous
            if getGenerateCode(b)
                generateCode(unused, b);
            end
            setRemainPaused(false);
        else
            asynchronousInstance = [];
            if ~isempty(newData)
                newVariableNames = fields(newData);
                for j = 1:length(newVariableNames)
                    assignin('caller', newVariableNames{j}, newData.(newVariableNames{j}));
                end
                if ~isempty(newVariableNames)
                    dt = javaMethod('getInstance', 'com.mathworks.mde.desk.MLDesktop');
                    statusMessage = getString(message('MATLAB:codetools:uiimport:ImportWizardCreatedVariables'));
                    if dt.hasMainFrame
                        dt.setStatusText(statusMessage);
                    else
                        disp(statusMessage);
                    end
                end
            end
            if getGenerateCode(b)
                generateCode(unused, b);
            end
            releaseReferences;
        end
    end

    function cancel(~, ~)
        setRemainPaused(false);
        if ~isSynchronous
            asynchronousInstance = [];
        end
        wiz.dispose;
        releaseReferences;
    end

    function generateCode(~, b)
        ad.codegen.hasOutputArg = isSynchronous;
        switch(getStyle(b))
            case 2
                ad.codegen.outputBreakup = 1;
            case 1
                ad.codegen.outputBreakup = 2;
            otherwise
                ad.codegen.outputBreakup = 0;
        end
        ad.codegen.worksheetName = char(getWorksheetName(b));
        makeimportcode(ad.codegen, 'output', '-editor');
    end

    function releaseReferences
        ad = '';
        newData = [];
        % The following lines are necessary to release references to
        % Java objects.
        iwc = [];
        set(hhwizardCallbackProxy, 'filePreviewEventCallback', []);
        set(hhwizardCallbackProxy, 'multimediaEventCallback', []);
        set(hhwizardCallbackProxy, 'variableListEventCallback', []);
        set(hhwizardCallbackProxy, 'variableListDelimiterEventCallback', []);
        set(hhwizardCallbackProxy, 'variablePreviewEventCallback', []);
        set(hhwizardCallbackProxy, 'finishEventCallback', []);
        set(hhwizardCallbackProxy, 'cancelEventCallback', []);
        hhwizardCallbackProxy = [];
        wizardCallbackProxy = [];
        wiz = [];
    end

    function type = previewType
        type = 0;
        if ~isempty(ad.type)
            switch getFileTypeFromExt(ad.type)
                case 'movie'
                    % if this is an avi, show a panel for preview
                    type = 1;
                case 'image'
                    % if this is an image, show a panel for preview
                    type = 2;
                case 'sound'
                    % if this is a sound, show a panel for preview
                    type = 3;
            end
        end
    end
end

%
% utility functions
%
function out = convertToString(in)
if ischar(in) || (isstring(in) && isscalar(in))
    out = char(in);
elseif iscellstr(in)
    out = '';
    for i = 1:length(in)
        out = [out char(in{i}) char(10)]; %#ok<AGROW>
    end
elseif isstring(in)
    out = char(strjoin(in, char(10)));
else
%     out = ['Unknown result of class ' class(in) ' encountered.'];
    out = getString(message('MATLAB:codetools:uiimport:UnknownResultOfClassEncountered',class(in)));
end
out = strrep(out, char([13 10]), char(10));
out = strrep(out, char(13), char(10));
end

function result = getFileTypeFromExt(inext)
if strcmp(inext, 'avi') || strcmp(inext, 'video')  
    result = 'movie';
    % finfo returns 'im' for files which are known image types (regardless of file ext)
elseif strcmp(inext, 'im')
    result = 'image';
elseif (strcmp(inext, 'wav') || ...
        strcmp(inext, 'au') || ...
        strcmp(inext, 'snd') || ...
        strcmp(inext, 'audio'))
    result = 'sound';
else
    result = '';
end
end

function out = getSizeString(in)
builtinNeeded = false;
try
    s = size(in);
catch err %#ok<NASGU>
    builtinNeeded = true;
end
if builtinNeeded || ~isa(s, 'double') || length(s) < 2
    s = builtin('size', in);
end
switch(length(s))
    case 1
        out = num2str(s(1));
    case 2
        out = [num2str(s(1)) 'x' num2str(s(2))];
    case 3
        out = [num2str(s(1)) 'x' num2str(s(2)) 'x' num2str(s(3))];
    otherwise
        out = [num2str(length(s)) '-D'];
end
end

function multimediaDisplay(~, in)
import com.mathworks.mde.dataimport.*;
file = char(getAbsolutePath(getFile(in)));
medium = getMedium(in);
switch (medium)
    case MultimediaEvent.MEDIUM_IMAGE
        imageview(file);
    case MultimediaEvent.MEDIUM_MOVIE
        movieview(file);
    case MultimediaEvent.MEDIUM_SOUND
        soundview(file);
end
end

function ret = ishdf(file)
out = [];
fid = fopen(file);
if fid ~= -1
    out = fread(fid, 4);
    fclose(fid);
end
ret = length(out) == 4 && sum(out == [14; 3; 19; 1]) == 4;
end

function in = genvarnameLocal(in)
if ~isempty(in)
    if strcmp(in, '-pastespecial')
        in = 'A_pastespecial';
    else
        in = iGenerateVariableName(in);
    end
end
end

function varName = iGenerateVariableName(S)
varName = matlab.lang.makeUniqueStrings(...
    matlab.lang.makeValidName(S), {}, namelengthmax);
end

function restoreWarnings(xlWarningStatus, lastmsg, lastID)
warning(xlWarningStatus);
lastwarn(lastmsg, lastID);
end

function hdfToolCleanup = filterHdfToolWarning
    warnState = warning('off','MATLAB:imagesci:hdftool:FunctionToBeRemoved');
    hdfToolCleanup = onCleanup(@() warning(warnState));
end

function cellOfChars = stringA2charC(stringA)
    cellOfChars = cell(size(stringA));
    for i = 1:length(stringA)
         cellOfChars{i} = char(stringA(i));
    end
end


function fileAbsolutePath = localGetAbsolutePath(fileAbsolutePath)

% We have been given an file.  Absolute, or in the current
% directory?  Let's find out...
possiblePath = which(fileAbsolutePath);
if ~isempty(possiblePath)
    % We've found it, and now have the absolute path.
    fileAbsolutePath = possiblePath;
else
    % Didn't find it yet.  Let's see if we were given only
    % the file name (no path) of an existing file.
    if exist(fileAbsolutePath, 'file') ~= 0
        possibleDir = fileparts(fileAbsolutePath);
        if isempty(possibleDir)
            % Yes, we were given a file in this directory.
            fileAbsolutePath = fullfile(pwd, ...
                fileAbsolutePath);
        else
            % We don't know what we have .  Leave it.
        end
    else
        % We were probably given an absolute path.  Leave it.
    end
end
end

function waitFrame = showLargeFileWindow()
    waitFrame = com.mathworks.mlwidgets.importtool.TextImportClient.showWaitProgressWindow();
end

function hideLargeFileWindow(waitFrame)
    if ~isempty(waitFrame)
        com.mathworks.mlwidgets.importtool.TextImportClient.hideWaitProgressWindow(waitFrame);
    end
end

function isTextFile = isTextFile(fileAbsolutePath)
    import internal.matlab.importtool.*;
    [~, ~, fileExt] = fileparts(fileAbsolutePath);
    isTextFile = any(strcmpi(fileExt,ImportableFileExtension.getTextFileExtensions));
    if ~isTextFile
        [FileType,~,~,~] = finfo(fileAbsolutePath);
        try
            % extracting video file extensions
            videoFileExt = ImportableFileExtension.getVideoFileExtensions(false);
        catch me %#ok<NASGU>
            % Ideally should not get in here. No need to throw error.
            videoFileExt = {}; 
        end
        
        try
            % Get the list of supported audio file formats
            audioFileExt = ImportableFileExtension.getAudioFileExtensions(false);
        catch me %#ok<NASGU>
            % Ideally should not get in here. No need to throw error.
            audioFileExt = {}; 
        end
        
        if any(strcmp(FileType,{'ods','avi','audio','video','im','mat'}))
            isTextFile = false;
        elseif (any(strcmp(FileType, videoFileExt))) || (any(strcmp(FileType, audioFileExt)))
            isTextFile = false;
        else
            % try to treat as hidden mat file
            try
                load('-mat',FileName);
            catch exception  %#ok<NASGU>
                isTextFile = true; % Not a known extension so try as text file
            end
        end
    end
end



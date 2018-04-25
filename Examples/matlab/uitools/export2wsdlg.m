function [hDialogout, OKPressed]=export2wsdlg(checkboxLabels, defaultVariableNames, itemsToExport, varargin)
%EXPORT2WSDLG Exports variables to the workspace. 
%   EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT)
%   creates a dialog with a series of checkboxes and edit fields.
%   CHECKBOXLABELS is a cell array of labels for the checkboxes.
%   DEFAULTVARIABLENAMES is a cell array of strings that serve as a basis
%   for variable names that appear in the edit fields. ITEMSTOEXPORT is a
%   cell array of the values to be stored in the variables. If there is
%   only one item to export, EXPORT2WSDLG creates a text control instead of
%   a checkbox. 
%
%   EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE) 
%   creates the dialog with TITLE as its title.
%
%   EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                   SELECTED) 
%   creates the dialog allowing the user to control which checkboxes are
%   checked. SELECTED is a logical array, whose length is the same as 
%   CHECKBOXLABELS. True indicates that the checkbox should initially be 
%   checked, false unchecked.
%
%   EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                   SELECTED, HELPFUNCTION) 
%   creates the dialog with a help button. HELPFUNCTION is a callback that 
%   displays help.
%
%   EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                   SELECTED, HELPFUNCTION, FUNCTIONLIST) 
%   creates a dialog that enables the user to pass in FUNCTIONLIST, a cell 
%   array of functions and optional arguments that calculate, then return 
%   the value to export. FUNCTIONLIST should be the same length as
%   CHECKBOXLABELS. 
%
%   HDIALOG = EXPORT2WSDLG(...) returns the handle of the dialog. 
%
%   [HDIALOG, OK_PRESSED] = EXPORT2WSDLG(...) sets OK_PRESSED to true if
%   the OK button is pressed, or false otherwise. If two return arguments
%   are requested, HDIALOG is [] and the function does not return until the 
%   dialog is closed.
%   
%   User can edit the text fields to modify the default variable names. If
%   the same name appears in multiple edit fields, EXPORT2WSDLG creates a
%   structure using that name. It then uses the DEFAULTVARIABLENAMES as
%   fieldnames for that structure.
%
%   The lengths of CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT and 
%   SELECTED must all be equal.
%
%   The strings in DEFAULTVARIABLENAMES must be unique.
%
%   Example:
%
%   A = randn(10,1);
%
%   checkLabels = {'Save sum of A to variable named:' ...
%                 'Save mean of A to variable named:'};
%   varNames = {'sumA', 'meanA'};
%   items = {sum(A), mean(A)};
% 
%   export2wsdlg(checkLabels, varNames, items, 'Save Sums to Workspace'); 
%   
%   See also DIALOG, MSGBOX, QUESTDLG.

%   Copyright 2002-2014 The MathWorks, Inc.

if nargin > 0
    if isstring(checkboxLabels)
        checkboxLabels = cellstr(checkboxLabels);
    end
end

if nargin > 1
    if isstring(defaultVariableNames)
        defaultVariableNames = cellstr(defaultVariableNames);
    end
end

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if (~iscell(checkboxLabels) || ~iscell(defaultVariableNames) || ...
    ~iscell(itemsToExport))
    error(message('MATLAB:export2wsdlg:CellArrayRequired'));
end

retButtonRequest = (nargout == 2);

checkBoxCount = length(checkboxLabels);

if checkBoxCount ~= length(defaultVariableNames) || ...
   checkBoxCount ~= length(itemsToExport)
    error(message('MATLAB:export2wsdlg:InputSizeMismatchLabelsNamesExportItems'));
end

if length(unique(defaultVariableNames)) ~= checkBoxCount
    error(message('MATLAB:export2wsdlg:BadDefaultNames'));
end

if (nargin > 3)
    title = varargin{1};
else
    title = getString(message('MATLAB:uistring:export2wsdlg:ExportToWorkspace'));
end

if (nargin > 4)
    selected = varargin{2};
    if ~islogical(selected)
        error(message('MATLAB:export2wsdlg:BadSelected'));
    elseif length(selected) ~= checkBoxCount
        error(message('MATLAB:export2wsdlg:InputSizeMismatchSelectedExportItems'));
    end
else
    selected = true(1, checkBoxCount);
end

if (nargin > 6)     % export functions
    functionlist = varargin{4};
    if length(functionlist) ~= checkBoxCount
        error(message('MATLAB:export2wsdlg:InputSizeMismatchFunctionListExportItems'));
    end
else
    functionlist = cell(1, checkBoxCount);
end

hDialog = dialog('Visible', 'off', 'Name', title, 'WindowStyle', 'normal', 'Units', 'pixels');
setappdata(hDialog,'OKPressed',@setOKPressed);
set(hDialog, 'CloseRequestFcn', {@CancelCallback, hDialog, retButtonRequest});

variableNames = createVarNames(defaultVariableNames);

if (nargin > 5)   % help button wanted
    helpButton = uicontrol(hDialog,'String', getString(message('MATLAB:uistring:export2wsdlg:Help')), 'Units', 'pixels', ...
                                   'Callback', {@HelpCallback, varargin{3}},'Tag','HelpButton');
else
    helpButton = [];
end

cancelButton = uicontrol(hDialog,'String', getString(message('MATLAB:uistring:export2wsdlg:Cancel')), 'Units', 'pixels', ...
                                 'Callback', {@CancelCallback, hDialog, ...
                                  retButtonRequest},'Tag','CancelButton');
okButton = uicontrol(hDialog,'String', getString(message('MATLAB:uistring:export2wsdlg:OK')), 'Units', 'pixels','Tag','OkButton');

[checkBoxes, editFields] = layoutDialog(hDialog, okButton, cancelButton, helpButton, ...
                                        checkboxLabels, variableNames, ...
                                        selected, checkBoxCount);

set(okButton, 'Callback', {@OKCallback, hDialog, checkBoxes, editFields, ...
                           itemsToExport, defaultVariableNames, functionlist, retButtonRequest});
set(hDialog, 'KeyPressFcn', {@KeyPressCallback, hDialog, checkBoxes, editFields, ...
                           itemsToExport, defaultVariableNames, functionlist, retButtonRequest});

if (length(checkBoxes) > 1)
    for i = 1:length(checkBoxes)
        set(checkBoxes{i}, 'Callback', {@CBCallback, checkBoxes, ...
                                        editFields, i});
    end
end

%set the okButton to be the default
fh = handle(hDialog);
% Call the setDefaultButton method on the figure handle
fh.setDefaultButton(okButton);

set(hDialog, 'HandleVisibility', 'callback', 'WindowStyle', 'modal');
set(hDialog, 'Visible', 'on');
movegui(hDialog,'onscreen');

% Set focus to the OK button
uicontrol(okButton);
OKPressed = true;
if nargout == 1  % only interested in the dialog handle
    hDialogout = hDialog;
elseif retButtonRequest  % wait until dialog is closed and return OKPressed
    hDialogout = [];
    uiwait(hDialog);
    delete(hDialog);
end

    function setOKPressed(val)
        OKPressed = val;
    end

end

%----------------------------------------------------------------------------
function modifiedNames = createVarNames(defVariableNames)
    % Preallocating for speed
    modifiedNames = cell(1, length(defVariableNames));
    for i = 1:length(defVariableNames)
        modifiedNames{i} = computename(defVariableNames{i});
    end
end

%----------------------------------------------------------------------------
function name = computename(nameprefix)

if (evalin('base',['exist(''', nameprefix,''', ''var'');']) == 0)
    name = nameprefix;
    return
end

% get all names that start with prefix in workspace
workvars = evalin('base', ['char(who(''',nameprefix,'*''))']);
% trim off prefix name
workvars = workvars(:,length(nameprefix)+1:end); 

if ~isempty(workvars)
    % remove all names with suffixes that are "non-numeric"
    lessthanzero = workvars < '0';
    morethannine = workvars > '9';
    notblank = (workvars ~= ' ');
    notnumrows = any((notblank & (lessthanzero | morethannine)),2);
    workvars(notnumrows,:) = [];
end

% find the "next one"
if isempty(workvars)
    name = [nameprefix, '1'];
else
    nextone = max(str2num(workvars)) + 1; %#ok
    if isempty(nextone)
        name = [nameprefix, '1'];
    else
        name = [nameprefix, num2str(nextone)];
    end
end
end

%----------------------------------------------------------------------------
function OKCallback(obj, eventdata, dialog, cb, e, itm, ...
    defaultVariableNames, fcs, retButtonRequest)  %#ok
    
    varnames = [];
    items = [];
    funcs = [];
    fieldnames = [];
    
    if (length(e) == 1)
          varnames{1} = get(e{1}, 'String');
          items{1} = itm{1};
          funcs{1} = fcs{1};
          fieldnames{1} = defaultVariableNames{1};
    else
        % we only care about items that are checked
        for i = 1:length(e)
            if get(cb{i}, 'Value') == 1
                varnames{end + 1} = get(e{i}, 'String'); %#ok
                items{end + 1} = itm{i}; %#ok
                funcs{end + 1} = fcs{i}; %#ok
                fieldnames{end + 1} = defaultVariableNames{i}; %#ok
            end
        end
    
        if isempty(varnames)
            errordlg(getString(message('MATLAB:uistring:export2wsdlg:YouMustCheckABoxToExportVariables')), ...
                     getString(message('MATLAB:uistring:export2wsdlg:NothingSelected')),'modal');
            return;
        end
    end
    
    %check for invalid and empty variable names
    badnames = [];
    emptynames = 0;
    emptystrmsg = '';
    badnamemsg = '';
    for i = 1:length(varnames)
        if strcmp('', strtrim(varnames{i}))
            emptynames = 1;
            emptystrmsg = getString(message('MATLAB:uistring:export2wsdlg:AnEmptyStringIsNotAValidChoiceForAVariableName'));
        elseif ~isvarname(varnames{i})
            badnames{end + 1} = varnames{i}; %#ok
        end
    end
    badnames = unique(badnames);
       
    if ~isempty(badnames)
        if (length(badnames) == 1)
            badnamemsg = getString(message('MATLAB:uistring:export2wsdlg:NotValidMATLABVariableNamesOneVariables', badnames{1}));
        elseif (length(badnames) == 2)
            badnamemsg = getString(message('MATLAB:uistring:export2wsdlg:NotValidMATLABVariableNamesTwoVariables', badnames{1}, badnames{2}));
        else
            badnamespart1 = sprintf('"%s", ', badnames{1:end-2});
            badnamemsg = getString(message('MATLAB:uistring:export2wsdlg:NotValidMATLABVariableNamesThreeVariables',badnamespart1, badnames{end-1}, badnames{end}));
        end
    end
    
    if (emptynames + length(badnames) > 0)
        dialogname = getString(message('MATLAB:uistring:export2wsdlg:InvalidVariableNames'));
        if (emptynames + length(badnames) == 1)
            dialogname = getString(message('MATLAB:uistring:export2wsdlg:InvalidVariableName'));
        end
        errordlg([emptystrmsg badnamemsg], dialogname,'modal');    
        return; 
    end
    
    %check for names already in the workspace
    dupnames = [];
    for i = 1:length(varnames)
        if evalin('base',['exist(''',varnames{i},''', ''var'');'])
            dupnames{end + 1} = varnames{i}; %#ok
        end
    end
    dupnames = unique(dupnames);
 
    if ~isempty(dupnames)
        dialogname = getString(message('MATLAB:uistring:export2wsdlg:DuplicateVariableNames'));
        if (length(dupnames) == 1)
            queststr = getString(message('MATLAB:uistring:export2wsdlg:OverWriteQuestionOneVariable',dupnames{1}));
            dialogname = getString(message('MATLAB:uistring:export2wsdlg:DuplicateVariableName'));
        elseif (length(dupnames) == 2)
              queststr = getString(message('MATLAB:uistring:export2wsdlg:OverWriteQuestionTwoVariables',dupnames{1}, dupnames{2}));
        else
            queststrpart1 = sprintf('"%s", ', dupnames{1:end-2});
            queststr = getString(message('MATLAB:uistring:export2wsdlg:OverWriteQuestionThreeVariables',queststrpart1, dupnames{end-1}, dupnames{end}));
        end
        buttonName = questdlg(queststr, dialogname, getString(message('MATLAB:uistring:export2wsdlg:Yes')), getString(message('MATLAB:uistring:export2wsdlg:No')), getString(message('MATLAB:uistring:export2wsdlg:Yes')));
        if ~strcmp(buttonName, getString(message('MATLAB:uistring:export2wsdlg:Yes')))
            return;
        end
    end


    %Check for variable names repeated in the dialog edit fields
    [uniqueArray, ~, uniqueIndex] = unique(varnames);
    for i = 1:length(uniqueArray)
        found = find(uniqueIndex == i);
        if (length(found) == 1) %variable name is not repeated
            index = found(1);
            if (isempty(funcs{index}))
                itemtoexport = items{index};
            else
                fun = funcs{index};
                itemtoexport = feval(fun{1}, fun{2:end});
            end
            assignin('base', varnames{found(1)}, itemtoexport);
        else %repeated variable names
            tempstruct = struct;
            for j = 1:length(found)
                index = found(j);
                if (isempty(funcs{index}))
                    itemtoexport = items{index};
                else
                    fun = funcs{index};
                    itemtoexport = feval(fun{1}, fun{2:end});
                end
                tempstruct.(fieldnames{index}) = itemtoexport;
            end
            assignin('base', varnames{found(1)}, tempstruct); 
        end
    end 
    
    disp(getString(message('MATLAB:uistring:export2wsdlg:VariablesHaveBeenCreatedInTheCurrentWorkspace')))
    if retButtonRequest
        okPressed = getappdata(dialog, 'OKPressed');
        okPressed(true);
        uiresume(dialog);
    end
    delete(dialog);    
 end
 
%----------------------------------------------------------------------------
function CBCallback(obj, eventdata, cb, e, num) %#ok
    if (get(cb{num}, 'Value') == 0)
        set(e{num}, 'Enable', 'off');
        set(e{num}, 'BackgroundColor', [0.831373 0.815686 0.784314]);
    else
        set(e{num}, 'Enable', 'on');
        set(e{num}, 'BackgroundColor', 'white');
    end
 end 
 
%----------------------------------------------------------------------------
function CancelCallback(obj, eventdata, dialog, retButtonRequest) %#ok
    if retButtonRequest
        okPressed = getappdata(dialog, 'OKPressed');
        okPressed(false);
        uiresume(dialog);
    end
    delete(dialog);    
end
    
%----------------------------------------------------------------------------
function KeyPressCallback(obj, eventdata, dialog, cb, e, itm, ...
    defaultVariableNames, fcs, retButtonRequest)

asciiVal = get(dialog, 'CurrentCharacter');
if ~isempty(asciiVal)
    if (asciiVal==32 || asciiVal==13)   % space bar or return is the "same" as OK
        OKCallback(obj, eventdata, dialog, cb, e, itm, defaultVariableNames, fcs, retButtonRequest);
    elseif (asciiVal == 27) % escape is the "same" as Cancel
        CancelCallback(obj, eventdata, dialog, retButtonRequest);
    end
end
end
   
%----------------------------------------------------------------------------
function HelpCallback(obj, eventdata, helpfun) %#ok
     feval(helpfun{1}, helpfun{2:end});
end 

%----------------------------------------------------------------------------
function [cb, e] = layoutDialog(hDlg, okBut, cancelBut, helpBut, checkboxLabels, ...
                                variableNames, selected, itemCnt)
    
    EXTENT_WIDTH_INDEX = 3;  % width is the third argument of extent
    
    POS_X_INDEX      = 1;
    POS_Y_INDEX      = 2;
    POS_WIDTH_INDEX  = 3;
    POS_HEIGHT_INDEX = 4;
    
    CONTROL_SPACING  = 10;
    EDIT_WIDTH       = 100;
    CHECK_BOX_WIDTH  = 20;
    DEFAULT_INDENT   = 20;
    
    % the following mimics what questdlg does in terms of setting the
    % height of the buttons, which are a little larger than the default
    % uicontrol button height
    
    % questdlg also sets the y position of the buttons to 10.
    
    BtnYOffset = 10;
    BtnHeight = 22;
    BtnMargin = 1.4;
    BtnExtent = get(okBut, 'Extent');
    BtnHeight = max(BtnHeight,BtnExtent(4)*BtnMargin);  
    
    if isempty(helpBut)
        helpPos = [0 0 0 0];
        helpWidth = 0;
    else
        helpPos = get(helpBut, 'Position');
        helpWidth = helpPos(POS_WIDTH_INDEX) + CONTROL_SPACING; 
    end
    
    longestCBExtent = 0;
    ypos = BtnHeight + BtnYOffset + CONTROL_SPACING;
    cb = cell(itemCnt, 1);
    e = cell(itemCnt, 1);
    for i = itemCnt:-1:1
        % create uicontrols in reverse order. We will flip them later.
        e{i} = uicontrol(hDlg, 'Style', 'edit', 'String', variableNames{i}, ...
                               'BackgroundColor', 'white', ...
                               'HorizontalAlignment', 'left', ...
                               'Units', 'pixels');
        cb{i} = uicontrol(hDlg, 'Style', 'checkbox', 'String', ...
                          checkboxLabels{i}, 'Units', 'pixels');
        check_pos = get(cb{i}, 'Position');
        check_pos(POS_Y_INDEX) = ypos;
        extent = get(cb{i}, 'Extent');
        width = extent(EXTENT_WIDTH_INDEX);
        check_pos(POS_WIDTH_INDEX) = width + CHECK_BOX_WIDTH;  
        set(cb{i}, 'Position', check_pos);
        edit_pos = get(e{i}, 'Position');
        edit_pos(POS_Y_INDEX) = ypos;
        edit_pos(POS_WIDTH_INDEX) = EDIT_WIDTH;
        % cursor doesn't seem to appear in default edit height
        edit_pos(POS_HEIGHT_INDEX) = edit_pos(POS_HEIGHT_INDEX) + 1;
        set(e{i}, 'Position', edit_pos);
        ypos = ypos + CONTROL_SPACING + edit_pos(POS_HEIGHT_INDEX);
        if width > longestCBExtent
            longestCBExtent = width;
        end
        if selected(i)
            set(cb{i}, 'Value', 1)
        else
            set(e{i}, 'Enable', 'off');
            set(e{i}, 'BackgroundColor', [0.831373 0.815686 0.784314]);
        end                  
    end
    
    % if there is only one item, make it a text control instead of a checkbox
    if (itemCnt == 1)
        set(cb{1}, 'Style', 'text');
    end
    
    % Position edit boxes
    edit_x_pos = check_pos(POS_X_INDEX) + longestCBExtent + CONTROL_SPACING ...
                           + CHECK_BOX_WIDTH;
    for i = 1:itemCnt
        edit_pos = get(e{i}, 'Position');
        edit_pos(POS_X_INDEX) = edit_x_pos;
        set(e{i}, 'Position', edit_pos);
    end
    h_pos = get(hDlg, 'Position');
    
    okPos = get(okBut, 'Position');
    cancelPos = get(cancelBut, 'Position');
    okPos(POS_WIDTH_INDEX) = 100;
    cancelPos(POS_WIDTH_INDEX) = 100;
    h_pos(POS_WIDTH_INDEX) = max(edit_x_pos + edit_pos(POS_WIDTH_INDEX) + ...
                                 CHECK_BOX_WIDTH, okPos(POS_WIDTH_INDEX) + ...
                                 cancelPos(POS_WIDTH_INDEX) +  helpWidth + ...
                                 CONTROL_SPACING + (2 * DEFAULT_INDENT));
    h_pos(POS_HEIGHT_INDEX) = ypos;

    h_pos = getnicedialoglocation(h_pos, 'pixels'); 

    set(hDlg, 'Position', h_pos);
    
    x_ok = (h_pos(POS_WIDTH_INDEX))/2 -  (okPos(POS_WIDTH_INDEX) + ... 
            helpWidth + CONTROL_SPACING + cancelPos(POS_WIDTH_INDEX))/2;
    
    okPos(POS_X_INDEX) = x_ok;
    okPos(POS_HEIGHT_INDEX) = BtnHeight;
    okPos(POS_Y_INDEX) = BtnYOffset;
    set(okBut, 'Position', okPos); 
   
    cancelPos(POS_X_INDEX) = okPos(POS_X_INDEX) + okPos(POS_WIDTH_INDEX) + ...
                                   CONTROL_SPACING;   
    cancelPos(POS_HEIGHT_INDEX) = BtnHeight;
    cancelPos(POS_Y_INDEX) = BtnYOffset;                       
    set(cancelBut, 'Position', cancelPos);
    
    if ~isempty(helpBut)
        helpPos(POS_X_INDEX) = cancelPos(POS_X_INDEX) + cancelPos(POS_WIDTH_INDEX) + ...
                                   CONTROL_SPACING;
        helpPos(POS_HEIGHT_INDEX) = BtnHeight;
        helpPos(POS_Y_INDEX) = BtnYOffset;
        set(helpBut, 'Position', helpPos);
    end

    % Reorder the children so that tabbing makes sense
    children = get(hDlg, 'Children');
    children = flipud(children);
    set(hDlg, 'Children', children);
end

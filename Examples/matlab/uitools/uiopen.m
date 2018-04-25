function uiopen(type,direct)
%UIOPEN Present file selection dialog with appropriate file filters.
%
%   UIOPEN presents a file selection dialog.  The user can either choose a
%   file to open or click cancel.  No further action is taken if the user
%   clicks on cancel.  Otherwise the OPEN command is evaluated in the base
%   workspace with the user specified filename.
%
%   These are the file filters presented using UIOPEN.
%
%   1st input argument   Filter List
%   <no input args>      *.m, *.fig, *.mat,
%                        *.mdl, *.slx  (if Simulink is installed),
%                        *.cdr         (if Stateflow is installed),
%                        *.rtw, *.tmf, *.tlc, *.c, *.h, *.ads, *.adb
%                                      (if Simulink Coder is installed),
%                        *.*
%   MATLAB               *.m, *.fig, *.*
%   LOAD                 *.mat, *.*
%   FIGURE               *.fig, *.*
%   SIMULINK             *.mdl, *.slx, *.*
%   EDITOR               *.m, *.mdl, *.cdr, *.rtw, *.tmf, *.tlc, *.c, *.h, *.ads, *.adb, *.*
%
%   If the first input argument is unrecognized, it is treated as a file
%   filter and passed directly to the UIGETFILE command.
%
%   If the second input argument is true, the first input argument is
%   treated as a filename.
%
%   Examples:
%       uiopen % displays the dialog with the file filter set to all MATLAB
%              %files.
%
%       uiopen('matlab') %displays the dialog with the file
%                         %filter set to all MATLAB files.
%
%       uiopen('load') %displays the dialog with the file filter set to
%                      %MAT-files (*.mat).
%
%       uiopen('figure') %displays the dialog with the file filter set to
%                        %figure files (*.fig).
%
%       uiopen('simulink') %displays the dialog with the file filter set to
%                          %model files (*.mdl,*.slx).
%
%       uiopen('editor') %displays the dialog with the file filter set to
%                        %"All MATLAB files". This filters out binary
%                        %formats: .mat, .fig, .slx.
%                        %All files are opened in the MATLAB Editor.
%
%   See also UIGETFILE, UIPUTFILE, OPEN, UIIMPORT.

%   Copyright 1984-2011 The MathWorks, Inc.

if nargin > 0
    type = convertStringsToChars(type);
end

if nargin > 1
    direct = convertStringsToChars(direct);
end

if nargin == 0
    type = '';
end

if nargin < 2
    direct = false;
end

if direct
    fn = type;
else
    % Error if MATLAB is running in no JVM mode.
    warnfiguredialog('uiopen');
    if isempty(type)
        % Do not provide a filter list. UIGETFILE called below will pick up all
        % the filters available in the MATLAB installation automatically.
        filterList = '';
    else
        allML = getPatternAndDescription(com.mathworks.mwswing.FileExtensionFilterUtils.getMatlabProductFilter());
        switch(lower(type))
            case 'matlab'
                filterList = [
                    allML; ...
                    getPatternAndDescription(com.mathworks.mwswing.FileExtensionFilterUtils.getMatlabFileFilter()); ...
                    getPatternAndDescription(com.mathworks.mwswing.FileExtensionFilterUtils.getFigFileFilter()); ...
                    {'*.*',   getString(message('MATLAB:uistring:uiopen:AllFiles'))}
                    ];
            case 'load'
                filterList = [
                    getPatternAndDescription(com.mathworks.mwswing.FileExtensionFilterUtils.getMatFileFilter()); ...
                    allML; ...
                    {'*.*',   getString(message('MATLAB:uistring:uiopen:AllFiles'))}
                    ];
            case 'figure'
                filterList = [
                    getPatternAndDescription(com.mathworks.mwswing.FileExtensionFilterUtils.getFigFileFilter()); ...
                    allML; ...
                    {'*.*',   getString(message('MATLAB:uistring:uiopen:AllFiles'))}
                    ];
            case 'simulink'
                % Simulink filters are the only ones hardcoded here.
                % This should be changed this in future
                filterList = [
                    {'*.mdl;*.slx', getString(message('MATLAB:uistring:uiopen:ModelFiles'))}; ...
                    allML; ...
                    {'*.*',   getString(message('MATLAB:uistring:uiopen:AllFiles'))}
                    ];
            case 'editor'
                % We should be deprecating this usage.
                % uiopen('editor') is an unused option and does not scale well to new file extenstions
                % This option primarily used to open a file in the 
                % MATLAB Editor using the EDIT function    
                % According to the documentation we need to remove .mat, .fig, .slx from the list
                allMLWithoutBinary = {regexprep(allML{1}, {'*.slx;','*.mat;','*.fig;'}, ''), allML{2}};
                filterList = [
                    allMLWithoutBinary;...
                    {'*.*',   getString(message('MATLAB:uistring:uiopen:AllFiles'))}
                    ];
            otherwise
                filterList = type;
        end
    end
    
    % Is it a .APP or .KEY directory on the Mac?
    % If so, open it properly.
    if strncmp(computer,'MAC',3) && ~iscell(filterList)...
            && (ischar(filterList) && isdir(filterList))
        [~, ~, ext] = fileparts(filterList);
        if strcmpi(ext, '.app') || strcmpi(ext, '.key')
            unix(['open "' filterList '" &']);
            return;
        end
    end
    [fn,pn] = uigetfile(filterList,getString(message('MATLAB:uistring:uiopen:DialogOpen')));
    if isequal(fn,0)
        return;
    end
    fn = fullfile(pn,fn);
end

try
    % send open requests from editor back to editor
    if strcmpi(type,'editor')
        edit(fn);
    else
        % Is it a MAT-file?
        [~, ~, ext] = fileparts(fn);
        if strcmpi(ext, '.mat')
            quotedFile = ['''' strrep(fn, '''', '''''') ''''];
            evalin('caller', ['load(' quotedFile ');']);
            setStatusBar(~isempty(whos('-file', fn)));
            return;
        end
        
        % Look to see if it's an HDF file  If so, don't try to handle it;
        % Pass it off to tools that know what to do.
        out = [];
        fid = fopen(fn);
        if fid ~= -1
            out = fread(fid, 4);
            fclose(fid);
        end
        if length(out) == 4 && sum(out == [14; 3; 19; 1]) == 4
            % Filter out hdftool deprecation warning
            warnState = warning('off','MATLAB:imagesci:hdftool:FunctionToBeRemoved');
            warnCleanup = onCleanup(@() warning(warnState));
            
            hdftool(fn);
        else
            sans = [];
            % If open creates variables, ans will get populated in here.
            % We need to assign it in the calling workspace later
            open(fn);
            
            if ~isempty(sans)
                vars = sans;
                % Shove the resulting variables into the calling workspace
                status = true;
                if isstruct(vars)
                    names = fieldnames(vars);
                    status = ~isempty(names);
                    for i = 1:length(names)
                        assignin('caller',names{i}, vars.(names{i}));
                    end
                else
                    assignin('caller','ans',vars);
                end
                setStatusBar(status);
            end
        end
    end
catch ex
    % Strip hyperlinks since errordlg does not support them
    err = ex.getReport('basic','hyperlinks','off');
    try 
        err = regexprep(err, '<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>','$1');
    catch
        % Just try removing hyperlinks that are left over
    end
    errordlg(err);
end

end

function setStatusBar(varsCreated)

if varsCreated
    theMessage = getString(message('MATLAB:uistring:uiopen:VariablesCreatedInCurrentWorkspace'));
else
    theMessage = getString(message('MATLAB:uistring:uiopen:NoVariablesCreatedInCurrentWorkspace'));
end

% The following class reference is undocumented and
% unsupported, and may change at any time.
dt = javaMethod('getInstance', 'com.mathworks.mde.desk.MLDesktop');
if dt.hasMainFrame
    dt.setStatusText(theMessage);
else
    disp(theMessage);
end

end

function filters = getPatternAndDescription(javaFileExtensionFilters)
filters = cell(1,2);

% PATTERNS
pattern = javaFileExtensionFilters.getPatterns;
if length(pattern)>1
    cellPatterns = arrayfun(@(x) [char(x) ';'], pattern,'UniformOutput',false);
    filters{1,1} = [cellPatterns{:}];
else
    filters{1,1} = char(pattern);
end

% DESCRIPTIONS
filters{1,2} = char(javaFileExtensionFilters.getDescription);
end

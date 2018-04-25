function [userCancelled, imageBatchStore] = loadInputBatchFolderDialog(groupName)

% Copyright 2014-2015 The MathWorks, Inc.


imageBatchStore    = [];
userCancelled      = false;
currentlyLoading   = false;

s = settings;
previousLocations = s.images.imagebatchprocessingtool.BatchLocations.ActiveValue;

% If the settings get corrupted, previousLocations will return empty. If
% this is the first time you're using this and there is no record of a
% previous directory, previousSettings{1} will return empty. In either
% case, we default to the present working directory.
if(isempty(previousLocations) || isempty(previousLocations{1}))
    folderAbsolutePath = pwd;
else
    % Using only one location now
    folderAbsolutePath = previousLocations{1};
end

recurseFlag = true;

loadDirDialog = dialog(...
    'Name',getString(message('images:loadInputBatchFolderDialog:loadImages')),...
    'Units','char',...
    'Position',[0 0 100 9],...
    'Visible','off',...
    'Tag','LoadDirDialog');
loadDirDialog.CloseRequestFcn = @doCancel;
movegui(loadDirDialog, 'center');


% Label
uicontrol('Parent', loadDirDialog,...
    'Style','text', ...
    'Units', 'char',...
    'Position', [1 7 100 1.5],...
    'HorizontalAlignment', 'left',...
    'String', getString(message('images:loadInputBatchFolderDialog:loadImagesFrom')));

% Text box to type path
hTextBox = uicontrol('Parent', loadDirDialog,...
    'Style', 'edit', ...
    'Units', 'char',...
    'Position', [1 5 80 1.5],...
    'String', folderAbsolutePath, ...
    'HorizontalAlignment', 'left',...
    'KeyPressFcn',@doLoadIfEntered,...
    'Tag','InputFolderTextBox');

    function doLoadIfEntered(~, event)
        if(strcmp(event.Key,'return'))
            doLoad();
        end
    end

% Browse button
currentlyBrowsing = false;
hBrowseButton = uicontrol('Parent', loadDirDialog, ...
    'Units', 'char',...
    'Position', [85 5 14 1.5],...
    'Callback', @doBrowse,...
    'String',getString(message('images:commonUIString:browse')),...
    'Tag','BrowseButton');

    function doBrowse(varargin)
        if(currentlyBrowsing)
            return;
        end
        currentlyBrowsing = true;
        dirname = uigetdir(hTextBox.String,getString(message('images:loadInputBatchFolderDialog:selectInput')));
        if(dirname ~= 0)
            folderAbsolutePath = dirname;
            hTextBox.String    = folderAbsolutePath;
        end
        currentlyBrowsing = false;
    end

% Checkbox for recursion
hCheckBox = uicontrol('Parent', loadDirDialog, ...
    'Style', 'checkbox',...
    'Units', 'char',...
    'Position', [1 3 100 1.5],...
    'Value', recurseFlag,...
    'Callback', @checkboxChange,...
    'String',getString(message('images:loadInputBatchFolderDialog:recurse')),...
    'Tag','IncludeSubfolderCheckBox');

    function checkboxChange(varargin)
        recurseFlag = logical(hCheckBox.Value);
    end

% Cancel button
uicontrol('Parent', loadDirDialog, ...
    'Callback', @doCancel,...
    'Units', 'char',...
    'Position', [85 1 14 1.5],...
    'String', getString(message('images:commonUIString:cancel')),...
    'Tag','CancelButton');

    function doCancel(varargin)
        userCancelled = true;
        if(~currentlyLoading)
            delete(loadDirDialog);
        end
    end

    function tf = pollForCancel()
        drawnow; % Ensure cancel button click is processed
        tf = userCancelled;
    end

% Load button
hLoadButton = uicontrol('Parent', loadDirDialog, ...
    'Callback', @doLoad,...
    'Units', 'char',...
    'Position', [65 1 16 1.5],...
    'String', getString(message('images:loadInputBatchFolderDialog:load')),...
    'Tag', 'LoadButton');



    function doLoad(varargin)
        drawnow; % Ensure all edits are captured
        folderAbsolutePath = hTextBox.String;
        folderAbsolutePath = strtrim(folderAbsolutePath);
        
        if(isdir(folderAbsolutePath))
            hLoadButton.String = getString(message('images:loadInputBatchFolderDialog:loading'));
            hLoadButton.Enable = 'off';
            hTextBox.Enable = 'off';
            hCheckBox.Enable = 'off';
            hBrowseButton.Enable = 'off';
            currentlyLoading = true;
            drawnow; % Ensure controls are disabled
            
            imageBatchStore = iptui.internal.batchProcessor.ImageBatchDataStore(...
                folderAbsolutePath,...
                recurseFlag,...
                @pollForCancel);
            
            if(imageBatchStore.NumberOfImages==0)
                hw = warndlg(getString(message('images:imageBatchProcessor:noImagesFoundDetail', folderAbsolutePath)),...
                    getString(message('images:imageBatchProcessor:noImagesFound')),...
                    'modal');
                uiwait(hw);
                imageBatchStore = [];
                
                hLoadButton.String = getString(message('images:loadInputBatchFolderDialog:load'));
                hLoadButton.Enable = 'on';
                hTextBox.Enable = 'on';
                hCheckBox.Enable = 'on';
                hBrowseButton.Enable = 'on';
                currentlyLoading = false;
                drawnow; % Ensure controls are enabled
                
                return;
            else
                % Remember successfully loaded location
                s.images.imagebatchprocessingtool.BatchLocations.PersonalValue = {folderAbsolutePath};
            end
            delete(loadDirDialog);
            
        else
            errordlg(getString(message('images:loadInputBatchFolderDialog:dirNonExistent', folderAbsolutePath)),...
                getString(message('images:loadInputBatchFolderDialog:dirNonExistentTitle')),...
                'modal');
        end
    end

%
loadDirDialog.Units = 'pixels'; % needed for API below
if(nargin==1)
    % Attempt to position dialog at center of tool
    loadDirDialog.Position = imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
        groupName, loadDirDialog.Position(3:4));
    movegui(loadDirDialog,'onscreen');
end

loadDirDialog.Visible = 'on';
uiwait(loadDirDialog);
end

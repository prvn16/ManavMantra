function varargout = guidetemplate(frame)
% Support function for GUIDE. Show dialog for creating or opening GUIDE GUIs.

% Copyright 1984-2008 The MathWorks, Inc.

import com.mathworks.toolbox.matlab.guide.template.QuickStartPanel;

parent = [];
origin = QuickStartPanel.MODE_STARTUP;

if (nargin == 1)
    parent = frame;
    origin = QuickStartPanel.MODE_NEW;
end

% Create the quick start panel
quickstartpanel = QuickStartPanel.create(origin);

% Wire a callback to the panel and stuff it into a figure
callback = handle(quickstartpanel.getCallback());
l = handle.listener(callback, 'delayed', {@dialogCallback,quickstartpanel});
size = quickstartpanel.getPreferredSize;
title = char(QuickStartPanel.DIALOG_NAME);
hDialog = dialog('Name', title,'visible','off');
set(hDialog, 'position', matlab.ui.internal.PositionUtils.getPlatformPixelRectangleInPixels([0, 0, size.width, size.height], hDialog));
[jc, hc] = javacomponent(quickstartpanel, [], hDialog);
set(hc,'Units','normalized','Position',[0 0 1 1]);
setappdata(hc,'DialogListener',l)

% position the dialog relative to the screen or its invoking parent frame
if ~isempty(parent)
    location = parent.getLocation;
    screen = get(0,'screenSize');
    pos = getpixelposition(hDialog);
    set(hDialog, 'position',[location.x, screen(4)-location.y-pos(4), pos(3), pos(4)]);
else
    movegui(hDialog,'center');
end

% put the dialog on screen
set(hDialog,'resize','on');
set(hDialog,'visible','on');
%need the drawnow here so that the panel can run code in EDT after the
%figure is shown
drawnow;

% When drawing the figure, some funny business happens on a MAC where it
% suddenly decides to change the figure height at draw-time; I assume for
% the title bar. This will reposition the panel to accommodate the new
% shape. (But we don't want it to flash up on all other systems after the 
% empty figure is quickly displayed, so leave the original position set)
% See: G357758
set(hc,'Units','normalized','Position',[0 0 1 1]);

% Set the initial focus component in the dialog. This must be done after
% the dialog has been instantiated and displayed.
quickstartpanel.setInitialFocus;

% give the panel a chance to do things after the dialog is shown. Do
% startup optimization if no output is expected
numout = nargout;

% if output is expected, wait for that to be set in the dialogCallback
if numout
    waitfor(hDialog)
end

    function dialogCallback(evtsrc, evtdata, quickstartpanel) 

        filename = [];
        evtsrc = java(evtsrc);

        id = evtsrc.getID;
        % browse for saving new figure
        if(id == evtsrc.BROWSE_FOR_SAVE)
            [fname, pname] = uiputfile({'*.fig', ...
                                getString(message('MATLAB:guide:GuiFileDescription'))},...
                                getString(message('MATLAB:guide:SaveAsDialogTitle')),...
                                'untitled.fig');
            if (fname ~= 0)
                filename = fullfile(pname, fname);
            end
            quickstartpanel.setSaveDestination(filename);
        % history - browse for figure files
        elseif (id == evtsrc.BROWSE_FOR_OPEN)
            [fname, pname] = uigetfile({'*.fig', ...
                                getString(message('MATLAB:guide:GuiFileDescription'))},...
                                getString(message('MATLAB:guide:OpenDialogTitle')));
            if (fname ~= 0)
                filename = fullfile(pname, fname);
                % Ask the panel to close only when a valid filename is
                % chosen by the user. This will trigger the callback to run 
                % the code in the else block below. 
                quickstartpanel.close;
            end
            quickstartpanel.setSelectionResult(filename);
        % dialog dismissed
        else
            if ishandle(hDialog)
                % delete figure and resume from the waitfor
                delete(hDialog);

                % process the result saved in the QuickStartPanel
                processDialogResult(quickstartpanel);
            end
        end
    end %dialogCallback

    % Get the result from the Quick Start Dialog
    function destfigfile = processDialogResult(quickstartpanel)

        dialogResult = quickstartpanel.getResult;

        destfigfile = 0;
        if ~isempty(dialogResult)
            % user did not hit ESC or CANCEL.
            label = char(dialogResult.getButtonLabel);

            if isempty(label)
                return;
            else
                import com.mathworks.toolbox.matlab.guide.ResourceManager;
                exportLabel = ResourceManager.getString('dialog.exportbutton');
                
                [path, file]= fileparts(char(dialogResult.getDestFileName));
                destmfile = fullfile(path,[file '.m']);
                destfigfile  = fullfile(path,[file '.fig']);
                
                if strcmp(label, exportLabel)
                    % User selected to migrate their GUIDE fig to App
                    % Designer.
                    guidefunc('exportAppDesigner', destfigfile);
                    return;
                else
                    % label is 'Browse' or 'OK'
                    % tplfile is a full path and filename w/o an extension.
                    tplfile = char(dialogResult.getTemplateFileName);
                    
                    if ~isempty(tplfile)
                        % For OK only.
                        saveFlag = dialogResult.isSaveOn;
                        
                        if ispc
                            tplfile = strrep(tplfile, '/', filesep);
                        else
                            tplfile = strrep(tplfile, '\', filesep);
                        end
                        
                        % save the template as the user selected file
                        % TBD this should be stored in a list somewhere
                        srcmfile = [tplfile,'.m'];
                        srcfigfile = [tplfile,'.fig'];
                        
                        setappdata(0,'templateFile', srcfigfile);
                        
                        if (saveFlag)
                            % guicopyToSave returns empty on success
                            % TBD something other than error would be good
                            setappdata(0,'templateFileSave', 1);
                            targetmfile = destmfile;
                            targetfigfile  = destfigfile;
                            
                            % error(guicopyToSave(srcmfile, destmfile));
                        else
                            setappdata(0,'templateFileSave', 0);
                            % guicopyToTemp just loads a template figure
                            % into memory and returns a handle to it.
                            temp = tempname;
                            targetmfile = [temp, '.m'];
                            targetfigfile = [temp, '.fig'];
                            
                            destfigfile = targetfigfile;
                        end
                        % copyfile does not force write permissions anymore.
                        % Need to force write permission explicitly using fileattrib
                        copyfile(srcfigfile, targetfigfile, 'writable');
                        fileattrib(targetfigfile, '+w');
                        copyfile(srcmfile, targetmfile,'writable');
                        fileattrib(targetmfile, '+w');
                        
                    end
                end
            end
        end

        if numout
            % set output if one is expected
            varargout{1} = destfigfile;
        else
            % reenter guide again with the user input when output is not
            % expected
            if destfigfile ~= 0
                guide(destfigfile);
            end            
        end
    end %processDialogResult

end %guidetemplate



function linkbtnoncallback(varargin)

%   Copyright 2007-2011 The MathWorks, Inc.

% When plots are linked from HG toolbar button or menus the callback
% strings execute in the base workspace. Consequently, these calls must be
% routed through the java LinkPlotPanel which will re-execute them from the
% current (possibly debug) workspace.
if usejava('awt')
    linkstate = linkdata(gcbf);
    
    if nargin>=1 
        if strcmp(varargin{1},linkstate.Enable)
            return % Quick return for no-op changes
        else 
            newstate = varargin{1};
        end
    else % Toggle the linked state
        if strcmp(linkstate.Enable,'off')
            newstate = 'on';
        else
            newstate = 'off';
        end
    end
    
    % Disable toolbar button to prevent double clicks causing the state 
    % to get out of sync with the toolbar button
    linkbtn = uigettool(gcbf,'DataManager.Linking');
    if isempty(linkbtn)
        return
    end
    if strcmp(newstate,'on')
        if ~isappdata(linkbtn,'cursorCacheData')
            setappdata(linkbtn,'cursorCacheData',get(gcbf,'Pointer'));
            set(gcbf,'Pointer','watch');
            drawnow expose
        end
        set(linkbtn,'Enable','off');
        com.mathworks.page.datamgr.linkedplots.LinkPlotPanel.activateLinkMode(java(handle(gcbf)));
        
    else
        % Make sure any pending link activations actions have processed
        % or the button could get out of sync with the figure state.
        drawnow 
        linkdata(gcbf,'off');
    end
else
    errordlg(getString(message('MATLAB:datamanager:linkbtnoncallback:LinkedPlotsCannotBeUsedWithoutJava')),'MATLAB',true);
end
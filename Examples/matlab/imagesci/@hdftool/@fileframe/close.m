function close(this)
%CLOSE Destroy the fileframe.
%   This method is called when the fileframe class is being closed.
%   It will close all files and close the tool itself.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object

%   Copyright 2005-2013 The MathWorks, Inc.

    if this.prefs.confirmClose
        yes = getString(message('MATLAB:imagesci:hdftool:yes'));
        no = getString(message('MATLAB:imagesci:hdftool:no'));
        reply = questdlg( ...
            getString(message('MATLAB:imagesci:hdftool:AreYouSureYouWantToCloseTheHDFTool')), ...
            getString(message('MATLAB:imagesci:hdftool:ReallyQuit')), ...
			yes, no, yes);
        if strcmp(reply, no)
            return
        end
    end

    fileToolSize = get(this.figureHandle,'Position');

    fileToolConfigSize = [fileToolSize(3)-this.figSplitPane.DominantExtent,...
        fileToolSize(4)-this.rightSplitPane.DominantExtent];

    % Save the size preferences of the tool.
    setpref('MATLAB_IMAGESCI', 'FILETOOL_SIZE', fileToolSize);
    setpref('MATLAB_IMAGESCI', 'FILETOOL_CONFIG_SIZE', fileToolConfigSize);
    
    this.closeAllFiles();
    drawnow;
    
    hTree = getTree(this.treeHandle);
    hhTree = handle(hTree,'callbackProperties');
    set(hhTree, 'MouseEnteredCallback', '');
    
    delete(this.treeHandle);
    delete(this.figureHandle);
    delete(this.noDataPanel);
    delete(this);
end

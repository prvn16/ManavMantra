function result = getSelectedTreeNode(this)
%GETSELECTEDTREENODE Returns the system selected in the main tree of the
%FPT

% Copyright 2015-2016 The MathWorks, Inc.

    result = this.TreeController.getSelectedTreeNode;
    % Return the parent node if the result is a MATLAB function.
    % This is needed for codeview to work correctly.
    if ischar(result)
        idx = strfind(result, '|');
        if ~isempty(idx) %#ok<*STREMP>
            % Indicates a MATLAB function node is selected. In this
            % case, return the parent tree node so that codeview
            % works as expected
            index = strfind(result,'::');
            if ~isempty(index)
                mlfbBlkPath = result(1:index-1);
                [~, result] = fxptds.getBlockPathFromIdentifier(mlfbBlkPath,'Stateflow');
            end
        end
    end
end

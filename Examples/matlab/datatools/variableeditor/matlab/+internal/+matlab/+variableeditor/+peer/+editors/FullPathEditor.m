classdef FullPathEditor < ...
        internal.matlab.variableeditor.peer.editors.AbstractFilePathConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % FullPath EditorConverter class. This class allows the client to
    % trigger file browsing on the server side
    
    % Copyright 2017 The MathWorks, Inc.

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            if ~isempty(value) && value(1) == this.BROWSE_CHAR
                args = this.getArgs(value);
                [fileName, pathName] = uigetfile(args{:});
                
                if fileName
                    this.value = [pathName fileName];
                end
            else
                % if user has entered filename on path, fill in rest of full
                % path
                if which(value)
                    this.value = which(value);
                else
                    this.value = value;
                end
            end
        end
    end
end

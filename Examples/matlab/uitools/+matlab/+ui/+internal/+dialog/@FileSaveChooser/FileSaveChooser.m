classdef FileSaveChooser < matlab.ui.internal.dialog.FileChooser
    % This function is undocumented and will change in a future release.
    
    % Copyright 2006-2012 The MathWorks, Inc.
    methods
        function obj = FileSaveChooser(varargin)
            % disp C_FileSaveDialog;
            % Initialize properties
            initialize(obj);
            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:UiFileSaveDialog:UnpairedParamsValues'));
            end
            for i = 1:2:length(varargin)
                if ~ischar(varargin{i})
                    error (message('MATLAB:UiFileSaveDialog:IllegalParameterType', i));
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:UiFileSaveDialog:IllegalParameter', varargin{ i }));
                end
            end
            createPeer(obj);

        end

        function setIncludeFilterExtension(obj,validate)
            obj.Peer.setIncludeFilterExtension(validate);
        end


%         function show(obj)
%             show@matlab.ui.internal.dialog.FileChooser(obj);
%         end

    end

    methods(Access = 'protected')
        function initialize(obj)
            % disp I_FileSaveDialog;
            initialize@matlab.ui.internal.dialog.FileChooser(obj);
            obj.Title = getString(message('MATLAB:uistring:filedialogs:SelectFileToWrite'));
        end

        function dataobj = updateDataObject(obj)
            dataobj.isMultiSelect = false;
            try
                dataobj.SelectedFiles = obj.Peer.getSelectedFile();
            catch %#ok<CTCH>
                dataobj.SelectedFiles = [];
            end
            dataobj.State = ~logical(obj.Peer.getState());
        end
     end
    
     methods(Access='protected')
        function extraPrepareDialog(obj)
            setIncludeFilterExtension(obj,true);
        end
        function doShowDialog(obj,parFrame)
            javaMethodEDT('showSaveDialog',obj.Peer,parFrame);
        end
    end
    
end

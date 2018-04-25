classdef FileOpenChooser < matlab.ui.internal.dialog.FileChooser
    % This function is undocumented and will change in a future release.
    
    % Copyright 2006-2012 The MathWorks, Inc.
    properties
        MultiSelection = false;
    end

    methods
        function obj = FileOpenChooser(varargin)
            % disp CFOO_FileOpenDialog;
            % Initialize properties
            initialize(obj);

            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:UiFileOpenDialog:UnpairedParamsValues'));
            end

            for i = 1:2:length(varargin)

                if ~ischar(varargin{i})
                    error (message('MATLAB:UiFileOpenDialog:illegalParameter', i));
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:UiFileDialog:illegalParameter', varargin{ i }));
                end
            end

            createPeer(obj);
        end

%         function show(obj)
%             show@matlab.ui.internal.dialog.FileChooser(obj);
%         end

        %Error checking for MultiSelection property
        function obj = set.MultiSelection(obj,v)
            if ~islogical(v)
                error(message('MATLAB:UiFileOpenDialog:InvalidMultiSelection'));
            end
            obj.MultiSelection = v;
        end
    end

    methods(Access = 'protected')
        function bool = isValidFieldName(obj,iFieldName)
            switch iFieldName
                case {'MultiSelection'}
                    bool = true;
                otherwise
                    bool = isValidFieldName@matlab.ui.internal.dialog.FileChooser(obj, iFieldName);
            end
        end

        function initialize(obj)
            % disp I_FileOpenDialog;
            initialize@matlab.ui.internal.dialog.FileChooser(obj);
            obj.MultiSelection = false;
            obj.Title = 'Select File To Open';
        end


        function dataobj = updateDataObject(obj)
            dataobj.isMultiSelect = false;
            try
                if isPeerMultiSelectionEnable(obj)
                    dataobj.SelectedFiles = obj.Peer.getSelectedFiles();
                    dataobj.isMultiSelect = true;
                else
                    dataobj.SelectedFiles = obj.Peer.getSelectedFile();
                end
            catch %#ok<CTCH>
                dataobj.SelectedFiles = [];
            end
            dataobj.State = ~logical(obj.Peer.getState());
        end
    end
    
    methods(Access='protected')
        function extraPrepareDialog(obj)
            setPeerMultiSelectionEnable(obj);
        end
        function doShowDialog(obj,parFrame)
            javaMethodEDT('showOpenDialog',obj.Peer,parFrame); % synchronous
            %javaMethodEDT('showOpenDialog',obj.Peer,getParentFrame(obj),[]); % asynchronous
        end
    end

    methods(Access = 'private')
        % Multi Selection related
        function setPeerMultiSelectionEnable(obj)
            myobj = obj.Peer;
            myobj.setMultiSelectionEnabled(obj.MultiSelection);
        end

        function a = isPeerMultiSelectionEnable(obj)
            a = (obj.MultiSelection == 1);
        end
    end
end

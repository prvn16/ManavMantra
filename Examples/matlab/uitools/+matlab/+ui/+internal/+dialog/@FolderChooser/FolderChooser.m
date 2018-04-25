classdef FolderChooser < matlab.ui.internal.dialog.FileSystemChooser
    % This function is undocumented and will change in a future release.
    
% Copyright 2006-2013 The MathWorks, Inc.

    properties (SetAccess = 'private')
       SelectedFolder = [];
    end
    
    %%%%%%%%%%%%%%%%%%%
    % ALL PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%
    methods
        function obj = FolderChooser(varargin)
            % Initialize properties
            initialize(obj);
            
            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:UiDirDialog:UnpairedParamsValues'));
            end

            for i = 1:2:length(varargin)
                if ~ischar(varargin{i})
                    error (message('MATLAB:UiDirDialog:illegalParameter', i));
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:UiFileDialog:illegalParameter', varargin{ i }));
                end
            end
            
        end
        
        
        function show(obj)    
            % Create and prepare the peer 
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end
   
            obj.Peer = handle(javaObjectEDT('com.mathworks.mwswing.MJFileChooserPerPlatform'),'callbackproperties');
            obj.Peer.setFileSelectionMode(javax.swing.JFileChooser.DIRECTORIES_ONLY);            
            setPeerTitle(obj);
            setPeerInitialPathName(obj);   
            doShowDialog(obj)
        end
       
    end
        
    methods (Access='protected')
        function setPeerInitialPathName(obj)
            obj.Peer.setCurrentDirectory(java.io.File(obj.InitialPathName));
        end
        
        function setPeerTitle(obj)
            obj.Peer.setDialogTitle(obj.Title);
        end
             
        function initialize(obj)
            initialize@matlab.ui.internal.dialog.FileSystemChooser(obj);
            obj.SelectedFolder = [];
            obj.Title = 'Select a Directory To Open';
        end
        
        % Method that actually opens the dialog. 
        function doShowDialog(obj)
            javaMethodEDT('showOpenDialog', obj.Peer, getParentFrame(obj));
            drawnow;
            if (obj.Peer.getState() == javax.swing.JFileChooser.APPROVE_OPTION)
                obj.SelectedFolder = char(obj.Peer.getSelectedFile());
            end
        end       
        
        
        function dispose(obj)
            dispose@matlab.ui.internal.dialog.FileSystemChooser(obj);
            set(obj.Peer,'StateChangedCallback','');            
        end

    end
end

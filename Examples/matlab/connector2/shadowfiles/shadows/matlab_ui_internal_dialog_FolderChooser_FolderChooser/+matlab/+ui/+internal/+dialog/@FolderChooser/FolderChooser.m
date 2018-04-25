classdef FolderChooser < matlab.ui.internal.dialog.FileSystemChooser
% $Revision: 1.1.4.2 $  $Date: 2011/02/11 20:45:19 $
% Copyright 2006-2010 The MathWorks, Inc.

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
                if ~ischar(varargin{i}) && ~isstring(varargin{i})
                    error (message('MATLAB:UiDirDialog:illegalParameter', i));
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:UiFileDialog:illegalParameter', varargin{ i }));
                end
            end

            createMJFolderChooser(obj);
        end


        function show(obj)
            % Setting Title causes the peer to be recreated because of a
            % lack of ability to set Title on MJFolderChooser. So,
            % setPeerTitle must be the first call in show().
            setPeerTitle(obj);
            setPeerInitialPathName(obj);
            myobj = obj.Peer;
            set(myobj,'ActionPerformedCallback',{@localUpdateIfSelected});
            set(myobj,'DialogCancelledCallback',{@localUpdateIfCancelled});
            myobj.browseAsynchronously();

            blockMATLAB(obj)

            function localUpdateIfSelected(src,evt)
                obj.SelectedFolder = char(evt.getActionCommand);
                dispose(obj);
            end
            function localUpdateIfCancelled(src,evt)
                obj.SelectedFolder = [];
                dispose(obj);
            end
        end

    end

    methods (Access='protected')
        function setPeerInitialPathName(obj)
            myobj = obj.Peer;
            aPathName = obj.InitialPathName;
            myobj.setInitialDirectory(java.io.File(aPathName));
        end

        function setPeerTitle(obj)
            createMJFolderChooser(obj);
        end

        function initialize(obj)
            initialize@matlab.ui.internal.dialog.FileSystemChooser(obj);
            obj.SelectedFolder = [];
            obj.Title = 'Select a Directory To Open';
        end

        % create thread safe java object
        function createMJFolderChooser(obj)
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end

            parent = getParentFrame(obj);
            aTitle = obj.Title;
            %f = handle(javaObjectEDT('javax.swing.JFrame', 'New Title'))
            obj.Peer = handle(javaObjectEDT('com.mathworks.mwswing.dialog.MJFolderChooser', parent, aTitle),'callbackproperties');
            %Always force useJava. Native dialogs cannot be detected
            obj.Peer.setUseJavaDialogs(true);
            javaObj = obj.Peer;
        end


        function dispose(obj)
            dispose@matlab.ui.internal.dialog.FileSystemChooser(obj);
            set(obj.Peer,'ActionPerformedCallback','');
            set(obj.Peer,'DialogCancelledCallback','');
        end

    end
end

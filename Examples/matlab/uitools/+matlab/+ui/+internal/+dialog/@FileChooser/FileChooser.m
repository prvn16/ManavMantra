classdef FileChooser < matlab.ui.internal.dialog.FileSystemChooser
% This function is undocumented and will change in a future release.
    
    % Copyright 2006-2012 The MathWorks, Inc.
    
    %Properties definition
    properties
        UseNativeDialog = false;
        
        FileFilter = '';
        InitialFileName = '';
        
        PathName = '';
        FileName= '';
        FilterIndex = 0;
        
        State = -1;

        UserSelectedMultipleFolders = false;
    end
    
    properties(Access=private)
        DialogShowCompleted = false;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor definition
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = FileChooser(varargin)
            % disp C_AbstractFileDialog;
            initialize(obj);
            
            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:AbstractFileDialog:UnpairedParamsValues'));
            end
            for i = 1:2:length(varargin)
                
                if ~ischar(varargin{i})
                    error (message('MATLAB:AbstractFileDialog:IllegalParameterType', i));
                end
                
                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:AbstractFileDialog:IllegalParameter', varargin{ i }));
                end
            end
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for setting/checking property values
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %Error checking for FileFilter property
        function set.FileFilter(obj,v)
            if ischar(v)
                v = {v};
            end
            if ~iscell(v)
                error(message('MATLAB:AbstractFileDialog:IllegalFileFilterParameter'));
            end
            temp = size(v);
            if temp(2)>2
                error(message('MATLAB:AbstractFileDialog:IllegalFileFilterSpecification'));
            end
            obj.FileFilter = v;
        end
        
        % Error checking for the fileName property
        function set.InitialFileName(obj,v)
            iFile = checkString(obj, v, 'InitialFileName');
            if any(ismember({'.', '..'}, iFile))
                iFile = '';
            end
            obj.InitialFileName = iFile;
        end
        
    end%end of methods that define set on properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods defined on the object
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access='private')
        function prepareDialog(obj)
            setPeerTitle(obj);
            addPeerFileExtensionFilters(obj);
            setPeerCurrentFile(obj);
            setFileExist(obj,true);
            set(obj.Peer,'StateChangedCallback',{@localupdate});
            obj.DialogShowCompleted = false;
            extraPrepareDialog(obj);
            function localupdate(~,~)
                updateFromDialog(obj,updateDataObject(obj));
                dispose(obj);
            end
        end
       
           
        function filterIndex = getPeerFilterIndex(obj)
            myobj = obj.Peer;
            filterIndex = myobj.getFileFilterIndex()+1; %Adding one for matlab 1 based indexing
        end
        
        %Most likely not used unless required
        function filter = getPeerFilter(obj)
            myobj = obj.Peer;
            filter = myobj.getFileFilter();
        end
        
        function showPeerAndBlockMATLAB(obj)
            parFrame = getParentFrame(obj);
            doShowDialog(obj, parFrame);
            blockMATLAB(obj);
        end
    end
    
    methods
        function show(obj)
            prepareDialog(obj);
            obj.showPeerAndBlockMATLAB();
            
            % If multiple files are selected from different folders 
            % Show an error dialog and reshow the open dialog 
            % Applies to libraries on Windows 
            % Also applies to List/CoverFlow view on the Mac dialog
            % see g803695
            while (obj.UserSelectedMultipleFolders)
                uiwait(warndlg(getString(message('MATLAB:AbstractFileDialog:MultipleFoldersSelected')), ...
                    getString(message('MATLAB:AbstractFileDialog:InvalidSelection')), ...
                    'modal'));
                % Re-Create the java peer
                obj.createPeer();
                % initialize the peer
                obj.prepareDialog();
                % show again
                obj.showPeerAndBlockMATLAB();
            end            
        end
       
    end%end of methods2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %OTHER PRIVATE METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'protected')
        function createPeer(obj)
            % Peer Constructor
            javaImpl = true;
            if ispc
                javaImpl = false; % Until Jared provided FilterIndex for
                % native Windows impl.
            end
            % f = handle(javaObjectEDT('javax.swing.JFrame', 'New Title'))
            %handles to raw java objects are used so that set and get
            %on handles do not take it into a bad state
            obj.Peer = handle(javaObjectEDT('com.mathworks.mwswing.MJFileChooserPerPlatform', ...
                java.io.File(''), javaImpl),'callbackproperties');
            obj.Peer.setFileHidingEnabled(false);
            % We need to allow multiple dialogs to be open due to g604761
            % Simulink runs into issues if we do not have this next line of
            % code. 
            % @TODO: If modality is fixed on Windows, we may not need this.
            obj.Peer.allowConcurrentInstances(); 
        end
        
        %Title Related
        function setPeerTitle(obj)
            myobj = obj.Peer;
            aTitle = obj.Title;
            myobj.setDialogTitle(aTitle);
        end
        
        function setFileExist(obj,v)
            if ~islogical(v)
                error(message('MATLAB:AbstractFileDialog:InvalidLogicalValue'));
            end
            myobj = obj.Peer;
            myobj.setFileMustExist(v);
        end
        
        function updateFromDialog(obj,dataobj)
            obj.State = dataobj.State;
            %Initial value of path,file and filterindex before
            %dialog writes into it
            obj.PathName = [];
            obj.FileName = [];
            obj.FilterIndex = 0;
			obj.UserSelectedMultipleFolders = false;
            if (obj.State == true)
                if (dataobj.isMultiSelect)
                    files = dataobj.SelectedFiles;
                    filenames = [];
                    filepaths = [];
                    filteridx = 0;
                    try
                        %prealloc size
                        filenames = cell(1,length(files));
                        filepaths = cell(1,length(files));
                        for i=1:length(files)
                            filenames{1,i} = char(files(i).getName);
                            filepaths{1,i} = char(files(i).getParent);
                        end
                        filteridx = getPeerFilterIndex(obj);
                    catch ex %#ok<NASGU>
                        warning(message('MATLAB:AbstractFileDialog:UnableToSelectFiles'));
                    end                                   
                   
                    if (length(unique(filepaths)) >= 2)
                        obj.UserSelectedMultipleFolders = true;
                    else
                        obj.UserSelectedMultipleFolders = false;
                        obj.FileName = filenames;
                        obj.PathName = filepaths{1};
                        obj.FilterIndex = filteridx;
                    end
                else
                    try
                        file = dataobj.SelectedFiles;
                        obj.PathName = char(file.getParent);
                        obj.FileName = char(file.getName);
                        obj.FilterIndex = getPeerFilterIndex(obj);
                    catch ex %#ok<NASGU>
                        warning(message('MATLAB:AbstractFileDialog:UnableToSelectFile'));
                    end
                end
            end
        end
        
        %%add file extension filters
        function addPeerFileExtensionFilters(obj)
            javaObj = obj.Peer;
            
            % create java object and add filters to java obj.
            if isempty(obj.FileFilter{1})
                javaFileExtensionFilters = getPeer(matlab.ui.internal.dialog.FileExtensionFilter);
                %Synchronize object state with the static set of filters
                %that we show as default.
                filters = cell(numel(javaFileExtensionFilters),2);
                for j = 1:size(filters,1)
                    % PATTERNS
                    pattern = javaFileExtensionFilters{j}.getPatterns;
                    if length(pattern)>1
                        cellPatterns = arrayfun(@(x) [char(x) ';'], pattern,'UniformOutput',false);
                        filters{j,1} = [cellPatterns{:}];
                    else
                        filters{j,1} = char(pattern);
                    end
                    
                    % DESCRIPTIONS
                    filters{j,2} = char(javaFileExtensionFilters{j}.getDescription);
                end                
                
                obj.FileFilter = filters; 
            else
                %first remove existing all file filter before adding new
                javaFileExtensionFilters = getPeer(matlab.ui.internal.dialog.FileExtensionFilter(obj.FileFilter));
            end
            javaMethodEDT('setAcceptAllFileFilterUsed',javaObj, false);
            for i = 1: length(javaFileExtensionFilters)
                % This fix is meant for resolving 356278. This fix
                % would prevent reordering of filters and hence return
                % the correct filter index. The filter index would not
                % get altered.
                %%%%%%%%%%
                % Todo
                %%%%%%%%%%
                % This does not eliminate the possibility of
                % having multiple 'All files' filter and we may seek
                % an alternate approach to optimize this.
                
                %                 if isAcceptAllFilesFilter(javaFileExtensionFilters{i})
                %                     awtinvoke(javaObj,'setAcceptAllFileFilterUsed(Z)', true);
                %                 else
                javaMethodEDT('addChoosableFileFilter',javaObj,javaFileExtensionFilters{i});
                %                 end
            end
        end
        
        function setPeerCurrentFile(obj)
            aPathName = obj.InitialPathName;
            aFileName = obj.InitialFileName;
            
            if isempty(aFileName)
                javaMethodEDT('setCurrentDirectory',obj.Peer,(java.io.File([aPathName, filesep])));
            else
                x = warning('off','MATLAB:dispatcher:nameConflict');
                %                try
                % Check if the path and file make up a valid path. Then
                % we need to call setCurrentDirectory.
                %Example uigetfile('D:/Work') parses into
                %InitialPathName - D:/
                %InitialFileName - Work
                %while we actually need InitialPathName to be
                %'D:/Work'. Hence we try to concat the path and
                %filename to see if we can make up a valid path
                %and then try to cd to it. This way, we eliminate
                %the need for a trailing slash after 'D:/Work' like before.
                dir = [aPathName, filesep, aFileName];
                if isdir(dir)
                    %                    cur = cd(dir);
                    %                    dir = cd(cur);
                    javaMethodEDT('setCurrentDirectory',obj.Peer,java.io.File(dir));
                    
                    %                catch ex
                else
                    % Otherwise, call setSelectedFile.
                    javaMethodEDT('setSelectedFile',obj.Peer,java.io.File([aPathName, filesep], aFileName));
                end
                warning(x);
            end
        end
        
        % Filter extension related
        function addPeerFileFilter(obj,v)
            if ~strcmp(class(v),'FileExtensionFilter')
                error(message('MATLAB:AbstractFileDialog:InvalidAddFilterExtensionType'));
            end
            if length(v.getPeer())==1
                temp = v.getPeer();
                obj.Peer.addChoosableFileFilter(temp{1});
            else
                error(message('MATLAB:AbstractFileDialog:InvalidNumberOfFiltersAdded'));
            end
        end
        
        function removePeerFileFilter(obj,v)
            if ~strcmp(class(v),'matlab.ui.internal.dialog.FileExtensionFilter')
                error(message('MATLAB:AbstractFileDialog:InvalidRemoveFilterExtensionType'));
            end
            if length(v.getPeer())==1
                temp = v.getPeer();
                obj.Peer.removeChoosableFileFilter(temp{1});
            else
                error(message('MATLAB:AbstractFileDialog:InvalidNumberOfFiltersRemoved'));
            end
        end
    end
    
    
    
    methods(Access = 'protected')
        function bool = isValidFieldName(obj,iFieldName)
            switch (iFieldName)
                case {'InitialFileName', 'FileFilter', 'UseNativeDialog'}
                    bool = true;
                otherwise
                    bool = isValidFieldName@matlab.ui.internal.dialog.FileSystemChooser(obj, iFieldName);
            end
        end
        
        
        function initialize(obj)
            % disp I_AbstractFileDialog;
            initialize@matlab.ui.internal.dialog.FileSystemChooser(obj);
            obj.UseNativeDialog = false;
            obj.FileFilter = ''; %getDefaultFileFilters(obj);
            obj.InitialFileName = '';
            obj.InitialPathName = '';
        end
        
        %For peers with asynchronous show methods, where we block
        %MATLAB and wait for callbacks, we need to clear the callbacks
        %to ensure that the destructor is called.
        function dispose(obj)
            dispose@matlab.ui.internal.dialog.FileSystemChooser(obj);
            set(obj.Peer,'StateChangedCallback','');
        end
        
        function blockMATLAB(obj)
            %%%%%%%%%%%%%%%%%%%%
            % The blockMATLAB and the unblockMATLAB methods are overridden in this class 
            % because the test infrastructure currently requires it. 
            % Since the doShowDialog uses the synchronous version of the 
            % MJFileChooserPerPlatform, really this calls should not need to block/unblock 
            % MATLAB at all. Really we should be able to simple follow the doShowDialog in 
            % the show method with the updateFrom Dialog call. However, the qeblockedstate.native 
            % test delegate is currently asynchronous requiring the while loop below in the overridden 
            % blockMATLAB to wait until the callback has been executed in order to move on. Once the 
            % test infrastructure's MTestDelegate can is synchronous the following can happen:
            %
            % 1) The blockMATLAB and unblockMATLAB overrides can be removed
            % 2) The reference to blockMATLAB in the show method can be removed
            % 3) The StateChangedCallback code and the local update function can be removed
            % 4) The dispose method can be removed
            % 5) The DialogShowCompleted properties and all references can be removed
            % 6) The updateFromDialog can simply be moved to after the doShowDialog call in the show method
            while ~obj.DialogShowCompleted
                drawnow;
            end
        end
        
        function unblockMATLAB(obj)
            obj.DialogShowCompleted = true;
        end
    end
    
    methods(Abstract=true,Access='protected')
        aStruct = updateDataObject(obj)
        extraPrepareDialog(obj)
        doShowDialog(obj,parFrame)
    end
    
    
end%end of class definition




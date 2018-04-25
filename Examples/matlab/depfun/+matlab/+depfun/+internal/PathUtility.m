classdef PathUtility < handle
    
    properties(Access = private)
        Environment
    end
    
    properties(Dependent,Access = private)
        FullToolboxRoot
        RelativeToolboxRoot
        PcmPath
    end
    
    % patterns for regexp (so we don't have to build the string every time)
    properties(Access = private)
        BaseDirectoryPattern
        RelativePathPattern
    end
    
    % constructor
    methods
        function obj = PathUtility
            
            % Use the Environment that is current at construction
            obj.Environment = matlab.depfun.internal.reqenv;
            
            fs = filesep;
            sepstr = '[\/\\]';

            obj.BaseDirectoryPattern = [strrep(regexptranslate('escape',...
                obj.FullToolboxRoot), ['\' fs],sepstr), ...
                sepstr, '(\w+)' sepstr '?'];
            
            pat = [strrep(regexptranslate('escape', ...
                obj.FullToolboxRoot),['\' fs],sepstr), ...
                sepstr, '(\S)+'];
            obj.RelativePathPattern = ...
                sprintf('[%s%s]%s',upper(pat(1)),lower(pat(1)),pat(2:end));
        end
    end
    
    % get
    methods
        function fulltbxrt = get.FullToolboxRoot(obj)
            fulltbxrt = obj.Environment.FullToolboxRoot;
        end
        
        function reltbxrt = get.RelativeToolboxRoot(obj)
            reltbxrt = obj.Environment.RelativeToolboxRoot;
        end
        
        function pcmpth = get.PcmPath(obj)
            pcmpth = obj.Environment.PcmPath;
        end
    end
    
    % public utility
    methods
        function b = isFromUncompilableToolbox(obj,str,uncmptbx)
            b = false;            
            if str~="" && contains(str,obj.FullToolboxRoot)
                b = contains(str, uncmptbx);
            end
        end
        
        function b = isaMathWorksFile(obj,cstr)
            
            % Note that cstr is a cell array of chars
            
            lclpath = fullfile(matlabroot,'toolbox','local');
            cmppath = fullfile(matlabroot,'toolbox','compiler');
            dmpath = fullfile(matlabroot,'toolbox','matlab','demos');
            
            N = numel(cstr);
            b = false(N,1);
            for k = 1:N
                b = ~isempty(obj.findToolboxPath(cstr{k})) && ...
                    isempty(strfind(cstr{k},lclpath)) && ...
                    isempty(strfind(cstr{k},cmppath)) && ...
                    isempty(strfind(cstr{k},dmpath));
            end
        end
        
        function new_filename = rp2fp(obj,tbxDir,fileName)
            mlrt = matlabroot;
            reltbxrt = obj.RelativeToolboxRoot;
            
            if iscell(fileName)
                isRP = cellfun('isempty', regexp(fileName,'^<matlabroot>'));
                FPitems = fileName(~isRP);
                RPitems = fileName(isRP);
                
                FPitems = strrep(FPitems,'<matlabroot>',mlrt);
                RPitems = strcat(fullfile(mlrt,reltbxrt,tbxDir,'/'),RPitems);
                
                new_filename = [FPitems; RPitems];
            else
                if isempty(regexp(fileName,'^<matlabroot>','ONCE'))
                    new_filename = strcat(fullfile(mlrt,reltbxrt,tbxDir,'/'),fileName);
                else
                    new_filename = strrep(fileName,'<matlabroot>',mlrt);
                end
            end
            
            new_filename = strrep(new_filename,'\','/');
        end
        
        function keep = keepOnPath(obj,pth)
            fs = filesep;
            
            % Find the entries that match 'toolbox/<something>/' (using
            % file separators appropriate for the platform, of course).
            % These are the entries we want to discard.
            match = ...
                regexp(pth, [obj.RelativeToolboxRoot '\' fs ...
                '([^\' fs ']+)(\' fs '|$)']);
            % We want to keep all the entries that DIDN'T match. Keep
            % all the entries for which the match offset is empty. If
            % the string doesn't have 'toolbox/<something>/' in it, we
            % want to keep it.
            keep = cellfun('isempty', match);
            
            % Now, look for directories we must keep:
            %   * toolbox/matlab
            %   * toolbox/local
            
            tbxML = regexp(pth, ['toolbox\' fs ...
                '((matlab\' fs ')|(local[\' fs ']?))']);
            
            % Keep those entries that DID match; that means we keep
            % only those entries with a non-empty match. We only keep
            % the strings that contain 'toolbox/matlab/' somewhere.
            keepML = ~cellfun('isempty', tbxML);
            
            % Apply logical index filter to pth cell array, removing the
            % entries for all components except toolbox/matlab.
            keep = keep | keepML;
        end
        
        function path_item = parent_to_toolbox(obj,d)
            % Copied directly from SearchPath
            path_item = d;
            tbx_path = fullfile(obj.FullToolboxRoot, d);
            if exist(tbx_path,'dir') == 7
                path_item = tbx_path;
            end
        end
        
        function outstr = componentBaseDir(obj,instr)
            outstr = regexp(instr, obj.BaseDirectoryPattern, 'tokens');
        end
        
        function outstr = componentRelativePath(obj,instr)
            outstr = regexp(instr, obj.RelativePathPattern, 'tokens');
        end
        
        function b = pcmexist(obj)
            b = exist(obj.PcmPath,'file') == 2;
        end

        function pth = dir2path(obj, dir)
        % This function turns a directory full path into a path prefix suitable for
        % the MATLAB path. Since @, +, and private directories cannot appear
        % directly on the MATLAB path, this function removes them from the
        % returned path prefix.
            At_Plus_Private_Idx = at_plus_private_idx(dir);
            if ~isempty(At_Plus_Private_Idx)
                pth = dir(1:At_Plus_Private_Idx-1);
            else
                pth = dir;
            end
        end
    end
    
    % utility
    methods(Access = private)
        function idx = findToolboxPath(obj,str)
            idx = strfind(str,obj.FullToolboxRoot);
        end
    end
    
end
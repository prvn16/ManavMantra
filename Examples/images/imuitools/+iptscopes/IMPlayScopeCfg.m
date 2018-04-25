classdef IMPlayScopeCfg < matlabshared.scopes.ScopeSpecification
    %IMPlayScopeCfg   Define the IMPlayScopeCfg class.
    %
    %    IMPlayScopeCfg methods:
    %        getConfigurationFile - Returns the configuration file name
    %        getAppName           - Returns the application name
    %        getScopeTitle        - Returns the scope title
    %        getHelpArgs          - Returns the help arguments for the key
    %        getHelpMenus         - Get the helpMenus.
    
    %   Copyright 2008-2017 The MathWorks, Inc.
    
    methods
        
        function obj = IMPlayScopeCfg(varargin)
            %IMPlayScopeCfg   Construct the IMPlayScopeCfg class.
            
            obj@matlabshared.scopes.ScopeSpecification(varargin{:});
            
        end
        
        function cfgFile = getConfigurationFile(~)
            %getConfigurationFile   Returns the configuration file name
            
            cfgFile = 'implay.cfg';
        end
        
        function appName = getAppName(~)
            %getAppName   Returns the application name
            
            appName = getString(message('images:implayUIString:toolName'));
        end
        
        function appTag = getScopeTag(~)
            appTag = 'Movie Player';
        end
        
        function scopeTag = getScopeName(~)
            scopeTag = getString(message('images:implayUIString:toolName'));
        end
        
        function scopeTitle = getScopeTitle(~,~)
            %getAppName   Returns the scope title

            scopeTitle = getString(message('images:implayUIString:toolName')); 
        end
        
        function helpArgs = getHelpArgs(~, key)
            %getHelpArgs   Returns the help arguments for the key
            
            mapFileLocation = fullfile(docroot, 'toolbox', 'images', ...
                'images.map');
            
            if nargin < 2
                key = 'overall';
            end
            switch lower(key)
                case 'colormap'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_colormap_dialog'};
                case 'framerate'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_framerate_dialog'};
                case 'overall'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_anchor'};
                otherwise
                    helpArgs = {};
            end
        end
        
        function [mApp, mExample, mAbout] = createHelpMenuItems(~, mHelp)
            
            mapFileLocation = fullfile(docroot, 'toolbox', 'images', ...
                'images.map');
            
            mApp(1) = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Movie Player',...
                'Label', getString(message('images:implayUIString:implayHelpMenuLabel')), ...
                'Callback', @(varargin) helpview(mapFileLocation, ...
                'implay_anchor'));
            
            mApp(2) = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Image Processing Toolbox', ...
                'Label', getString(message('images:commonUIString:imageProcessingToolboxHelpLabel')), ...
                'Callback', @(varargin) helpview(mapFileLocation, ...
                'ipt_roadmap_page'));
            
            mExample = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Image Processing Toolbox Demos ', ...
                'Label', getString(message('images:commonUIString:imageProcessingDemosLabel')), ...
                'Callback', @(varargin) demo('toolbox','image processing'));
            
            % Want the "About" option separated, so we group everything
            % above into a menugroup and leave "About" as a singleton menu
            mAbout = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_About', ...
                'Label', getString(message('images:commonUIString:aboutImageProcessingToolboxLabel')), ...
                'Callback', @(h,ed) aboutipt);
        end
        
        function hiddenExts = getHiddenExtensions(~)
            hiddenExts = {'Tools:Plot Navigation', 'Visuals', ...
                'Tools:Measurements'};
        end
        
        function show = showPrintAction(~,~)
            show = true;
        end
    end
    
    methods(Hidden=true)
        function flag = useMCOSExtMgr(~)
            flag = true;
        end
        
        function flag = useUIMgr(~)
            flag = false;
        end
    end
end

% -------------------------------------------------------------------------
function aboutipt

w = warning('off', 'images:imuitoolsgate:undocumentedFunction');
imuitoolsgate('iptabout');
warning(w);

end

% [EOF]

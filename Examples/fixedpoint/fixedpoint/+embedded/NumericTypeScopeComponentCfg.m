classdef NumericTypeScopeComponentCfg < scopeextensions.AbstractSystemObjectScopeCfg & ...
        embedded.NumericTypeScopeCfg
%NUMERICTYPESCOPECOMPONENTCFG Defines the configuration for the NumericType Scope

% Copyright 2009-2017 The MathWorks, Inc.

    methods 
        function this = NumericTypeScopeComponentCfg(varargin)
            this@scopeextensions.AbstractSystemObjectScopeCfg(varargin{:});
        end
        
        function configFile = getConfigurationFile(~)
            configFile = 'NumericTypeScopeComponent.cfg';
        end
        
        function scopeTitle = getScopeTitle(this, hScope)
            scopeTitle = getScopeTitle@embedded.NumericTypeScopeCfg(this, hScope);
        end
        
        function serializable = isSerializable(this)
            serializable = isSerializable@scopeextensions.AbstractSystemObjectScopeCfg(this);
        end
        
        function hiddenTypes = getHiddenTypes(this) %#ok<MANU>
             hiddenTypes = {'Sources','Visuals','Tools'};
        end
        
        function hiddenExtensions = getHiddenExtensions(this) %#ok
            hiddenExtensions = {'Core:Source UI'};
        end
        
        % Disable the progress bar.
        function showWaitbar = getShowWaitbar(~)
            showWaitbar = false;
        end

        function appName = getAppName(~)
            appName = 'NumericTypeScope';
        end
        
        function b = showPrintAction(~, ~)
            b = false;
        end
        
%         function helpMenus = getHelpMenus(this,hUI) %#ok
%             mapFileLocation = fullfile(docroot, 'toolbox', 'fixedpoint' , 'fixedpoint.map');
%             
%             mHistScope = uimgr.uimenu('NumericTypeScope', ...
%                                       getString(message('fixed:NumericTypeScope:NTXHelp')));
%             mHistScope.Placement = -inf;
%             mHistScope.setWidgetPropertyDefault(...
%                 'callback', @(hco,ev) helpview(mapFileLocation, 'NumericTypeScope'));
%             
%             mFixedPointHelp = uimgr.uimenu('Fixed-Point Designer',...
%                                            getString(message('fixed:NumericTypeScope:FPToolboxHelp')));
%             mFixedPointHelp.setWidgetPropertyDefault(...
%                 'callback', @(hco,ev) helpview(mapFileLocation, 'fixedpoint_roadmap'));
%             
%             mFixedPointDemo = uimgr.uimenu('Fixed-Point Designer Demos',...
%                                            getString(message('fixed:NumericTypeScope:FPToolboxDemos')));
%             mFixedPointDemo.setWidgetPropertyDefault(...
%                 'callback', @(hco,ev) demo('matlab','fixed-point'));
%             
%             % Want the "About" option separated, so we group everything above
%             % into a menu group and leave "About" as a singleton menu
%             mAbout = uimgr.uimenu('About',...
%                                   getString(message('fixed:NumericTypeScope:FPToolboxAbout')));
%             mAbout.setWidgetPropertyDefault(...
%                 'callback', @(hco,ev) aboutfixedpttlbx);
%             
%             helpMenus = uimgr.Installer( { ...
%                 mHistScope 'Base/Menus/Help/Application'; ...
%                 mFixedPointHelp 'Base/Menus/Help/Application'; ...
%                 mFixedPointDemo 'Base/Menus/Help/Demo'; ...
%                 mAbout 'Base/Menus/Help/About'});
%         end
        
        function [mApp, mExample, mAbout] = createHelpMenuItems(~, mHelp)
            mapFileLocation = fullfile(docroot, 'toolbox', 'fixedpoint' , 'fixedpoint.map');
            
            mApp = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_NumericTypeScope', ...
                'Label', getString(message('fixed:NumericTypeScope:NTXHelp')), ...
                'Callback', @(hco,ev) helpview(mapFileLocation, 'NumericTypeScope'));
            
            mApp(2) = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Fixed-Point Designer',...
                'Label', getString(message('fixed:NumericTypeScope:FPToolboxHelp')), ...
                'Callback', @(hco,ev) helpview(mapFileLocation, 'fixedpoint_roadmap'));
            
            mExample = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Fixed-Point Designer Demos',...
                'Label', getString(message('fixed:NumericTypeScope:FPToolboxDemos')), ...
                'Callback', @(hco,ev) demo('matlab','fixed-point'));
            
            % Want the "About" option separated, so we group everything above
            % into a menu group and leave "About" as a singleton menu
            mAbout = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_About',...
                'Label', getString(message('fixed:NumericTypeScope:FPToolboxAbout')), ...
                'Callback', @(hco,ev) aboutfixedpttlbx);
        end
    end
    
    methods (Hidden)
        function showToolbar = shouldShowMainToolbar(this) %#ok<MANU>
        % Hide the main toolbar if not on the maci platform since the scope won't have any actions.
            showToolbar = true;
            if ~ismac
                showToolbar = false;
            end
        end
    end
end

% [EOF]

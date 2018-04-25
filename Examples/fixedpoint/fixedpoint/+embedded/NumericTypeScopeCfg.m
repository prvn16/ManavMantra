classdef NumericTypeScopeCfg < uiscopes.AbstractScopeCfg
%NUMERICTYPESCOPECFG Define the Configuration for the NumericType Scope

% Copyright 2009-2017 The MathWorks, Inc.

    properties (Hidden)
       scopeTitleString; 
    end
    methods
        function this = NumericTypeScopeCfg(varargin)
            this@uiscopes.AbstractScopeCfg(varargin{:});
         end
        
        function appName = getAppName(this) %#ok
            appName = 'NumericTypeScope';
        end
        
        function cfgFile = getConfigurationFile(this) %#ok
            cfgFile = 'NumericTypeScopeSL.cfg';
        end
        
        function helpArgs = getHelpArgs(this,key) %#ok
            helpArgs = [];
        end
        
        function show = showPrintAction(~, ~)
        %showPrintAction Returns false as Printing is not supported in
        % NumericTypeScopes
            show = false;
        end

        % Hide Sources, Visuals and Tools for now.
         function hiddenTypes = getHiddenTypes(this) %#ok
            hiddenTypes = {'Visuals','Tools'};
        end
        
        % Hide Sources, Visuals and Tools for now.
         function hiddenTypes = getHiddenExtensions(this) %#ok
            hiddenTypes = {'Sources:File', 'Sources:Workspace',...
                           'Visuals',...
                           'Tools:Image Navigation Tools',...
                           'Tools:Image Tool', 'Tools:Pixel Region',...
                           'Tools:Instrumentation Sets'};
         end
       
        function hidden = hideStatusBar(this) %#ok
           hidden = true;
        end
        
        % Get the title of the scope based on the configuration.
        function scopeTitle = getScopeTitle(this, hScope)
            scopeTitle = getScopeTitleString(this);
            if isempty(scopeTitle)
                scopeTitle = getAppName(hScope);
                if ~isempty(hScope.DataSource)
                    scopeTitle = sprintf('%s - %s', scopeTitle, ...
                        getSourceName(hScope.DataSource));
                end
                
            end
        end
        
        % function helpMenus = getHelpMenus(this,hUI) %#ok
        %     mapFileLocation = fullfile(docroot, 'fixedpoint' , 'fixedpoint.map');
            
        %     mHistScope = uimgr.uimenu('NumericTypeScope', ...
        %                               DAStudio.message('FixedPointTool:fixedPointTool:NTSHelp'));
        %     mHistScope.Placement = -inf;
        %     mHistScope.setWidgetPropertyDefault(...
        %         'callback', @(hco,ev) helpview(mapFileLocation,'nts'));
            
        %     mFixedPointHelp = uimgr.uimenu('Fixed-Point Designer',...
        %                                    DAStudio.message('FixedPointTool:fixedPointTool:actionHELPSLFXPT'));
        %     mFixedPointHelp.setWidgetPropertyDefault(...
        %         'callback', @(hco,ev) helpview(mapFileLocation, 'fp_product_page'));
            
        %     mFixedPointDemo = uimgr.uimenu('Fixed-Point Designer Demos',...
        %                                   DAStudio.message('FixedPointTool:fixedPointTool:actionHELPSLFXPTDEMOS'));
        %     mFixedPointDemo.setWidgetPropertyDefault(...
        %         'callback', @(hco,ev)  demo('matlab','Fixed-Point Designer'));
            
        %     % Want the "About" option separated, so we group everything above
        %     % into a menu group and leave "About" as a singleton menu
        %     mAbout = uimgr.uimenu('About', ...
        %                           DAStudio.message('FixedPointTool:fixedPointTool:actionHELPABOUTSLFXPT'));
        %     mAbout.setWidgetPropertyDefault(...
        %         'callback', @(hco,ev) fxptui.aboutslfixpoint);
            
        %     helpMenus = uimgr.Installer( { ...
        %         mHistScope 'Base/Menus/Help/Application'; ...
        %         mFixedPointHelp 'Base/Menus/Help/Application'; ...
        %         mFixedPointDemo 'Base/Menus/Help/Demo'; ...
        %         mAbout 'Base/Menus/Help/About'});
        % end
        
        function [mApp, mExample, mAbout] = createHelpMenuItems(~, mHelp)
                
            mapFileLocation = fullfile(docroot, 'fixedpoint' , 'fixedpoint.map');
            
            mApp = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_NumericTypeScope', ...
                'Label', getString(message('FixedPointTool:fixedPointTool:NTSHelp')), ...
                'Callback', @(hco,ev) helpview(mapFileLocation,'nts'));
            
            mApp(2) = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Fixed-Point Designer',...
                'Label', getString(message('FixedPointTool:fixedPointTool:actionHELPSLFXPT')), ...
                'Callback', @(hco,ev) helpview(mapFileLocation, 'fp_product_page'));
            
            mExample = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_Fixed-Point Designer Demos',...
                'Label', getString(message('FixedPointTool:fixedPointTool:actionHELPSLFXPTDEMOS')), ...
                'Callback', @(hco,ev) demo('matlab','Fixed-Point Designer'));
            
            % Want the "About" option separated, so we group everything above
            % into a menu group and leave "About" as a singleton menu
            mAbout = uimenu(mHelp, ...
                'Tag', 'uimgr.uimenu_About', ...
                'Label', getString(message('FixedPointTool:fixedPointTool:actionHELPABOUTSLFXPT')), ...
                'Callback', @(hco,ev) fxptui.aboutslfixpoint);
        end
    end
    
    methods (Hidden)
        
        function b = useMCOSExtMgr(~)
            b = true;
        end
        function setScopeTitleString(this, val)
            if ischar(val)
                this.scopeTitleString = val;
            end
        end
        
        function scopeTitle = getScopeTitleString(this)
            scopeTitle = this.scopeTitleString;
        end
        
    end
    
end

%--------------------------------------------------------------


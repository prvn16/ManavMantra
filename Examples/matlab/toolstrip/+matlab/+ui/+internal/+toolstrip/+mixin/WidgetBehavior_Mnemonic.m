classdef (Abstract) WidgetBehavior_Mnemonic < handle
    % Mixin class inherited by all the controls and Tab and Section
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public, Hidden)
        % Property "Mnemonic": 
        %
        %   The mnemonic key of a control or tab or section.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button('Submit')
        %       btn.Mnemonic = 'S'
        Mnemonic
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        MnemonicPrivate = ''
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Mnemonic(this)
            % GET function
            value = this.MnemonicPrivate;
        end
        function set.Mnemonic(this, value)
            % SET function
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if ~ischar(value) || ~all(isletter(value))
                error(message('MATLAB:toolstrip:control:invalidMnemonic'))
            end
            this.MnemonicPrivate = value;
            this.setPeerProperty('mnemonic',value);
        end

    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_Mnemonic(this)
            mcos = {'MnemonicPrivate'};
            peer = {'mnemonic'};
        end
        
    end
    
end


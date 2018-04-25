classdef  BitAllocationDialog < dialogmgr.DialogContent
    % Implement options dialog for NTX

%   Copyright 2010-2014 The MathWorks, Inc.

    properties (Access=private)
        % Handles to widgets within the dialog panel
        
        hBASignedPrompt
        hBASigned
        
        hBARoundingPrompt
        hBARounding

        hBAFLPanel
        hBAFLPrompt
        hBAFLMethod
        hBAFLValuePrompt
        hBAFLSpecifyMagnitude
        hBAFLSpecifyBits
        hBAFLExtraBitsPrompt
        hBAFLExtraBits
        
        hBAILPanel
        hBAILPrompt
        hBAILMethod
        hBAILPercent
        hBAILCount
        hBAILUnits
        hBAILValuePrompt
        hBAILSpecifyMagnitude
        hBAILSpecifyBits
        hBAILGuardBitsPrompt
        hBAILGuardBits
        
        % Graphical mode
        hBAGraphicalMode
        
        % Word Length control
        hBAWLPrompt
        hBAWLMethod
        hBAWLValuePrompt
        hBAWLBits
        
        % Combined IL/FL optimization.
        hBAILFLPanel
        hBASpecifyPrompt
        hBAILFLMethod
        hBAILFLValuePrompt
        hBAILFLMaxOverflowPrompt
        hBAILFLPercent
        hBAILFLCount
        hBAILFLUnits
        hBAILFLSpecifyMSBMagnitude
        hBAILFLSpecifyILBits
        hBAILFLGuardBitsPrompt
        hBAILFLGuardBits
        hBAILFLSpecifyLSBMagnitude
        hBAILFLSpecifyFLBits
        hBAILFLExtraBitsPrompt
        hBAILFLExtraBits
       
    end
    
    properties (SetAccess=private,SetObservable,AbortSet)
        % Properties that require NTX to take immediate action in response
        % to a change in value
        
        % Signed mode
        %  1 = Auto
        %  2 = Signed
        %  3 = Unsigned
        BASigned = 1
        
        % Rounding mode
        % 1 = Ceil
        % 2 = Convergent
        % 3 = Floor
        % 4 = Nearest
        % 5 = Round
        % 6 = Zero
        BARounding = 4
        
        % Bit Allocation Fraction Length (BAFL) dialog
        %
        % BAFLMethod
        %   1 = Smallest magnitude, 2 = Specify FL Bits
        BAFLMethod      = 1
        BAFLMagInteractive = 0.01   % Used when initialized to Interactive
        BAFLSpecifyMagnitude = 0.05 % Min magnitude
        BAFLSpecifyBits = 8     % Directly specify number of FL Bits
        BAFLExtraBits   = 0     % Extra FL bits beyond minimum required
        
        % Bit Allocation Integer Length (BAIL) dialog
        %
        % BAILMethod
        %  1 = maximum Overflow, 2 = Largest Magnitude, 3 = Specify IL Bits
        BAILMethod      = 1
        BAILMagInteractive = 10
        BAILPercent     = 0   % Max Overflow Percent target
        BAILCount       = 0   % Max Overflow Count target
        BAILUnits       = 1   % Max Overflow units: 1=Percent, 2=Count
        BAILSpecifyMagnitude = 10  % Max magnitude
        BAILSpecifyBits = 8   % Directly specify number of IL Bits
        BAILGuardBits   = 0   % Guard Bits
        
        % Word Length choice
        % 1 = "Auto"
        % 2 = "Specify"
        BAWLMethod = 2;
        
        % Select a IL or FL specification
        % 1 = Maximum overflow, 2 = Largest magnitude, 3 = IL bits
        % 4 = Smallest magnitude, 5 = FL bits
        BAILFLMethod = 1;
        
        % Indicators for which interactive line was dragged. This used to 
        % check which line was dragged when a word length is specified and graphical
        % mode is turned on. The expected behavior for graphical interaction when a
        % word length is specified is that the entire word length area will shift 
        % based on the line a user drags.
        BAOverflowLineDragged = false;
        BAUnderflowLineDragged = false;
        
        % Bit Allocation Word Length (BAWL) bits
        BAWLBits = 16
        
        % Interactive cursor selection. Value is a logical.
        BAGraphicalMode = false;
        
    end
    
    methods
        function dlg = BitAllocationDialog(ntx)
            % Setup dialog
            dlg.Name = getString(message('fixed:NumericTypeScope:BitAllocationDialogName'));
            dlg.UserData = ntx; % record NTX application handle
        end
        
        function y = extraLSBBitsSelected(dlg)
            % True if DTX enabled and extra bits selected for Frac Length
            %
            % Property is active in all modes except 'Specify Bits'
            % (BAFLMethod==2)
            %
            %Return false if word length is specified and IL
            %constraint is chosen, since extra precision is not considered
            %when estimating FL.  If Word length is specified, then
            %BAILFLMethod has to be set to "Smallest magnitude (4)" for
            %extra bits to apply. If Word length is not specified, then
            %BAFLMethod has to be set to "smallest magnitude (1)" for extra
            %bits to apply.
            y = (dlg.BAFLExtraBits > 0) && ((~dlg.BAGraphicalMode && (dlg.BAWLMethod==2) && (dlg.BAILFLMethod==4)) ||...
                ((dlg.BAWLMethod==1) && (dlg.BAFLMethod==1)) || ((dlg.BAWLMethod==1) && dlg.BAGraphicalMode));
        end
        
        function y = extraMSBBitsSelected(dlg)
            % True if DTX enabled and extra bits selected for Int Length
            %
            % Property is active in all modes except Specify Bits
            % (BAILMethod==2)
            %
            % If Word length is specified, then BAILFLMethod has to be set
            %to one of "Maximum overflow (1)" or "Largest magnitude (2)" for
            %extra bits to apply. If Word length is not specified, then
            %BAILMethod has to be set to "Maximum overflow (1)" or "Largest
            %magnitude (2)" for extra bits to apply.
            y = (dlg.BAILGuardBits > 0) && (((dlg.BAWLMethod==1) && dlg.BAGraphicalMode) ||...
                ((dlg.BAWLMethod==1) && (dlg.BAILMethod~=3)) || ...
                ( ~dlg.BAGraphicalMode && (dlg.BAWLMethod==2) && (dlg.BAILFLMethod <= 2)));
        end
        
        function setBAILMethod(dlg, varargin)
        % Set the Integer Length constraint
            if nargin < 2
                dlg.BAILMethod = get(dlg.hBAILMethod,'Value');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    dlg.BAILMethod = sscanf(varargin{1},'%d');
                end
                set(dlg.hBAILMethod,'Value',dlg.BAILMethod);
            end
        end
        
        function setBAFLMethod(dlg, varargin)
        % Set the Fraction Length constraint
            if nargin < 2
                dlg.BAFLMethod = get(dlg.hBAFLMethod,'Value');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    dlg.BAFLMethod = sscanf(varargin{1},'%d');
                end
                set(dlg.hBAFLMethod,'Value',dlg.BAFLMethod);
            end
        end
        
        function setBAILFLMethod(dlg, varargin)
        % Set the Integer or Fraction Length constraint when a Word Length
        % is specified
            if nargin < 2
                dlg.BAILFLMethod = get(dlg.hBAILFLMethod,'Value');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    dlg.BAILFLMethod = sscanf(varargin{1},'%d');
                else
                    dlg.BAILFLMethod = varargin{1};
                end
                %Set the widget to the updated value.
                set(dlg.hBAILFLMethod,'Value',dlg.BAILFLMethod);
            end
            % We now need to set the correct BAILMethod & BAFLMethod based
            % on the selection BAILFL is a union of the two.  The order of
            % this list is very important. Rearranging the IL/FL list
            % without correctly changing this method will lead to bugs.
            % 1 = Maximum overflow, 2 = Largest magnitude, 3 = IL bits 
            % 4 = Smallest magnitude, 5 = FL bits.
            switch dlg.BAILFLMethod
               case 1
                dlg.BAILMethod = 1;
              case 2
                dlg.BAILMethod = 2;
              case 3
                dlg.BAILMethod = 3;
              case 4
                dlg.BAFLMethod = 1;
              case 5
                dlg.BAFLMethod = 2;
            end
        end
        
        function setBAWLMethod(dlg, varargin)
        % Set the Word Length mode.
            if nargin < 2
                dlg.BAWLMethod = get(dlg.hBAWLMethod,'Value');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    dlg.BAWLMethod = sscanf(varargin{1},'%d');
                else
                    dlg.BAWLMethod = varargin{1};
                end
                % Set the widget to the updated value.
                set(dlg.hBAWLMethod,'Value',dlg.BAWLMethod);
            end
        end
        
        function setBAWLBits(dlg, value)
            % This method provides a way to set the .BAWLBits
            % property outside the dialog. When the incoming data has a
            % fixed-point type, then the properties (WordLength, Fraction
            % Length & Signedness) on the BitAllocation panel are updated
            % to reflect the data type. 
            
            % This is also the callback that gets invoked when the
            % wordlength is set from the dialog.
            if nargin < 2
                str = get(dlg.hBAWLBits,'String');
                value = sscanf(str,'%f');
                if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(value)) || ...
                        (value == 0) || (value > 65535)
                    % Invalid value; replace old value into edit box
                    value = dlg.BAWLBits;
                    if isempty(str); str = '[]'; end
                    errordlg(getString(message('fixed:NumericTypeScope:WordLengthInvalidValue', str)), ...
                        getString(message('fixed:NumericTypeScope:WordLengthDialogName')),'modal');
                end
            else
                if ischar(value)
                    value = sscanf(value,'%f');
                end
                if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(value)) || ...
                            (value == 0) || (value > 65535)
                        if isempty(value); value = '[]'; end
                        [msg, msgID] = DAStudio.message('fixed:NumericTypeScope:WordLengthInvalidValue',value);
                        DAStudio.error(msgID, msg);
                end     
            end
            dlg.BAWLBits = value;
            % Update the widget with the value.
            str = sprintf('%d',dlg.BAWLBits); % replace string (removes spaces, etc)
            set(dlg.hBAWLBits,'String',str)
        end
        
        function setBAILUnits(dlg,h,varargin)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILUnits or dlg.hBAILFLUnits
            % If the input is from the matlab connector, then the value
            % will be passed directly and there will not be any handle to
            % the widget.
            if isempty(h)
                if isempty(varargin)
                    return;
                elseif ischar(varargin{1})
                    dlg.BAILUnits = sscanf(varargin{1},'%d');
                end
            end

            if ~isempty(h)
                if isgraphics(h, 'uicontrol') %isa(handle(h),'uicontrol') && ishghandle(h)
                    dlg.BAILUnits = get(h,'Value');
                else
                    dlg.BAILUnits = h;
                end
            end
            set(dlg.hBAILUnits,'Value',dlg.BAILUnits);
            set(dlg.hBAILFLUnits,'Value',dlg.BAILUnits);
        end
        
        function setBAFLBits(dlg, value)
            % This method provides a way to set the .BAFLSpecifyBits
            % property outside the dialog. When the incoming data has a
            % fixed-point type, then the properties (WordLength, Fraction
            % Length & Signedness) on the BitAllocation panel are updated
            % to reflect the data type.
            if ischar(value)
                value = sscanf(value,'%d');
            end
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(value,'allowNegValues'))
                errordlg(getString(message('fixed:NumericTypeScope:FractionLengthInvalidValue')), ...
                    getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
            else
                dlg.BAFLSpecifyBits = value;
            end
            % Set the widgets to reflect the updated value.
            set(dlg.hBAFLSpecifyBits,'String',sprintf('%g',dlg.BAFLSpecifyBits));
            set(dlg.hBAILFLSpecifyFLBits,'String',sprintf('%g',dlg.BAFLSpecifyBits));
        end
        
        function setBAGraphicalMode(dlg)
        % Turn On/Off the Graphical controls.
            dlg.BAGraphicalMode = get(dlg.hBAGraphicalMode,'Value');
        end
        
        function enableBAILPanel(dlg)
        % Make the Integer Length panel visible
            set(dlg.hBAILPanel,'Visible','on');
        end
        
        function enableBAFLPanel(dlg)
        % Make the Fraction Length panel visible.
            set(dlg.hBAFLPanel,'Visible','on');
        end
        
        function setOverflowLineDragged(dlg,value)
        % Set the value of BAOverflowLine if dragged via cursor.
            dlg.BAOverflowLineDragged = value;
        end
        
        function setUnderflowLineDragged(dlg,value)
        % Set the value of BAUnderflowLine if dragged via cursor.
            dlg.BAUnderflowLineDragged = value;
        end
        
        function setSignedPromptColor(dlg,clrPrompt,clrPulldown,clrText)
        % Set color of signed prompt and widget for warning state
            set(dlg.hBASignedPrompt,...
                'BackgroundColor',clrPrompt,...
                'ForegroundColor',clrText);
            set(dlg.hBASigned,...
                'BackgroundColor',clrPulldown,...
                'ForegroundColor',clrText);
        end
        
        function setSignedMode(dlg, varargin)
        % Update .IsSigned based on user-selected OptionsSigned mode
        % and past histogram data
        if nargin < 2
            dlg.BASigned = get(dlg.hBASigned,'Value');
        elseif ~isempty(varargin)
            if ischar(varargin{1})
                dlg.BASigned = sscanf(varargin{1},'%d');
            else
                dlg.BASigned = varargin{1};
            end
            set(dlg.hBASigned,'Value',dlg.BASigned);
        end
        end
        
        
        function y = getRoundingMode(dlg)
        % Get the rounding mode from the widget.
            y = dlg.BARounding;
        end
    end
    
    methods (Static)
       % Check value entered on the edit boxes. 
       isValid = isInputValueValid(value, option) 
    end
        
    
    methods (Access=protected)
        % Implement part of create() method defined by Dialog class
        createContent(dlg,hParent)
    end
    
    methods (Access=private)
        % Private methods in external files
        createFLSubdialog(dlg,hPanel)
        createILSubdialog(dlg,hPanel)
        createILFLSubdialog(dlg,hPanel)
        setBAFLWidgets(dlg)
        setBAILWidgets(dlg)
        setBAILFLWidgets(dlg)
    end
    
    methods (Access=private)
        % Enable/disable/hide widget panels
        
        function disableBAFLPanel(dlg)
            % Disable interactive Fraction Length panel controls

            hChild = get(dlg.hBAFLPanel,'Children');
            set(hChild,'Visible','off');
            % Only enable extra bits when Word Length is unspecified and
            % Graphical mode is turned on.
            if (dlg.BAWLMethod == 1) && dlg.BAGraphicalMode
                % Make the Extra FL Bits widget visible if graphical mode
                % is turned on.
                set([dlg.hBAFLExtraBitsPrompt dlg.hBAFLExtraBits],'Visible','on');
            end
        end
        
        function disableBAILPanel(dlg)
            %Disable the panel
            set(dlg.hBAILPanel,'Visible','off');
            
            % Disable normal Integer Length panel controls
            hChild = get(dlg.hBAILPanel,'Children');
            set(hChild,'Visible','off');
            % Only enable extra bits when Word Length is unspecified and
            % Graphical mode is turned on.
            if (dlg.BAWLMethod == 1) && dlg.BAGraphicalMode
                %Enable  the panel as its children needs to be visible
                set(dlg.hBAILPanel,'Visible','on');
                % Make the Extra IL Bits widget visible if graphical mode
                % is turned on.
                set([dlg.hBAILGuardBitsPrompt dlg.hBAILGuardBits],'Visible','on');
            end
        end
        
        function disableBAWLPanel(dlg)
            % Disable normal Word Length panel controls
            set(dlg.hBAWLValuePrompt,'Visible','off','Enable','off');
            set(dlg.hBAWLBits,'Visible','off','Enable','off');
        end
        
        function disableBAILFLPanel(dlg)
            % Disable normal IL/FL panel controls
            hChild = get(dlg.hBAILFLPanel,'Children');
            set(hChild,'Visible','off');
            set(dlg.hBAILFLPanel,'Visible','off');
        end
        
        function enableBAWLPanel(dlg)
        % Enable normal Word Length panel controls
            set(dlg.hBAWLValuePrompt,'Visible','on','Enable','inactive');
            set(dlg.hBAWLBits,'Visible','on','Enable','on');
        end
        
        function enableBAILFLPanel(dlg)
            %Enable normal IL/FL panel controls
            set(dlg.hBAILFLPanel,'Visible','on');
        end
       
        function hideBAWLPanel(dlg)
            % Make Word Length panel controls invisible
            hChild = get(dlg.hBAWLPanel,'Children');
            set(hChild,'Enable','off');
            h = [dlg.hBAWLPrompt dlg.hBAWLMethod dlg.hBAWLValuePrompt ...
                dlg.hBAWLBits];
            set(h,'Visible','off');
        end
    end
    
    methods (Hidden)
        % React to changes in widget values
        
        function updateProperty(dlg, msg)
            fields = fieldnames(msg);
            for i = 1:length(fields)
                propertyName = fields{i};
                switch propertyName
                    case 'BASigned'
                        dlg.setSignedMode(msg.(fields{i}));
                    case 'BAWLMethod'
                        dlg.setBAWLMethod(msg.(fields{i}));
                    case 'BAWLBits'
                        dlg.setBAWLBits(msg.(fields{i}));
                    case 'BAFLMethod'
                        dlg.setBAFLMethod(msg.(fields{i}));
                    case 'BAFLSpecifyMagnitude'
                        dlg.setBAFLMagEdit([],msg.(fields{i}));
                    case 'BAFLSpecifyBits'
                        dlg.setBAFLBits(msg.(fields{i}));
                    case 'BAFLExtraBits'
                        dlg.setBAFLExtraBits(msg.(fields{i}));
                    case 'BAILMethod'
                        dlg.setBAILMethod(msg.(fields{i}));
                    case 'BAILPercent'
                        dlg.setBAILPercent([],msg.(fields{i}));
                    case 'BAILCount'
                        dlg.setBAILCount([],msg.(fields{i}));
                    case 'BAILUnits'
                        dlg.setBAILUnits([],msg.(fields{i}));
                    case 'BAILSpecifyMagnitude'
                        dlg.setBAILMagEdit([],msg.(fields{i}));
                    case 'BAILSpecifyBits'
                        dlg.setBAILSpecifyBits([],msg.(fields{i}));
                    case 'BAILGuardBits'
                        dlg.setBAILGuardBits(msg.(fields{i}));
                    case 'BAILFLMethod'
                        dlg.setBAILFLMethod(msg.(fields{i}));
                end
            end
        end
        
        function setBAFLCount(dlg)
             str = get(dlg.hBAFLCount,'String');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
                % Invalid value; replace old value into edit box
                val = dlg.BAFLCount;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidUnderflowCount')), ...
                    getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
            end
            set(dlg.hBAFLCount,'String',sprintf('%d',val));
            dlg.BAFLCount = val; % record value last, triggers event
        end
        
        function setBAFLMagEdit(dlg,h,varargin)
            % Two widgets use this method as a callback. The smallest
            % magnitude widget in the ILFL joint panel and the FL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAFLSpecifyMagnitude
            % or dlg.hBAILFLSpecifyLSBMagnitude
            if ~isempty(h)
                str = get(h,'String');
                val = sscanf(str,'%f');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    val = sscanf(varargin{1},'%f');
                end
            end
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val, 'allowNonIntegerValues')) || (val == 0)
                % Invalid value; replace old value into edit box
                val = dlg.BAFLSpecifyMagnitude;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidFLMagnitude')), ...
                    getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
            end
            
            % Update dialog edit box
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAFLSpecifyMagnitude,'String',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyLSBMagnitude,'String',sprintf('%g',val));
            dlg.BAFLSpecifyMagnitude = val; % record value last, triggers event
        end
        
        function setBAFLMethodTooltip(dlg)
            switch dlg.BAFLMethod
              case 1 % Smallest magnitude
                flm_tip = getString(message('fixed:NumericTypeScope:SmallestMagMethodToolTip'));
              case 2 % Specify Bits
                flm_tip = getString(message('fixed:NumericTypeScope:FLBitsToolTip'));
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                error(message('fixed:NumericTypeScope:invalidBAFLMethod', dlg.BAFLMethod));
            end
            set(dlg.hBAFLMethod,'TooltipString',flm_tip);
        end
        
        function setBAFLPercent(dlg)
            str = get(dlg.hBAFLPercent,'String');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNonIntegerValues')) || val>100
                % Invalid value; replace old value into edit box
                val = dlg.BAFLPercent;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidUnderflowPcnt')), ...
                    getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
            end
            set(dlg.hBAFLPercent,'String',sprintf('%g',val));
            dlg.BAFLPercent = val; % record value last
        end
        
        function setBAFLSpecifyBits(dlg,h)
            % Two widgets use this method as a callback. The fractional
            % bits widget in the ILFL joint panel and the FL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAFLSpecifyBits
            % or dlg.hBAILFLSpecifyBits
            str = get(h,'String');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNegValues'))
                % Invalid value; replace old value into edit box
                %val = dlg.BAFLSpecifyBits;
                errordlg(getString(message('fixed:NumericTypeScope:FractionLengthInvalidValue')), ...
                    getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
            else
                dlg.BAFLSpecifyBits = val;
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAFLSpecifyBits,'String',sprintf('%g',dlg.BAFLSpecifyBits));
            set( dlg.hBAILFLSpecifyFLBits,'String',sprintf('%g',dlg.BAFLSpecifyBits));
        end
        
        function setBAFLUnits(dlg)
            % Two widgets use this method as a callback. The max
            % underflow widget in the ILFL joint panel and the FL panel.
            dlg.BAFLUnits = get(dlg.hBAILFLUnits,'Value');
        end
        
        function setBAILCount(dlg,h,varargin)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILCount or dlg.hBAILFLCount
            if ~isempty(h)
                str = get(h,'String');
                val = sscanf(str,'%f');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    val = sscanf(varargin{1},'%f');
                end
            end
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
                % Invalid value; replace old value into edit box
                val = dlg.BAILCount;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidOverflowCount')), ...
                        getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')),'modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILCount,'String',sprintf('%d',val));
            set(dlg.hBAILFLCount,'String',sprintf('%d',val));
            dlg.BAILCount = val; % record value
        end
        
        function setBAILMagEdit(dlg,h,varargin)
            % Two widgets use this method as a callback. The Largest
            % magnitude widget in the ILFL joint panel and the IL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAILSpecifyMagnitude
            % or dlg.hBAILFLSpecifyMagnitude
            
            % Change in Integer Length (IL) Maximum Magnitude edit box
            if ~isempty(h)
                str = get(h,'String');
                val = sscanf(str,'%f');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    val = sscanf(varargin{1},'%f');
                end
            end
            % Do not attempt to constrain edit box value to >= LSB (underflow cursor)
            % That's because the LSB is dynamic and may change over time.  We are not
            % going to reject the edit box value here based on a dynamic LSB.  We
            % handle clipping of the recommendation elsewhere.
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val)) || (val == 0)
                % Invalid value; replace old value into edit box
                val = dlg.BAILSpecifyMagnitude;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidILMagnitude')), ...
                    getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')),'modal');
            end
            % Update dialog edit box
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILSpecifyMagnitude,'String',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyMSBMagnitude,'String',sprintf('%g',val));
            dlg.BAILSpecifyMagnitude = val; % record value
        end
        
        function setBAILMethodTooltip(dlg)
            % Set tooltip for Bit Allocation Integer Length popup tooltip
            switch dlg.BAILMethod
              case 1 % Specify Overflow
                ilm_tip = getString(message('fixed:NumericTypeScope:OverflowToolTip'));
              case 2 % Specify Magnitude
                ilm_tip = getString(message('fixed:NumericTypeScope:LargestMagToolTip'));
              case 3 % Specify bits
                ilm_tip = getString(message('fixed:NumericTypeScope:ILBitsToolTip'));
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                error(message('fixed:NumericTypeScope:invalidBAILMethod',dlg.BAILMethod));
            end
            set(dlg.hBAILMethod,'TooltipString',ilm_tip);
        end
        
        function setBAILFLMethodTooltip(dlg)
        % Set the tooltip for the BAILFL joint optimization
        % popup choices.
            switch dlg.BAILFLMethod % .BAILMethod
              case 1 % Maximum Overflow
                ilm_tip = getString(message('fixed:NumericTypeScope:OverflowToolTip'));
              case 2 % Largest Magnitude
                ilm_tip = getString(message('fixed:NumericTypeScope:LargestMagToolTip'));
              case 3 % Set Integer bits
                ilm_tip = getString(message('fixed:NumericTypeScope:ILBitsToolTip'));
              case 4 % Smallest magnitude
                ilm_tip = getString(message('fixed:NumericTypeScope:SmallestMagMethodToolTip'));
              case 5 % Set Fraction bits
                ilm_tip = getString(message('fixed:NumericTypeScope:FLBitsToolTip'));
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                error(message('fixed:NumericTypeScope:invalidBAILFLMethod',dlg.BAILFLMethod));
            end
            set(dlg.hBAILFLMethod,'TooltipString',ilm_tip);
        end
        
        function setBAILPercent(dlg,h,varargin)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILPercent or dlg.hBAILFLPercent
            if ~isempty(h)
                str = get(h,'String');
                val = sscanf(str,'%f');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    val = sscanf(varargin{1},'%f');
                end
            end
                
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNonIntegerValues')) || val>100
                % Invalid value; replace old value into edit box
                val = dlg.BAILPercent;
                errordlg(getString(message('fixed:NumericTypeScope:InvalidOverflowPcnt')), ...
                    getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')), 'modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILPercent,'String',sprintf('%g',val));
             set(dlg.hBAILFLPercent,'String',sprintf('%g',val));
            dlg.BAILPercent = val; % record value
        end
        
        function setBAILSpecifyBits(dlg,h,varargin)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILSpecifyBits or
            % dlg.hBAILFLSpecifyBits
            if ~isempty(h)
                str = get(h,'String');
                val = sscanf(str,'%f');
            elseif ~isempty(varargin)
                if ischar(varargin{1})
                    val = sscanf(varargin{1},'%f');
                end
            end
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNegValues'))
                % Invalid value; replace old value into edit box
                val = dlg.BAILSpecifyBits;
                errordlg(getString(message('fixed:NumericTypeScope:IntegerLengthInvalidValue')), ...
                    getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')),'modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILSpecifyBits,'String',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyILBits,'String',sprintf('%g',val));
            dlg.BAILSpecifyBits = val; % record value
        end
    end
end

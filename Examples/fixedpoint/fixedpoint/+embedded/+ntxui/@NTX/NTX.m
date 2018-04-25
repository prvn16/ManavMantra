classdef NTX < handle
    % Numeric Type Explorer class.
    % Supports Numeric Type Explorer UI.

    %   Copyright 2010-2017 The MathWorks, Inc.

    properties (Hidden)
        Subscriptions; % Unsubscribe during deletion
        %Channel to publish Data
        SubscribeChannel = '/fxp_histogram_receive';
        PublishChannel = '/fxp_histogram_send';
    end

    properties (SetAccess=private, Hidden)
        hFig       % handle to HG figure - copied from DialogPanel
        dp         % handle to DialogPanel object
        hHistAxis  % kept in pixel units
    end
    
    properties (Access=private)
        % Properties that are internal state of basic NTX UI
        % These do not directly control observable elements of the UI
        
        hParent    % handle to top-level DialogPanel panel object (copied from dp)
        hTicks     % vector of text widgets handles
        htXLabel
        htTitle
        htSigned
        htNoHistoTxt
        hOffscreenText
        hBar       % barplot handle, positive+negative
        hBarNeg    % barplot handle, negative only
        hBarPos    % barplot handle, positive only
        hlSignLine % overlay line handle
        BinCountVerticalUnitsStr = '' % 'thousands', etc
        
        BlankIcon
        WarnIcon
        
        IsSigned = false  % gets updated in updateSignedStatus()
        
        % Half-width of gap between histogram bars
        % Often used so we compute and cache this for efficient access
        BarGapCenter
        
        % How to treat "small" negative values: underflow or overflow?
        % (negative values with magnitudes < eps in the given data type, such that
        % rounding could force them to zero)
        % This is set based on the rounding mode (floor, ceil, nearest, etc)
        SmallNegAreOverflow = false
        
        % Enable dragging of horizontal word-size line
        EnableWordSizeLineDrag = false
        
        % Record axis margins, in pixels
        %   [ left_margin_pix, bottom_margin_pix, ...
        %     right_margin_pix, top_margin_pix ]
        Margins
        
        % Out-of-range bin indicators (vector of 2 handles)
        hXRangeIndicators
        
        % Scale factor in range [0,1]
        % Sets maximum Y-axis placement of peak of histogram data
        %   0=half display height
        %   1=just below lowest readout text line (under/overflow text)
        DataPeakYScaling = 1.0
        
        % Allow x-axis to autoscale the displayed limits
        %
        XAxisAutoscaling = true
        XAxisDisplayMin
        XAxisDisplayMax
        
        % Track mouse transitions from outside to inside axes
        % and vice-versa.  This influences the axes display,
        % locking the x-axis scaling, etc
        %
        MouseInsideAxes = false
        
        % Used to suppress updates of the vertical axis units-string
        % (e.g., 'Thousands', 'Millions', etc)
        % Normal range is an integer >= 0
        % Default is -1, which won't match any new value and forces a change
        LastYAxisPowerOf1000 = -1
        
        % Establish RadixPt position
        % This is the x-axis point at which the radix line should appear.
        % Graphical measurements relative to the radix are based on this value.
        % This does NOT include the gap-width "below" start of 2^0 bin
        % The Radix point is between 2^-1 & 2^0. The binary point is to the
        % right of 2^0 and left of 2^-1.
        RadixPt = 0 % binary point just to the right of 0. 
        
    end
    
    properties (SetAccess=private)
        % Histogram data state
        
        % Histogram states
        NegBinCounts = 0 % # of neg values in this (abs val) bin
        PosBinCounts = 0 % # of pos values in this (abs val) bin
        BinCounts    = 0  % a bit redundant: combined pos+neg count vector
        BinEdges     = 0
        
        % Data counts
        DataCount    = 0  % number of data values (scalars) since last reset
        DataZeroCnt  = 0  % number of zeros in data
        DataPosCnt   = 0  % number of positive values in data
        DataNegCnt   = 0  % number of negative values in data
        
        % Statistics
        DataMax    = [] % maximum positive value; must preset to empty
        DataMin    = [] % maximum negative value; must preset to empty
        DataSum    = 0  % Sum of (possibly signed) data
        SSQ        = 0  % Sum of Squared Data (for SNR)
        SSQE       = 0  % Sum of Squared Quantization Error (for SNR)
        NumSSQE    = 0  % Independent sample count for SSQE/SNR
    end
    
    properties (SetAccess=private)
        % Object to compute envelope preprocessor
        PreprocEnvelope
    end
    
    properties
        % Handles to Dialog subclasses
        hLegendDialog
        hResultingTypeDialog
        hInputDataDialog
        hOptionsDialog
        hBitAllocationDialog
    end
    
    properties (Access=private)
        % Internal properties specific to data type explorer overlay
        
        hlOver    % Overflow line
        htOver    % Overflow text
        hlUnder   % Underflow line
        htUnder   % Underflow text
        
        LastOver   % Last value of overflow threshold
        LastUnder  % Last value of underflow threshold
        
        % Flag to indicate if integer bits accounted for the extra IL bits
        % specified.
        wasExtraMSBBitsAdded = false 
        
        % Flag to indicate if fractional bits accounted for the extra FL
        % bits specified.
        wasExtraLSBBitsAdded = false 
        
        % Line drag state: 0=neither, 1=under, 2=over
        % Used during drag (drag events while mouse is down)
        WhichLineDragged = 0 
        
        % Used to break tie when both cursors coincide along x-axis
        WhichLineDraggedLast = 1
        
        % Caches x-coord of drag on wordlength region
        % for locked-cursor (constant WL) drag
        DragWordLengthRegion
        
        LockThresholds = false  % synchronize threshold cursors
        yWordSpan               % y-coord of word line
        
        % Handles to graphical overlays
        hlRadixLine   % vertical line indicating radix point
        hlWordSpan    % horizontal line spanning word size
        htWordSpan    % text object above word size line
        htIntSpan     % text under word span denoting integer size
        htFracSpan    % text under word span denoting fraction size
        
        % For vertical rescaling via mouse-drag on WordSpan line
        % Used as state for current and next vertical position
        %
        % Requires empty as default value
        LastDragWordSizeLine
    end
    
    properties (SetAccess=private)
        % Properties that directly reflect observable elements of UI
        
        % FIGURE
        % ------
        ColorFixedLine       = [.6 .6 .6]  % gray
        ColorManualThreshold = [0 .7 0]    % green
        ColorAutoThreshold   = [0 0 0]     % black
        ColorOverflowBar     = [.7 .2 .2]  % red
        ColorNormalBar       = [0 0 .75]   % blue
        ColorUnderflowBar    = [.9 .9 0]   % yellow
        % [.6 .2 .2]   % dark red
        % [.8 .55 .25] % orange
        % [1 .65 .15] % orange
        
        % HISTOGRAM
        % ---------
        % Width of histogram bars in data units
        % The bar-to-bar data distance is always 1
        % BarWidth should be in the range (0,1]
        HistBarWidth = .75
        
        % Offset of histogram bars in data units
        % The bar starts with an offset and ends at the next bin edge. 
        HistBarOffset = .25
        
        % Define display units for vertical axis
        % 1 = Percentage
        % 2 = Bin count
        HistVerticalUnits = 1
        
        % Ignore saturated (overflow) values in SQNR computation
        OptionIgnoreOverflowInSQNR = true
        
        % DTX SYSTEM
        % ----------
        
        % Fractional and Integer span options
        % 1 = Integer length
        % 2 = MSB
        DTXIntSpanText = 1 % no user-affordance dedicated to this
        
        % Fractional span options
        % 1 = Fraction length
        % 2 = Scale factor
        DTXFracSpanText = 1
    end
    
    events (NotifyAccess=private)
        UpdateNTXMenusOnVerticalUnitsChange
    end
    
     methods
        function h = NTX(varargin)
            % Construct a NumericType Explorer object.
            %
            % NTX(hUser) initializes NTX object to create UI within uipanel
            % specified by handle hUser.
            %
            % NTX(hUser,userOpts) specifies initial values for properties
            % within NTX.
            if nargin>0
                init(h,varargin{:});
            end
            connector.ensureServiceOn;
            h.Subscriptions = message.subscribe(h.SubscribeChannel, @(msg)updateNTX(h, msg));
        end
        
        function delete(this)
            message.unsubscribe(this.SubscribeChannel);
            this.Subscriptions = [];
        end
    end
    
    methods (Access=private)
        % Declare a few private methods
        
        updateHistBarPlot(ntx)
        bins = getBinsForData(ntx, data);
        overlayNegBarsIfUnsigned(ntx,negVal,xp,zp)
        overlayPosBarsIfSigned(ntx,posVal,xp,zp)
        loadCustomUserSettings(ntx,s)
        resetDataHist(ntx)
        updateSmallNegAreOverflow(ntx)
        updateSignedStatus(ntx)
        
        
        y = extraBitsSelected(ntx)
        y = extraLSBBitsSelected(ntx)
        y = extraMSBBitsSelected(ntx)
        
        updateWordTextAndXPos(ntx)
        enableMouse(ntx)
        updateDTXTextYPos(ntx)
        updateDTXLinesYPos(ntx)
        updateDTXTextAndLinesYPos(ntx)
        initHistDisplay(ntx)
        updateNumericTypesAndSigns(ntx)
        updateSNRForNumericTypeChange(ntx,isFirstUpdate)
        y = validUnderflowXDrag(ntx,v)
        y = validOverflowXDrag(ntx,v)
        updateBarThreshColor(ntx)
        updateUnderflowTextAndXPos(ntx)
        updateOverflowTextAndXPos(ntx)
        updateIntTextAndXPos(ntx)
        updateFracTextAndXPos(ntx)
        updateRadixLineYExtent(ntx)
        updateInteractiveMagLinesAndReadouts(ntx,newOverExp,newUnderExp)
        updateThresholds(ntx,xq)
        updateDTXHistReadouts(ntx)
        resetThresholds(ntx)
        resizeBody(ntx)
        updateSignedTextYPos(ntx)
        adjustHistAxisSize(ntx)
        s = findMinXTickSpacing(hParent,xMin,xMax)
        checkXAxisLock(ntx)
        holdXAxisLimits(ntx,hold)
        setXAxisLimits(ntx,xmin,xmax)
        updateXTickLabels(ntx,forceYUpdate)
        updateXAxisTextPos(ntx)
        createXAxisTicks(ntx)
        updateDTXState(ntx)
        
        performAutoBA(ntx)
        performAutoBA_SQNRforIL(ntx)
        performAutoBA_WLforIL(ntx)
        performAutoBA_WLforFL(ntx)
        wasILUpdated = performAutoBA_ILonly(ntx,flag)
        wasFLUpdated = performAutoBA_FLonly(ntx,flag)
        
        bcnt = getUnderflowCounts(ntx)
        
        updateDTXControls(ntx)
        updateOverflowLineColor(ntx)
        updateUnderflowLineColor(ntx)
        
        changeDTXFracSpanText(ntx,hThisMenu)
        [posVal,negVal] = getBarData(ntx)
        setDisplayDecimation(ntx)
        resizeXRangeIndicators(ntx)
        buildAxisContextMenu(ntx)
        buildContextMenu(ntx,hMainContext)
        hp = createOutOfRangeBins(ntx,hax,htXLabel,rgbUnder,rgbOver)
        showOutOfRangeBins(ntx)
        setYAxisLimits(ntx)
        updateYAxisTitle(ntx)
        datatypeChanged(ntx)
        
        createAppSpecificDialogs(ntx)
        createDTX(ntx)
        createHistogramUI(ntx)
        initMainGUIParts(ntx)
        changeVerticalUnitsOption(ntx,hThisMenu)

    end
    
    methods (Static)
        ntx = createGUI(hUser,userOpts)
        underStr = getFormattedUnderMagText(underExp)
        overStr = getFormattedOverMagText(overExp)
        [hb,hl] = dynamicBar(hax,width,offset,xrange,rgb)
        [xp,zp,xl,zl,cp] = createXBarData(x,binwidth,offset,rgb)
    end
    
    methods (Hidden)
        isFirstUpdate = updateHistData(ntx,data,dataTypeObject)
        function data = getHistogramData(ntx)
            % Packs the data required to draw the histogram
           [intBits,fracBits,wordBits,isSigned] = getWordSize(ntx,1);
           if ~isempty(wordBits)
                Tx = numerictype('Signed',isSigned,'WordLength',wordBits,...
                    'FractionLength',fracBits,'DataTypeOverride','Off');
                try
                    fiObj = fi(0,Tx);
                    [qlowerbound, qupperbound] = range(fiObj);
                    qlowerbound = double(qlowerbound);
                    qupperbound = double(qupperbound);
                catch ntx_exception %#ok<NASGU>
                end
            end
           data = struct('NegBinCounts', ntx.NegBinCounts,...
                'PosBinCounts', ntx.PosBinCounts,...
                'BinCounts', ntx.BinCounts,...
                'BinEdges', ntx.BinEdges,...
                'DataCount', ntx.DataCount,...
                'DataZeroCnt', ntx.DataZeroCnt,...
                'DataPosCnt', ntx.DataPosCnt,...
                'DataNegCnt', ntx.DataNegCnt,...
                'DataMax', ntx.DataMax,...
                'DataMin', ntx.DataMin,...
                'DataSum', ntx.DataSum,...
                'SSQ', ntx.SSQ,...
                'LastOver', ntx.LastOver,...
                'LastUnder', ntx.LastUnder,...
                'wasExtraMSBBitsAdded', ntx.wasExtraMSBBitsAdded,...
                'wasExtraLSBBitsAdded', ntx.wasExtraLSBBitsAdded,...
                'NumericTypeStr', ntx.getNumericTypeStrs,...
                'TotalOverflows', ntx.getTotalOverflows,...
                'TotalUnderflows', ntx.getTotalUnderflows,...
                'WordLength', wordBits,...
                'IntLength', intBits,...
                'FracLength', fracBits,...
                'isSigned', isSigned,...
                'LowerBound', qlowerbound,...
                'UpperBound', qupperbound,...
                'SNR', ntx.getSNR);
        end
        
        function value = getValue(ntx,propertyName)
            % Returns the value of the property specified
            value = ntx.(propertyName);
        end
        
        function data = packData(this)
            data = this.getHistogramData;
            % message.publish(this.PublishChannel, data);
        end
        
        function updateNTX(this, msg)
            % Processes the change that occured on the user-interface
            % and calls the appropriate method to handle it.
            dlg = this.hBitAllocationDialog;
            if isfield(msg, 'ntx')
                switch msg.ntx.draggedLine
                    case '1'
                        updateInteractiveMagLinesAndReadouts(this,msg.ntx.LastOver,msg.ntx.LastUnder);
                        setUnderflowLineDragged(dlg, true);
                        setOverflowLineDragged(dlg, false);
                    case '2'
                        updateInteractiveMagLinesAndReadouts(this,msg.ntx.LastOver,msg.ntx.LastUnder);
                        setUnderflowLineDragged(dlg, false);
                        setOverflowLineDragged(dlg, true);
                end
                updateNumericTypesAndSigns(this);
                if (dlg.BAWLMethod == 2)
                    performAutoBA(this);
                end
                updateDTXHistReadouts(this);
                data = this.packData;
                message.publish(this.PublishChannel, data);
                    
                %msg.ntx.LastOver
                %msg.ntx.LastUnder
            elseif isfield(msg, 'BAWidget')
                dlg.updateProperty(msg.BAWidget);
                data = this.packData;
                message.publish(this.PublishChannel, data);
            end
            
        end
    end
end

function setBAFLExtraBits(dlg,val)
% Set Bit Allocation Fraction Length extra bits
% Both the IL/FL joint optimization widget and FL panel invoke this
% callback to set the extra bits via the dialog.

%   Copyright 2010-2014 The MathWorks, Inc.

if nargin<2
    str = get(dlg.hBAFLExtraBits,'String');
    val = sscanf(str,'%f');
elseif ~isequal(val,0) && embedded.ntxui.isHGHandleOfType(val,'uicontrol') 
    % If the value is 0, ishghandle will return true since it thinks 0 is
    % the root. Check if the handle to the widget is passed in via callback
    % is a valid hghandle only if the value is non-zero.
    str = get(val,'String');
    val = sscanf(str,'%f');
elseif ischar(val)
    val = sscanf(val,'%f');
end

if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
    % Invalid value; replace old value into edit box
    val = dlg.BAFLExtraBits;
    errordlg(getString(message('fixed:NumericTypeScope:InvalidExtraFLBits')),...
        getString(message('fixed:NumericTypeScope:FracLengthDialogName')),'modal');
end
if(dlg.BAWLMethod == 1) % Auto
    % check if the amount of extra bits requested puts the word length limit
    % beyond 65535.
    [intBits,fracBits,~,~] = getWordSize(dlg.UserData,true);
    % fracBits includes the extra bits, so negate it from the fracBits to
    % get the actual fractional bits.Also account for 1 sign bit
    % irrespective of the signedness of data. One can explicitly change the
    % sign bit to "signed" when data is unsigned.
    maxExtraBits = 65535-intBits-(fracBits-dlg.BAFLExtraBits);
    if val > maxExtraBits
        warndlg(getString(message('fixed:NumericTypeScope:LargeExtraFLBitLength',...
            val,maxExtraBits,65535)),...
            getString(message('fixed:NumericTypeScope:FracLengthDialogName')),'modal');
        val = maxExtraBits;
    end        
end

dlg.BAFLExtraBits = val; % record value
str = sprintf('%d',dlg.BAFLExtraBits); % replace string (removes spaces, etc)
set(dlg.hBAFLExtraBits,'String',str);
set(dlg.hBAILFLExtraBits,'String',str);

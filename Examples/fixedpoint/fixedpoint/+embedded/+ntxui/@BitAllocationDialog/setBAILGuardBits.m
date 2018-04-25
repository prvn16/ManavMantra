function setBAILGuardBits(dlg,val)
% Set Bit Allocation Integer Length guard bits
% Both the IL/FL joint optimization widget and IL panel invoke this
% callback to set the guard bits via the dialog.

%   Copyright 2010-2014 The MathWorks, Inc.

if nargin<2
    str = get(dlg.hBAILGuardBits,'String');
    val = sscanf(str,'%f');
elseif ischar(val)
    val = sscanf(val,'%f');
elseif ~isequal(val,0) && embedded.ntxui.isHGHandleOfType(val,'uicontrol') 
    % If the value is 0, ishghandle will return true since it thinks 0 is
    % the root. Check if the handle to the widget passed in to the callback
    % is a valid hghandle only if the value is non-zero.
    str = get(val,'String');
    val = sscanf(str,'%f');
end
if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
    % Invalid value; replace old value into edit box
    val = dlg.BAILGuardBits;
    errordlg(getString(message('fixed:NumericTypeScope:InvalidExtraILBits')),...
        getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')), ...
        'modal');
end
if(dlg.BAWLMethod == 1) % Auto
    % check if the amount of extra bits requested puts the word length limit
    % beyond 65535.
    [intBits,fracBits,~,~] = getWordSize(dlg.UserData,true);
    % intBits includes the extra bits, so negate it from the intBits to get
    % the actual integer bits. Also account for 1 sign bit irrespective of
    % the signedness of data. One can explicitly change the sign bit to
    % "signed" when data is unsigned.
    maxGuardBits = 65535-(intBits-dlg.BAILGuardBits)-fracBits;
    if val > maxGuardBits
        warndlg(getString(message('fixed:NumericTypeScope:LargeExtraILBitLength',...
            val,maxGuardBits,65535)),...
            getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')), ...
            'modal');
        val = maxGuardBits;
    end        
end
dlg.BAILGuardBits = val; % record value
str = sprintf('%d',dlg.BAILGuardBits); % replace string (removes spaces, etc)
set(dlg.hBAILGuardBits,'String',str);
set(dlg.hBAILFLGuardBits,'String',str);

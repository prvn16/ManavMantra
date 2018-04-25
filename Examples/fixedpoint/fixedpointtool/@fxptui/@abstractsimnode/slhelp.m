function slhelp(this,handle)
%SLHELP   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

hDlgSource=this.getDialogSource;
if ~isempty(hDlgSource) && ismethod(hDlgSource,'slhelp')
    hDlgSource.slhelp(handle);
end


% [EOF]


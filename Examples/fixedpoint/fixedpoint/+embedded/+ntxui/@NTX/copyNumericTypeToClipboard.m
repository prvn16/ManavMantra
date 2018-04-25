function copyNumericTypeToClipboard(ntx)
% Copy numerictype text string into system clipboard
% for use with cut-and-paste.

%   Copyright 2010-2014 The MathWorks, Inc.

% Include guard- and precision-bits
[~,fracBits,wordBits,isSigned] = getWordSize(ntx,true);
dt = numerictype(isSigned, wordBits, fracBits);
str = dt.tostring;

% Place string into the OS-specific cut buffer, as if "cut" was invoked
% This way, the datatype can be pasted into any application.
com.mathworks.mwswing.datatransfer.MJClipboard.getMJClipboard.setContents(str,[]);

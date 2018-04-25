function enableBorrowUI(option)
%Enable or Disable the License Borrow UI option in menu the next time MATLAB starts.
%   enableBorrowUI(true) enables License Borrow UI option in the menu.
%   enableBorrowUI(false) disables License Borrow UI option in the menu.

%   Copyright 2013 The MathWorks, Inc.


% Arg checking
narginchk(1, 1);
nargoutchk(0, 0);

% Check argument datatype and call java interface with input option
if (~islogical(option))
    error('Input must be boolean - true or false');
end

try
	com.mathworks.mde.licensing.borrowing.BorrowUI.getInstance().enableFeature(option);
catch x
	error(x.message)
end



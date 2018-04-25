function display(obj, name) %#ok<DISPLAY> showing extra information.
%DISPLAY Display tall array.

% Copyright 2015-2017 The MathWorks, Inc.

if nargin < 2
    name = inputname(1);
else
    validateattributes(name, {'char','string'}, {'row'}, mfilename, 'name', 2);
end

if ~obj.ValueImpl.IsValid
    iPrintInvalidDisplay(name);
    return;
end

arrayInfo = matlab.bigdata.internal.util.getArrayInfo(obj);

if ~isempty(arrayInfo.Error)
    err = arrayInfo.Error;
    warning(message('MATLAB:bigdata:array:DisplayPreviewErrored', name, err.message));
end
context = matlab.bigdata.internal.util.DisplayInfo(name, arrayInfo);
displayImpl(obj.Adaptor, context, obj.ValueImpl);
end

% Print an invalid array display for cases where the underlying data is no
% longer valid, for example when the execution environment has been closed.
function iPrintInvalidDisplay(name)
formatSpacing = get(0,'FormatSpacing');
str = getString(message('MATLAB:bigdata:array:InvalidTall'));
if isequal(formatSpacing,'compact')
    fprintf('\n%s =\n    %s\n', name, str);
else
    fprintf('\n%s =\n\n    %s\n\n', name, str);
end
end

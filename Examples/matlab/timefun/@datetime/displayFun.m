function displayFun(this,objectname)

%   Copyright 2014-2016 MathWorks, Inc.

% nargin == 1 => disp(this)
% nargin == 2 => display(this)
maxWidth = matlab.internal.display.commandWindowWidth;
isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');

thisData = this.data;
sz = size(thisData);
% Use the string display to remove possible new lines from the format.
fmt = getDisplayFormat(this);
fmt = matlab.internal.display.truncateLine(fmt,2*numel(fmt));
pageSz = sz(1:2);
asChar = @(data) char(matlab.internal.datetime.formatAsString(data,fmt,this.tz,false,getDatetimeSettings('locale')));
dispPage = @(data) matlab.internal.datetime.displayPage(asChar(data),pageSz,isLoose,maxWidth);

if isempty(thisData)
    return;
end

if ismatrix(thisData)
    dispPage(thisData);
    if (isLoose), fprintf('\n'); end
else
    if (isLoose), fprintf('\n'); end
    NDsz = sz(3:end);
    subs = cell(1,length(NDsz));
    for p = 1:prod(NDsz)
        if (isLoose && p>1), fprintf('\n'); end
        [subs{:}] = ind2sub(NDsz,p);
        disp([objectname '(:,:' sprintf(',%d',subs{:}) ') =']);
        if (isLoose), fprintf('\n'); end
        dispPage(thisData(:,:,p));
        if (isLoose), fprintf('\n'); end
    end
end
end

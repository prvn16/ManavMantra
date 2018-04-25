function displayFun(this,objectname)

%   Copyright 2014-2016 The MathWorks, Inc.

% nargin == 1 => disp(this)
% nargin == 2 => display(this)
maxWidth = matlab.internal.display.commandWindowWidth;
isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');

theComponents = this.components;
sz = size(this);
pageSz = sz(1:2);
dispPage = @(components,p) matlab.internal.datetime.displayPage(asChar(components,p,this.fmt),pageSz,isLoose,maxWidth);

if prod(sz) == 0
    return;
end

if length(sz) == 2
    dispPage(theComponents,1);
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
        dispPage(theComponents,p);
        if (isLoose), fprintf('\n'); end
    end
end


function chars = asChar(components,p,fmt)
page = components;
if ~isscalar(components.months), page.months = page.months(:,:,p); end
if ~isscalar(components.days), page.days = page.days(:,:,p); end
if ~isscalar(components.millis), page.millis = page.millis(:,:,p); end
chars = strjust(char(cellstr(calendarDuration.formatAsString(page,fmt,true))),'right');

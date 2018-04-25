function displayFun(this,objectname)

%   Copyright 2014-2016 MathWorks, Inc.

% nargin == 1 => disp(this)
% nargin == 2 => display(this)
maxWidth = matlab.internal.display.commandWindowWidth;
isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');
isLong = strncmp(matlab.internal.display.format,'long',4);

thisMillis = this.millis;
sz = size(thisMillis);
pageSz = sz(1:2);
asChar = @(millis) strjust(char(matlab.internal.duration.formatAsString(millis,this.fmt,isLong,false)),'right');
dispPage = @(millis) matlab.internal.datetime.displayPage(asChar(millis),pageSz,isLoose,maxWidth);

if isempty(thisMillis)
    return;
end

if ismatrix(thisMillis)
    dispPage(thisMillis);
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
        dispPage(thisMillis(:,:,p));
        if (isLoose), fprintf('\n'); end
    end
end

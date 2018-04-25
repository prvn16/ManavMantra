function y = wkeep2(x,siz,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(2,4);
coder.internal.prefer_const(varargin);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.indexInt(size(x,2));
if nargin >= 3
    optInput = varargin{1};
    if isnumeric(optInput)
        coder.internal.assert(numel(optInput) >= 2,'MATLAB:badsubscript');
        opt1 = optInput(1);
        opt2 = optInput(2);
    elseif isempty(optInput)
        opt1 = 'c';
        opt2 = 'c';
    else
        opt1 = lower(optInput(1));
        opt2 = opt1;
    end
    if nargin == 3
        if ischar(optInput)
            sideInput = optInput(2:end);
        else
            sideInput = '00';
        end
    else
        sideInput = varargin{2};
    end
    if isempty(sideInput)
        side1 = '0';
        side2 = '0';
    elseif isscalar(sideInput)
        side1 = sideInput(1);
        side2 = 'l';
    else
        side1 = sideInput(1);
        side2 = sideInput(2);
    end
else
    opt1 = 'c';
    opt2 = 'c';
    side1 = '0';
    side2 = '0';
end
[firstRow,lastRow] = wkeepFirstLastIndex(mx,siz(1),opt1,side1);
[firstCol,lastCol] = wkeepFirstLastIndex(nx,siz(2),opt2,side2);
y = x(firstRow:lastRow,firstCol:lastCol,:);

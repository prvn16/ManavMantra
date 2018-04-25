function RGB = demosaic(I, sensorAlignment) %#codegen
%DEMOSAIC Convert Bayer pattern encoded image to a truecolor image.

%   Copyright 2015-2017 The MathWorks, Inc.

validateattributes(I,{'uint8','uint16','uint32'},{'real','2d'}, mfilename, 'I',1);
sensorAlignment = validatestring(sensorAlignment, ...
    {'gbrg', 'grbg', 'bggr', 'rggb'}, mfilename, ...
    'sensorAlignment',2);

coder.internal.errorIf(~coder.internal.isConst(sensorAlignment),...
    'MATLAB:images:validate:codegenInputNotConst','sensorAlignment');

sizeI = size(I);
coder.internal.errorIf(sizeI(1) < 5 || sizeI(2) < 5, ...
    'images:demosaic:invalidImageSize');

Ipad = dualTierPad(I);

RGB = coder.nullcopy(zeros([size(I) 3],'like',I));

rOffset = coder.internal.indexInt(0);
gOffset = coder.internal.indexInt(numel(I));
bOffset = coder.internal.indexInt(numel(I)*2);

secondIdxLen = coder.internal.indexInt(size(I,2));
firstIdxLen = coder.internal.indexInt(size(I,1));

switch sensorAlignment
    case 'grbg'
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexInt(1);
        [RGB, Ipad] = green1(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexPlus(firstIdxLen,1);
        [RGB, Ipad] = red(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexInt(2);
        [RGB, Ipad] = blue(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexPlus(firstIdxLen,2);
        [RGB, Ipad] = green2(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad); %#ok<*ASGLU>
    case 'gbrg'
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexInt(1);
        [RGB, Ipad] = green2(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexPlus(firstIdxLen,1);
        [RGB, Ipad] = blue(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexInt(2);
        [RGB, Ipad] = red(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexPlus(firstIdxLen,2);
        [RGB, Ipad] = green1(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
    case 'rggb'
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexInt(1);
        [RGB, Ipad] = red(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexPlus(firstIdxLen,1);
        [RGB, Ipad] = green1(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexInt(2);
        [RGB, Ipad] = green2(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexPlus(firstIdxLen,2);
        [RGB, Ipad] = blue(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
    case 'bggr'
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexInt(1);
        [RGB, Ipad] = blue(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(3);
        position = coder.internal.indexPlus(firstIdxLen,1);
        [RGB, Ipad] = green2(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(3);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexInt(2);
        [RGB, Ipad] = green1(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
        secondIdxStart = coder.internal.indexInt(4);
        firstIdxStart = coder.internal.indexInt(4);
        position = coder.internal.indexPlus(firstIdxLen,2);
        [RGB, Ipad] = red(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position,...
            rOffset, gOffset, bOffset, RGB, Ipad);
        
    otherwise
        assert(false,'Invalid sensor alignment string');
end

function [RGB, Ipad] = red(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position, ...
    rOffset, gOffset, bOffset, RGB, Ipad)

handleResult = coder.nullcopy(zeros(1));
firstIdxLenPad = coder.internal.indexPlus(firstIdxLen,4);

% offset only when column elements/row count is odd,
% affecting position after subsequent column advance.
if (mod(firstIdxLen,2) > 0)
    if (mod(coder.internal.indexMinus(firstIdxStart,1),2) > 0)
        % one before: offset will be added
        positionOffset = -1;
    else
        % one past: offset will be subtracted
        positionOffset = 1;
    end
else
    %no offset needed
    positionOffset = 0;
end
%
% Indexing through the data steps to corresponded with the 4 pixel
% blocked nature of the Bayer sensor data, skipping dissimilarly
% banded pixels to operate correctly. Thus, += 2 is used for pixel
% position & row placement modifier, while += colEl is used to
% skip subsequent dissimilar band columns of pixel information.
for indexModifier = secondIdxStart:2:coder.internal.indexPlus(secondIdxLen,2)
    for index = coder.internal.indexPlus(coder.internal.indexTimes(coder.internal.indexMinus(indexModifier,1),firstIdxLenPad),firstIdxStart):2:coder.internal.indexMinus(coder.internal.indexTimes(indexModifier,firstIdxLenPad),2)
        RGB(coder.internal.indexPlus(position, rOffset)) = eml_cast(Ipad(index),class(RGB),'floor');
        handleResult(1) = ...
            (4 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index,2)) ...
            - Ipad(coder.internal.indexPlus(index,2)) ...
            - Ipad(coder.internal.indexMinus(index,coder.internal.indexTimes(firstIdxLenPad,2))) ...
            - Ipad(coder.internal.indexPlus(index,coder.internal.indexTimes(firstIdxLenPad,2))) ...
            + (2 * Ipad(coder.internal.indexMinus(index,1))) ...
            + (2 * Ipad(coder.internal.indexPlus(index,1))) ...
            + (2 * Ipad(coder.internal.indexMinus(index,firstIdxLenPad))) ...
            + (2 * Ipad(coder.internal.indexPlus(index,firstIdxLenPad)))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, gOffset)) = eml_cast(handleResult,class(RGB),'floor');
        handleResult(1) = ...
            (6 * Ipad(index)...
            - (3 * Ipad(coder.internal.indexMinus(index,2))) / 2.0 ...
            - (3 * Ipad(coder.internal.indexPlus(index,2))) / 2.0 ...
            - (3 * Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2)))) / 2.0 ...
            - (3 * Ipad(coder.internal.indexPlus(index, coder.internal.indexTimes(firstIdxLenPad,2)))) / 2.0 ...
            + 2 * Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1)))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, bOffset)) = eml_cast(handleResult,class(RGB),'floor');
        position = coder.internal.indexPlus(position,2);
    end
    position = coder.internal.indexPlus(position, coder.internal.indexMinus(firstIdxLen,positionOffset));
end

function [RGB, Ipad] = green1(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position, ...
    rOffset, gOffset, bOffset, RGB, Ipad)

handleResult = coder.nullcopy(zeros(1));
firstIdxLenPad = coder.internal.indexPlus(firstIdxLen,4);

% offset only when column elements/row count is odd,
% affecting position after subsequent column advance.
if (mod(firstIdxLen,2) > 0)
    if (mod(coder.internal.indexMinus(firstIdxStart,1),2) > 0)
        % one before: offset will be added
        positionOffset = -1;
    else
        % one past: offset will be subtracted
        positionOffset = 1;
    end
else
    %no offset needed
    positionOffset = 0;
end

for indexModifier = secondIdxStart:2:coder.internal.indexPlus(secondIdxLen,2)
    for index = coder.internal.indexPlus(coder.internal.indexTimes(coder.internal.indexMinus(indexModifier,1),firstIdxLenPad),firstIdxStart):2:coder.internal.indexMinus(coder.internal.indexTimes(indexModifier,firstIdxLenPad),2)
        handleResult(1) = ...
            (5 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            + Ipad(coder.internal.indexMinus(index,2)) / 2.0 ...
            + Ipad(coder.internal.indexPlus(index,2)) / 2.0 ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexTimes(firstIdxLenPad,2))) ...
            + 4 * Ipad(coder.internal.indexMinus(index, firstIdxLenPad)) ...
            + 4 * Ipad(coder.internal.indexPlus(index, firstIdxLenPad))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, rOffset)) = eml_cast(handleResult,class(RGB),'floor');
        RGB(coder.internal.indexPlus(position, gOffset)) = eml_cast(Ipad(index),class(RGB),'floor');
        handleResult(1) = ...
            (5 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index,2)) ...
            - Ipad(coder.internal.indexPlus(index,2)) ...
            + Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2))) / 2.0 ...
            + Ipad(coder.internal.indexPlus(index, coder.internal.indexTimes(firstIdxLenPad,2))) / 2.0 ...
            + 4 * Ipad(coder.internal.indexMinus(index,1)) ...
            + 4 * Ipad(coder.internal.indexPlus(index,1))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, bOffset)) = eml_cast(handleResult,class(RGB),'floor'); 
        position = coder.internal.indexPlus(position,2);
    end
    position = coder.internal.indexPlus(position, coder.internal.indexMinus(firstIdxLen,positionOffset));
end

function [RGB, Ipad] = green2(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position, ...
    rOffset, gOffset, bOffset, RGB, Ipad)

handleResult = coder.nullcopy(zeros(1));
firstIdxLenPad = coder.internal.indexPlus(firstIdxLen,4);

% offset only when column elements/row count is odd,
% affecting position after subsequent column advance.
if (mod(firstIdxLen,2) > 0)
    if (mod(coder.internal.indexMinus(firstIdxStart,1),2) > 0)
        % one before: offset will be added
        positionOffset = -1;
    else
        % one past: offset will be subtracted
        positionOffset = 1;
    end
else
    %no offset needed
    positionOffset = 0;
end

for indexModifier = secondIdxStart:2:coder.internal.indexPlus(secondIdxLen,2)
    for index = coder.internal.indexPlus(coder.internal.indexTimes(coder.internal.indexMinus(indexModifier,1),firstIdxLenPad),firstIdxStart):2:coder.internal.indexMinus(coder.internal.indexTimes(indexModifier,firstIdxLenPad),2)
        handleResult(1) = ...
            (5 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index,2)) ...
            - Ipad(coder.internal.indexPlus(index,2)) ...
            + Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2))) / 2.0 ...
            + Ipad(coder.internal.indexPlus(index, coder.internal.indexTimes(firstIdxLenPad,2))) / 2.0 ...
            + 4 * Ipad(coder.internal.indexMinus(index,1)) ...
            + 4 * Ipad(coder.internal.indexPlus(index,1))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, rOffset)) = eml_cast(handleResult,class(RGB),'floor');
        RGB(coder.internal.indexPlus(position, gOffset)) = eml_cast(Ipad(index),class(RGB),'floor');
        handleResult(1) = ...
            (5 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            + Ipad(coder.internal.indexMinus(index,2)) / 2.0 ...
            + Ipad(coder.internal.indexPlus(index,2)) / 2.0 ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2))) ...
            - Ipad(coder.internal.indexPlus(index, coder.internal.indexTimes(firstIdxLenPad,2))) ...
            + 4 * Ipad(coder.internal.indexMinus(index,firstIdxLenPad)) ...
            + 4 * Ipad(coder.internal.indexPlus(index,firstIdxLenPad))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, bOffset)) = eml_cast(handleResult,class(RGB),'floor');
        position = coder.internal.indexPlus(position,2);
    end
    position = coder.internal.indexPlus(position, coder.internal.indexMinus(firstIdxLen,positionOffset));
end

function [RGB, Ipad] = blue(secondIdxLen, firstIdxLen, secondIdxStart, firstIdxStart, position, ...
    rOffset, gOffset, bOffset, RGB, Ipad)

handleResult = coder.nullcopy(zeros(1));
firstIdxLenPad = coder.internal.indexPlus(firstIdxLen,4);

% offset only when column elements/row count is odd,
% affecting position after subsequent column advance.
if (mod(firstIdxLen,2) > 0)
    if (mod(coder.internal.indexMinus(firstIdxStart,1),2) > 0)
        % one before: offset will be added
        positionOffset = -1;
    else
        % one past: offset will be subtracted
        positionOffset = 1;
    end
else
    %no offset needed
    positionOffset = 0;
end

for indexModifier = secondIdxStart:2:coder.internal.indexPlus(secondIdxLen,2)
    for index = coder.internal.indexPlus(coder.internal.indexTimes(coder.internal.indexMinus(indexModifier,1),firstIdxLenPad),firstIdxStart):2:coder.internal.indexMinus(coder.internal.indexTimes(indexModifier,firstIdxLenPad),2)
        handleResult(1) = ...
            (6 * Ipad(index) ...
            - (3.0 * Ipad(coder.internal.indexMinus(index,2))) / 2 ...
            - (3.0 * Ipad(coder.internal.indexPlus(index,2))) / 2 ...
            - (3.0 * Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2)))) / 2 ...
            - (3.0 * Ipad(coder.internal.indexPlus(index , coder.internal.indexTimes(firstIdxLenPad,2)))) / 2 ...
            + 2 * Ipad(coder.internal.indexMinus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexPlus(index, coder.internal.indexPlus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexMinus(index, coder.internal.indexMinus(firstIdxLenPad,1))) ...
            + 2 * Ipad(coder.internal.indexPlus(index, coder.internal.indexMinus(firstIdxLenPad,1)))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, rOffset)) = eml_cast(handleResult,class(RGB),'floor');
        handleResult(1) = ...
            (4 * Ipad(index) ...
            - Ipad(coder.internal.indexMinus(index,2)) ...
            - Ipad(coder.internal.indexPlus(index,2)) ...
            - Ipad(coder.internal.indexMinus(index, coder.internal.indexTimes(firstIdxLenPad,2))) ...
            - Ipad(coder.internal.indexPlus(index , coder.internal.indexTimes(firstIdxLenPad,2))) ...
            + 2 * Ipad(coder.internal.indexMinus(index,firstIdxLenPad)) ...
            + 2 * Ipad(coder.internal.indexPlus(index,firstIdxLenPad)) ...
            + 2 * Ipad(coder.internal.indexMinus(index,1)) ...
            + 2 * Ipad(coder.internal.indexPlus(index,1))) ...
            / 8.0;
        RGB(coder.internal.indexPlus(position, gOffset)) = eml_cast(handleResult,class(RGB),'floor');
        RGB(coder.internal.indexPlus(position, bOffset)) = eml_cast(Ipad(index),class(RGB),'floor');
        position = coder.internal.indexPlus(position,2);
    end
    position = coder.internal.indexPlus(position, coder.internal.indexMinus(firstIdxLen,positionOffset));
end


function b = dualTierPad(a)
% Pad the image size on all sides by an edge reflection of two rows or 
% columns. The corners are obtained by reflecting the padded edges. The 
% reflection is centered on the edge which is not reflected. This differs 
% from symmetric padding where the edge is also reflected. 

coder.inline('always');

b = coder.nullcopy(zeros((size(a) + 2*2),'double'));

colEl = size(a,1);
rowEl = size(a,2);

expColEl = colEl + 4;
expRowEl = rowEl + 4;

% upper left
b(1) = a(colEl * 2 + 3);
b(2) = a(colEl * 2 + 2);
b(expColEl + 1) = a(colEl + 3);
b(expColEl + 2) = a(colEl + 2);

% lower left
b(expColEl - 1) = a(colEl * 3 - 1);
b(expColEl) = a(colEl * 3 - 2);
b(2 * expColEl - 1) = a(colEl * 2 - 1);
b(2 * expColEl) = a(colEl * 2 - 2);

% upper right
b((expRowEl - 1) * expColEl + 1) = a((rowEl - 3) * colEl + 3);
b((expRowEl - 1) * expColEl + 2) = a((rowEl - 3) * colEl + 2);
b((rowEl + 2) * expColEl + 1) = a((rowEl - 2) * colEl + 3);
b((rowEl + 2) * expColEl + 2) = a((rowEl - 2) * colEl + 2);

% lower right
b((expRowEl - 1)* expColEl - 1) = a((rowEl - 1) * colEl - 1);
b((expRowEl - 1)* expColEl) = a((rowEl - 1) * colEl - 2);
b(expRowEl * expColEl - 1) = a((rowEl - 2) * colEl - 1);
b(expRowEl * expColEl) = a((rowEl - 2) * colEl - 2);

% top edges
for i = 1:rowEl
    j = (colEl * (i-1) + 3);
    b((expColEl) *((i-1) + 2) + 1) = a(j); % outer
    b((expColEl) *((i-1) + 2) + 2) = a(j - 1); % inner
end

% bottom edges
for i = 1:rowEl
    j = (colEl * i - 2);
    b((expColEl) *(i + 2)) = a(j); %outer
    b((expColEl) *(i + 2) - 1) = a(j + 1); %inner
end

offset = 2;

% outer right edge
for i = 1:colEl
    b((rowEl + 3) * expColEl + offset + i) = a(colEl * (rowEl - 3) + i);
end

% inner right edge
for i = 1:colEl
    b((rowEl + 2) * expColEl + offset + i) = a(colEl * (rowEl - offset) + i);
end

% outer left edge
for i = 1:colEl
    b(offset + i) = a(2*colEl + i);
end

% inner left edge
for i = 1:colEl
    b(expColEl + offset + i) = a(colEl + i);
end

% Copy data (untouched) into the center of the padded
for j = 1:size(a,2)
    for i = 1:size(a,1)
        b(coder.internal.indexPlus(i,2),coder.internal.indexPlus(j,2)) = a(i,j);
    end
end

function J = grayxform(I,Tin) %#codegen
% J = GRAYXFORM(I,T) Apply gray-level transformation defined in T to input
% image, I.

% Copyright 2014-2015 The MathWorks, Inc.

coder.inline('always');
narginchk(2,2);

coder.internal.errorIf(~isreal(I),...
    'images:grayxformmex:inputImageMustBeReal');

coder.internal.errorIf(~isa(Tin,'double'),...
    'images:grayxformmex:transformArrayMustBeDouble');

coder.internal.errorIf(isempty(Tin),...
    'images:grayxformmex:emptyTransformArray');

if ~isreal(Tin)
    T = real(Tin);
    
    coder.internal.warning(true,...
        'images:grayxformmex:imaginaryPartOfTransformArrayIgnored');
else
    T = Tin;
end

for i = 1:numel(T)
    coder.internal.errorIf((T(i) < 0) || (T(i) > 1),...
        'images:grayxformmex:outOfRangeElementsOfTransformArray');
end

J = coder.nullcopy(I);

coder.extrinsic('images.internal.coder.useSharedLibrary');

useSharedLibrary =  coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(images.internal.coder.useSharedLibrary());

if (useSharedLibrary)
    % MATLAB Host Target (PC)
    
    % Number of threads (obtained at compile time)
    singleThread = images.internal.coder.useSingleThread();
    
    if (singleThread)
        J = calcgrayxform(I,T,J);
    else
        fcnName = ['grayxform_tbb_', images.internal.coder.getCtype(I)];
        
        if(coder.isRowMajor)
            temp = size(I);
            inRows = temp(end);
            inColsEtc = coder.internal.prodsize(I,'below',numel(temp));
        else
            inRows = size(I,1); %Rows
            inColsEtc = coder.internal.prodsize(I,'above',1); %ColsEtc
        end
        
        J = images.internal.coder.buildable.Grayxform_tbbBuildable.grayxform_tbb( ...
            fcnName,...
            I, ...
            numel(I), ...
            inRows,... %Rows
            inColsEtc,... %ColsEtc
            T,...
            numel(T),...
            J);
    end
    
else
    % Non-PC Target
    J = calcgrayxform(I,T,J);
    
end
end

function J = calcgrayxform(I,T,J)

coder.internal.prefer_const(I,T);
coder.inline('always');
%Apply gray-level transformation defined in T to I.
classIm = class(I);
nLevels   = numel(T)-1;

switch classIm
    case 'uint8'
        if nLevels == 255
            for i = 1:numel(I)
                temp = 255.0 * T(coder.internal.indexPlus(I(i),1)) + 0.5;
                J(i) = eml_cast(temp,'uint8','floor');
            end
        else
            scale = nLevels / 255;
            for i = 1:numel(I)
                index = coder.internal.indexInt(scale * double(I(i)) + 0.5 + 1);
                temp = 255 * T(index);
                J(i) = eml_cast(temp,'uint8','floor');
            end
        end
        
    case 'uint16'
        if nLevels == 65535
            for i = 1:numel(I)
                temp = 65535.0 * T(coder.internal.indexPlus(I(i),1)) + 0.5;
                J(i) = eml_cast(temp,'uint16','floor');
            end
        else
            scale = nLevels / 65535;
            for i = 1:numel(I)
                index = coder.internal.indexInt((scale * double(I(i))) + 0.5 + 1);
                temp = 65535.0 * T(index) + 0.5;
                J(i) = eml_cast(temp,'uint16','floor');
                
            end
        end
         
    case 'single'
        for i = 1:numel(I)
            if I(i) >= 0 && I(i) <= 1
                % floor() is not required as the subsequent call to
                % coder.internal.indexPlus(idx(1),1) introduces a c-style
                % cast of idx(1) before adding which truncates the
                % index value as desired.
                % index = floor(I(i)*nLevels + 0.5)+1;
                index = I(i)*nLevels + 0.5;
                % Add 1 to the index to account for 1-indexing in MATLAB vs
                % 0-indexing in C.
                J(i) = single(T(coder.internal.indexPlus(index,1)));
            elseif I(i) > 1
                J(i) = single(T(coder.internal.indexPlus(nLevels,1)));
            else
                J(i) = single(T(1));
            end
        end
        
    case 'double'
        for i = 1:numel(I)
            if I(i) >= 0 && I(i) <= 1
                % floor() is not required as the subsequent call to
                % coder.internal.indexPlus(idx(1),1) introduces a c-style
                % cast of idx(1) before adding which truncates the
                % index value as desired.
                % index = floor(I(i)*nLevels + 0.5)+1;
                index = I(i)*nLevels + 0.5;
                % Add 1 to the index to account for 1-indexing in MATLAB vs
                % 0-indexing in C.
                J(i) = T(coder.internal.indexPlus(index,1));
            elseif I(i) > 1
                J(i) = T(coder.internal.indexPlus(nLevels,1));
            else
                J(i) = T(1);
            end
        end
        
    otherwise
        coder.internal.errorIf(true,...
            'images:grayxformmex:unsupportedInputClass',mfilename);
end
end

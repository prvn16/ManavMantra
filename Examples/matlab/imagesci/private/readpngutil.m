function [X, map, alpha] = readpngutil(filename, bg, byteOffset)
%READPNGUTIL Utility function that allows reading a PNG stream located at
%any location in a file.

% Copyright 2016 MathWorks

alpha = [];
try
    [X,map,oneRow3d] = pngreadc(filename, bg, false, byteOffset);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:png:libraryFailure')
        [X,map,oneRow3d] = pngreadc(filename, bg,true);
        warning(message('MATLAB:imagesci:png:tooManyIDATsData'));
    else
        rethrow(me);
    end
end
X = permute(X, ndims(X):-1:1);

if oneRow3d
    X = reshape(X,[1 size(X)]);
end

if (ismember(size(X,3), [2 4]))
    alpha = X(:,:,end);
    % Strip the alpha channel off of X.
    X = X(:,:,1:end-1);
end
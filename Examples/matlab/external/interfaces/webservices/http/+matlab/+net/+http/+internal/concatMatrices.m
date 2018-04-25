function res = concatMatrices(strs, stringParser)
% concatMatrices concatenates a cell vector of Nx2 string matrices into an MxNx2
%   string array.  If input is Nx2 string matrix treat as if it was in a cell vector
%   of length 1.
%
%   If all the elements are Nx2 or some are Nx2 some are scalars (and
%   stringParser is set), return a an MxNx2 array where M is the size of the cell
%   vector and missing rows in each of the matrices are filled in with string('').
%
%    strings       cell array of string matrices and/or scalar strings or string
%                  matrix
%
%    stringParser  (optional) if strings{i} is a scalar, convert it to a matrix
%                  using this function.  
%
%   This function is for internal use and may change in a future release

% Copyright 2015-2016 The MathWorks, Inc.
    if ~isempty(strs)
        if isstring(strs) && size(strs,2) == 2
            % already a string matrix; treat as one element at top dimension 
            % TBD: this was res(1,:,:) = strings but that's broken due to g1356461
            for i = size(strs,1) : -1 : 1
                res(1,i,:) = strs(i,:);
            end
        else
            numStrings = length(strs);
            if nargin > 1 && any(cellfun(@isscalar, strs))
                % convert any scalar strings if stringParser specified
                for i = 1 : numStrings
                    if isscalar(strs{i})
                        strs{i} = stringParser(strs{i});
                        assert(~isscalar(strs{i}) && ismatrix(strs{i}));
                    end
                end
            end
            maxParams = max(cellfun(@(x) size(x,1), strs));
            res = strings(numStrings,maxParams,2);
            for i = 1 : numStrings
                element = strs{i};
                len = size(element,1);
                res(i,1:len,:) = element;
            end
        end
    else
        res = [];
    end
end
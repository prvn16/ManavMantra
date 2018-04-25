function useUtf8 = h5ParseEncoding(inputArgs)

if nargin == 0
    useUtf8 = false;
    return;
end

p = inputParser;
p.addParameter('TextEncoding', 'system', ...
                    @(x) ismember(lower(x), {'system', 'utf-8'}));
p.parse(inputArgs{:});
useUtf8 = strcmpi(p.Results.TextEncoding, 'UTF-8');
function componentDir = componentExamplesDir(component)

componentDir = fullfile(matlabroot,'examples',component);
examplesXml = fullfile(componentDir,'examples.xml');

if ~exist(examplesXml, 'file')
    componentDir = fullfile(matlabshared.supportpkg.getSupportPackageRoot, 'examples', component);
    examplesXml = fullfile(componentDir,'examples.xml');
    if ~exist(examplesXml, 'file')
        error(em('InvalidArgument',component))
    end
end

function m = em(id,varargin)
m = message(['MATLAB:examples:' id],varargin{:});
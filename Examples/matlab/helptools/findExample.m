function metadata = findExample(arg)
%

%   Copyright 2017 The MathWorks, Inc. 

% Exact token, component-metadata.
match = regexp(arg,'^(\w+)-(\w+)$','tokens','once');
if ~isempty(match)
    return
end

% By component/main.
match = regexp(arg,'^(\w+)/(\w+)$','tokens','once');
if ~isempty(match)
    component = match{1};
    source = match{2};

    componentExamplesDir = exampleUtils.componentExamplesDir(component);
    examplesXml = fullfile(componentExamplesDir,'examples.xml');
    dom = xmlread(examplesXml);

    factory = javax.xml.xpath.XPathFactory.newInstance;
    xpath = factory.newXPath;
    bySource = '/demos/demoitem[source/text()=''%s'']/metadata/text()';
    expression = xpath.compile(sprintf(bySource,source));
    
    NODESET = javax.xml.xpath.XPathConstants.NODESET;
    nodeList = expression.evaluate(dom,NODESET);
    if nodeList.getLength == 1
        metadata = char(nodeList.item(0).getTextContent);
        id = [component '-' metadata];
        metadata = exampleUtils.readMetadata(id, componentExamplesDir);
        return;
    end
    error(em('ExampleNotFound',source,examplesXml))
end

error(em('InvalidArgument',arg))

function m = em(id,varargin)
m = message(['MATLAB:examples:' id],varargin{:});
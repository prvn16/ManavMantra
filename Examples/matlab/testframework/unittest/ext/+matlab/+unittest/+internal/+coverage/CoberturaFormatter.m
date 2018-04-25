classdef CoberturaFormatter < matlab.unittest.internal.coverage.CoverageFormatter
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017-2018 The MathWorks, Inc.
    
    methods 
        function publishCoverageReport(formatter, fileName, coverage, sourceFolders)
            % Create a new DOM element.
            document =  com.mathworks.xml.XMLUtils.createDocument('coverage');
            
            % Run through the children of the coverage instance. Pass the
            % doc for them to create new nodes.
            coverage.formatCoverageData(formatter,document, sourceFolders);
            
            % Write the DOM to an XML.
            xmlwrite(fileName,document);
        end
        
        function coverageElement = formatOverallCoverageData(formatter,overallCoverage,document, sourceFolders) 
            % Get the coverage element with the attributes
            coverageElement = document.getDocumentElement;
            addAttributesToCoverageElement(coverageElement,overallCoverage);
            
            % Create the sources element with the individual source
            % elements
            sourcesElement = createSourcesElement(document,sourceFolders);
            
            % Add a packages element and run through the coverageList of
            % the overallCoverage class to add individual package elements
            % to the packages element.
            packagesElement = document.createElement('packages');
            for coverage = overallCoverage.CoverageList
                packageElement = coverage.formatCoverageData(formatter,document,sourceFolders);
                packagesElement.appendChild(packageElement);
            end
            
            % Add sources and packages elements to the coverage element
            coverageElement.appendChild(sourcesElement);
            coverageElement.appendChild(packagesElement);
        end

        function packageElement = formatPackageCoverageData(formatter,packageCoverage,document,sourceFolders)
            % Create a new package element with the right attributes
            packageElement = createPackageElement(document,packageCoverage);
            
            % Create classes element for the package. Run through all the
            % files (classes) that are in the package and append them
            % under the classes element 
            classesElement = document.createElement('classes');
            for coverage = packageCoverage.CoverageList
                classElement = coverage.formatCoverageData(formatter,document,sourceFolders);
                classesElement.appendChild(classElement);
            end
            
            % Append the classes element as a child to the package element
            packageElement.appendChild(classesElement); 
        end
        
        function classElement = formatFileCoverageData(~,fileCoverage,document,sourceFolders)
            % Create a class element for each file.
            classElement = createClassElement(document,fileCoverage,sourceFolders);
            
            % Add a methods element and run through each method in the
            % class and append them under it.
            methodsElement = document.createElement('methods');
            for methodCoverage = fileCoverage.MethodCoverageData
                methodElement = createMethodElement(document,methodCoverage);
                methodsElement.appendChild(methodElement);
            end
            
            % Create lines element and add class lines under it.
            linesElement = createLinesElement(document,fileCoverage);
            
            % Append the methods and lines element under the class element.
            classElement.appendChild(methodsElement);
            classElement.appendChild(linesElement);
        end
    end
end


function sourcesElement = createSourcesElement(document,sourceFolders)
sourcesElement = document.createElement('sources');
for idx = 1:numel(sourceFolders)
    sourceElement = document.createElement('source');
    textNode = document.createTextNode(sourceFolders(idx));
    sourceElement.appendChild(textNode);
    sourcesElement.appendChild(sourceElement);
end
end


function addAttributesToCoverageElement(coverageElement,overallCoverage)
coverageElement.setAttribute('branch-rate',num2str(nan));
coverageElement.setAttribute('branches-covered',num2str(nan));
coverageElement.setAttribute('branches-valid',num2str(nan));
coverageElement.setAttribute('complexity',num2str(nan));
coverageElement.setAttribute('version',"");
coverageElement.setAttribute('line-rate',num2str(overallCoverage.LineRate));
coverageElement.setAttribute('lines-valid',num2str(overallCoverage.ExecutableLineCount));
coverageElement.setAttribute('lines-covered',num2str(overallCoverage.ExecutedLineCount));            
coverageElement.setAttribute('timestamp',num2str(posixtime(datetime('now'))));
end


function packageElement = createPackageElement(document,packageCoverage)
packageElement = document.createElement('package');
packageElement.setAttribute('branch-rate',num2str(nan));
packageElement.setAttribute('complexity',num2str(nan));
packageElement.setAttribute('line-rate',num2str(packageCoverage.LineRate));
packageElement.setAttribute('name',packageCoverage.PackageName);
end


function classElement = createClassElement(document,fileCoverage,sourceFolders)
idx = find(arrayfun(@(x)startsWith(fileCoverage.FullName,x),sourceFolders), 1,'first');
sourceFolder = sourceFolders(idx);
relativeFileName = regexprep(fileCoverage.FullName,strcat('^',regexptranslate('escape',sourceFolder)),'');

classElement = document.createElement('class');
classElement.setAttribute('branch-rate',num2str(nan));
classElement.setAttribute('complexity',num2str(nan));
classElement.setAttribute('name',fileCoverage.FileIdentifier);
classElement.setAttribute('filename',relativeFileName);
classElement.setAttribute('line-rate',num2str(fileCoverage.LineRate));
end


function methodElement = createMethodElement(document,methodCoverage)
methodElement = document.createElement('method');
methodElement.setAttribute('branch-rate',num2str(nan));
methodElement.setAttribute('line-rate',num2str(methodCoverage.LineRate));
methodElement.setAttribute('name',methodCoverage.Name);
methodElement.setAttribute('signature',methodCoverage.Signature);

linesElement = createLinesElement(document,methodCoverage);
methodElement.appendChild(linesElement);
end


function linesElement = createLinesElement(document,coverage)
linesElement = document.createElement('lines');
for idx = 1:numel(coverage.ExecutableLines)
    lineElement = document.createElement('line');
    lineElement.setAttribute('number',num2str(coverage.ExecutableLines(idx)));
    lineElement.setAttribute('hits',num2str(coverage.HitCount(idx)));                
    linesElement.appendChild(lineElement);
end
end
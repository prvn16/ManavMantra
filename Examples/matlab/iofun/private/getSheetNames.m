function sheets = getSheetNames(workbook_xml_rels, workbook_xml)
    % getSheetNames parses OpenXML to extract Worksheet names.
    %   sheets = getSheetNames(workbook_xml_rels, workbook_xml) parses the 
    %   Office Open XML code in the char array docProps to extract 
    %   Worksheet names into the cell array sheets.
    %
    %   See also xlsread, xlsfinfo
    
    % Copyright 2011-2014 The MathWorks, Inc.
    
    % Excel usually generates files with the 'Type' label first, but
    % Python usually generates file with the 'Target' label first.  We
    % account for both.
    sheetIDs = regexp(workbook_xml_rels, ...
                 ['<Relationship[^>]+Id="(?<rid>[^>]+?)"[^>]+(Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"[^>]+Target="worksheets/[^>]+?.xml"|' ...
                 'Target="worksheets/[^>]+?.xml"[^>]+Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet")[^>]*/>'], ...
                 'names' );
  
    match = regexp(workbook_xml, '<sheet[^>]+name="(?<sheetName>[^"]*)"[^>]*r:id="(?<rid>[^>]+?)"[^>]*/>|<sheet[^>]*r:id="(?<rid>[^>]+?)"[^>]*name="(?<sheetName>[^"]*)"[^>]*/>', 'names');
    
    validSheetIndices = zeros(size(sheetIDs));
    count = 1;
    
    % Match rIDs found in the header with rIDs for sheets in the file.
    % Only return the sheet names of sheet rIDs that are found in the
    % header.
    for i = 1:numel(sheetIDs)
       for j = 1:numel(match)
           if isequal(sheetIDs(i).rid, match(j).rid)
               validSheetIndices(count) = j;
               count = count + 1;
           end
       end
    end
    
    indices = sort(validSheetIndices);
    
    sheets = {match(indices).sheetName};
    
end
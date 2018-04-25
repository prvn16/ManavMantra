function jsonContent = getJsonFromOpcPackage(opcPackage)
    % getJsonFromOpcPackage - This function takes a OPC package and gives
    % the Json representation
    % Get Java Map
    opcMap = com.mathworks.services.mlx.OpcUtils.convertOpcPackageToMap(opcPackage);

    % Convert the file to Json and return
    converter = com.mathworks.connector.message_service.impl.JSONConverterImpl;
    jsonContent = char(converter.convertToJson(opcMap));
end
classdef MessageHandler < asyncio.MessageHandler
    
    properties(GetAccess='private', SetAccess=?audiovideo.internal.writer.plugin.IPlugin)
        Plugin
    end
    
    methods(Access='public')
        function onError(obj, data)
            obj.Plugin.onDeviceError(data);            
        end
    end
end
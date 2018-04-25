classdef CDataShape
    enumeration
        ConstantColor, TrueColor, ColorMapped, ColorMappedScalar
    end
    
    methods
        function ret = isConstantColor(e)
            ret = (matlab.graphics.chart.primitive.utilities.CDataShape.ConstantColor == e);
        end
        
        function ret = isTrueColor(e)
            ret = (matlab.graphics.chart.primitive.utilities.CDataShape.TrueColor == e);
        end
        
        function ret = isColorMapped(e)
            ret = (matlab.graphics.chart.primitive.utilities.CDataShape.ColorMapped == e);
        end
        
        function ret = isColorMappedScalar(e)
            ret = (matlab.graphics.chart.primitive.utilities.CDataShape.ColorMappedScalar == e);
        end
    end
end
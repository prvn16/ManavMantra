classdef CartesianPolarMixin < handle
     % Copyright 2017 The MathWorks, Inc.
    methods
        function  addPolarProperties(this,obj)
            props = {'RData','ThetaData','ThetaDataMode','RDataSource','ThetaDataSource'};
            this.addDynamicProps(obj,props);
        end
        
        function addCartesianProperties(this,obj)
            props = {'XData','XDataMode','YData','ZData','XDataSource','YDataSource','ZDataSource'};
            this.addDynamicProps(obj,props);
        end
        
        function addDynamicProps(this,objs,props)
            % if there are multiple objects, take the first one and add the
            % properties to the view class
            obj = objs(1);
            for i = 1:numel(props)
                pi = this.addprop(props{i});
                this.(pi.Name) = obj.(pi.Name);
                if any(string(pi.Name) == ["XDataMode","ThetaDataMode"])
                    xdmProp = findprop(obj,pi.Name);
                    % Need to explicitly set the property type in the inspector's PropertyTypeMap because you can't set the type of a dynamically added property
                    this.PropertyTypeMap(pi.Name)= xdmProp.Type;
                end
            end
        end
    end
end


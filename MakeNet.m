classdef MakeNet
    %MAKENET このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Property1
        z1
        z2
        b1
    end
    
    methods
        function obj = MakeNet(inputArg1,inputArg2)
            %MAKENET このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function res = netsum(obj)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            obj.z1 = fi([1, 2, 4; 3, 4, 1]);
            obj.z2 = fi([-1, 2, 2; -5, -6, 1]);
            obj.b1 = fi(concur([0; -1],3));
            res = obj.z1+obj.z2 + obj.b1;
            %
            %             net = feedforwardnet();
            %             net.layers{1}.netInputFcn = 'netsum';
            % M12/S Mount currently used, We prefer CS Mount are used
        end
        
        function [net,tr] = fitNet(obj,inputs,targets)
            % Solve an Input-Output Fitting problem with a Neural Network
            
%             load bodyfat_dataset
%             inputs = bodyfatInputs;
%             targets = bodyfatTargets;
            
            
            
            % Create a Fitting Network
            hiddenLayerSize = 10;
            net = fitnet(hiddenLayerSize);
            
            % Set up Division of Data for Training, Validation, Testing
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 15/100;
            
            % Train the Network
            [net,tr] = train(net,inputs,targets);
            
            % Test the Network
            outputs = net(inputs);
            errors = gsubtract(outputs,targets);
            performance = perform(net,targets,outputs)
            
            % View the Network
            view(net)
            
            % Plots
            % Uncomment these lines to enable various plots.
            % figure, plotperform(tr)
            % figure, plottrainstate(tr)
            % figure, plotfit(targets,outputs)
            % figure, plotregression(targets,outputs)
            % figure, ploterrhist(errors)
        end
        
        function helpDatasets(obj)
            help nndatasets;
        end 
    end
end


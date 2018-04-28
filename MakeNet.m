classdef MakeNet
    %MAKENET このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Property1
        z1
        z2
        b1
        javaruntime = java.lang.Runtime.getRuntime;
        hiddenLayerSize = 10;
        net 
        tr
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
%             hiddenLayerSize = 10;
            net = fitnet(obj.hiddenLayerSize);
            
            % Set up Division of Data for Training, Validation, Testing
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 15/100;
            
            % Train the Network
            [net,tr] = train(net,inputs,targets);
            
            obj.net = net;
            obh.tr = tr;
            
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
        
        function [ fi_net ] = conv2single( net, w , f )
            %CONV2SINGLE Convert weights, biases of neural net to single precision
            %   We are using fi objects,
            
            % create fixed_point net, copy of the given net
            
            fi_net = net;
            
            % extract weights and bias from net
            % convert to signed fixed point object of wordlength w, fraction length f
            
            IW=fi(net.IW{1,1},1,w,f);
            LW=fi(net.LW{2,1},1,w,f);
            b_1=fi(net.b{1},1,w,f);
            b_2=fi(net.b{2},1,w,f);
            
            % write converted data back to fixedpoint net
            
            fi_net.IW{1,1}=IW.data;
            fi_net.LW{2,1}=LW.data;
            fi_net.b{1}=b_1.data;
            fi_net.b{2}=b_2.data;
            
        end
        
        function fiNet(obj)
            % Input layer weights for a trained network using the NN toolbox
            net.IW{1,1}
            % set the weights to a temporary variable
            net_IW_1_1 = fi(net.IW{1,1}, 1, 12, 7);
            % convert the temporary variable object to a vector of doubles
            % note: we need to keep the double representation BUT it has fixed point precision now
            net_IW_1_1 = net_IW_1_1.double;
            % now the double vector can be used to set the new object values
            net.IW{1,1} = net_IW_1_1;
            % Viola!
            net.IW{1,1}
        end
        function gc(obj)
            obj.mem
            obj.javaruntime.gc();
            obj.mem
        end
        function mem(obj)
            fmem = obj.javaruntime.freeMemory/1000000;
            ftot = obj.javaruntime.totalMemory/1000000;
            disp(join([fmem, "/", ftot, " = " , fmem/ftot]) );
        end
    end
end


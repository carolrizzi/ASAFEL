
classdef Network < handle

	methods (Static)

		function net = createNet (x, y, layerSize)
			net = feedforwardnet(layerSize);
			net.inputs{1}.processParams{2}.ymin = 0;
			net = train(net, x, y);
		end

		function extension = extendNet (net, extensionSize, extensionMinValue, extensionMaxValue)
			mi = min(net.inputs{1}.processedRange);
			ma = max(net.inputs{1}.processedRange);
			if(mi == 0 && ma == 1)
				initialInputSize = net.inputs{1}.size;
				layerSize = net.layers{1}.dimensions;
				inputSize = initialInputSize + extensionSize;

				inputs = zeros(inputSize, 2);
				inputs(1:initialInputSize, :) = net.inputs{1}.range;
				inputs((initialInputSize+1) : end, 1) = extensionMinValue;
				inputs((initialInputSize+1) : end, 2) = extensionMaxValue;

				extension = feedforwardnet(layerSize);
				extension.inputs{1}.processParams{2}.ymin = 0;
				extension = train(extension, inputs, net.outputs{2}.range);
				extension.b = net.b;
				extension.iw{1} = [net.iw{1}, zeros(layerSize, extensionSize)];
				extension.lw{2} = net.lw{2};
			else
				error('Normalization interval must be [0,1]. Network extension not concluded.');
			end
		end

	end
end

classdef ASP < handle

	properties (SetAccess = private)
		sensitivity;
		alpha;

		xSeetings;
		wmin;
		wmax;
		
		uSize;
		cSize;
		hSize;
		
		amax;
		amin;
	end

	methods

		% Constructor
		function this = ASP (net, association, sensitivity)
			this.xSeetings = net.inputs{1}.processSettings{1};
			this.sensitivity = sensitivity;
			[this.cSize, this.uSize] = size(sensitivity);
			this.wmin = net.iw{1}(:, this.uSize + 1 : end);
			this.wmax = net.iw{1}(:, 1:this.uSize) * sensitivity';
			this.alpha = association ./ sum(sensitivity, 2);
			[r, c] = find(this.alpha == Inf);
			this.alpha(r, c) = 0;
			[r, c] = find(isnan(this.alpha) == 1);
			this.alpha(r, c) = 0;
			this.hSize = size(net.iw{1}, 1);
		end

		function net = init (this, net)
			if(isfield(net.userdata, 'amin') && isfield(net.userdata, 'amax'))
				this.createHomeostasisFunction (net.userdata.amin, net.userdata.amax);
			else
				bias = net.b{1};

				w_xmax = net.iw{1} * this.xSeetings.ymax;
				w_xmin = net.iw{1} * this.xSeetings.ymin;
				wx_min = [];
				wx_max = [];
				for i = 1 : size(net.iw{1}, 2)
					wx = [w_xmin(:, i), w_xmax(:, i)];
					wx_min = [wx_min, min(wx, [], 2)];
					wx_max = [wx_max, max(wx, [], 2)];
				end
				wx_minSum = sum(wx_min, 2);
				wx_maxSum = sum(wx_max, 2);

				amin = bias + wx_minSum;
				amax = bias + wx_maxSum;

				this.createHomeostasisFunction(amin, amax);
				net.userdata.amin = amin;
				net.userdata.amax = amax;

				transferFcn = net.layers{1}.transferFcn;
				if(strcmp(transferFcn,'tansig') && strcmp(transferFcn, 'tansig_homeostasis'))
					error('Synapse:transferFcn', 'This algorithm works only for classical feedforward neural networks.\nThe neural network transfer function must be "tansig" or "tansig_homeostasis". It is currently %s.\n---------------------------\n', transferFcn);
				end
				net.layers{1}.transferFcn = 'tansig_homeostasis';
			end
		end

		function createHomeostasisFunction (this, amin, amax)
			arg1 = '';
			arg2 = '';
			for i = 1 : size(amin, 1)
				arg1 = strcat(arg1, num2str(amin(i)), ';');
				arg2 = strcat(arg2, num2str(amax(i)), ';');
			end
			eval(strcat('! sh tansig_homeostasis.sh "[', arg1, ']" "[', arg2, ']"'));
		end

		function newWeights = getNewWeights (this, weights, x)
			x = mapminmax('apply', x, this.xSeetings);

			wCurrent = weights(:, this.uSize + 1 : end);
			u = x(1 : this.uSize, 1);
			c = x(1 + this.uSize : end, 1);

			term1 = this.alpha .* (this.sensitivity * u);
			term2 = bsxfun(@times, c', (this.wmax - wCurrent));
			term2 = term2 - bsxfun(@times, (1 - c)', (wCurrent - this.wmin));
			delta = bsxfun(@times, term1', term2);
			delta = [zeros(this.hSize, this.uSize), delta];
			newWeights = weights + delta;
		end
	end
end

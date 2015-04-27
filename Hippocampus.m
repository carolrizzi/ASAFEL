
classdef Hippocampus < handle

	properties (SetAccess = private)
		% Input Data
		inX = [];

		% Output Data
		% X: Each column represents one variable, and each row represents one observation.
		% Y: Each row represents the classification of the corresponding row of X.
		outX = [];
		outY = [NaN];

		tempX = [];

		% Control Variables
		windowSize;
		updateInterval = 100;
		count = 0;
		numAttributes;
		threshold;
		sumX;
		danger = false;

		% Tree
		tree;
	end

	methods

% TODO
% define window
% manage features (mean, etc.)
% filter (remover instancias iguais)
% define what is a new instance and call tree

		% Constructor
		% windoSize:
		% numAttributes:
		% threshold: adrenalines threashold for identifying the life-cycle start of a danger situation;
		function this = Hippocampus (windowSize, numAttributes, threshold)
			if(nargin < 3)
				error('Argument missing. Must have 3 arguments.')
			end

			this.windowSize = windowSize;
			this.numAttributes = numAttributes;
			this.sumX = zeros(1, this.numAttributes);
			this.threshold = threshold;
			this.outX = NaN(1, numAttributes);
		end

		function eminentDanger = addData (this, x, y)
			eminentDanger = 0;
			xSize = size(this.inX, 1);
			if ~xSize || mod(xSize, this.windowSize)
				this.inX = [this.inX; x];
				this.sumX = this.sumX + x;
				return;
			end

			y = y >= this.threshold;
			instance = this.sumX / this.windowSize;

			if y && ~this.danger % if high adrenaline and robot is not currently in a danger situation
				this.count = 0;
				this.updateTree(instance, y);
				this.danger = true;
			end

			if ~y % if low adrenaline 
				if this.danger
					this.danger = false;
				end

				if(this.count >= this.updateInterval)
					this.count = 0;
					this.updateTree(instance, y);
				else
					this.count = this.count + 1;
					eminentDanger = this.tree.predict(instance);
				end
			end

			this.sumX = this.sumX - this.inX(1,:) + x;
			this.inX = [this.inX(2:this.windowSize, :); x];
		end

		function updateTree (this, x, y)
			this.outX = [this.outX; x];
			this.outY = [this.outY; y];
			this.tree = fitctree(this.outX, this.outY);
		end

	end

end
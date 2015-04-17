
load data/data.mat;
clear h;

X = X';
X = [X,Y];
X = [X;X];
Y = [Y;Y];

h = Hippocampus(20 , 3, 0.5);
% answers = [];
for i = 1:30 %size(X,1)
	ed = h.addData(X(i,:),Y(i));
	% answers = [answers, ed];
end

% load net.mat;

% % ----- aspConfig = load asp configuration (sensitivity, us, cs, etc);

% % SENSITIVITY (matrix): defines the sensitivity of each CS to each US
% % In other word, it defines how much of each US each CS should associate,
% % where each sensitivity value must be in range [0,1];
% % 	Columns represent USs (noxious stimulus)
% % 	Rows represent CSs (neutral stimulus)
% sensitivity = [];

% % ASSOCIATION (vector): defines the association speed (range [0,1]) of each CS.
% % 	Rows represent the association factor of each CS.
% association = [];

% % ----- instantiate ASP
% asp = ASP(net, association, sensitivity);
% asp.init(net);

% % ----- instantiate ASP
% hipp = Hippocampus;

% % ----- get and enable sensors
% touch_sensors(1) = wb_robot_get_device('ts_front_left');
% touch_sensors(2) = wb_robot_get_device('ts_left');
% touch_sensors(3) = wb_robot_get_device('ts_back');
% touch_sensors(4) = wb_robot_get_device('ts_right');
% touch_sensors(5) = wb_robot_get_device('ts_front_right');

% for sensor = touch_sensors
% 	wb_touch_sensor_enable(sensor, TIME_STEP);
% end

% while wb_robot_step(TIME_STEP) ~= -1
% 	% ----- sensorsData = getdatafrom sensors
% 	sensorData = [wb_touch_sensor_get_value(sensor), etc.];

% 	% ----- refinedData = do preprocessing on sensorsData (if needed)
% 	% ----- stimulusDangerLevel = call ASP with refined data
% 	net.iw{1} = asp.getNewWeights(net.iw{1}, sensorsData);
% 	emotioanalResponse = net(sensorsData);
	
% 	% ----- situationData = call Hippocampus with refinedData and stimulusDangerLevel
% 	hipp.addData(emotioanalResponse, sensorsData);

% 	% ----- situationDangerLevel = call tree classification with situationData
% end
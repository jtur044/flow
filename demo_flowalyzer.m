

%% define output files 

%% Saaed
%% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4

inputVideo      = './data/Saaed/eye0.reduced.mp4';
outputVideo     = './data/Saaed/clip0.result.mp4';
outputDataFile  = './data/Saaed/clip0.result.csv';

StartTime = 0;
EndTime   = 100;


%% Simulation
%inputVideo      = './data/Simulation/simulation.mp4';
%outputVideo     = './data/Simulation/simulation.result.mp4';
%outputDataFile  = './data/Simulation/simulation.result.csv';



%% run analysis 
configuration = load_configuration('./config/flowalyzer-config.tiled.json');
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'UseProfile', 'MatlabLK', 'StartTime', StartTime, 'EndTime', EndTime);

%% show analysis 
dataTable = readtable (outputDataFile);

figure(1); clf;
show_flowalyzer_result (dataTable, 2,2);

%figure(2); clf;
%show_flowalyzer_result (dataTable, 2,2, 'Component', 'Vx');

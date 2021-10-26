

%% define output files 

% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!


%% Saaed 
inputVideo      = './data/Saaed/eye0.reduced.mp4';
outputVideo     = './data/Saaed/clip0.result.mp4';
outputDataFile  = './data/Saaed/clip0.result.csv';
bestTile        = 'tile-5';

%% j_kau 
%inputVideo      = './data/j_kau/eye0.reduced.mp4';
%outputVideo     = './data/j_kau/clip0.result.mp4';
%outputDataFile  = './data/j_kau/clip0.result.csv';
%bestTile        = 'tile-6';

%% j_kau_3 
%inputVideo      = './data/j_kau_3/eye0.reduced.mp4';
%outputVideo     = './data/j_kau_3/clip0.result.mp4';
%outputDataFile  = './data/j_kau_3/clip0.result.csv';
%bestTile        = 'tile-6';

StartTime = 0;
EndTime   = 100;


%% Simulation
%inputVideo      = './data/Simulation/simulation.mp4';
%outputVideo     = './data/Simulation/simulation.result.mp4';
%outputDataFile  = './data/Simulation/simulation.result.csv';



%% run analysis 
configuration = load_configuration('./config/flowalyzer-config.tiled.json');
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'StartTime', StartTime, 'EndTime', EndTime);

%% show analysis 
dataTable = readtable (outputDataFile);

figure(1); clf;
show_flowalyzer_result (dataTable, 'tile-5');

%figure(2); clf;
%show_flowalyzer_result (dataTable, 2,2, 'Component', 'Vx');

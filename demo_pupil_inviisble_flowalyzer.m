% DEMO_PUPIL_INVISIBLE_FLOWALYZER Demo the pupil invisible flow-alyzer
%
% This demo runs the flowalyzer on example eye camera videos.
%
%

% define output files 
%
% note: the input files have the ".reduced" extension added to the name 
% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!


%% Saeed 
inputVideo      = './data/Saeed/eye0.reduced.mp4';
outputVideo     = './data/Saeed/clip0.result.mp4';
outputDataFile  = './data/Saeed/clip0.result.csv';
configFile      = './data/Saeed/flowalyzer-config.tiled.json';
logfile         = './data/Saeed/log.txt';
bestTile        = 'tile-5';
StartTime       = 0;
EndTime         = 100;


%% j_kau (uncomment to run)
%inputVideo      = './data/j_kau/eye0.reduced.mp4';
%outputVideo     = './data/j_kau/clip0.result.mp4';
%outputDataFile  = './data/j_kau/clip0.result.csv';
%configFile      = './data/j_kau/flowalyzer-config.tiled.json';
%logfile         = './data/j_kau/log.txt';
%bestTile        = 'tile-6';
%StartTime = 0;
%EndTime   = 100;

%% j_kau_3 (uncomment to run)
%inputVideo      = './data/j_kau_3/eye0.reduced.mp4';
%outputVideo     = './data/j_kau_3/clip0.result.mp4';
%outputDataFile  = './data/j_kau_3/clip0.result.csv';
%configFile      = './data/j_kau/flowalyzer-config.tiled.json';
%logfile         = './data/j_kau/log.txt';
%bestTile        = 'tile-6';
%StartTime = 0;
%EndTime   = 100;

%% Simulation (uncomment to run)
%inputVideo      = './data/Simulation/simulation.mp4';
%outputVideo     = './data/Simulation/simulation.result.mp4';
%outputDataFile  = './data/Simulation/simulation.result.csv';
%configFile      = './data/Simulation/flowalyzer-config.tiled.json';
%logfile         = './data/Simulation/log.txt';
%bestTile        = 'tile-5';
%StartTime = 0;
%EndTime   = 100;


clear rlog;
rlog('on');
rlog(logfile);
configuration = load_configuration(configFile);
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'StartTime', StartTime, 'EndTime', EndTime, 'UseProfile', 'MatlabLK');

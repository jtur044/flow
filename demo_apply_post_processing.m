%% DEMO_APPLY_POST_PROCESSING 
%
% Demo apply post-processing 
%
%


%% Saaed 
%configfile      = './data/Saaed/flowalyzer-config.tiled.json';
%inputDataFile   = './data/Saaed/clip0.result.csv';
%outputDataFile  = './data/Saaed/clip0.result.updated.csv';
%outputFigFile   = './data/Saaed/clip0.result.updated.fig';
%bestTile        = 'tile-5';


%% j_kau 
%configfile      = './data/j_kau/flowalyzer-config.tiled.json';
%inputDataFile   = './data/j_kau/clip0.result.csv';
%outputDataFile  = './data/j_kau/clip0.result.updated.csv';
%outputFigFile   = './data/j_kau/clip0.result.updated.fig';
%bestTile        = 'tile-6';

%% j_kau_3
configfile      = './data/j_kau_3/flowalyzer-config.tiled.json';
inputDataFile   = './data/j_kau_3/clip0.result.csv';
outputDataFile  = './data/j_kau_3/clip0.result.updated.csv';
outputFigFile   = './data/j_kau_3/clip0.result.updated.fig';
bestTile        = 'tile-6';


%% This file will load 'configfile' which will contain post-processing rules 
apply_post_processing (configfile, inputDataFile, outputDataFile);

figure(1); clf;
show_flowalyzer_result (outputDataFile, bestTile);
savefig(gcf);
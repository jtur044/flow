
# Flow

Flow introduces the flowalyzer which is a matlab toolbox for displacement estimation using Optincal Flow. 

## Installation

Add this directory to the Matlab PATH to install.

## Usage

At the Matlab commandline prompt use:

```matlab
demo_flowalyzer
```

This will generate data for one of the provided example video(s). You will need to uncomment the appropriate lines to run for each 
example person provided  (````j_kau, j_kau_3, Saaed````).

Note that the flowalyzer reads a config file. The config file defines  TILES which are regions of interest (ROI) in which flowalyzer will be applied. The TILES are arranged in row, column order and are numbered  starting from 1. So for a 3x3 matrix (3,1) is the bottom left TILE, and the number of the TILE is 3. There is  

It is noted that this numbered is my own convention and does not need to be observed.  I have also added a 'global' TILE that refers to the entire image. 

Once data has been generated (it already has) you can view the results using ```show_flowalyzer_result```. This function can reference the appropriate CSV file directly or the loaded table. The tile of interest is referenced as well. It is called ```global```.

These examples are shown below

### Example 1 

```matlab
filename = './data/j_kau_3/clip0.result.csv';
dataTable = load_flowalyzer_result (filename);
show_flowalyzer_result (dataTable, 'global');
```

### Example 2

```matlab
filename = './data/j_kau_3/clip0.result.csv';
show_flowalyzer_result (filename, 'global');
```

The data generated from a run of the ```flowalyzer```can be post-processed. An example of this post-processing is provided in ```demo_apply_post_processing``` This demonstration loads the rules from a config file and applies the filters in sequence. Please see the files ```flowalyzer-config.tiled.json``` in the individual directories (````j_kau, j_kau_3, Saaed````).


# Flow

Flow introduces the flowalyzer which is a matlab toolbox for displacement estimation using Optincal Flow. 

## Installation

Add this directory to the Matlab PATH to install.

## Usage

At the Matlab commandline prompt use:

```demo_flowalyzer
```
to generate data from example video(s).

### Example 1 

```filename = './data/j_kau_3/clip0.result.csv';
dataTable = load_flowalyzer_result (filename);
show_flowalyzer_result (dataTable, 'global');
```

### Example 2

```filename = './data/j_kau_3/clip0.result.csv';
show_flowalyzer_result (filename, 'global');
```



This will (hopefully) run a demonstration of the flowalyzer toolbox on an example video.


## License
[MIT](https://choosealicense.com/licenses/mit/)

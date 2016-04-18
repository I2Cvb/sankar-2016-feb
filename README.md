Classification of SD-OCT volumes for DME detection: an anomaly detection approach
=================================================================================

```
@proceeding{sankar2016classification,
author = {Sankar, S. and Sidib\'{e}, D. and Cheung, Y. and Wong, T. Y. and Lamoureux, E. and Milea, D. and Meriaudeau, F.},
title = {Classification of SD-OCT volumes for DME detection: an anomaly detection approach},
journal = {Proc. SPIE},
volume = {9785},
pages = {97852O-97852O-6},
year = {2016}
}
```

How to use the pipeline?
-------

### Pre-processing pipeline

The follwoing pre-processing routines were applied:

- Flattening,
- Cropping.

#### Data variables

In the file `pipeline/feature-preprocessing/pipeline_preprocessing.m`, you need to set the following variables:

- `data_directory`: this directory contains the orignal SD-OCT volume. The format used was `.img`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.

#### Algorithm variables

The variables which are not indicated in the inital publication and that can be changed are:

- `x_size`, `y_size`, `z_size`: the original size of the SD-OCT volume. It is needed to open `.img` file.
- `kernelratio`, `windowratio`, `filterstrength`: the NLM parameters.
- `h_over_rpe`, `h_under_rpe`, `width_crop`: the different variables driving the cropping.
- `thres_method`, `thres_val`: method to threshold and its associated value to binarize the image.
- `gpu_enable`: method to enable GPU.
- `median_sz`: size of the kernel when applying the median filter.
- `se_op`, `se_cl`: size of the kernel when applying the closing and opening operations.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-preprocessing/pipeline_preprocessing.m
```

### Extraction pipeline

For this pipeline, the following features were extracted:

- PCA on vectorized B-scans.

#### Data variables

In the file `pipeline/feature-extraction/pipeline_extraction.m`, you need to set the following variables:

- `data_directory`: this directory contains the pre-processed SD-OCT volume. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.
- `pca_compoments`: this the number of components to keep when reducing the dimension by PCA.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-extraction/pipeline_extraction.m
```

### Classification pipeline

The method for classification used was:

- GMM modelling.

#### Data variables

In the file `pipeline/feature-preprocessing/pipeline_classifier.m`, you need to set the following variables:

- `data_directory`: this directory contains the feature extracted from the SD-OCT volumes. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.
- `gmm_k`: this is the number of mixture components of the GMM.
- `pca_components`: this is the number of components of the PCA used in the extraction.
- `mahal_thresh`: the treshold to use to consider a B-scan as abnormal or not.
- `n_slices_thres`: the minimum number of abnormal slices to consider the volume as DME.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-classification/pipeline_classifier.m
```

### Validation pipeline

#### Data variables

In the file `pipeline/feature-validation/pipeline_validation.m`, you need to set the following variables:

- `data_directory`: this directory contains the classification results. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-validation/pipeline_validation.m
```

clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                  'sankar_2016/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/results/' ...
                   'sankar_2016/'];
% Location of the ground-truth
gt_file = '/data/retinopathy/OCT/SERI/data.xls';

% Load the csv data
[~, ~, raw_data] = xlsread(gt_file);
% Extract the information from the raw data
% Store the filename inside a cell
filename = { raw_data{ 2:end, 1} };
% Store the label information into a vector
data_label = [ raw_data{ 2:end, 2 } ];
% Get the index of positive and negative class
idx_class_pos = find( data_label ==  1 );
idx_class_neg = find( data_label == -1 );

% Number of mixture components
gmm_k = 8;

% Mahalanobis threshold
pca_components = 300;
mahal_thresh = chi2inv(0.95, pca_components);

% Number of abnormal slices tolerated
n_slices_thres = 32;

% Number of slice per volume
x_size = 128;

% poolobj = parpool('local', 48);

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_neg)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % Load the data for this cross validation
    filename_cv = ['cv_', num2str(idx_cv_lpo), '.mat'];
    load(strcat(data_directory, filename_cv));

    % Apply a GMM learning on the training set
    gmm_model = fitgmdist(training_data, gmm_k);

    test_vol = 1;
    % Test the gmm_model and count the number of outliers
    for test_id = 1 : x_size : size(testing_data,1)
        % Extract the data to use in the gmm model
        t_data = testing_data(test_id : test_id + x_size - 1,:));
        
        % Compute the Mahalanobis distance for all the slices
        mahal_dist = mahal(gmm_model, t_data);

        % Get the distance to the nearest components
        mahal_dist_near = min(mahal_dist, [], 2);

        % Check how many slices are abnormal
        n_abnormal_slices = nnz(mahal_dist_near > mahal_thresh);
        
        % Affect the predicted label
        if n_abnormal_slices > n_slices_thres
            pred_label_cv(idx_cv_lpo, test_vol) = 1;
        else
            pred_label_cv(idx_cv_lpo, test_vol) = -1;
        end
        
        test_vol = test_vol + 1;
    end

end

save(strcat(store_directory, 'predicition.mat'), 'pred_label_cv');

%delete(poolobj);
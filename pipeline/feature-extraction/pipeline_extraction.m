clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/' ...
                  'sankar_2016/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
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

% Number of components for the PCA
pca_components = 300;

% poolobj = parpool('local', 48);

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_neg)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % The two patients for testing will corresspond to the current
    % index of the cross-validation

    % Load the testing data
    testing_data_tem = [];
    % Load the patient
    load(strcat(data_directory, filename{idx_class_pos(idx_cv_lpo)}));
    n_bscan = size(vol_cropped, 3);
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; ...
                        reshape(vol_cropped, size(vol_cropped, 1) * size(vol_cropped, 2), ...
                                size(vol_cropped, 3))'];
    % Load the negative patient
    load(strcat(data_directory, filename{idx_class_neg(idx_cv_lpo)}));
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; ...
                        reshape(vol_cropped, size(vol_cropped, 1) * size(vol_cropped, 2), ...
                                size(vol_cropped, 3))'];

    % Load the training data
    training_data_tem = [];
    for tr_idx = 1:length(idx_class_neg)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load(strcat(data_directory, filename{idx_class_neg(tr_idx)}));
            % Concatenate the data
            training_data_tem = [ training_data_tem ; ...
                                reshape(vol_cropped, size(vol_cropped, 1) * size(vol_cropped, 2), ...
                                size(vol_cropped, 3))'];
        end
    end
    disp('Loaded the training set')

    % Apply PCA on the training data
    [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data_tem, 'NumComponents', pca_components);
    training_data = score;

    % Transform the testing data
    testing_data = (bsxfun(@minus, testing_data_tem, mu)) * coeff;

    disp('Projected the data using PCA');

    % Save all the data
    filename_cv = ['cv_', num2str(idx_cv_lpo), '.mat'];
    save(strcat(store_directory, filename_cv), 'training_data', 'testing_data');

end

%delete(poolobj);
%{
Author: zhihao Wang
Date: Mar 22, 2019

Purpose: preprocess all the image data and output three mat files
%}

%% === Configurations 
clear; 
clc; 

% show the long precision numbers 
format long g;

% data direction 
dir_data = '.\data\';

% global parameters
isDataRready_pe = true;

% data sources
dir_pe   = 'Poisson_editing\'; 
dir_pe_1 = 'data1\';
dir_pe_2 = 'data2\';

% the set of images
nPe = 2; 

%% == Poisson Image Editing
isGraphCut = true; 
if ~isDataRready_pe
    fprintf(1, 'Processing Poisson Editing Data .. \n');
    tic;

    % setup directory 
    tmp_dir_data = strcat(dir_data, dir_pe);
    % data 1
    tmp_dir_data1 = strcat(tmp_dir_data, dir_pe_1);
    file_pattern = fullfile(tmp_dir_data1, '*.JPG');
    img_files1 = dir(file_pattern);
    file_pattern = fullfile(tmp_dir_data1, '*.jpeg');
    img_files_extra1 = dir(file_pattern);
    % data 2
    tmp_dir_data2 = strcat(tmp_dir_data, dir_pe_2);
    file_pattern = fullfile(tmp_dir_data2, '*.jpg');
    img_files2 = dir(file_pattern);

    nImg = length(img_files2) * 2;
    tmp_img_col = [];

    % read images 
    for i = 1:nImg
        if i == 1
            base_file_name = img_files_extra1.name;
            full_file_name = fullfile(tmp_dir_data1, base_file_name);
        elseif i == 2
            base_file_name = img_files1.name;
            full_file_name = fullfile(tmp_dir_data1, base_file_name);
        else
            base_file_name = img_files2(i-2).name;
            full_file_name = fullfile(tmp_dir_data2, base_file_name);
        end
        fprintf(1, '	Reading %s\n', full_file_name);

        % store image in the image cell
        tmp_img_col{i} = imread(full_file_name);

    %   % test
    %   figure;
    %   imshow(tmp_img_col{i});
    %   drawnow; 
    end
    
    % obtain mask from Graph Cut 
    if isGraphCut
        % BW is the binary mask obtained from the Graph Cut Tool by manually selecting masks
        fmask{1} = BW1;
        fmask{2} = BW2;
    end

    % re-organize data 
    pe = [];
    for i = 1:nPe
        sub = [];
        sub.bimg = tmp_img_col{i*2-1};
        sub.bimg_grey = rgb2gray(tmp_img_col{i*2-1});
        sub.bsize = size(sub.bimg);
        sub.fimg = tmp_img_col{i*2};
        sub.fimg_gray = rgb2gray(tmp_img_col{i*2});
        sub.fsize = size(sub.fimg); 
        sub.fmask = fmask{i}; 

        pe{i} = sub; 
    end

    save('.\data\pe.mat', 'pe');
    fprintf(1, 'Done!');
    toc;
    fprintf(1, '\n\n');
end



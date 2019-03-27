%{
Author: zhihao Wang
Date: Mar 22, 2019

Purpose: Poisson Image Editing

%}

%% === Configurations 
clear; 
clc; 

% show the long precision numbers 
format long g;

% data directory 
dir_data = '.\data\';
dir_res ='.\res\';


% control
isPE = true; 


%% === Read data
fprintf(1, 'Now start loading imgs ...\n');
tic;

load(strcat(dir_data, 'pe.mat')); 

fprintf(1, '\nDone!\n');
toc;


%% === Poisson Editing 
if isPE
    
    fprintf(1, '\n\nPoisson Editing ...\n');
    tic;

    % configuration
    starting_loc = [200, 700; % image 1 
                    600, 700]; % image 2

    % image set
    t = 1; 
    cur_pe = pe{t};


    %== extract foreground image 
    % find vertical range
    [~, tmp_r] = max(cur_pe.fmask, [], 2); 
    tmp_r = find(tmp_r ~= 1);
    % find horizontal range 
    [~, tmp_c] = max(cur_pe.fmask); 
    tmp_c = find(tmp_c ~= 1);
    % obtain mask info
    cur_mask_loc = [tmp_r(1), tmp_c(1); 
                    tmp_r(end), tmp_c(end)];
    cur_mask_size = cur_mask_loc(2,:) - cur_mask_loc(1,:) + 1; 
    cur_mask = cur_pe.fmask(cur_mask_loc(1,1):cur_mask_loc(2,1), cur_mask_loc(1,2):cur_mask_loc(2,2));
    cur_fore = cur_pe.fimg(cur_mask_loc(1,1):cur_mask_loc(2,1), cur_mask_loc(1,2):cur_mask_loc(2,2), :);
    % update starting loctions 
    starting_loc(t,:) = starting_loc(t,:) + cur_mask_loc(1,:) - 1;


    % direct blending
    res_direct = cur_pe.bimg;
    res_direct(starting_loc(t, 1):(starting_loc(t, 1) + cur_mask_size(1) - 1), ...
               starting_loc(t, 2):(starting_loc(t, 2) + cur_mask_size(2) - 1), :) = cur_fore;


    %== Poisson Editing
    % coef matric 
    A = sparse(cur_mask_size(1)*cur_mask_size(2), cur_mask_size(1)*cur_mask_size(2));
    for i = 2:(cur_mask_size(1) - 1) 
        for j = 2:(cur_mask_size(2) - 1)
            tmp_idx = (j - 1) * cur_mask_size(1) + i; 
            if cur_mask == 1
                A(tmp_idx, tmp_idx) = 4;
                A(tmp_idx, tmp_idx - 1) = -1;
                A(tmp_idx, tmp_idx + 1) = -1;
                A(tmp_idx, tmp_idx - cur_mask_size(1)) = -1;
                A(tmp_idx, tmp_idx + cur_mask_size(1)) = -1;
            else
                A(tmp_idx, tmp_idx) = 1; 
            end 
            
        end 
    end
    
    % gradient mixing
    cur_back = cur_pe.bimg(starting_loc(t, 1):(starting_loc(t, 1) + cur_mask_size(1) - 1), ...
               starting_loc(t, 2):(starting_loc(t, 2) + cur_mask_size(2) - 1), :);
    [cur_back_grad, ~] = imgradient3(cur_back); 
    [cur_fore_grad, ~] = imgradient3(cur_fore); 
    B_b = reshape(cur_back_grad, cur_mask_size(1)*cur_mask_size(2), 3);
    B_f = reshape(cur_fore_grad, cur_mask_size(1)*cur_mask_size(2), 3);
    
    pe_alpha = 0.5;
    B = pe_alpha * B_b + (1 - pe_alpha) * B_f;
    
    % solve Ax = B
    x = B\A;
    
    x_matrix = reshape(full(x), cur_mask_size(1), cur_mask_size(2), 3);  
    res_pe = cur_pe.bimg;
    res_pe(starting_loc(t, 1):(starting_loc(t, 1) + cur_mask_size(1) - 1), ...
           starting_loc(t, 2):(starting_loc(t, 2) + cur_mask_size(2) - 1), :) = x_matrix;
    
 
    % plot
    h = figure; 
    hax(1) = subplot(1,4,1);
    imshow(cur_pe.bimg);
    title('Target');
    hax(2) = subplot(1,4,2);
    imshow(cur_fore);
    title('Source');
    hax(3) = subplot(1,4,3);
    imshow(res_direct);
    title('Blended');
    hax(3) = subplot(1,4,4);
    imshow(res_pe);
    title('Blended');


    fprintf(1, '\nDone!\n');
    toc;

end 









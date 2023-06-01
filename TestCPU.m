%% Test file for the ASTRA-Projector toolbox
% Here we illustrate the use of the toolbox when using a CPU. 
%
% Note: Using CPU results in a matched projector pair!

%% Load path to ASTRA-Projectors toolbox and set up ASTRA
addpath("~/Desktop/ABBA_projectors/ASTRA-Projectors") % Path to toolbox
astra_setup("~/astra") % Only needs to be run once

%% Set up CT specifications and create the projector pair
num_pixels = 32;
num_angles = 180;
num_detectors = 32;
det_width = 1;
GPU = 0;

[A, B] = astra_projectors(GPU, num_pixels, num_angles, num_detectors, ...
    det_width, missing, missing, missing, 'linear');

%% Size of operators
A_size = size(A);
B_size = size(B);

%% Create sparse forward projector matrix
% Note: ASTRA provide the forward operator matrix
Af = sparse(A); % full(A) is also availabe

%% Create sparse backward projector matrix
Bf = sparse(B); % full(B) is also availabe

%% Plot one ray moving through the image x
idx = 30;
xray = reshape(Af(idx, :), num_pixels, num_pixels);

imagesc(xray)

%% Show backprojection
X = phantom('Modified Shepp-Logan',num_pixels);
x = X(:);

sinogram = reshape(A*x,num_angles,num_detectors);

figure();
imagesc(sinogram)
title('Sinogram')

recon = reshape(B*sinogram(:),num_pixels,num_pixels);

figure();
imagesc(recon)
title('Backprojection')

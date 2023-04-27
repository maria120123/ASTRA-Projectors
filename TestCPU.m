%% Test file for th ASTRA-Projector toolbox
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

[A, B] = astra_projectors(0, num_pixels, num_angles, num_detectors, ...
    det_width);

%% Create full matrix
Af = sparse(A);

%%
Bf = sparse(B);

%% Plot one ray
idx = 313;
xray = reshape(Af(idx, :), num_pixels, num_pixels);

imagesc(xray)

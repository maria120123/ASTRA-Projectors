addpath("~/Desktop/PC_ABBA_projectors/ASTRA-Projectors")
%%
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

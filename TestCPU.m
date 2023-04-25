num_pixels = 64;
num_angles = 180;
num_detectors = 64;
det_width = 1;

% FP og BP mangler blot "FP" i stedet for "FP_CUDA" og det samme for BP -
% men der er en fejl lige nu pga. synkronisering. Men ellers burde vi kunne 
% teste vha. dette. 
[A, B] = astra_projectors(num_pixels, num_angles, num_detectors, ...
    det_width);
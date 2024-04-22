%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program tracks the mouse in open field/NOR/NOL and provide analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;clear;clc;

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 0. Parameters
% ==============
main_dir = 'D:\AD_data\github_prep\NOR'; % The main directory contains subfolders including videos
spatial_ratio = mean([840/51.435 536/33.655]); %pixel/cm
width = 840;      % Width  of the bottom of the box (Region of interest)
height = 536;     % Height of the bottom of the box (Region of interest)
fps = 30;         % Frame per second
fixation_points_filename = 'fixation_points.mat'; % Store the picked fixation point
start_end_time_filename = 'start_end_points.mat';
raw_video_name_contents = 'WIN*Pro.mp4';
cropped_video_name_contents = 'cropped_WIN*Pro.mp4';
time_par = [9,15,(10*60+10)]; 
%[9,15] is the approximate time in second to remove the box, 
%(10*60+10) = 610 is the end time in second of experiment

% The parameters below is for function mice_tracking:
mouse_size_threshold = 1000; % The mice's size should be above this value.
mouse_max_speed = 400; % The mice's speed should be smaller than this value.
smooth_span_size = 9;  % smooth the raw velocity
% This matlab code calculates parameters including 
mouse_max_size = 10000; % The maximum size of mice in pixel
movement_threshold = 1.6; %1.5 is a good enough!

save(fullfile(main_dir,'global_parameters.mat'),"main_dir","spatial_ratio","width",...
      "height","fps","fixation_points_filename","start_end_time_filename",...
      "raw_video_name_contents","cropped_video_name_contents","time_par",...
      "mouse_size_threshold","mouse_max_speed","smooth_span_size",...
      "mouse_max_size","movement_threshold");




% -------------------------------------------------------------------------
folder_dir = dir(main_dir);
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 1. Select the lower-bottom point manually as the fixation point.
% ==============
disp('1. Select the lower-bottom point manually as the fixation point.')

pick_ROI(folder_dir, raw_video_name_contents, fixation_points_filename)
close all;
% -------------------------------------------------------------------------

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 2. Estimate the start and end time of each video
% ==============
disp('2. Estimate the start and end time of each video')
estimate_time_range(folder_dir, fps, time_par, width, height, raw_video_name_contents, fixation_points_filename, start_end_time_filename)
load(fullfile(main_dir,start_end_time_filename))
disp('The file containing the start and end time of each video has been loaded!');
close all;
% -------------------------------------------------------------------------

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 3. Crop each video
% ==============
disp('3. Crop each video based on fixation points and range of time')
crop_video(folder_dir,fixation_points_filename,start_end_time_filename, raw_video_name_contents, width, height)
disp('The cropped videos have been created!');
close all;
% -------------------------------------------------------------------------

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 4. Track mice
% ==============
disp('4. Track mice')
mice_tracking(folder_dir, cropped_video_name_contents, mouse_size_threshold,...
    mouse_max_speed, smooth_span_size, mouse_max_size, movement_threshold,...
    width, height)
disp('The mice tracking has been done!');
close all;
% -------------------------------------------------------------------------

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 5. Data analysis
% ==============
disp('5. Data analysis')
mice_tracking(folder_dir, cropped_video_name_contents, mouse_size_threshold,...
    mouse_max_speed, smooth_span_size, mouse_max_size, movement_threshold,...
    width, height)
disp('The mice tracking has been done!');
close all;
% -------------------------------------------------------------------------

disp('Done!')
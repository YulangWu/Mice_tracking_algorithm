function [] = crop_video(folder_dir,fixation_points_filename,start_end_time_filename, raw_video_name_contents, width, height)
    % This function crops videos in both spatial and temporal dimensions
    
    % Load the fixation points correpsonding to the ROI
    load(fullfile(folder_dir(1).folder,fixation_points_filename))
    % Load the start and end time points corresponding to the range of time
    load(fullfile(folder_dir(1).folder,start_end_time_filename))


    index = 0;
    for m = 1 : length(folder_dir)

        if folder_dir(m).name ~= "." && folder_dir(m).name ~= ".."
            subfolder_dir = dir(fullfile([folder_dir(m).folder '/' folder_dir(m).name],raw_video_name_contents));
            for n = 1 : length(subfolder_dir)
                if subfolder_dir(n).name ~= "." && subfolder_dir(n).name ~= ".."
                    index = index + 1;
                    cropX = x_vec(index);
                    cropY = y_vec(index);
                    start_point = start_point_vec(index);
                    end_point   = end_point_vec(index);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 0. Get files in directory
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    inputVideoFile = string([folder_dir(m).folder '/' folder_dir(m).name '/' subfolder_dir(n).name]);

                    outputVideoFile = string([folder_dir(m).folder '/' folder_dir(m).name '/' 'cropped_' subfolder_dir(n).name]);
%                     disp(outputVideoFile)

                    if isfile(outputVideoFile)
                        disp(["Skip " outputVideoFile])
                        continue;
                    end

                    if isfile(outputVideoFile) == 0
%                         disp(['3. Generate new videos: ' outputVideoFile] )
                        disp(['Process: ' inputVideoFile])

                        % Create VideoReader and VideoWriter objects
                        videoReader = VideoReader(inputVideoFile);
                        outputVideo = VideoWriter(outputVideoFile, 'MPEG-4');
                        outputVideo.FrameRate = videoReader.FrameRate;

                        % Open the VideoWriter for writing
                        open(outputVideo);

                        % Read, crop, and downsample frames
                        time_step = 0;
                        while hasFrame(videoReader)
                            frame = readFrame(videoReader);

                            time_step = time_step + 1;

%                             if mod(time_step,5000) == 0
%                                  disp([inputVideoFile ' : ' num2str(time_step)])
%                             end

                            if time_step >= start_point && time_step <= end_point
                                % Crop the frame
                                croppedFrame = frame(floor(cropY)-height+1:floor(cropY), floor(cropX)-width+1:floor(cropX),:);
                                % Change image from RGB to gray (new feature)
                                % Write the cropped frame to the output video
                                writeVideo(outputVideo, croppedFrame);
                            end
                        end

                        % Close the VideoReader and VideoWriter objects
                        close(outputVideo);
                        % release(videoReader);

                        disp(['Done: ' outputVideoFile]);

                        % Optional: Play the cropped video
                        % implay(outputVideoFile);
                    end % isfile()

                end
            end
        end

    end
end


function [] = mice_tracking(folder_dir, ...
            cropped_video_name_contents, mouse_size_threshold,...
            mouse_max_speed, smooth_span_size, mouse_max_size, ...
            movement_threshold, width, height)
        
    index = 0; %Index of file
    for m = 1 : length(folder_dir)
        file_dir = dir(fullfile([folder_dir(m).folder '/' folder_dir(m).name],cropped_video_name_contents));
        for n = 1 : length(file_dir)

            % Create VideoReader environment
            inputVideoFile = [folder_dir(m).folder '/' folder_dir(m).name '/' file_dir(n).name];
            disp(['Process: ' inputVideoFile]) 

            output_matdata_file = inputVideoFile(1:end-4) + "_mean_subtract.mat"; 


            if isfile(output_matdata_file)
                disp(['skip: ' output_matdata_file])
                continue;
            end

            index = index + 1;

            %% 1. Get mean image for subtraction (Suggested by Prof. Christoph Kirst)

            %Read the frame from video
            videoReader = VideoReader(inputVideoFile);

            avg_frame = zeros(height,width);

            frame_num = length(1:10:videoReader.NumFrames);
            for t = 1:10:videoReader.NumFrames
%                 if mod(t,5000) == 0
%                     disp([inputVideoFile ' (AVG) : ' num2str(t)])
%                     % % % % % imagesc(avg_frame);
%                 end
                frame = rgb2gray(read(videoReader,t));
                avg_frame = avg_frame + double(frame)/frame_num;
            end
            avg_frame = int8(avg_frame);

            %As the mice is 0 (black) and background is 170, so the
            %threhsold = background - mice = 170 
            threshold = mean(mean(avg_frame(floor(height/2)...
                -floor(height/8):floor(height/2)+floor(height/8))...
                ,floor(width/2)-floor(width/8):...
                    floor(width/2)+floor(width/8)))*0.6;

            %% 2. Subtract video from mean map and do classification
            %Read the frame from video again
            videoReader = VideoReader(inputVideoFile);
            % Define 7 mice's parameters: 
            % size of mouse in pixels, median_y, median_x, distance, velocity, 
            % dummy status (move or stationary), interpolation or not 
            mice = zeros(7,videoReader.NumFrames);
            mice_location = [];
            for t = 1:1:videoReader.NumFrames

                frame = readFrame(videoReader);

                % Define the vector to store coordinate of the mice
                pos_arr = zeros(mouse_max_size,2);
                count = 0; % Count the number of pixels in mice

                % Extract the mouse
                if mod(t,1) == 0
                    %Trim the episode of video prior to start point in time
                    %and downsample the time from frame to second (fps=30)
                    gray_frame = avg_frame - int8(rgb2gray(frame));
                    dummy_frame = gray_frame;
                    % get the dummy variable
                    num_pts_mouse = 0;
                    for i = 1:height
                        for j = 1:width
                            if gray_frame(i,j) < threshold
                                dummy_frame(i,j) = 0;
                            else
                                dummy_frame(i,j) = 1;
                                num_pts_mouse = num_pts_mouse + 1;
                                % this point is in mice
                                count = count + 1;
                                pos_arr(count,1) = i;
                                pos_arr(count,2) = j;

                                end
                            end
                        end

                    % Store the coordinates of the mouse at each frame 
                    mice_location{t} = pos_arr;

                    %Compute the mice's parameters (size, x, y)
                    % Size in pixels
                    mice(1,t) = sum(sum(dummy_frame)); 
                    % Y coordinate of center of the mice
                    mice(2,t) = floor(median(pos_arr(1:count,1)));
                    % X coordinate of center of the mice
                    mice(3,t) = floor(median(pos_arr(1:count,2)));
                    if t > 1
                        % Velocity unit=pixel/frame
                        mice(5,t) = sqrt((mice(2,t) - mice(2,t-1))^2 + ...
                                         (mice(3,t) - mice(3,t-1))^2);
                        % Distance unit=pixel
                        mice(4,t) = mice(4,t-1) + mice(5,t);
                    end

                    % Corner case that mouse might be hidden by objects
                    % Check whether mice appear sufficiently in the dummy frame
                    if num_pts_mouse == 0 || ...
                            mice(1,t) < mouse_size_threshold || ...
                            mice(5,t) > mouse_max_speed
                        % % % % % disp(['Mouse is invisible at frame=' num2str(t)])
                        % % % % % disp([num_pts_mouse mice(1,t) mice(5,t)])
                        mice(7,t) = 1;    % 0 means no interpolation by default
                        mice(2:4,t) = mice(2:4,t-1);
                        mice(5,t) = 0; % set velocity = 0
                    end

                    if t > 1 && mice(7,t) == 0 && mice(7,t-1) == 1 % The time mice reappear
                        mice(5,t) = 0; % set velocity = 0
                    end

                end
            end 

            % Smooth the velocity and get dummy status of mice
            % (stationary or movement)
            mice(5,:) = smooth(mice(5,:), smooth_span_size);
            for i = 1 : length(mice)
                if mice(5,i) < movement_threshold
                    mice(6,i) = 0;
                else
                    mice(6,i) = 1;
                end
            end

            mouse_SN = folder_dir(m).name;
            
            save(output_matdata_file,"mice","threshold","mouse_max_size",...
                "movement_threshold","smooth_span_size","avg_frame",...
                "mouse_max_speed","mouse_size_threshold",...
                "mice_location","mouse_SN");

            disp(['save file: ' output_matdata_file])


            figure(index)
            subplot(2,3,1);
            plot(mice(1,:))
            subplot(2,3,2);
            plot(mice(2,:))
            subplot(2,3,3);
            plot(mice(3,:))
            subplot(2,3,4);
            plot(mice(4,:))
            subplot(2,3,5);
            plot(mice(5,:))
            subplot(2,3,6);
            plot(mice(7,:))
            title(inputVideoFile(1:end-4))
            saveas(gcf, inputVideoFile(1:end-4) + "_plot.jpg", 'jpg');


            % release(videoReader);
            % release(VideoWriter);

            % implay(outputVideoFile);

        end %end to process the current file


    end

end


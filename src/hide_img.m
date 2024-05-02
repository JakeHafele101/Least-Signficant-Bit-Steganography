clear all
close all

N = 1; %Number of bits to clear/hide 

% Load Original Image
original_filename = "cadenx8.png";
original_image = imread(original_filename);

% Create Hidden Message

hidden_filename = "caden.png";

hidden_image = imread(hidden_filename); %original uint8

[hidden_x hidden_y hidden_z] = size(hidden_image);


hidden_binary = dec2bin(hidden_image);

hidden_reshape_nofill = reshape(hidden_binary, [], 1);

num_pad = N - rem(length(hidden_reshape_nofill), N);
zero_append = char(zeros(num_pad, 1));

hidden_reshape = [hidden_reshape_nofill; zero_append];

% Hide hidden message in original image

int_clear = 2^8 - 2^N; 

modified_image = original_image;

[x y z] = size(original_image);

message_index = 1;

for a = 1:x
    for b = 1:y
        for c = 1:z %every 3 is R, G, B

            if message_index > length(hidden_reshape) %FIXME, bad solution
                break;
            end

            modified_image(a, b, c) = bitand(original_image(a, b, c), int_clear);

            int_fill = (hidden_reshape(message_index : message_index + N - 1));
            int_fill_dec = bin2dec(int_fill.');
            
            message_index = message_index + N;

            modified_image(a, b, c) = bitor(modified_image(a, b, c), int_fill_dec);
        end
    end
end

% Recover hidden message from modified image

message_index = 1;

recovered_binary(1:length(hidden_reshape)) = zeros();

int_recover = 2^N - 1; 

for a = 1:x
    for b = 1:y
        for c = 1:z %every 3 is R, G, B

            if message_index > length(hidden_reshape) %FIXME, bad solution
                break;
            end
            
            recovered_int = bitand(modified_image(a, b, c), int_recover);
            
            binary_loop = dec2bin(recovered_int, N);
            
            recovered_binary(message_index : message_index + N - 1) = binary_loop;
            
            message_index = message_index + N;

        end
    end
end

% Convert recovered Message

reovered_binary_no_pad = recovered_binary(1:length(hidden_reshape) - num_pad);
recovered_reshape = reshape(reovered_binary_no_pad, [], 8);
recovered_char = char(recovered_reshape);

recovered_binary = bin2dec(recovered_char);

recovered_image = uint8(reshape(recovered_binary, hidden_x, hidden_y, hidden_z));

% Display Images

figure
subplot(2,2,1);
imshow(original_image);
title("Original Image");

subplot(2,2,2);
imshow(hidden_image);
title("Hidden Image");

subplot(2,2,3); 
imshow(modified_image);
title("Modified Image");

subplot(2,2,4); 
imshow(recovered_image);
title("Recovered Image");

imwrite(modified_image, "ModifiedImage.png");
imwrite(recovered_image, "RecoveredImage.png");

% Error Calculation

mod_err = ssim(modified_image, original_image);
rec_err = ssim(recovered_image, hidden_image);

disp("ssim modified image error: " + mod_err); %Value closer to 1 represents better image quality
disp("ssim recovered image error: " + rec_err); %Value closer to 1 represents better image quality



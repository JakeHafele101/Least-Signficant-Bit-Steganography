clear all
close all

N = 1; %Number of bits to clear/hide 

% Load Original Image
original_filename = "cadenx8.png";
original_image = imread(original_filename);

% Create Hidden Message

hidden_filename = "nerd-radar_iYz2boOk.mp3";

FID = fopen(hidden_filename);
bits = fread(FID, '*ubit1', 'ieee-le');
fclose(FID);
bitlength = length(bits);
for i = 1:bitlength/8
    bytes(i) = 0;
    for p = 1:8
        bytes(i) = bytes(i) + bits((i-1)*8 + p) * 2 ^ (p-1);
    end
end
fileID = fopen('bytes.png','w');
fwrite(fileID, bytes);
fclose(fileID);



hidden_double = double(bits);

hidden_binary = dec2bin(hidden_double);
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

% Display modified image with hidden message

figure
subplot(1,2,1);
imshow(original_image);
title("Original Image");

subplot(1,2,2); 
imshow(modified_image);
title("Modified Image");

imwrite(modified_image, "BeeMovieCaden.png");

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
bitlength = length(reovered_binary_no_pad);
for i = 1:bitlength/8
    bytes(i) = 0;
    for p = 1:8
        bytes(i) = bytes(i) + bits((i-1)*8 + p) * 2 ^ (p-1);
    end
end
fileID = fopen('recoveredsound.mp3','w');
fwrite(fileID, bytes);
fclose(fileID);

% Error Calculation

ssim_err = ssim(modified_image, original_image);

disp("ssim error: " + ssim_err); %Value closer to 1 represents better image quality


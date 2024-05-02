clear all
close all



% Load Original Image
original_filename = uigetfile({'*.*'}, 'File Selector');
original_image = imread(original_filename);
[x y z] = size(original_image);

% Create Hidden Message

hidden_filename = convertCharsToStrings(uigetfile({'*.*'}, 'File Selector'));
hidden_filename_2 = hidden_filename + '?';
hidden_filename_chars = convertStringsToChars(hidden_filename_2);

FID = fopen(hidden_filename);
filebits = fread(FID, '*ubit1', 'ieee-le');
fclose(FID);
bitlength = length(filebits);

bits = [zeros(43 + 7 * (length(hidden_filename_chars)), 1); filebits];
bytecount = x * y * z;
N = 1; %Number of bits to clear/hide 
while bytecount * N < length(bits)
    N = N+1;
end
H = N;
if H >= 4
    bits(1) = 1;
    H = H - 4;
end
if H >= 2
    bits(2) = 1;
    H = H - 2;
end
if H >= 1
    bits(3) = 1;
end
total_length = length(bits);
mod_length = total_length;
for i = 1:40
    if mod_length >= 2^(40 - i)
        bits(3 + i) = 1;
        mod_length = mod_length - 2^(40-i);
    end
end
textvar = double(hidden_filename_chars);
textbin = [];
for i = 1:length(textvar)
    for k = 1:7
        textbin((i - 1) * 7 + (k)) = 0;
        if textvar(i) >= 2 ^ (7-k)
           textbin((i - 1) * 7 + (k)) = 1;
           textvar(i) = textvar(i) - 2 ^ (7-k);
        end
    end
end
bits(44:43 + 7 * length(hidden_filename_chars)) = textbin;




% for i = 1:bitlength/8
%     bytes(i) = 0;
%     for p = 1:8
%         bytes(i) = bytes(i) + bits((i-1)*8 + p) * 2 ^ (p-1);
%     end
% end
% fileID = fopen('bytes.png','w');
% fwrite(fileID, bytes);
% fclose(fileID);



hidden_double = double(bits);

hidden_binary = dec2bin(hidden_double);
hidden_reshape_nofill = reshape(hidden_binary, [], 1);

num_pad = N - rem(length(hidden_reshape_nofill), N);
zero_append = char(zeros(num_pad, 1));

hidden_reshape = [hidden_reshape_nofill; zero_append];

% Hide hidden message in original image

int_clear = 2^8 - 2^N; 
N_clear = 2^8 - 2^3;
modified_image = original_image;

message_index = 1;

first = 0;
for a = 1:x
    for b = 1:y
        for c = 1:z %every 3 is R, G, B
            if first == 0;

                if message_index > length(hidden_reshape) %FIXME, bad solution
                    break;
                end
    
                modified_image(a, b, c) = bitand(original_image(a, b, c), N_clear);
    
                int_fill = (hidden_reshape(message_index : message_index + 3 - 1));
                int_fill_dec = bin2dec(int_fill.');
                
                message_index = message_index + 3;
    
                modified_image(a, b, c) = bitor(modified_image(a, b, c), int_fill_dec);
                first = 1;
            else
                if message_index >= length(bits) %FIXME, bad solution
                    break;
                end
                while message_index + N > length(bits)
                    N = N -1;
                end
                modified_image(a, b, c) = bitand(original_image(a, b, c), int_clear);

                int_fill = (hidden_reshape(message_index: message_index + N - 1));
                int_fill_dec = bin2dec(int_fill.');
                
                message_index = message_index + N;
    
                modified_image(a, b, c) = bitor(modified_image(a, b, c), int_fill_dec);
                
            end

        end
        
    end
    disp(message_index/bitlength)
end

% Display modified image with hidden message

figure
subplot(1,2,1);
imshow(original_image);
title("Original Image");

subplot(1,2,2); 
imshow(modified_image);
title("Modified Image");

imwrite(modified_image, "ModifiedImage.png");

ssim_err = ssim(modified_image, original_image);

disp("ssim error: " + ssim_err); %Value closer to 1 represents better image quality

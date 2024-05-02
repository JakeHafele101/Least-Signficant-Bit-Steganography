close all
clear all
% Recover hidden message from modified image

modified_image = imread("ModifiedImage.png");
[x y z] = size(modified_image);
message_index = 1;

recovered_binary = [];

int_recover = 2^3 - 1; 
bitlength = 0;
name_discovered = 0;
charbit = 0;
filename = [];
name_ready = 0;
charvar = 0;
first = 0;
for a = 1:x
    for b = 1:y
        for c = 1:z %every 3 is R, G, B
            if first == 0;
                
                recovered_int = bitand(modified_image(a, b, c), int_recover);
                
                binary_loop1 = dec2bin(recovered_int, 3);
                
                recovered_binary(message_index : message_index + 3 - 1) = binary_loop1;
                
                message_index = message_index + 3;
                N = (recovered_binary(1)-48) * 4 + (recovered_binary(2)-48) * 2 + (recovered_binary(3)-48);
                int_recover = 2^N - 1; 
                first = 1;

            elseif message_index < 44
                
                recovered_int = bitand(modified_image(a, b, c), int_recover);
                
                binary_loop = dec2bin(recovered_int, N);
                
                recovered_binary(message_index : message_index + N - 1) = binary_loop;
                
                message_index = message_index + N;
            end
            if message_index >= 44 && name_ready == 0;
                for i = 0:39
                    bitlength = bitlength + (recovered_binary(43 - i) - 48) * 2 ^ (i);
                end
            end
            if message_index > 43 && name_ready == 1 && name_discovered == 0;

                if message_index > bitlength %FIXME, bad solution
                    break;
                end
                
                recovered_int = bitand(modified_image(a, b, c), int_recover);
                
                binary_loop = dec2bin(recovered_int, N);
                
                recovered_binary(message_index : message_index + N - 1) = binary_loop;

                charbit = charbit + N;
                if charbit >= 7
                    charvar = 0;
                    charbit = charbit - 7;
                    for i = 0:6
                        charvar = charvar + (recovered_binary(44 + 7 * length(filename) + i) - 48) * 2 ^ (6-i);
                    end
                    filename = [filename charvar];
                end
                
                message_index = message_index + N;
            end
            if name_discovered == 1

                if message_index > bitlength && name_discovered == 1; %FIXME, bad solution
                    break;
                end
                
                recovered_int = bitand(modified_image(a, b, c), int_recover);
                
                binary_loop = dec2bin(recovered_int, N);
                
                recovered_binary(message_index : message_index + N - 1) = binary_loop;
                
                message_index = message_index + N;
            end
            if message_index > 43
                name_ready = 1;
            end
            if charvar == 63
                name_discovered = 1;
            end
            if message_index > bitlength && name_discovered == 1; %FIXME, bad solution
                break;
            end
        end
        if message_index > bitlength && name_discovered == 1; %FIXME, bad solution
            break;
        end
    end
end

% Convert recovered Message
databitlength = bitlength - (43+7*length(filename));
bits = recovered_binary(43+7*length(filename):bitlength);
for i = 1:databitlength/8
    bytes(i) = 0;
    for p = 1:8
        bytes(i) = bytes(i) + (bits((i-1)*8+p + 1) - 48) * 2 ^ (p-1);
    end
end
filestring = ("recovered " + convertCharsToStrings(char(filename(1:length(filename)-1))));
fileID = fopen(filestring,'w');
fwrite(fileID, bytes);
fclose(fileID);

original_image = imread("caden.png");
figure
subplot(2,2,1);
imshow(original_image);
title("Original Image");

subplot(2,2,3); 
imshow(modified_image);
title("Modified Image");

hide_image = imread("caden.png");
subplot(2,2,2);
imshow(hide_image);
title("image to hide:");

recover_image = imread("recovered caden.png");
subplot(2,2,4); 
imshow(recover_image);
title("recovered image");


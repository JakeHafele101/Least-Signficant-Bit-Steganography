function big()   
    image = imread("image2.png");
    [x y z] = size(image);
    l = x * y * z;
    image2 = image;
    n = 8;
    for a = 1:x
        for b = 1:y
            for c = 1:z
                for d = 1:n
                    for e = 1:n
                        image2(a * n + (d-1) -1, b * n + (e-1) - 1, c) = image(a, b, c);
                    end
                end
                
            end
        end
        disp(a/x * 100)
    end
    imshow(image2);
    imwrite(image2, "big caden.png")
end
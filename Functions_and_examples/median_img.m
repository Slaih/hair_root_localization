function img_median = median_img(img, ksize)
    [height , width, depth] = size(img);
    if depth ~=1
        img = im2gray(img);
    end

    if ksize == 0
        ksize = 3;
    end

    step = ksize - ((ksize+1)/2);
    img_temp = zeros(height + step*2, width + step*2);
    img_temp(step+1:(height+step), step+1:(width+step)) = img;
    img_temp = uint8(img_temp);

    for i=1:height
        for j=1:width
            img(i, j) = median(double(img_temp(i:ksize+i-1, j:ksize+j-1)), 'all');
        end
    end

    img_median = uint8(img);
end
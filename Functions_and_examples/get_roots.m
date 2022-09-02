% root_array -> array of root locations (first coloumn is row index)
% note: if you do not want to see images which are result of this function
% you can command figure parts
function root_array = get_roots(img)
    %Note: Input of this function should be trimmed hairs because it works
    %nicely with it otherwise when used with long hairs, it finds hairs but can
    %not find their locations

    img_g = im2gray(img); % rgb to gray scale conversion
    

    % structring element to find hair edges
    SE = [0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0; 1 1 1 1 1 1 1 1 1;...
        0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0 0];

    % median filter used to reduce noise in the image but it increases
    % computational time, if you want to fast result you can comment this
    % line. (Output will be mmore noisy)
    img_g = median_img(img_g, 3);
    
    % black hat (bottom hat) operation: it is used to find black foreground element on
    % the white background 
    % function = first img_g closed by SE then result substracted from
    % img_g
    SE_img = imbothat(img_g, SE);
    
    figure(1);
    imshow(SE_img);
    title("edge of img");

    % gaussian filter to reduce effect of non hair edges 
    img_blur = imgaussfilt(SE_img);
    
    % binarizing the image
    T = find_th(img_blur);
    mask = (img_blur > floor(T*255));
    
    figure(2);
    imshow(mask);
    title("mask");
    
    % connected component function to eliminate non-hair masks which are
    % small compared to other
    CC = bwconncomp(mask);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    id_x = find(numPixels < (min(numPixels)+3));
    
    % getting rid of non hair masks
    for i=1:length(id_x)
        mask(CC.PixelIdxList{id_x(i)}) = 0;
    end
    figure(3);
    imshow(mask);
    title("mask denoised");   


  
    % connected component function to find hair location after denoising
    % the image
    CC = bwconncomp(mask);
    hair_num = CC.NumObjects;
    
    % array which includes hair root locations
    root_array = zeros(hair_num,2);
    numPixels = cellfun(@numel,CC.PixelIdxList);

    % this part to take all the pixel locations connected to one component
    % and average them to use root locations
    for i=1:length(numPixels)
        index_arr = CC.PixelIdxList{i};
        [r,c] = ind2sub(size(mask), index_arr);
        r = floor(mean(r));
        c = floor(mean(c)); 
        root_array(i, 1) = r;
        root_array(i, 2) = c;

        % painting root locations to red
        img(r,c,1) = 255;
        img(r,c,2) = 0;
        img(r,c,3) = 0;
    end

    % this part to show found hairs
    maskedRgbImage = bsxfun(@times, img, cast(imcomplement(mask), 'like', img));
    figure(4);
    imshow(maskedRgbImage);
    title("masked img");    

    % this part to show hair root, it will be one red pixel on the hair 
    % (if you can not see you should get closer to image)
    figure(5);
    imshow(img);
    title("hair root found");      
end
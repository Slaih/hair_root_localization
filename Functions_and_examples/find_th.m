function threshold = find_th(img_g)

    img_d = im2double(img_g);
    % first we take average of min and max
    T = 0.5*(min(img_d(:)) + max(img_d(:)));

    % delta_T to determine at which gray scale value we stop to search 
    delta_T = 0.01;
    done = false;
   
    while ~done
        % fidning image indexes above T and below T
        g = img_d >= T;

        % using that indexes calculating new th
        T_next = 0.5*(mean(img_d(g)) + mean(img_d(~g)));
        done = abs(T - T_next) < delta_T;
        T = T_next;
    end
    
    threshold = T_next;
end
function data = gfilt3(data,sz,oriVer,twodVer)
% data = gfilt3(data,sz,oriVer)
% data = (subject) X (trial) X (time)

if nargin < 3, oriVer = 0; end
if nargin < 4, twodVer = 0; end
n = size(data,1);

if sz ~= 0,
    for k = 1:n
        if ~twodVer,
            data(k,:,:) = gfilt2(squeeze(data(k,:,:)),sz,oriVer);
        elseif twodVer == 1,
            data(k,:,:) = imgaussfilt(squeeze(data(k,:,:)),sz);         
        elseif twodVer == 2,
            tmpdat = squeeze(data(k,:,:));
            [h,v] = size(tmpdat);
            tmppos = reshape(1:h*v,h,v);
            
            for hi = 0:(h-1),
                tmpIdx = diag(tmppos,-hi);
                tmpdat(tmpIdx) = gfilt2(tmpdat(tmpIdx)',sz,oriVer);
            end
            
            for vi = 1:(v-1),
                tmpIdx = diag(tmppos,vi);
                tmpdat(tmpIdx) = gfilt2(tmpdat(tmpIdx)',sz,oriVer);
            end
            data(k,:,:) = tmpdat;
            
        end
    end
end

end

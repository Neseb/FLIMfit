function data = smooth_flim_data(data,extent,mode)

    % Copyright (C) 2013 Imperial College London.
    % All rights reserved.
    %
    % This program is free software; you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation; either version 2 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc.,
    % 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
    %
    % This software tool was developed with support from the UK 
    % Engineering and Physical Sciences Council 
    % through  a studentship from the Institute of Chemical Biology 
    % and The Wellcome Trust through a grant entitled 
    % "The Open Microscopy Environment: Image Informatics for Biological Sciences" (Ref: 095931).

    % Author : Sean Warren
    
    s = size(data);
    n_t = s(1);
    n_chan = s(2);
    
    if length(s) == 2
        return
    end
    
    extent = extent*2+1;
    extent2 = extent * extent;
        
    kernel = ones(extent) ./ extent2;

    % pre-calculate correction of normalization (same for all planes)
    siz = size(data);
    size_plane = siz(3:4);
    c = conv2(ones(size_plane),kernel,'same');
  
    for i = 1:n_t
        for j = 1:n_chan
            plane = squeeze(data(i,j,:,:));

            C = conv2(plane,kernel,'same');
            data(i,j,:,:) = C./c;
        end
    end
end
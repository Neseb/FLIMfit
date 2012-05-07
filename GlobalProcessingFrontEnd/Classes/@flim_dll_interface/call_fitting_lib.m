function err = call_fitting_lib(obj,roi_mask,selected)

    p = obj.fit_params;
    d = obj.data_series;
    
    if nargin < 3
        selected = [];
    end
    if nargin < 2
        roi_mask = [];
    end
    
    if p.polarisation_resolved

        err = calllib(obj.lib_name,'SetupGlobalPolarisationFit', ...
                            obj.dll_id, p.global_algorithm, ...
                            length(d.tr_irf), obj.p_t_irf, obj.p_irf, 0, ...
                            p.n_exp, p.n_fix, ...
                            obj.p_tau_min, obj.p_tau_max, 1, obj.p_tau_guess, ...
                            p.fit_beta, obj.p_fixed_beta, ...
                            p.n_theta, p.n_theta_fix, 0, obj.p_theta_guess, ...
                            p.fit_t0, 0, p.fit_offset, p.offset, ...
                            p.fit_scatter, p.scatter, ...
                            p.fit_tvb, p.tvb, obj.p_tvb_profile, ...
                            p.pulsetrain_correction, 1e-6/p.rep_rate, ...
                            p.ref_reconvolution, p.ref_lifetime, p.fitting_algorithm, ...
                            obj.p_ierr, p.n_thread, true, false, 0);
    else
       
       

        err = calllib(obj.lib_name,'SetupGlobalFit', ...
                            obj.dll_id, p.global_algorithm, ...
                            length(d.tr_irf), obj.p_t_irf, obj.p_irf, 0, ...
                            p.n_exp, p.n_fix, ...
                            obj.p_tau_min, obj.p_tau_max, 1, obj.p_tau_guess, ...
                            p.fit_beta, obj.p_fixed_beta, ...
                            p.fit_t0, 0, p.fit_offset, p.offset, ...
                            p.fit_scatter, p.scatter, ...
                            p.fit_tvb, p.tvb, obj.p_tvb_profile, ...
                            p.n_fret, p.n_fret_fix, p.inc_donor, obj.p_E_guess, ...
                            p.pulsetrain_correction, 1e-6/p.rep_rate, ...
                            p.ref_reconvolution, p.ref_lifetime, p.fitting_algorithm, ...
                            obj.p_ierr, p.n_thread, true, false, 0);
    end

    if err ~= 0
        return;
    end
    
    if obj.bin
        n_datasets = 1;
        height = 1;
        width = 1;
        
        decay = obj.data_series.get_roi(roi_mask,selected);
        decay = squeeze(nanmean(decay,3));
        obj.p_data = libpointer('doublePtr', decay);
        t_skip = [];
        n_t = length(d.tr_t);
        obj.p_t = libpointer('doublePtr',d.tr_t);
        obj.p_mask = libpointer('int32Ptr',1);

    else
        n_datasets = sum(d.loaded);
        width = d.width;
        height = d.height;
        
        t_skip = d.t_skip;
        n_t = length(d.t);
        obj.p_t = libpointer('doublePtr',d.t);
        
        if ~isempty(d.seg_mask)        
            obj.p_mask = libpointer('int32Ptr', int32(d.seg_mask));
        else
            obj.p_mask = [];
        end
    end
    
    data_type = ~strcmp(d.mode,'TCSPC');
    
    calllib(obj.lib_name,'SetDataParams',...
            obj.dll_id, n_datasets, height, width, d.n_chan, n_t, obj.p_t, t_skip, length(d.tr_t),...
            data_type, obj.p_use, obj.p_mask, d.thresh_min, d.gate_max, p.global_fitting, d.binning, p.use_autosampling);
 
    if err ~= 0
        return;
    end
        
    if ~obj.bin
        if d.background_type == 1
            calllib(obj.lib_name,'SetBackgroundValue',obj.dll_id,d.background_value);
        elseif d.background_type == 2
            obj.p_background = libpointer('doublePtr', d.background_image);
            calllib(obj.lib_name,'SetBackgroundImage',obj.dll_id,obj.p_background);
        end
    end
    
    if err ~= 0
        return;
    end    
    
    if d.use_memory_mapping && ~obj.bin
        if d.raw
            data_class = 1; % uint16
        else
            data_class = 0; % double
        end
        err = calllib(obj.lib_name,'SetDataFile',obj.dll_id,d.mapfile_name,data_class,d.mapfile_offset);
    else
        err = calllib(obj.lib_name,'SetDataDouble',obj.dll_id,obj.p_data);
    end
    
    if err ~= 0
        return;
    end

    err = calllib(obj.lib_name,'StartFit',obj.dll_id);
        

    end
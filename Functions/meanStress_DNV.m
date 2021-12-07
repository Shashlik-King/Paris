function [f_m] = get_factor_effect_of_mean_stress_DNV(stress_range,mean_stress)
    f_m = 1;
    
    sig_t = mean_stress+stress_range/2;
    sig_c = mean_stress-stress_range/2;
    
    if sig_t < 0
        sig_t = 0;
    end
    
    if sig_c > 0
        sig_c = 0;
    end
    
    if (sig_t + abs(sig_c) > 0)
        f_m = (sig_t + 0.6*abs(sig_c))/(sig_t+abs(sig_c));
    end
    
    if f_m < 0.6
        f_m = 0.6;
    end
    if f_m > 1
        f_m = 1;
    end
end
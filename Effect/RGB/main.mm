#import "AEConfig.h"
#import "AE_Effect.h"
#import "AE_Macros.h"
#import "Param_Utils.h"

#import <Cocoa/Cocoa.h>
#import <vector>

#import "Config.h"

static PF_Err UpdateParamsUI(PF_InData *in_data, PF_OutData* out_data, PF_ParamDef *params[], const PF_UserChangedParamExtra *which_hit) {
    PF_Err err = PF_Err_NONE;
    if((which_hit&&which_hit->param_index==Params::RANDOMIZE)) {
        srand(CFAbsoluteTimeGetCurrent());
        params[Params::R]->uu.change_flags = PF_ChangeFlag_CHANGED_VALUE;
        params[Params::G]->uu.change_flags = PF_ChangeFlag_CHANGED_VALUE;
        params[Params::B]->uu.change_flags = PF_ChangeFlag_CHANGED_VALUE;
        params[Params::R]->u.sd.value = (random()&0xFF);
        params[Params::G]->u.sd.value = (random()&0xFF);
        params[Params::B]->u.sd.value = (random()&0xFF);
    }
    return err;
}

static PF_Err GlobalSetup(PF_InData *in_data,PF_OutData *out_data,PF_ParamDef *params[],PF_LayerDef *output) {
    PF_Err 	err = PF_Err_NONE;
    out_data->my_version = PF_VERSION(2,0,0,PF_Stage_DEVELOP,0);
    out_data->out_flags = PF_OutFlag_WIDE_TIME_INPUT;
    out_data->out_flags2 = PF_OutFlag2_SUPPORTS_THREADED_RENDERING;
    return err;
}

static PF_Err Render(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;

    int width  = output->width;
    int height = output->height;
    
    unsigned int *dst = (unsigned int *)output->data;
    int dstRow = output->rowbytes>>2;
    
    bool fill = false;
    
    PF_LayerDef *input = &params[Params::INPUT]->u.ld;
    if(input->width==width&&input->height==height)  {
        
        unsigned int *src = (unsigned int *)input->data;
        int srcRow = input->rowbytes>>2;
        
        unsigned char r = params[Params::R]->u.sd.value;
        unsigned char g = params[Params::G]->u.sd.value;
        unsigned char b = params[Params::B]->u.sd.value;
        
        for(int i=0; i<height; i++) {
            for(int j=0; j<width; j++) {
                dst[i*dstRow+j] = b<<24|g<<16|r<<8|0xFF;
            }
        }
    }
    else {
        fill = true;
    }
    
    if(fill) {
        for(int i=0; i<height; i++) {
            for(int j=0; j<width; j++) {
                dst[i*dstRow+j] = 0xFF0000FF;
            }
        }
    }
    
    return err;
}

extern "C" {
    PF_Err EffectMain(PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output, void *extra) {
        PF_Err err = PF_Err_NONE;
        try {
            switch (cmd) {
                case PF_Cmd_GLOBAL_SETUP: err = GlobalSetup(in_data,out_data,params,output); break;
                case PF_Cmd_PARAMS_SETUP: err = ParamsSetup(in_data,out_data,params,output); break;
                case PF_Cmd_USER_CHANGED_PARAM:
                    err = UpdateParamsUI(in_data,out_data,params,(cmd==PF_Cmd_USER_CHANGED_PARAM)?(const PF_UserChangedParamExtra *)extra:nullptr);
                    break;
                case PF_Cmd_RENDER: {
                    @autoreleasepool {
                        err = Render(in_data,out_data,params,output); break;
                    }
                }
                default: break;
            }
        } catch(PF_Err &thrown_err) {
            err = thrown_err;
        }
        return err;
    }
}

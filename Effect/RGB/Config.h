#define IDENTIFIER @"Ae.CPU.RGB"
#define METALLIB @"Plugin.metallib"

namespace Params {
    enum {
        INPUT = 0,
        RANDOMIZE,
        R,
        G,
        B,
        NUM
    };
}

static PF_Err ParamsSetup(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;
    PF_ParamDef def;

    AEFX_CLR_STRUCT(def);
    PF_ADD_BUTTON("","Randomize",PF_PUI_NONE,PF_ParamFlag_SUPERVISE|PF_ParamFlag_CANNOT_TIME_VARY|PF_ParamFlag_CANNOT_INTERP,Params::RANDOMIZE);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_SLIDER("R",0,255,0,255,0,Params::R);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_SLIDER("G",0,255,0,255,0,Params::G);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_SLIDER("B",0,255,0,255,0,Params::B);
    
    out_data->num_params = Params::NUM;
    return err;
}
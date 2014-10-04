module VoiceConversion

# Voice conversion
export FrameByFrameConverter, TrajectoryConverter,
       fvconvert, vc,
       GMMMap, TrajectoryGMMMap, TrajectoryGMMMapWithGV

# Post filters
export PeseudoGV, fvpostf!, fvpostf

# Dynamic Time Warping (DTW) related functions
export DTW, fit!, update!, set_template!, backward

# Feature conversion, extractions and alignment
export logamp2mcep, mcep2e, world_mcep, align_mcep

# Datasets
export ParallelDataset, GVDataset, push_delta

## Type Hierarchy ##
abstract Converter
abstract FrameByFrameConverter <: Converter
abstract TrajectoryConverter <: Converter

for fname in ["align",
              "dtw",
              "datasets",
              "mcep",
              "gmm",
              "gmmmap",
              "trajectory_gmmmap",
              "peseudo_gv",
              "converter"]
    include(string(fname, ".jl"))
end

end # module

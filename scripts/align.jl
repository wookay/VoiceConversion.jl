using DocOpt

doc="""Align two feature vector sequences and create parallel data in batch.
Note that filename of source and target feature is assumed to be same.

Usage:
    align.jl [options] <src_dir> <tgt_dir> <dst_dir>
    align.jl --version
    align.jl -h | --help

Options:
    -h --help       show this message
    --threshold=TH  threshold that is used to remove silence [default: -14.0]
    --max=MAX       Maximum number that will be processed [default: 200]
"""

using VoiceConversion
using HDF5, JLD

using Logging
@Logging.configure(level=DEBUG, output=STDOUT)

searchdir(path, key) = filter(x -> contains(x, key), readdir(path))

function mkdir_if_not_exist(dir)
    if !isdir(dir)
        println("Create $(dir)")
        run(`mkdir -p $dir`)
    end
end

function align!(src::Dict,
                tgt::Dict;
                threshold::FloatingPoint=-14.0,
                )
    src_fm = src["feature_matrix"]
    tgt_fm = tgt["feature_matrix"]

    if src["type"] == "MelCepstrum"
        src_fm, tgt_fm = align_mcep(src_fm, tgt_fm,
                                    float(src["alpha"]),
                                    int(src["fftlen"]);
                                    threshold=threshold)
    else
        src_fm, tgt_fm = _align(src_fm, tgt_fm)
    end

    @assert size(src_fm) == size(tgt_fm)

    @info("The number of aligned frames: $(size(src_fm, 2))")
    if size(src_fm, 2) ==  0
        @warn("No frame found in aligned data. Probably threshold is too high.")
    end

    @assert !any(isnan(src_fm))
    @assert !any(isnan(tgt_fm))

    src["feature_matrix"] = src_fm
    tgt["feature_matrix"] = tgt_fm

    # type Dict{Union(UTF8String, ASCIIString), Any} is saved as
    # Dict{UTF8String, Any} and cause error in reading JLD file.
    # remove off Union and then save do the trick (but why? bug in HDF5?)
    @assert isa(src, Dict{Union(UTF8String, ASCIIString), Any})
    @assert isa(tgt, Dict{Union(UTF8String, ASCIIString), Any})


    Dict{UTF8String, Any}(src), Dict{UTF8String, Any}(tgt)
end

let
    args = docopt(doc, version=v"0.0.1")

    srcdir = args["<src_dir>"]
    tgtdir = args["<tgt_dir>"]
    dstdir = args["<dst_dir>"]
    mkdir_if_not_exist(dstdir)

    threshold = float(args["--threshold"])
    nmax = int(args["--max"])

    files = searchdir(srcdir, ".jld")
    @info("$(length(files)) data found.")

    count = 0
    for filename in files
        # filename is assumed to be same between src and tgt
        srcpath = joinpath(srcdir, filename)
        tgtpath = joinpath(tgtdir, filename)
        savepath = joinpath(dstdir, string(splitext(basename(srcpath))[1],
                                      "_parallel.jld"))

        @info("Start processing $(srcpath) and $(tgtpath)")
        elapsed = @elapsed begin
            src = load(srcpath)
            tgt = load(tgtpath)


            src, tgt = align!(src, tgt, threshold=threshold)
            save(savepath,
                 "description", "Parallel data",
                 "src", src,
                 "tgt", tgt
                 )
        end
        @info("Elapsed time in alignment is $(elapsed) sec.")
        @info("Dumped to $(savepath)")

        count += 1
        count >= nmax && break
    end

    @info("Finished")
end

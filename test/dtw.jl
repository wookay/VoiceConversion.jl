# Dynamic Time Warping (DTW)

using VoiceConversion.DTWs

println("testing: Dynamic time warping")

let
    # template sequence [1,2,3,4]
    v1 = [1. 2 3;1 2 4;1 8 5;10 3 6]'
    # sequence to be aligned [1 2 2 3 4]
    v2 = [1. 2 3;1 2 4;1 2 5; 1 8 5;10 3 6]'

    # Perform alignment
    d = DTW(bstep=1, fstep=0)
    indices = fit!(d, v1, v2)

    expected = Int[1, 2, 2, 3, 4]
    @test indices == expected
end

let
    v1 = [0.; 1; 2; 3; 4; 5]'
    v2 = [0.; 0; 1; 2; 3; 4; 4; 5;]'

    # Perform alignment
    d = DTW(bstep=1, fstep=0)
    indices = fit!(d, v1, v2)

    expected = Int[1, 1, 2, 3, 4, 5, 5, 6]
    @test indices == expected
end

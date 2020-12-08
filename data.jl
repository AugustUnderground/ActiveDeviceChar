using Statistics
using LinearAlgebra
using JLD2
using DataFrames
using Plots
using FFTW

# Read DF
df = jldopen("./data/ptmn.jld", "r") do file
    file["database"];
end;
df.Vgs = round.(df.Vgs, digits = 2);

# Matrix for specific W and L
sample = df[( (df.W .== 7.0e-7) 
           .& (df.L .== 1.5e-7))
           , : ];
vg = unique(sample[:, "Vgs"]);
vd = unique(sample[:, "Vds"]);
id = hcat(map((g) -> sample[(sample.Vgs .== g), "id"], vg)...);

heatmap(vg, vd, id)

# Matrix for specific W and L
sample = df[( (df.Vgs .== 0.6) 
           .& (df.Vds .== 0.6))
           , : ];
W = unique(sample[:, "W"]);
L = unique(sample[:, "L"]);
id = hcat(map((l) -> sample[(sample.L .== l), "id"], L)...);

heatmap(L, W, id)

sample[(sample.W .== 5.0e-6) .& (sample.L .== 1.5e-7),"id"]


## FFT
SAMPLE = fft(Matrix(sample));
absS = abs.(SAMPLE);
heatmap(absS)
shiftS = fftshift(SAMPLE);
heatmap(abs.(shiftS))
logS = log.(1 .+ abs.(shiftS));
heatmap(logS)

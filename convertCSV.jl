#!/usr/bin/env -S julia --project

using Statistics
using LinearAlgebra
using CSV
using JLD2
using HDF5
using DataFrames
using Printf
using ArgParse

function csv2df(csvFile)
    simData = CSV.File(csvFile, header=true, type=Float64) |> DataFrame;

    Cgg = simData[!, :cgg];
    Css = simData[!, :css];
    Cdd = simData[!, :cdd];
    Cbb = simData[!, :cbb];
    Csg = simData[!, :csg];
    Cgs = simData[!, :cgs];
    Cgd = simData[!, :cgd];
    Cdg = simData[!, :cdg];
    Cbg = simData[!, :cbg];
    Cgb = simData[!, :cgb];

    M = [  (2. / 7.)   -(3. / 14.)   (2. / 7.)   -(3. / 14.)   (3. / 14.)  -(2. / 7.)    (3. / 14.) 
        ;  (2. / 7.)   -(3. / 14.)  -(3. / 14.)   (2. / 7.)    (3. / 14.)   (3. / 14.)  -(2. / 7.) 
        ;  (2. / 7.)    (2. / 7.)   -(3. / 14.)  -(3. / 14.)  -(2. / 7.)    (3. / 14.)   (3. / 14.) 
        ; -(3. / 14.)   (2. / 7.)    (2. / 7.)   -(3. / 14.)   (3. / 14.)   (3. / 14.)  -(2. / 7.) 
        ; -(3. / 14.)   (2. / 7.)   -(3. / 14.)   (2. / 7.)    (3. / 14.)  -(2. / 7.)    (3. / 14.) 
        ; -(3. / 14.)  -(3. / 14.)   (2. / 7.)    (2. / 7.)   -(2. / 7.)    (3. / 14.)   (3. / 14.) ];

    C = [ Cgg' ; Css' ; Cdd' ; Cbb' 
        ; (Cgg + Css + Csg + Cgs)'
        ; (Cgg + Cdd + Cgd + Cdg)'
        ; (Cgg + Cbb + Cbg + Cgb)' ];

    Cxx = M * C; 

    data = DataFrame();

    data["Vgs"]     = simData[:vgs]
    data["Vds"]     = simData[:vds]
    data["Vbs"]     = simData[:vbs]
    data["W"]       = simData[:W];
    data["L"]       = simData[:L];
    data["vth"]     = simData[:vth];
    data["vdsat"]   = simData[:vdsat];
    data["id"]      = simData[:id];
    data["gm"]      = simData[:gm];
    data["gmb"]     = simData[:gmbs];
    data["gds"]     = simData[:gds];
    data["fug"]     = simData[:gm] ./ (2 .* π .* simData[:cgg]);
    data["cgd"]     = Cxx[1,:];
    data["cgb"]     = Cxx[2,:];
    data["cgs"]     = Cxx[3,:];
    data["cds"]     = Cxx[4,:];
    data["csb"]     = Cxx[5,:];
    data["cdb"]     = Cxx[6,:];

    return data
end

function df2jld(df, jldFile)
    jldopen(jldFile, "w") do file
        file["database"] = df;
    end;
end

function df2hdf(df, hdfFile)
    h5write(hdfFile, "database", df);
end

function parseArgs()
    settings = ArgParseSettings()

    @add_arg_table settings begin
        "--type", "-t"
            help = "Output Type, can be either `jld` or `hdf`."
            arg_type = String
            range_tester = (x) -> x in ["jld", "hdf", "h5"]
            default = "jld"
        "--out", "-o"
            help = "Path to output file."
            arg_type = String
            default = ""
            required = false
        "--verbose", "-v"
            help = "Verbose output, otherwise is quiet."
            action = :store_true
        "csv"
            help = "Path to CSV input file."
            required = true
    end

    return parse_args(settings)
end

function main()
    parsedArgs = parseArgs();

    csvFile = parsedArgs["csv"];
    outFile = parsedArgs["out"];
    outType = parsedArgs["type"];
    verbose = parsedArgs["verbose"];

    if isempty(outFile)
        idx = first(findlast(".", csvFile));
        outFile = csvFile[1:idx] * outType;
    end

    if verbose
        @printf("Converting %s to %s:\n", "csv", outType)
        @printf("\t%s -> %s\n", csvFile, outFile)
    end

    if verbose
        @printf("Reading %s and Converting to DataFrame ... ", csvFile)
        df = @time csv2df(csvFile);
        @printf("Done.\nStoring DataFrame as %s in %s\n", outType, outFile)
    else
        df = csv2df(csvFile);
    end

    if outType == "jld"
        df2jld(df, outFile);
    else
        df2hdf(df, outFile);
    end
    
    if verbose
        @printf("DataFrame Stored in %s, enjoy.\n", outFile)
    end

    exit(0)
end

main()

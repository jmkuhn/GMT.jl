"""
    blockmean(cmd0::String="", arg1=nothing; kwargs...)

Block average (x,y,z) data tables by L2 norm.
	
Full option list at [`blockmean`]($(GMTdoc)blockmean.html)

Parameters
----------

- $(GMT.opt_R)
- **I** | **inc** :: [Type => Str | Number]

    *x_inc* [and optionally *y_inc*] is the grid spacing.
    ($(GMTdoc)blockmean.html#i)
- **A** | **fields** :: [Type => Str]

    Select which fields to write to individual grids. Append comma-separated codes for available
    fields: **z** (the mean data z, but see **-S**), **s** (standard deviation), **l** (lowest value),
    **h** (highest value) and **w** (the output weight; requires **-W**). [Default is just **z**].
    ($(GMTdoc)blockmean.html#a)
- **C** | **center** :: [Type => Bool]

    Use the center of the block as the output location [Default uses the mean location]. Not used when **-A**
    ($(GMTdoc)blockmean.html#c)
- **E** | **extend** :: [Type => Str | []]

    Provide Extended report which includes s (the standard deviation about the mean), l, the lowest
    value, and h, the high value for each block. Output order becomes x,y,z,s,l,h[,w]. [Default
    outputs x,y,z[,w]. See -W for w output. If -Ep is used we assume weights are 1/(sigma squared)
    and s becomes the propagated error of the mean.
    ($(GMTdoc)blockmean.html#e)
- **G** | **outgrid** :: [Type => Str | []]

    Write one or more fields directly to grids on disk; no table data are return. If more than one
    fields are specified via **A** then grdfile must contain the format flag %s so that we can embed the
    field code in the file names. If not provided but **A** is used, return 1 or more GMTgrid type(s).
    ($(GMTdoc)blockmean.html#g)
- **S** :: [Type => Str | Symb] 

    Use S=:n to report the number of points inside each block, S=:s to report the sum of all z-values 
    inside a block, S=:w to report the sum of weights [Default (or S=:m reports mean value].
    ($(GMTdoc)blockmean.html#s)
- **npts** | **counts** :: [Type => Any] 

    Report the number of points inside each block
- **sum** :: [Type => Any] 

    Report the sum of all z-values inside each block
- **sum_weights** :: [Type => Any] 

    Report the the sum of weights
- **W** | **weights** :: [Type => Str | []]

    Unweighted input and output have 3 columns x,y,z; Weighted i/o has 4 columns x,y,z,w. Weights can
    be used in input to construct weighted mean values for each block.
    ($(GMTdoc)blockmean.html#w)
- $(GMT.opt_V)
- $(GMT.opt_bi)
- $(GMT.opt_di)
- $(GMT.opt_e)
- $(GMT.opt_f)
- $(GMT.opt_h)
- $(GMT.opt_i)
- $(GMT.opt_r)
- $(GMT.opt_swap_xy)
"""
function blockmean(cmd0::String="", arg1=nothing; kwargs...)

	length(kwargs) == 0 && return monolitic("blockmean", cmd0, arg1)

	d = KW(kwargs)
	help_show_options(d)		# Check if user wants ONLY the HELP mode
	cmd = parse_these_opts("", d, [[:E :extended], [:S]])
	if     (find_in_dict(d, [:npts :count])[1] !== nothing)  cmd *= " -Sn"
    elseif (find_in_dict(d, [:sum])[1] !== nothing)          cmd *= " -Ss"
    elseif (find_in_dict(d, [:sum_weights])[1] !== nothing)  cmd *= " -Sw"
    end

	return common_blocks(cmd0, arg1, d, cmd, "blockmean", kwargs...)
end

# ---------------------------------------------------------------------------------------------------
"""
    blockmedian(cmd0::String="", arg1=nothing; kwargs...)

Block average (x,y,z) data tables by L1 norm.
	
Full option list at [`blockmedian`]($(GMTdoc)blockmedian.html)
"""
function blockmedian(cmd0::String="", arg1=nothing; kwargs...)

	length(kwargs) == 0 && return monolitic("blockmedian", cmd0, arg1)

	d = KW(kwargs)
	help_show_options(d)		# Check if user wants ONLY the HELP mode
	cmd = parse_these_opts("", d, [[:E :extended], [:Q :quick], [:T :quantile]])
	return common_blocks(cmd0, arg1, d, cmd, "blockmedian", kwargs...)
end

# ---------------------------------------------------------------------------------------------------
"""
    blockmode(cmd0::String="", arg1=nothing; kwargs...)

Block average (x,y,z) data tables by mode estimation.
	
Full option list at [`blockmode`]($(GMTdoc)blockmode.html)
"""
function blockmode(cmd0::String="", arg1=nothing; kwargs...)

	length(kwargs) == 0 && return monolitic("blockmode", cmd0, arg1)

	d = init_module(false, kwargs...)[1]		# Also checks if the user wants ONLY the HELP mode
	cmd = parse_these_opts("", d, [[:E :extended], [:D :histogram_binning], [:Q :quick]])
	return common_blocks(cmd0, arg1, d, cmd, "blockmode", kwargs...)
end

# ---------------------------------------------------------------------------------------------------
function common_blocks(cmd0, arg1, d, cmd, proggy, kwargs...)

	cmd = parse_these_opts(cmd, d, [[:A :fields], [:C :center], [:I :inc], [:W :weights]])
	opt_G = add_opt(d, "", 'G', [:G :grid :outgrid])

	if (opt_G != "" && !occursin("-A", cmd))
		cmd = cmd * " -Az"					# So that we can use plain -G to mean write grid 
	end
	(length(opt_G) > 3) && (cmd *= opt_G)	# G=true will give " -G", which we'll ignore  (Have to)
	cmd, = parse_common_opts(d, cmd, [:R :V_params :bi :di :e :f :h :i :o :r :yx])

	cmd, got_fname, arg1 = find_data(d, cmd0, cmd, arg1)
	common_grd(d, proggy * " " * cmd, arg1)		# Finish build cmd and run it
end

# ---------------------------------------------------------------------------------------------------
blockmean(arg1, cmd0::String=""; kw...) = blockmean(cmd0, arg1; kw...)
# ---------------------------------------------------------------------------------------------------
blockmedian(arg1, cmd0::String=""; kw...) = blockmedian(cmd0, arg1; kw...)
# ---------------------------------------------------------------------------------------------------
blockmode(arg1, cmd0::String=""; kw...) = blockmode(cmd0, arg1; kw...)

"""
    grdimage(cmd0::String="", arg1=nothing, arg2=nothing, arg3=nothing; kwargs...)

Produces a gray-shaded (or colored) map by plotting rectangles centered on each grid node and assigning
them a gray-shade (or color) based on the z-value.

See full GMT (not the `GMT.jl` one) docs at [`grdimage`]($(GMTdoc)grdimage.html)

Parameters
----------

- **A** | **img_out** | **image_out** :: [Type => Str]

    Save an image in a raster format instead of PostScript.
- $(GMT._opt_J)
- $(GMT._opt_B)
- $(GMT.opt_C)
- **D** | **img_in** | **image_in** :: [Type => Str]

    Specifies that the grid supplied is an image file to be read via GDAL.
- **E** | **dpi** :: [Type => Int]

    Sets the resolution of the projected grid that will be created.
- **G** | **bit_color** :: [Type => Int]

- **I** | **shade** | **shading** | **intensity** :: [Type => Bool | Str | GMTgrid]

    Gives the name of a grid file or GMTgrid with intensities in the (-1,+1) range,
    or a grdgradient shading flags.
- **M** | **monochrome** :: [Type => Bool]

    Force conversion to monochrome image using the (television) YIQ transformation.
- **N** | **noclip** :: [Type => Bool]

    Do not clip the image at the map boundary.
- $(GMT.opt_P)
- **Q** | **alpha_color** | **nan_alpha** :: [Type => Bool | Tuple | Str]	``Q = true | Q = (r,g,b)``

    Make grid nodes with z = NaN transparent, or pick a color for transparency in a image.
- $(GMT._opt_R)
- $(GMT.opt_U)
- $(GMT.opt_V)
- $(GMT.opt_X)
- $(GMT.opt_Y)
- $(GMT._opt_f)
- $(GMT.opt_n)
- $(GMT._opt_p)
- $(GMT._opt_t)
- $(GMT.opt_savefig)

To see the full documentation type: ``@? grdimage``
"""
function grdimage(cmd0::String="", arg1=nothing, arg2=nothing, arg3=nothing; first=true, kwargs...)

	arg4 = nothing		# For the r,g,b + intensity case
	d, K, O = init_module(first, kwargs...)		# Also checks if the user wants ONLY the HELP mode
	common_insert_R!(d, O, cmd0, arg1)			# Set -R in 'd' out of grid/images (with coords) if limits was not used

	if (arg1 === nothing && haskey(d, :R) && guess_T_from_ext(cmd0) == " -Ti")
		_opt_R = d[:R]
		t = (isa(_opt_R, Tuple) || isa(_opt_R, VMr)) ?
			["$(_opt_R[1])", "$(_opt_R[2])", "$(_opt_R[3])", "$(_opt_R[4])"] : split(_opt_R, '/')
		opts = ["-projwin", t[1], t[4], t[2], t[3]]		# -projwin <ulx> <uly> <lrx> <lry>
		I = cut_with_gdal(cmd0, opts)
		(arg1 === nothing) ? arg1 = I : ((arg2 === nothing) ? arg2 = I : ((arg3 === nothing) ? arg3 = I : arg4 = I))
		cmd0 = ""
	end

	has_opt_B = (is_in_dict(d, [:B :frame :axis :axes]) !== nothing)
	cmd::String, opt_B::String, opt_J::String, opt_R::String = parse_BJR(d, "", "", O, " -JX" * split(def_fig_size, '/')[1] * "/0")
	(startswith(opt_J, " -JX") && !contains(opt_J, "/")) && (cmd = replace(cmd, opt_J => opt_J * "/0")) # When sub-regions
	(!has_opt_B && isa(arg1, GMTimage) && (isimgsize(arg1) || CTRL.limits[1:4] == zeros(4)) && opt_B == def_fig_axes_bak) &&
		(cmd = replace(cmd, opt_B => ""))	# Dont plot axes for plain images if that was not required

	cmd, = parse_common_opts(d, cmd, [:UVXY :params :c :f :n :p :t], first)
	cmd  = parse_these_opts(cmd, d, [[:A :img_out :image_out], [:D :img_in :image_in], [:E :dpi], [:G :bit_color],
	                                 [:M :monochrome], [:N :noclip], [:Q :nan_alpha :alpha_color]])
	cmd = add_opt(d, cmd, "%", [:layout :mem_layout], nothing)
	cmd = add_opt(d, cmd, "T", [:T :no_interp :tiles], (skip="_+s", skip_nan="_+s", outlines=("+o", add_opt_pen)))

	cmd, got_fname, arg1 = find_data(d, cmd0, cmd, arg1)		# Find how data was transmitted
	if (got_fname == 0 && isa(arg1, Tuple))			# Then it must be using the three r,g,b grids
		cmd, got_fname, arg1, arg2, arg3 = find_data(d, cmd0, cmd, arg1, arg2, arg3)
	end

	if (isa(arg1, Matrix{<:Real}))
		if (isa(arg1, Matrix{UInt8}) || isa(arg1, Matrix{UInt16}))
			arg1 = mat2img(arg1; d...)
		else
			arg1 = mat2grid(arg1)
			(isa(arg2, Matrix{<:Real})) && (arg2 = mat2grid(arg2))
			(isa(arg3, Matrix{<:Real})) && (arg3 = mat2grid(arg3))
		end
	end

	set_defcpt!(d, cmd0)	# When dealing with a remote grid assign it a default CPT

	cmd, _, arg1, arg2, arg3 = common_get_R_cpt(d, cmd0, cmd, opt_R, got_fname, arg1, arg2, arg3, "grdimage")
	cmd, arg1, arg2, arg3, arg4 = common_shade(d, cmd, arg1, arg2, arg3, arg4, "grdimage")

	if (isa(arg1, GMTimage) && !occursin("-Q", cmd))
		if (!occursin("-D", cmd))  cmd *= " -D"  end	# Lost track why but need this so gmt_main knows it should init a img
		(length(opt_J) > 3 && (opt_J[4] != 'X' && opt_J[4] != 'x')) && (cmd *= "r")	# GMT crashes when just -D and proj
	end

	do_finish = false
	_cmd = ["grdimage " * cmd]
	_cmd = frame_opaque(_cmd, opt_B, opt_R, opt_J; bot=false)		# No -t in frame
	if (!occursin("-A", cmd))			# -A means that we are requesting the image directly
		_cmd = finish_PS_nested(d, _cmd)
		do_finish = true
	end

	_cmd = finish_PS_nested(d, _cmd)
	if (length(_cmd) > 1 && cmd0 != "")		# In these cases no -R is passed so the nested calls set an unknown -R
		for k = 2:lastindex(_cmd)  _cmd[k] = replace(_cmd[k], "-R " => "-R" * cmd0 * " ")  end
	end
	finish_PS_module(d, _cmd, "", K, O, do_finish, arg1, arg2, arg3, arg4)
end

# ---------------------------------------------------------------------------------------------------
function common_insert_R!(d::Dict, O::Bool, cmd0, I_G)
	# Set -R in 'd' under several conditions. We may need this to make -J=:guess to work
	O && return
	if ((val = find_in_dict(d, [:R :region :limits], false)[1]) === nothing && (isa(I_G, GItype)))
		if (isa(I_G, GMTgrid) || !isimgsize(I_G))
			d[:R] = @sprintf("%.15g/%.15g/%.15g/%.15g", I_G.range[1], I_G.range[2], I_G.range[3], I_G.range[4])
		end
	elseif (val === nothing && (isa(cmd0, String) && cmd0 != "") && (CTRL.limits[1:4] != zeros(4) || snif_GI_set_CTRLlimits(cmd0)) )
		d[:R] = @sprintf("%.15g/%.15g/%.15g/%.15g", CTRL.limits[1], CTRL.limits[2], CTRL.limits[3], CTRL.limits[4])
	elseif (val !== nothing)
		if (isa(val, StrSymb))
			s = string(val)::String
			d[:R] = (s == "global" || s == "d") ? (-180,180,-90,90) : (s == "global360" || s == "g") ? (0,360,-90,90) : val
		else
			d[:R] = val
		end
		del_from_dict(d, [:region, :limits])
	end
end
function isimgsize(I_G)
	xy = (length(I_G.layout) > 1 && I_G.layout[2] == 'R') ? [1,2] : [2,1]	# 'R' means array is row major and first dim is xx
	(I_G.range[2] - I_G.range[1]) == size(I_G, xy[1]) && (I_G.range[4] - I_G.range[3]) == size(I_G, xy[2])
end

# ---------------------------------------------------------------------------------------------------
function common_shade(d::Dict, cmd::String, arg1, arg2, arg3, arg4, prog)
	# Used both by grdimage and grdview
	symbs = [:I :shade :shading :intensity]
	(show_kwargs[1]) && return print_kwarg_opts(symbs, "GMTgrid | String"), arg1, arg2, arg3, arg4

	if ((val = find_in_dict(d, symbs, false)[1]) !== nothing)
		if (!isa(val, GMTgrid))			# Uff, simple. Either a file name or a -A type modifier
			if (isa(val, String) || isa(val, Symbol) || isa(val, Bool))
				val = arg2str(val)
				(val == "" || val == "default" || val == "auto") ? cmd *= " -I+a-45+nt1" : cmd *= " -I" * val
    		else
				cmd = add_opt(d, cmd, "I", [:I :shading :shade :intensity],
							  (auto = "_+", azim = "+a", azimuth = "+a", norm = "+n", default = "_+d+a-45+nt1"))
			end
		else
			if (prog == "grdimage")  cmd, N_used = put_in_slot(cmd, 'I', arg1, arg2, arg3, arg4)
			else                     cmd, N_used = put_in_slot(cmd, 'I', arg1, arg2, arg3)
			end
			(N_used == 1) ? arg1 = val : ((N_used == 2) ? arg2 = val : ((N_used == 3) ? arg3 = val : arg4 = val))
		end
		del_from_dict(d, [:I, :shade, :shading, :intensity])
	end
	return cmd, arg1, arg2, arg3, arg4
end

# ---------------------------------------------------------------------------------------------------
function common_get_R_cpt(d::Dict, cmd0::String, cmd::String, opt_R::String, got_fname::Int, arg1, arg2, arg3, prog::String)
	# Used by several proggys
	if (convert_syntax[1])		# Here we cannot risk to execute any code. Just parsing. Movie stuff
		cmd, = add_opt_cpt(d, cmd, CPTaliases, 'C')
		N_used = !isempty_(arg1) + !isempty_(arg2) + !isempty_(arg3)
	else
		cmd, N_used, arg1, arg2, arg3 = get_cpt_set_R(d, cmd0, cmd, opt_R, got_fname, arg1, arg2, arg3, prog)
	end
	return cmd, N_used, arg1, arg2, arg3
end

# ---------------------------------------------------------------------------------------------------
function set_defcpt!(d::Dict, cmd0::String)
	# When dealing with remote grids (those that start with a @), assign them a default CPT
	cptname = check_remote_cpt(cmd0)
	cptname != "" && (d[:this_cpt] = cptname)
	return nothing
end

# ---------------------------------------------------------------------------------------------------
function check_remote_cpt(cmd0::String)
	out = ""
	(cmd0 == "" || (cmd0 != "" && cmd0[1] != '@')) && return ""
	cpt_path = joinpath(dirname(pathof(GMT)), "..", "share", "cpt")
	if (any(occursin.(["earth_relief_", "earth_gebco_", "earth_gebcosi_", "earth_synbath_"], cmd0))) out = "geo"
	elseif (any(occursin.(["earth_mag4km_", "earth_mag_"], cmd0)))  out = cpt_path * "/earth_mag.cpt"
	elseif (occursin("earth_wdmam_", cmd0))  out = cpt_path * "/earth_wdmam.cpt"
	elseif (occursin("earth_age_", cmd0))  out = cpt_path * "/earth_age.cpt"
	elseif (occursin("earth_faa_", cmd0))  out = cpt_path * "/earth_faa.cpt"
	elseif (occursin("earth_vgg_", cmd0))  out = cpt_path * "/earth_vgg.cpt"
	end
	return out
end

# ---------------------------------------------------------------------------------------------------
grdimage!(cmd0::String="", arg1=nothing, arg2=nothing, arg3=nothing; kw...) =
	grdimage(cmd0, arg1, arg2, arg3; first=false, kw...) 

grdimage(arg1,  arg2=nothing, arg3=nothing; kw...) = grdimage("", arg1, arg2, arg3; first=true, kw...)
grdimage!(arg1, arg2=nothing, arg3=nothing; kw...) = grdimage("", arg1, arg2, arg3; first=false, kw...)

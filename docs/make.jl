using Documenter, GMT

makedocs(
	modules = [GMT],
	sitename = "GMT",
	format = Documenter.HTML(assets = ["assets/custom.css"]),
	pages = Any[
		"Introduction"             => "usage.md",
		"Quick Learn"              => "quick_learn.md",
		"Some examples"            => "examples.md",
		"Draw rectangles examples" => "rectangles.md",
		"Draw frames examples"     => "frames.md",
		"Map projections"          => "proj_examples.md",
		"Gallery"                  => [
			"Advanced ISC example"  => "gallery/isc.md",
			"AGU"                   => "gallery/tables.md",
			"Bar plots"             => "gallery/bars/bars.md",
			"Color lines"           => "gallery/color_lines/color_lines.md",
			"Choropleth maps"       => [
										"Coutries (DCW)"    => "gallery/choropleths/choropleth_DCW.md",
										"Covid in Portugal" => "gallery/choropleths/choropleth_cv19.md"
										],
			"Contourf"              => "gallery/contourf/contourf.md",
			"Historical collection" => "gallery/historic.md",
			"Landsat8"              => "gallery/Landsat8/histogram_stretch.md",
			"Map projections"       => "gallery/mapprojs.md",
			"Plotting functions"    => "gallery/plot_funs/plot_funs.md",
			"Plotyy"                => "gallery/plotyy/plotyy.md",
			"Spirals"               => "gallery/spirals/spirals.md",
		],
		hide("gallery/scripts_agu/arrows_I.md"),
		hide("gallery/scripts_agu/arrows_II.md"),
		hide("gallery/scripts_agu/arrows_III.md"),
		hide("gallery/scripts_agu/bars_3D.md"),
		hide("gallery/scripts_agu/bars3_peaks.md"),
		hide("gallery/scripts_agu/bezier.md"),
		hide("gallery/scripts_agu/colored_bars.md"),
		hide("gallery/scripts_agu/compass.md"),
		hide("gallery/scripts_agu/decorated_I.md"),
		hide("gallery/scripts_agu/decorated_II.md"),
		hide("gallery/scripts_agu/error_bars.md"),
		hide("gallery/scripts_agu/flower.md"),
		hide("gallery/scripts_agu/histo_step.md"),
		hide("gallery/scripts_agu/matangles.md"),
		hide("gallery/scripts_agu/hello_I.md"),
		hide("gallery/scripts_agu/spiders.md"),
		hide("gallery/scripts_agu/snake.md"),
		hide("gallery/scripts_agu/solar.md"),
		hide("gallery/scripts_agu/scatter_cart.md"),
		hide("gallery/scripts_agu/scatter_polar.md"),
		hide("gallery/historic/ex01.md"),
		hide("gallery/historic/ex02.md"),
		hide("gallery/historic/ex03.md"),
		hide("gallery/historic/ex04.md"),
		hide("gallery/historic/ex05.md"),
		hide("gallery/historic/ex06.md"),
		hide("gallery/historic/ex07.md"),
		hide("gallery/historic/ex08.md"),
		hide("gallery/historic/ex09.md"),
		hide("gallery/historic/ex10.md"),
		hide("gallery/historic/ex11.md"),
		hide("gallery/historic/ex12.md"),
		hide("gallery/historic/ex13.md"),
		hide("gallery/historic/ex14.md"),
		hide("gallery/historic/ex15.md"),
		hide("gallery/historic/ex16.md"),
		hide("gallery/historic/ex17.md"),
		hide("gallery/historic/ex18.md"),
		hide("gallery/historic/ex19.md"),
		hide("gallery/historic/ex20.md"),
		hide("gallery/historic/ex21.md"),
		hide("gallery/historic/ex22.md"),
		hide("gallery/historic/ex23.md"),
		hide("gallery/historic/ex24.md"),
		hide("gallery/historic/ex25.md"),
		hide("gallery/historic/ex26.md"),
		hide("gallery/historic/ex27.md"),
		hide("gallery/historic/ex28.md"),
		hide("gallery/historic/ex29.md"),
		hide("gallery/historic/ex30.md"),
		hide("gallery/historic/ex32.md"),
		hide("gallery/historic/ex33.md"),
		hide("gallery/historic/ex34.md"),
		hide("gallery/historic/ex35.md"),
		hide("gallery/historic/ex36.md"),
		hide("gallery/historic/ex40.md"),
		hide("gallery/historic/ex41.md"),
		hide("gallery/historic/ex42.md"),
		hide("gallery/historic/ex43.md"),
		hide("gallery/historic/ex44.md"),
		hide("gallery/historic/ex45.md"),
		hide("gallery/historic/ex46.md"),
		hide("gallery/historic/ex48.md"),
		hide("pens.md"),
		hide("grdhisteq.md"),
		"Manual" => [
			"monolitic.md",
			"modules.md",
			"Common options"   => "common_opts.md",
			"General features" => [
				"arrows_control.md",
				"color.md",
				"decorated.md",
				"symbols.md",
			],
		],
		"Modules manuals" => [
			"arrows.md",
			"bar.md",
			"bar3.md",
			"coast.md",
			"colorbar.md",
			"contourf.md",
			"grdcontour.md",
			"grdimage.md",
			"grdgradient.md",
			"grdview.md",
			"histogram.md",
			"lines.md",
			"makecpt.md",
			"movie.md",
			"plot.md",
			"scatter.md",
			"scatter3.md",
			"solar.md",
			"subplot.md",
			"text.md",
		],
		"The GMT types"            => "types.md",
		"Index"                    => "index.md",
	],
)

deploydocs(
	repo   = "github.com/GenericMappingTools/GMT.jl.git",
	target  = "build",
	push_preview = true,
)

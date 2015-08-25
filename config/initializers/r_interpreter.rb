require 'rinruby'
R.echo(false,false)
R.eval(".libPaths(c(\"#{Dir.pwd}/r_libs\", .libPaths()))")

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "lib/valideizer/version.rb"

Gem::Specification.new do |spec|
  spec.name          = "valideizer"
  spec.version       = Valideizer::VERSION
  spec.authors       = ["Arthur 'ArtK0DE' Korochansky"]
  spec.email         = ["art2rik.desperado@gmail.com"]

  spec.summary       = %q{Small Gem to validate parameters}
  spec.description   = %q{Small Gem to validate parameters. Can be integrated with Rails controllers}
  spec.homepage      = "https://github.com/artk0de/valideizer"
  spec.license       = "MIT"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = %w(lib/valideizer.rb lib/valideizer/core.rb lib/valideizer/rails.rb lib/valideizer/error_printer.rb  lib/valideizer/rules.rb
                          lib/valideizer/version.rb lib/valideizer/holder.rb lib/valideizer/.rb)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
end

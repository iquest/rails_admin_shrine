$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_admin_shrine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_admin_shrine"
  s.version     = RailsAdminShrine::VERSION
  s.authors     = ["dush"]
  s.email       = ["dusanek@iquest.cz"]
  s.homepage    = "https://github.com/iquest/rails_admin_shrine"
  s.summary     = "Rails Admin field for Shrine file uploading gem."
  s.description = "Implements field for field Shrine uploader attribute"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'rails_admin', '>= 0.7.0'
end

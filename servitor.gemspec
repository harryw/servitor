Gem::Specification.new do |s|
  s.name        = 'servitor'
  s.version     = '0.0.1'
  s.date        = '2012-11-02'
  s.summary     = "A tool to help compose an SOA from 12-factor apps"
  s.description = "A tool to help compose an SOA from 12-factor apps"
  s.authors     = ["Harry Wilkinson"]
  s.email       = 'hwilkinson@mdsol.com'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")
  s.homepage    = 'http://github.com/harryw/servitor'

  s.add_dependency 'veewee', '0.3.0.beta2'
  s.add_dependency 'childprocess'
  s.add_dependency 'erubis'
  s.add_dependency 'mysql2'
  s.add_development_dependency 'rspec'
end

require "minitest/spec"
require "minitest/autorun"
require "pathname"
require "spending_parser"
require "pry"

TEST_ROOT = Pathname.new(File.dirname(__FILE__))
$:.unshift TEST_ROOT.parent.join("lib")

def fixture_path(path)
  TEST_ROOT.join("fixtures", path)
end

require 'spec_helper'
require 'rspec/expectations'

describe "be_successful" do
  before(:each) do
    stub_status("/success", 200)
    stub_status("/fail", 400)
  end

  it "should pass when it gets a 200" do
    expect(DOMAIN + "/success").to be_successful
  end

  it "should fail when it gets 400" do
    expect{expect(DOMAIN + "/fail").to be_successful}.to raise_error(RuntimeError)
  end
end

describe "be_gzipped" do
  before(:each) do
    zip = File.open("spec/fixtures/bar.gz", "r")
    stub_headers("/gzipped", { "content-encoding" => "gzip" }, zip.read)
    stub_headers("/not_gzipped_lies", { "content-encoding" => "gzip" })
    stub_headers("/gzipped_lies", { "content-encoding" => "something-else" }, zip.read)
    stub_headers("/not_gzipped", { "content-encoding" => "stuff" })
    zip.close
  end

  it "should pass when gzipped" do
    expect(DOMAIN + "/gzipped").to be_gzipped
  end

  it "should fail when not gzipped but header lies" do
    expect{expect(DOMAIN + "/not_gzipped_lies").to be_gzipped}.to raise_error(Zlib::GzipFile::Error)
  end

  it "should fail when gzipped but header lies" do
    expect{expect(DOMAIN + "/gzipped_lies").to be_gzipped}.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "should fail when not gzipped" do
    expect{expect(DOMAIN + "/not_gzipped").to be_gzipped}.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
require 'spec/spec_support'
require 'spec/prompt_helpers_support'

describe "prompt_for_value" do
  it "should return the value" do
    @value = 'value'
    prompt_for_value('value').should == 'value'
  end

  describe "with default" do
    it "should return the value when it's specified" do
      @value = 'value'
      prompt_for_value('value', :default => 'default').should == 'value'
    end
    it "should return the default when no value is specified" do
      @value = ''
      prompt_for_value('value', :default => 'default').should == 'default'
    end
  end
end

describe "prompt_for_path" do
  before { @value = tmp_prefix }
  it "should return the path" do
    prompt_for_path('path', :type => :path).should == tmp_prefix
  end
  describe "with ~" do
    before { @value = '~' }
    it "should return the path" do
      prompt_for_path('path').should == '~'
    end
  end
  describe "with default" do
    it "should return the value when it's specified" do
      @value = tmp_prefix
      prompt_for_path('path', :default => '/tmp').should == tmp_prefix
    end
    it "should return the default when no value is specified" do
      @value = ''
      prompt_for_path('path', :default => '/tmp').should == '/tmp'
    end
  end
  describe "with nonexistent path" do
    before { @value = tmp_prefix / 'nonexistent_path' }
    it "should fail" do
      prompt_for_path('path', :type => :path).should be_nil
    end
    it "should fail with a valid default" do
      prompt_for_path('path', :type => :path, :default => '/tmp').should be_nil
    end
  end
end

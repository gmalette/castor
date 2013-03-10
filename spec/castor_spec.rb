require_relative "spec_helper"

describe Castor do
  subject {
    Castor.configure do |config|

      # Complete syntax
      config.toto do
        type Integer
        value_in 1..50
        default 42
      end

      # Short syntax
      config.titi "hello"

      # Mass-assign syntax
      config.(:mass => :assign, :is => :working, :for => 100)
      
      # Nested
      config.more :nested => true do |nested_config|
        nested_config.titi :toto
      end

      # Nested through new Castor
      config.other_nested Castor.configure{|nested_config|
        nested_config.is_nested true
      }
    end
  }
  
  context "default values" do
    its(:toto) { should == 42 }
    its(:titi) { should == "hello" }
    its(:mass) { should == :assign }
    its(:is)   { should == :working }
    its(:for)  { should == 100 }
  end

  context "nested values" do
    it "sets the correct default values" do
      subject.more.titi.should == :toto
      subject.other_nested.is_nested.should be_true
    end
  end

  context "changing defaults" do
    context "to a valid value" do
      before {
        subject.toto = 11
      }

      its(:toto) { should == 11 }
    end

    context "to a value out of range" do
      it "throws an exception" do
        expect { subject.toto = 100 }.to raise_error Castor::Configuration::InvalidValueError
      end
    end
  end
end

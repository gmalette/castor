require_relative "spec_helper"

describe Castor do
  subject {
    Castor.configure do |config|
      config.toto do
        type Integer
        value_in 1..50
        default 42
      end
    end
  }
  
  context "default values" do
    its(:toto) { should == 42 }
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
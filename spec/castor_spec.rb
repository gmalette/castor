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

      # Lazy Eval
      config.time_now :lazy => lambda { Time.now }

      # Lazy eval with block
      config.lazy_increment do
        type Fixnum
        default 3
      end

      # Expected procs
      config.proc do
        type Proc
        default { 3 }
      end
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

  context "lazy values" do
    it "doesn't override the behavior of expected procs" do
      subject.proc.should be_a Proc
    end
  end

  context "changing defaults" do
    context "normal case" do
      before {
        subject.toto = 11
      }

      its(:toto) { should == 11 }
    end

    context "lazy eval" do
      before {
        i = 0
        subject.lazy_increment = lambda { i += 1 }
      }

      it "evaluates the proc" do
        subject.lazy_increment.should == 1
        subject.lazy_increment.should == 2
      end
    end

    context "to a value out of range" do
      it "throws an error" do
        expect { subject.toto = 100 }.to raise_error Castor::Configuration::InvalidValueError
      end
    end

    context "setting a value not specified" do
      it "throws an error" do 
        expect { subject.undefined_config_value(3) }.to raise_error NoMethodError
      end
    end
  end

  it "behaves like an enumerable"
end

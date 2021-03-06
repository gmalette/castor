require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Castor do
  subject {
    Castor.configure do |config|

      # Complete syntax
      config.def :toto do
        type Integer
        value_in 1..50
        default 42
      end

      # Short syntax
      config.def :titi, "hello"

      # Mass-assign syntax
      config.def_many(:mass => :assign, :is => :working, :for => 100)
      
      # Nested
      config.def :more, :nested => true do |nested_config|
        nested_config.def :titi, :toto
      end

      # Nested through new Castor
      config.def :other_nested, Castor.configure{|nested_config|
        nested_config.def :is_nested, true
      }

      # Lazy Eval
      config.def :time_now, :lazy => lambda { Time.now }

      # Lazy eval with block
      config.def :lazy_increment do
        type Fixnum
        default 3
      end

      # Expected procs
      config.def :proc do
        type Proc
        default { 3 }
      end
    end
  }
  
  context "default values" do
    its(:toto)      { should == 42 }
    its(:titi)      { should == "hello" }
    its(:mass)      { should == :assign }
    its(:is)        { should == :working }
    its(:for)       { should == 100 }
    its(:time_now)  { should be_a Time }
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

    context "by merging with a Hash" do
      before {
        subject.merge :toto => 21, :more => { :titi => 21 }
      }

      its(:toto) { should == 21 }

      it "deep merges hashes" do
        subject.more.titi.should == 21
      end
    end
  end

  context "trying to adding new nodes" do
    it "throws an exception" do
      expect { subject.def(:new_node, 3) }.to raise_error Castor::Configuration::AlreadyInitializedError
    end
  end

  it "behaves like an enumerable"
end

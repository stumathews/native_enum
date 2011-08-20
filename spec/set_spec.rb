require 'spec_helper'

describe "SET datatype" do

  describe "schema dump" do
    before { load_schema "set_old" }
    subject { standard_dump }

    it "dumps native format" do
      subject.should match %r{t\.set\s+"gadgets",\s+:limit => \["propeller", "tail gun", "gps"\]}
    end

    it "dumps default option" do
      subject.should match %r{t\.set\s+"gadgets",.+:default => \["propeller", "gps"\]}
    end

    it "dumps null option" do
      subject.should match %r{t\.set\s+"gadgets",.+:null => false$}
    end
  end

  describe "schema loading" do
    before { load_schema "set_new" }
    subject { ActiveRecord::Base.connection.select_one "SHOW FIELDS FROM balloons WHERE Field='ribbons'" }

    it "loads native format" do
      subject[ "Type" ].should == "set('red','green','gold')"
    end

    it "loads default option" do
      subject[ "Default" ].should == "green,gold"
    end

    it "loads null option" do
      subject[ "Null" ].should == "NO"
    end

    it "loads native column format" do
      subject = ActiveRecord::Base.connection.select_one "SHOW FIELDS FROM balloons WHERE Field='gasses'"
      subject[ "Type" ].should == "set('helium','hydrogen')"
    end
  end

  describe "assignment" do
    it "accepts single value"
    it "accepts array of values"
    it "accepts comma-separated values"
  end

  describe "validation" do
    it "validates assigned values are members of the list"
    it "allows nil when null enabled"
    it "allows empty list"
  end

  private
  def standard_dump
    stream = StringIO.new
    ActiveRecord::SchemaDumper.ignore_tables = []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.string.lines.select {|l| /^\s*#/.match(l).nil? }.join
  end
end
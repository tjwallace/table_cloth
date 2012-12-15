require 'spec_helper'

describe TableCloth::Presenter do
  subject { TableCloth::Presenter.new(objects, dummy_table, view_context) }
  let(:dummy_table) { Class.new(DummyTable) }
  let(:dummy_model) { FactoryGirl.build(:dummy_model) }

  let(:objects) { 3.times.map { FactoryGirl.build(:dummy_model) } }

  let(:view_context) { ActionView::Base.new }
  subject { TableCloth::Presenter.new(objects, dummy_table, view_context) }

  context ".columns" do
    it "returns all columns from the table" do
      expect(subject).to have(3).columns
    end

    it "returns hashes of the column detail" do
      subject.columns.each do |column|
        expect(column).to be_kind_of Hash
      end
    end
  end

  context ".column_names" do
    let(:table_instance) { dummy_table.new(objects, view_context) }
    before(:each) { table_instance.stub admin?: false, awesome?: true }

    it 'returns all names' do
      subject.column_names.should =~ ["Id", "Name", "Email"]
    end

    it 'uses a name given to it' do
      dummy_table.column :email, label: 'Email Address'
      subject.column_names.should include 'Email Address'
    end
  end

  it 'returns all values for a row' do
    subject.row_values(dummy_model).should == [dummy_model.id, dummy_model.name, dummy_model.email]
  end
  
  it 'generates the values for all of the rows' do
    expected = objects.map {|o| [o.id, o.name, o.email] }
    expect(subject.rows).to eq(expected)
  end

  context 'tags' do
    it '.wrapper_tag includes config for a tag in block form' do
      TableCloth::Configuration.table.should_receive(:to_hash).and_return(class: "stuff")
      table = subject.wrapper_tag(:table) { "Hello "}
      Nokogiri::HTML(table).at_xpath('//table')[:class].should == 'stuff'
    end

    it '.wrapper_tag includes config for a tag without a block' do
      TableCloth::Configuration.table.should_receive(:to_hash).and_return(class: "stuff")
      table = subject.wrapper_tag(:table, 'Hello')
      Nokogiri::HTML(table).at_xpath('//table')[:class].should == 'stuff'
    end
  end
end
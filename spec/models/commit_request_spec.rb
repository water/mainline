describe CommitRequest do
  it "should have have getters 'n setters for #options" do
    value = {data: 1}
    cr = CommitRequest.new(value)
    cr.options.should eq(value)
    cr.options = "value"
    cr.options.should eq("value")
  end
  
  describe "#perform!" do
    
  end
end
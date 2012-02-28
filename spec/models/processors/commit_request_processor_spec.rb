describe CommitRequestProcessor do
  let(:processor) { CommitRequestProcessor.new }

  it "should not crash" do
    lambda {  processor.on_message("Message") }.should_not raise_error
  end
end

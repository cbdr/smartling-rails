require 'spec_helper'

module SmartlingRails
  describe Config do
    let(:config) { Config.new }
    describe 'default behavior' do
      it 'api_key defaults to nil' do
        expect(config.api_key).to eq nil
      end
      it 'project_id defaults to nil' do
        expect(config.project_id).to eq nil
      end
      it 'locales defaults to hash' do
        expect(config.locales).to eq nil
      end
    end

    describe '.env file load' do

      before {
        file_content = 'SMARTLING_API_KEY=mocksmartlingkey
SMARTLING_PROJECT_ID=mockprojectid'
        file = double(File)
        expect(file).to receive(:each_line) {|&block| file_content.lines {|line| block.yield line } } 
        File.stub(:open) { |&block| block.yield file }
        File.should_receive(:exist?).with(".env").and_return(true)
      }
      
      it 'should set api_key from file' do
        expect(config.api_key).to eq 'mocksmartlingkey'
      end

      it 'should set api_key from file' do
        expect(config.project_id).to eq 'mockprojectid'
      end
    end
  end
end
 
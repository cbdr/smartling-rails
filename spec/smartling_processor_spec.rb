require 'spec_helper'

module SmartlingRails
  describe SmartlingProcessor do
    
    let(:processor) { SmartlingRails::SmartlingProcessor.new}
    let(:my_smartling) {double('my_smartling', :status => nil)}
    before {
      SmartlingRails.configuration
      processor.my_smartling = my_smartling
    }

    describe 'initialize' do
      it 'xxx' do
      end
    end

    describe 'get_file_statuses' do
      it 'loops over locales and checks each one' do
        processor.should_receive(:check_file_status).at_least(SmartlingRails.configuration.locales.count).times
        processor.get_file_statuses
      end
    end

    describe 'supported_locales' do
      it 'should return an output friendly array of supported locales' do
        expect(processor.supported_locales).to eq ["French fr-FR", "German de-DE", "Dutch nl-NL", "Italian it-IT", "Swedish sv-SE", "Chinese zh-CN", "Spanish es-ES", "FrenchCanadian fr-CA", "Greek el-GR"]
      end
    end

    describe 'check_file_status' do
      it 'gracefully handles lack of smartling credentials' do
        allow($stdout).to receive(:puts) { "mock puts" }
        allow(my_smartling).to receive(:status) { raise "Missing parameters: [:apiKey, :projectId]" }
        processor.check_file_status('fr-FR')
        expect($stdout).to have_received(:puts).with('Missing parameters: [:apiKey, :projectId]')
      end
      it 'knows when processing is comlete' do
        allow($stdout).to receive(:puts) { "mock puts" }
        result = {"fileUri"=>"/files/adam-test-resume-[ver-interim-translations]-en-us-.yml", "lastUploaded"=>"2015-02-21T19:56:23", "stringCount"=>161, "fileType"=>"yaml", "wordCount"=>664, "callbackUrl"=>nil, "approvedStringCount"=>161, "completedStringCount"=>161}
        allow(my_smartling).to receive(:status).and_return(result)
        processor.check_file_status('fr-FR')
        expect($stdout).to have_received(:puts).with('fr-FR completed: true (161 / 161)')
      end
      it 'knows when processing is not comlete' do
        allow($stdout).to receive(:puts) { "mock puts" }
        result = {"fileUri"=>"/files/adam-test-resume-[ver-interim-translations]-en-us-.yml", "lastUploaded"=>"2015-02-21T19:56:23", "stringCount"=>161, "fileType"=>"yaml", "wordCount"=>664, "callbackUrl"=>nil, "approvedStringCount"=>10, "completedStringCount"=>16}
        allow(my_smartling).to receive(:status).and_return(result)
        processor.check_file_status('fr-FR')
        expect($stdout).to have_received(:puts).with('fr-FR completed: false (16 / 161)')
      end
    end

    describe 'put_files' do
      it 'xxx' do
      end
    end

    describe 'upload_english_file' do
      it 'xxx' do
      end
    end

    describe 'local_file_path_for_locale' do
      it 'correctly defines the local file path besed on hostsite' do
        expect(processor.local_file_path_for_locale('de-de')).to eq "config/locales/de-de.yml"
        expect(processor.local_file_path_for_locale('en-ca')).to eq "config/locales/en-ca.yml"
      end
    end

    describe 'upload_file_path' do

      it 'returns the constructed path for smartling' do
        expect(processor.upload_file_path).to eq "/files/adam-test-resume-[mock_branch]-en-us.yml"
      end
    end

    describe 'get_files' do
      it 'xxx' do
      end
    end

    describe 'fetch_fix_and_save_file_for_locale' do
      it 'xxx' do
      end
    end

    describe 'get_file_for_locale' do
      it 'initializes a smartling_file object' do
        mock_french_locale = {smartling: 'fr-FR', careerbuilder: 'fr-fr'}
        smartling_file = processor.get_file_for_locale(SmartlingRails.locales[:French])
        expect(smartling_file.file_contents).to eq ''
        expect(smartling_file.locale_codes).to eq mock_french_locale
      end
    end

    describe 'save_to_local_file' do
      it 'xxx' do
      end
    end

    describe 'get_current_branch' do
      it 'returns the branch name indicated by * from the "git brach" command' do
        processor.should_receive(:`).at_least(1).times.with("git branch").and_return("* adding-tests\n  master\n  update-readme")
        expect(processor.get_current_branch).to eq 'adding-tests'
      end
    end
    
  end
end
 
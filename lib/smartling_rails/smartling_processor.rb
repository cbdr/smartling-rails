module SmartlingRails
  class SmartlingProcessor
    attr_accessor :my_smartling

    def initialize()
      puts SmartlingRails.configuration
      @my_smartling = Smartling::File.new(:apiKey => SmartlingRails.api_key, :projectId => SmartlingRails.project_id)
      #@my_smartling = Smartling::File.sandbox(:apiKey => @@api_key, :projectId => @@project_id)
      #puts @my_smartling.list
      SmartlingRails.print_msg "You are working with this remote file on smartling: #{upload_file_path}", true
      SmartlingRails.print_msg "Smartling Ruby client #{Smartling::VERSION}"
    end

    def get_file_statuses
      SmartlingRails.print_msg("Checking status for #{supported_locales}", true)
      SmartlingRails.locales.each do |language, codes|
        check_file_status(codes[:smartling])
      end
    end

    def supported_locales
      SmartlingRails.locales.map { |language, codes| language.to_s + ' ' + codes[:smartling] }
    end

    def check_file_status(language_code)
      begin
        res = @my_smartling.status(upload_file_path, :locale => language_code)
        total_strings =  res['stringCount'].to_i
        completed_strings =  res['completedStringCount'].to_i
        file_complete = completed_strings >= total_strings 
        SmartlingRails.print_msg "#{language_code} completed: #{file_complete} (#{completed_strings} / #{total_strings})"
      rescue Exception => e
        puts e
      end
    end

    def put_files
      SmartlingRails.print_msg "Uploading the english file to smartling to process:", true
      upload_english_file()
    end

    def upload_english_file()
      SmartlingRails.print_msg "uploading #{local_file_path_for_locale('en-us')} to #{upload_file_path}"
      @my_smartling.upload(local_file_path_for_locale('en-us'), upload_file_path, 'YAML')
    end

    def local_file_path_for_locale(cb_locale)
      "config/locales/#{cb_locale}.yml"
    end

    def upload_file_path()
      "/files/adam-test-resume-en-us-[#{get_current_branch}].yml"
    end

    def get_files
      SmartlingRails.print_msg("Checking status for #{supported_locales}", true)
      SmartlingRails.locales.each do |language, locale_codes|
        fetch_fix_and_save_file_for_locale(locale_codes)
      end
    end

    def fetch_fix_and_save_file_for_locale(locale_codes)
      smartling_file = get_file_for_locale(locale_codes)
      smartling_file.fix_file_issues()
      save_to_local_file(smartling_file.file_contents, locale_codes[:careerbuilder])
    end

    def get_file_for_locale(locale_codes)
      smartling_file = SmartlingFile.new('', locale_codes)
      SmartlingRails.print_msg "Downloading #{locale_codes[:smartling]}:", true
      begin
        smartling_file.file_contents = @my_smartling.download(upload_file_path, :locale => locale_codes[:smartling])
        SmartlingRails.print_msg "file loaded..."
      rescue Exception => e
        SmartlingRails.print_msg e
      end
      smartling_file
    end

    def save_to_local_file(file_contents, cb_locale)
      File.open(local_file_path_for_locale(cb_locale), 'w') { |file| file.write(file_contents) }
    end

    

    def get_current_branch
      b = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
      b.first.gsub("* ","")
    end
  end
end
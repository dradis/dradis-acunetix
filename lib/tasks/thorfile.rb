class AcunetixTasks < Thor
  include Rails.application.config.dradis.thor_helper_module

  namespace 'dradis:plugins:acunetix:upload'

  desc 'standard FILE', 'upload Standard Acunetix XML results'
  def standard(file_path)
    detect_and_set_project_scope
    importer = Dradis::Plugins::Acunetix::Standard::Importer.new(task_options)

    process_upload(importer, file_path)
  end

  desc 'acunetix_360 FILE', 'upload Acunetix360 XML results'
  def acunetix_360(file_path)
    detect_and_set_project_scope
    importer = Dradis::Plugins::Acunetix::Acunetix360::Importer.new(task_options)

    process_upload(importer, file_path)
  end

  private

  def process_upload(importer, file_path)
    require 'config/environment'

    unless File.exist?(file_path)
      $stderr.puts "** the file [#{file_path}] does not exist"
      exit -1
    end

    importer.import(file: file_path)
  end
end

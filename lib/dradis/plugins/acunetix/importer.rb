module Dradis::Plugins::Acunetix
  class Importer < Dradis::Plugins::Upload::Importer

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def import(params={})
      file_content    = File.read( params[:file] )

      logger.info{'Parsing Acunetix output file...'}
      doc = Nokogiri::XML( file_content )
      logger.info{'Done.'}

      return true
    end # /import
  end
end
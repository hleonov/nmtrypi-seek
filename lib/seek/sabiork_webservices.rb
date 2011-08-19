require 'rest_client'
require 'libxml'

module Seek
  class SabiorkWebservices
    def get_compound_annotation compound_name
      url=URI.encode(webservice_base_url+"suggestions/compounds?searchCompounds=#{compound_name}")
      doc = get_xml_doc url
      compound_annotations = {}
      unless doc.blank?
        doc.find("/suggestionsResource_Compounds/Compound").collect do |node|
          #compound_annotations.push node.child.content
        end
      end
      compound_annotations
    end

    def webservice_base_url
      "http://hitssv506.h-its.org/sabioRestWebServices/"
    end

    def get_xml_doc url
      begin
        response = RestClient.get(url)
        parser = LibXML::XML::Parser.string(response, :encoding => LibXML::XML::Encoding::UTF_8)
        doc = parser.parse
        doc
      rescue
        return nil
      end
    end
  end
end
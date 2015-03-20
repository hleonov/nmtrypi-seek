module Seek
  module Data
    class CompoundsExtraction
      include Singleton

      attr_reader :compound_id_smiles_hash

      def initialize
        #need run "bundle exec rake tmp:clear to clean cache"
        @compound_id_smiles_hash ||= get_compound_id_smiles_hash
      end


      private

      def get_compound_id_smiles_hash
        id_smiles_hash = {}
        DataFile.all.each do |df|
          id_smiles_hash.merge! get_compound_id_smiles_hash_per_file(df)
        end
        #sort by key
        id_smiles_hash.sort_by{|k,v| k.to_s}.to_h
      end

      def get_compound_id_smiles_hash_per_file data_file
        Rails.cache.fetch("#{data_file.content_blob.cache_key}-compound-id-smile-hash") do
          id_smiles_hash = {}
          #temporiably only excels
          if data_file.content_blob.is_extractable_spreadsheet?
            xml = data_file.spreadsheet_xml
            doc = LibXML::XML::Parser.string(xml).parse
            doc.root.namespaces.default_prefix="ss"
            compound_id_cells = get_column_cells doc, "compound"
            smiles_cells = get_column_cells doc, "smile"
            compound_id_cells.each do |id_cell|
              row_index = id_cell.attributes["row"]
              smile = smiles_cells.detect { |cell| cell.attributes["row"] == row_index }.try(:content)
              if id_cell && is_standard_compound_id?(id_cell.content) && !smile.blank?
                standardized_content = Seek::Search::SearchTermStandardize.to_standardize(id_cell.content)
                id_smiles_hash[standardized_content] = smile
              end
            end
          end
          id_smiles_hash
        end

      end
      def get_column_cells doc, column_name
        head_cells = doc.find("//ss:sheet[@hidden='false' and @very_hidden='false']/ss:rows/ss:row/ss:cell").find_all { |cell| cell.content.gsub(/\s+/, " ").strip.match(/#{column_name}/i) }
        body_cells = []
        unless head_cells.blank?
          head_cell = head_cells[0]
          head_col = head_cell.attributes["column"]
          body_cells = doc.find("//ss:sheet[@hidden='false' and @very_hidden='false']/ss:rows/ss:row/ss:cell[@column=#{head_col} and @row != 1]").find_all { |cell| !cell.content.blank? }
        end

        body_cells

      end

      def is_standard_compound_id? content
        Seek::Search::SearchTermStandardize.to_standardize?(content)
      end
    end
  end
end
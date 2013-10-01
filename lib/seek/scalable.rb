module Seek
  module Scalable
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods

      def acts_as_scalable
        acts_as_annotatable :name_field=>:title
        include Seek::Scalable::InstanceMethods
        include Seek::Scalable::WithParamsInstanceMethods
      end


    end

    module InstanceMethods

      def scales= scales, source=User.current_user
        scales = resolve_types(scales)

        remove = self.scales - scales
        add = scales - self.scales
        add.each do |scale|
          annotation = Annotation.new(
              :source => source,
              :annotatable => self,
              :attribute_name => "scale",
              :value => scale
          )
          annotation.save
        end
        remove.each do |scale|
          annotation = Annotation.for_annotatable(self.class.name,self.id).with_attribute_name("scale").select{|an| an.value == scale}.first
          annotation.destroy unless annotation.nil?
          remove_additional_scale_info(scale.id)
        end
      end

      def scales
        self.annotations_with_attribute("scale",true).collect{|an| an.value}.sort_by(&:pos)
      end

      private

      #handles scales passed as Id's, invalid or blank ids, or a single item
      def resolve_types scales
        scales = Array(scales).collect do |scale|
          if scale.is_a?(Numeric) || scale.is_a?(String)
            scale=Scale.find_by_id(scale)
          end
          scale
        end.compact
      end
    end

    module WithParamsInstanceMethods
      def attach_additional_scale_info scale_id, other_info={},source=User.current_user
        other_info[:scale_id]=scale_id.to_s
        value = TextValue.new
        value.text=other_info.to_json
        annotation = Annotation.new(
            :source => source,
            :annotatable => self,
            :attribute_name => "additional_scale_info",
            :value => value
        )
        annotation.save
      end

      def fetch_additional_scale_info scale_id
        self.annotations_with_attribute("additional_scale_info",true).select do |an|
          json = JSON.parse(an.value.text)
          json["scale_id"]==scale_id.to_s
        end.collect do |an|
          JSON.parse(an.value.text)
        end.first
      end

      def remove_additional_scale_info scale_id
        self.annotations_with_attribute("additional_scale_info",true).select do |an|
          json = JSON.parse(an.value.text)
          json["scale_id"]==scale_id.to_s
        end.each do |an|
          an.destroy
        end
      end
    end

  end
end

ActiveRecord::Base.class_eval do
  include Seek::Scalable
end
require "rails_admin_shrine/engine"

module RailsAdminShrine
end

require 'rails_admin/config/fields'
require 'rails_admin/config/fields/base'
require 'rails_admin/config/fields/types/file_upload'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Shrine < RailsAdmin::Config::Fields::Types::FileUpload
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :thumb_method do
            unless defined? @thumb_method
              @thumb_method ||= begin              
                attacher = bindings[:object].try("#{name}_attacher".to_sym)              
                if attacher
                  versions = attacher.shrine_class.version_names 
                  versions.detect{|v| v.in?([:thumb, :thumbnail, 'thumb', 'thumbnail']) } || versions.first.to_s
                end  
              end
            end
            @thumb_method  
          end

          register_instance_option :delete_method do
            "remove_#{name}"
          end

          register_instance_option :cache_method do
            "cached_#{name}_data"
          end

          def resource_url(thumb = false)
            return nil unless (uploader = bindings[:object].send(name)).present?                        
            if uploader.is_a? Hash # has versions
              thumb.present? ? uploader[thumb].url : uploader[uploader.keys.first].url
            else
              uploader.url  
            end  
          end
        end
      end
    end
  end
end

RailsAdmin::Config::Fields.register_factory do |parent, properties, fields|
  model = parent.abstract_model.model  
  if defined?(::Shrine) && (attachment_names = (model).ancestors.select{|m| m.is_a? Shrine::Attachment}.map{|a| a.instance_variable_get("@name")}).any? && (attachment_name = attachment_names.detect{|a| a == properties.name.to_s.chomp('_data').to_sym})
    columns = [attachment_name, "#{attachment_name}_data".to_sym]
    field = RailsAdmin::Config::Fields::Types.load(:shrine).new(parent, attachment_name, properties)
    fields << field
    children_fields = []
    columns.each do |children_column_name|
      next unless child_properties = parent.abstract_model.properties.detect { |p| p.name.to_s == children_column_name.to_s }
      children_field = fields.detect { |f| f.name == children_column_name } || RailsAdmin::Config::Fields.default_factory.call(parent, child_properties, fields)
      children_field.hide unless field == children_field
      children_field.filterable(false) unless field == children_field
      children_fields << children_field.name
    end
    field.children_fields(children_fields)
    true
  else
    false
  end
end



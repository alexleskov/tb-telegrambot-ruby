# frozen_string_literal: true

module Teachbase
  module Bot
    class ContentLoaderController < Teachbase::Bot::DataLoaderController
      ADDTION_OBJECTS = { attachments: :attachment,
                          answers: :answer,
                          comments: :comment }.freeze

      attr_reader :lms_info, :cs_tb_id, :tb_id, :section_loader

      def initialize(appshell, section_loader, params = {})
        @section_loader = section_loader
        @tb_id = params[:tb_id]
        @cs_tb_id = section_loader.cs_tb_id
        raise "Must be set up 'section_loader', 'tb_id' and 'cs_tb_id" unless tb_id && cs_tb_id && section_loader

        super(appshell)
      end

      def db_entity(mode = :no_create)
        call_data do
          case mode
          when :with_create
            section_db.public_send(self.class::METHOD_CNAME).find_or_create_by!(tb_id: tb_id)
          else
            section_db.public_send(self.class::METHOD_CNAME).find_by!(tb_id: tb_id)
          end
        end
      end

      def section_db
        section_loader.db_entity(:no_create)
      end

      def me
        raise "Section not found" unless section_db

        lms_load
        update_data(lms_info, :no_create)
      end

      protected

      def attach_all_addition_objects(content, data_from_lms)
        Teachbase::Bot::ContentLoaderController::ADDTION_OBJECTS.keys.each do |addition_object|
          attach_addition_object(addition_object, content, data_from_lms)
        end
      end

      def attach_addition_object(addition_object, content, data_from_lms = lms_info)
        return unless addition_object?(addition_object, data_from_lms)

        data_from_lms[addition_object.to_s].each do |data_lms|
          data_type_class = to_constantize(to_camelize(addit_data_sign(addition_object)), "Teachbase::Bot::")
          attributes = Attribute.create(data_type_class.attribute_names, data_lms)
          attributes[:tb_id] = data_lms["id"] if data_lms["id"]
          attributes[:tb_created_at] = data_lms["created_at"] if data_lms["created_at"]
          addition_data_bd = content.public_send(addition_object).find_or_create_by!(attributes)
          next unless data_lms.keys.any? { |key| ADDTION_OBJECTS.include?(key.to_sym) }

          ADDTION_OBJECTS.keys.each do |sub_addition_object|
            attach_addition_object(sub_addition_object, addition_data_bd, data_lms)
          end
        end
      end

      def addition_object?(addition_object, data_from_lms)
        data_from_lms.keys.include?(addition_object.to_s) && !data_from_lms[addition_object.to_s].empty?
      end

      def addit_data_sign(addition_object)
        (ADDTION_OBJECTS[addition_object.to_sym]).to_s
      end

      def data_type_class(addition_object)
        to_constantize(to_camelize(addit_data_sign(addition_object)), "Teachbase::Bot::")
      end
    end
  end
end

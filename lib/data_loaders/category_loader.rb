# frozen_string_literal: true

module Teachbase
  module Bot
    class CategoryLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :tb_id, :lms_info

      def initialize(appshell, params)
        @tb_id = params[:tb_id]
        @lms_info = params[:lms_info]
        super(appshell)
      end

      def me
        @tb_id = lms_info["id"]
        update_data(lms_info.merge!("tb_id" => lms_info["id"]))
      end

      # Endpoint deleted in Teachbase
      #
      #       def list
      #         lms_load
      #         lms_info.each do |course_type_lms|
      #           @tb_id = lms_info["id"]
      #           update_data(course_type_lms.merge!("tb_id" => lms_info["id"]))
      #         end
      #       end

      def db_entity(mode = :with_create)
        call_data do
          case mode
          when :with_create
            model_class.find_or_create_by!(tb_id: tb_id)
          else
            model_class.find_by!(tb_id: tb_id)
          end
        end
      end

      def model_class
        Teachbase::Bot::Category
      end

      private

      # Endpoint deleted in Teachbase
      #
      #       def lms_load
      #         @lms_info = call_data { appshell.authsession.load_course_types }
      #       end
    end
  end
end

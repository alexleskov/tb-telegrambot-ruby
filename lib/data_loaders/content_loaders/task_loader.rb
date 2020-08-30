# frozen_string_literal: true

module Teachbase
  module Bot
    class TaskLoader < Teachbase::Bot::ContentLoaderController
      CUSTOM_ATTRS = {}.freeze
      METHOD_CNAME = :tasks

      def me
        super
        attach_all_addition_objects(db_entity, lms_info)
        db_entity
      end

      def model_class
        Teachbase::Bot::Task
      end

      def submit(params)
        raise unless db_entity || !params.is_a?(Hash)

        update_data(lms_upload(params.merge!(data: :submit)), :no_create)
      end

      private

      def lms_upload(options)
        @lms_info = call_data do
          case options[:data].to_sym
          when :submit
            if options[:answer]
              appshell.authsession.send_task_answer(cs_tb_id, tb_id, options[:answer])
            elsif options[:comment]
              appshell.authsession.send_task_comment(db_entity.answers.last_sended.tb_id, options[:comment])
            else
              raise "Must have comment or answer"
            end
          end
        end
      end

      def lms_load
        @lms_info = call_data { appshell.authsession.load_task(cs_tb_id, tb_id) }
      end
    end
  end
end

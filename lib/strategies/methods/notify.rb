# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Notify < Teachbase::Bot::Strategies
        attr_reader :from_user, :type

        def initialize(controller, options)
          super(controller)
          @from_user = options[:from_user] || appshell.user_with_full_name
          @type = options[:type]
        end

        def send_to(tg_id)
          interface.sys.text.ask_answer.show
          appshell.ask_answer(mode: :bulk, saving: :cache)
          interface.sys.menu(disable_web_page_preview: true, mode: :none)
                   .confirm_answer(:message, appshell.user_cached_answer).show
          answer_data = build_answer_data(files_mode: :download_url)
          on_answer_confirmation(reaction: user_reaction.source) do
            interface.sys.text(text: "#{answer_data[:text]}\n\n#{build_attachments_list(answer_data[:attachments])}")
                     .send_to(tg_id, from_user)
          end
          appshell.authsession(:without_api) ? interface.sys.menu.after_auth.show : interface.sys.menu.starting.show
        end

        def about(entity_tb_id)
          appshell.authsession(:with_api)
          entity_loader = appshell.data_loader.public_send(type, tb_id: entity_tb_id)
          entity_interface = interface.public_send(type, entity_loader.info)
          case type
          when :cs
            entity_interface.text(text: "#{default_greetings} #{I18n.t('course').downcase}:\n")
                            .course.show
          end
        end

        private

        def default_greetings
          "#{I18n.t('greeting_message')} #{from_user}!\n\n#{I18n.t('notify_about_new')}"
        end
      end
    end
  end
end

# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Core < Teachbase::Bot::Strategies
        include Teachbase::Bot::Strategies::ActionsList

        def administration
          with_tg_user_policy [:admin] do
            appshell.change_scenario(Teachbase::Bot::Strategies::ADMIN_MODE_NAME)
            interface.admin.menu.main.show
          end
        end

        def starting
          appshell.to_default_scenario
        end

        def help
          interface.sys.text.help_info.show
        end

        def demo_mode
          appshell.logout
          appshell.change_scenario(Teachbase::Bot::Strategies::DEMO_MODE_NAME)
          appshell.controller.context.handle.starting
        end

        def sign_out
          interface.sys.menu.farewell(appshell.user_fullname(:string)).show
          appshell.to_default_scenario if demo_mode?
          appshell.logout
          appshell.controller.context.handle
          appshell.controller.context.current_strategy.starting
        rescue RuntimeError => e
          interface.sys.text.on_error(e).show
        end

        alias closing sign_out

        def ready; end

        def decline; end

        def send_contact; end

        protected

        def admin
          with_tg_user_policy [:admin] do
            Teachbase::Bot::Strategies::Admin.new(controller)
          end
        end

        def demo_mode?
          controller.context.settings.scenario == DEMO_MODE_NAME
        end

        def build_attachments_list(attachments_array)
          return "" if attachments_array.empty?

          result = ["#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"]
          attachments_array.each_with_index do |attachment, ind|
            result << to_url_link(attachment[:file], "#{I18n.t('file').capitalize} #{ind + 1}").to_s
          end
          result.join("\n")
        end

        def build_answer_data(params = {})
          return { text: appshell.cached_answers_texts } if params.empty?
          raise "No such mode: '#{params[:files_mode]}'." unless %i[upload download_url].include?(params[:files_mode].to_sym)

          attachments = []
          files_ids = appshell.cached_answers_files
          unless files_ids.empty?
            appshell.cached_answers_files.each do |file_id|
              attachments << { file: appshell.controller.filer.public_send(params[:files_mode], file_id) }
            end
            attachments
          end
          { text: appshell.cached_answers_texts, attachments: attachments }
        end

      end
    end
  end
end

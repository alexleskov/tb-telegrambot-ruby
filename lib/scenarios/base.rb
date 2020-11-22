# frozen_string_literal: true

require './lib/scenarios/base/content'
require './lib/scenarios/base/course_session'
require './lib/scenarios/base/profile'
require './lib/scenarios/base/section'
require './lib/scenarios/base/setting'
require './lib/scenarios/base/document'

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter
        include Teachbase::Bot::Scenarios::Base::Content
        include Teachbase::Bot::Scenarios::Base::CourseSession
        include Teachbase::Bot::Scenarios::Base::Profile
        include Teachbase::Bot::Scenarios::Base::Section
        include Teachbase::Bot::Scenarios::Base::Setting
        include Teachbase::Bot::Scenarios::Base::Document

        TEACHSUPPORT_TG_ID = 439_802_952

        def starting
          interface.sys.menu.about_bot.show
          interface.sys.menu.starting.show
        end

        def sign_in
          interface.sys.text.on_enter(appshell.account_name).show
          auth = appshell.authorization
          raise unless auth

          appshell.data_loader.user.profile.me
          interface.sys.menu.greetings(appshell.account_name, appshell.user.profile_info(appshell.current_account.id)).show
          interface.sys.menu.after_auth.show
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end

        def sign_out
          interface.sys.menu.farewell(appshell.user_fullname).show
          appshell.logout
          interface.sys.menu.starting.show
        rescue RuntimeError => e
          interface.sys.text.on_error(e).show
        end

        alias closing sign_out

        def change_account
          appshell.logout_account
          sign_in
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end

        alias accounts change_account

        def check_status(mode = :silence)
          text_interface = interface.sys.text
          text_interface.update_status(:in_progress).show
          result = yield

          if mode == :silence && result
            interface.destroy(delete_bot_message: { mode: :last })
            return result
          end

          if result
            text_interface.update_status(:success).show
          else
            text_interface.update_status(:fail).show
          end
          interface.destroy(delete_bot_message: { mode: :previous })
          result
        end

        def ready; end

        def send_message_to(tg_id, options_sender = {})
          options_sender[:from_user] ||= appshell.user_fullname.to_s
          interface.sys.text.ask_answer.show
          appshell.ask_answer(mode: :bulk, saving: :cache)
          interface.sys.menu(disable_web_page_preview: true, mode: :none)
                   .confirm_answer(:message, appshell.user_cached_answer).show
          user_reaction = appshell.controller.take_data
          answer_data = build_answer_data(files_mode: :download_url)
          on_answer_confirmation(reaction: user_reaction) do
            interface.sys.text(text: "#{answer_data[:text]}\n\n#{build_attachments_list(answer_data[:attachments])}")
                     .send_to(tg_id, options_sender[:from_user])
          end
          appshell.authsession(:without_api) ? interface.sys.menu.after_auth.show : interface.sys.menu.starting.show
        end

        def find_entity_by(type, keyword = nil)
          keyword ||= keyword
          find_result =
            case type.to_sym
            when :course_sessions
              appshell.user.course_sessions_by(name: "%#{keyword}%", account_id: appshell.current_account.id)
                      .order(rating: :desc, name: :asc)
            end
          return interface.sys.text.on_empty.show if !find_result && find_result.empty?

          interface.cs.menu(title_params: { text: "#{Emoji.t(:mag_right)} \"#{keyword}\"" }, mode: :none,
                            back_button: { mode: :custom, action: router.cs(path: :list).link,
                                           button_sign: I18n.t('cs_list'), emoji: :books }).main(find_result).show
        end

        def match_data
          on router.main(path: :accounts).regexp do
            accounts
          end

          on router.main(path: :login).regexp do
            sign_in
          end

          on router.setting(path: :root).regexp do
            settings
          end

          on router.setting(path: :edit).regexp do
            settings_edit
          end

          on router.setting(path: :edit, p: %i[param]).regexp do
            setting_choose(c_data[1])
          end

          on router.setting(path: :localization, p: %i[param]).regexp do
            langugage_change(c_data[1])
          end

          on router.setting(path: :scenario, p: %i[param]).regexp do
            scenario_change(c_data[1])
          end

          on router.cs(path: :list).regexp do
            courses_states
          end

          on router.cs(path: :list, p: %i[param]).regexp do
            courses_list_by(c_data[1])
          end

          on router.cs(path: :list, p: %i[offset limit param]).regexp do
            courses_list_by(c_data[1], c_data[2], c_data[3])
          end

          on router.cs(path: :entity).regexp do
            sections_choose(c_data[1])
          end

          on router.cs(path: :sections, p: %i[param]).regexp do
            sections_by(c_data[1], c_data[2])
          end

          on router.section(path: :entity, p: %i[cs_id]).regexp do
            section_contents(c_data[1], c_data[2])
          end

          on router.section(path: :additions, p: %i[cs_id]).regexp do
            section_additions(c_data[1], c_data[2])
          end

          on router.content(path: :entity, p: %i[cs_id sec_id type]).regexp do
            content_by(c_data[1], c_data[2], c_data[3], c_data[4])
          end

          on router.content(path: :track_time, p: %i[time sec_id cs_id]).regexp do
            content_track_time(c_data[1], c_data[2], c_data[3], c_data[4])
          end

          on router.content(path: :take_answer, p: %i[answer_type cs_id]).regexp do
            content_take_answer(c_data[1], c_data[2], c_data[3])
          end

          on router.content(path: :confirm_answer, p: %i[param answer_type type sec_id cs_id]).regexp do
            answer_confirm(c_data[1], c_data[2], c_data[3], c_data[4], c_data[5], c_data[6])
          end

          on router.content(path: :answers, p: %i[cs_id]).regexp do
            task_answers(c_data[1], c_data[2])
          end

          on router.document(path: :entity).regexp do
            documents(c_data[1])
          end

          on router.main(path: :documents).regexp do
            documents
          end

          on router.main(path: :send_message, p: %i[u_id]).regexp do
            send_message_to(last_auth_session_by(c_data[1]).tg_account.id)
          end
        end

        def match_text_action
          on router.main(path: :start).regexp do
            starting
          end

          on router.main(path: :logout).regexp do
            closing
          end

          on router.setting(path: :root).regexp do
            settings
          end

          on router.cs(path: :entity).regexp do
            sections_choose(c_data[1])
          end

          on router.section(path: :entity, p: %i[cs_id]).regexp do
            section_contents(c_data[1], c_data[2])
          end

          on router.document(path: :entity).regexp do
            documents(c_data[1])
          end

          on router.user(path: :entity).regexp do
            profile(c_data[1])
          end
        end

        def match_ai_skill
          on %r{small_talks} do
            interface.sys.text.answer.text.send_out(@c_data)
          end

          on %r{bot-creator-info} do
            interface.sys.text.rare_message(I18n.t('creation_info').to_s).show
          end

          on %r{show} do
            if @c_data["course"]
              if @c_data["active"]
                courses_list_by(:active)
              elsif @c_data["archived"]
                courses_list_by(:archived)
              elsif @c_data["on"] && !@c_data["active"] && !@c_data["archived"]
                courses_states
              end
            end
          end

          on %r{find} do
            if @c_data["course"]
              if @c_data["education-name"]
                find_entity_by(:course_sessions, @c_data["education-name"].first["value"])
              else
                find_entity_by(:course_sessions)
              end
            else
              interface.sys.text.on_undefined.show
            end
          end

          on %r{to_human} do
            if @c_data["curator"]
              p "curator"
            elsif @c_data["techsupport"]
              send_message_to(TEACHSUPPORT_TG_ID)
            elsif @c_data["human"]
              p "human"
            end
          end

          interface.sys.text.on_undefined.show unless @c_data
        end

        protected

        def last_auth_session_by(user_id)
          Teachbase::Bot::AuthSession.where("user_id = ?", user_id.to_i).order(auth_at: :desc).first
        end

        def access_denied?(e)
          e.respond_to?(:http_code) && [401, 403].include?(e.http_code)
        end

        def on_answer_confirmation(params)
          params[:mode] ||= :last
          params[:type] ||= :reply_markup
          interface.destroy(delete_bot_message: params)
          params[:checker_mode] ||= :default
          if params[:reaction].to_sym == :accept
            result = check_status(params[:checker_mode]) { yield }
            appshell.clear_cached_answers if result
          else
            appshell.clear_cached_answers
            interface.sys.text.declined.show
          end
        end

        def build_attachments_list(attachments_array)
          return "" if attachments_array.empty?

          result = ["#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"]
          attachments_array.each_with_index do |attachment, ind|
            result << to_url_link(attachment[:file], "#{I18n.t('file').capitalize} #{ind + 1}").to_s
          end
          result.join("\n")
        end

        def build_back_button_data
          { mode: :basic, sent_messages: appshell.controller.tg_user.tg_account_messages }
        end

        def build_answer_data(params)
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

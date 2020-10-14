# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter

        DEFAULT_COUNT_PAGINAION = 10

        def starting
          interface.sys.text.about_bot
          interface.sys.menu.starting
        end

        def sign_in
          interface.sys.text(user_name: appshell.user_fullname,
                             account_name: appshell.account_name).on_enter
          auth = appshell.authorization
          raise unless auth

          interface.sys.text(user_name: appshell.user_fullname,
                             account_name: appshell.account_name).greetings
          courses_update
          interface.sys.menu.after_auth
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "Error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e)
          interface.sys.menu(text: title).sign_in_again
        end

        def sign_out
          interface.sys.text(user_name: appshell.user_fullname).farewell
          appshell.logout
          interface.sys.menu.starting
        rescue RuntimeError => e
          interface.sys.text.on_error(e)
        end

        alias closing sign_out

        def settings
          interface.sys.menu(scenario: appshell.settings.scenario,
                             localization: appshell.settings.localization).settings
        end

        def user_profile
          appshell.data_loader.user.profile.me
          user = appshell.user
          return interface.sys.text.on_empty unless user.profile && user

          interface.user(user).text.profile
        end

        def profile_links
          links = appshell.data_loader.user.profile.links
          return interface.sys.text.on_empty if links.empty?

          links.each do |link_param|
            interface.sys.text.link(link_param["url"], link_param["label"])
          end
        end

        alias more_actions profile_links

        def change_account
          appshell.logout_account
          sign_in
        end

        alias accounts change_account

        def settings_edit
          interface.sys.menu(back_button: build_back_button_data).edit_settings
        end

        def setting_choose(setting)
          interface.sys.menu(back_button: build_back_button_data).choosing("Setting", setting.to_sym)
        end

        def langugage_change(lang)
          raise "Lang param is empty" if lang.empty?

          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            interface.sys.text.on_save("localization", lang)
            interface.sys.menu.starting
          end
        end

        def scenario_change(mode)
          raise "Mode param is empty" if mode.empty?

          appshell.change_scenario(mode)
          interface.sys.text.on_save("scenario", mode)
          interface.sys.menu.starting
        end

        def check_status(mode = :silence)
          interface.sys.text.update_status(:in_progress)
          result = yield ? true : false

          if mode == :silence && result
            interface.sys.destroy(delete_bot_message: { mode: :last })
            return result
          end

          if result
            interface.sys.text.update_status(:success)
          else
            interface.sys.text.update_status(:fail)
          end
          interface.sys.destroy(delete_bot_message: { mode: :previous })
          result
        end

        def courses_states
          interface.cs.menu(text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>").states
        end

        alias cs_list courses_states

        def courses_list_by(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
          return courses_update if state.to_sym == :update

          interface.sys.destroy(delete_bot_message: { mode: :last, type: :reply_markup })
          offset = offset.to_i
          limit = limit.to_i
          course_sessions = appshell.data_loader.cs.list(state: state, category: appshell.settings.scenario)
          return interface.sys.text.on_empty if course_sessions.empty?

          interface.cs.menu(text: course_sessions.first.sign_course_state)
                   .main(course_sessions.limit(limit).offset(offset))
          offset += limit
          return if offset >= course_sessions.size

          interface.sys.menu(object_type: :cs, path: :list, all_count: course_sessions.size, param: state,
                             limit_count: limit, offset_num: offset).show_more
        end

        def courses_update
          check_status(:default) { appshell.data_loader.cs.update_all_states }
        end

        def sections_choose(cs_tb_id)
          sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          return interface.sys.text.on_empty if sections.empty?

          cs = sections.first.course_session
          interface.section(cs).menu(stages: %i[title],
                                     back_button: { mode: :custom,
                                                    action: router.cs(path: :list, p: [type: :states]).link })
                   .main
        rescue RuntimeError => e
          return interface.sys.text.on_empty if e.http_code == 404
        end

        def sections_by(option, cs_tb_id)
          option = option.to_sym
          all_sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          sections_by_option = find_sections_by(option, all_sections)
          return interface.sys.text.on_empty if all_sections.empty? || sections_by_option.empty?

          cs = sections_by_option.first.course_session
          interface.section(cs).menu(stages: %i[title menu],
                                     params: { state: "#{option}_sections" }).show_by_option(sections_by_option, option)
        end

        def section_contents(cs_tb_id, sec_pos)
          section_loader = appshell.data_loader.section(option: :position, value: sec_pos,
                                                        cs_tb_id: cs_tb_id)
          check_status do
            return interface.sys.text.on_empty unless section_loader.contents

            section_loader.progress
          end
          interface.section(section_loader.db_entity)
                   .menu(stages: %i[title], back_button: { mode: :custom,
                                                           action: router.cs(path: :entity, id: cs_tb_id).link })
                   .contents
        end

        def section_additions(cs_tb_id, sec_id)
          section_loader = appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
          return interface.sys.text.on_empty if section_loader.links.empty?

          interface.sys(section_loader.db_entity)
                   .menu(back_button: build_back_button_data, links: section_loader.links, stages: %i[title]).links
        end

        def content_by(type, sec_id, cs_tb_id, content_tb_id)
          entity = content_loader(type, cs_tb_id, sec_id, content_tb_id).me
          return interface.sys.text.on_empty unless entity

          options = default_open_content_options(type.to_sym)
          return interface.sys.text.on_error unless options

          options[:stages] = %i[title]
          interface.public_send(type, entity).menu(options).show
        rescue RuntimeError => e
          return interface.sys.text.on_forbidden if e.http_code == 401 || e.http_code == 403
        end

        def content_take_answer(cs_tb_id, answer_type, content_tb_id)
          content = appshell.user.task_by_cs_tbid(cs_tb_id, content_tb_id)
          return unless content

          interface.sys.text.ask_answer
          appshell.ask_answer(mode: :bulk, saving: :cache)
          interface.sys(content).menu(disable_web_page_preview: true, mode: :none,
                                      user_answer: appshell.user_cached_answer).confirm_answer(answer_type)
          interface.sys.menu.after_auth
        end

        def content_track_time(cs_tb_id, sec_id, time_spent, content_tb_id)
          section_loader = appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
          check_status(:default) do
            section_loader.content.material(tb_id: content_tb_id).track(time_spent)
          end
          interface.sys.text.ask_next_action
        end

        def answer_confirm(cs_tb_id, sec_id, type, answer_type, param, object_tb_id)
          on_answer_confirmation(reaction: param) { answer_submit(cs_tb_id, sec_id, object_tb_id, answer_type, type) }
          content_by(type, sec_id, cs_tb_id, object_tb_id)
        end

        def answer_submit(cs_tb_id, sec_id, object_tb_id, answer_type, type)
          raise "Can't submit answer" unless type.to_sym == :task

          content_loader(type, cs_tb_id, sec_id, object_tb_id)
            .submit(answer_type.to_sym => build_answer_data(files_mode: :upload))
        end

        def task_answers(cs_tb_id, task_tb_id)
          task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)
          return unless task

          interface.task(task).menu(back_button: build_back_button_data,
                                    stages: %i[title answers]).user_answers
        end

        def ready; end

        def send_message_to(tg_id)
          interface.sys.text.ask_answer
          appshell.ask_answer(mode: :bulk, saving: :cache)
          interface.sys.menu(disable_web_page_preview: true, mode: :none,
                             user_answer: appshell.user_cached_answer).confirm_answer(:message)
          user_reaction = appshell.controller.take_data
          answer_data = build_answer_data(files_mode: :download_url)
          on_answer_confirmation(reaction: user_reaction) do
            interface.sys.text(from: "#{appshell.user_fullname} (@#{appshell.controller.tg_user.username})",
                               text: "#{answer_data[:text]}\n\n#{build_attachments_list(answer_data[:attachments])}")
                     .to_tg_id(tg_id)
          end
          appshell.authsession(:without_api) ? interface.sys.menu.after_auth : interface.sys.menu.starting
        end

        def match_data
          on router.main(path: :login).regexp do
            sign_in
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

          on router.cs(path: :list, p: %i[type]).regexp do
            courses_states
          end

          on router.cs(path: :list, p: %i[param]).regexp do
            courses_list_by(c_data[1])
          end

          on router.cs(path: :list, p: %i[offset lim param]).regexp do
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
        end

        def match_ai_skill
          on %r{small_talks} do
            interface.sys.text.answer.text.send_out(@c_data)
          end

          on %r{courses} do
            if @c_data["active"]
              courses_list_by(:active)
            elsif @c_data["archived"]
              courses_list_by(:archived)
            elsif @c_data["on"] && !@c_data["active"] && !@c_data["archived"]
              courses_states
            end
          end

          on %r{to_human} do
            if @c_data["curator"]
              p "curator"
            elsif @c_data["techsupport"]
              send_message_to(876_403_528)
            elsif @c_data["human"]
              p "human"
            end
          end

          interface.sys.text.on_undefined_text unless @c_data
        end

        protected

        def access_denied?(e)
          e.respond_to?(:http_code) && (e.http_code == 401 || e.http_code == 403)
        end

        def content_loader(content_type, cs_tb_id, sec_id, content_tb_id)
          appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
                  .content.load_by(type: content_type, tb_id: content_tb_id)
        end

        def default_open_content_options(object_type)
          case object_type.to_sym
          when :material
            { mode: :edit_msg, approve_button: { time_spent: 25 } }
          when :task
            { mode: :edit_msg, show_answers_button: true, approve_button: true,
              disable_web_page_preview: true }
          when :quiz, :scorm_package
            { mode: :edit_msg, approve_button: true }
          end
        end

        def on_answer_confirmation(params)
          params[:mode] ||= :last
          params[:type] ||= :reply_markup
          interface.sys.destroy(delete_bot_message: params)
          params[:checker_mode] ||= :default
          if params[:reaction].to_sym == :accept
            result = check_status(params[:checker_mode]) { yield }
            appshell.clear_cached_answers if result
          else
            appshell.clear_cached_answers
            interface.sys.text.declined
          end
        end

        def build_attachments_list(attachments_array)
          return "" if attachments_array.empty?

          result = ["#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"]
          attachments_array.each_with_index do |attachment, ind|
            result << "#{to_url_link(attachment[:file], I18n.t('file').capitalize.to_s)} #{ind + 1}"
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

        def find_sections_by(option, sections)
          case option
          when :find_by_query_num
            interface.sys.text.ask_enter_the_number(:section)
            sections.where(position: appshell.request_data(:string).text)
          when :show_all
            sections
          when :show_avaliable
            sections.where(is_available: true, is_publish: true)
          when :show_unvaliable
            sections.where(is_available: false)
          else
            raise "No such option: '#{option}' for showing sections"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter

        DEFAULT_COUNT_PAGINAION = 10

        def starting
          interface.sys.text(user_name: appshell.user_fullname, account_name: appshell.account_name).greetings
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
        rescue RuntimeError => e
          title = if e.respond_to?(:http_code) && (e.http_code == 401 || e.http_code == 403)
                    "#{I18n.t('error')} #{e.to_s}\n#{I18n.t('try_again')}"
                  end
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

        def more_actions
          links = appshell.data_loader.user.profile.links
          return interface.sys.text.is_empty if links.empty?

          links.each do |link_param|
            interface.sys.text.link(link_param["url"], link_param["label"])
          end
        end

        def ready; end

        def edit_settings
          interface.sys.menu(back_button: build_back_button_data).edit_settings
        end

        def choose_localization
          interface.sys.menu(back_button: build_back_button_data).choosing("Setting", :localization)
        end

        def choose_scenario
          interface.sys.menu(back_button: build_back_button_data).choosing("Setting", :scenario)
        end

        def change_language(lang)
          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            interface.sys.text.on_save("localization", lang)
            interface.sys.menu.starting
          end
        end

        def change_scenario(mode)
          appshell.change_scenario(mode)
          interface.sys.text.on_save("scenario", mode)
          interface.sys.menu.starting
        end

        def check_status
          interface.sys.text.update_status(:in_progress)
          if yield
            interface.sys.text.update_status(:success)
            true
          else
            interface.sys.text.update_status(:fail)
            false
          end
        end

        def load_content(content_type, cs_tb_id, sec_id, content_tb_id)
          appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
                  .content.load_by(type: content_type, tb_id: content_tb_id)
        end

        def courses_list
          interface.cs.menu(text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>",
                            command_prefix: "courses_").states
        end

        def show_cs_list(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
          offset = offset.to_i
          limit = limit.to_i
          course_sessions = appshell.data_loader.cs.list(state: state, category: appshell.settings.scenario)
          return interface.sys.text.is_empty if course_sessions.empty?

          cs_count = course_sessions.size
          sign_by_state = course_sessions.first.sign_course_state
          interface.cs.menu(text: sign_by_state).main(course_sessions.limit(limit).offset(offset))
          offset += limit
          return if offset >= course_sessions.size

          interface.sys.menu(object_type: :course_sessions, all_count: course_sessions.size, state: state,
                             limit_count: limit, offset_num: offset).show_more
        end

        def courses_update
          check_status { appshell.data_loader.cs.update_all_states }
        end

        def track_material(cs_tb_id, sec_id, tb_id, time_spent)
          check_status do
            appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id).content
                    .material(tb_id: tb_id).track(time_spent)
          end
        end

        def open_section_content(type, cs_tb_id, sec_id, content_tb_id)
          object_type = Teachbase::Bot::Section::OBJECTS_TYPES[type.to_sym]
          entity = load_content(object_type, cs_tb_id, sec_id, content_tb_id).me
          return interface.sys.text.is_empty unless entity

          interface_controller = interface.public_send(object_type, entity)
          title = { stages: %i[contents title] }
          case object_type.to_sym
          when :material
            interface_controller.text(title).show
            interface_controller.menu(approve_button: true).actions
          when :task
            options = { mode: :edit_msg, show_answers_button: true, approve_button: true }.merge!(title)
            interface_controller.menu(options).show
          when :quiz
            interface_controller.menu(title).show
          when :scorm_package
            interface_controller.text(title).show
            interface_controller.menu.actions
          else
            interface.sys.text.on_error
          end
        end

        def show_section_additions(cs_tb_id, sec_id)
          links = appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id).links
          return interface.sys.text.is_empty if links.empty?

          interface.sys.menu(build_back_button_data.merge!(links: links)).links
        end

        def take_answer_task(cs_tb_id, task_tb_id)
          task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)
          return unless task

          interface.sys.text.ask_answer
          appshell.ask_answer(mode: :bulk, saving: :cache)
          interface.sys.menu.after_auth
          interface.sys(task).menu(disable_web_page_preview: true, mode: :none,
                                   user_answer: appshell.user_cached_answer).confirm_answer
        end

        def confirm_answer(cs_tb_id, sec_id, object_tb_id, type, param)
          if param.to_sym == :decline
            appshell.clear_cached_answers
            interface.sys.text.declined
          else
            result = check_status { submit_answer(cs_tb_id, sec_id, object_tb_id, type) }
            appshell.clear_cached_answers if result
          end
          interface.sys.menu(callback_data: "/sec#{sec_id}_cs#{cs_tb_id}").custom_back
        end

        def submit_answer(cs_tb_id, sec_id, object_tb_id, type)
          raise "Can't submit answer" unless type.to_sym == :task

          load_content(type, cs_tb_id, sec_id, object_tb_id).submit(build_answer_data)
        end

        def answers_task(cs_tb_id, task_tb_id)
          task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)
          return unless task

          interface.task(task).menu(stages: %i[contents title answers]).user_answers
        end

        def match_data
          on %r{sign_in} do
            sign_in
          end

          on %r{edit_settings} do
            edit_settings
          end

          on %r{^settings:localization} do
            choose_localization
          end

          on %r{^localization_param:} do
            @message_value =~ %r{^localization_param:(\w*)}
            change_language($1)
          end

          on %r{settings:scenario} do
            choose_scenario
          end

          on %r{^scenario_param:} do
            @message_value =~ %r{^scenario_param:(\w*)}
            mode = $1
            change_scenario(mode)
          end

          on %r{courses_list} do
            courses_list
          end

          on %r{courses_archived} do
            show_cs_list(:archived)
          end

          on %r{courses_active} do
            show_cs_list(:active)
          end

          on %r{show_course_sessions_list} do
            @message_value =~ %r{^show_course_sessions_list:(\w*)_lim:(\d*)_offset:(\d*)}
            show_cs_list($1, $2, $3)
          end

          on %r{^open_content:} do
            @message_value =~ %r{^open_content:(\w*)_by_csid:(\d*)_secid:(\d*)_objid:(\d*)}
            open_section_content($1, $2, $3, $4)
          end

          on %r{^show_section_additions_by_csid:} do
            @message_value =~ %r{^show_section_additions_by_csid:(\d*)_secid:(\d*)}
            show_section_additions($1, $2)
          end

          on %r{courses_update} do
            courses_update
          end
        end

        def match_text_action
          on %r{^/start} do
            starting
          end

          on %r{^/settings} do
            settings
          end

          on %r{^/close} do
            closing
          end
        end

        private

        def build_back_button_data
          { mode: :basic, sent_messages: appshell.controller.tg_user.tg_account_messages }
        end

        def build_answer_data
          { text: appshell.cached_answers_texts, attachments: appshell.cached_answers_files }
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

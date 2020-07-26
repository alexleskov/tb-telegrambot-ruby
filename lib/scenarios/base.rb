# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter

        def starting
          interface.sys.text(user_name: appshell.user_fullname, account_name: appshell.account_name).greetings
          interface.sys.menu.starting
        end

        def closing
          interface.sys.text(user_name: appshell.user_fullname).farewell
          interface.sys.menu.starting
        end

        def sign_in
          t_params = { user_name: appshell.user_fullname, account_name: appshell.account_name }
          interface.sys.text(t_params).on_enter
          auth = appshell.authorization
          raise unless auth

          interface.sys.text(t_params).greetings
          interface.sys.menu.after_auth
        rescue RuntimeError => e
          interface.sys.menu.sign_in_again
        end

        def sign_out
          interface.sys.text.on_farewell
          appshell.logout
          closing
        rescue RuntimeError => e
           interface.sys.text.on_error(e)
        end

        def settings
          interface.sys.menu(scenario: appshell.settings.scenario,
                             localization: appshell.settings.localization).settings
        end

        def edit_settings
          interface.sys.menu(back_button: build_back_button_data).edit_settings
        end

        #def ready; end

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
          type = Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym]
          raise unless type

          appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
                              .content.load_by(type: type, tb_id: content_tb_id)
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
          entity = load_content(type, cs_tb_id, sec_id, content_tb_id).me
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

# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base
        include Teachbase::Bot::Interfaces::StandartLearning

        DEFAULT_COUNT_PAGINAION = 4

        def show_profile_state
          data_loader.user.profile
          user = appshell.user
          return answer.text.empty_message unless user.profile && user

          print_user_profile(user)
        end

        def show_cs_list(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
          offset = offset.to_i
          limit = limit.to_i
          course_sessions = appshell.data_loader.cs.list(state: state, limit: limit, offset: offset,
                                                         scenario: appshell.settings.scenario)
          appshell.data_loader.user.profile
          cs_count = appshell.user.profile.cs_count_by(state)
          print_course_state(state)
          return answer.text.empty_message if course_sessions.empty?

          menu_courses_list(course_sessions, stages: %i[title])
          offset += limit
          return if offset >= cs_count

          answer.menu.show_more(object_type: :course_sessions, all_count: cs_count, state: state,
                                limit_count: limit, offset_num: offset)
        end

        def show_course_session_info(cs_tb_id)
          cs = appshell.data_loader.cs(tb_id: cs_tb_id).info
          print_course_stats_info(cs)
        end

        def sections_choosing_menu(cs_tb_id)
          sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          menu_choosing_section(sections, stages: %i[title sections],
                                          command_prefix: "show_sections_by_csid:#{cs_tb_id}_param:")
        end

        def show_sections(cs_tb_id, option)
          sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          sections_by_option = find_sections_by(option, sections)
          if sections.empty? || sections_by_option.empty?
            cs = appshell.data_loader.cs(tb_id: cs_tb_id).info
            title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
            return menu_empty_msg(text: title, back_button: { mode: :custom, action: cs.back_button_action },
                                  mode: :edit_msg)
          end

          menu_sections_by_option(sections_by_option, option)
        end

        def show_section_contents(section_position, cs_tb_id)
          section_loader = appshell.data_loader.section(option: :position, value: section_position, cs_tb_id: cs_tb_id)
          contents = section_loader.contents
          return answer.text.empty_message unless contents

          contents_by_types = section_loader.db_entity.contents_by_types
          appshell.data_loader.section(option: :position, value: section_position, cs_tb_id: cs_tb_id).progress
          title = create_title(object: section_loader.db_entity, stages: %i[title contents])
          menu_section_contents(contents: contents_by_types, text: title,
                                back_button: { mode: :custom, action: section_loader.db_entity
                                                                      .course_session.back_button_action })
        end

        def open_section_content(type, cs_tb_id, sec_id, content_tb_id)
          object_type = Teachbase::Bot::Section::OBJECTS_TYPES[type.to_sym]
          content = load_content(type, cs_tb_id, sec_id, content_tb_id).me
          return answer.text.empty_message unless content

          respond_to?("print_#{object_type}") ? public_send("print_#{object_type}", content) : answer.text.error
        end

        def take_answer_task(cs_tb_id, task_tb_id)
          task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)

          return unless task

          answer.text.ask_answer
          appshell.ask_answer(mode: :bulk, saving: :cache)
          answer.menu.after_auth
          menu_confirm_answer(object: task, disable_web_page_preview: true, mode: :none,
                              user_answer: appshell.user_cached_answer)
        end

        def answers_task(cs_tb_id, task_tb_id)
          task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)
          return unless task

          print_answers(task)
        end

        def confirm_answer(cs_tb_id, sec_id, object_tb_id, type, param)
          pre_submit_answer(cs_tb_id, sec_id, object_tb_id, type, param)
          answer.menu.custom_back(callback_data: "/sec#{sec_id}_cs#{cs_tb_id}")
        end

        def courses_list
          menu_choosing_course_state
        end

        def match_data
          on %r{signin} do
            signin
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

          on %r{courses_update} do
            courses_update
          end

          on %r{^cs_info_id:} do
            @message_value =~ %r{^cs_info_id:(\d*)}
            show_course_session_info($1)
          end

          on %r{^cs_sec_by_id:} do
            @message_value =~ %r{^cs_sec_by_id:(\d*)}
            sections_choosing_menu($1)
          end

          on %r{^show_sections_by_csid:} do
            @message_value =~ %r{^show_sections_by_csid:(\d*)_param:(\w*)}
            show_sections($1, $2.to_sym)
          end

          on %r{^open_content:} do
            @message_value =~ %r{^open_content:(\w*)_by_csid:(\d*)_secid:(\d*)_objid:(\d*)}
            open_section_content($1, $2, $3, $4)
          end

          on %r{^/sec(\d*)_cs(\d*)} do
            @message_value =~ %r{^/sec(\d*)_cs(\d*)}
            show_section_contents($1, $2)
          end

          on %r{^approve_material_by_csid:} do
            @message_value =~ %r{^approve_material_by_csid:(\d*)_secid:(\d*)_objid:(\d*)_time:(\d*)}
            track_material($1, $2, $3, $4)
          end

          on %r{submit_task_by_csid:} do
            @message_value =~ %r{submit_task_by_csid:(\d*)_objid:(\d*)}
            take_answer_task($1, $2)
          end

          on %r{answers_task_by_csid:} do
            @message_value =~ %r{answers_task_by_csid:(\d*)_objid:(\d*)}
            answers_task($1, $2)
          end

          on %r{confirm_csid:} do
            @message_value =~ %r{^confirm_csid:(\d*)_secid:(\d*)_objid:(\d*)_t:(\w*)_p:(\w*)}
            confirm_answer($1, $2, $3, $4, $5)
          end
        end

        def match_text_action
          on %r{^/sec(\d*)_cs(\d*)} do
            @message_value =~ %r{^/sec(\d*)_cs(\d*)}
            show_section_contents($1, $2)
          end

          on %r{^/start} do
            answer.text.greeting_message(appshell.user_fullname(:string))
            answer.menu.starting
          end

          on %r{^/settings} do
            settings
          end

          on %r{^/close} do
            print_farewell
          end
        end

        private

        def find_sections_by(option, sections)
          case option
          when :find_by_query_num
            ask_enter_the_number(:section)
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

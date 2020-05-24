# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base
        include Teachbase::Bot::Interfaces::StandartLearning

        DEFAULT_COUNT_PAGINAION = 4

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def show_profile_state
          appshell.user_info
          user = appshell.user
          return answer.text.empty_message unless user.profile && user

          print_user_profile(user)
        end

        def show_course_sessions_list(state, limit_count = DEFAULT_COUNT_PAGINAION, offset_num = 0)
          offset_num = offset_num.to_i
          limit_count = limit_count.to_i
          course_sessions = appshell.course_sessions_list(state, limit_count, offset_num)
          cs_count = appshell.cs_count_by(state)
          print_course_state(state)
          return answer.text.empty_message if course_sessions.empty?

          menu_courses_list(course_sessions, stages: %i[title])
          offset_num += limit_count
          return if offset_num >= cs_count

          answer.menu.show_more(:course_sessions, all_count: cs_count, state: state, limit_count: limit_count,
                                                  offset_num: offset_num)
        end

        def show_course_session_info(cs_tb_id)
          cs = appshell.course_session_info(cs_tb_id)
          print_course_stats_info(cs)
        end

        def sections_choosing_menu(cs_tb_id)
          sections = appshell.course_session_sections(cs_tb_id)
          menu_choosing_section(sections, stages: %i[title sections],
                                          command_prefix: "show_sections_by_csid:#{cs_tb_id}_param:")
        end

        def show_sections(cs_tb_id, option)
          sections = appshell.course_session_sections(cs_tb_id)
          sections_by_option = find_sections_by(option, sections)

          if sections.empty? || sections_by_option.empty?
            cs = appshell.course_session_info(cs_tb_id)
            title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
            return menu_empty_msg(text: title, buttons: create_sections_back_button(cs_tb_id), mode: :edit_msg)
          end

          menu_sections_by_option(sections_by_option, option)
        end

        def show_section_contents(section_position, cs_tb_id)
          section = appshell.course_session_section(:position, section_position, cs_tb_id)
          contents = appshell.course_session_section_contents(section_position, cs_tb_id)
          return answer.text.empty_message unless contents

          appshell.course_session_update_progress(cs_tb_id)
          title = create_title(object: section, stages: %i[title contents])
          menu_section_contents(section, contents, text: title)
        end

        def open_section_content(type, cs_tb_id, sec_id, content_tb_id)
          object_type = Teachbase::Bot::Section::OBJECTS_TYPES[type.to_sym]
          content = appshell.course_session_section_content(type, cs_tb_id, sec_id, content_tb_id)
          return answer.text.empty_message unless content
          
          print_content_title(content)
          respond_to?("print_#{object_type}") ? public_send("print_#{object_type}", content) : answer.text.error
        end

        def courses_update
          check_status { appshell.update_all_course_sessions }
        end

        def track_material(cs_tb_id, material_tb_id, time_spent)
          check_status { appshell.track_material(cs_tb_id, material_tb_id, time_spent) }
        end

        def submit_answer_task(cs_tb_id, task_tb_id)
          task = appshell.course_session_task(cs_tb_id, task_tb_id)
          return unless task

          menu_confirm_answer(task)
        end

        def confirm_answer(cs_tb_id, object_tb_id, type, param)
          if param.to_sym == :decline
            return answer.menu.declined(back_button: :back)
          end

          user_answer = appshell.ask_answer
          return answer.text.error unless user_answer

          check_status { appshell.submit_answer(cs_tb_id, object_tb_id, type, user_answer) }
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
            show_course_sessions_list(:archived)
          end

          on %r{courses_active} do
            show_course_sessions_list(:active)
          end

          on %r{show_course_sessions_list} do
            @message_value =~ %r{^show_course_sessions_list:(\w*)_lim:(\d*)_offset:(\d*)}
            show_course_sessions_list($1, $2, $3)
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
            @message_value =~ %r{^approve_material_by_csid:(\d*)_objid:(\d*)_time:(\d*)}
            track_material($1, $2, $3)
          end

          on %r{submit_tasks_by_csid:} do
            @message_value =~ %r{submit_tasks_by_csid:(\d*)_objid:(\d*)}
            submit_answer_task($1, $2)
          end

          on %r{confirm_csid:} do
            @message_value =~ %r{^confirm_csid:(\d*)_objid:(\d*)_t:(\w*)_p:(\w*)}
            confirm_answer($1, $2, $3, $4)
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
            sections.where(position: appshell.request_data(:string))
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

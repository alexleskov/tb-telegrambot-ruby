module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base
        include Teachbase::Bot::Viewers::StandartLearning

        LIMIT_COUNT_PAGINAION = 4

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def show_profile_state
          appshell.user_info
          profile = appshell.profile
          user = appshell.user
          return answer.empty_message unless profile && user

          print_user_profile(user, profile)
        end

        def show_course_sessions_list(state, limit_count = LIMIT_COUNT_PAGINAION, offset_num = 0)
          offset_num = offset_num.to_i
          limit_count = limit_count.to_i
          course_sessions = appshell.course_sessions_list(state, limit_count, offset_num)
          сs_count = appshell.cs_count_by(state) 
          print_course_state(state)
          return answer.empty_message if course_sessions.empty?
          
          print_courses_list(course_sessions, breadcrumbs: :course, level: [:name])
          offset_num += limit_count
          unless offset_num >= сs_count
            menu.show_more(:course_sessions, all_count: сs_count, state: state, limit_count: limit_count,
                           offset_num: offset_num)
          end
        end

        def show_course_session_info(cs_tb_id)
          cs = appshell.course_session_info(cs_tb_id)
          text = print_course_stats(cs, breadcrumbs: :course, level: [:name, :info])
          menu.back(text)
        end

        def sections_choosing_menu(cs_tb_id)
          sections = appshell.course_session_sections(cs_tb_id)
          cs = sections.first.course_session
          if sections.empty?
            print_is_empty_by(cs, breadcrumbs: :course, level: [:name, :contents])
          else
            menu_choosing_section(sections, breadcrumbs: :course, level: [:name, :contents, :sections],
                                            command_prefix: "show_sections_by_csid:#{cs_tb_id}_param:")
          end
        end

        def show_sections(cs_tb_id, option)
          sections_bd = appshell.course_session_sections(cs_tb_id, :without_api)
          cs = sections_bd.first.course_session
          return answer.empty_message if sections_bd.empty?

          sections = find_sections_by(option, sections_bd)
          title = prepare_title(object: cs,
                                breadcrumbs: :section, level: [:section_menu], menu_option: option)

          if sections.empty?
            menu.create(buttons: prepare_sections_button(cs_tb_id, :arrow_left),
                        text: "#{title}\n\n#{create_empty_msg}",
                        type: :menu_inline)            
          else
            menu_mode = option == :find_by_query_num ? :none : :edit_msg
            menu.back("#{title}
                       #{print_sections_by_status(sections, cs_tb_id)}",
                       menu_mode)
          end
        end

        def show_section_contents(section_position, cs_tb_id)
          contents = appshell.course_session_section_contents(section_position, cs_tb_id)
          cs = appshell.course_session_info(cs_tb_id, :without_api)
          back_to_course_button = prepare_sections_button(cs_tb_id, :arrow_left)
          return answer.empty_message unless contents

          menu.create(buttons: prepare_content_buttons(contents, cs_tb_id) + back_to_course_button,
                      mode: :none,
                      type: :menu_inline,
                      text: prepare_title(object: cs,
                                          breadcrumbs: :section,
                                          level: [:section],
                                          section: contents[:section]))
        end

        def open_section_content(content_type, cs_tb_id, sec_id, content_tb_id)
          content = appshell.course_session_section_content(content_type, cs_tb_id, sec_id, content_tb_id)
          return answer.empty_message unless content

          find_content_type(content)
        end

        def courses_update
          print_update_status(:in_progress)
          course_update = appshell.update_all_course_sessions
          course_update ? print_update_status(:success) : print_update_status(:fail)
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
        end

        def match_text_action
          on %r{^/sec(\d*)_cs(\d*)} do
            @message_value =~ %r{^/sec(\d*)_cs(\d*)}
            show_section_contents($1, $2)
          end

          on %r{^/start} do
            answer.greeting_message
            menu.starting
          end

          on %r{^/settings} do
            settings
          end

          on %r{^/close} do
            menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('farewell_message')} :'(")
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

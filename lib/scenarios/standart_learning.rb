# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base

        DEFAULT_COUNT_PAGINAION = 4

        def show_profile_state
          appshell.data_loader.user.profile
          user = appshell.user
          return interface.sys.text.is_empty unless user.profile && user

          interface.user(user).text.profile
        end

        def show_cs_list(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
          offset = offset.to_i
          limit = limit.to_i
          course_sessions = appshell.data_loader.cs.list(state: state, limit: limit, offset: offset,
                                                         scenario: appshell.settings.scenario)
          appshell.data_loader.user.profile
          cs_count = appshell.user.profile.cs_count_by(state)
          interface.cs.text.state(state)
          return interface.sys.text.is_empty if course_sessions.empty?

          course_sessions.each do |cs|
            interface.cs(cs).menu(stages: %i[title], callback_data: ["cs_sec_by_id:#{cs.tb_id}",
                                                                     "cs_info_id:#{cs.tb_id}"]).main
          end
          offset += limit
          return if offset >= cs_count

          interface.sys.menu(object_type: :course_sessions, all_count: cs_count, state: state,
                             limit_count: limit, offset_num: offset).show_more
        end

        def show_course_session_info(cs_tb_id)
          cs = appshell.data_loader.cs(tb_id: cs_tb_id).info
          interface.cs(cs).menu(stages: %i[title info]).stats_info
        end

        def sections_choosing_menu(cs_tb_id)
          sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          return interface.sys.text.is_empty if sections.empty?

          cs = sections.first.course_session
          interface.section(cs).menu(stages: %i[title sections],
                                     command_prefix: "show_sections_by_csid:#{cs.tb_id}_param:",
                                     back_button: build_back_button_data).main
        end

        def show_sections(cs_tb_id, option)
          all_sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          sections_by_option = find_sections_by(option, all_sections)
          return interface.sys.text.is_empty if all_sections.empty? || sections_by_option.empty?

          cs = sections_by_option.first.course_session
          interface.section(cs).menu(stages: %i[title sections menu],
                                     params: { state: option }).show_by_option(sections_by_option, option)
        end

        def show_section_contents(section_position, cs_tb_id)
          section_loader = appshell.data_loader.section(option: :position, value: section_position,
                                                        cs_tb_id: cs_tb_id)
          return interface.sys.text.is_empty unless section_loader.contents

          appshell.data_loader.section(option: :position, value: section_position, cs_tb_id: cs_tb_id).progress
          section = section_loader.db_entity
          interface.section(section)
                   .menu(stages: %i[title contents], back_button: { mode: :custom,
                                                                    action: section.course_session.back_button_action })
                   .contents
        end

        def courses_list
          interface.cs.menu(text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>",
                            command_prefix: "courses_").states
        end

        def match_data
          super

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
          super 

          on %r{^/sec(\d*)_cs(\d*)} do
            @message_value =~ %r{^/sec(\d*)_cs(\d*)}
            show_section_contents($1, $2)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base

        def show_profile_state
          appshell.data_loader.user.profile.me
          user = appshell.user
          return interface.sys.text.is_empty unless user.profile && user

          interface.user(user).text.profile
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
                                     back_button: { mode: :custom, action: "courses_list" }).main
        end

        def show_sections(cs_tb_id, option)
          all_sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          sections_by_option = find_sections_by(option, all_sections)
          return interface.sys.text.is_empty if all_sections.empty? || sections_by_option.empty?

          cs = sections_by_option.first.course_session
          interface.section(cs).menu(stages: %i[title sections menu],
                                     params: { state: option }).show_by_option(sections_by_option, option)
        end

        def show_section_contents(sec_id, cs_tb_id)
          section_loader = appshell.data_loader.section(option: :id, value: sec_id,
                                                        cs_tb_id: cs_tb_id)
          check_status do
            return interface.sys.text.is_empty unless section_loader.contents

            section_loader.progress
          end
          section = section_loader.db_entity
          interface.section(section)
                   .menu(stages: %i[title contents], back_button: { mode: :custom,
                                                                    action: section.course_session.back_button_action })
                   .contents
        end

        def match_data
          super

          on %r{^cs_info_id:} do
            @message_value =~ %r{^cs_info_id:(\d*)}
            show_course_session_info($1)
          end

          on %r{^/cs_sec_id} do
            @message_value =~ %r{^/cs_sec_id(\d*)}
            sections_choosing_menu($1)
          end

          on %r{^show_sections_by_csid:} do
            @message_value =~ %r{^show_sections_by_csid:(\d*)_param:(\w*)}
            show_sections($1, $2.to_sym)
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

          on %r{^/cs_sec_id} do
            @message_value =~ %r{^/cs_sec_id(\d*)}
            sections_choosing_menu($1)
          end

          on %r{^/sec(\d*)_cs(\d*)} do
            @message_value =~ %r{^/sec(\d*)_cs(\d*)}
            show_section_contents($1, $2)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base

        def show_profile_state
          appshell.data_loader.user.profile.me
          user = appshell.user
          return interface.sys.text.on_empty unless user.profile && user

          interface.user(user).text.profile
        end

        def sections_choosing_menu(cs_tb_id)
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

        def show_sections(option, cs_tb_id)
          option = option.to_sym
          all_sections = appshell.data_loader.cs(tb_id: cs_tb_id).sections
          sections_by_option = find_sections_by(option, all_sections)
          return interface.sys.text.on_empty if all_sections.empty? || sections_by_option.empty?

          cs = sections_by_option.first.course_session
          interface.section(cs).menu(stages: %i[title menu],
                                     params: { state: "#{option}_sections" }).show_by_option(sections_by_option, option)
        end

        def show_section_contents(cs_tb_id, sec_pos)
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

        def match_data
          super

          on router.cs(path: :entity).regexp do
            @message_value =~ router.cs(path: :entity).regexp
            sections_choosing_menu($1)
          end

          on router.cs(path: :sections, p: [:param]).regexp do
            @message_value =~ router.cs(path: :sections, p: [:param]).regexp
            show_sections($1, $2)
          end

          on router.section(path: :entity, p: [:cs_id]).regexp do
            @message_value =~ router.section(path: :entity, p: [:cs_id]).regexp
            show_section_contents($1, $2)
          end
        end

        def match_text_action
          super

          on router.cs(path: :entity).regexp do
            @message_value =~ router.cs(path: :entity).regexp
            sections_choosing_menu($1)
          end

          on router.section(path: :entity, p: [:cs_id]).regexp do
            @message_value =~ router.section(path: :entity, p: [:cs_id]).regexp
            show_section_contents($1, $2)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Content
          def content_by(type, sec_id, cs_tb_id, content_tb_id)
            entity = content_loader(type, cs_tb_id, sec_id, content_tb_id).me
            return interface.sys.text.on_empty.show unless entity

            options = default_open_content_options(type.to_sym)
            return interface.sys.text.on_error.show unless options

            options[:mode] = :edit_msg
            options[:title_params] = { stages: %i[title] }
            options[:back_button] = { mode: :custom, action: router.section(path: :entity, position: entity.section.position,
                                                                            p: [cs_id: cs_tb_id]).link }
            interface.public_send(type, entity).menu(options).content.show
          rescue RuntimeError, TeachbaseBotException => e
            return interface.sys.text.on_forbidden.show if e.respond_to?(:http_code) && (401..403).include?(e.http_code)
          end

          def content_take_answer(cs_tb_id, answer_type, content_tb_id)
            content = appshell.user.task_by_cs_tbid(cs_tb_id, content_tb_id)
            return unless content

            interface.sys.text.ask_answer.show
            appshell.ask_answer(mode: :bulk, saving: :cache)
            interface.sys(content).menu(disable_web_page_preview: true, mode: :none)
                     .confirm_answer(answer_type, appshell.user_cached_answer).show
            interface.sys.menu.after_auth.show
          end

          def content_track_time(cs_tb_id, sec_id, time_spent, content_tb_id)
            section_loader = appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
            check_status(:default) do
              section_loader.content.material(tb_id: content_tb_id).track(time_spent)
            end
            interface.sys.text.ask_next_action.show
          end

          def answer_confirm(cs_tb_id, sec_id, type, answer_type, param, object_tb_id)
            on_answer_confirmation(reaction: param) do
              answer_submit(cs_tb_id, sec_id, object_tb_id, answer_type, type)
            end
            content_by(type, sec_id, cs_tb_id, object_tb_id)
          end

          def answer_submit(cs_tb_id, sec_id, object_tb_id, answer_type, type)
            raise "Can't submit answer" unless type.to_sym == :task

            content_loader(type, cs_tb_id, sec_id, object_tb_id).submit(answer_type.to_sym => build_answer_data(files_mode: :upload))
          end

          def task_answers(cs_tb_id, task_tb_id)
            task = appshell.user.task_by_cs_tbid(cs_tb_id, task_tb_id)
            return unless task

            interface.task(task).menu(back_button: build_back_button_data,
                                      title_params: { stages: %i[title answers] }).user_answers.show
          end

          protected

          def content_loader(content_type, cs_tb_id, sec_id, content_tb_id)
            appshell.data_loader.section(option: :id, value: sec_id, cs_tb_id: cs_tb_id)
                    .content.load_by(type: content_type, tb_id: content_tb_id)
          end

          def default_open_content_options(object_type)
            menu_options = {}

            case object_type.to_sym
            when :material
              menu_options[:approve_button] = { time_spent: 25 }
            when :task
              menu_options[:show_answers_button] = true
              menu_options[:approve_button] = true
              menu_options[:disable_web_page_preview] = true
            when :quiz, :scorm_package
              menu_options[:approve_button] = true
            end
            menu_options
          end
        end
      end
    end
  end
end

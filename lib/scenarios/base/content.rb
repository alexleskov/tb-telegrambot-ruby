# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Content
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

          protected

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
        end
      end
    end
  end
end

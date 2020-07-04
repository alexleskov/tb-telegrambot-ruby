# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter
        include Teachbase::Bot::Interfaces::Base

        def signin(account_name = "teachbase")
          print_on_enter(account_name)
          auth = appshell.authorization
          raise unless auth

          print_greetings(account_name)
          answer.menu.after_auth
        rescue RuntimeError => e
          answer.menu.sign_in_again
        end

        def sign_out
          print_on_farewell
          appshell.logout
          print_farewell
          answer.menu.starting
        rescue RuntimeError => e
          answer.text.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          answer.menu.settings
        end

        def edit_settings
          answer.menu.edit_settings
        end

        def ready; end

        def choose_localization
          answer.menu.choosing("Setting", :localization)
        end

        def choose_scenario
          answer.menu.choosing("Setting", :scenario)
        end

        def change_language(lang)
          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            print_on_save("localization", lang)
            answer.menu.starting
          end
        end

        def change_scenario(mode)
          appshell.change_scenario(mode)
          print_on_save("scenario", mode)
        end

        def check_status
          print_update_status(:in_progress)
          if yield
            print_update_status(:success)
            true
          else
            print_update_status(:fail)
            false
          end
        end

        def submit_answer(cs_tb_id, sec_id, object_tb_id, type)
          raise "Can't submit answer" unless type.to_sym == :task

          load_content(type, cs_tb_id, sec_id, object_tb_id).submit(build_answer_data)
        end

        def pre_submit_answer(cs_tb_id, sec_id, object_tb_id, type, param)
          if param.to_sym == :decline
            appshell.clear_cached_answers
            answer.text.declined
          else
            result = check_status { submit_answer(cs_tb_id, sec_id, object_tb_id, type) }
            appshell.clear_cached_answers if result
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

        private

        def build_answer_data
          { text: appshell.cached_answers_texts, attachments: appshell.cached_answers_files }
        end
      end
    end
  end
end

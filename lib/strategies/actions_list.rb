# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      module ActionsList
        def do_action
          return if push_command
          return if push_file

          controller.on router.main(path: :start).regexp do
            starting
          end

          controller.on router.main(path: :logout).regexp do
            closing
          end

          controller.on router.setting(path: :root).regexp do
            setting.list
          end

          controller.on router.cs(path: :entity).regexp do
            section.choosing(data[1])
          end

          controller.on router.section(path: :entity, p: %i[cs_id]).regexp do
            section.contents(data[1], data[2])
          end

          controller.on router.document(path: :entity).regexp do
            document.list_by(data[1])
          end

          controller.on router.user(path: :entity).regexp do
            profile.me(data[1])
          end

          controller.on router.main(path: :find, p: %i[type]).regexp do
            find.public_send(data[1])
          end

          controller.on router.main(path: :accounts).regexp do
            accounts
          end

          controller.on router.main(path: :login).regexp do
            sign_in
          end

          controller.on router.main(path: :help).regexp do
            help
          end

          controller.on router.main(path: :password, p: %i[param]).regexp do
            reset_password if data[1].to_sym == :reset
          end

          controller.on router.setting(path: :edit).regexp do
            setting.edit
          end

          controller.on router.setting(path: :edit, p: %i[param]).regexp do
            setting.choose_one(data[1])
          end

          controller.on router.setting(path: :localization, p: %i[param]).regexp do
            setting.langugage_change(data[1])
          end

          controller.on router.setting(path: :scenario, p: %i[param]).regexp do
            setting.scenario_change(data[1])
          end

          controller.on router.cs(path: :list).regexp do
            cs.states
          end

          controller.on router.cs(path: :list, p: %i[param]).regexp do
            cs.list_by(data[1])
          end

          controller.on router.cs(path: :list, p: %i[offset limit param]).regexp do
            cs.list_by(data[1], data[2], data[3])
          end

          controller.on router.cs(path: :sections, p: %i[param]).regexp do
            section.list_by(data[1], data[2])
          end

          controller.on router.section(path: :additions, p: %i[cs_id]).regexp do
            section.additions(data[1], data[2])
          end

          controller.on router.content(path: :entity, p: %i[cs_id sec_id type]).regexp do
            content.open_by(data[1], data[2], data[3], data[4])
          end

          controller.on router.content(path: :track_time, p: %i[time sec_id cs_id]).regexp do
            content.track_time(data[1], data[2], data[3], data[4])
          end

          controller.on router.content(path: :take_answer, p: %i[answer_type cs_id]).regexp do
            content.take_user_answer(data[1], data[2], data[3])
          end

          controller.on router.content(path: :confirm_answer, p: %i[param answer_type type sec_id cs_id]).regexp do
            content.confirm_user_answer(data[1], data[2], data[3], data[4], data[5], data[6])
          end

          controller.on router.content(path: :answers, p: %i[cs_id]).regexp do
            content.answers(data[1], data[2])
          end

          controller.on router.main(path: :documents).regexp do
            document.list_by
          end

          controller.on router.main(path: :send_message, p: %i[u_id]).regexp do
            tg_account_id = Teachbase::Bot::User.last_tg_account(data[1]).select(:tg_account_id).pluck(:tg_account_id).first
            raise unless tg_account_id

            notify.send_to(tg_account_id)
          end

          controller.on %r{^/ai:small_talks} do
            interface.sys.text.rare_message(data).show
          end

          controller.on %r{^/ai:bot-creator-info} do
            interface.sys.text.rare_message(I18n.t('creation_info').to_s).show
          end

          controller.on %r{^/ai:show} do
            if data["course"]
              if data["active"]
                cs.list_by(:active)
              elsif data["archived"]
                cs.list_by(:archived)
              elsif data["on"] && !data["active"] && !data["archived"]
                cs.states
              else
                interface.sys.text.on_undefined.show
              end
            end
          end

          controller.on %r{^/ai:find} do
            if data["course"]
              if data["education-name"]
                find(keyword: data["education-name"].first["value"]).cs
              else
                find.cs
              end
            else
              interface.sys.text.on_undefined.show
            end
          end

          controller.on %r{^/ai:to_human} do
            notification_sender = notify(from_user: appshell.user(:without_api))
            if data["curator"]
              notification_sender.to_curator
            elsif data["techsupport"]
              notification_sender.to_support
            elsif data["human"]
              interface.sys.text.on_undefined_action.show
            end
          end

          controller.on %r{^/webhook:created} do
            case data
            when Teachbase::Bot::Webhook::CourseStat
              notify(type: :cs).about(data.cs_tb_id)
            end
          end

          return push_ai if respond_by_ai?
        end

        private

        def push_command
          return unless controller.is_a?(Teachbase::Bot::CommandController)

          controller.find_command
          public_send(data)
        end

        def push_ai
          return unless controller.is_a?(Teachbase::Bot::TextController)

          ai_controller = controller.respond.ai
          controller.respond.msg_responder.strategy.new(ai_controller).do_action
          interface.sys.text.on_undefined.show unless ai_controller.action
        end

        def push_file
          return unless controller.is_a?(Teachbase::Bot::FileController)

          interface.sys.text.on_undefined_file.show
        end

        def data
          controller.c_data
        end

        def respond_by_ai?
          controller.ai_mode && !controller.action_result && !controller.is_a?(Teachbase::Bot::AIController)
        end
      end
    end
  end
end

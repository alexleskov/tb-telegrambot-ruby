# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      module ActionsList
        def do_action
          return if push_command
          return if push_file

          controller.on router.g(:main, :admin).regexp do
            administration
          end

          controller.on router.g(:admin, :root, p: %i[acc_id type]).regexp do
            admin.update_account(data[1], data[2])
          end

          controller.on router.g(:admin, :root, p: %i[acc_id param]).regexp do
            admin.update_account_setting(data[1], data[2])
          end

          controller.on router.g(:admin, :new_account).regexp do
            admin.add_new_account
          end          

          controller.on router.g(:main, :start).regexp do
            starting
          end

          controller.on router.g(:main, :logout).regexp do
            closing
          end

          controller.on router.g(:setting, :list).regexp do
            setting.list
          end

          controller.on router.g(:cs, :root).regexp do
            section.choosing(data[1])
          end

          controller.on router.g(:section, :root, p: %i[cs_id]).regexp do
            section.contents(data[1], data[2])
          end

          controller.on router.g(:document, :root).regexp do
            mode = controller.is_a?(Teachbase::Bot::TextController) ? :none : :edit_msg
            document.list_by(data[1], mode)
          end

          controller.on router.g(:user, :root).regexp do
            profile.me(data[1])
          end

          controller.on router.g(:main, :find, p: %i[type]).regexp do
            find(what: data[1].to_sym).go
          end

          controller.on router.g(:main, :accounts).regexp do
            accounts
          end

          controller.on router.g(:main, :login).regexp do
            sign_in
          end

          controller.on router.g(:main, :help).regexp do
            help
          end

          controller.on router.g(:main, :password, p: %i[param]).regexp do
            reset_password if data[1].to_sym == :reset
          end

          controller.on router.g(:setting, :edit).regexp do
            setting.edit
          end

          controller.on router.g(:setting, :edit, p: %i[param]).regexp do
            setting.choose_one(data[1])
          end

          controller.on router.g(:setting, :localization, p: %i[param]).regexp do
            setting.langugage_change(data[1])
          end

          controller.on router.g(:setting, :scenario, p: %i[param]).regexp do
            setting.scenario_change(data[1])
          end

          controller.on router.g(:cs, :list).regexp do
            cs.states
          end

          controller.on router.g(:cs, :list, p: %i[param]).regexp do
            cs.list_by(data[1])
          end

          controller.on router.g(:cs, :list, p: %i[param limit offset]).regexp do
            cs.list_by(data[1], data[2], data[3])
          end

          controller.on router.g(:cs, :sections, p: %i[param]).regexp do
            section.list_by(data[1], data[2])
          end

          controller.on router.g(:section, :additions, p: %i[cs_id]).regexp do
            section.additions(data[1], data[2])
          end

          controller.on router.g(:content, :root, p: %i[cs_id sec_id type]).regexp do
            content.open_by(data[1], data[2], data[3], data[4])
          end

          controller.on router.g(:content, :track_time, p: %i[cs_id sec_id time]).regexp do
            content.track_time(data[1], data[2], data[3], data[4])
          end

          controller.on router.g(:content, :take_answer, p: %i[cs_id answer_type]).regexp do
            content.take_user_answer(data[1], data[2], data[3])
          end

          controller.on router.g(:content, :confirm_answer, p: %i[cs_id sec_id type answer_type param]).regexp do
            content.confirm_user_answer(data[1], data[2], data[3], data[4], data[5], data[6])
          end

          controller.on router.g(:content, :answers, p: %i[cs_id]).regexp do
            content.answers(data[1], data[2])
          end

          controller.on router.g(:main, :documents).regexp do
            document.list_by
          end

          controller.on router.g(:main, :send_message, p: %i[u_id]).regexp do
            tg_account_id = Teachbase::Bot::User.last_tg_account(data[1]).select(:tg_account_id).pluck(:tg_account_id).first
            raise unless tg_account_id

            notify.send_to(tg_account_id)
          end

          controller.on %r{^/ai:small_talks} do
            interface.sys.text(text: data).show
          end

          controller.on %r{^/ai:bot-creator-info} do
            interface.sys.text(text: I18n.t('creation_info')).show
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
                interface.sys.text.on_undefined_action.show
              end
            end
          end

          controller.on %r{^/ai:find} do
            if data["course"]
              if data["education-name"]
                find(keyword: data["education-name"].first["value"], what: :cs).go
              else
                find(what: :cs).go
              end
            else
              interface.sys.text.on_undefined_action.show
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
          controller.context.strategy_class.new(ai_controller).do_action
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
          controller.context.ai_mode && !controller.action_result && !controller.is_a?(Teachbase::Bot::AIController)
        end
      end
    end
  end
end

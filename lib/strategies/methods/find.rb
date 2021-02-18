# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Find < Teachbase::Bot::Strategies
        attr_reader :keyword, :result, :what

        def initialize(controller, options)
          super(controller)
          @keyword = options[:keyword] || take_keyword
          @what = options[:what]
        end

        def go
          find_options = { name: "%#{keyword}%", account_id: appshell.current_account.id }
          @result =
            case what.to_sym
            when :cs
              appshell.user.find_all_by_type(:cs, find_options).order(rating: :desc, name: :asc)
            when :document
              appshell.user.find_all_by_type(:document, find_options).order(is_folder: :desc, name: :asc)
            else
              raise "Don't know how find: '#{what}'."
            end
          show_result
        end

        private

        def show_result
          return interface.sys.text.on_empty.show unless result

          menu_param = { mode: :none, back_button: build_back_button_data }
          text_param = { text: "#{Emoji.t(:mag_right)} #{I18n.t(what.to_s)}: \"#{keyword}\"" }
          text_param[:text] = "#{text_param[:text]}\n\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if result.empty? 
          case what.to_sym
          when :cs
            menu_param[:title_params] = text_param
            interface.cs.menu(menu_param).list(result).show
          when :document
            interface.document.menu(menu_param.merge!(text_param)).list(result).show
          else
            raise "Don't know how find: '#{what}'."
          end
        end

        def take_keyword
          interface.sys.text.ask_find_keyword.show
          user_answer = appshell.ask_answer(mode: :once, answer_type: :string)
          return interface.sys.text.on_undefined.show unless user_answer

          user_answer.source
        end

        def build_back_button_data
          { mode: :custom, action: router.g(:main, :find, p: [type: what]).link,
            button_sign: I18n.t('find_again'), emoji: :mag, order: :ending }
        end
      end
    end
  end
end

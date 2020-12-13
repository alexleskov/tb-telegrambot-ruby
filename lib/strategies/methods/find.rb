# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Find < Teachbase::Bot::Strategies
        attr_reader :keyword, :result, :finder_type

        def initialize(controller, options)
          super(controller)
          @keyword = options[:keyword] || take_keyword
        end

        def cs
          @result = appshell.user.course_sessions_by(name: "%#{keyword}%", account_id: appshell.current_account.id)
                            .order(rating: :desc, name: :asc)
          @finder_type = :cs
          show_result
        end

        private

        def show_result
          return interface.sys.text.on_empty.show if !result && result.empty?

          interface.cs.menu(title_params: { text: "#{Emoji.t(:mag_right)} \"#{keyword}\"" }, mode: :none,
                            back_button: build_back_button_data).main(result).show
        end

        def take_keyword
          interface.sys.text.ask_find_keyword.show
          user_answer = appshell.ask_answer(mode: :once, answer_type: :string)
          return interface.sys.text.on_undefined.show unless user_answer

          user_answer.source
        end

        def build_back_button_data
          { mode: :custom, action: router.main(path: :find, p: [type: finder_type]).link,
            button_sign: I18n.t('find_again'), emoji: :mag }
        end

      end
    end
  end
end
